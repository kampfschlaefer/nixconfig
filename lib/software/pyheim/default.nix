{ }:

let
  pkgs = import ../../../nixpkgs {};
  python = import ./requirements.nix { inherit pkgs; };
in python.mkDerivation {
  name = "pyheim-0.1.0";
  src = pkgs.fetchgit {
    name = "pyheim-master";
    url = "git://gitolite/pyheim.git";
    rev = "7aa70cd999d2ea2018454ea4b5ec3bf7f1364371";
    sha256 = "0hcjqaqj6ym7zclysspfswkwbppn0v3npf6yxrnh320qnx0845fp";
  };
  buildInputs = [ pkgs.openssh ];
  propagatedBuildInputs = [
    python.packages."configparser"
    python.packages."future"
    python.packages."phue"
  ];
}
