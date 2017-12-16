{ config, lib, pkgs, ... }:

let
in
{
  /*systemd.services."container@selfoss".after = [ "container@postgres.service" "container@firewall.service" ];*/

  containers.homeassistant = {
    autoStart = lib.mkOverride 100 true;

    privateNetwork = true;
    hostBridge = "lan";
    /*extraVeths = {
      backendpg = {
        hostBridge = "backend";
      };
    };*/

    config = { config, pkgs, ... }: {
      imports = [
        ../../lib/software/homeassistant/service.nix
      ];

      time.timeZone = "Europe/Berlin";

      networking.domain = "arnoldarts.de";
      networking.defaultGateway = "192.168.1.220";
      networking.defaultGateway6 = "2001:470:1f0b:1033:6669:7265:7761:6c6c";

      networking.interfaces = {
        eth0 = {
          useDHCP = false;
          ip4 = [{ address="192.168.1.232"; prefixLength=24; }];
          ip6 = [{ address="2001:470:1f0b:1033:686f:6d65:6173:7369"; prefixLength=64; }];
        };
        /*backendpg = {
          useDHCP = false;
          ip4 = [{ address="192.168.6.2"; prefixLength=23; }];
          ip6 = [];
        };*/
      };
      networking.firewall.enable = true;
      networking.firewall.allowedTCPPorts = [ 80 443 ];
      /*networking.firewall.allowedTCPPorts = [ 8123 ];*/

      services.homeassistant = {
        enable = true;
      };

      services.nginx = {
        enable = true;
        sslCiphers = "ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:!RSA+AES:!aNULL:!MD5:!DSS";
        recommendedTlsSettings = true;
        recommendedProxySettings = false;
        virtualHosts = {
          "homeassistant" = {
            serverAliases = [ "homeassistant.arnoldarts.de" ];
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              proxyPass = "http://localhost:8123";
            };
          };
        };
      };
      /*services.selfoss.updateinterval = "hourly";
      services.selfoss.instances.arnold = {
        servername = "selfoss.arnoldarts.de";
        dbtype = "pgsql";
        dbhost = "postgres";
        dbname = "selfoss";
        dbusername = "selfoss";
        dbpassword = "";
      };*/
      /*services.selfoss.sqlite = {
        dbtype = "sqlite";
        servername = "sqlite_selfoss.arnoldarts.de";
      };*/

      /*environment.systemPackages = [ selfosspkg ];*/
    };
  };
}
