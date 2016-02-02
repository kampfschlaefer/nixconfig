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

      imports = [
        ../../lib/users/arnold.nix
      ];
      # users.users.arnold.home = "/media/music";
      users.users.arnold.group = lib.mkOverride 10 "mpd";

      networking.firewall.enable = false;

      services.openssh = {
        enable = true;
        allowSFTP = true;
        startWhenNeeded = true;
      };

      services.mpd = {
        enable = true;
        musicDirectory = "/media/music";
        extraConfig = ''
          audio_output {
            type            "httpd"
            name            "My HTTP Stream"
            encoder         "vorbis"                # optional, vorbis or lame
            port            "8000"
            quality         "5.0"                   # do not define if bitrate is defined
            #bitrate         "192"                   # do not define if quality is defined
            #format          "48000:16:2"
          }
        '';
      };
      systemd.services.mpd.postStart = ''
        if [ ! -d ${config.services.mpd.dataDir}/playlists ]; then
          mkdir -p ${config.services.mpd.dataDir}/playlists
          chown -R ${config.services.mpd.user}:${config.services.mpd.group} ${config.services.mpd.dataDir}
        fi
        chown :${config.services.mpd.group} ${config.services.mpd.musicDirectory}
        chmod 2775 ${config.services.mpd.musicDirectory}
      '';
    };
  };
}
