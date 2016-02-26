{ config, lib, pkgs, ... }:

with lib;
# dhcp-host=00:21:04:f4:76:df,c470-ip,6h
# dhcp-host=00:19:3e:00:42:03,pirelli,6h
# dhcp-host=00:18:84:24:F5:58,openwrt
# #dhcp-host=00:00:cb:61:18:80,saratoga,192.168.1.205
# #dhcp-host=00:15:17:26:25:18,xingu,192.168.1.50
# dhcp-host=38:ec:e4:cc:c4:dc,schieber
# dhcp-host=7c:dd:90:5d:91:97,raspio
# # watering lan
# dhcp-host=b8:27:eb:c3:4c:ae,watering
# # watering wireless
# dhcp-host=7c:dd:90:73:6b:6b,watering
# # raspimate wlan
# dhcp-host=7c:dd:90:73:6a:56,raspimate
# dhcp-host=00:17:88:1a:21:a5,philips-hue,192.168.1.197,set:mute*/

let
  known_hosts = [
    { name = "watering-lan"; ethernetAddress = "b8:27:eb:c3:4c:ae"; } # lan
    { name = "watering-wifi"; ethernetAddress = "7c:dd:90:73:6b:6b"; } # wifi
    { name = "raspimate"; ethernetAddress = "7c:dd:90:73:6a:56"; }
    { name = "raspio"; ethernetAddress = "7c:dd:90:5d:91:97"; }
    { name = "android-lg"; ethernetAddress = "f8:a9:d0:1e:b7:29"; }
    { name = "android-ines"; ethernetAddress = "60:be:b5:0a:73:d3"; }
    { name = "xingu"; ethernetAddress = "d0:50:99:4f:3b:07"; }
  ];
in {
  services.dhcpd = {
    enable = true;
    interfaces = [ "lan" ];
    machines = [
      # { ethernetAddress = ""; hostName = ""; ipAddress = ""; }
    ];
    extraConfig = ''
      option subnet-mask 255.255.255.0;
      # option domain-name-servers 192.168.1.240 2001:470:1f0b:1033::706f:7274:616c;
      option domain-name-servers 192.168.1.240;
      option domain-name "arnoldarts.de";

      subnet 192.168.1.0 netmask 255.255.255.0 {

        pool {
          range 192.168.1.90 192.168.1.126;
          default-lease-time 7200;
          max-lease-time 14400;
          deny unknown-clients;

          option routers 192.168.1.220;

          ${lib.concatMapStrings
            (machine:
              ''
                host ${machine.name} { hardware ethernet ${machine.ethernetAddress}; }
              ''
            )
            known_hosts
          }
        }

        pool {
          range 192.168.1.129 192.168.1.158;
          default-lease-time 300;
          max-lease-time 1800;
          allow unknown-clients;
        }
      }
    '';
  };
}