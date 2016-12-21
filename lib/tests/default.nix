{ stdenv, bats, curl, git, jq, bishbosh, mqtt_client }:

let
  install_script = script: ''
    install -m 0755 ${script}.bats $out/bin/${script}
    substituteAllInPlace $out/bin/${script}
  '';
in
stdenv.mkDerivation rec {
  name = "testgitolite";

  src = ./.;

  inherit jq;
  inherit curl;
  inherit git;
  inherit bats;
  inherit bishbosh;
  inherit mqtt_client;

  configurePhase = false;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin

    install -m 0755 mqtt_client.bishbosh $out/bin/mqtt_client.bishbosh
    substituteAllInPlace $out/bin/mqtt_client.bishbosh

    install -m 0755 test_gitolite.sh $out/bin/test_gitolite
    substituteAllInPlace $out/bin/test_gitolite

    ${install_script "test_selfoss"}
    ${install_script "test_mqtt"}

    mkdir -p $out/data
    install -m 0600 data/*_key* $out/data
  '';
}