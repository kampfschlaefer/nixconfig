import ./nixpkgs/nixos/tests/make-test.nix ({ pkgs, lib, ... }:
  let
  in {
    name = "test-portal";

    machine = {config, pkgs, ... }:
      {
        imports = [
          ./portal/default.nix
        ];
        virtualisation.memorySize = 2*1024;
        virtualisation.vlans = [ 1 2 ];

        networking.interfaces.eth1 = lib.mkOverride 1 {};
        networking.interfaces.eth2 = lib.mkOverride 1 {};
        networking.bridges.lan.interfaces = lib.mkOverride 10 [ "eth1" ];

        containers.firewall.autoStart = lib.mkOverride 10 true;
        containers.firewall.interfaces = lib.mkOverride 10 [ "eth2" ];
        containers.mpd.autoStart = lib.mkOverride 10 true;
        containers.gitolite.autoStart = lib.mkOverride 10 true;
        containers.imap.autoStart = lib.mkOverride 10 false;
        containers.cups.autoStart = lib.mkOverride 10 false;
      };

    testScript = ''

      $portal->start();

      $portal->waitForUnit("default.target");

      # sleep 10;

      $portal->succeed("ip link >&2");
      $portal->succeed("ip -4 a >&2");
      $portal->succeed("ip -6 a >&2");
      $portal->succeed("ip -6 a show dev lan >&2");
      $portal->succeed("ip -4 r >&2");
      $portal->succeed("ip -6 r >&2");

      $portal->succeed("ping -n -c 1 -w 2 gitolite >&2");
      $portal->succeed("ping -n -c 1 -w 2 mpd >&2");
      $portal->succeed("ping -n -c 1 -w 2 firewall >&2");

      $portal->succeed("ping6 -n -c 1 -w 2 gitolite >&2");
      $portal->succeed("ping6 -n -c 1 -w 2 mpd >&2");
      # The firewall machine doesn't yet answer ipv6 pings
      $portal->fail("ping6 -n -c 1 -w 2 firewall >&2");

      $portal->execute("nixos-container stop mpd >&2");
      $portal->fail("ping -n -c 1 -w 2 mpd >&2");

      $portal->shutdown();
    '';
  }
)