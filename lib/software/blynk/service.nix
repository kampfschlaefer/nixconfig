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
    environment.systemPackages = [ jre ];

    systemd.services.blynk-server = {
      script = "${jre}/bin/java -jar server.jar -dataFolder ${blynkdir}";
      preStart = ''
        [ -d ${blynkdir} ] || mkdir -p ${blynkdir}
        [ -e ${blynkdir}/server.jar ] || cp ${blynkserver} ${blynkdir}/server.jar
      '';

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        WorkingDirectory = "/var/lib/blynk";
      };
    };
  };
}