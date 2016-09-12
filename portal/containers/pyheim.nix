{ config, lib, pkgs, ... }:

let
  pyheimpkg = pkgs.callPackage ../../lib/software/pyheim {};
in
{
  containers.pyheim = {
    autoStart = lib.mkOverride 100 true;

    privateNetwork = true;
    hostBridge = "lan";
    localAddress = "192.168.1.226/24";
    localAddress6 = "2001:470:1f0b:1033::7079:6865:696d/64";

    config = { config, pkgs, ... }: {

      networking.domain = "arnoldarts.de";
      networking.firewall.enable = false;

      services.openssh = {
        enable = true;
        allowSFTP = true;
        startWhenNeeded = true;
      };

      environment.systemPackages = [ pyheimpkg ];

    };
  };
}
