{ config, lib, pkgs, ... }:

let
  pyheimpkg = pkgs.callPackage ../../lib/software/pyheim {};

  pyheim_timer = {
    serviceConfig = {
      User = "root";
      WorkingDirectory = "/root";
    };
    script = "${pyheimpkg}/bin/pyheim_colortemp --transitiontime 20 0";
  };
in
{
  containers.pyheim = {
    autoStart = lib.mkOverride 100 true;

    privateNetwork = true;
    hostBridge = "lan";
    localAddress = "192.168.1.226/24";
    localAddress6 = "2001:470:1f0b:1033::7079:6865:696d/64";

    config = { config, pkgs, ... }: {
      time.timeZone = "Europe/Berlin";

      networking.domain = "arnoldarts.de";
      networking.firewall.enable = false;

      services.openssh = {
        enable = true;
        allowSFTP = true;
        startWhenNeeded = true;
      };

      environment.systemPackages = [ pyheimpkg ];

      systemd.services.pyheim_colortemp_daytime = pyheim_timer // {
        startAt = "*-*-* 17,18,19,20,21,22,23:*:00";
      };
      systemd.services.pyheim_colortemp_night = pyheim_timer // {
        startAt = "*-*-* 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17:00/5:00";
      };
      systemd.services.pyheim_spots_off = pyheim_timer // {
        startAt = "*-*-* 1:00,05:00";
        script = "${pyheimpkg}/bin/pyheim_spot_cmd off";
      };
    };
  };
}
