{ config, lib, pkgs, ...}:

let
  /* pg_pkg = pkgs.postgresql95;
  backup_path = "/var/backup/postgresql";
  db_list_command = "psql -l -t -A |cut -d'|' -f 1 |grep -v -e template0 -e template1 -e 'root=CT'"; */
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

    config = {config, pkgs, ...}: {
      time.timeZone = "Europe/Berlin";

      networking.interfaces = {
        eth0 = {
          useDHCP = false;
          ipv4.addresses = [{ address="192.168.6.17"; prefixLength=23; }];
          ipv6.addresses = [];
        };
      };

      networking.firewall = {
        enable = true;
        allowPing = true;
        allowedTCPPorts = [ 8086 ];
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
    };
  };
}
