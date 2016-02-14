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
      users.users.arnold.group = lib.mkOverride 10 "dovecot2";

      environment.systemPackages = with pkgs; [
        offlineimap
        vimNox
      ];

      networking.firewall = {
        enable = true;
        defaultPolicies = { input = "DROP"; output = "DROP"; forward="DROP"; };
        rules = [
          { fromInterface = "lo"; target = "ACCEPT"; }
          { toInterface = "lo"; target = "ACCEPT"; }
          { fromInterface = "eth0"; protocol = "tcp"; destinationPort = "22"; target = "ACCEPT"; }
          { fromInterface = "eth0"; protocol = "tcp"; destinationPort = "143"; target = "ACCEPT"; }
          { fromInterface = "eth0"; protocol = "tcp"; destinationPort = "993"; target = "ACCEPT"; }
          { toInterface = "eth0"; protocol = "tcp"; destinationPort = "143"; target = "ACCEPT"; }
          { toInterface = "eth0"; protocol = "tcp"; destinationPort = "993"; target = "ACCEPT"; }
          { fromInterface = "eth0"; protocol = "icmp"; target = "ACCEPT"; }
          { toInterface = "eth0"; protocol = "icmp"; target = "ACCEPT"; }
          { fromInterface = "eth0"; protocol = "icmp6"; target = "ACCEPT"; }
          { toInterface = "eth0"; protocol = "icmp6"; target = "ACCEPT"; }
        ];
      };

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