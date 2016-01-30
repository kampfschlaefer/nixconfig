{ config, pkgs, ... }:

{
  systemd.services.duplyamazon = {
    path = [ pkgs.duply ];
    environment = { LANG = "C"; HOME="/root"; TMPDIR="/tmp"; };
    script = "duply amazon backup";
    startAt = "Sat 13:27:00";
  };
}
