{ config, pkgs, ... }:

{
  fileSystems = {
    "/media/duplydisk" = {
      device = "/dev/disk/by-uuid/4bff6ea6-a6f4-4163-9a7e-1703c84cb769";
      options = [ "noauto" ];
    };
  };
  systemd.automounts = [
    {
      wantedBy = [ "multi-user.target" ];
      where = "/media/duplydisk";
    }
  ];

  systemd.services.duplyamazon = {
    path = [ pkgs.bash pkgs.duply pkgs.duplicity ];
    serviceConfig = {
      User = "root";
      WorkingDirectory = "/root";
    };
    environment =  {
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    };
    script = "duply amazon backup";
    startAt = "*-*-* 2:10:00";
  };
}
