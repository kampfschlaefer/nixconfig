{ config, lib, pkgs, ... }:

{
  containers.cups = {
    autoStart = true;

    privateNetwork = true;
    hostBridge = "lan";

    config = { config, pkgs, ... }: {
      imports = [
        ../../lib/users/arnold.nix
      ];

      networking.domain = "lan.arnoldarts.de";
      networking.interfaces.eth0 = {
        useDHCP = false;
        ip6 = [{ address = "2001:470:1f0b:1033::6375:7073"; prefixLength = 64; }];
        ip4 = [{ address = "192.168.1.222"; prefixLength = 24; }];
      };
      networking.firewall.allowPing = true;
      networking.firewall.allowedTCPPorts = [ 631 ];

      services.printing = {
        enable = true;
        listenAddresses = [ "*:631" ];
        defaultShared = true;
        browsing = true;
        extraConf = ''
          ServerAlias *
          DefaultEncryption Never
          <Location />
            Order allow,deny
            Allow localhost
            Allow from 192.168.1.0/24
            Allow from [2001:470:1f0b:1033::]/64
          </Location>
          <Location /admin>
            Order allow,deny
            Allow from localhost
            Allow from 192.168.1.0/24
            Allow from [2001:470:1f0b:1033::]/64
          </Location>

          <Location /admin/conf>
            AuthType Basic
            Require user @SYSTEM @users arnold
            Order allow,deny
            Allow from localhost
            Allow from 192.168.1.0/24
            Allow from [2001:470:1f0b:1033::]/64
          </Location>
        '';
      };
    };
  };
}