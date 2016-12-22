{ stdenv ? null, fetchurl ? null, ... }:

let
  pkgs = import ../../../nixpkgs {};
in

with pkgs.python35Packages;

buildPythonApplication rec {
  name = "mqtt_client-${version}";
  version = "1";

  src = ./.;

  propagatedBuildInputs = [ paho-mqtt ];

  doCheck = false;

  buildPhase = ''
    test -f mqtt_client.py
  '';

  installPhase = ''
    install -D -m 0755 mqtt_client.py $out/bin/mqtt_client
  '';
}
