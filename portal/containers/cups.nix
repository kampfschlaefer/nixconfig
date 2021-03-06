{ config, lib, pkgs, ... }:

{
  containers.cups = {
    autoStart = lib.mkOverride 100 false;

    privateNetwork = true;
    hostBridge = "lan";

    config = { config, pkgs, ... }: {
      imports = [
        ../../lib/users/arnold.nix
      ];

      networking.domain = "arnoldarts.de";
      networking.interfaces.eth0 = {
        useDHCP = false;
        ipv6.addresses = [{ address = "2001:470:1f0b:1033::6375:7073"; prefixLength = 64; }];
        ipv4.addresses = [{ address = "192.168.1.222"; prefixLength = 24; }];
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

          BrowseLocalProtocols all

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