{ config, pkgs, ... }:

{
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
