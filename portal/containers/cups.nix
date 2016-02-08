{ config, lib, pkgs, ... }:

{
  containers.cups = {
    autoStart = true;

    privateNetwork = true;
    hostBridge = "lan";
    localAddress = "192.168.1.222/24";
    localAddress6 = "2001:470:1f0b:1033::6375:7073/64";

    config = { config, pkgs, ... }: {
      networking.domain = "lan.arnoldarts.de";
      networking.firewall.allowPing = true;
      networking.firewall.allowedTCPPorts = [ 631 ];

      services.printing = {
        enable = true;
        listenAddresses = [ "*:631" ];
        defaultShared = true;
        browsing = true;
        extraConf = ''
          ServerAlias *
        '';
      };
    };
  };
}