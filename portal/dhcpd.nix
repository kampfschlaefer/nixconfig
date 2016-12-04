{ config, lib, pkgs, ... }:


# ranges:
# 65-94 (/27) known hosts with fixed addresses
# 97-126 (/26) known hosts dhcp
# 129-158 (/27) unknown hosts (no default route)
#
with lib;
# dhcp-host=00:21:04:f4:76:df,c470-ip,6h
# dhcp-host=00:18:84:24:F5:58,openwrt
# #dhcp-host=00:00:cb:61:18:80,saratoga,192.168.1.205
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
    { hostName = "watering-lan";  ethernetAddress = "b8:27:eb:c3:4c:ae"; } # lan
    { hostName = "watering-wifi"; ethernetAddress = "7c:dd:90:73:6b:6b"; } # wifi
    { hostName = "raspimate";     ethernetAddress = "7c:dd:90:73:6a:56"; }
    { hostName = "raspio";        ethernetAddress = "7c:dd:90:5d:91:97"; }
    { hostName = "touchpi";       ethernetAddress = "b8:27:eb:73:38:22"; ipAddress = "192.168.1.70"; }
    { hostName = "android-lg";    ethernetAddress = "f8:a9:d0:1e:b7:29"; }
    { hostName = "android-ines";  ethernetAddress = "60:be:b5:0a:73:d3"; }
    { hostName = "flachmann";     ethernetAddress = "00:22:f4:4e:5e:8e"; }
    { hostName = "xingu";         ethernetAddress = "d0:50:99:4f:3b:07"; ipAddress = "192.168.1.65"; }
    { hostName = "amazonas";      ethernetAddress = "ac:b5:7d:3a:0f:ce"; ipAddress = "192.168.1.67"; }
    { hostName = "orinoco";       ethernetAddress = "78:e4:00:90:74:79"; ipAddress = "192.168.1.66"; }
    { hostName = "orinoco-wire";  ethernetAddress = "b8:ac:6f:75:bf:d3"; }
    { hostName = "ebookold";      ethernetAddress = "ac:a2:13:a1:46:c3"; }
    { hostName = "ebook";         ethernetAddress = "28:f3:66:9c:13:71"; }
    { hostName = "steuer";        ethernetAddress = "08:00:27:1f:06:82"; }
    { hostName = "pi-top";        ethernetAddress = "b8:27:eb:89:25:ec"; }
    { hostName = "blueray";       ethernetAddress = "98:93:cc:50:0c:77"; }
    { hostName = "firestick";     ethernetAddress = "34:d2:70:04:0b:4d"; }
    { hostName = "arduino";       ethernetAddress = "18:fe:34:cf:a7:26"; }
  ] ++ (if config.testdata then [
    { hostName = "inside";        ethernetAddress = "7e:e2:63:7f:f0:0e"; }
  ] else []);
in {
  services.dhcpd = {
    enable = true;
    interfaces = [ "lan" ];
    machines = [];  # filter (host: hasAttr "ipAddress" host) known_hosts;
    extraConfig = ''
      ddns-update-style none;
      ddns-updates off;

      option subnet-mask 255.255.255.0;
      # option domain-name-servers 192.168.1.240 2001:470:1f0b:1033::706f:7274:616c;
      option domain-name-servers 192.168.1.240;
      option domain-name "arnoldarts.de";

      subnet 192.168.1.0 netmask 255.255.255.0 {

        group {
          default-lease-time 7200;
          max-lease-time 14400;
          option routers 192.168.1.220;
          ${lib.concatMapStrings
            (machine:
              ''
                host ${machine.hostName} { hardware ethernet ${machine.ethernetAddress}; fixed-address ${machine.ipAddress}; }
              ''
            )
            (filter (host: hasAttr "ipAddress" host) known_hosts)
          }
        }
        pool {
          # This is a /27 network for the known clients in 97-126
          range 192.168.1.97 192.168.1.126;
          default-lease-time 7200;
          max-lease-time 14400;
          deny unknown-clients;

          option routers 192.168.1.220;

          ${lib.concatMapStrings
            (machine:
              ''
                host ${machine.hostName} { hardware ethernet ${machine.ethernetAddress}; }
              ''
            )
            (filter (host: !hasAttr "ipAddress" host) known_hosts)
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
