/* This module enables a simple firewall.

   The firewall can be customised in arbitrary ways by setting
   ‘networking.myfirewall.extraCommands’.  For modularity, the firewall
   uses several chains:

   - ‘nixos-myfw-input’ is the main chain for input packet processing.

   - ‘nixos-myfw-log-refuse’ and ‘nixos-myfw-refuse’ are called for
     refused packets.  (The former jumps to the latter after logging
     the packet.)  If you want additional logging, or want to accept
     certain packets anyway, you can insert rules at the start of
     these chain.

   - ‘nixos-myfw-accept’ is called for accepted packets.  If you want
     additional logging, or want to reject certain packets anyway, you
     can insert rules at the start of this chain.

*/

{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.networking.myfirewall;

  targetChains = {
    ACCEPT = "nixos-myfw-accept";
    DROP = "nixos-myfw-refuse";
    REJECT = "nixos-myfw-log-refuse";
  };

  helpers =
    ''
      # Helper command to manipulate both the IPv4 and IPv6 tables.
      ip46tables() {
        iptables -w "$@"
        ${optionalString config.networking.enableIPv6 ''
          ip6tables -w "$@"
        ''}
      }
    '';

  getTargetForPolicy = policy:
    if policy == "ACCEPT"
    then "nixos-myfw-accept"
    else "nixos-myfw-refuse";

  prependStringIfNotNull = prefix: string:
    if string != null
    then "${prefix}${string}"
    else "";

  writeShScript = name: text: let dir = pkgs.writeScriptBin name ''
    #! ${pkgs.stdenv.shell} -e
    ${text}
  ''; in "${dir}/bin/${name}";

  startScript = writeShScript "firewall-start" ''
    ${helpers}

    # Flush the old firewall rules.  !!! Ideally, updating the
    # firewall would be atomic.  Apparently that's possible
    # with iptables-restore.
    ip46tables -D INPUT -j nixos-myfw-input 2> /dev/null || true
    ip46tables -D OUTPUT -j nixos-myfw-output 2> /dev/null || true
    ip46tables -D FORWARD -j nixos-myfw-forward 2> /dev/null || true
    for chain in nixos-myfw nixos-myfw-input nixos-myfw-output nixos-myfw-forward nixos-myfw-accept nixos-myfw-log-refuse nixos-myfw-refuse __invalid_chain__ FW_REFUSE; do
      ip46tables -F "$chain" 2> /dev/null || true
      ip46tables -X "$chain" 2> /dev/null || true
    done

    # Set default policies
    ip46tables -P INPUT ${cfg.defaultPolicies.input}
    ip46tables -P OUTPUT ${cfg.defaultPolicies.output}
    ip46tables -P FORWARD ${cfg.defaultPolicies.forward}

    # The "nixos-myfw-accept" chain just accepts packets.
    ip46tables -N nixos-myfw-accept
    ip46tables -A nixos-myfw-accept -j ACCEPT


    # The "nixos-myfw-refuse" chain rejects or drops packets.
    ip46tables -N nixos-myfw-refuse

    ${if cfg.rejectPackets then ''
      # Send a reset for existing TCP connections that we've
      # somehow forgotten about.  Send ICMP "port unreachable"
      # for everything else.
      ip46tables -A nixos-myfw-refuse -p tcp ! --syn -j REJECT --reject-with tcp-reset
      ip46tables -A nixos-myfw-refuse -j REJECT
    '' else ''
      ip46tables -A nixos-myfw-refuse -j DROP
    ''}

    # The "nixos-myfw-log-refuse" chain performs logging, then
    # jumps to the "nixos-myfw-refuse" chain.
    ip46tables -N nixos-myfw-log-refuse

    ${optionalString cfg.logRefusedConnections ''
      ip46tables -A nixos-myfw-log-refuse -p tcp --syn -j LOG --log-level info --log-prefix "rejected connection: "
    ''}
    ${optionalString (cfg.logRefusedPackets && !cfg.logRefusedUnicastsOnly) ''
      ip46tables -A nixos-myfw-log-refuse -m pkttype --pkt-type broadcast \
        -j LOG --log-level info --log-prefix "rejected broadcast: "
      ip46tables -A nixos-myfw-log-refuse -m pkttype --pkt-type multicast \
        -j LOG --log-level info --log-prefix "rejected multicast: "
    ''}
    ip46tables -A nixos-myfw-log-refuse -m pkttype ! --pkt-type unicast -j nixos-myfw-refuse
    ${optionalString cfg.logRefusedPackets ''
      ip46tables -A nixos-myfw-log-refuse \
        -j LOG --log-level info --log-prefix "rejected packet: "
    ''}
    ip46tables -A nixos-myfw-log-refuse -j nixos-myfw-refuse


    # Perform a reverse-path test to refuse spoofers
    # For now, we just drop, as the raw table doesn't have a log-refuse yet
    ${optionalString (kernelHasRPFilter && cfg.checkReversePath) ''
      # Clean up rpfilter rules
      ip46tables -t raw -D PREROUTING -j nixos-myfw-rpfilter 2> /dev/null || true
      ip46tables -t raw -F nixos-myfw-rpfilter 2> /dev/null || true
      ip46tables -t raw -N nixos-myfw-rpfilter 2> /dev/null || true

      ip46tables -t raw -A nixos-myfw-rpfilter -m rpfilter -j RETURN

      # Allows this host to act as a DHCPv4 server
      iptables -t raw -A nixos-myfw-rpfilter -s 0.0.0.0 -d 255.255.255.255 -p udp --sport 68 --dport 67 -j RETURN

      ${optionalString cfg.logReversePathDrops ''
        ip46tables -t raw -A nixos-myfw-rpfilter -j LOG --log-level info --log-prefix "rpfilter drop: "
      ''}
      ip46tables -t raw -A nixos-myfw-rpfilter -j DROP

      ip46tables -t raw -A PREROUTING -j nixos-myfw-rpfilter
    ''}

    # The "nixos-myfw-[input|output|forward]" chains do the actual work.
    ip46tables -N nixos-myfw-input
    ip46tables -N nixos-myfw-output
    ip46tables -N nixos-myfw-forward

    ip46tables -N __invalid_chain__

    # Accept packets from established or related connections.
    ip46tables -A nixos-myfw-input -m conntrack --ctstate ESTABLISHED,RELATED -j nixos-myfw-accept
    ip46tables -A nixos-myfw-forward -m conntrack --ctstate ESTABLISHED,RELATED -j nixos-myfw-accept
    ip46tables -A nixos-myfw-output -m conntrack --ctstate ESTABLISHED,RELATED -j nixos-myfw-accept

    # Put the rules into their respective chains.
    ${concatMapStrings (rule:
        let
          ipversions = if
              rule.ipv6Only ||
              rule.protocol == "icmpv6" ||
              (
                if rule.sourceAddr != null
                then elem ":" (stringToCharacters rule.sourceAddr)
                else false
              ) || (
                if rule.destinationAddr != null
                then elem ":" (stringToCharacters rule.destinationAddr)
                else false
              )
            then
              ["ipv6"]
            else
              if
                rule.ipv4Only ||
                rule.protocol == "icmp" ||
                (
                  if rule.sourceAddr != null
                  then elem "." (stringToCharacters rule.sourceAddr)
                  else false
                ) || (
                  if rule.destinationAddr != null
                  then elem "." (stringToCharacters rule.destinationAddr)
                  else false
                )
              then
                ["ipv4"]
              else
                ["ipv4" "ipv6"];
          chain = if
              rule.fromInterface != null && rule.toInterface != null
            then
              "nixos-myfw-forward"
            else
              if
                rule.fromInterface != null && rule.toInterface == null
              then
                "nixos-myfw-input"
              else
                if
                  rule.fromInterface == null && rule.toInterface != null
                then
                  "nixos-myfw-output"
                else "__invalid_chain__";
          target = getAttr rule.target targetChains;
          ifacein = prependStringIfNotNull "-i " rule.fromInterface;
          ifaceout = prependStringIfNotNull "-o " rule.toInterface;
          srcaddr = prependStringIfNotNull "-s " rule.sourceAddr;
          destaddr = prependStringIfNotNull "-d " rule.destinationAddr;
          sourceport = if
              elem rule.protocol [ "tcp" "udp" "dccp" "sctp" ]
            then prependStringIfNotNull "--sport " rule.sourcePort
            else "";
          destinationport = if
              elem rule.protocol [ "tcp" "udp" "dccp" "sctp" ]
            then prependStringIfNotNull "--dport " rule.destinationPort
            else "";
        in
        ''
          ${optionalString (elem "ipv4" ipversions) ''
            iptables -A ${chain} -p ${rule.protocol} \
              ${ifacein} ${ifaceout} \
              ${srcaddr} ${destaddr} \
              ${sourceport} ${destinationport} \
              -j ${target}
          ''}
          ${optionalString (elem "ipv6" ipversions) ''
            ip6tables -A ${chain} -p ${rule.protocol} \
              ${ifacein} ${ifaceout} \
              ${srcaddr} ${destaddr} \
              ${sourceport} ${destinationport} \
              -j ${target}
          ''}
        ''
      ) cfg.rules
    }

    # Accept all traffic on the trusted interfaces.
    ${flip concatMapStrings cfg.trustedInterfaces (iface: ''
      ip46tables -A nixos-myfw-input -i ${iface} -j nixos-myfw-accept
    '')}

    # Accept connections to the allowed TCP ports.
    ${concatMapStrings (port:
        ''
          ip46tables -A nixos-myfw-input -p tcp --dport ${toString port} -j nixos-myfw-accept
        ''
      ) cfg.allowedTCPPorts
    }

    # Accept connections to the allowed TCP port ranges.
    ${concatMapStrings (rangeAttr:
        let range = toString rangeAttr.from + ":" + toString rangeAttr.to; in
        ''
          ip46tables -A nixos-myfw-input -p tcp --dport ${range} -j nixos-myfw-accept
        ''
      ) cfg.allowedTCPPortRanges
    }

    # Accept packets on the allowed UDP ports.
    ${concatMapStrings (port:
        ''
          ip46tables -A nixos-myfw-input -p udp --dport ${toString port} -j nixos-myfw-accept
        ''
      ) cfg.allowedUDPPorts
    }

    # Accept packets on the allowed UDP port ranges.
    ${concatMapStrings (rangeAttr:
        let range = toString rangeAttr.from + ":" + toString rangeAttr.to; in
        ''
          ip46tables -A nixos-myfw-input -p udp --dport ${range} -j nixos-myfw-accept
        ''
      ) cfg.allowedUDPPortRanges
    }

    # Accept IPv4 multicast.  Not a big security risk since
    # probably nobody is listening anyway.
    #iptables -A nixos-myfw-input -d 224.0.0.0/4 -j nixos-myfw-accept

    # Optionally respond to ICMPv4 pings.
    ${optionalString cfg.allowPing ''
      iptables -w -A nixos-myfw-input -p icmp --icmp-type echo-request ${optionalString (cfg.pingLimit != null)
        "-m limit ${cfg.pingLimit} "
      }-j nixos-myfw-accept
    ''}

    # Accept all ICMPv6 messages except redirects and node
    # information queries (type 139).  See RFC 4890, section
    # 4.4.
    ${optionalString config.networking.enableIPv6 ''
      ip6tables -A nixos-myfw-input -p icmpv6 --icmpv6-type redirect -j DROP
      ip6tables -A nixos-myfw-input -p icmpv6 --icmpv6-type 139 -j DROP
      ip6tables -A nixos-myfw-input -p icmpv6 -j nixos-myfw-accept
    ''}

    ${cfg.extraCommands}

    # Reject/drop everything else depending on the default policies.
    ip46tables -A nixos-myfw-input -j ${getTargetForPolicy cfg.defaultPolicies.input}
    ip46tables -A nixos-myfw-output -j ${getTargetForPolicy cfg.defaultPolicies.output}
    ip46tables -A nixos-myfw-forward -j ${getTargetForPolicy cfg.defaultPolicies.forward}


    # Enable the firewall.
    ip46tables -A INPUT -j nixos-myfw-input
    ip46tables -A OUTPUT -j nixos-myfw-output
    ip46tables -A FORWARD -j nixos-myfw-forward
  '';

  stopScript = writeShScript "firewall-stop" ''
    ${helpers}

    # Clean up in case reload fails
    ip46tables -D INPUT -j nixos-drop 2>/dev/null || true

    # Clean up after added ruleset
    ip46tables -D INPUT -j nixos-myfw-input 2>/dev/null || true
    ip46tables -D OUTPUT -j nixos-myfw-output 2>/dev/null || true
    ip46tables -D FORWARD -j nixos-myfw-forward 2>/dev/null || true

    # Open up the firewall by the default policies
    ip46tables -P INPUT ACCEPT
    ip46tables -P OUTPUT ACCEPT
    ip46tables -P FORWARD ACCEPT

    ${optionalString (kernelHasRPFilter && cfg.checkReversePath) ''
      ip46tables -t raw -D PREROUTING -j nixos-myfw-rpfilter 2>/dev/null || true
    ''}

    ${cfg.extraStopCommands}
  '';

  reloadScript = writeShScript "firewall-reload" ''
    ${helpers}

    # Create a unique drop rule
    ip46tables -D INPUT -j nixos-drop 2>/dev/null || true
    ip46tables -F nixos-drop 2>/dev/null || true
    ip46tables -X nixos-drop 2>/dev/null || true
    ip46tables -N nixos-drop
    ip46tables -A nixos-drop -j DROP

    # Don't allow traffic to leak out until the script has completed
    ip46tables -A INPUT -j nixos-drop
    if ${startScript}; then
      ip46tables -D INPUT -j nixos-drop 2>/dev/null || true
    else
      echo "Failed to reload firewall... Stopping"
      ${stopScript}
      exit 1
    fi
  '';

  kernelPackages = config.boot.kernelPackages;

  kernelHasRPFilter = kernelPackages.kernel.features.netfilterRPFilter or false;
  kernelCanDisableHelpers = kernelPackages.kernel.features.canDisableNetfilterConntrackHelpers or false;

in

{

  ###### interface

  options = {

    networking.myfirewall.enable = mkOption {
      type = types.bool;
      default = true;
      description =
        ''
          Whether to enable the firewall.  This is a simple stateful
          firewall that blocks connection attempts to unauthorised TCP
          or UDP ports on this machine.  It does not affect packet
          forwarding.
        '';
    };

    networking.myfirewall.logRefusedConnections = mkOption {
      type = types.bool;
      default = true;
      description =
        ''
          Whether to log rejected or dropped incoming connections.
        '';
    };

    networking.myfirewall.logRefusedPackets = mkOption {
      type = types.bool;
      default = false;
      description =
        ''
          Whether to log all rejected or dropped incoming packets.
          This tends to give a lot of log messages, so it's mostly
          useful for debugging.
        '';
    };

    networking.myfirewall.logRefusedUnicastsOnly = mkOption {
      type = types.bool;
      default = true;
      description =
        ''
          If <option>networking.myfirewall.logRefusedPackets</option>
          and this option are enabled, then only log packets
          specifically directed at this machine, i.e., not broadcasts
          or multicasts.
        '';
    };

    networking.myfirewall.rejectPackets = mkOption {
      type = types.bool;
      default = false;
      description =
        ''
          If set, forbidden packets are rejected rather than dropped
          (ignored).  This means that an ICMP "port unreachable" error
          message is sent back to the client.  Rejecting packets makes
          port scanning somewhat easier.
        '';
    };

    networking.myfirewall.trustedInterfaces = mkOption {
      type = types.listOf types.str;
      description =
        ''
          Traffic coming in from these interfaces will be accepted
          unconditionally.
        '';
    };

    networking.myfirewall.allowedTCPPorts = mkOption {
      default = [];
      example = [ 22 80 ];
      type = types.listOf types.int;
      description =
        ''
          List of TCP ports on which incoming connections are
          accepted.
        '';
    };

    networking.myfirewall.allowedTCPPortRanges = mkOption {
      default = [];
      example = [ { from = 8999; to = 9003; } ];
      type = types.listOf (types.attrsOf types.int);
      description =
        ''
          A range of TCP ports on which incoming connections are
          accepted.
        '';
    };

    networking.myfirewall.allowedUDPPorts = mkOption {
      default = [];
      example = [ 53 ];
      type = types.listOf types.int;
      description =
        ''
          List of open UDP ports.
        '';
    };

    networking.myfirewall.allowedUDPPortRanges = mkOption {
      default = [];
      example = [ { from = 60000; to = 61000; } ];
      type = types.listOf (types.attrsOf types.int);
      description =
        ''
          Range of open UDP ports.
        '';
    };

    networking.myfirewall.defaultPolicies = mkOption {
      default = { input = "DROP"; output = "ACCEPT"; forward = "DROP"; };
      example = { input = "ACCEPT"; output = "DROP"; forward = "ACCEPT"; };
      type = types.attrsOf types.str;
      description =
        ''
          Set the default policies of the main filter chains
        '';
    };

    networking.myfirewall.rules = mkOption {
      default = [];
      example = [];
      type = types.listOf types.optionSet;
      description = ''
        Rules for the iptables firewall.
      '';
      options = {
        ipv4Only = mkOption {
          default = false;
          type = types.bool;
          description = ''
            Force this rule to apply to ipv4 tables only.
            Otherwise its decided upon the ipaddress and its format if it
            applies to ipv6 or not.
          '';
        };
        ipv6Only = mkOption {
          default = false;
          type = types.bool;
          description = ''
            Force this rule to apply to ipv6 tables only.
            Otherwise its decided upon the ipaddress and its format if it
            applies to ipv4 or not.
          '';
        };

        sourceAddr = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
          '';
        };
        destinationAddr = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
          '';
        };

        sourcePort = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "10000:15000";
          description = ''
            A port or portrange (as string) for the --sport option of iptables.
            TODO: Validate this on protocol in ["tcp" "udp"]
          '';
        };
        destinationPort = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "80:443";
          description = ''
            A port or portrange (as string) for the --dport option of iptables.
            TODO: Validate this on protocol in ["tcp" "udp"]
          '';
        };

        fromInterface = mkOption {
          default = null;
          type = types.nullOr types.str;
          description = ''
            Source interface to match on.
            Value is the name of the interface, optionally prefixed with ! to
            match everything _except_ that interface.
            Wildcards are allowed: eth+ matches all eth-something interfaces.
            Special value nil equals all interfaces.
          '';
        };
        toInterface = mkOption {
          default = null;
          type = types.nullOr types.str;
          description = ''
            Source interface to match on.
            Value is the name of the interface, optionally prefixed with ! to
            match everything _except_ that interface.
            Wildcards are allowed: eth+ matches all eth-something interfaces.
            Special value nil equals all interfaces.
          '';
        };
        target = mkOption {
          default = null;
          type = types.nullOr (
            types.addCheck types.str (
              v: v == "ACCEPT" || v == "DROP" || v == "REJECT"
            )
          );
          description = ''
            What to do with the data. Allowed values: ACCEPT, REJECT and DROP.
          '';
        };
        protocol = mkOption {
          default = "all";
          type = types.addCheck types.str (
            v: elem v [ "tcp" "udp" "udplite" "icmp" "icmpv6" "esp" "ah" "sctp" "mh" "all" ]
          );
          description = ''
            Protocols to filter on. One of tcp, udp, udplite, icmp, icmpv6, esp, ah, sctp, mh and all, which matches all protocols.
            Not to be mixed up with the port(s).
          '';
        };
      };
    };

    networking.myfirewall.allowPing = mkOption {
      default = true;
      type = types.bool;
      description =
        ''
          Whether to respond to incoming ICMPv4 echo requests
          ("pings").  ICMPv6 pings are always allowed because the
          larger address space of IPv6 makes network scanning much
          less effective.
        '';
    };

    networking.myfirewall.pingLimit = mkOption {
      default = null;
      type = types.nullOr (types.separatedString " ");
      description =
        ''
          If pings are allowed, this allows setting rate limits
          on them. If non-null, this option should be in the form
          of flags like "--limit 1/minute --limit-burst 5"
        '';
    };

    networking.myfirewall.checkReversePath = mkOption {
      default = kernelHasRPFilter;
      type = types.bool;
      description =
        ''
          Performs a reverse path filter test on a packet.
          If a reply to the packet would not be sent via the same interface
          that the packet arrived on, it is refused.

          If using asymmetric routing or other complicated routing,
          disable this setting and setup your own counter-measures.

          (needs kernel 3.3+)
        '';
    };

    networking.myfirewall.logReversePathDrops = mkOption {
      default = false;
      type = types.bool;
      description =
        ''
          Logs dropped packets failing the reverse path filter test if
          the option networking.myfirewall.checkReversePath is enabled.
        '';
    };

    networking.myfirewall.connectionTrackingModules = mkOption {
      default = [ "ftp" ];
      example = [ "ftp" "irc" "sane" "sip" "tftp" "amanda" "h323" "netbios_sn" "pptp" "snmp" ];
      type = types.listOf types.str;
      description =
        ''
          List of connection-tracking helpers that are auto-loaded.
          The complete list of possible values is given in the example.

          As helpers can pose as a security risk, it is advised to
          set this to an empty list and disable the setting
          networking.myfirewall.autoLoadConntrackHelpers

          Loading of helpers is recommended to be done through the new
          CT target. More info:
          https://home.regit.org/netfilter-en/secure-use-of-helpers/
        '';
    };

    networking.myfirewall.autoLoadConntrackHelpers = mkOption {
      default = true;
      type = types.bool;
      description =
        ''
          Whether to auto-load connection-tracking helpers.
          See the description at networking.myfirewall.connectionTrackingModules

          (needs kernel 3.5+)
        '';
    };

    networking.myfirewall.extraCommands = mkOption {
      type = types.lines;
      default = "";
      example = "iptables -A INPUT -p icmp -j ACCEPT";
      description =
        ''
          Additional shell commands executed as part of the firewall
          initialisation script.  These are executed just before the
          final "reject" firewall rule is added, so they can be used
          to allow packets that would otherwise be refused.
        '';
    };

    networking.myfirewall.extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      example = literalExample "[ pkgs.ipset ]";
      description =
        ''
          Additional packages to be included in the environment of the system
          as well as the path of networking.myfirewall.extraCommands.
        '';
    };

    networking.myfirewall.extraStopCommands = mkOption {
      type = types.lines;
      default = "";
      example = "iptables -P INPUT ACCEPT";
      description =
        ''
          Additional shell commands executed as part of the firewall
          shutdown script.  These are executed just after the removal
          of the nixos input rule, or if the service enters a failed state.
        '';
    };

  };


  ###### implementation

  # FIXME: Maybe if `enable' is false, the firewall should still be
  # built but not started by default?
  config = mkIf cfg.enable {

    networking.firewall.enable = false;

    networking.myfirewall.trustedInterfaces = [ "lo" ];

    environment.systemPackages = [ pkgs.iptables ] ++ cfg.extraPackages;

    boot.kernelModules = map (x: "nf_conntrack_${x}") cfg.connectionTrackingModules;
    boot.extraModprobeConfig = optionalString (!cfg.autoLoadConntrackHelpers) ''
      options nf_conntrack nf_conntrack_helper=0
    '';

    assertions = [ { assertion = ! cfg.checkReversePath || kernelHasRPFilter;
                     message = "This kernel does not support rpfilter"; }
                   { assertion = cfg.autoLoadConntrackHelpers || kernelCanDisableHelpers;
                     message = "This kernel does not support disabling conntrack helpers"; }
                 ];

    systemd.services.myfirewall = {
      description = "Firewall";
      wantedBy = [ "multi-user.target" "sysinit.target" ];
      wants = [ "network-pre.target" ];
      before = [ "network-pre.target" ];
      after = [ "systemd-modules-load.service" ];

      path = [ pkgs.iptables ] ++ cfg.extraPackages;

      # FIXME: this module may also try to load kernel modules, but
      # containers don't have CAP_SYS_MODULE. So the host system had
      # better have all necessary modules already loaded.
      unitConfig.ConditionCapability = "CAP_NET_ADMIN";

      reloadIfChanged = true;

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "@${startScript} firewall-start";
        ExecReload = "@${reloadScript} firewall-reload";
        ExecStop = "@${stopScript} firewall-stop";
      };
    };

  };

}
