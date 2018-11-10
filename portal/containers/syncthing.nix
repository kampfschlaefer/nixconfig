{ config, lib, pkgs, ... }:

let
  container = name: ip: ip6: rec {
    autoStart = lib.mkOverride 100 true;

    privateNetwork = true;
    hostBridge = "lan";
    localAddress = "${ip}/24";
    localAddress6 = "${ip6}/64";

    config = { config, pkgs, ... }: {
      /*nixpkgs.config.packageOverrides = pkgs: rec {
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
      };*/
      time.timeZone = "Europe/Berlin";

      networking.domain = "arnoldarts.de";
      networking.defaultGateway = "192.168.1.220";
      networking.defaultGateway6 = "2001:470:1f0b:1033:6669:7265:7761:6c6c";
      networking.nameservers = [ "192.168.1.240" ];
      networking.useDHCP = false;
      networking.useHostResolvConf = false;

      networking.firewall.enable = true;
      networking.firewall.allowedTCPPorts = [ 80 443 ];

      security.acme.validMin = 864000;

      services.syncthing = {
        enable = true;
        openDefaultPorts = true;
      };

      services.nginx = {
        enable = true;
        sslCiphers = "ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:!RSA+AES:!aNULL:!MD5:!DSS";
        recommendedTlsSettings = true;
        recommendedProxySettings = false;
        virtualHosts = {
          "${name}.arnoldarts.de" = {
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              proxyPass = "http://localhost:8384";
            };
          };
        };
      };
    };
  };
in
{
  fileSystems = {
    "/var/lib/containers/syncthing/var/lib/syncthing" = {
      device = "/dev/portalgroup/syncthing";
    };
    "/var/lib/containers/syncthing2/var/lib/syncthing" = {
      device = "/dev/portalgroup/syncthing2";
    };
  };

  containers.syncthing = container "syncthing" "192.168.1.230" "2001:470:1f0b:1033:796e:6374:6869:6e67";
  containers.syncthing2 = container "syncthing2" "192.168.1.231" "2001:470:1f0b:1033:796e:6374:6869:6e68";
}
