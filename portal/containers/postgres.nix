{ config, lib, pkgs, ...}:

let
in
{
  containers.postgres = {
    autoStart = lib.mkOverride 100 true;

    privateNetwork = true;
    hostBridge = "backend";
    # localAddress = "192.168.6.1/23";

    config = {config, pkgs, ...}: {
      time.timeZone = "Europe/Berlin";

      networking.interfaces = {
        eth0 = {
          useDHCP = false;
          ip4 = [{ address="192.168.6.1"; prefixLength=23; }];
          ip6 = [];
        };
      };

      networking.firewall = {
        enable = true;
        allowPing = true;
        allowedTCPPorts = [ 5432 ];
      };

      services.postgresql = {
        enable = true;

        enableTCPIP = true;

        package = pkgs.postgresql95;
      };

    };
  };
}