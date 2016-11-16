{ config, lib, pkgs, ...}:

with lib;

let

  cfg = config.services.outsideweb;

  httpDir = pkgs.stdenv.mkDerivation rec {
    name = "outsideweb_resources";

    src = ./data;

    buildInputs = [];
    configurePhase = false;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/html

      echo "Congratulations, you found the outside web" > $out/html/index.txt

      cp index.html $out/html
      cp feed.atom $out/html
      cp favicon.ico $out/html
    '';
  };

in
{
  options = {
    services.outsideweb = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;

      httpConfig = ''
      server {
        server_name outsideweb;

        root ${httpDir}/html;

        access_log syslog:server=unix:/dev/log;
        error_log syslog:server=unix:/dev/log;
      }
      '';
    };
  };
}