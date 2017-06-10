import ../nixpkgs/nixos/tests/make-test.nix ({ pkgs, lib, ... }:
  let
    run_unbound = false;
    run_firewall = false;
    run_gitolite = false;
    run_mqtt = true;
    run_ntp = false;
    run_pyheim = false;
    run_selfoss = false;
    run_torproxy = false;

    # No advanced tests yet, not even if the service is up and reachable
    run_mpd = false;

    run_postgres = false;

    debug = false;

    inside_needed = run_firewall || run_selfoss || run_gitolite || run_ntp || run_mqtt;
    outside_needed = run_firewall || run_torproxy || run_selfoss;

    testspkg = import ../lib/tests/default.nix {
      stdenv = pkgs.stdenv;
      bats = pkgs.bats;
      curl = pkgs.curl;
      git = pkgs.git;
      jq = pkgs.jq;
      mqtt_client = pkgs.callPackage ../lib/software/mqtt_client {};
    };

    extraHosts = ''
      # Could add extra name-address pairs here
    '';

  in {
    name = "test-portal";

    nodes = {
      portal = {config, pkgs, ... }:
        {
          testdata = true;
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
                ip4 = [];
                ip6 = [];
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
          /*containers.mpd.autoStart = lib.mkOverride 10 run_mpd;*/
          /*containers.mqtt.autoStart = lib.mkOverride 10 run_mqtt;*/
          /*containers.postgres.autoStart = lib.mkOverride 10 (run_postgres || run_selfoss);*/
          /*containers.pyheim.autoStart = lib.mkOverride 10 run_pyheim;*/
          /*containers.selfoss.autoStart = lib.mkOverride 10 run_selfoss;*/
          containers.torproxy.autoStart = lib.mkOverride 10 run_torproxy;

          containers.imap.autoStart = lib.mkOverride 10 false;
          containers.cups.autoStart = lib.mkOverride 10 false;
        };
      outside = {config, pkgs, ...}:
        {
          virtualisation.memorySize = 256;
          virtualisation.vlans = [ 2 ];
          boot.kernelParams = [ "quiet" ];

          imports = [
            ../lib/tests/outsideweb.nix
          ];

          networking = {
            interfaces.eth1 = {
              useDHCP = false;
              ip4 = [ { address = "192.168.2.10"; prefixLength = 32; } ];
            };

            firewall.enable = false;

            inherit extraHosts;
          };

          services.outsideweb.enable = true;

          environment.systemPackages = [ pkgs.nmap ];
        };
      inside = {config, pkgs, ...}:
        {
          virtualisation.memorySize = 256;
          virtualisation.vlans = [ 1 ];
          boot.kernelParams = [ "quiet" ];

          imports = [
            ../lib/users/arnold.nix
          ];

          networking = {
            interfaces = {
              eth0 = lib.mkOverride 10 {
                useDHCP = false;
                ip4 = [];
                ip6 = [];
              };
              eth1 = lib.mkOverride 10 {
                useDHCP = true;
                ip4 = [];
                ip6 = [ { address = "2001:470:1f0b:1033::696e:7369:6465"; prefixLength = 64; } ];
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
    };

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
          # $portal->succeed("nixos-container run torproxy -- iptables -L -nv >&2");
          # $portal->succeed("nixos-container run torproxy -- ip6tables -L -nv >&2");

          $portal->succeed("ping -4 -n -c 1 -w 2 torproxy >&2");
          $portal->succeed("ping -6 -n -c 1 -w 2 torproxy >&2");
          $portal->succeed("nmap --open -n -p 9050 torproxy -oG - |grep \"/open\"");
          $portal->succeed("nmap --open -n -p 9063 torproxy -oG - |grep \"/open\"");
          $portal->succeed("nmap --open -n -p 8118 torproxy -oG - |grep \"/open\"");
          $outside->fail("nmap --open -n -p 9050 192.168.2.225 -oG - |grep \"/open\"");
          $outside->fail("nmap --open -n -p 9063 192.168.2.225 -oG - |grep \"/open\"");
          $outside->fail("nmap --open -n -p 8118 192.168.2.225 -oG - |grep \"/open\"");
          ''
        }
      };

      ${lib.optionalString run_mpd
        ''subtest "check mpd container shutdown", sub {
          $portal->execute("nixos-container stop mpd >&2");
          $portal->fail("ping -4 -n -c 1 -w 2 mpd >&2");
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

      ${lib.optionalString run_pyheim
        ''subtest "Check pyheim", sub {
          $portal->waitForUnit("container\@pyheim");
          $portal->succeed("nixos-container run pyheim -- pyheim_get_all --help >&2");
          $portal->succeed("systemctl -M pyheim status pyheim_colortemp_daytime.timer >&2");
          $portal->succeed("systemctl -M pyheim status pyheim_colortemp_night.timer >&2");
          $portal->succeed("systemctl -M pyheim status pyheim_spots_off.timer >&2");
        };''
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
          $portal->succeed("journalctl -M selfoss -u phpfpm >&2");
          $portal->succeed("journalctl -M selfoss -u nginx >&2");
          $portal->succeed("systemctl -M selfoss status nginx >&2");
          $portal->succeed("systemctl -M selfoss status phpfpm >&2");

          # check update service
          $portal->succeed("systemctl -M selfoss status selfoss_update.timer >&2");
          $portal->succeed("nixos-container run selfoss -- systemctl start selfoss_update.service >&2");
          $portal->execute("journalctl -M selfoss -u selfoss_update >&2");
          $portal->succeed("systemctl -M selfoss status selfoss_update.service >&2");

          # access selfoss webinterface from container and from inside
          $portal->succeed("curl --connect-timeout 1 -s -f http://selfoss/");
          $inside->waitForUnit("default.target");
          $inside->succeed("curl -4 -s -f http://selfoss/");
          $inside->succeed("curl -6 -s -f http://selfoss/");

          # Add Feed, fetch Feed
          $inside->succeed("test_selfoss >&2");
        };''
      }
      ${lib.optionalString (run_selfoss && debug)
        ''subtest "selfoss debugging", sub {
          #$portal->succeed("curl -f http://selfoss/ >&2");
          #$portal->succeed("curl --connect-timeout 1 -s http://selfoss/sources/list >&2");
          $portal->succeed("journalctl -M selfoss -u phpfpm >&2");
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

      ${lib.optionalString run_mqtt
        ''subtest "mqtt testing", sub {
          $portal->succeed("systemctl status container\@mqtt >&2");
          $portal->succeed("systemctl -M mqtt status mosquitto >&2");
          $portal->succeed("host -t a mqtt >&2");
          $portal->succeed("host -t aaaa mqtt >&2");
          $portal->succeed("ping -4 -n -c 2 mqtt >&2");
          $portal->succeed("ping -6 -n -c 2 mqtt >&2");

          $portal->execute("nmap -4 mqtt -n -p 1883 >&2");
          $portal->succeed("nmap -4 mqtt -n -p 1883 |grep filtered >&2");

          $portal->succeed("[ -d /var/lib/containers/mqtt/var/lib/mosquitto ]");

          $inside->succeed("test_mqtt >&2");
        };''
      }
      ${lib.optionalString (!run_mqtt)
        ''subtest "mqtt not reachable", sub {
          $portal->fail("ping -4 -n -c 1 mqtt >&2");
        }''
      }

      #$inside->shutdown();
      #$portal->shutdown();
      ${lib.optionalString outside_needed
        ''#$outside->shutdown();''
      }
    '';
  }
)