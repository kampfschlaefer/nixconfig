{ config, lib, pkgs, ... }:

let
  users = if config.testdata then {
    "user" = "password";
  } else import ./selfoss_secrets.nix {};
in
{
  systemd.services."container@selfoss".after = [ "container@postgres.service" "container@firewall.service" ];
  # To lazy to debug nixos containers
  systemd.services."container@selfoss".postStart = "ip link set dev backendpg master backend up";

  containers.selfoss = {
    autoStart = lib.mkOverride 100 true;

    privateNetwork = true;
    hostBridge = "lan";
    extraVeths = {
      backendpg = {
        hostBridge = "backend";
      };
    };

    config = { config, pkgs, ... }: let
      selfosspkg = pkgs.callPackage ../../lib/software/selfoss { };
    in {
      imports = [
        ../../lib/software/selfoss/service.nix
      ];

      time.timeZone = "Europe/Berlin";

      networking.domain = "arnoldarts.de";
      networking.defaultGateway = "192.168.1.220";
      networking.defaultGateway6 = "2001:470:1f0b:1033:6669:7265:7761:6c6c";
      networking.nameservers = [ "192.168.1.240" ];
      networking.useDHCP = false;
      networking.useHostResolvConf = false;

      networking.interfaces = {
        eth0 = {
          useDHCP = false;
          ipv4.addresses = [{ address="192.168.1.227"; prefixLength=24; }];
          ipv6.addresses = [{ address="2001:470:1f0b:1033:73:656c:666f:7373"; prefixLength=64; }];
        };
        backendpg = {
          useDHCP = false;
          ipv4.addresses = [{ address="192.168.6.2"; prefixLength=23; }];
          ipv6.addresses = [];
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
        users = users;
      };

      environment.systemPackages = [ selfosspkg ];
    };
  };
}
