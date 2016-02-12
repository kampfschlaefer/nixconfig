{ config, lib, pkgs, ... }:

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
      "2001:470:1f0b:1033::1" # starbase
    ];
    extraConfig = ''
      local-zone: "lan.arnoldarts.de." static

      local-data: "portal.lan.arnoldarts.de. IN A    192.168.1.240"
      local-data: "portal.lan.arnoldarts.de. IN AAAA 2001:470:1f0b:1033::706f:7274:616c"
      local-data-ptr: "192.168.1.240  portal.lan.arnoldarts.de."
      local-data-ptr: "2001:470:1f0b:1033::706f:7274:616c  portal.lan.arnoldarts.de."

      local-data: "mpd.lan.arnoldarts.de. IN A 192.168.1.221"
      local-data: "mpd.lan.arnoldarts.de. IN AAAA 2001:470:1f0b:1033::6d:7064"
      local-data: "cups.lan.arnoldarts.de. IN A 192.168.1.222"
      local-data: "cups.lan.arnoldarts.de. IN AAAA 2001:470:1f0b:1033::6375:7073"
      local-data: "starbase.lan.arnoldarts.de. IN A 192.168.1.250"
      local-data: "starbase.lan.arnoldarts.de. IN AAAA 2001:470:1f0b:1033::1"
    '';
  };
}