import ../nixpkgs/nixos/tests/make-test.nix ({ pkgs, lib, ... }:
  let
    run_headless = true;
  in {
    name = "test-orinoco";

    nodes = {
      orinoco = {config, pkgs, ... }:
        {
          imports = [
            ./default.nix
          ];
          virtualisation.memorySize = 1024;
          virtualisation.vlans = [ 1 ];
          nix.buildCores = 3;
        };
    };

    testScript = ''

      subtest "set up", sub {
        $orinoco->start();

        $orinoco->waitForUnit("multi-user.target");
      };

      subtest "networking", sub {
        $orinoco->succeed("systemctl status network-manager >&2");
      };

      subtest "admin environment", sub {
        ${lib.concatStringsSep "\n" (
          map
            (app: ''$orinoco->succeed("which ${app} >&2");'')
            [ "git-crypt" "claws-mail" "tig" "virtualenv" "pwsafe" "python3" "atom" ]
        )}

        $orinoco->execute("grep /etc/static/bashrc -e 'alias' >&2");
        $orinoco->succeed("grep /etc/static/bashrc -e 'vi=' >&2");
        # $orinoco->succeed("grep /etc/static/bashrc -e 'vinox=' >&2");
      };

      subtest "arnolds environment", sub {
        $orinoco->succeed("test -d /home/arnold >&2");
      };

      $orinoco->shutdown();
    '';
  }
)