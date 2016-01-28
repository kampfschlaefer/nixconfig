{ config, lib, pkgs, ... }:

{
  containers.testing = {
    privateNetwork = true;
    localAddress = "192.168.1.220";
    config = { config, pkgs, ... }: {
      services.openssh.enable = true;
      networking.firewall.enable = false;
      networking.interfaces.eth0 = {
        useDHCP = false;
        ip6 = [{ address = "2001:470:1f0b:1033:74:6573:7469:6e67"; prefixLength = 64; }];
      };
    };
  };
}

