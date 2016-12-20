{ config, lib, pkgs, ... }:

let
  /*bishbosh_pkg = pkgs.callPackage ../../lib/software/bishbosh {};*/
  /*pyheimpkg = pkgs.callPackage ../../lib/software/pyheim {};

  pyheim_timer = {
    serviceConfig = {
      User = "root";
      WorkingDirectory = "/root";
    };
    script = "${pyheimpkg}/bin/pyheim_colortemp --transitiontime 20 0";
  };*/
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

        users = {};
      };

      /*environment.systemPackages = [ pyheimpkg ];*/

      /*systemd.services.pyheim_colortemp_daytime = pyheim_timer // {
        startAt = "*-*-* 17,18,19,20,21,22,23:*:00";
      };
      systemd.services.pyheim_colortemp_night = pyheim_timer // {
        startAt = "*-*-* 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16:00/5:00";
      };
      systemd.services.pyheim_spots_off = pyheim_timer // {
        startAt = "*-*-* 1:00,05:00";
        script = "${pyheimpkg}/bin/pyheim_spot_cmd off";
      };*/
    };
  };
}
