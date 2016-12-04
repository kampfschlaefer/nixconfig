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
    sha256 = "1pxdcyhcm9hm46374vk5wy0wnm6pflydpr71a6kx1rqbz1fv64jh";
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
