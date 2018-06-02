{ config, lib, pkgs, ... }:

let
  pkg_startpage = pkgs.callPackage ../../lib/software/startpage {};
in
{
  containers.startpage = {
    autoStart = lib.mkOverride 100 true;

    privateNetwork = true;
    hostBridge = "lan";

    config = { config, pkgs, ... }: {
      imports = [
        ../../lib/software/homeassistant/service.nix
      ];

      time.timeZone = "Europe/Berlin";

      networking.domain = "arnoldarts.de";
      networking.defaultGateway = "192.168.1.220";
      networking.defaultGateway6 = "2001:470:1f0b:1033:6669:7265:7761:6c6c";

      networking.interfaces = {
        eth0 = {
          useDHCP = false;
          ip4 = [{ address="192.168.1.233"; prefixLength=24; }];
          ip6 = [{ address="2001:470:1f0b:1033::73:7461:7274"; prefixLength=64; }];
        };
      };
      networking.firewall.enable = true;
      networking.firewall.allowedTCPPorts = [ 80 443 ];

      services.nginx = {
        enable = true;
        sslCiphers = "ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:!RSA+AES:!aNULL:!MD5:!DSS";
        recommendedTlsSettings = true;
        recommendedProxySettings = false;
        virtualHosts = {
          "startpage" = {
            serverName = "startpage.arnoldarts.de";
            forceSSL = true;
            enableACME = true;
            locations."/" = {
              root = pkg_startpage;
              index = "index.html";
            };
          };
        };
      };
    };
  };
}
