{ config, lib, pkgs, ...}:

with lib;

let

  cfg = config.services.outsideweb;

  indexhtml = ''
    <html>
      <head><title>Outside Web</title></head>
      <body>
        <h1>Congratulations!</h1>
        <p>You reached the outside web.</p>
      </body>
    </html>
  '';

  httpDir = pkgs.stdenv.mkDerivation rec {
    name = "outsideweb_resources";

    src = ./.;

    buildInputs = [];
    configurePhase = false;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out/html

      echo "Congratulations, you found the outside web" > $out/html/index.txt

      echo "${indexhtml}" > $out/html/index.html
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