{ config, lib, pkgs, ... }:

let
  mqtt_users = {
    homeassistant = {
      acl = [];
      hashedPassword = "$6$qk8CJ.6G5.v$z1Rlj8ngtF4wyHDrrdG4f5e6sJ9V.Ra8l5Bto/RI9843sKq5AtMvq/QGsprOFFaIbJDzXpxuslx9KE1gE8v0e1";
    };
    arnold = {
      acl = [];
      hashedPassword = "$6$CHag5zouOUPC$ecdfyuTz0uObdIA/t7e2zwnMtR1kYG9/nWpUhUbOw94brizo8GitRKmC874RYdSe/8vxSqW5G/reaj0FOQT6f0";
    };
  } // (if config.testdata then {
    testclient = { acl = []; password = "password"; };
  } else {});
in
{
  containers.mqtt = {
    autoStart = lib.mkOverride 100 true;

    privateNetwork = true;
    hostBridge = "lan";
    localAddress = "192.168.1.229/24";
    localAddress6 = "2001:470:1f0b:1033::6d71:7474/64";

    config = { config, pkgs, ... }: {
      time.timeZone = "Europe/Berlin";

      networking.domain = "arnoldarts.de";
      networking.firewall.enable = false;

      services.openssh = {
        enable = true;
        allowSFTP = true;
        startWhenNeeded = true;
      };

      services.mosquitto = {
        enable = true;
        host = "0.0.0.0";
        port = 1883;

        users = mqtt_users;
      };
    };
  };
}
