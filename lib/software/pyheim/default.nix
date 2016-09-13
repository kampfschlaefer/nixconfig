{ }:

let
  pkgs = import ../../../nixpkgs {};
  python = import ./requirements.nix { inherit pkgs; };
in python.mkDerivation {
  name = "pyheim-0.1.0";
  src = pkgs.fetchgit {
    name = "pyheim-master";
    url = "git://gitolite/pyheim.git";
    rev = "d5a74a498311acef681c00eea9be10804d9e1873";
    sha256 = "13psf1hmsk0xcc02bdh672q41d6ya352fcf7n6zydr5shf7gzq4g";
  };
  buildInputs = [ pkgs.openssh ];
  propagatedBuildInputs = [
    python.packages."configparser"
    python.packages."future"
    python.packages."phue"
  ];
}