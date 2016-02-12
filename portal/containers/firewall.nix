{ config, lib, pkgs, ... }:

{
  containers.firewall = {
    /*autoStart = true;*/

    privateNetwork = true;
    hostBridge = "lan";
    interfaces = [ "eno2" ];

    config = { config, pkgs, ... }: {
      /*imports = [
        ../../lib/users/arnold.nix
      ];*/

      networking.domain = "arnoldarts.de";

      networking.bridges = {
        dmz = { interfaces = [ "eno2" ]; };
        lan = { interfaces = [ "eth0" ]; };
      };

      networking.interfaces.lan = {
        useDHCP = false;
        ip6 = [{ address = "2001:470:1f0b:1033:6669:7265:7761:6c6c"; prefixLength = 64; }];
        ip4 = [{ address = "192.168.1.220"; prefixLength = 24; }];
      };
      networking.interfaces.dmz = {
        useDHCP = false;
        #ip6 = [{ address = "2001:470:1f0b:1033:6669:7265:7761:6c6c"; prefixLength = 64; }];
        ip4 = [{ address = "192.168.2.220"; prefixLength = 24; }];
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
            fromInterface = "lan";
            toInterface = "dmz";
            protocol = "tcp";
            destinationPort = "80";
            target = "ACCEPT";
          }
          {
            fromInterface = "lan";
            toInterface = "dmz";
            protocol = "tcp";
            destinationPort = "443";
            target = "ACCEPT";
          }
        ];
      };

      /*services.openssh = {
        enable = true;
        allowSFTP = true;
        startWhenNeeded = true;
      };*/
    };
  };
}
