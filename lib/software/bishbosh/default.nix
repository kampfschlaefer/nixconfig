{ stdenv ? null, fetchurl ? null, ... }:

let
  pkgs = import ../../../nixpkgs {};
  mystdenv = if stdenv != null then stdenv else pkgs.stdenv;
  myfetchurl = if fetchurl != null then fetchurl else pkgs.fetchurl;

in
mystdenv.mkDerivation rec {
  name = "bishbosh-${version}";
  version = "2015.0629.0920";
  src = myfetchurl {
    url = "https://github.com/raphaelcohn/bish-bosh/releases/download/release_2015.0629.0920-4/bish-bosh_2015.0629.0920-2_all.tar.gz";
    sha256 = "007ydcr1b5acbmcljmlzj2vd3c2hy5rxwfv7kl3hdwmlvjg2q4jj";
  };

  configurePhase = null;

  buildPhase = ''
    test -f usr/bin/bish-bosh
    test -d usr/share
    #ls -la
    #ls -la usr/
    #ls -la usr/bin
    #ls -la usr/share
  '';

  installPhase = ''
    mkdir -p $out

    cp -R usr/bin $out
    cp -R usr/share $out
  '';
}
