{ }:

let
  pkgs = import ../../../nixpkgs {};
  python = import ./requirements.nix { inherit pkgs; };
in python.mkDerivation {
  name = "pyheim-0.1.0";
  src = pkgs.fetchgit {
    name = "pyheim-master";
    url = "git://gitolite/pyheim.git";
    rev = "7e4c5bbd39402fae8faf9de2373c1d1a367a4e7e";
    sha256 = "077yq9pkhi6ig7qcy3r73x6qnhj88bll5l7khrmx58h106slrzba";
  };
  buildInputs = [ pkgs.openssh ];
  propagatedBuildInputs = [
    python.packages."configparser"
    python.packages."future"
    python.packages."phue"
  ];
}
