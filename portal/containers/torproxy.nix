{ config, lib, pkgs, ... }:

let
  dmzIf = "dmztor";
  lanIf = "eth0";
in
{
  containers.torproxy = {
    autoStart = lib.mkOverride 100 true;

    privateNetwork = true;
    hostBridge = "lan";
    extraVeths = {
      dmztor = {
        hostBridge = "dmz";
      };
    };

    config = { config, pkgs, ... }: {
      networking.domain = "arnoldarts.de";
      networking.defaultGateway = "192.168.2.10";

      networking.interfaces = {
        "${lanIf}" = {
          useDHCP = false;
          ip6 = [{ address = "2001:470:1f0b:1033:746f:7270:726f:7879"; prefixLength = 64; }];
          ip4 = [{ address = "192.168.1.225"; prefixLength = 24; }];
        };
        "${dmzIf}" = {
          useDHCP = false;
          ip6 = [];
          ip4 = [{ address = "192.168.2.225"; prefixLength = 24; }];
        };
      };

      networking.nat.enable = false;

      networking.firewall = {
        /*enable = false;*/
        allowPing = true;
        rejectPackets = true;
        # log target doesn't work inside network-namespaces
        logRefusedPackets = false;

        defaultPolicies = { input = "DROP"; forward = "DROP"; output = "DROP"; };
        rules = [
          { fromInterface = "lo"; target = "ACCEPT"; }
          { toInterface = "lo"; target = "ACCEPT"; }
          { fromInterface = "${lanIf}"; protocol = "tcp"; destinationPort = "9050"; target = "ACCEPT"; }
          { fromInterface = "${lanIf}"; protocol = "tcp"; destinationPort = "9063"; target = "ACCEPT"; }
          { toInterface = "${lanIf}"; protocol = "icmpv6"; target = "ACCEPT"; }
          /*{ toInterface = "${dmzIf}"; target = "ACCEPT"; }*/
        ];
      };

      services.tor = {
        enable = true;

        client = {
          enable = true;
          socksListenAddress = "192.168.1.225:9050";
          socksListenAddressFaster = "192.168.1.225:9063";
          socksPolicy = "accept 192.168.1.0/24, reject *";
        };
      };

      environment.systemPackages = [
        pkgs.atop
        pkgs.iftop
        pkgs.sysstat
      ];
    };
  };
}