{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/var/lib/containers/imap/var/spool/mail" = {
      device = "/dev/portalgroup/maildir";
    };
  };

  containers.imap = {
    autoStart = true;

    privateNetwork = true;
    hostBridge = "lan";

    config = { config, pkgs, ... }: {
      networking.domain = "arnoldarts.de";
      networking.interfaces.eth0 = {
        useDHCP = false;
        ip4 = [{ address = "192.168.1.224"; prefixLength = 24; }];
        ip6 = [{ address = "2001:470:1f0b:1033::696d:6170"; prefixLength = 64; }];
      };

      imports = [
        ../../lib/users/arnold.nix
      ];
      users.users.arnold.group = lib.mkOverride 10 services.dovecot2.group;

      networking.firewall.enable = false;

      services.openssh = {
        enable = true;
        allowSFTP = true;
        startWhenNeeded = true;
      };

      services.dovecot2 = {
        enable = true;
        enableImap = true;
        enableLmtp = true;
        enablePop3 = false;
        mailLocation = "maildir:/var/spool/mail/%u";
        /*sslCACert = "";
        sslServerCert = "";
        sslServerKey = "";*/
      };
    };
  };
}