{ config, lib, pkgs, ... }:

with lib;

let
  addresses = [
    { name = "laserjet"; a = "192.168.1.10"; }
    { name = "fonera";   a = "192.168.1.20"; }

    { name = "xingu";    a = "192.168.1.65"; aaaa = "2001:470:1f0b:1033:d250:99ff:fe4f:3b07"; }
    { name = "orinoco";  a = "192.168.1.66"; } # wireless
    { name = "amazonas"; a = "192.168.1.67"; } # wireless
    { name = "touchpi";  a = "192.168.1.70"; /*aaaa = "2001:470:1f0b:1033:d250:99ff:fe4f:3b07";*/ }

    { name = "firewall"; a = "192.168.1.220"; aaaa = "2001:470:1f0b:1033:6669:7265:7761:6c6c"; }
    { name = "mpd";      a = "192.168.1.221"; aaaa = "2001:470:1f0b:1033::6d:7064"; }
    { name = "cups";     a = "192.168.1.222"; aaaa = "2001:470:1f0b:1033::6375:7073"; }
    { name = "gitolite"; a = "192.168.1.223"; aaaa = "2001:470:1f0b:1033::67:6974"; }
    { name = "imap";     a = "192.168.1.224"; aaaa = "2001:470:1f0b:1033::696d:6170"; }
    { name = "torproxy"; a = "192.168.1.225"; aaaa = "2001:470:1f0b:1033:746f:7270:726f:7879"; }
    { name = "pyheim";   a = "192.168.1.226"; aaaa = "2001:470:1f0b:1033::7079:6865:696d"; }
    { name = "selfoss";  a = "192.168.1.227"; aaaa = "2001:470:1f0b:1033:73:656c:666f:7373"; }

    { name = "portal";   a = "192.168.1.240"; aaaa = "2001:470:1f0b:1033::706f:7274:616c"; }

    { name = "starbase"; a = "192.168.1.250"; aaaa = "2001:470:1f0b:1033::1"; }
    { name = "seafile";  a = "192.168.1.250"; aaaa = "2001:470:1f0b:1033::5ea:f11e"; }

    { name = "openwrt";  a = "192.168.1.251"; }
    { name = "tenda";    a = "192.168.1.252"; }
    # { name = "hp";       a = "192.168.1.253"; } # old switch, not printer
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
    enableRootTrustAnchor = false;
    allowedAccess = [
      "127.0.0.0/8"
      "192.168.0.0/16"
      "::1/64"
      "2001:470:1f0b:1033::/64"
    ];
    interfaces = [
      "::"
      # "::1"
      # "2001:470:1f0b:1033::706f:7274:616c"
      "127.0.0.1"
      "192.168.1.240"
    ];
    forwardAddresses = [
      "8.8.8.8"              # Google Public DNS
      "74.82.42.42"          # Hurricane Electric
      "2001:4860:4860::8888" # Google Public DNS
      "2001:470:20::2"       # Hurricane Electric
    ];
    extraConfig = ''
      # >1 logs requests
      verbosity: 1

      # Is it the dns that makes it so slow here?
      log-queries: no
      statistics-interval: 300
      extended-statistics: yes

      cache-min-ttl: 300
      cache-max-ttl: 3600
      prefetch: yes

      local-zone: "arnoldarts.de." typetransparent

      ${localdata addresses}

      local-data: "nfs.arnoldarts.de. IN CNAME portal.arnoldarts.de."
    '';
  };
}