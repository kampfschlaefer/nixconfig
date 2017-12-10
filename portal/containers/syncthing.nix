{ config, lib, pkgs, ... }:

let
in
{
  fileSystems = {
    "/var/lib/containers/syncthing/var/lib/syncthing" = {
      device = "/dev/portalgroup/syncthing";
    };
  };

  containers.syncthing = {
    autoStart = lib.mkOverride 100 true;

    privateNetwork = true;
    hostBridge = "lan";
    localAddress = "192.168.1.230/24";
    localAddress6 = "2001:470:1f0b:1033:796e:6374:6869:6e67/64";

    config = { config, pkgs, ... }: {
      time.timeZone = "Europe/Berlin";

      networking.domain = "arnoldarts.de";
      networking.firewall.enable = false;

      services.syncthing = {
        enable = true;
        #user = "arnold";
        #group = "syncthing";
      };

      services.nginx = {
        enable = true;
        virtualHosts = {
          "syncthing.arnoldarts.de" = {
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              proxyPass = "http://localhost:8384";
            };
          };
        };
      };
      /*services.openssh = {
        enable = true;
        allowSFTP = true;
        startWhenNeeded = true;
      };

      services.mosquitto = {
        enable = true;
        host = "0.0.0.0";
        port = 1883;

        allowAnonymous = true;
        users = {};
      };*/
    };
  };
}
