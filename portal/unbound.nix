{ config, lib, pkgs, ... }:

with lib;

let
  tls_upstream = false;

  addresses = [
    { name = "laserjet";      a = "192.168.1.10"; }
    { name = "fonera";        a = "192.168.1.20"; }
    { name = "td-29";         a = "192.168.1.30"; }

    # client machines
    { name = "xingu";         a = "192.168.1.65"; aaaa = "2001:470:1f0b:1033:d250:99ff:fe4f:3b07"; }
    { name = "orinoco";       a = "192.168.1.66"; } # wireless
    { name = "amazonas";      a = "192.168.1.67"; } # wireless

    { name = "touchpi";       a = "192.168.1.70"; /*aaaa = "2001:470:1f0b:1033:d250:99ff:fe4f:3b07";*/ }
    { name = "octopi";        a = "192.168.1.71"; aaaa = "2001:470:1f0b:1033::6f63:746f:7069"; } # wireless
    { name = "weatherpi";     a = "192.168.1.72"; } # wireless raspi A
    { name = "pibot";         a = "192.168.1.73"; } # raspi w

    { name = "firestick";     a = "192.168.1.80"; }
    { name = "denon";         a = "192.168.1.81"; }
    { name = "huebridge";     a = "192.168.1.82"; }
    { name = "blueray";       a = "192.168.1.83"; }
    { name = "soundcraft";    a = "192.168.1.84"; }


    # containers
    { name = "firewall";      a = "192.168.1.220"; aaaa = "2001:470:1f0b:1033:6669:7265:7761:6c6c"; }
    { name = "mpd";           a = "192.168.1.221"; aaaa = "2001:470:1f0b:1033::6d:7064"; }
    { name = "cups";          a = "192.168.1.222"; aaaa = "2001:470:1f0b:1033::6375:7073"; }
    { name = "gitolite";      a = "192.168.1.223"; aaaa = "2001:470:1f0b:1033::67:6974"; }
    { name = "imap";          a = "192.168.1.224"; aaaa = "2001:470:1f0b:1033::696d:6170"; }
    { name = "torproxy";      a = "192.168.1.225"; aaaa = "2001:470:1f0b:1033:746f:7270:726f:7879"; }
    { name = "selfoss";       a = "192.168.1.227"; aaaa = "2001:470:1f0b:1033:73:656c:666f:7373"; }
    { name = "blynk";         a = "192.168.1.228"; aaaa = "2001:470:1f0b:1033::62:6c79:6e6b"; }
    { name = "mqtt";          a = "192.168.1.229"; aaaa = "2001:470:1f0b:1033::6d71:7474"; }
    { name = "syncthing";     a = "192.168.1.230"; aaaa = "2001:470:1f0b:1033:796e:6374:6869:6e67"; }
    { name = "syncthing2";    a = "192.168.1.231"; aaaa = "2001:470:1f0b:1033:796e:6374:6869:6e68"; }
    { name = "homeassistant"; a = "192.168.1.232"; aaaa = "2001:470:1f0b:1033:686f:6d65:6173:7369"; }

    # servers
    { name = "portal";   a = "192.168.1.240"; aaaa = "2001:470:1f0b:1033::706f:7274:616c"; }

    { name = "starbase"; a = "192.168.1.250"; aaaa = "2001:470:1f0b:1033::1"; }
    { name = "seafile";  a = "192.168.1.250"; aaaa = "2001:470:1f0b:1033::5ea:f11e"; }

    # network infrastructure
    { name = "openwrt";  a = "192.168.1.251"; }
    { name = "tenda";    a = "192.168.1.252"; }
    { name = "turris";   a = "192.168.1.253"; }
    { name = "tp";       a = "192.168.1.254"; }

    # backend (/23 net)
    { name = "postgres"; a = "192.168.6.1"; }
    # { name = "selfoss";  a = "192.168.6.2"; }  # for documentation
  ] ++ (if config.testdata then [
    { name = "outsideweb";   a = "192.168.2.10"; }
  ] else []);

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
    forwardAddresses = if tls_upstream then [
      "146.185.167.43@853"  # securedns.eu Europe
      "89.233.43.71@853"    # unicast.censurfridns.dk Europe
      "9.9.9.9@853"         # quad9.net primary
      "1.1.1.1@853"         # cloudflare primary
      "149.112.112.112@853" # quad9.net secondary
      "1.0.0.1@853"         # cloudflare secondary
    ] else [
      "8.8.8.8"              # Google Public DNS
      "74.82.42.42"          # Hurricane Electric
      "2001:4860:4860::8888" # Google Public DNS
      "2001:470:20::2"       # Hurricane Electric
    ];
    extraConfig = ''

      num-threads: 2
      num-queries-per-thread: 1024
      outgoing-tcp-mss: 1220

      # >1 logs requests
      verbosity: 1

      # Is it the dns that makes it so slow here?
      log-queries: ${if config.testdata then "yes" else "no"}
      log-replies: ${if config.testdata then "yes" else "no"}
      statistics-interval: 300
      extended-statistics: yes

      cache-min-ttl: 300
      cache-max-ttl: 3600
      prefetch: yes
      serve-expired: yes
      ssl-upstream: ${if tls_upstream then "yes" else "no"}
      # ssl-cert-bundle: /etc/ssl/certs/ca-certificates.crt  # version >=1.7.0

      local-zone: "arnoldarts.de." ${if config.testdata then "refuse" else "typetransparent"}

      ${localdata addresses}

      local-data: "nfs.arnoldarts.de. IN CNAME portal.arnoldarts.de."
    '';
  };
}
