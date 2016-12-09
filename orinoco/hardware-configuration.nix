# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports = [
    ../nixpkgs/nixos/modules/installer/scan/not-detected.nix
  ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.initrd.luks.devices = [ { name = "luksroot"; device = "/dev/sda2"; preLVM = true; allowDiscards = true; } ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/066226b8-fdb4-4443-bf01-8b1c85d7fbae";
      fsType = "ext4";
      options = [ "noatime" "nodiratime" "discard" ];
    };
  fileSystems."/boot" =
    { device = "/dev/sda1";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/0932d0d2-c344-490f-a0ce-d36e8c8a3240"; }
    ];

  nix.maxJobs = lib.mkDefault 2;
}
