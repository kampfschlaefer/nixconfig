{ stdenv ? null, fetchurl ? null, ... }:

let
  pkgs = import ../../../nixpkgs {};
  mystdenv = if stdenv != null then stdenv else pkgs.stdenv;
  myfetchurl = if fetchurl != null then fetchurl else pkgs.fetchurl;

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
/*mystdenv.mkDerivation rec {
  name = "mqtt_client-${version}";
  version = "1";
  src = ./.;

  propagatedBuildInputs = [ pkgs.python35Packages.paho-mqtt ];
  configurePhase = null;

}*/
