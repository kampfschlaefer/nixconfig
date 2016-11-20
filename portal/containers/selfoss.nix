{ config, lib, pkgs, ... }:

let
  selfosspkg = pkgs.callPackage ../../lib/software/selfoss {};
in
{
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
      networking.firewall.allowedTCPPorts = [ 80 ];

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