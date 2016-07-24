import ./nixpkgs/nixos/tests/make-test.nix ({ pkgs, lib, ... }:
  let
    run_headless = true;
  in {
    name = "test-orinoco";

    nodes = {
      orinoco = {config, pkgs, ... }:
        {
          imports = [
            ./orinoco/default.nix
          ];
          virtualisation.memorySize = 1024;
          virtualisation.vlans = [ 1 ];
        };
    };

    testScript = ''

      subtest "set up", sub {
        $orinoco->start();

        $orinoco->waitForUnit("default.target");
      };

      subtest "admin environment", sub {
        $orinoco->succeed("which git-crypt >&2");
        $orinoco->succeed("which sensors >&2");

        $orinoco->execute("grep /etc/static/bashrc -e 'alias' >&2");
        $orinoco->succeed("grep /etc/static/bashrc -e 'vi=' >&2");
        $orinoco->succeed("grep /etc/static/bashrc -e 'vinox=' >&2");
      };

      $orinoco->shutdown();
    '';
  }
)