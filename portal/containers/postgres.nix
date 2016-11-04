{ config, lib, pkgs, ...}:

let
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
        package = pkgs.postgresql95;
        authentication = ''
          host selfoss selfoss 192.168.6.2/32 trust
        '';
        initialScript = builtins.toFile "pg_initial_script" ''
          CREATE ROLE selfoss LOGIN CREATEDB;
          CREATE DATABASE selfoss OWNER selfoss;
        '';
      };

    };
  };
}