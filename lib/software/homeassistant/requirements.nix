# generated using pypi2nix tool (version: 1.8.1)
# See more at: https://github.com/garbas/pypi2nix
#
# COMMAND:
#   pypi2nix -r requirements.txt -V 3 -I /home/arnold/programme/nixconfig/ -E libffi openssl
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
    # patching pip so it does not try to remove files when running nix-shell
    overrides =
      self: super: {
        bootstrapped-pip = super.bootstrapped-pip.overrideDerivation (old: {
          patchPhase = old.patchPhase + ''
            sed -i               -e "s|paths_to_remove.remove(auto_confirm)|#paths_to_remove.remove(auto_confirm)|"                -e "s|self.uninstalled = paths_to_remove|#self.uninstalled = paths_to_remove|"                  $out/${pkgs.python35.sitePackages}/pip/req/req_install.py
          '';
        });
      };
  };

  commonBuildInputs = with pkgs; [ libffi openssl ];
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
          ln -s ${pythonPackages.python.executable}               python3
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
        pythonPackages.buildPythonPackage (drv.drvAttrs // f drv.drvAttrs //                                            { meta = drv.meta; });
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
        homepage = "http://jinja.pocoo.org/";
        license = licenses.bsdOriginal;
        description = "A small but fast and easy to use stand-alone template engine written in pure python.";
      };
    };



    "MarkupSafe" = python.mkDerivation {
      name = "MarkupSafe-1.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ac/7e/1b4c2e05809a4414ebce0892fe1e32c14ace86ca7d50c70f00979ca9b3a3/MarkupSafe-1.1.0.tar.gz"; sha256 = "4e97332c9ce444b0c2c38dd22ddc61c743eb208d916e4265a2a3b575bdccb1d3"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://www.palletsprojects.com/p/markupsafe/";
        license = licenses.bsdOriginal;
        description = "Safely add untrusted strings to HTML/XML markup.";
      };
    };



    "PyJWT" = python.mkDerivation {
      name = "PyJWT-1.6.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/00/5e/b358c9bb24421e6155799d995b4aa3aa3307ffc7ecae4ad9d29fd7e07a73/PyJWT-1.6.4.tar.gz"; sha256 = "4ee413b357d53fd3fb44704577afac88e72e878716116270d722723d65b42176"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."cryptography"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/jpadilla/pyjwt";
        license = licenses.mit;
        description = "JSON Web Token implementation in Python";
      };
    };



    "PyQRCode" = python.mkDerivation {
      name = "PyQRCode-1.2.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/37/61/f07226075c347897937d4086ef8e55f0a62ae535e28069884ac68d979316/PyQRCode-1.2.1.tar.gz"; sha256 = "fdbf7634733e56b72e27f9bce46e4550b75a3a2c420414035cae9d9d26b234d5"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/mnooner256/pyqrcode";
        license = licenses.bsdOriginal;
        description = "A QR code generator written purely in Python with SVG, EPS, PNG and terminal output.";
      };
    };



    "PyYAML" = python.mkDerivation {
      name = "PyYAML-3.13";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9e/a3/1d13970c3f36777c583f136c136f804d70f500168edc1edea6daa7200769/PyYAML-3.13.tar.gz"; sha256 = "3ef3092145e9b70e3ddd2c7ad59bdd0252a94dfe3949721633e41344de00a6bf"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pyyaml.org/wiki/PyYAML";
        license = licenses.mit;
        description = "YAML parser and emitter for Python";
      };
    };



    "SQLAlchemy" = python.mkDerivation {
      name = "SQLAlchemy-1.2.17";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c6/52/73d1c92944cd294a5b165097038418abb6a235f5956d43d06f97254f73bf/SQLAlchemy-1.2.17.tar.gz"; sha256 = "52a42dbf02d0562d6e90e7af59f177f1cc027e72833cc29c3a821eefa009c71d"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.sqlalchemy.org";
        license = licenses.mit;
        description = "Database Abstraction Library";
      };
    };



    "Unidecode" = python.mkDerivation {
      name = "Unidecode-1.0.23";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9b/d8/c1b658ed7ff6e63a745eda483d7d917eb63a79c59fcb422469b85ff47e94/Unidecode-1.0.23.tar.gz"; sha256 = "8b85354be8fd0c0e10adbf0675f6dc2310e56fda43fa8fe049123b6c475e52fb"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "";
        license = licenses.gpl2Plus;
        description = "ASCII transliterations of Unicode text";
      };
    };



    "aiohttp" = python.mkDerivation {
      name = "aiohttp-3.5.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/0f/58/c8b83f999da3b13e66249ea32f325be923791c0c10aee6cf16002a3effc1/aiohttp-3.5.4.tar.gz"; sha256 = "9c4c83f4fa1938377da32bc2d59379025ceeee8e24b89f72fcbccd8ca22dc9bf"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."async-timeout"
      self."attrs"
      self."chardet"
      self."idna-ssl"
      self."multidict"
      self."typing-extensions"
      self."yarl"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/aio-libs/aiohttp";
        license = licenses.asl20;
        description = "Async http client/server framework (asyncio)";
      };
    };



    "aiohttp-cors" = python.mkDerivation {
      name = "aiohttp-cors-0.7.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/44/9e/6cdce7c3f346d8fd487adf68761728ad8cd5fbc296a7b07b92518350d31f/aiohttp-cors-0.7.0.tar.gz"; sha256 = "4d39c6d7100fd9764ed1caf8cebf0eb01bf5e3f24e2e073fda6234bc48b19f5d"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."aiohttp"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/aio-libs/aiohttp-cors";
        license = licenses.asl20;
        description = "CORS support for aiohttp";
      };
    };



    "aiohue" = python.mkDerivation {
      name = "aiohue-1.9.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/7c/c4/6b8844c7625dc36033b326868891b6f1996cc44af8d20e85518e95585f51/aiohue-1.9.0.tar.gz"; sha256 = "3b6cb87652cf1ffc904443b9c5514873c331e159953f2ebf77a051444b350594"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."aiohttp"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/balloob/aiohue";
        license = licenses.asl20;
        description = "Python module to talk to Philips Hue.";
      };
    };



    "asn1crypto" = python.mkDerivation {
      name = "asn1crypto-0.24.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fc/f1/8db7daa71f414ddabfa056c4ef792e1461ff655c2ae2928a2b675bfed6b4/asn1crypto-0.24.0.tar.gz"; sha256 = "9d5c20441baf0cb60a4ac34cc447c6c189024b6b4c6cd7877034f4965c464e49"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/wbond/asn1crypto";
        license = licenses.mit;
        description = "Fast ASN.1 parser and serializer with definitions for private keys, public keys, certificates, CRL, OCSP, CMS, PKCS#3, PKCS#7, PKCS#8, PKCS#12, PKCS#5, X.509 and TSP";
      };
    };



    "astral" = python.mkDerivation {
      name = "astral-1.8";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/42/cb/6c5e5f6bca97a72002677166f3a0b98f7a45a6349f7db050e8fb38f2efce/astral-1.8.tar.gz"; sha256 = "7d624ccd09c591e56103f077733bc36194940076939875d84909d5086afd99c8"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pytz"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/sffjunkie/astral";
        license = "Apache-2.0";
        description = "Calculations for the position of the sun and moon.";
      };
    };



    "async-timeout" = python.mkDerivation {
      name = "async-timeout-3.0.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a1/78/aae1545aba6e87e23ecab8d212b58bb70e72164b67eb090b81bb17ad38e3/async-timeout-3.0.1.tar.gz"; sha256 = "0c3c816a028d47f659d6ff5c745cb2acf1f966da1fe5c19c77a70282b25f4c5f"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/aio-libs/async_timeout/";
        license = licenses.asl20;
        description = "Timeout context manager for asyncio programs";
      };
    };



    "attrs" = python.mkDerivation {
      name = "attrs-18.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/0f/9e/26b1d194aab960063b266170e53c39f73ea0d0d3f5ce23313e0ec8ee9bdf/attrs-18.2.0.tar.gz"; sha256 = "10cbf6e27dbce8c30807caf056c8eb50917e0eaafe86347671b57254006c3e69"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://www.attrs.org/";
        license = licenses.mit;
        description = "Classes Without Boilerplate";
      };
    };



    "bcrypt" = python.mkDerivation {
      name = "bcrypt-3.1.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/91/a5/fd19eac0252e56b4ce65ced937ae40024782c21108da7d830003b7f76cdb/bcrypt-3.1.5.tar.gz"; sha256 = "136243dc44e5bab9b61206bd46fff3018bd80980b1a1dfbab64a22ff5745957f"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."cffi"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pyca/bcrypt/";
        license = licenses.asl20;
        description = "Modern password hashing for your software and your servers";
      };
    };



    "certifi" = python.mkDerivation {
      name = "certifi-2018.11.29";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/55/54/3ce77783acba5979ce16674fc98b1920d00b01d337cfaaf5db22543505ed/certifi-2018.11.29.tar.gz"; sha256 = "47f9c83ef4c0c621eaef743f133f09fa8a74a9b75f037e8624f83bd1b6626cb7"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://certifi.io/";
        license = licenses.mpl20;
        description = "Python package for providing Mozilla's CA Bundle.";
      };
    };



    "cffi" = python.mkDerivation {
      name = "cffi-1.11.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e7/a7/4cd50e57cc6f436f1cc3a7e8fa700ff9b8b4d471620629074913e3735fb2/cffi-1.11.5.tar.gz"; sha256 = "e90f17980e6ab0f3c2f3730e56d1fe9bcba1891eeea58966e89d352492cc74f4"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pycparser"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://cffi.readthedocs.org";
        license = licenses.mit;
        description = "Foreign Function Interface for Python calling C code.";
      };
    };



    "chardet" = python.mkDerivation {
      name = "chardet-3.0.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d/chardet-3.0.4.tar.gz"; sha256 = "84ab92ed1c4d4f16916e05906b6b75a6c0fb5db821cc65e70cbd64a3e2a5eaae"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/chardet/chardet";
        license = licenses.lgpl2;
        description = "Universal encoding detector for Python 2 and 3";
      };
    };



    "colorlog" = python.mkDerivation {
      name = "colorlog-4.0.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fc/30/6ba1282b773e9f44d9cfaafa38b6cc180441307c5fe0edd8db13a8903e3f/colorlog-4.0.2.tar.gz"; sha256 = "3cf31b25cbc8f86ec01fef582ef3b840950dea414084ed19ab922c8b493f9b42"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/borntyping/python-colorlog";
        license = licenses.mit;
        description = "Log formatting with colors!";
      };
    };



    "cryptography" = python.mkDerivation {
      name = "cryptography-2.3.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/22/21/233e38f74188db94e8451ef6385754a98f3cad9b59bedf3a8e8b14988be4/cryptography-2.3.1.tar.gz"; sha256 = "8d10113ca826a4c29d5b85b2c4e045ffa8bad74fb525ee0eceb1d38d4c70dfd6"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."asn1crypto"
      self."cffi"
      self."idna"
      self."pytz"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pyca/cryptography";
        license = licenses.bsdOriginal;
        description = "cryptography is a package which provides cryptographic recipes and primitives to Python developers.";
      };
    };



    "denonavr" = python.mkDerivation {
      name = "denonavr-0.7.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/02/5c/8515cc6b493ea0adb8d6171505b198351ce26960650f484de0b379476da4/denonavr-0.7.7.tar.gz"; sha256 = "23b7a0cc6d699cfe894b6bb004f71554b17e49aae4b6d01a216d61482f947dd7"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."requests"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/scarface-4711/denonavr";
        license = licenses.bsdOriginal;
        description = "Automation Library for Denon AVR receivers";
      };
    };



    "distro" = python.mkDerivation {
      name = "distro-1.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ca/e3/78443d739d7efeea86cbbe0216511d29b2f5ca8dbf51a6f2898432738987/distro-1.4.0.tar.gz"; sha256 = "362dde65d846d23baee4b5c058c8586f219b5a54be1cf5fc6ff55c4578392f57"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/nir0s/distro";
        license = licenses.asl20;
        description = "Distro - an OS platform information API";
      };
    };



    "geojson" = python.mkDerivation {
      name = "geojson-2.4.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f8/92/3afac9986bb640dcc8736a69841435af32c8e8ae3d069da560927a4e5eb3/geojson-2.4.1.tar.gz"; sha256 = "b175e00a76d923d6e7409de0784c147adcdd6e04b311b1d405895a4db3612c9d"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/frewsxcv/python-geojson";
        license = licenses.bsdOriginal;
        description = "Python bindings and utilities for GeoJSON";
      };
    };



    "home-assistant-frontend" = python.mkDerivation {
      name = "home-assistant-frontend-20190203.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/dc/0a/fcc854654f94463f2f88f8044c1c364df1b0642afe188837aca83a3bf06d/home-assistant-frontend-20190203.0.tar.gz"; sha256 = "8f71a63e1c35ec088ed46e4529b30df7dd44f4968d84068306718c912d3a1410"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."user-agents"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/home-assistant/home-assistant-polymer";
        license = licenses.asl20;
        description = "The Home Assistant frontend";
      };
    };



    "homeassistant" = python.mkDerivation {
      name = "homeassistant-0.87.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/26/2b/429a250b3b9bafa8f5e65d526c50c7ef867cb33abef5c303e2a945e72e26/homeassistant-0.87.1.tar.gz"; sha256 = "f2ada4f0fe17587070cf4bf945e91f3c653501f11e94ea2b6ca2502d0d0b9a51"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Jinja2"
      self."PyJWT"
      self."PyYAML"
      self."aiohttp"
      self."astral"
      self."async-timeout"
      self."attrs"
      self."bcrypt"
      self."certifi"
      self."cryptography"
      self."python-slugify"
      self."pytz"
      self."requests"
      self."ruamel.yaml"
      self."voluptuous"
      self."voluptuous-serialize"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://home-assistant.io/";
        license = licenses.asl20;
        description = "Open-source home automation platform running on Python 3.";
      };
    };



    "httmock" = python.mkDerivation {
      name = "httmock-1.3.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/4e/17/0e25f808c3ff3b818923a346bf00882fa779489329306970092935c56741/httmock-1.3.0.tar.gz"; sha256 = "e0bbaced224426bcd994a5f1c64ab60e0c923ea615825c53e6c0190b2a7341fe"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."requests"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/patrys/httmock";
        license = "Copyright 2013 Patryk Zawadzki";
        description = "A mocking library for requests.";
      };
    };



    "idna" = python.mkDerivation {
      name = "idna-2.8";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ad/13/eb56951b6f7950cadb579ca166e448ba77f9d24efc03edd7e55fa57d04b7/idna-2.8.tar.gz"; sha256 = "c357b3f628cf53ae2c4c05627ecc484553142ca23264e593d327bcde5e9c3407"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/kjd/idna";
        license = licenses.bsdOriginal;
        description = "Internationalized Domain Names in Applications (IDNA)";
      };
    };



    "idna-ssl" = python.mkDerivation {
      name = "idna-ssl-1.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/46/03/07c4894aae38b0de52b52586b24bf189bb83e4ddabfe2e2c8f2419eec6f4/idna-ssl-1.1.0.tar.gz"; sha256 = "a933e3bb13da54383f9e8f35dc4f9cb9eb9b3b78c6b36f311254d6d0d92c6c7c"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."idna"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/aio-libs/idna-ssl";
        license = licenses.mit;
        description = "Patch ssl.match_hostname for Unicode(idna) domains support";
      };
    };



    "ifaddr" = python.mkDerivation {
      name = "ifaddr-0.1.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9f/54/d92bda685093ebc70e2057abfa83ef1b3fb0ae2b6357262a3e19dfe96bb8/ifaddr-0.1.6.tar.gz"; sha256 = "c19c64882a7ad51a394451dabcbbed72e98b5625ec1e79789924d5ea3e3ecb93"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pydron/ifaddr";
        license = "";
        description = "Enumerates all IP addresses on all network adapters of the system.";
      };
    };



    "influxdb" = python.mkDerivation {
      name = "influxdb-5.2.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/0a/a9/9dc769bf971ce8b1daf653a3c90339dbbd4d3c23fca57ac48ede26592b5d/influxdb-5.2.1.tar.gz"; sha256 = "75d96de25d0d4e9e66e155f64dc9dc2a48de74ac4e77e3a46ad881fba772e3b6"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."python-dateutil"
      self."pytz"
      self."requests"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/influxdb/influxdb-python";
        license = licenses.mit;
        description = "InfluxDB client";
      };
    };



    "luftdaten" = python.mkDerivation {
      name = "luftdaten-0.3.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/78/59/4f1640f70aba964d96ead2f6a564ff7dffcb89bff84cfac87b132002d851/luftdaten-0.3.4.tar.gz"; sha256 = "c298ea749ff4eec6a95e04023f9068d017acb02133f1fdcc38eb98e5ebc69442"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."aiohttp"
      self."async-timeout"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/fabaff/python-luftdaten";
        license = licenses.mit;
        description = "Python API for interacting with luftdaten.info.";
      };
    };



    "multidict" = python.mkDerivation {
      name = "multidict-4.5.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/7f/8f/b3c8c5b062309e854ce5b726fc101195fbaa881d306ffa5c2ba19efa3af2/multidict-4.5.2.tar.gz"; sha256 = "024b8129695a952ebd93373e45b5d341dbb87c17ce49637b34000093f243dd4f"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/aio-libs/multidict";
        license = licenses.asl20;
        description = "multidict implementation";
      };
    };



    "netdisco" = python.mkDerivation {
      name = "netdisco-2.3.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/51/a2/46b1b4e969ebd824cc55200e75b091faa19df2d5c378851122980a9fae71/netdisco-2.3.0.tar.gz"; sha256 = "2571fc094f3bf8c60be211e90474515f565f3ef1c92e857176daab8577493a3b"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."requests"
      self."zeroconf"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/home-assistant/netdisco";
        license = licenses.asl20;
        description = "Discover devices on your local network";
      };
    };



    "paho-mqtt" = python.mkDerivation {
      name = "paho-mqtt-1.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/25/63/db25e62979c2a716a74950c9ed658dce431b5cb01fde29eb6cba9489a904/paho-mqtt-1.4.0.tar.gz"; sha256 = "e440a052b46d222e184be3be38676378722072fcd4dfd2c8f509fb861a7b0b79"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://eclipse.org/paho";
        license = "License :: OSI Approved";
        description = "MQTT version 3.1.1 client class";
      };
    };



    "pycparser" = python.mkDerivation {
      name = "pycparser-2.19";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/68/9e/49196946aee219aead1290e00d1e7fdeab8567783e83e1b9ab5585e6206a/pycparser-2.19.tar.gz"; sha256 = "a988718abfad80b6b157acce7bf130a30876d27603738ac39f140993246b25b3"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/eliben/pycparser";
        license = licenses.bsdOriginal;
        description = "C parser in Python";
      };
    };



    "pyiss" = python.mkDerivation {
      name = "pyiss-1.0.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/64/70/f42b4f35ba02fe2c3a5cba75a2e6d72f2594a12cc774a3972be7b5bd9d32/pyiss-1.0.1.tar.gz"; sha256 = "0c745e7a518e6cd0c5814b2dd3ac846a63fd936e0601b10016d030556ddf2772"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."httmock"
      self."requests"
      self."voluptuous"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/HydrelioxGitHub/pyiss";
        license = licenses.mit;
        description = "A simple python3 library for info about the current International Space Station location";
      };
    };



    "pyotp" = python.mkDerivation {
      name = "pyotp-2.2.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b1/ab/477cda97b6ca7baced5106471cb1ac1fe698d1b035983b9f8ee3422989eb/pyotp-2.2.7.tar.gz"; sha256 = "be0ffeabddaa5ee53e7204e7740da842d070cf69168247a3d0c08541b84de602"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pyotp/pyotp";
        license = licenses.mit;
        description = "Python One Time Password Library";
      };
    };



    "pyowm" = python.mkDerivation {
      name = "pyowm-2.10.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a9/7b/c527a8acbadb90a323724d719cd137c906436c341071a963372583bbe3b0/pyowm-2.10.0.tar.gz"; sha256 = "8fd41a18536f4d6c432bc6d9ea69994efb1ea9b43688cf19523659b6f4d86cf7"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."geojson"
      self."requests"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/csparpa/pyowm";
        license = licenses.mit;
        description = "A Python wrapper around OpenWeatherMap web APIs";
      };
    };



    "python-dateutil" = python.mkDerivation {
      name = "python-dateutil-2.8.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ad/99/5b2e99737edeb28c71bcbec5b5dda19d0d9ef3ca3e92e3e925e7c0bb364c/python-dateutil-2.8.0.tar.gz"; sha256 = "c89805f6f4d64db21ed966fda138f8a5ed7a4fdbc1a8ee329ce1b74e3c74da9e"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://dateutil.readthedocs.io";
        license = licenses.bsdOriginal;
        description = "Extensions to the standard Python datetime module";
      };
    };



    "python-slugify" = python.mkDerivation {
      name = "python-slugify-1.2.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/00/ad/c778a6df614b6217c30fe80045b365bfa08b5dd3cb02e8b37a6d25126781/python-slugify-1.2.6.tar.gz"; sha256 = "7723daf30996db26573176bddcdf5fcb98f66dc70df05c9cb29f2c79b8193245"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Unidecode"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/un33k/python-slugify";
        license = licenses.mit;
        description = "A Python Slugify application that handles Unicode";
      };
    };



    "pytz" = python.mkDerivation {
      name = "pytz-2018.9";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/af/be/6c59e30e208a5f28da85751b93ec7b97e4612268bb054d0dff396e758a90/pytz-2018.9.tar.gz"; sha256 = "d5f05e487007e29e03409f9398d074e158d920d36eb82eaf66fb1136b0c5374c"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pythonhosted.org/pytz";
        license = licenses.mit;
        description = "World timezone definitions, modern and historical";
      };
    };



    "requests" = python.mkDerivation {
      name = "requests-2.21.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/52/2c/514e4ac25da2b08ca5a464c50463682126385c4272c18193876e91f4bc38/requests-2.21.0.tar.gz"; sha256 = "502a824f31acdacb3a35b6690b5fbf0bc41d63a24a45c4004352b0242707598e"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."certifi"
      self."chardet"
      self."cryptography"
      self."idna"
      self."urllib3"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://python-requests.org";
        license = licenses.asl20;
        description = "Python HTTP for Humans.";
      };
    };



    "ruamel.yaml" = python.mkDerivation {
      name = "ruamel.yaml-0.15.85";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/77/73/d7aa12dba105a2a6d18c2dfb18e643c259dfe2b9301b95079d823f6428ba/ruamel.yaml-0.15.85.tar.gz"; sha256 = "34af6e2f9787acd3937b55c0279f46adff43124c5d72dced84aab6c89d1a960f"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://bitbucket.org/ruamel/yaml";
        license = licenses.mit;
        description = "ruamel.yaml is a YAML parser/emitter that supports roundtrip preservation of comments, seq/map flow style, and map key order";
      };
    };



    "six" = python.mkDerivation {
      name = "six-1.12.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/dd/bf/4138e7bfb757de47d1f4b6994648ec67a51efe58fa907c1e11e350cddfca/six-1.12.0.tar.gz"; sha256 = "d16a0141ec1a18405cd4ce8b4613101da75da0e9a7aec5bdd4fa804d0e0eba73"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/benjaminp/six";
        license = licenses.mit;
        description = "Python 2 and 3 compatibility utilities";
      };
    };



    "typing-extensions" = python.mkDerivation {
      name = "typing-extensions-3.7.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fa/aa/229f5c82d17d10d4ef318b5c22a8626a1c78fc97f80d3307035cf696681b/typing_extensions-3.7.2.tar.gz"; sha256 = "fb2cd053238d33a8ec939190f30cfd736c00653a85a2919415cecf7dc3d9da71"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/python/typing/blob/master/typing_extensions/README.rst";
        license = licenses.psfl;
        description = "Backported and Experimental Type Hints for Python 3.5+";
      };
    };



    "ua-parser" = python.mkDerivation {
      name = "ua-parser-0.8.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b0/02/94ea43fc432fb112fbb62a89855317c41c210fb5239a2ed9b94ecb63024f/ua-parser-0.8.0.tar.gz"; sha256 = "97bbcfc9321a3151d96bb5d62e54270247b0e3be0590a6f2ff12329851718dcb"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/ua-parser/uap-python";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Python port of Browserscope's user agent parser";
      };
    };



    "urllib3" = python.mkDerivation {
      name = "urllib3-1.24.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b1/53/37d82ab391393565f2f831b8eedbffd57db5a718216f82f1a8b4d381a1c1/urllib3-1.24.1.tar.gz"; sha256 = "de9529817c93f27c8ccbfead6985011db27bd0ddfcdb2d86f3f663385c6a9c22"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."certifi"
      self."cryptography"
      self."idna"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://urllib3.readthedocs.io/";
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
        homepage = "https://github.com/selwin/python-user-agents";
        license = licenses.mit;
        description = "A library to identify devices (phones, tablets) and their capabilities by parsing (browser/HTTP) user agent strings";
      };
    };



    "voluptuous" = python.mkDerivation {
      name = "voluptuous-0.11.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/6e/5e/4e721e30cf175f9e11a5acccf4cd74898c32cae93580308ecd4cf7d2a454/voluptuous-0.11.5.tar.gz"; sha256 = "567a56286ef82a9d7ae0628c5842f65f516abcb496e74f3f59f1d7b28df314ef"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/alecthomas/voluptuous";
        license = licenses.bsdOriginal;
        description = "# Voluptuous is a Python data validation library";
      };
    };



    "voluptuous-serialize" = python.mkDerivation {
      name = "voluptuous-serialize-2.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/66/fd/c3e522ce5645686b9712d230e3599fca12bdf5f76b8176da26d19c3852db/voluptuous-serialize-2.0.0.tar.gz"; sha256 = "44be04d87aec34bd7d31ab539341fadc505205f2299031ed9be985112c21aa41"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."voluptuous"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/balloob/voluptuous-serialize";
        license = licenses.asl20;
        description = "Convert voluptuous schemas to dictionaries";
      };
    };



    "xmltodict" = python.mkDerivation {
      name = "xmltodict-0.11.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/57/17/a6acddc5f5993ea6eaf792b2e6c3be55e3e11f3b85206c818572585f61e1/xmltodict-0.11.0.tar.gz"; sha256 = "8f8d7d40aa28d83f4109a7e8aa86e67a4df202d9538be40c0cb1d70da527b0df"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/martinblech/xmltodict";
        license = licenses.mit;
        description = "Makes working with XML feel like you are working with JSON";
      };
    };



    "yarl" = python.mkDerivation {
      name = "yarl-1.3.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fb/84/6d82f6be218c50b547aa29d0315e430cf8a23c52064c92d0a8377d7b7357/yarl-1.3.0.tar.gz"; sha256 = "024ecdc12bc02b321bc66b41327f930d1c2c543fa9a561b39861da9388ba7aa9"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."idna"
      self."multidict"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/aio-libs/yarl/";
        license = licenses.asl20;
        description = "Yet another URL library";
      };
    };



    "zeroconf" = python.mkDerivation {
      name = "zeroconf-0.21.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9a/a3/9e4bb6a8e5f807c1a817168c9985f9d3975725a71ae77eb47ce1db66ada7/zeroconf-0.21.3.tar.gz"; sha256 = "5b52dfdf4e665d98a17bf9aa50dea7a8c98e25f972d9c1d7660e2b978a1f5713"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."ifaddr"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/jstasiak/python-zeroconf";
        license = licenses.lgpl2;
        description = "Pure Python Multicast DNS Service Discovery Library (Bonjour/Avahi compatible)";
      };
    };

  };
  localOverridesFile = ./requirements_override.nix;
  overrides = import localOverridesFile { inherit pkgs python; };
  commonOverrides = [

  ];
  allOverrides =
    (if (builtins.pathExists localOverridesFile)
     then [overrides] else [] ) ++ commonOverrides;

in python.withPackages
   (fix' (pkgs.lib.fold
            extends
            generated
            allOverrides
         )
   )