# generated using pypi2nix tool (version: 1.8.0)
# See more at: https://github.com/garbas/pypi2nix
#
# COMMAND:
#   pypi2nix -r requirements.txt -V 3 -I /home/arnold/programme/nixconfig/
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



    "SQLAlchemy" = python.mkDerivation {
      name = "SQLAlchemy-1.2.6";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/da/ef/f10a6892f8ff3c1fec1c25699a7379d1f72f291c8fa40b71c31cab3f779e/SQLAlchemy-1.2.6.tar.gz"; sha256 = "7cb00cc9b9f92ef8b4391c8a2051f81eeafefe32d63c6b395fd51401e9a39edb"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "Database Abstraction Library";
      };
    };



    "aiohttp" = python.mkDerivation {
      name = "aiohttp-3.0.9";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/aa/07/1e6a237d0847ae355eb5a5511aad5adcf8dac8e5fb42656bb14d063580d6/aiohttp-3.0.9.tar.gz"; sha256 = "281a9fa56b5ce587a2147ec285d18a224942f7e020581afa6cc44d7caecf937b"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."async-timeout"
      self."attrs"
      self."chardet"
      self."idna-ssl"
      self."multidict"
      self."yarl"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.asl20;
        description = "Async http client/server framework (asyncio)";
      };
    };



    "aiohue" = python.mkDerivation {
      name = "aiohue-1.3.0";
      src = pkgs.fetchurl { url = "https://github.com/kampfschlaefer/aiohue/archive/fix_pip_install_from_source.zip"; sha256 = "b9e1250246dd1f5b5f9c1ecba83575b25c403af246011a23119ff0cee1ac0053"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."aiohttp"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.asl20;
        description = "Python module to talk to Philips Hue.";
      };
    };



    "astral" = python.mkDerivation {
      name = "astral-1.6";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/52/10/e9fbc6f7c9f8cc411003a3fd3e3df75de79447a8b965ae96272d526fba28/astral-1.6.tar.gz"; sha256 = "874b397ddbf0a4c1d8d644b21c2481e8a96b61343f820ad52d8a322d61a15083"; };
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
      name = "async-timeout-2.0.1";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/23/6d/e37be168272b7a499111d0ed14940da80644d21b201e27980892c7125abb/async-timeout-2.0.1.tar.gz"; sha256 = "00cff4d2dce744607335cba84e9929c3165632da2d27970dbc55802a0c7873d0"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.asl20;
        description = "Timeout context manager for asyncio programs";
      };
    };



    "attrs" = python.mkDerivation {
      name = "attrs-17.4.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/8b/0b/a06cfcb69d0cb004fde8bc6f0fd192d96d565d1b8aa2829f0f20adb796e5/attrs-17.4.0.tar.gz"; sha256 = "1c7960ccfd6a005cd9f7ba884e6316b5e430a3f1a6c37c5f87d8b43f83b54ec9"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "Classes Without Boilerplate";
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



    "colorlog" = python.mkDerivation {
      name = "colorlog-3.1.2";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/b8/a3/d181e256fba34d07ac3a052269cc0a43a61cfec14674bceaa1cca1f5fdb0/colorlog-3.1.2.tar.gz"; sha256 = "7f94b6a88e789e68025b84f2581c17a52c8fb3c07e07a23e7e22bf774dd34144"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "Log formatting with colors!";
      };
    };



    "denonavr" = python.mkDerivation {
      name = "denonavr-0.6.1";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/6b/a7/209db17d8fac095b482bddecfa9e4ce032d88aa7fc393115554213e8b7d8/denonavr-0.6.1.tar.gz"; sha256 = "e99004462a65ff95063a4776f6462d1b26f5a4087488101351a90afa41330a77"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."requests"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.bsdOriginal;
        description = "Automation Library for Denon AVR receivers";
      };
    };



    "distro" = python.mkDerivation {
      name = "distro-1.2.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/b2/2e/e4b8b7f947465474e58bc9dbaa6ea8c4b4cc9e845711c0fc2f66601e464b/distro-1.2.0.tar.gz"; sha256 = "d94370e43b676ac44fbe1ab68ca903a6147eaba3a9e8eff85b2c05556a455b76"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.asl20;
        description = "Linux Distribution - a Linux OS platform information API";
      };
    };



    "home-assistant-frontend" = python.mkDerivation {
      name = "home-assistant-frontend-20180330.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/65/3e/523693c87c577deabfb132ffc983c7926da8835ff14ddb4d684d6b58707f/home-assistant-frontend-20180330.0.tar.gz"; sha256 = "bf841325c51cb72b84ab2632281c9f73d0a63d33d845f200eb7c50dede0b6be3"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."user-agents"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.asl20;
        description = "The Home Assistant frontend";
      };
    };



    "homeassistant" = python.mkDerivation {
      name = "homeassistant-0.66.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/c4/39/8cf7c6c950abcf089572cf42b6ca57f8c363f4c5af3464da1e1434acd25f/homeassistant-0.66.0.tar.gz"; sha256 = "1e81ad4c0eb80d6f822ca9982cc18b2883e05ccc97ec764ee0391980c8c2a341"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Jinja2"
      self."PyYAML"
      self."aiohttp"
      self."astral"
      self."async-timeout"
      self."attrs"
      self."certifi"
      self."pytz"
      self."requests"
      self."typing"
      self."voluptuous"
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



    "idna-ssl" = python.mkDerivation {
      name = "idna-ssl-1.0.1";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/c4/3b/facf5a5009e577e7764e68a2af5ee25c63f41c78277260c2c42b8cfabf2e/idna-ssl-1.0.1.tar.gz"; sha256 = "1293f030bc608e9aa9cdee72aa93c1521bbb9c7698068c61c9ada6772162b979"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."idna"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "Patch ssl.match_hostname for Unicode(idna) domains support";
      };
    };



    "luftdaten" = python.mkDerivation {
      name = "luftdaten-0.1.4";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/28/5a/fd150bfabef6bbfbdfecc8eb45acc0a8775c35a34031d29e777bcf8fcec6/luftdaten-0.1.4.tar.gz"; sha256 = "d3e3af830ad2b731c36af223bbb5d47d68aa3786b2965411216917a7381e1179"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."aiohttp"
      self."async-timeout"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "Python API for interacting with luftdaten.info.";
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



    "netdisco" = python.mkDerivation {
      name = "netdisco-1.3.1";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/fc/59/7b81fc97224cbf5bc47e3dd154b39553bb04899eb70d314278da50cd458e/netdisco-1.3.1.tar.gz"; sha256 = "52a0f30221f2ec6677b9ae3fdbea9c3be16b5c0ba034b83aeb33a333f10831a2"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."requests"
      self."zeroconf"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.asl20;
        description = "Discover devices on your local network";
      };
    };



    "netifaces" = python.mkDerivation {
      name = "netifaces-0.10.6";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/72/01/ba076082628901bca750bf53b322a8ff10c1d757dc29196a8e6082711c9d/netifaces-0.10.6.tar.gz"; sha256 = "0c4da523f36d36f1ef92ee183f2512f3ceb9a9d2a45f7d19cda5a42c6689ebe0"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "Portable network interface information.";
      };
    };



    "paho-mqtt" = python.mkDerivation {
      name = "paho-mqtt-1.3.1";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/2a/5f/cf14b8f9f8ed1891cda893a2a7d1d6fa23de2a9fb4832f05cef02b79d01f/paho-mqtt-1.3.1.tar.gz"; sha256 = "31911f6031de306c27ed79dc77b690d7c55b0dcb0f0434ca34ec6361d0371122"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = "License :: OSI Approved";
        description = "MQTT version 3.1.1 client class";
      };
    };



    "pytz" = python.mkDerivation {
      name = "pytz-2018.3";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/1b/50/4cdc62fc0753595fc16c8f722a89740f487c6e5670c644eb8983946777be/pytz-2018.3.tar.gz"; sha256 = "410bcd1d6409026fbaa65d9ed33bf6dd8b1e94a499e32168acfc7b332e4095c0"; };
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



    "ua-parser" = python.mkDerivation {
      name = "ua-parser-0.7.3";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/a3/b4/3d31176d3cb2807635175004e0381fb72351173ec8c9c043b80399cf33a6/ua-parser-0.7.3.tar.gz"; sha256 = "0aafb05a67b621eb4d69f6c1c3972f2d9443982bcd9132a8b665d90cd48a1add"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Python port of Browserscope's user agent parser";
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



    "user-agents" = python.mkDerivation {
      name = "user-agents-1.1.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/be/ff/886a1e2570784ee63b1c4b0fd77037b84087ffe7b7b45f9751285418be34/user-agents-1.1.0.tar.gz"; sha256 = "643d16772280052b546d956971d719989ef6dc9b17d9ff0386aa21391a038039"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."ua-parser"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "A library to identify devices (phones, tablets) and their capabilities by parsing (browser/HTTP) user agent strings";
      };
    };



    "voluptuous" = python.mkDerivation {
      name = "voluptuous-0.11.1";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/64/1a/bc658313d0a228ce474648c360bd06e28af3ed5e24029b1a4108739c23f4/voluptuous-0.11.1.tar.gz"; sha256 = "af7315c9fa99e0bfd195a21106c82c81619b42f0bd9b6e287b797c6b6b6a9918"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.bsdOriginal;
        description = "# Voluptuous is a Python data validation library";
      };
    };



    "xmltodict" = python.mkDerivation {
      name = "xmltodict-0.11.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/57/17/a6acddc5f5993ea6eaf792b2e6c3be55e3e11f3b85206c818572585f61e1/xmltodict-0.11.0.tar.gz"; sha256 = "8f8d7d40aa28d83f4109a7e8aa86e67a4df202d9538be40c0cb1d70da527b0df"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.mit;
        description = "Makes working with XML feel like you are working with JSON";
      };
    };



    "yarl" = python.mkDerivation {
      name = "yarl-1.1.1";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/91/14/5983db75b143681058d31a0a89a770f40a7f68f9b94cfeb6e6495b0039bf/yarl-1.1.1.tar.gz"; sha256 = "a69dd7e262cdb265ac7d5e929d55f2f3d07baaadd158c8f19caebf8dde08dfe8"; };
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



    "zeroconf" = python.mkDerivation {
      name = "zeroconf-0.20.0";
      src = pkgs.fetchurl { url = "https://pypi.python.org/packages/20/d7/418ff6c684ace0f5855ec56c66cfa99ec50443c41693b91e9abcccfa096c/zeroconf-0.20.0.tar.gz"; sha256 = "6e3f1e7b5871e3d1410ac29b9fb85aafc1e2d661ed596b07a6f84559a475efcb"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."netifaces"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.lgpl2;
        description = "Pure Python Multicast DNS Service Discovery Library (Bonjour/Avahi compatible)";
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