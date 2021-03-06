{ config, lib, pkgs, ...}:

with lib;

let
  cfg = config.services.homeassistant;

  homeassistant_env = import ./requirements.nix { inherit pkgs; };
  homeassistant = builtins.trace (attrNames homeassistant_env.interpreter.out) "blub" /*homeassistant_env.packages."homeassistant"*/;

in {
  options = {
    services.homeassistant = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable the homeassistant as a systemd service.
        '';
      };
      api_password = mkOption {
        type = types.string;
        default = "";
        description = ''
          API Password to secure access
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.homeassistant = {
      path = [ pkgs.iputils ];
      script = ''
        ${homeassistant_env.interpreter.out}/bin/python -m homeassistant --skip-pip
      '';
      wantedBy = [ "multi-user.target" ];
    };
  };
}