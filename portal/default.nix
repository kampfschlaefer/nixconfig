{ config, lib, pkgs, ... }:

let
  vgfilesystems = [ "audiofiles" "je_pictures" "misc-system" "videos" ];
in {
  imports =
    [ # Include the results of the hardware scan.
      #/etc/nixos/hardware-configuration.nix
      ../lib/users/arnold.nix
      ./containers/gitolite.nix
      ./containers/testing.nix
      ./containers/mpd.nix
      ./containers/cups.nix
      ./containers/firewall.nix
      ./containers/imap.nix
      ./duply.nix
      ./postfix-satelite.nix
      ./unbound.nix
      ./dhcpd.nix
      ./ups.nix
    ];

  nix.nixPath = [
    "/etc/nixos/nixconfig/nixpkgs"
    "nixpkgs=/etc/nixos/nixconfig/nixpkgs"
    "nixos-config=/etc/nixos/configuration.nix"
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  boot.kernelModules = [ "dm-mirror" "dm-snapshot" ];

  fileSystems = {
    "/media/duplycache" = { device = "/dev/portalgroup/duplycache"; };
    "/media/backup" = { device = "/dev/portalgroup/backup"; options = "defaults,noauto"; };
  } // builtins.listToAttrs(
    map (x:
      {
        name = "/srv/nfs/${x}";
        value = { device = "/dev/portalgroup/${x}"; };
      }
    ) vgfilesystems
  );

  networking.hostName = lib.mkOverride 10 "portal"; # Define your hostname.
  networking.domain = "arnoldarts.de";

  networking.nameservers = lib.mkOverride 100 [
    "192.168.1.240"
    #"2001:470:1f0b:1033::706f:7274:616c"
    "8.8.4.4"              # Google DNS
    #"2001:4860:4860::8888" # Google DNS
    "74.82.42.42"          # Hurricane Electric
    #"2001:470:20::2"       # Hurricane Electric
  ];
  networking.search = [ "arnoldarts.de" ];

  networking.enableIPv6 = true;
  networking.useDHCP = false;
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = false;
  networking.wicd.enable = false;
  services.hostapd.enable = false;

  networking.nat = {
    # enable nat to enable ip forwarding
    enable = true;
  };

  networking.bridges = {
    lan = { interfaces = lib.mkOverride 100 [ "eno1" ]; };
  };

  networking.interfaces = {
    lan = {
      useDHCP = false;
      ip4 = [ { address = "192.168.1.240"; prefixLength = 24; } ];
      ip6 = [ { address = "2001:470:1f0b:1033::706f:7274:616c"; prefixLength = 64; } ];
    };
  };

  networking.defaultGateway = "192.168.1.220";
  networking.defaultGateway6 = "2001:470:1f0b:1033::1";

  networking.firewall = {
    enable = true;
    allowPing = true;
    rejectPackets = true;
    allowedTCPPorts = [ 111 2049 4001 4002 ];
    allowedUDPPorts = [ 111 2049 4001 4002 60001 ];
    rules = [
      {
        fromInterface = "lan";
        toInterface = "ve-gitolite";
        target = "ACCEPT";
      }
    ];
    extraPackages = [ pkgs.procps ];
    extraCommands = ''
      sysctl net.ipv4.conf.all.forwarding=1
      sysctl net.ipv6.conf.all.forwarding=1
    '';
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "de";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    wget tcpdump nmap
    htop atop freeipmi lm_sensors psmisc dnstop sysstat
    vimNox byobu tmux python
    gptfdisk parted hdparm
    git
    duply gnupg
    linuxPackages.netatop
  ];
  environment.shellAliases = {
    vi = "vim";
  };

  programs.bash.enableCompletion = true;
  environment.sessionVariables = {
    EDITOR = "vim";
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  #services.sudo.wheelNeedsPassword = false;
  security.pam.enableSSHAgentAuth = true;
  security.pam.services.ssh.sshAgentAuth = true;

  services.fcron.enable = true;
  #services.fcron.mailto = "root@starbase.arnoldarts.de";

  services.nscd.enable = false;

  services.nfs.server = {
    enable = true;
    createMountPoints = true;
    lockdPort = 4001;
    mountdPort = 4002;
    exports = "/srv/nfs  192.168.1.0/24(rw,sync,fsid=0,crossmnt,no_subtree_check) 2001:470:1f0b:1033::/64(rw,sync,fsid=0,crossmnt,no_subtree_check)";
  };

  services.smartd = {
    enable = true;
    notifications = {
      mail.enable = true;
      mail.recipient = "arnold@arnoldarts.de";
      #test = true;
    };
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  #power.ups.enable = true;
  #power.ups.mode = "netclient";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.kdm.enable = true;
  # services.xserver.desktopManager.kde4.enable = true;

}

