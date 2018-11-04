import ../nixpkgs/nixos/tests/make-test.nix ({ pkgs, lib, ... }:
  let
    run_firewall = true;
    run_gitolite = true;
    run_homeassistant = true;
    run_influxdb = true;
    run_mqtt = true;
    run_ntp = true;
    run_selfoss = true;
    run_startpage = true;
    run_syncthing = true;
    run_torproxy = true;
    run_unbound = true;
    run_ups = true;

    debug_unbound = false;

    # No advanced tests yet, not even if the service is up and reachable
    run_mpd = false;

    run_postgres = false;

    debug = false;

    inside_needed = run_firewall || run_selfoss || run_gitolite || run_ntp || run_mqtt || run_syncthing;
    outside_needed = run_firewall || run_torproxy || run_selfoss;

    testspkg = import ../lib/tests/default.nix {
      stdenv = pkgs.stdenv;
      bats = pkgs.bats;
      curl = pkgs.curl;
      git = pkgs.git;
      jq = pkgs.jq;
      mqtt_client = pkgs.callPackage ../lib/software/mqtt_client { inherit pkgs; };
    };

    extraHosts = ''
      # Could add extra name-address pairs here
    '';

    outside_node = if outside_needed then {
      outside = {config, pkgs, ...}:
        {
          virtualisation.memorySize = 256;
          virtualisation.vlans = [ 2 ];
          boot.kernelParams = [ "quiet" ];

          imports = [
            ../lib/tests/outsideweb.nix
          ];

          networking = {
            interfaces.eth0 = {
              useDHCP = false;
              ipv4.addresses = [];
              ipv6.addresses = [];
            };
            interfaces.eth1 = {
              useDHCP = false;
              ipv4.addresses = [ { address = "192.168.2.10"; prefixLength = 32; } ];
            };

            firewall.enable = false;
            /* nameservers = [ "192.168.1.240" ]; */

            inherit extraHosts;
          };

          services.outsideweb.enable = true;

          environment.systemPackages = [ pkgs.nmap ];
        };
    } else {};

    inside_node = if inside_needed then {
      inside = {config, pkgs, ...}:
        {
          virtualisation.memorySize = 256;
          virtualisation.vlans = [ 1 ];
          boot.kernelParams = [ "quiet" ];

          imports = [
            ../lib/users/arnold.nix
          ];

          networking = {
            nameservers = [ "192.168.1.240" ];
            interfaces = {
              eth0 = lib.mkOverride 10 {
                useDHCP = false;
                ipv4.addresses = [];
                ipv6.addresses = [];
              };
              eth1 = lib.mkOverride 10 {
                useDHCP = true;
                ipv4.addresses = [];
                ipv6.addresses = [ { address = "2001:470:1f0b:1033::696e:7369:6465"; prefixLength = 64; } ];
                macAddress = "7e:e2:63:7f:f0:0e";
              };
            };
            inherit extraHosts;
          };

          environment.systemPackages = [
            pkgs.git
            pkgs.nmap
            pkgs.openssh
            testspkg
            pkgs.ntp
          ];
        };
    } else {};

  in {
    name = "test-portal";

    nodes = {
      portal = {config, pkgs, ... }:
        {
          testdata = true;
          inherit debug_unbound;

          imports = [
            ../portal/default.nix
          ];
          virtualisation.memorySize = 2*1024;
          virtualisation.vlans = [ 1 2 ];

          boot.kernelParams = [ "quiet" ];

          networking = {
            interfaces = {
              eth0 = lib.mkOverride 10 {
                useDHCP = false;
                ipv4.addresses = [];
                ipv6.addresses = [];
              };
              eth1 = lib.mkOverride 1 {};
              eth2 = lib.mkOverride 1 {};
            };
            bridges = {
              lan.interfaces = lib.mkOverride 10 [ "eth1" ];
              dmz.interfaces = lib.mkOverride 10 [ "eth2" ];
            };
            inherit extraHosts;
          };

          containers.firewall.autoStart = lib.mkOverride 10 (run_firewall || run_selfoss);
          containers.gitolite.autoStart = lib.mkOverride 10 run_gitolite;
          containers.grafana.autoStart = lib.mkOverride 10 run_influxdb;
          containers.homeassistant.autoStart = lib.mkOverride 10 run_homeassistant;
          containers.influxdb.autoStart = lib.mkOverride 10 run_influxdb;
          containers.mpd.autoStart = lib.mkOverride 10 run_mpd;
          containers.mqtt.autoStart = lib.mkOverride 10 run_mqtt;
          containers.postgres.autoStart = lib.mkOverride 10 (run_postgres || run_selfoss);
          containers.selfoss.autoStart = lib.mkOverride 10 run_selfoss;
          containers.startpage.autoStart = lib.mkOverride 10 run_startpage;
          containers.syncthing.autoStart = lib.mkOverride 10 run_syncthing;
          containers.syncthing2.autoStart = lib.mkOverride 10 run_syncthing;
          containers.torproxy.autoStart = lib.mkOverride 10 run_torproxy;

          #containers.imap.autoStart = lib.mkOverride 10 false;
          #containers.cups.autoStart = lib.mkOverride 10 false;
        };
    } // outside_node // inside_node;

    testScript = ''

      subtest "set up", sub {
        $portal->start();

        $portal->waitForUnit("default.target");
        ${lib.optionalString run_torproxy
          ''$portal->waitForUnit("container\@torproxy");''
        }
      };

      subtest "admin environment", sub {
        $portal->execute("grep /etc/static/bashrc -e 'alias' >&2");
        $portal->succeed("grep /etc/static/bashrc -e 'vi=' >&2");
      };

      subtest "check basic interface setup", sub {
        $portal->succeed("ip link >&2");
        $portal->succeed("ip -4 a >&2");
        $portal->succeed("ip -6 a >&2");
        $portal->succeed("ip -6 a show dev lan >&2");
        $portal->succeed("ip -4 r >&2");
        $portal->succeed("ip -6 r >&2");
      };

      ${lib.optionalString run_unbound
        ''subtest "check unbound/dhcp", sub {
          $portal->succeed("unbound-checkconf /var/lib/unbound/unbound.conf >&2");
          $portal->succeed("systemctl is-active unbound >&2");
          #$portal->succeed("journalctl -u unbound >&2");
          #$portal->succeed("netstat -l -nv >&2");
          #$portal->succeed("iptables -L -nv >&2");
          $portal->succeed("host -v -t a portal.arnoldarts.de 127.0.0.1 >&2");
          $portal->succeed("host -v -t a portal.arnoldarts.de 192.168.1.240 >&2");

          $portal->succeed("unbound-control -c /var/lib/unbound/unbound.conf list_forwards |grep 8.8.8.8");

          $portal->succeed("systemctl is-active dhcpd4 >&2");
        };''
      }
      #$portal->succeed("iptables -L -nv >&2");
      #$portal->succeed("journalctl -u unbound >&2");


      subtest "check libvirtd", sub {
        $portal->succeed("getent group |grep libvirtd >&2");
        $portal->succeed("virsh list >&2");
        # Arnold should be allowed to do virsh commands
        $portal->succeed("id arnold |grep libvirtd");
        $portal->succeed("sudo -u arnold -l virsh list >&2");
      };

      subtest "check duply setup", sub {
        $portal->succeed("systemctl status duplyportal.timer >&2");
        $portal->succeed("systemctl status duplyamazon.timer >&2");
      };

      subtest "start other machines as needed", sub {
        ${lib.optionalString outside_needed
          ''$outside->start();''
        }
        ${lib.optionalString inside_needed
          ''$inside->start();''
        }
        ${lib.optionalString outside_needed
          ''$outside->waitForUnit("default.target");''
        }
        ${lib.optionalString inside_needed
          ''$inside->waitForUnit("default.target");''
        }
      };

      ${lib.optionalString run_ntp
        ''subtest "check ntp", sub {
          $inside->waitForUnit("default.target");
          $portal->fail("systemctl status ntpd >&2");
          $portal->succeed("systemctl status -n 10 -l openntpd >&2");
          $inside->succeed("ntpdate -q portal.arnoldarts.de |grep \"stratum 16\"");
        };''
      }

      ${lib.optionalString run_ups
        ''subtest "check ups", sub {
          $portal->execute("systemctl status -l -n 20 upsmon >&2");
          $portal->execute("systemctl status -l -n 20 upsd >&2");
          $portal->execute("systemctl status -l -n 20 upsdrv >&2");
          $portal->succeed("systemctl is-active upsd");
          $portal->succeed("systemctl is-active upsdrv");
          $portal->succeed("systemctl is-active upsmon");
          $portal->succeed("upsc -l >&2");
          $portal->succeed("upsc eaton >&2");
        };''
      }

      ${lib.optionalString run_firewall
        ''subtest "check outside connectivity", sub {
          $portal->waitForUnit("container\@firewall");

          $portal->execute("ip link >&2");
          $portal->succeed("ping -4 -n -c 1 -w 2 outside >&2");
          $portal->succeed("ping -4 -n -c 1 -w 2 outsideweb >&2");
          $portal->succeed("curl --connect-timeout 1 -s -f http://outsideweb >&2");

          $outside->execute("ip link >&2");
          $outside->execute("ip -4 a >&2");
          $outside->succeed("ping -4 -n -c 1 -w 2 192.168.2.220 >&2");

          $portal->execute("nixos-container run firewall -- ip link >&2");
          $portal->execute("nixos-container run firewall -- ip -4 a >&2");
          $portal->fail("nixos-container run firewall -- ping -4 -n -c 1 -w 2 192.168.2.10 >&2");

          $inside->execute("ip -4 a >&2");
          $inside->execute("ip -4 r >&2");
          $inside->succeed("ip r get 192.168.2.10 >&2");

          $inside->execute("cat /etc/resolv.conf >&2");
          $inside->execute("host -v -t any outsideweb.arnoldarts.de >&2");
          $inside->succeed("ping -4 -c 1 -w 2 -n outsideweb >&2");
          $inside->succeed("curl --connect-timeout 1 -s -f http://outsideweb >&2");
        };''
      }

      subtest "check containers connectivity", sub {
        ${lib.optionalString run_gitolite
          ''$portal->succeed("ping -4 -n -c 1 -w 2 gitolite >&2");
          $portal->succeed("ping -6 -n -c 1 -w 2 gitolite >&2");''
        }
        ${lib.optionalString run_mpd
          ''$portal->succeed("ping -4 -n -c 1 -w 2 mpd >&2");
          $portal->succeed("ping -6 -n -c 1 -w 2 mpd >&2");''
        }
        ${lib.optionalString run_firewall
          ''$portal->succeed("ping -4 -n -c 1 -w 2 firewall >&2");
          # The firewall machine doesn't yet answer ipv6 pings
          $portal->fail("ping -6 -n -c 1 -w 2 firewall >&2");''
        }
        ${lib.optionalString run_torproxy
          ''$portal->execute("journalctl -M torproxy -u tor >&2");

          # $portal->succeed("nixos-container run torproxy -- ip a >&2");
          # $portal->execute("nixos-container run torproxy -- iptables -L -nv >&2");
          # $portal->execute("nixos-container run torproxy -- ip6tables -L -nv >&2");
          # $portal->execute("nixos-container run torproxy -- netstat -l -nv >&2");

          $portal->succeed("ping -4 -n -c 1 -w 2 torproxy >&2");
          $portal->succeed("ping -6 -n -c 1 -w 2 torproxy >&2");
          $portal->succeed("nixos-container run torproxy -- netstat -l -nv |grep 8118");
          $portal->execute("nmap -4 --open -n -p 9050,9063,8118 torproxy -oG - >&2");
          # FIXME: Somehow its not correctly checking the ports. But tor is hard to test without connecting to other tor nodes.
          #$portal->succeed("nmap -4 --open -n -p 9050 torproxy -oG - |grep -e \"Ports\" |grep -e \"9050\" >&2");
          #$portal->succeed("nmap -4 --open -n -p 9063 torproxy -oG - |grep -e \"Ports\" |grep -e \"9063\" >&2");
          #$portal->succeed("nmap -4 --open -n -p 8118 torproxy -oG - |grep -e \"Ports\" |grep -e \"8118\"");
          $outside->fail("nmap -4 --open -n -p 9050 192.168.2.225 -oG - |grep -e \"Ports\" |grep -e \"9050\" >&2");
          $outside->fail("nmap -4 --open -n -p 9063 192.168.2.225 -oG - |grep -e \"Ports\" |grep -e \"9063\" >&2");
          $outside->fail("nmap -4 --open -n -p 8118 192.168.2.225 -oG - |grep -e \"Ports\" |grep -e \"8118\" >&2");
          ''
        }
      };

      ${lib.optionalString run_mpd
        ''subtest "check mpd container shutdown", sub {
          $portal->execute("nixos-container stop mpd >&2");
          $portal->fail("ping -4 -n -c 1 -w 2 mpd >&2");
        };''
      }

      ${lib.optionalString run_startpage
        ''subtest "Check startpage", sub {
          $portal->waitForUnit("container\@startpage");
          $portal->succeed("curl --connect-timeout 1 --insecure -f https://startpage.arnoldarts.de/ >&2");
        };''
      }

      ${lib.optionalString run_gitolite
        ''subtest "Check gitolite", sub {
          $portal->waitForUnit("container\@gitolite");
          # $portal->succeed("journalctl -M gitolite -u gitolite-init >&2");
          # $portal->succeed("journalctl -M gitolite -u git-daemon >&2");
          $portal->succeed("systemctl -M gitolite status gitolite-init >&2");
          # $portal->succeed("systemctl -M gitolite list-dependencies git-daemon >&2");
          $portal->succeed("systemctl -M gitolite status git-daemon >&2");
          # $portal->succeed("nixos-container run gitolite -- ls -la /var/lib/gitolite >&2");
          # $portal->succeed("nixos-container run gitolite -- ls -la /var/lib/gitolite/repositories >&2");
          # $portal->succeed("nixos-container run gitolite -- cat /var/lib/gitolite/.gitolite.rc >&2");
          $portal->succeed("grep 0027 /var/lib/containers/gitolite/var/lib/gitolite/.gitolite.rc >&2");
          $inside->waitForUnit("default.target");
          # $inside->succeed("curl --connect-timeout 1 -s http://gitolite/gitweb/ |grep \"404 - No projects found\" >&2");
          $inside->fail("curl --connect-timeout 1 -s http://gitolite/gitweb/ >&2");
          $inside->succeed("test_gitolite >&2");
        };
        # $portal->succeed("nixos-container run gitolite -- ls -la /var/lib/gitolite >&2");
        # $portal->succeed("nixos-container run gitolite -- ls -la /var/lib/gitolite/repositories >&2");
        ''
      }

      ${lib.optionalString run_postgres
        ''subtest "Check postgres", sub {
          # start up
          $portal->waitForUnit("container\@postgres");
          $portal->succeed("journalctl -M postgres -u postgresql >&2");
          $portal->succeed("systemctl -M postgres status postgresql >&2");
          $portal->succeed("nixos-container run postgres -- psql -l >&2");

          # backup dump works
          $portal->succeed("systemctl -M postgres start postgresql-dump.service >&2");
          sleep(1);
          $portal->succeed("ls -lha /var/lib/containers/postgres/var/backup/postgresql >&2");
          $portal->succeed("journalctl -M postgres -u postgresql-dump.service -l -n 50 >&2");
          $portal->fail("systemctl -M postgres is-failed postgresql-dump.service >&2");
          $portal->succeed("[ -f /var/lib/containers/postgres/var/backup/postgresql/complete_dump.sql.gz ]");

          # backup dump has a timer
          $portal->succeed("systemctl -M postgres status postgresql-dump.timer >&2");
        };''
      }

      ${lib.optionalString run_selfoss
        ''subtest "Check selfoss", sub {
          # Preparation
          $outside->succeed("systemctl status -l -n 40 nginx >&2");
          $portal->succeed("nixos-container run selfoss -- ip r get 192.168.2.10 >&2");
          $portal->succeed("nixos-container run selfoss -- ping -4 -n -c 1 -w 2 outsideweb >&2");
          $portal->succeed("nixos-container run selfoss -- curl --connect-timeout 1 -s -f http://outsideweb >&2");
          $portal->succeed("nixos-container run selfoss -- curl --connect-timeout 1 -s -f http://outsideweb/feed.atom >&2");

          # Services
          $portal->waitForUnit("container\@selfoss");
          $portal->succeed("ping -4 -n -c 1 selfoss >&2");
          $portal->succeed("nixos-container run selfoss -- ping -4 -n -c 2 192.168.6.1 >&2");
          $portal->succeed("nixos-container run selfoss -- netstat -l -nv >&2");
          $portal->succeed("journalctl -M selfoss -u phpfpm-selfoss >&2");
          $portal->succeed("journalctl -M selfoss -u nginx >&2");
          $portal->succeed("systemctl -M selfoss status nginx >&2");
          $portal->succeed("systemctl -M selfoss status phpfpm-selfoss >&2");

          # check update service
          $portal->succeed("systemctl -M selfoss status selfoss_update.timer >&2");
          $portal->succeed("nixos-container run selfoss -- systemctl start selfoss_update.service >&2");
          $portal->execute("journalctl -M selfoss -u selfoss_update >&2");
          $portal->succeed("systemctl -M selfoss status selfoss_update.service >&2");

          # access selfoss webinterface from container and from inside
          $portal->fail("curl --insecure --connect-timeout 1 -s -f https://selfoss/ >&2");
          $portal->succeed("curl --anyauth --user user:password --insecure --connect-timeout 1 -s -f https://selfoss/ >&2");
          $inside->waitForUnit("default.target");
          $inside->succeed("curl -4 --anyauth --user user:password --insecure -s -f https://selfoss.arnoldarts.de/ >&2");
          $inside->succeed("curl -6 --anyauth --user user:password --insecure -s -f https://selfoss/ >&2");

          # Add Feed, fetch Feed
          $inside->succeed("test_selfoss >&2");
        };''
      }
      ${lib.optionalString (run_selfoss && debug)
        ''subtest "selfoss debugging", sub {
          #$portal->succeed("curl -f http://selfoss/ >&2");
          #$portal->succeed("curl --connect-timeout 1 -s http://selfoss/sources/list >&2");
          $portal->succeed("journalctl -M selfoss -u phpfpm-selfoss >&2");
          $portal->succeed("journalctl -M selfoss -u nginx >&2");
          #$portal->succeed("nixos-container run postgres -- psql -l >&2");
          #$portal->succeed("nixos-container run postgres -- psql selfoss -c \"\\dp\" >&2");
          $portal->succeed("nixos-container run selfoss -- ls -la /var/lib/selfoss/arnold >&2");
          $portal->succeed("nixos-container run selfoss -- ls -la /var/lib/selfoss/arnold/data/favicons/ >&2");
          #$portal->succeed("nixos-container run selfoss -- ls -la /var/lib/selfoss/arnold/data/logs >&2");
          #$portal->execute("nixos-container run selfoss -- cat /var/lib/selfoss/arnold/data/logs/default.log >&2");
          #$portal->succeed("nixos-container run selfoss -- cat /var/lib/selfoss/arnold/config.ini >&2");

          $outside->succeed("journalctl -u nginx >&2");
        };''
      }

      ${lib.optionalString run_syncthing
        ''subtest "Check syncthing", sub {
          $portal->execute("nixos-container run syncthing -- netstat -l -nv >&2");
          $portal->execute("nixos-container run syncthing -- systemctl -l status syncthing >&2");
          $portal->execute("nixos-container run syncthing -- ls -la /var/lib/syncthing >&2");
          $portal->execute("nixos-container run syncthing -- ls -la /var/lib/ >&2");
          $inside->succeed("ping -4 -n -c 1 syncthing >&2");
          $inside->succeed("ping -6 -n -c 1 syncthing >&2");
          $inside->succeed("curl -4 -s -f http://syncthing >&2");
          $inside->succeed("curl -4 --insecure -s -f https://syncthing >&2");
        };
        subtest "Check syncthing for ines", sub {
          #$portal->execute("nixos-container run syncthing2 -- netstat -l -nv >&2");
          #$portal->execute("nixos-container run syncthing2 -- systemctl -l status syncthing >&2");
          #$portal->execute("nixos-container run syncthing2 -- ls -la /var/lib/syncthing >&2");
          #$portal->execute("nixos-container run syncthing2 -- ls -la /var/lib/ >&2");
          $inside->succeed("ping -4 -n -c 1 syncthing2 >&2");
          $inside->succeed("ping -6 -n -c 1 syncthing2 >&2");
          $inside->succeed("curl -4 -s -f http://syncthing2 >&2");
          $inside->succeed("curl -4 --insecure -s -f https://syncthing2 >&2");
        };''
      }

      ${lib.optionalString run_homeassistant
        ''subtest "Check homeassistant", sub {
          $portal->succeed("host -t a homeassistant >&2");
          $portal->succeed("host -t aaaa homeassistant >&2");
          $portal->succeed("ping -4 -n -c 1 homeassistant >&2");
          $portal->succeed("ping -6 -n -c 1 homeassistant >&2");
          $portal->waitUntilSucceeds("nixos-container run homeassistant -- netstat -l -nv |grep 8123 ");
          $portal->waitUntilSucceeds("test -f /var/lib/containers/homeassistant/root/.homeassistant/configuration.yaml");
          $portal->execute("nixos-container run homeassistant -- systemctl -l status homeassistant >&2");
          #$portal->execute("nixos-container run homeassistant -- journalctl -u homeassistant >&2");
          $portal->execute("nixos-container run homeassistant -- systemctl -l status nginx >&2");
          $portal->succeed("nixos-container run homeassistant -- curl -4 -s -f --max-time 5 http://localhost:8123 >&2");
          $portal->fail("curl -4 -s -f --max-time 5 http://homeassistant:8123 >&2");
          $portal->succeed("curl -4 --insecure -s -f https://homeassistant/api/ >&2");
          $portal->succeed("curl -6 --insecure -s -f https://homeassistant/api/ >&2");
          $portal->execute("curl --insecure -s -f https://homeassistant/ || journalctl -M homeassistant -u homeassistant >&2");
          $portal->succeed("curl --insecure -s -f https://homeassistant/ >&2");

          $portal->waitUntilSucceeds("journalctl -M homeassistant -u dash_button_daemon --boot |grep \"ready for action\"");
          $portal->succeed("systemctl -M homeassistant is-active dash_button_daemon || journalctl -M homeassistant -u dash_button_daemon --boot >&2");

          $portal->succeed("nixos-container run homeassistant -- dash_button_test >&2");
          $portal->succeed("nixos-container run homeassistant -- dash_button_test event >&2");
          $portal->waitUntilSucceeds("journalctl -M homeassistant -u homeassistant |grep light.benachrichtigung >&2");
          $portal->waitUntilSucceeds("journalctl -M homeassistant -u homeassistant |grep dash_button_pressed >&2");
          $portal->waitUntilSucceeds("journalctl -M homeassistant -u homeassistant |grep dash_button_pressed |grep ac:63:be:be:01:95 >&2");
        };''
      }

      ${lib.optionalString run_mqtt
        ''subtest "mqtt testing", sub {
          $portal->succeed("systemctl status container\@mqtt >&2");
          $portal->succeed("systemctl -M mqtt status mosquitto >&2");
          $portal->succeed("host -t a mqtt >&2");
          $portal->succeed("host -t aaaa mqtt >&2");
          $portal->succeed("ping -4 -n -c 2 mqtt >&2");
          $portal->succeed("ping -6 -n -c 2 mqtt >&2");

          #$portal->execute("nmap -4 mqtt -n -p 1883 >&2");
          #$portal->succeed("nmap -4 mqtt -n -p 1883 |grep filtered >&2");

          $portal->succeed("[ -d /var/lib/containers/mqtt/var/lib/mosquitto ]");

          $inside->succeed("test_mqtt >&2");
        };''
      }
      ${lib.optionalString (!run_mqtt)
        ''subtest "mqtt not reachable", sub {
          $portal->fail("ping -4 -n -c 1 mqtt >&2");
        };''
      }

      ${lib.optionalString run_influxdb
        ''subtest "influxdb testing", sub {
          $portal->succeed("systemctl status container\@influxdb >&2");
          $portal->succeed("systemctl -M influxdb status influxdb >&2");
          $portal->fail("nixos-container run influxdb -- netstat -l -nv |grep 127.0.0.1:8086");
          $portal->succeed("nixos-container run influxdb -- netstat -l -nv |grep :8086");
          $portal->succeed("nixos-container run influxdb -- influx -execute 'SHOW DATABASES' >&2");
        };

        subtest "grafana", sub {
          $portal->succeed("systemctl status container\@grafana >&2");
          $portal->succeed("systemctl -M grafana status grafana >&2");
          $portal->succeed("curl -4 --insecure -f https://grafana >&2");
        };''
      }
      ${lib.optionalString (!run_influxdb)
        ''subtest "influxdb not running", sub {
          $portal->fail("systemctl status container\@influxdb >&2");
        };''
      }
      ${lib.optionalString (run_influxdb && run_homeassistant)
        ''subtest "homeassistant access to influxdb", sub {
          $portal->succeed("nixos-container run homeassistant -- curl -4 http://192.168.6.17:8086 >&2");
        };''
      }

      #$inside->shutdown();
      #$portal->shutdown();
      ${lib.optionalString outside_needed
        ''#$outside->shutdown();''
      }
    '';
  }
)
