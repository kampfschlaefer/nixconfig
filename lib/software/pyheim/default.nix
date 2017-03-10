{ }:

let
  pkgs = import ../../../nixpkgs {};
  python = import ./requirements.nix { inherit pkgs; };
in python.mkDerivation {
  name = "pyheim-0.1.0";
  src = pkgs.fetchgit {
    name = "pyheim-master";
    url = "git://gitolite/pyheim.git";
    rev = "3b759f5080359bebfa42463de9c102b8ce3a94cd";
    sha256 = "0719n1fahjnz5b5g1vjhl1knqyqfv4pghpdynzhmx6zhygzx2h57";
  };
  doCheck = false;
  checkPhase = ''
    export NO_TESTS_OVER_WIRE=1
    export PYTHONDONTWRITEBYTECODE=1

    #flake8 pyheim
    #py.test --cov=pyheim -cov-report term-missing
    #coverage html
  '';
  buildInputs = [
    pkgs.openssh
    python.packages."pytest-runner"
  ];
  propagatedBuildInputs = [
    python.packages."configparser"
    python.packages."future"
    python.packages."phue"
  ];
  /*propagatedBuildInputs = builtins.attrValues python.packages;*/
}
