{ config, lib, pkgs, ... }:

with lib;

let
in {
  power.ups = {
    enable = false; # TODO: Switch to true

    ups = {
      eaton = {
        description = "Eaton for server(s) and internet";
        driver = "usbhid-ups";
        port = "auto";
      };
    };
  };
}