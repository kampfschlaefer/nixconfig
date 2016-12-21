{ stdenv, bats, curl, git, jq, mqtt_client }:

let
  install_script = script: ''
    install -D -m 0755 ${script}.bats $out/bin/${script}
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
  inherit mqtt_client;

  configurePhase = false;
  dontBuild = true;

  installPhase = ''
    install -D -m 0755 test_gitolite.sh $out/bin/test_gitolite
    substituteAllInPlace $out/bin/test_gitolite

    ${install_script "test_selfoss"}
    ${install_script "test_mqtt"}

    mkdir -p $out/data
    install -D -m 0600 data/*_key* $out/data
  '';
}