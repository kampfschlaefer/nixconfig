{ config, lib, pkgs, ... }:

{
  imports = [
    ../lib/machines/base.nix
    ../lib/software/pwsafe.nix
    ../lib/users/arnold.nix
  ];

  nix.useSandbox = true;

  nixpkgs.config.allowUnfree = true;

  networking.hostName = lib.mkOverride 10 "orinoco";
  networking.useDHCP = false;
  networking.enableIPv6 = true;
  networking.wireless.enable = false;  # Disables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;
  networking.connman.enable = false;
  # networking.wicd.enable = true;
  services.hostapd.enable = false;

  users.users.arnold.extraGroups = [ "networkmanager" ];

  # List packages installed in system profile. To search by name, run:
  environment.systemPackages = with pkgs; [
    claws-mail firefox
    atom zeal
    seafile-client
    gitAndTools.tig
    python27 python33 python35
    python27Packages.virtualenv
    python35Packages.virtualenv
    kde5.networkmanager-qt
    # connman
  ];

  services.dbus.socketActivated = true;

  services.xserver.enable = true;
  services.xserver.layout = "de";
  services.xserver.synaptics = {
    enable = true;
    twoFingerScroll = true;
  };

  services.xserver.desktopManager.enlightenment.enable = true;
  services.xserver.desktopManager.kde5.enable = true;
  services.xserver.displayManager.sddm.enable = true;
}