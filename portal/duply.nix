{ config, pkgs, ... }:

{
  systemd.services.duplyamazon = {
    path = [ pkgs.bash pkgs.duply pkgs.duplicity ];
    #serviceConfig = {
      #PrivateTmp = false;
      #PrivateNetwork = false;
      #User = "root";
      #WorkingDirectory = "/root";
    #};
    script = "bash -l -c \"duply amazon backup\"";
    startAt = "*-*-* 2:10:00";
  };
}
