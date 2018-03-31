{ config, lib, pkgs, ... }:

with lib;

let
  secrets = import ./ups_secrets.nix {};

in {
  power.ups = {
    enable = true;
    mode = "standalone";
    ups = if config.testdata then {
      eaton = {
        description = "Test UPS";
        driver = "dummy-ups";
        port = "dummy-ups.txt";
      };
    } else secrets.ups;
  };

  environment.etc = [
    {
      source = pkgs.writeText "upsd.conf" ''
      LISTEN 127.0.0.1
      LISTEN ::1
      '';
      target = "nut/upsd.conf";
      mode = "0600";
    }
    {
      text = if config.testdata then ''
      [monmaster]
        password = password
        upsmon master
      '' else secrets.upsd_users;
      target = "nut/upsd.users";
      mode = "0600";
    }
    {
      text = if config.testdata then ''
      MONITOR eaton 1 monmaster password master
      '' else secrets.upsmon_conf;
      target = "nut/upsmon.conf";
      mode = "0600";
    }
  ] ++ (if config.testdata then [
    {
      source = pkgs.writeText "dummy-ups.txt" ''
      ups.status: 0L
      TIMER 60
      '';
      target = "nut/dummy-ups.txt";
      mode = "0600";
    }
  ] else []);
  system.activationScripts.upsSetup2 = stringAfter [ "users" "groups" "upsSetup" ] ''
    mkdir -p /var/lib/nut
    chmod o-rwx /var/lib/nut
  '';
}