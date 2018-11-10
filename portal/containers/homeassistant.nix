{ config, lib, pkgs, ... }:

let
  dash_button_pkg = import ../../lib/software/dash_button { inherit lib pkgs; };
  secrets = import ./homeassistant_secrets.nix {};
  mqtt_users = if config.testdata then {
    testclient = { acl = []; password = "password"; };
  } else import ./mqtt_secrets.nix {};


  dash_button_testconfig = {
    "DEFAULT" = {
      "interface" = "eth0";
      "host" = "localhost";
      "blackout_time" = 0;
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
    extraVeths = {
      backendha = {
        hostBridge = "backend";
      };
    };

    config = { config, pkgs, ... }: {
      imports = [
        ../../lib/software/homeassistant/service.nix
      ];
      /*nixpkgs.config.packageOverrides = pkgs: rec {
        simp_le = pkgs.simp_le.overrideDerivation (oldAttrs: {
          version = "0.6.1";
          src = pkgs.pythonPackages.fetchPypi {
            pname = "simp_le-client";
            version = "0.6.1";
            sha256 = "0x4fky9jizs3xi55cdy217cvm3ikpghiabysan71b07ackkdfj6k";
          };
        });
        certbot = pkgs.certbot.overrideDerivation (oldAttrs: {
          version = "0.19.0";
          src = pkgs.fetchFromGitHub {
            owner = "certbot";
            repo = "certbot";
            rev = "v0.19.0";
            sha256 = "14i3q59v7j0q2pa1dri420fhil4h0vgl4vb471hp81f4y14gq6h7";
          };
        });
      };*/

      time.timeZone = "Europe/Berlin";

      networking.domain = "arnoldarts.de";
      networking.defaultGateway = "192.168.1.220";
      networking.defaultGateway6 = "2001:470:1f0b:1033:6669:7265:7761:6c6c";
      networking.nameservers = [ "192.168.1.240" ];
      networking.useDHCP = false;
      networking.useHostResolvConf = false;

      networking.interfaces = {
        eth0 = {
          useDHCP = false;
          ipv4.addresses = [
            { address="192.168.1.232"; prefixLength=24; } # homeassistant
            { address="192.168.1.229"; prefixLength=32; } # mqtt
          ];
          ipv6.addresses = [
            { address="2001:470:1f0b:1033:686f:6d65:6173:7369"; prefixLength=64; } # homeassistant
            { address="2001:470:1f0b:1033::6d71:7474"; prefixLength=64; } # mqtt
          ];
        };
        backendha = {
          useDHCP = false;
          ipv4.addresses = [{ address="192.168.6.18"; prefixLength=23; }];
          ipv6.addresses = [];
        };
      };
      networking.firewall.enable = true;
      networking.firewall.allowedTCPPorts = [ 80 443 1883 ];
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
              /*extraConfig = ''
                proxy_set_header Host $host;
                proxy_redirect http:// https://;
                proxy_http_version 1.1;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection $connection_upgrade;
              '';*/
            };
          };
        };
      };

      services.mosquitto = {
        enable = true;
        host = "0.0.0.0";
        port = 1883;

        extraConf = ''
        password_file /var/lib/mosquitto/passwd
        '';

        users = mqtt_users;
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
