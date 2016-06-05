import ./nixpkgs/nixos/tests/make-test.nix ({ pkgs, lib, ... }:
  let
    run_gitolite = true;
    run_mpd = true;
    run_firewall = true;
  in {
    name = "test-portal";

    nodes = {
      portal = {config, pkgs, ... }:
        {
          imports = [
            ./portal/default.nix
          ];
          virtualisation.memorySize = 2*1024;
          virtualisation.vlans = [ 1 2 ];

          networking.nameservers = lib.mkOverride 1 [
            "192.168.1.240"
          ];
          networking.interfaces.eth1 = lib.mkOverride 1 {};
          networking.interfaces.eth2 = lib.mkOverride 1 {};
          networking.bridges.lan.interfaces = lib.mkOverride 10 [ "eth1" ];

          containers.firewall.autoStart = lib.mkOverride 10 run_firewall;
          containers.firewall.interfaces = lib.mkOverride 10 [ "eth2" ];
          containers.mpd.autoStart = lib.mkOverride 10 run_mpd;
          containers.gitolite.autoStart = lib.mkOverride 10 run_gitolite;
          containers.imap.autoStart = lib.mkOverride 10 false;
          containers.cups.autoStart = lib.mkOverride 10 false;
        };
      outside = {config, pkgs, ...}:
        {
          virtualisation.memorySize = 512;
          virtualisation.vlans = [ 2 ];

          networking.interfaces.eth1 = {
            useDHCP = false;
            ip4 = [ { address = "192.168.2.10"; prefixLength = 24; } ];
          };

          networking.firewall.enable = false;
        };
    };

    testScript = ''

      subtest "set up", sub {
        $outside->start();
        $portal->start();

        $portal->waitForUnit("default.target");
        # $portal->waitForUnit("container\@gitolite");
      };

      subtest "check unbound", sub {
        $portal->succeed("unbound-checkconf /var/lib/unbound/unbound.conf >&2");

        $portal->succeed("systemctl is-active unbound >&2");
      };

      subtest "check basic interface setup", sub {
        $portal->succeed("ip link >&2");
        $portal->succeed("ip -4 a >&2");
        $portal->succeed("ip -6 a >&2");
        $portal->succeed("ip -6 a show dev lan >&2");
        $portal->succeed("ip -4 r >&2");
        $portal->succeed("ip -6 r >&2");
      };

      ${lib.optionalString run_firewall
        ''subtest "check outside connectivity", sub {
          $portal->fail("ping -n -c 1 -w 2 192.168.2.10 >&2");
          # $outside->execute("ip -4 a >&2");
          $outside->succeed("ping -n -c 1 -w 2 192.168.2.20 >&2");
          # $portal->execute("nixos-container run firewall -- ip -4 a >&2");
          $portal->execute("nixos-container run firewall -- ping -n -c 1 -w 2 192.168.2.10 >&2");
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
      };

      ${lib.optionalString run_mpd
        ''subtest "check container shutdown", sub {
          $portal->execute("nixos-container stop mpd >&2");
          $portal->fail("ping -n -c 1 -w 2 mpd >&2");
        };''
      }

      $portal->shutdown();
    '';
  }
)