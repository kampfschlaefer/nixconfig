{ config, lib, pkgs, ... }:

{
  fileSystems = {
    "/var/lib/containers/imap/var/spool/mail" = {
      device = "/dev/portalgroup/maildir";
    };
  };

  systemd.services."container@imap".after = [ "container@firewall.service" ];

  containers.imap = {
    autoStart = lib.mkOverride 100 false;

    privateNetwork = true;
    hostBridge = "lan";

    config = { config, pkgs, ... }: {
      networking.domain = "arnoldarts.de";
      networking.interfaces.eth0 = {
        useDHCP = false;
        ipv4.addresses = [{ address = "192.168.1.224"; prefixLength = 24; }];
        ipv6.addresses = [{ address = "2001:470:1f0b:1033::696d:6170"; prefixLength = 64; }];
      };

      imports = [
        ../../lib/users/arnold.nix
        ../../lib/software/myfirewall.nix
      ];
      users.users.arnold.group = lib.mkOverride 10 "dovecot2";

      environment.systemPackages = with pkgs; [
        offlineimap
        vim_configurable
      ];

      networking.myfirewall = {
        enable = false;
        defaultPolicies = { input = "DROP"; output = "DROP"; forward="DROP"; };
        rules = [
          { fromInterface = "lo"; target = "ACCEPT"; }
          { toInterface = "lo"; target = "ACCEPT"; }
          /*{ fromInterface = "eth0"; protocol = "tcp"; destinationPort = "22"; target = "ACCEPT"; }*/
          { toInterface = "eth0"; protocol = "udp"; destinationPort = "53"; target = "ACCEPT"; }
          { fromInterface = "eth0"; protocol = "tcp"; destinationPort = "24"; target = "ACCEPT"; }
          { fromInterface = "eth0"; protocol = "tcp"; destinationPort = "143"; target = "ACCEPT"; }
          { fromInterface = "eth0"; protocol = "tcp"; destinationPort = "993"; target = "ACCEPT"; }
          { toInterface = "eth0"; protocol = "tcp"; destinationPort = "143"; target = "ACCEPT"; }
          { toInterface = "eth0"; protocol = "tcp"; destinationPort = "993"; target = "ACCEPT"; }
          { fromInterface = "eth0"; protocol = "icmp"; target = "ACCEPT"; }
          { toInterface = "eth0"; protocol = "icmp"; target = "ACCEPT"; }
          { fromInterface = "eth0"; protocol = "icmpv6"; target = "ACCEPT"; }
          { toInterface = "eth0"; protocol = "icmpv6"; target = "ACCEPT"; }
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
        extraConfig = ''
          service lmtp {
            inet_listener lmtp {
              address = 192.168.1.224 2001:470:1f0b:1033::696d:6170 127.0.0.1 ::1
              port = 24
            }
          }
          protocol lmtp {
            #mail_plugins = $mail_plugins sieve
            postmaster_address = arnold@arnoldarts.de
          }
        '';
        /*sslCACert = "";
        sslServerCert = "";
        sslServerKey = "";*/
      };
    };
  };
}