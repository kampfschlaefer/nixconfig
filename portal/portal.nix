{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      #/etc/nixos/hardware-configuration.nix
      ./gitolite-container.nix
      ./testing-container.nix
      ./duply.nix
      ./postfix-satelite.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  fileSystems = {
    "/media/duplycache" = { device = "/dev/portalgroup/duplycache"; };
  };

  networking.hostName = "portal"; # Define your hostname.
  networking.domain = "arnoldarts.de";

  networking.nameservers = [ "192.168.1.250" "2001:470:1f0b:1033::1" "8.8.4.4" ];
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
    lan = { interfaces = [ "eno1" ]; };
  };

  networking.interfaces = {
    lan = {
      useDHCP = false;
      ip4 = [ { address = "192.168.1.240"; prefixLength = 24; } ];
      ip6 = [ { address = "2001:470:1f0b:1033::706f:7274:616c"; prefixLength = 64; } ];
    };
  };

  networking.defaultGateway = "192.168.1.250";
  networking.defaultGateway6 = "2001:470:1f0b:1033::1";

  networking.firewall = {
    enable = true;
    allowPing = true;
    rejectPackets = true;
  };

  #networking.defaultMailServer = {
  #  directDelivery = true;
  #  domain = "portal.arnoldarts.de";
  #  hostName = "starbase.arnoldarts.de";
  #  root = "arnold@starbase.arnoldarts.de";
  #  #useTLS = true;
  #};

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
    htop atop freeipmi lm_sensors psmisc
    vimNox byobu tmux python
    gptfdisk parted hdparm
    git
    duply gnupg
  ];
  environment.shellAliases = {
    vi = "vim";
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  #services.sudo.wheelNeedsPassword = false;
  security.pam.enableSSHAgentAuth = true;
  security.pam.services.ssh.sshAgentAuth = true;

  services.fcron.enable = true;
  #services.fcron.mailto = "root@starbase.arnoldarts.de";
  
  services.nfs.server = {
    enable = true;
    createMountPoints = true;
    exports = "/srv/nfs  192.168.0.0/24(rw,sync,fsid=0,crossmnt,no_subtree_check) 2001:470:1f0b:1033::/64(rw,sync,fsid=0,crossmnt,no_subtree_check)";
  };

  services.smartd = {
    enable = true;
    notifications = {
      mail.enable = true;
      mail.recipient = "arnold@arnoldarts.de";
      #test = true;
    };
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.arnold = {
     isNormalUser = true;
     uid = 1000;
     group = "users";
     extraGroups = [ "wheel" ];
     initialHashedPassword = "$6$iGIV7lSJNXd63m$p9ajhxdkbGI8ttLw7Zb3ej/yDjzPuHGAvy5dxUCk8pg4Zh8wGD.Lt4K5gQ/CEdwtvN.ai.z974T9BhVZTapq6.";
     openssh.authorizedKeys.keys = [
       "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRl2ySjWm53HKTmKU02I1M6y5tx0mJMlyBrp/1n4VBeye9wGmSxP+pIwdD1HH9xZC9OPDHv5DPMSlliccbqrq7pIibMXuIg9V+MdzAtzbeMptKvsx/uSUJFGSWwc4W3/QeYpFOp+u5CaQ9ZoMhiwIeVY7Z1UTd8SRRyzMNtsIdF0A61r1AhNoV4CNK8wuKzfAokBEmxUeW+uGuILZeEX6B1y3ml4dWBBSOfYqbEfxU1/mDw5OAMaSo8k3o6CKQ8YVywimeURgnGG0DbVvF6oSNc2xxUKG5EIKc1E5dsaLWR0EwZ9zpvGPWHB1pv0zPBV6gkFwSbP3LpqwTkj8U8YChPw9hrq+ONGEaWVaczLqApw7aUdALpis7nkPueTQdsXD036MuwH6tZWNGEnkZb/JoE9eewPMBJNYnxY9e+Nj9DVitByrKLWA+T4bZEQf4uUl8LEKv4tp8ePYDKiDmRkRLE7CdpkO5f2vttMrGPMCB0LHvsepy/S6sROSAGzq8VS+fjubRKy6XBHlVrJGQ5eqk7c01H+oDPYSStADXO60fr4YHBBfrQMzc/7/Xb+UrsjJXP5etaNU1H2KPj7SuoEmBhkWrm0KKKdgBYZyl5Cjj5FcAd/hIpreyNDyb6jSgWduXLxc63HZB5aak4N2fDrORd3C8duNN7dswnBjD7MZ4zQ== arnold@xingu.arnoldarts.de"
     ];
  };

}

