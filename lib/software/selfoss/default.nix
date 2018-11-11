{ stdenv, fetchurl, unzip, ... }:

let
in
stdenv.mkDerivation rec {
  name = "selfoss-${version}";
  version = "2.18";
  src = fetchurl {
    url = "https://github.com/SSilence/selfoss/releases/download/2.18/selfoss-2.18.zip";
    sha256 = "1vd699r1kjc34n8avggckx2b0daj5rmgrj997sggjw2inaq4cg8b";
  };

  configurePhase = null;

  unpackPhase = ''
    ${unzip}/bin/unzip ${src} -d ${name}
  '';

  buildPhase = ''
    rm -f *.zip .git*
  '';

  installPhase = ''
    mkdir -p $out

    cp -R ${name}/* $out
  '';
}
