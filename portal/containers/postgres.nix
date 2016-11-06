{ config, lib, pkgs, ...}:

let
  pg_pkg = pkgs.postgresql95;
  backup_path = "/var/backup/postgresql";
  db_list_command = "psql -l -t -A |cut -d'|' -f 1 |grep -v -e template0 -e template1 -e 'root=CT'";
in
{
  containers.postgres = {
    autoStart = lib.mkOverride 100 true;

    privateNetwork = true;
    hostBridge = "backend";

    config = {config, pkgs, ...}: {
      time.timeZone = "Europe/Berlin";

      networking.interfaces = {
        eth0 = {
          useDHCP = false;
          ip4 = [{ address="192.168.6.1"; prefixLength=23; }];
          ip6 = [];
        };
      };

      networking.firewall = {
        enable = true;
        allowPing = true;
        allowedTCPPorts = [ 5432 ];
      };

      services.postgresql = {
        enable = true;
        enableTCPIP = true;
        package = pg_pkg;
        authentication = ''
          host selfoss selfoss 192.168.6.2/32 trust
        '';
        initialScript = builtins.toFile "pg_initial_script" ''
          CREATE ROLE selfoss LOGIN CREATEDB;
          CREATE DATABASE selfoss OWNER selfoss;
        '';
      };

      systemd.services.postgresql.preStart = ''
        if [ ! -d ${backup_path} ]; then
          mkdir -p ${backup_path}
          chown postgres ${backup_path}
        fi
      '';

      systemd.services.postgresql-dump = {
        path = [ pg_pkg pkgs.gzip ];
        serviceConfig = {
          User = "root";
        };
        script = ''
          ${db_list_command}
          for db in `${db_list_command}`; do
            echo "Dumping $db"
            pg_dump --format directory --file ${backup_path}/$db $db
          done
          echo "Dumping all in one gzip"
          pg_dumpall |gzip > ${backup_path}/complete_dump.sql.gz
        '';
        startAt = "daily";
      };

    };
  };
}
