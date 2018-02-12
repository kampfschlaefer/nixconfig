{ config, lib, pkgs, ... }:

let
  selfosspkg = pkgs.callPackage ../../lib/software/selfoss {};
in
{
  systemd.services."container@selfoss".after = [ "container@postgres.service" "container@firewall.service" ];

  containers.selfoss = {
    autoStart = lib.mkOverride 100 true;

    privateNetwork = true;
    hostBridge = "lan";
    extraVeths = {
      backendpg = {
        hostBridge = "backend";
      };
    };

    config = { config, pkgs, ... }: {
      imports = [
        ../../lib/software/selfoss/service.nix
      ];
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
      networking.defaultGateway = "192.168.1.220";
      networking.defaultGateway6 = "2001:470:1f0b:1033:6669:7265:7761:6c6c";

      networking.interfaces = {
        eth0 = {
          useDHCP = false;
          ip4 = [{ address="192.168.1.227"; prefixLength=24; }];
          ip6 = [{ address="2001:470:1f0b:1033:73:656c:666f:7373"; prefixLength=64; }];
        };
        backendpg = {
          useDHCP = false;
          ip4 = [{ address="192.168.6.2"; prefixLength=23; }];
          ip6 = [];
        };
      };
      networking.firewall.enable = true;
      networking.firewall.allowedTCPPorts = [ 80 443 ];

      security.acme.validMin = 864000;

      services.selfoss.updateinterval = "hourly";
      services.selfoss.instances.arnold = {
        servername = "selfoss.arnoldarts.de";
        dbtype = "pgsql";
        dbhost = "postgres";
        dbname = "selfoss";
        dbusername = "selfoss";
        dbpassword = "";
      };
      /*services.selfoss.sqlite = {
        dbtype = "sqlite";
        servername = "sqlite_selfoss.arnoldarts.de";
      };*/

      environment.systemPackages = [ selfosspkg ];
    };
  };
}
