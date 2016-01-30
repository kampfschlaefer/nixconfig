{ config, pkgs, ... }:

{
  services.postfix = {
    enable = true;
    domain = "arnoldarts.de";
    hostname = "portal.arnoldarts.de";
    networksStyle = "subnet";
    relayHost = "starbase.arnoldarts.de";
    rootAlias = "arnold@starbase.arnoldarts.de";
  };

  environment.systemPackages = [ pkgs.mailutils ];
}
