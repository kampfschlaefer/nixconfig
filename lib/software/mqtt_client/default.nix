{ pkgs }:

let

  python = import ./requirements.nix { inherit pkgs; };

in python.mkDerivation rec {
  name = "mqtt_client-${version}";
  version = "1";

  src = ./.;

  propagatedBuildInputs = [ python.packages."paho-mqtt" ];

  doCheck = false;

  buildPhase = ''
    test -f mqtt_client.py
  '';

  installPhase = ''
    install -D -m 0755 mqtt_client.py $out/bin/mqtt_client
  '';
}
