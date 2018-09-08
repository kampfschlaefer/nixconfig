import ../../../nixpkgs/nixos/tests/make-test.nix ({ pkgs, lib, ... }:

{
  name = "homeassistant";

  machine =
    { config, pkgs, ... }:
    {
      imports = [
        ./service.nix
      ];
      services.homeassistant.enable = true;
    };

  testScript = ''
    startAll;
    $machine->waitUntilSucceeds("netstat -l -nv |grep 8123 ");
    $machine->waitUntilSucceeds("test -f /root/.homeassistant/configuration.yaml");
    $machine->execute("cat /root/.homeassistant/configuration.yaml >&2");
    $machine->execute("systemctl -l status homeassistant >&2");
    $machine->execute("journalctl -u homeassistant >&2");
    $machine->succeed("curl -4 -s -f --max-time 5 http://localhost:8123 >&2");
    $machine->succeed("curl -4 --include --max-time 5 http://localhost:8123/api/ |grep \" 401 \" >&2");
  '';
})