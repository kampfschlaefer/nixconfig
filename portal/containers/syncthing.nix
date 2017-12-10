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
      nixpkgs.config.packageOverrides = pkgs: rec {
        simp_le = pkgs.simp_le.overrideDerivation (oldAttrs: {
          version = "0.6.1";
          src = pkgs.pythonPackages.fetchPypi {
            pname = "simp_le-client";
            version = "0.6.1";
            sha256 = "0x4fky9jizs3xi55cdy217cvm3ikpghiabysan71b07ackkdfj6k";
          };
        });
        certbot = pkgs.certbot.overrideDerivation (oldAttrs: {
          version = "0.19.0";
          src = pkgs.fetchFromGitHub {
            owner = "certbot";
            repo = "certbot";
            rev = "v0.19.0";
            sha256 = "14i3q59v7j0q2pa1dri420fhil4h0vgl4vb471hp81f4y14gq6h7";
          };
        });
      };
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
        sslCiphers = "ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS";
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
