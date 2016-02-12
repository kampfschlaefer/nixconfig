{ config, lib, pkgs, ... }:

{
  containers.firewall = {
    /*autoStart = true;*/

    privateNetwork = true;
    hostBridge = "lan";
    interfaces = [ "eth1" ];

    config = { config, pkgs, ... }: {
      /*imports = [
        ../../lib/users/arnold.nix
      ];*/

      networking.domain = "arnoldarts.de";
      networking.interfaces.eth0 = {
        useDHCP = false;
        ip6 = [{ address = "2001:470:1f0b:1033:6669:7265:7761:6c6c"; prefixLength = 64; }];
        ip4 = [{ address = "192.168.1.220"; prefixLength = 24; }];
      };
      networking.interfaces.eth1 = {
        useDHCP = false;
        #ip6 = [{ address = "2001:470:1f0b:1033:6669:7265:7761:6c6c"; prefixLength = 64; }];
        ip4 = [{ address = "192.168.2.220"; prefixLength = 24; }];
      };
      networking.firewall = {
        allowPing = true;
        /*allowedTCPPorts = [ 631 ];*/
        extraPackages = [ pkgs.procps ];
        extraCommands = ''
          sysctl net.ipv4.conf.all.forwarding=1
          sysctl net.ipv6.conf.all.forwarding=1
        '';

        defaultPolicies = { input = "DROP"; forward = "DROP"; output = "DROP"; };
        rules = [
          { fromInterface = "lo"; target = "ACCEPT"; }
          { toInterface = "lo"; target = "ACCEPT"; }
          {
            fromInterface = "eth0"; protocol = "tcp"; destinationPort = "22"; target = "ACCEPT";
          }
        ];
      };
    };
  };
}
