{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/var/lib/containers/mpd/media/music" = {
      device = "/dev/portalgroup/music";
    };
  };

  containers.mpd = {
    autoStart = true;

    privateNetwork = true;
    hostBridge = "lan";
    localAddress = "192.168.1.221/24";
    localAddress6 = "2001:470:1f0b:1033::6d:7064/64";

    config = { config, pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        mpd
      ];

      networking.firewall.enable = false;

      services.mpd = {
        enable = true;
        musicDirectory = "/media/music";
      };
    };
  };
}
