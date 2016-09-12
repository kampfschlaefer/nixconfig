{ }:

let
  pkgs = import ../../../nixpkgs {};
  python = import ./requirements.nix { inherit pkgs; };
in python.mkDerivation {
  name = "pyheim-0.1.0";
  src = pkgs.fetchgit {
    name = "pyheim-master";
    url = "git://gitolite/pyheim.git";
    rev = "e40fc8593c864c68b8c319da96efcbbcdb7a038e";
    sha256 = "0dijp85mnfwl9x7q0l2ajbav8zq1759qix7wq7z2viv8a0zr7f4b";
  };
  buildInputs = [ pkgs.openssh ];
  propagatedBuildInputs = [
    python.packages."configparser"
    python.packages."future"
    python.packages."phue"
  ];
}