{ config, lib, pkgs, ... }:

{
  imports = [
    ../lib/machines/base.nix
    ../lib/software/pwsafe.nix
    ../lib/users/arnold.nix
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
    claws-mail firefox
    gitAndTools.tig
    python27Packages.virtualenv
  ];
  environment.shellAliases = {
    vinox = "vim";
  };

  programs.bash.enableCompletion = true;

  services.xserver.enable = true;
  services.xserver.layout = "de";
  services.xserver.desktopManager.kde5.enable = true;
  services.xserver.displayManager.kdm.enable = true;
}