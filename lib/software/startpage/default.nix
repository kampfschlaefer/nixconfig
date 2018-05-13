{stdenv}:

stdenv.mkDerivation {
  name = "startpage-0.1";
  src = ./data;

  configurePhase = null;

  buildPhase = "";

  installPhase = ''
    mkdir $out
    cp *.css $out
    cp *.html $out
  '';
}