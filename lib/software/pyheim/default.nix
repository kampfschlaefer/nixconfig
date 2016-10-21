{ }:

let
  pkgs = import ../../../nixpkgs {};
  python = import ./requirements.nix { inherit pkgs; };
in python.mkDerivation {
  name = "pyheim-0.1.0";
  src = pkgs.fetchgit {
    name = "pyheim-master";
    url = "git://gitolite/pyheim.git";
    rev = "84b1c16f7523f65fcf9bf13d349d47dc61a33300";
    sha256 = "0ma7nvy9r70a39lwq75rxqijlcaflz8kas9ffzlr1bz3qnda2cz1";
  };
  buildInputs = [ pkgs.openssh ];
  propagatedBuildInputs = [
    python.packages."configparser"
    python.packages."future"
    python.packages."phue"
  ];
}