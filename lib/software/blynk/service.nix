{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.blynk-server;
  jre = pkgs.jre;
  blynkserver = pkgs.callPackage ./default.nix {};
  blynkdir = "/var/lib/blynk";
in {
  options = {
    services.blynk-server = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Activate the blynk server.
        '';
      };
    };
  };

  config = mkIf cfg.enable {

    users.extraUsers.blynk = {
      name = "blynk";
      group = "blynk";
      description = "Blynk server user";
    };
    users.extraGroups.blynk = {};

    systemd.services.prepare-blynk-server = {
      script = ''
        [ -d ${blynkdir} ] || mkdir -p ${blynkdir}
        [ -e ${blynkdir}/server.jar ] || cp ${blynkserver} ${blynkdir}/server.jar
        chown blynk:blynk -Rc ${blynkdir}
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
    systemd.services.blynk-server = {
      script = "${jre}/bin/java -jar server.jar -dataFolder ${blynkdir}";

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      requires = [ "prepare-blynk-server.service" ];

      serviceConfig = {
        WorkingDirectory = "/var/lib/blynk";
        User = "blynk";
      };
    };
  };
}