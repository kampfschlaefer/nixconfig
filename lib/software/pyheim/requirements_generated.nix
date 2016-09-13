# generated using pypi2nix tool (version: 1.5.0.dev0)
#
# COMMAND:
#   pypi2nix -V 3.5 -e . -r requirements_dev.txt
#

{ pkgs, python, commonBuildInputs ? [], commonDoCheck ? false }:

self: {

  "configparser" = python.mkDerivation {
    name = "configparser-3.5.0";
    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/7c/69/c2ce7e91c89dc073eb1aa74c0621c3eefbffe8216b3f9af9d3885265c01c/configparser-3.5.0.tar.gz";
      sha256 = "5308b47021bc2340965c371f0f058cc6971a04502638d4244225c49d80db273a";
    };
    doCheck = commonDoCheck;
    buildInputs = commonBuildInputs;
    propagatedBuildInputs = [ ];
    meta = with pkgs.stdenv.lib; {
      homepage = "";
      license = licenses.mit;
      description = "This library brings the updated configparser from Python 3.5 to Python 2.6-3.5.";
    };
  };



  "coverage" = python.mkDerivation {
    name = "coverage-4.0";
    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/b6/1f/51dd99a422428771bd4c787bcac71fe4051fbfa0e33480b3d522192b75b3/coverage-4.0.tar.gz";
      sha256 = "b1244343e39cb2835f9c89c2d8fbcad8e4a5b4945344b434a4d8b6e9e7431390";
    };
    doCheck = commonDoCheck;
    buildInputs = commonBuildInputs;
    propagatedBuildInputs = [ ];
    meta = with pkgs.stdenv.lib; {
      homepage = "";
      license = licenses.asl20;
      description = "Code coverage measurement for Python";
    };
  };



  "flake8" = python.mkDerivation {
    name = "flake8-2.4.1";
    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/8f/b5/9a73c66c7dba273bac8758398f060c008a25f3e84531063b42503b5d0a95/flake8-2.4.1.tar.gz";
      sha256 = "2e7ebbe59d8c85e626e36d99f0db2f578394313d3f7ce9dc9f1da57ef6cd7537";
    };
    doCheck = commonDoCheck;
    buildInputs = commonBuildInputs;
    propagatedBuildInputs = [
      self."mccabe"
      self."pep8"
      self."pyflakes"
    ];
    meta = with pkgs.stdenv.lib; {
      homepage = "";
      license = licenses.mit;
      description = "the modular source code checker: pep8, pyflakes and co";
    };
  };



  "future" = python.mkDerivation {
    name = "future-0.15.2";
    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/5a/f4/99abde815842bc6e97d5a7806ad51236630da14ca2f3b1fce94c0bb94d3d/future-0.15.2.tar.gz";
      sha256 = "3d3b193f20ca62ba7d8782589922878820d0a023b885882deec830adbf639b97";
    };
    doCheck = commonDoCheck;
    buildInputs = commonBuildInputs;
    propagatedBuildInputs = [ ];
    meta = with pkgs.stdenv.lib; {
      homepage = "";
      license = licenses.mit;
      description = "Clean single-source support for Python 3 and 2";
    };
  };



  "mccabe" = python.mkDerivation {
    name = "mccabe-0.3.1";
    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/bb/c9/a7d3a53fdaee1fdff753e8333ccf8affe944ac1d4dc4894dbcaa3db5954b/mccabe-0.3.1.tar.gz";
      sha256 = "5f7ea6fb3aa9afe146d07fd6d5cedf788747d8b0c29e44732453c2b2db1e3d16";
    };
    doCheck = commonDoCheck;
    buildInputs = commonBuildInputs;
    propagatedBuildInputs = [ ];
    meta = with pkgs.stdenv.lib; {
      homepage = "";
      license = licenses.mit;
      description = "McCabe checker, plugin for flake8";
    };
  };



  "pep8" = python.mkDerivation {
    name = "pep8-1.7.0";
    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/3e/b5/1f717b85fbf5d43d81e3c603a7a2f64c9f1dabc69a1e7745bd394cc06404/pep8-1.7.0.tar.gz";
      sha256 = "a113d5f5ad7a7abacef9df5ec3f2af23a20a28005921577b15dd584d099d5900";
    };
    doCheck = commonDoCheck;
    buildInputs = commonBuildInputs;
    propagatedBuildInputs = [ ];
    meta = with pkgs.stdenv.lib; {
      homepage = "";
      license = licenses.mit;
      description = "Python style guide checker";
    };
  };



  "phue" = python.mkDerivation {
    name = "phue-0.8";
    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/84/8a/c10bd162ef44dfabef89a52649c0802a0212ff84567960300d17f6f0f76b/phue-0.8.tar.gz";
      sha256 = "520cc47fcde328e26edf3e7d59deda5640ad868c0f446d058751a6c8e096e2e0";
    };
    doCheck = commonDoCheck;
    buildInputs = commonBuildInputs;
    propagatedBuildInputs = [ ];
    meta = with pkgs.stdenv.lib; {
      homepage = "";
      license = "WTFPL";
      description = "A Philips Hue Python library";
    };
  };



  "pyflakes" = python.mkDerivation {
    name = "pyflakes-0.8.1";
    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/75/22/a90ec0252f4f87f3ffb6336504de71fe16a49d69c4538dae2f12b9360a38/pyflakes-0.8.1.tar.gz";
      sha256 = "3fa80a10b36d51686bf7744f5dc99622cd5c98ce8ed64022e629868aafc17769";
    };
    doCheck = commonDoCheck;
    buildInputs = commonBuildInputs;
    propagatedBuildInputs = [ ];
    meta = with pkgs.stdenv.lib; {
      homepage = "";
      license = licenses.mit;
      description = "passive checker of Python programs";
    };
  };

}