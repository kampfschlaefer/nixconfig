{ lib, pkgs, ... }:

let

  python = import ./requirements.nix { inherit pkgs; };

in python.mkDerivation rec {
  name = "dash_button-${version}";
  version = "2";

  # src = ./.;
  src = builtins.filterSource (p: t: lib.cleanSourceFilter p t && baseNameOf p != "dash_button.egg-info") ./.;

  propagatedBuildInputs = [ python.packages."scapy" python.packages."paho-mqtt" ];

  doCheck = false;
}