{ config, lib, pkgs, ... }:

let
  dash_button_pkg = import ../../lib/software/dash_button { inherit lib pkgs; };
  secrets = import ./homeassistant_secrets.nix {};

  dash_button_testconfig = {
    "DEFAULT" = {
      "interface" = "eth0";
      "host" = "localhost";
      "blackout_time" = 2;
      "api_password" = "";
    };
    "ac:63:be:be:01:93" = {
      "domain" = "light";
      "action" = "toggle";
      "data" = "{ \"entity_id\": \"light.benachrichtigung\" }";
    };
  "ac:63:be:be:01:95" = {};
  };

  dash_button_config = pkgs.writeText "dash_button.cfg" (
    lib.generators.toINI {} (
      if config.testdata
      then dash_button_testconfig
      else secrets.dash_config
    )
  );

in
{
  systemd.services."container@homeassistant".after = [
    "container@mqtt.service"
    "container@firewall.service"
  ];

  containers.homeassistant = {
    autoStart = lib.mkOverride 100 true;

    privateNetwork = true;
    hostBridge = "lan";
    /*extraVeths = {
      backendpg = {
        hostBridge = "backend";
      };
    };*/

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
          ipv4.addresses = [{ address="192.168.1.232"; prefixLength=24; }];
          ipv6.addresses = [{ address="2001:470:1f0b:1033:686f:6d65:6173:7369"; prefixLength=64; }];
        };
        /*backendpg = {
          useDHCP = false;
          ipv4.addresses = [{ address="192.168.6.2"; prefixLength=23; }];
          ipv6.addresses = [];
        };*/
      };
      networking.firewall.enable = true;
      networking.firewall.allowedTCPPorts = [ 80 443 ];
      /*networking.firewall.allowedTCPPorts = [ 8123 ];*/

      security.acme.validMin = 864000;

      services.homeassistant = {
        enable = true;
      };

      services.nginx = {
        enable = true;
        package = pkgs.nginxMainline;
        #sslCiphers = "ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:!RSA+AES:!aNULL:!MD5:!DSS";
        recommendedTlsSettings = true;
        recommendedProxySettings = false;
        virtualHosts = {
          "homeassistant" = {
            serverName = "homeassistant.arnoldarts.de";
            forceSSL = true;
            enableACME = true;
            extraConfig = ''
              proxy_buffering off;
              ssl_session_tickets on;
            '';
            locations."/" = {
              proxyPass = "http://localhost:8123";
              proxyWebsockets = true;
            };
          };
        };
      };

      systemd.services."dash_button_daemon" = {
        enable = true;
        script = "${dash_button_pkg}/bin/dash_button_daemon --config ${dash_button_config}";
        after = [ "homeassistant.service" ];
        wants = [ "homeassistant.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          RestartSec=10;
          Restart="on-failure";
        };
      };

      environment.systemPackages = [ dash_button_pkg ];
    };
  };
}
