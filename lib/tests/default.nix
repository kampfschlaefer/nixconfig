{ stdenv, bats }:

stdenv.mkDerivation rec {
  name = "testgitolite";

  src = ./.;

  buildInputs = [ bats ];
  configurePhase = false;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    install -m 0755 test_gitolite.sh $out/bin/test_gitolite
    substituteAllInPlace $out/bin/test_gitolite

    mkdir -p $out/data
    install -m 0600 data/*_key* $out/data
  '';
}