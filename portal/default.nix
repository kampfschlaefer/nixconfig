{ config, lib, pkgs, ... }:

let
  vgfilesystems = [
    "je_pictures"
    "misc-system"
    "videos"
  ];
  pkg_startpage = pkgs.callPackage ../lib/software/startpage {};
in {
  options.testdata = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };
  options.debug_unbound = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  imports =
    [
      ./hardware-configuration.nix
      ../lib/machines/base.nix
      ../lib/users/arnold.nix
      #./containers/cups.nix
      ./containers/firewall.nix
      ./containers/gitolite.nix
      ./containers/homeassistant.nix
      #./containers/influxdb.nix
      #./containers/imap.nix
      ./containers/postgres.nix
      ./containers/syncthing.nix
      ./containers/torproxy.nix
      ./containers/selfoss.nix
      #./containers/mpd.nix
      ./dhcpd.nix
      ./duply.nix
      ./postfix-satelite.nix
      ./unbound.nix
      #./ups.nix
    ];

  config = {
    # Use the GRUB 2 boot loader.
    boot.loader = {
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";

      grub = {
        enable = true;
        version = 2;
        efiSupport = true;

        devices = [
          "/dev/disk/by-id/ata-INTEL_SSDSC2BW180A4_CVDA447006A31802GN"
          "/dev/disk/by-id/ata-INTEL_SSDSC2KW480H6_CVLT61850B1Q480EGN"
        ];

        # Define on which hard drive you want to install Grub.
        mirroredBoots = [
          { devices = [ "/dev/disk/by-id/ata-INTEL_SSDSC2BW180A4_CVDA447006A31802GN" ]; path = "/boot2"; }
          { devices = [ "/dev/disk/by-id/ata-INTEL_SSDSC2KW480H6_CVLT61850B1Q480EGN" ]; path = "/boot"; }
        ];
      };
    };

    boot.kernelModules = [ "dm-mirror" "dm-snapshot" "kvm-intel" "dm-raid" ];
    boot.extraModulePackages = [ ];
    boot.extraModprobeConfig = ''
      options kvm_intel nested=y
    '';
    boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "uhci_hcd" "xhci_pci" "usbhid" "usb_storage" ];

    fileSystems = {
      "/media/duplycache" = { device = "/dev/portalgroup/duplycache"; };
      "/media/backup" = { device = "/dev/portalgroup/backup"; options = ["defaults" "noauto"]; };
    } // builtins.listToAttrs(
      map (x:
        {
          name = "/srv/nfs/${x}";
          value = { device = "/dev/portalgroup/${x}"; };
        }
      ) vgfilesystems
    );

    services.hostapd.enable = false;

    networking = {
      hostName = lib.mkOverride 10 "portal"; # Define your hostname.
      domain = "arnoldarts.de";

      nameservers = [
        "192.168.1.240"
        #"2001:470:1f0b:1033::706f:7274:616c"
        #"8.8.4.4"              # Google DNS
        #"2001:4860:4860::8888" # Google DNS
        #"74.82.42.42"          # Hurricane Electric
        #"2001:470:20::2"       # Hurricane Electric
      ];
      search = [ "arnoldarts.de" ];

      enableIPv6 = true;
      useDHCP = false;
      useHostResolvConf = false;
      wireless.enable = false;  # Enables wireless support via wpa_supplicant.
      networkmanager.enable = false;
      wicd.enable = false;

      nat = {
        # enable nat to enable ip forwarding
        enable = false;
      };

      vlans = lib.mkOverride 100 {
        vlan10 = { id = 10; interface = "eno1"; };
        wifi = { id = 2; interface = "eno1"; };
      };

      bridges = {
        lan = { interfaces = lib.mkOverride 100 [ "eno1" ]; };
        dmz = { interfaces = lib.mkOverride 100 [ "eno2" "vlan10" ]; };
        backend = { interfaces = []; };
      };

      interfaces = {
        lan = {
          useDHCP = false;
          ipv4.addresses = [
            { address = "192.168.1.240"; prefixLength = 24; }
            { address = "192.168.1.233"; prefixLength = 32; }
          ];
          ipv6.addresses = [
            { address = "2001:470:1f0b:1033::706f:7274:616c"; prefixLength = 64; }
            { address = "2001:470:1f0b:1033::73:7461:7274"; prefixLength = 128; }
          ];

        };
        dmz = {
          useDHCP = false;
          ipv4.addresses = [];
          ipv6.addresses = [];
        };
        backend = {
          useDHCP = false;
          ipv4.addresses = [];
          ipv6.addresses = [];
        };
      };

      defaultGateway = "192.168.1.220";
      defaultGateway6 = "2001:470:1f0b:1033::1";

      firewall = {
        enable = true;
        allowPing = true;
        rejectPackets = true;
        allowedTCPPorts = [ 111 2049 4001 4002 80 443 ];
        allowedUDPPorts = [ 111 123 2049 4001 4002 60001 ];
        extraPackages = [ pkgs.procps ];
        extraCommands = ''
          sysctl net.ipv4.conf.all.forwarding=1
          sysctl net.ipv6.conf.all.forwarding=1
        '';
      };
    };

    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    environment.systemPackages = with pkgs; [
      freeipmi lm_sensors dnstop
      duply gnupg
      /* linuxPackages.netatop */
    ];
    environment.shellAliases = {
    };

    # List services that you want to enable:

    services.fcron.enable = true;
    #services.fcron.mailto = "root@starbase.arnoldarts.de";

    services.nscd.enable = false;

    services.dnsmasq.enable = false;
    services.dnsmasq.resolveLocalQueries = false;

    services.nfs.server = {
      enable = true;
      createMountPoints = true;
      lockdPort = 4001;
      mountdPort = 4002;
      exports = "/srv/nfs  192.168.1.0/24(rw,sync,fsid=0,crossmnt,no_subtree_check) 2001:470:1f0b:1033::/64(rw,sync,fsid=0,crossmnt,no_subtree_check)";
    };

    services.ntp.enable = false;

    services.openntpd = {
      enable = true;
      servers = [ "pool.ntp.org" "0.ubuntu.pool.ntp.org" "1.ubuntu.pool.ntp.org" "0.nixos.pool.ntp.org" "1.nixos.pool.ntp.org" ];
      extraConfig = ''
        listen on 192.168.1.240
        listen on 2001:470:1f0b:1033::706f:7274:616c
      '';
    };

    services.smartd = {
      enable = true;
      notifications = {
        mail.enable = true;
        mail.recipient = "arnold@arnoldarts.de";
        #test = true;
      };
    };

    services.nginx = {
      enable = true;
      sslCiphers = "ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:!RSA+AES:!aNULL:!MD5:!DSS";
      recommendedTlsSettings = true;
      recommendedProxySettings = false;
      virtualHosts = {
        "startpage" = {
          serverName = "startpage.arnoldarts.de";
          listen = [
            { addr = "192.168.1.233"; port=80; ssl=false; }
            { addr = "192.168.1.233"; port=443; ssl=true; }
            { addr = "[2001:470:1f0b:1033::73:7461:7274]"; port=80; ssl=false; }
            { addr = "[2001:470:1f0b:1033::73:7461:7274]"; port=443; ssl=true; }
          ];
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            root = pkg_startpage;
            index = "index.html";
          };
        };
      };
    };

    virtualisation.libvirtd = {
      enable = true;
      qemuPackage = pkgs.qemu_kvm;
      onShutdown = "suspend";
    };
    users.users.arnold.extraGroups = [ "libvirtd" ];

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

  };
}

