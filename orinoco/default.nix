{ config, lib, pkgs, ... }:

{
  imports = [
    ../lib/machines/base.nix
  ];

  networking.hostName = lib.mkOverride 10 "orinoco";
  networking.useDHCP = true;
  networking.enableIPv6 = true;
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = false;
  networking.wicd.enable = true;
  services.hostapd.enable = false;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    freeipmi lm_sensors psmisc dnstop sysstat
  ];
  environment.shellAliases = {
    vinox = "vim";
  };

  programs.bash.enableCompletion = true;
  environment.sessionVariables = {
    EDITOR = "vim";
  };

  services.xserver.enable = true;
  services.xserver.layout = "de";
  services.xserver.desktopManager.kde5.enable = true;
  services.xserver.displayManager.kdm.enable = true;
}