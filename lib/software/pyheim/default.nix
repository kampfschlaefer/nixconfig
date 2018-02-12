{ pkgs }:

let
  python = import ./requirements.nix { inherit pkgs; };
in python.mkDerivation {
  name = "pyheim-0.1.0";
  src = pkgs.fetchgit {
    name = "pyheim-master";
    url = "git://gitolite/pyheim.git";
    rev = "a70186f0f06a12fa0539aadb27639ad22d830903";
    sha256 = "0nn01r9z1h6l3ihfc2m9cl4pdmpparxwg0gg0m19lp547cpv85g8";
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
