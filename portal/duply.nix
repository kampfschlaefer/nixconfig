{ config, pkgs, ... }:

{
  systemd.services.duplyamazon = {
    path = [ pkgs.duply pkgs.duplicity ];
    #environment = { LANG = "C"; HOME="/root"; TMPDIR="/tmp"; USER="root"; };
    serviceConfig = {
      PrivateTmp = false;
      PrivateNetwork = false;
      User = "root";
      WorkingDirectory = "/root";
    };
    script = "duply amazon status 2>&1 ";
    #startAt = "Sat 4:10:00";
  };
  #systemd.services.testduply = {
  #  path = [ pkgs.duply ];
  #  environment = { LANG = "C"; HOME="/root"; TMPDIR="/tmp"; };
  #  serviceConfig = {
  #    privateTmp = false;
  #    privateNetwork = false;
  #  };
  #  script = "set";
  #};
}
