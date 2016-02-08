{ config, lib, pkgs, ... }:

{
  containers.testing = {
    privateNetwork = true;
    hostBridge = "lan";
    /*localAddress = "192.168.1.220/24";*/
    /*localAddress6 = "2001:470:1f0b:1033:74:6573:7469:6e67/64";*/
    config = { config, pkgs, ... }: {
      services.openssh.enable = true;
      networking.firewall.enable = false;
      networking.interfaces.eth0 = {
        useDHCP = false;
        ip6 = [{ address = "2001:470:1f0b:1033:74:6573:7469:6e67"; prefixLength = 64; }];
        ip4 = [{ address = "192.168.1.220"; prefixLength = 24; }];
      };
    };
  };

  containers.testdhcp = {
    privateNetwork = true;
    hostBridge = "lan";
    config = { config, pkgs, ... }: {
      services.openssh.enable = true;
      networking.firewall.enable = true;
      networking.firewall.allowPing = true;
      networking.interfaces.eth0 = {
        useDHCP = true;
      };
    };
  };
}

