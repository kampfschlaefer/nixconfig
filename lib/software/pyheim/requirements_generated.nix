# generated using pypi2nix tool (version: 1.5.0.dev0)
#
# COMMAND:
#   pypi2nix -I /home/arnold/programme/nixconfig -V 3.5 -e . -e pytest-runner==2.6.2 -e setuptools_scm -v
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



  "mido" = python.mkDerivation {
    name = "mido-1.1.8";
    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/66/34/106162294c2860303fa791a87a6e0323b1e2a5cefc6b5462dc3143e24f34/mido-1.1.8.tar.gz";
      sha256 = "29203cb1eadbcb39863d5f2798425eea58dbdf6b13541cc84c75c19baa0a956a";
    };
    doCheck = commonDoCheck;
    buildInputs = commonBuildInputs;
    propagatedBuildInputs = [ ];
    meta = with pkgs.stdenv.lib; {
      homepage = "";
      license = licenses.mit;
      description = "MIDI Objects for Python";
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



  "pytest-runner" = python.mkDerivation {
    name = "pytest-runner-2.6.2";
    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/de/7a/a6b4f85476e29fcb35a5d4d7cf4b8d91b8919dedf8e7b070877d83deaa80/pytest-runner-2.6.2.tar.gz";
      sha256 = "e775a40ee4a3a1d45018b199c44cc20bbe7f3df2dc8882f61465bb4141c78cdb";
    };
    doCheck = commonDoCheck;
    buildInputs = commonBuildInputs;
    propagatedBuildInputs = [ ];
    meta = with pkgs.stdenv.lib; {
      homepage = "";
      license = licenses.mit;
      description = "Invoke py.test as distutils command with dependency resolution.";
    };
  };



  "setuptools-scm" = python.mkDerivation {
    name = "setuptools-scm-1.15.0";
    src = pkgs.fetchurl {
      url = "https://pypi.python.org/packages/80/b7/31b6ae5fcb188e37f7e31abe75f9be90490a5456a72860fa6e643f8a3cbc/setuptools_scm-1.15.0.tar.gz";
      sha256 = "daf12d05aa2155a46aa357453757ffdc47d87f839e62114f042bceac6a619e2f";
    };
    doCheck = commonDoCheck;
    buildInputs = commonBuildInputs;
    propagatedBuildInputs = [ ];
    meta = with pkgs.stdenv.lib; {
      homepage = "";
      license = licenses.mit;
      description = "the blessed package to manage your versions by scm tags";
    };
  };

}