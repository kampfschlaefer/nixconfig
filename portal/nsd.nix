{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  services.nsd = {
    enable = true;
    identity = "portal arnoldarts";
    interfaces = [ "::" "192.168.1.240" ];
    zones = {
      "lan.arnoldarts.de." = {
        data = ''
          \$ORIGIN lan.arnoldarts.de.
          \$TTL 3600
          @ IN SOA portal.lan.arnoldarts.de. root.arnoldarts.de (
            100 ; serial
            300 ; refresh time
            100 ; retry time
            6000 ; expire time
            600 ; negative caching time
            )

          @ IN NS portal.arnoldarts.de.

          starbase IN A 192.168.1.250
          starbase IN AAAA 2001:470:1f0b:1033::1

          portal IN A 192.168.1.240
          portal IN AAAA 2001:470:1f0b:1033::706f:7274:616c

          nfs IN CNAME portal

          mpd IN A 192.168.1.221
          mpd IN AAAA 2001:470:1f0b:1033::6d:7064

          cups IN A 192.168.1.222
          cups IN AAAA 2001:470:1f0b:1033::6375:7073
        '';
      };
    };
  };
}