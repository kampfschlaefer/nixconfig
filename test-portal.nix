import ./nixpkgs/nixos/tests/make-test.nix ({ pkgs, lib, ... }:
  let
    run_gitolite = true;
    run_mpd = true;
    run_firewall = true;
    run_torproxy = true;
    run_pyheim = true;
    run_ntp = true;

    outside_needed = run_firewall || run_torproxy;
    inside_needed = run_gitolite || run_ntp;

    testspkg = import ./lib/tests/default.nix {
      stdenv = pkgs.stdenv; bats = pkgs.bats; curl = pkgs.curl;
    };

  in {
    name = "test-portal";

    nodes = {
      portal = {config, pkgs, ... }:
        {
          testdata = true;
          imports = [
            ./portal/default.nix
          ];
          virtualisation.memorySize = 2*1024;
          virtualisation.vlans = [ 1 2 ];

          networking.interfaces.eth0 = lib.mkOverride 10 {
            useDHCP = false;
            ip4 = [];
            ip6 = [];
          };
          networking.interfaces.eth1 = lib.mkOverride 1 {};
          networking.interfaces.eth2 = lib.mkOverride 1 {};
          networking.bridges.lan.interfaces = lib.mkOverride 10 [ "eth1" ];
          networking.bridges.dmz.interfaces = lib.mkOverride 10 [ "eth2" ];

          containers.firewall.autoStart = lib.mkOverride 10 run_firewall;
          containers.mpd.autoStart = lib.mkOverride 10 run_mpd;
          containers.gitolite.autoStart = lib.mkOverride 10 run_gitolite;
          containers.torproxy.autoStart = lib.mkOverride 10 run_torproxy;
          containers.pyheim.autoStart = lib.mkOverride 10 run_pyheim;
          containers.imap.autoStart = lib.mkOverride 10 false;
          containers.cups.autoStart = lib.mkOverride 10 false;
        };
      outside = {config, pkgs, ...}:
        {
          virtualisation.memorySize = 512;
          virtualisation.vlans = [ 2 ];

          networking.interfaces.eth1 = {
            useDHCP = false;
            ip4 = [ { address = "192.168.2.10"; prefixLength = 32; } ];
          };

          networking.firewall.enable = false;

          environment.systemPackages = [ pkgs.nmap ];
        };
      inside = {config, pkgs, ...}:
        {
          virtualisation.memorySize = 256;
          virtualisation.vlans = [ 1 ];

          imports = [
            ./lib/users/arnold.nix
          ];

          networking.interfaces.eth0 = lib.mkOverride 10 {
            useDHCP = false;
            ip4 = [];
            ip6 = [];
          };
          networking.interfaces.eth1 = {
            useDHCP = true;
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
        ${lib.optionalString outside_needed
          ''$outside->start();''
        }
        ${lib.optionalString inside_needed
          ''$inside->start();''
        }

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

      subtest "check unbound/dhcp", sub {
        $portal->succeed("unbound-checkconf /var/lib/unbound/unbound.conf >&2");

        $portal->succeed("systemctl is-active unbound >&2");

        $portal->succeed("systemctl is-active dhcpd >&2");
      };

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
          $portal->execute("ip link >&2");
          $portal->succeed("ping -n -c 1 -w 2 192.168.2.10 >&2");
          $outside->execute("ip link >&2");
          $outside->execute("ip -4 a >&2");
          $outside->succeed("ping -n -c 1 -w 2 192.168.2.220 >&2");
          $portal->execute("nixos-container run firewall -- ip link >&2");
          $portal->execute("nixos-container run firewall -- ip -4 a >&2");
          $portal->fail("nixos-container run firewall -- ping -n -c 1 -w 2 192.168.2.10 >&2");
        };''
      }

      subtest "check containers connectivity", sub {
        ${lib.optionalString run_gitolite
          ''$portal->succeed("ping -n -c 1 -w 2 gitolite >&2");
          $portal->succeed("ping6 -n -c 1 -w 2 gitolite >&2");''
        }
        ${lib.optionalString run_mpd
          ''$portal->succeed("ping -n -c 1 -w 2 mpd >&2");
          $portal->succeed("ping6 -n -c 1 -w 2 mpd >&2");''
        }
        ${lib.optionalString run_firewall
          ''$portal->succeed("ping -n -c 1 -w 2 firewall >&2");
          # The firewall machine doesn't yet answer ipv6 pings
          $portal->fail("ping6 -n -c 1 -w 2 firewall >&2");''
        }
        ${lib.optionalString run_torproxy
          ''$portal->execute("journalctl -M torproxy -u tor >&2");

          # $portal->succeed("nixos-container run torproxy -- ip a >&2");
          # $portal->succeed("nixos-container run torproxy -- iptables -L -nv >&2");
          # $portal->succeed("nixos-container run torproxy -- ip6tables -L -nv >&2");

          $portal->succeed("ping -n -c 1 -w 2 torproxy >&2");
          $portal->succeed("ping6 -n -c 1 -w 2 torproxy >&2");
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
          $portal->fail("ping -n -c 1 -w 2 mpd >&2");
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
          # $inside->succeed("curl -s http://gitolite/gitweb/ |grep \"404 - No projects found\" >&2");
          $inside->fail("curl -s http://gitolite/gitweb/ >&2");
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

      #$inside->shutdown();
      #$portal->shutdown();
      ${lib.optionalString outside_needed
        ''#$outside->shutdown();''
      }
    '';
  }
)