{ config, lib, pkgs, ... }:

let
  dmzIf = "dmzfw";
  lanIf = "eth0";
in
{
  containers.firewall = {
    autoStart = lib.mkOverride 100 true;

    privateNetwork = true;
    hostBridge = "lan";
    extraVeths = {
      dmzfw = {
        hostBridge = "dmz";
      };
    };

    config = { config, pkgs, ... }: {
      /*imports = [
        ../../lib/users/arnold.nix
      ];*/

      networking.domain = "arnoldarts.de";

      networking.defaultGateway = "192.168.2.10";

      networking.interfaces = {
        "${lanIf}" = {
          useDHCP = false;
          ip6 = [{ address = "2001:470:1f0b:1033:6669:7265:7761:6c6c"; prefixLength = 64; }];
          ip4 = [{ address = "192.168.1.220"; prefixLength = 24; }];
        };
        "${dmzIf}" = {
          useDHCP = false;
          #ip6 = [{ address = "2001:470:1f0b:1033:6669:7265:7761:6c6c"; prefixLength = 64; }];
          ip4 = [{ address = "192.168.2.220"; prefixLength = 24; }];
        };
      };

      networking.nat = {
        enable = true;
        externalInterface = dmzIf;
        internalIPs = [ "192.168.1.0/24" ];
        externalIP = "192.168.2.220";
      };

      networking.firewall = {
        allowPing = true;
        rejectPackets = true;
        logRefusedPackets = true;

        defaultPolicies = { input = "DROP"; forward = "DROP"; output = "DROP"; };
        rules = [
          { fromInterface = "lo"; target = "ACCEPT"; }
          { toInterface = "lo"; target = "ACCEPT"; }
          /*{
            fromInterface = "eth0"; protocol = "tcp"; destinationPort = "22"; target = "ACCEPT";
          }*/
          {
            ipv4Only = true;
            fromInterface = lanIf;
            toInterface = dmzIf;
            /*protocol = "tcp";
            destinationPort = "80";*/
            target = "ACCEPT";
          }
          /*{
            fromInterface = lanIf;
            toInterface = dmzIf;
            protocol = "tcp";
            destinationPort = "443";
            target = "ACCEPT";
          }*/
        ];
      };

      environment.systemPackages = [
        pkgs.atop
        pkgs.iftop
        pkgs.sysstat
      ];

      /*services.openssh = {
        enable = true;
        allowSFTP = true;
        startWhenNeeded = true;
      };*/
    };
  };
}
