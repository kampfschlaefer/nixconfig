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
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/56/e6/332789f295cf22308386cf5bbd1f4e00ed11484299c5d7383378cf48ba47/Jinja2-2.10.tar.gz"; sha256 = "f84be1bb0040caca4cea721fcbbbbd61f9be9464ca236387158b0feea01914a4"; };
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
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/4d/de/32d741db316d8fdb7680822dd37001ef7a448255de9699ab4bfcbdf4172b/MarkupSafe-1.0.tar.gz"; sha256 = "a6be69091dac236ea9c6bc7d012beab42010fa914c459791d627dad4910eb665"; };
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
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/4a/85/db5a2df477072b2902b0eb892feb37d88ac635d36245a72a6a69b23b383a/PyYAML-3.12.tar.gz"; sha256 = "592766c6303207a20efc445587778322d7f73b161bd994f227adaa341ba212ab"; };
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
      name = "SQLAlchemy-1.2.8";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b4/9c/411a9bac1a471bed54ec447dc183aeed12a75c1b648307e18b56e3829363/SQLAlchemy-1.2.8.tar.gz"; sha256 = "2d5f08f714a886a1382c18be501e614bce50d362384dc089474019ce0768151c"; };
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
      name = "aiohttp-3.3.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/72/6a/5bbf3544fe8de525f4521506b372dc9c3b13070fe34e911c976aa95631d7/aiohttp-3.3.2.tar.gz"; sha256 = "f20deec7a3fbaec7b5eb7ad99878427ad2ee4cc16a46732b705e8121cbb3cc12"; };
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
      name = "aiohue-1.6.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/7f/dc/3103a6cf08112c2044ee7d27deb4679bae27fbcc90e76298fdfbc9d9a362/aiohue-1.6.0.tar.gz"; sha256 = "87f0f86865e88ea715ab358b1e5f2838b79ee7cdc0bdf762e9ed60aaf4c8bd4a"; };
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
      name = "astral-1.6.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/cc/cc/65ca157e967756a8f08b1cf1c0a1a30c83ed32c50dbe83c557874ce101ca/astral-1.6.1.tar.gz"; sha256 = "ab0c08f2467d35fcaeb7bad15274743d3ac1ad18b5391f64a0058a9cd192d37d"; };
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
      name = "async-timeout-3.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/35/82/6c7975afd97661e6115eee5105359ee191a71ff3267fde081c7c8d05fae6/async-timeout-3.0.0.tar.gz"; sha256 = "b3c0ddc416736619bd4a95ca31de8da6920c3b9a140c64dbef2b2fa7bf521287"; };
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
      name = "attrs-18.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e4/ac/a04671e118b57bee87dabca1e0f2d3bda816b7a551036012d0ca24190e71/attrs-18.1.0.tar.gz"; sha256 = "e0d0eb91441a3b53dab4d9b743eafc1ac44476296a2053b6ca3af0b139faf87b"; };
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
      name = "certifi-2018.4.16";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/4d/9c/46e950a6f4d6b4be571ddcae21e7bc846fcbb88f1de3eff0f6dd0a6be55d/certifi-2018.4.16.tar.gz"; sha256 = "13e698f54293db9f89122b0581843a782ad0934a4fe0172d2a980ba77fc61bb7"; };
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
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d/chardet-3.0.4.tar.gz"; sha256 = "84ab92ed1c4d4f16916e05906b6b75a6c0fb5db821cc65e70cbd64a3e2a5eaae"; };
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
      name = "colorlog-3.1.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/2c/a8/8ce4f59cf1fcbb9ebe750fcbab723146d95687c37256ed367a11d9f74265/colorlog-3.1.4.tar.gz"; sha256 = "418db638c9577f37f0fae4914074f395847a728158a011be2a193ac491b9779d"; };
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
      name = "denonavr-0.7.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/98/3c/c8391e283729516115e52fbcd70d6c002e323d1a1b5470ebd5961995b436/denonavr-0.7.3.tar.gz"; sha256 = "765aef97e91e07d446f9343dfaaa05307ef0acaeaf90fff286b038855728a1b5"; };
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
      name = "distro-1.3.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d2/42/3b059929a920cd9d4e91e7a5e35f0d2ed75211f8f4e877be9d1bde9fdf46/distro-1.3.0.tar.gz"; sha256 = "224041cef9600e72d19ae41ba006e71c05c4dc802516da715d7fda55ba3d8742"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.asl20;
        description = "Distro - an OS platform information API";
      };
    };



    "home-assistant-frontend" = python.mkDerivation {
      name = "home-assistant-frontend-20180510.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/04/de/a9ace982e0093f30ef90966a6394ce47fe4b4d52b9749522a4d9960eec3b/home-assistant-frontend-20180510.1.tar.gz"; sha256 = "266b25887b1917d47c8bf1c05c3367b6b4ba89536b6d43d0b614f9c1da0bef1a"; };
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
      name = "homeassistant-0.72.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c3/64/910c7f9b6e4867dbe2cc3056f9ca021a1c0b66993facc22c7a0fd0a3fd75/homeassistant-0.72.0.tar.gz"; sha256 = "9b9500a60b84e699b21841ff5082e806784b4fcead6b05e5130001c34a1f0b3e"; };
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
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f4/bd/0467d62790828c23c47fc1dfa1b1f052b24efdf5290f071c7a91d0d82fd3/idna-2.6.tar.gz"; sha256 = "2c6a5de3089009e3da7c5dde64a141dbc8551d5b7f6cf4ed7c2568d0cc520a8f"; };
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
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c4/3b/facf5a5009e577e7764e68a2af5ee25c63f41c78277260c2c42b8cfabf2e/idna-ssl-1.0.1.tar.gz"; sha256 = "1293f030bc608e9aa9cdee72aa93c1521bbb9c7698068c61c9ada6772162b979"; };
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
      name = "luftdaten-0.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/cc/2a/2b5583c82ac322ebffb14919d1f83bf2e27ad77d62e46464c36d189d7cbf/luftdaten-0.2.0.tar.gz"; sha256 = "75fb177f61904dd1a7f93c1fa6c7cd468fd4a2e04ca45a87d37c802d290d17ad"; };
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
      name = "multidict-4.3.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9d/b9/3cf1b908d7af6530209a7a16d71ab2734a736c3cdf0657e3a06d0209811e/multidict-4.3.1.tar.gz"; sha256 = "5ba766433c30d703f6b2c17eb0b6826c6f898e5f58d89373e235f07764952314"; };
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
      name = "netdisco-1.5.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e9/13/07f0c4b101eb46cb681bd931dccf0a759a34f6be1287af068f4ee24d4d26/netdisco-1.5.0.tar.gz"; sha256 = "308d8b9a95f9d25860349857a60915b9ef71fb33c5ed998b8acef1d88453a15c"; };
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
      name = "netifaces-0.10.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/81/39/4e9a026265ba944ddf1fea176dbb29e0fe50c43717ba4fcf3646d099fe38/netifaces-0.10.7.tar.gz"; sha256 = "bd590fcb75421537d4149825e1e63cca225fd47dad861710c46bd1cb329d8cbd"; };
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
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/2a/5f/cf14b8f9f8ed1891cda893a2a7d1d6fa23de2a9fb4832f05cef02b79d01f/paho-mqtt-1.3.1.tar.gz"; sha256 = "31911f6031de306c27ed79dc77b690d7c55b0dcb0f0434ca34ec6361d0371122"; };
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
      name = "pytz-2018.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/10/76/52efda4ef98e7544321fd8d5d512e11739c1df18b0649551aeccfb1c8376/pytz-2018.4.tar.gz"; sha256 = "c06425302f2cf668f1bba7a0a03f3c1d34d4ebeef2c72003da308b3947c7f749"; };
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
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b0/e1/eab4fc3752e3d240468a8c0b284607899d2fbfb236a56b7377a329aa8d09/requests-2.18.4.tar.gz"; sha256 = "9c443e7324ba5b85070c4a818ade28bfabedf16ea10206da1132edaa6dda237e"; };
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
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ec/cc/28444132a25c113149cec54618abc909596f0b272a74c55bab9593f8876c/typing-3.6.4.tar.gz"; sha256 = "d400a9344254803a2368533e4533a4200d21eb7b6b729c173bc38201a74db3f2"; };
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
      name = "ua-parser-0.8.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b0/02/94ea43fc432fb112fbb62a89855317c41c210fb5239a2ed9b94ecb63024f/ua-parser-0.8.0.tar.gz"; sha256 = "97bbcfc9321a3151d96bb5d62e54270247b0e3be0590a6f2ff12329851718dcb"; };
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
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ee/11/7c59620aceedcc1ef65e156cc5ce5a24ef87be4107c2b74458464e437a5d/urllib3-1.22.tar.gz"; sha256 = "cc44da8e1145637334317feebd728bd869a35285b93cbb4cca2577da7e62db4f"; };
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
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/be/ff/886a1e2570784ee63b1c4b0fd77037b84087ffe7b7b45f9751285418be34/user-agents-1.1.0.tar.gz"; sha256 = "643d16772280052b546d956971d719989ef6dc9b17d9ff0386aa21391a038039"; };
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
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/64/1a/bc658313d0a228ce474648c360bd06e28af3ed5e24029b1a4108739c23f4/voluptuous-0.11.1.tar.gz"; sha256 = "af7315c9fa99e0bfd195a21106c82c81619b42f0bd9b6e287b797c6b6b6a9918"; };
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
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/57/17/a6acddc5f5993ea6eaf792b2e6c3be55e3e11f3b85206c818572585f61e1/xmltodict-0.11.0.tar.gz"; sha256 = "8f8d7d40aa28d83f4109a7e8aa86e67a4df202d9538be40c0cb1d70da527b0df"; };
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
      name = "yarl-1.2.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/43/b8/057c3e5b546ff4b24263164ecda13f6962d85c9dc477fcc0bcdcb3adb658/yarl-1.2.6.tar.gz"; sha256 = "c8cbc21bbfa1dd7d5386d48cc814fe3d35b80f60299cdde9279046f399c3b0d8"; };
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
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/20/d7/418ff6c684ace0f5855ec56c66cfa99ec50443c41693b91e9abcccfa096c/zeroconf-0.20.0.tar.gz"; sha256 = "6e3f1e7b5871e3d1410ac29b9fb85aafc1e2d661ed596b07a6f84559a475efcb"; };
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