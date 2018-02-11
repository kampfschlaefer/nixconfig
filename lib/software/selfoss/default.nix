{ pkgs, stdenv ? null, fetchurl ? null, ... }:

let
  mystdenv = if stdenv != null then stdenv else pkgs.stdenv;
  myfetchurl = if fetchurl != null then fetchurl else pkgs.fetchurl;

in
mystdenv.mkDerivation rec {
  name = "selfoss-${version}";
  version = "2.15";
  src = myfetchurl {
    url = "https://github.com/SSilence/selfoss/archive/2.15.tar.gz";
    sha256 = "0ypqrv0ypjm79jzs6dpqgw5zzs2jfcg76yjy1wfqxhffsp04njcl";
  };

  configurePhase = null;

  buildPhase = ''
    rm -f *.zip .git*
  '';

  installPhase = ''
    mkdir -p $out

    cp -R . $out
  '';
}
