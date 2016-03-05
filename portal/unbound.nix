{ config, lib, pkgs, ... }:

with lib;

let
  addresses = [
    { name = "laserjet"; a = "192.168.1.10"; }
    { name = "fonera";   a = "192.168.1.20"; }

    { name = "firewall"; a = "192.168.1.220"; aaaa = "2001:470:1f0b:1033:6669:7265:7761:6c6c"; }
    { name = "mpd";      a = "192.168.1.221"; aaaa = "2001:470:1f0b:1033::6d:7064"; }
    { name = "cups";     a = "192.168.1.222"; aaaa = "2001:470:1f0b:1033::6375:7073"; }
    { name = "gitolite"; a = "192.168.1.223"; aaaa = "2001:470:1f0b:1033::67:6974"; }
    { name = "imap";     a = "192.168.1.224"; aaaa = "2001:470:1f0b:1033::696d:6170"; }

    { name = "portal";   a = "192.168.1.240"; aaaa = "2001:470:1f0b:1033::706f:7274:616c"; }

    { name = "starbase"; a = "192.168.1.250"; aaaa = "2001:470:1f0b:1033::1"; }
    { name = "seafile";  a = "192.168.1.250"; aaaa = "2001:470:1f0b:1033::5ea:f11e"; }

    { name = "openwrt";  a = "192.168.1.251"; }
    { name = "tenda";    a = "192.168.1.252"; }
    #{ name = "hp";       a = "192.168.1.253"; }
    { name = "tp";       a = "192.168.1.254"; }
  ];

  localdata = concatMapStrings (addr:
    ''
      ${optionalString (addr ? "a") ''
        local-data: "${addr.name}.arnoldarts.de. IN A ${addr.a}"
        local-data-ptr: "${addr.a} ${addr.name}.arnoldarts.de."
      ''}
      ${optionalString (addr ? "aaaa") ''
        local-data: "${addr.name}.arnoldarts.de. IN AAAA ${addr.aaaa}"
        local-data-ptr: "${addr.aaaa} ${addr.name}.arnoldarts.de."
      ''}
    ''
  );
in
{
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  services.unbound = {
    enable = true;
    allowedAccess = [
      "127.0.0.0/8"
      "192.168.0.0/16"
      "::1/64"
      "2001:470:1f0b:1033::/64"
    ];
    interfaces = [
      "::"
      "*"
    ];
    forwardAddresses = [
      "8.8.8.8"              # Google Public DNS
      "2001:4860:4860::8888" # Google Public DNS
      "74.82.42.42"          # Hurricane Electric
      "2001:470:20::2"       # Hurricane Electric
    ];
    extraConfig = ''
      # Is it the dns that makes it so slow here?
      log-queries: yes
      statistics-interval: 300
      extended-statistics: yes

      local-zone: "arnoldarts.de." static

      ${localdata addresses}

      local-data: "nfs.arnoldarts.de. IN CNAME portal.arnoldarts.de."
    '';
  };
}