{ config, lib, pkgs, ...}:

let
  /* pg_pkg = pkgs.postgresql95;
  backup_path = "/var/backup/postgresql";
  db_list_command = "psql -l -t -A |cut -d'|' -f 1 |grep -v -e template0 -e template1 -e 'root=CT'"; */
  influxpkg = config.services.influxdb.package;
in
{
  systemd.services."container@influxdb" = {
    serviceConfig = {
      TimeoutStartSec = "3min";
      RestartSec = 30;
    };
    after = [
      "container@postgres.service"
    ];
  };

  containers.influxdb = {
    autoStart = lib.mkOverride 100 true;

    privateNetwork = true;
    hostBridge = "backend";
    extraVeths = {
      grafanalan = {
        hostBridge = "lan";
      };
    };

    config = {config, pkgs, ...}: {
      time.timeZone = "Europe/Berlin";

      networking.interfaces = {
        eth0 = {
          useDHCP = false;
          ipv4.addresses = [{ address="192.168.6.17"; prefixLength=23; }];
          ipv6.addresses = [];
        };
        grafanalan = {
          useDHCP = false;
          ipv4.addresses = [{ address = "192.168.1.234"; prefixLength=24; }];
          ipv6.addresses = [{ address = "2001:470:1f0b:1033:67:7261:6661:6e61"; prefixLength=64; }];
        };
      };

      networking.firewall = {
        enable = true;
        allowPing = true;
        allowedTCPPorts = [ 80 443 8086 ];
      };

      services.grafana = {
        enable = true;
        analytics.reporting.enable = false;
        auth.anonymous.enable = true;
      };

      services.nginx = {
        enable = true;
        package = pkgs.nginxMainline;
        #sslCiphers = "ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:!RSA+AES:!aNULL:!MD5:!DSS";
        recommendedTlsSettings = true;
        recommendedProxySettings = false;
        virtualHosts = {
          "grafana" = {
            serverName = "grafana.arnoldarts.de";
            forceSSL = true;
            enableACME = true;
            extraConfig = ''
              proxy_buffering off;
              ssl_session_tickets on;
            '';
            locations."/" = {
              proxyPass = "http://localhost:3000";
              proxyWebsockets = true;
            };
          };
        };
      };

      services.influxdb = {
        enable = true;
        extraConfig = {
          meta = {
            hostname = "influxdb";
          };
          http = {
            bind-address = ":8086";
          };
        };
      };

      environment.systemPackages = [
        influxpkg
      ];
    };
  };
}
