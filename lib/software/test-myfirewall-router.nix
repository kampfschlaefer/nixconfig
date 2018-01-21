# Test the myfirewall module.

import ../../nixpkgs/nixos/tests/make-test.nix ( { pkgs, ... } :
with pkgs.lib;
let
  pingcmd = ip: "\"ping -n -c 1 ${ip} >&2\"";
  ping6cmd = ip: "\"ping -6 -n -c 1 ${ip} >&2\"";
in {
  name = "myfirewall-router";
  meta = with pkgs.stdenv.lib.maintainers; {
    maintainers = [ kampfschlaefer ];
  };

  nodes = {
    router = { config, pkgs, nodes, ... }:
    {
      virtualisation.vlans = [ 1 2 3 ];

      imports = [ ./myfirewall.nix ];

      networking = {
        interfaces = mkOverride 0 (listToAttrs (flip map [ 1 2 3 ] (n:
          {
            name = "eth${toString n}";
            value = {
              ip4 = [{ address = "192.168.${toString n}.1"; prefixLength = 24; }];
              ip6 = [{ address = "fd0${toString n}\:\:1"; prefixLength = 64; }];
            };
          }
        )));
      };
      networking.nat = {
        enable = true;
        externalInterface = "eth3";
        internalIPs = [ "192.168.1.0/24" ];
      };
      networking.myfirewall.enable = true;
      networking.myfirewall.allowPing = false;
      networking.myfirewall.rejectPackets = true;
      networking.myfirewall.logRefusedPackets = true;
      networking.myfirewall.extraPackages = [ pkgs.procps ];
      networking.myfirewall.extraCommands = ''
      sysctl net.ipv4.conf.all.forwarding=1
      sysctl net.ipv6.conf.all.forwarding=1
      '';
      networking.myfirewall.defaultPolicies = { input = "DROP"; forward = "DROP"; output = "ACCEPT"; };
      networking.myfirewall.rules = [
        { fromInterface = "eth0"; target = "ACCEPT"; }
        { fromInterface = "eth1"; protocol = "icmp"; target = "ACCEPT"; }
        { toInterface = "eth1"; target = "ACCEPT"; }
        { toInterface = "eth2"; target = "ACCEPT"; }
        { toInterface = "eth3"; target = "ACCEPT"; }
        { fromInterface = "lo"; target = "ACCEPT"; }
        {
          fromInterface = "eth1";
          toInterface = "eth2";
          protocol = "icmp";
          target = "ACCEPT";
        }
        { fromInterface = "eth1"; toInterface = "eth2"; target = "ACCEPT"; }
        {
          fromInterface = "eth2";
          toInterface = "eth1";
          destinationPort = "80";
          protocol = "tcp";
          target = "ACCEPT";
        }
        {
          fromInterface = "eth1";
          toInterface = "eth3";
          sourceAddr = "192.168.1.0/24";
          target = "ACCEPT";
        }
        {
          fromInterface = "eth3";
          toInterface = "eth+";
          protocol = "tcp";
          sourcePort = "1024:65535";
          target = "ACCEPT";
        }
        {
          fromInterface = "eth3";
          toInterface = "eth+";
          protocol = "icmp";
          target = "ACCEPT";
        }
        {
          fromInterface = "eth3";
          toInterface = "eth+";
          protocol = "icmpv6";
          target = "ACCEPT";
        }
      ];
    };

    site_a = { config, pkgs, ... }:
    {
      virtualisation.vlans = [ 1 ];
      imports = [ ./myfirewall.nix ];

      services.httpd.enable = true;
      services.httpd.adminAddr = "foo@example.org";
      networking.interfaces.eth1 = mkOverride 0 {
        ip4 = [{ address = "192.168.1.2"; prefixLength = 24;}];
        ip6 = [{ address = "fd01::2"; prefixLength = 64;}];
      };
      networking.defaultGateway = "192.168.1.1";
      networking.defaultGateway6 = "fd01::1";
      networking.myfirewall.enable = true;
      networking.myfirewall.rejectPackets = true;
      networking.myfirewall.logRefusedPackets = true;
      networking.myfirewall.defaultPolicies = {
        input = "ACCEPT"; output = "ACCEPT"; forward = "DROP";
      };
    };
    site_b = { config, pkgs, ... }:
    {
      virtualisation.vlans = [ 2 ];
      imports = [ ./myfirewall.nix ];

      services.httpd.enable = true;
      services.httpd.adminAddr = "foo@example.org";
      networking.interfaces.eth1 = mkOverride 0 {
        ip4 = [{ address = "192.168.2.2"; prefixLength = 24;}];
        ip6 = [{ address = "fd02::2"; prefixLength = 64;}];
      };
      networking.defaultGateway = "192.168.2.1";
      networking.defaultGateway6 = "fd02::1";
      networking.myfirewall.enable = true;
      networking.myfirewall.rejectPackets = true;
      networking.myfirewall.logRefusedPackets = true;
      networking.myfirewall.defaultPolicies = {
        input = "ACCEPT"; output = "ACCEPT"; forward = "DROP";
      };
    };
    site_c = { config, pkgs, ... }:
    {
      virtualisation.vlans = [ 3 ];
      imports = [ ./myfirewall.nix ];

      services.httpd.enable = true;
      services.httpd.adminAddr = "foo@example.org";
      networking.interfaces.eth1 = mkOverride 0 {
        ip4 = [{ address = "192.168.3.2"; prefixLength = 24;}];
        ip6 = [{ address = "fd03::2"; prefixLength = 64;}];
      };
      networking.defaultGateway = "192.168.3.1";
      networking.defaultGateway6 = "fd03::1";
      networking.myfirewall.enable = true;
      networking.myfirewall.rejectPackets = true;
      networking.myfirewall.logRefusedPackets = true;
      networking.myfirewall.defaultPolicies = {
        input = "ACCEPT"; output = "ACCEPT"; forward = "DROP";
      };
      networking.myfirewall.rules = [
        {
          sourceAddr = "192.168.1.0/24";
          fromInterface = "eth1";
          target = "REJECT";
        }
      ];
    };
  };

  testScript =
    { nodes, ... }:
    ''
      startAll;

      subtest "Wait for targets", sub {
        $router->waitForUnit("myfirewall");

        $site_a->waitForUnit("network.target");
        $site_b->waitForUnit("network.target");
        $site_c->waitForUnit("network.target");

        sleep 2;
      };

      subtest "check setup", sub {
        $router->execute("systemctl status -l -n 50 myfirewall >&2");
        $router->execute("ip -4 a >&2");
        $router->execute("ip -6 a >&2");
        $router->execute("ip -4 r >&2");
        $router->execute("ip -6 r >&2");

        $site_a->execute("ip -4 a >&2");
        $site_b->execute("ip -4 a >&2");
        $site_c->execute("ip -4 a >&2");
      };

      subtest "router can see everyone", sub {
        # Check that the router can see everyone
        $router->succeed(${pingcmd "192.168.1.2"});
        $router->succeed(${pingcmd "192.168.2.2"});
        $router->succeed(${pingcmd "192.168.3.2"});
        $router->succeed(${ping6cmd "fd01::2"});
        $router->succeed(${ping6cmd "fd02::2"});
        $router->succeed(${ping6cmd "fd03::2"});
      };

      subtest "site A can access site B native and site C via masquerading (ipv4)", sub {
        $site_a->succeed(${pingcmd "192.168.2.2"});
        $site_a->succeed("curl -q --fail --connect-timeout 1 192.168.2.2 >&2");
        $site_a->succeed(${pingcmd "192.168.3.2"});
        $site_a->succeed("curl -q --fail --connect-timeout 1 192.168.3.2 >&2");
        $site_a->succeed(${ping6cmd "fd02::2"});
        $site_a->succeed("curl -q --fail --connect-timeout 1 [fd02::2] >&2");
        $site_a->fail(${ping6cmd "fd03::2"});
        $site_a->fail("curl -q --fail --connect-timeout 1 [fd03::2] >&2");
      };
      subtest "site B can access site A port 80 (no ping) but not site C", sub {
        $site_b->fail(${pingcmd "192.168.1.2"});
        $site_b->succeed("curl -q --fail --connect-timeout 1 192.168.1.2 >&2");
        $site_b->fail(${pingcmd "192.168.3.2"});
        $site_b->fail("curl -q --fail --connect-timeout 1 192.168.3.2 >&2");
        $site_b->fail(${ping6cmd "fd01::2"});
        $site_b->succeed("curl -q --fail --connect-timeout 1 [fd01::2] >&2");
        $site_b->fail(${ping6cmd "fd03::2"});
        $site_b->fail("curl -q --fail --connect-timeout 1 [fd03::2] >&2");
      };
      subtest "site C can access site A and site B", sub {
        $site_c->succeed(${pingcmd "192.168.1.2"});
        $site_c->succeed("curl -q --fail --connect-timeout 1 192.168.1.2 >&2");
        $site_c->succeed(${pingcmd "192.168.2.2"});
        $site_c->succeed("curl -q --fail --connect-timeout 1 192.168.2.2 >&2");
        $site_c->succeed(${ping6cmd "fd01::2"});
        $site_c->succeed("curl -q --fail --connect-timeout 1 [fd01::2] >&2");
        $site_c->succeed(${ping6cmd "fd02::2"});
        $site_c->succeed("curl -q --fail --connect-timeout 1 [fd02::2] >&2");
      };

      subtest "iptables debug", sub {
        # Output rules for debugging
        $router->execute("iptables -L -nv >&2");
        $router->execute("iptables -t nat -L -nv >&2");
        $router->execute("ip6tables -L -nv >&2");
        $router->execute("ip6tables -t nat -L -nv >&2");
        $site_a->execute("iptables -L -nv >&2");
        $site_a->execute("ip6tables -L -nv >&2");
      };

      subtest "reload myfirewall", sub {
        $router->succeed("systemctl reload myfirewall.service >&2");
        $router->waitForUnit("myfirewall");
        $site_a->succeed(${pingcmd "192.168.2.2"});
        $site_a->succeed(${ping6cmd "fd02::2"});
      };
    '';
})
