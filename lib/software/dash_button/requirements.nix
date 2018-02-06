# generated using pypi2nix tool (version: 1.8.0)
# See more at: https://github.com/garbas/pypi2nix
#
# COMMAND:
#   pypi2nix -V 3 -I /home/arnold/programme/nixconfig/ -r requirements.txt -s pytz
#

{ pkgs ? import <nixpkgs> {}
}:

let

  inherit (pkgs) makeWrapper;
  inherit (pkgs.stdenv.lib) fix' extends inNixShell;

  pythonPackages =
  import "${toString pkgs.path}/pkgs/top-level/python-packages.nix" {
    inherit pkgs;
    inherit (pkgs) stdenv;
    python = pkgs.python3;
  };

  commonBuildInputs = [];
  commonDoCheck = false;

  withPackages = pkgs':
    let
      pkgs = builtins.removeAttrs pkgs' ["__unfix__"];
      interpreter = pythonPackages.buildPythonPackage {
        name = "python3-interpreter";
        buildInputs = [ makeWrapper ] ++ (builtins.attrValues pkgs);
        buildCommand = ''
          mkdir -p $out/bin
          ln -s ${pythonPackages.python.interpreter}               $out/bin/${pythonPackages.python.executable}
          for dep in ${builtins.concatStringsSep " "               (builtins.attrValues pkgs)}; do
            if [ -d "$dep/bin" ]; then
              for prog in "$dep/bin/"*; do
                if [ -f $prog ]; then
                  ln -s $prog $out/bin/`basename $prog`
                fi
              done
            fi
          done
          for prog in "$out/bin/"*; do
            wrapProgram "$prog" --prefix PYTHONPATH : "$PYTHONPATH"
          done
          pushd $out/bin
          ln -s ${pythonPackages.python.executable} python
          popd
        '';
        passthru.interpreter = pythonPackages.python;
      };
    in {
      __old = pythonPackages;
      inherit interpreter;
      mkDerivation = pythonPackages.buildPythonPackage;
      packages = pkgs;
      overrideDerivation = drv: f:
        pythonPackages.buildPythonPackage (drv.drvAttrs // f drv.drvAttrs);
      withPackages = pkgs'':
        withPackages (pkgs // pkgs'');
    };

  python = withPackages {};

  generated = self: {

    "Jinja2" = python.mkDerivation {
      name = "Jinja2-2.10";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/56/e6/332789f295cf22308386cf5bbd1f4e00ed11484299c5d7383378cf48ba47/Jinja2-2.10.tar.gz"; sha256 = "f84be1bb0040caca4cea721fcbbbbd61f9be9464ca236387158b0feea01914a4"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."MarkupSafe"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.bsdOriginal;
        description = "A small but fast and easy to use stand-alone template engine written in pure python.";
      };
    };



    "MarkupSafe" = python.mkDerivation {
      name = "MarkupSafe-1.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/4d/de/32d741db316d8fdb7680822dd37001ef7a448255de9699ab4bfcbdf4172b/MarkupSafe-1.0.tar.gz"; sha256 = "a6be69091dac236ea9c6bc7d012beab42010fa914c459791d627dad4910eb665"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.bsdOriginal;
        description = "Implements a XML/HTML/XHTML Markup safe string for Python";
      };
    };



    "PyYAML" = python.mkDerivation {
      name = "PyYAML-3.12";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/4a/85/db5a2df477072b2902b0eb892feb37d88ac635d36245a72a6a69b23b383a/PyYAML-3.12.tar.gz"; sha256 = "592766c6303207a20efc445587778322d7f73b161bd994f227adaa341ba212ab"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "YAML parser and emitter for Python";
      };
    };



    "aiohttp" = python.mkDerivation {
      name = "aiohttp-2.3.7";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/5e/67/c66a608cd61f49f71cedea2bb2e479c9da5bfaf4b83948b2b7a475e8ac8f/aiohttp-2.3.7.tar.gz"; sha256 = "fe294df38e9c67374263d783a7a29c79372030f5962bd5734fa51c6f4bbfee3b"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."async-timeout"
      self."chardet"
      self."multidict"
      self."yarl"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.asl20;
        description = "Async http client/server framework (asyncio)";
      };
    };



    "astral" = python.mkDerivation {
      name = "astral-1.4";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/a4/d6/c309f266677372964c6002a56a7bec2a90875338a71325e20b24d6d1e187/astral-1.4.zip"; sha256 = "e7f2c825ac101c0953812e0f4c617ca48bd9dd5f4ebf450f7ce9086ed8f5a1fe"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pytz"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = "Apache-2.0";
        description = "Calculations for the position of the sun and moon.";
      };
    };



    "async-timeout" = python.mkDerivation {
      name = "async-timeout-2.0.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/78/10/7fd2551dc51f6065bdbba07d395865df4582cc18169297e7a5c8d90f5bd2/async-timeout-2.0.0.tar.gz"; sha256 = "c17d8ac2d735d59aa62737d76f2787a6c938f5a944ecf768a8c0ab70b0dea566"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.asl20;
        description = "Timeout context manager for asyncio programs";
      };
    };



    "certifi" = python.mkDerivation {
      name = "certifi-2018.1.18";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/15/d4/2f888fc463d516ff7bf2379a4e9a552fef7f22a94147655d9b1097108248/certifi-2018.1.18.tar.gz"; sha256 = "edbc3f203427eef571f79a7692bb160a2b0f7ccaa31953e99bd17e307cf63f7d"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mpl20;
        description = "Python package for providing Mozilla's CA Bundle.";
      };
    };



    "chardet" = python.mkDerivation {
      name = "chardet-3.0.4";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d/chardet-3.0.4.tar.gz"; sha256 = "84ab92ed1c4d4f16916e05906b6b75a6c0fb5db821cc65e70cbd64a3e2a5eaae"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.lgpl2;
        description = "Universal encoding detector for Python 2 and 3";
      };
    };



    "homeassistant" = python.mkDerivation {
      name = "homeassistant-0.62.1";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/53/63/670ee76b94cd260c37b2fc539fd9f14e2f39b8a7d17a2a44e48969d8282e/homeassistant-0.62.1.tar.gz"; sha256 = "73d74d9511fcf0b5408ccc847836f54166dbce044bc7be3afe0082a972f6b8c9"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Jinja2"
      self."PyYAML"
      self."aiohttp"
      self."astral"
      self."async-timeout"
      self."certifi"
      self."chardet"
      self."pytz"
      self."requests"
      self."typing"
      self."voluptuous"
      self."yarl"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.asl20;
        description = "Open-source home automation platform running on Python 3.";
      };
    };



    "idna" = python.mkDerivation {
      name = "idna-2.6";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/f4/bd/0467d62790828c23c47fc1dfa1b1f052b24efdf5290f071c7a91d0d82fd3/idna-2.6.tar.gz"; sha256 = "2c6a5de3089009e3da7c5dde64a141dbc8551d5b7f6cf4ed7c2568d0cc520a8f"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.bsdOriginal;
        description = "Internationalized Domain Names in Applications (IDNA)";
      };
    };



    "multidict" = python.mkDerivation {
      name = "multidict-4.1.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/ea/eb/c79ed6ff320ac8e935dcbff8a8833f1afb35c2433bff5bf1c9dabbd631b2/multidict-4.1.0.tar.gz"; sha256 = "fb4412490324705dcd2172baa8a3ea58ae23c5f982476805cad58ae929fe2a52"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.asl20;
        description = "multidict implementation";
      };
    };



    "pytz" = python.mkDerivation {
      name = "pytz-2017.3";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/60/88/d3152c234da4b2a1f7a989f89609ea488225eaea015bc16fbde2b3fdfefa/pytz-2017.3.zip"; sha256 = "fae4cffc040921b8a2d60c6cf0b5d662c1190fe54d718271db4eb17d44a185b7"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "World timezone definitions, modern and historical";
      };
    };



    "requests" = python.mkDerivation {
      name = "requests-2.18.4";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/b0/e1/eab4fc3752e3d240468a8c0b284607899d2fbfb236a56b7377a329aa8d09/requests-2.18.4.tar.gz"; sha256 = "9c443e7324ba5b85070c4a818ade28bfabedf16ea10206da1132edaa6dda237e"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."certifi"
      self."chardet"
      self."idna"
      self."urllib3"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.asl20;
        description = "Python HTTP for Humans.";
      };
    };



    "scapy" = python.mkDerivation {
      name = "scapy-2.4.0rc4";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/59/55/392c68f2a8bad3a51d24de415645c042621937726b06d431ea40bf5922dd/scapy-2.4.0rc4.tar.gz"; sha256 = "2f967bac849eb19e8920ab8ebaef90fa093b8a3a3d542e23cd0f04c3acde2851"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.gpl2;
        description = "Scapy: interactive packet manipulation tool";
      };
    };



    "typing" = python.mkDerivation {
      name = "typing-3.6.4";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/ec/cc/28444132a25c113149cec54618abc909596f0b272a74c55bab9593f8876c/typing-3.6.4.tar.gz"; sha256 = "d400a9344254803a2368533e4533a4200d21eb7b6b729c173bc38201a74db3f2"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.psfl;
        description = "Type Hints for Python";
      };
    };



    "urllib3" = python.mkDerivation {
      name = "urllib3-1.22";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/ee/11/7c59620aceedcc1ef65e156cc5ce5a24ef87be4107c2b74458464e437a5d/urllib3-1.22.tar.gz"; sha256 = "cc44da8e1145637334317feebd728bd869a35285b93cbb4cca2577da7e62db4f"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."certifi"
      self."idna"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "HTTP library with thread-safe connection pooling, file post, and more.";
      };
    };



    "voluptuous" = python.mkDerivation {
      name = "voluptuous-0.10.5";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/c3/81/c84f8a3e723b760fdd1c41fc80201cb80cd29c1bce5159d8918c58df7d2a/voluptuous-0.10.5.tar.gz"; sha256 = "7a7466f8dc3666a292d186d1d871a47bf2120836ccb900d5ba904674957a2396"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.bsdOriginal;
        description = "# Voluptuous is a Python data validation library";
      };
    };



    "yarl" = python.mkDerivation {
      name = "yarl-0.18.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/65/e9/24738bbbf003e812f802d5700c41efe47b0b7cae40556a6ec74af0afc13e/yarl-0.18.0.tar.gz"; sha256 = "baa0d3f7982fa0c03a55433109c405e79a597141f2e2d6ee7e16c03eabd74886"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."idna"
      self."multidict"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.asl20;
        description = "Yet another URL library";
      };
    };

  };
  overrides = import ./requirements_override.nix { inherit pkgs python; };
  commonOverrides = [

  ];

in python.withPackages
   (fix' (pkgs.lib.fold
            extends
            generated
            ([overrides] ++ commonOverrides)
         )
   )