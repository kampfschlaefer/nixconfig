{ config, lib, pkgs, ... }:

{
  imports = [
    ../lib/machines/base.nix
    ../lib/software/pwsafe.nix
    ../lib/users/arnold.nix
  ];

  nixpkgs.config.allowUnfree = true;

  networking.hostName = lib.mkOverride 10 "orinoco";
  networking.useDHCP = true;
  networking.enableIPv6 = true;
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = false;
  networking.wicd.enable = true;
  services.hostapd.enable = false;

  users.users.arnold.extraGroups = [ "networkmanager" ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    claws-mail firefox
    gitAndTools.tig
    python27Packages.virtualenv
  ];

  services.xserver.enable = true;
  services.xserver.layout = "de";
  services.xserver.synaptics = {
    enable = true;
    twoFingerScroll = true;
  };
  services.xserver.desktopManager.kde5.enable = true;
  services.xserver.displayManager.sddm.enable = true;
}