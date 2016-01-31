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
    localAddress = "192.168.1.221";
    localAddress6 = "2001:470:1f0b:1033::6d:7064";
    config = { config, pkgs, ... }: {
      networking.firewall.enable = false;
      services.openssh.enable = true;
      services.mpd = {
        enable = true;
        musicDirectory = "/media/music";
      };
    };
  };
}
