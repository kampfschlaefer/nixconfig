# generated using pypi2nix tool (version: 2.0.0)
# See more at: https://github.com/garbas/pypi2nix
#
# COMMAND:
#   pypi2nix -r requirements.txt -V 3.6 -I /home/arnold/programme/nixconfig/ -E 'libffi openssl' --cache-dir __cache__/
#

{ pkgs ? import <nixpkgs> {},
  overrides ? ({ pkgs, python }: self: super: {})
}:

let

  inherit (pkgs) makeWrapper;
  inherit (pkgs.stdenv.lib) fix' extends inNixShell;

  pythonPackages =
  import "${toString pkgs.path}/pkgs/top-level/python-packages.nix" {
    inherit pkgs;
    inherit (pkgs) stdenv;
    python = pkgs.python36;
    # patching pip so it does not try to remove files when running nix-shell
    overrides =
      self: super: {
        bootstrapped-pip = super.bootstrapped-pip.overrideDerivation (old: {
          patchPhase = old.patchPhase + ''
            if [ -e $out/${pkgs.python36.sitePackages}/pip/req/req_install.py ]; then
              sed -i \
                -e "s|paths_to_remove.remove(auto_confirm)|#paths_to_remove.remove(auto_confirm)|"  \
                -e "s|self.uninstalled = paths_to_remove|#self.uninstalled = paths_to_remove|"  \
                $out/${pkgs.python36.sitePackages}/pip/req/req_install.py
            fi
          '';
        });
      };
  };

  commonBuildInputs = with pkgs; [ libffi openssl ];
  commonDoCheck = false;

  withPackages = pkgs':
    let
      pkgs = builtins.removeAttrs pkgs' ["__unfix__"];
      interpreterWithPackages = selectPkgsFn: pythonPackages.buildPythonPackage {
        name = "python36-interpreter";
        buildInputs = [ makeWrapper ] ++ (selectPkgsFn pkgs);
        buildCommand = ''
          mkdir -p $out/bin
          ln -s ${pythonPackages.python.interpreter} \
              $out/bin/${pythonPackages.python.executable}
          for dep in ${builtins.concatStringsSep " "
              (selectPkgsFn pkgs)}; do
            if [ -d "$dep/bin" ]; then
              for prog in "$dep/bin/"*; do
                if [ -x "$prog" ] && [ -f "$prog" ]; then
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
          ln -s ${pythonPackages.python.executable} \
              python3
          popd
        '';
        passthru.interpreter = pythonPackages.python;
      };

      interpreter = interpreterWithPackages builtins.attrValues;
    in {
      __old = pythonPackages;
      inherit interpreter;
      inherit interpreterWithPackages;
      mkDerivation = args: pythonPackages.buildPythonPackage (args // {
        nativeBuildInputs = (args.nativeBuildInputs or []) ++ args.buildInputs;
      });
      packages = pkgs;
      overrideDerivation = drv: f:
        pythonPackages.buildPythonPackage (
          drv.drvAttrs // f drv.drvAttrs // { meta = drv.meta; }
        );
      withPackages = pkgs'':
        withPackages (pkgs // pkgs'');
    };

  python = withPackages {};

  generated = self: {
    "Jinja2" = python.mkDerivation {
      name = "Jinja2-2.10.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/93/ea/d884a06f8c7f9b7afbc8138b762e80479fb17aedbbe2b06515a12de9378d/Jinja2-2.10.1.tar.gz";
        sha256 = "065c4f02ebe7f7cf559e49ee5a95fb800a9e4528727aec6f24402a5374c65013";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
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
      name = "MarkupSafe-1.1.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/b9/2e/64db92e53b86efccfaea71321f597fa2e1b2bd3853d8ce658568f7a13094/MarkupSafe-1.1.1.tar.gz";
        sha256 = "29872e92839765e546828bb7754a68c418d927cd064fd4708fab9fe9c8bb116b";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://palletsprojects.com/p/markupsafe/";
        license = "BSD-3-Clause";
        description = "Safely add untrusted strings to HTML/XML markup.";
      };
    };

    "PyJWT" = python.mkDerivation {
      name = "PyJWT-1.7.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/2f/38/ff37a24c0243c5f45f5798bd120c0f873eeed073994133c084e1cf13b95c/PyJWT-1.7.1.tar.gz";
        sha256 = "8d59a976fb773f3e6a39c85636357c4f0e242707394cadadd9814f5cbaa20e96";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."cryptography"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/jpadilla/pyjwt";
        license = "MIT";
        description = "JSON Web Token implementation in Python";
      };
    };

    "PyQRCode" = python.mkDerivation {
      name = "PyQRCode-1.2.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/37/61/f07226075c347897937d4086ef8e55f0a62ae535e28069884ac68d979316/PyQRCode-1.2.1.tar.gz";
        sha256 = "fdbf7634733e56b72e27f9bce46e4550b75a3a2c420414035cae9d9d26b234d5";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/mnooner256/pyqrcode";
        license = licenses.bsdOriginal;
        description = "A QR code generator written purely in Python with SVG, EPS, PNG and terminal output.";
      };
    };

    "PyYAML" = python.mkDerivation {
      name = "PyYAML-5.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/9f/2c/9417b5c774792634834e730932745bc09a7d36754ca00acf1ccd1ac2594d/PyYAML-5.1.tar.gz";
        sha256 = "436bc774ecf7c103814098159fbb84c2715d25980175292c648f2da143909f95";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/yaml/pyyaml";
        license = "MIT";
        description = "YAML parser and emitter for Python";
      };
    };

    "SQLAlchemy" = python.mkDerivation {
      name = "SQLAlchemy-1.3.5";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/62/3c/9dda60fd99dbdcbc6312c799a3ec9a261f95bc12f2874a35818f04db2dd9/SQLAlchemy-1.3.5.tar.gz";
        sha256 = "c30925d60af95443458ebd7525daf791f55762b106049ae71e18f8dd58084c2f";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.sqlalchemy.org";
        license = "MIT";
        description = "Database Abstraction Library";
      };
    };

    "Unidecode" = python.mkDerivation {
      name = "Unidecode-1.1.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/b1/d6/7e2a98e98c43cf11406de6097e2656d31559f788e9210326ce6544bd7d40/Unidecode-1.1.1.tar.gz";
        sha256 = "2b6aab710c2a1647e928e36d69c21e76b453cd455f4e2621000e54b2a9b8cce8";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "UNKNOWN";
        license = "GPL";
        description = "ASCII transliterations of Unicode text";
      };
    };

    "aioesphomeapi" = python.mkDerivation {
      name = "aioesphomeapi-2.2.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/ab/be/11f1d78b7a086798eb2c75b5587bcbb212ff5583da2b53218f292e9c3284/aioesphomeapi-2.2.0.tar.gz";
        sha256 = "c5f2caa5734bcb9c1268140da467fcff74c5f48ce00fba10638a981461a0ca7e";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."attrs"
        self."protobuf"
        self."zeroconf"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://esphome.io/";
        license = "UNKNOWN";
        description = "UNKNOWN";
      };
    };

    "aiohttp" = python.mkDerivation {
      name = "aiohttp-3.5.4";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/0f/58/c8b83f999da3b13e66249ea32f325be923791c0c10aee6cf16002a3effc1/aiohttp-3.5.4.tar.gz";
        sha256 = "9c4c83f4fa1938377da32bc2d59379025ceeee8e24b89f72fcbccd8ca22dc9bf";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
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
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/44/9e/6cdce7c3f346d8fd487adf68761728ad8cd5fbc296a7b07b92518350d31f/aiohttp-cors-0.7.0.tar.gz";
        sha256 = "4d39c6d7100fd9764ed1caf8cebf0eb01bf5e3f24e2e073fda6234bc48b19f5d";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
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
      name = "aiohue-1.9.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/02/5e/3a0e5a2824ac58bad818a61d86bc4a5b399b60eb282c9e43e2bd799173f9/aiohue-1.9.1.tar.gz";
        sha256 = "3c23aed8e82f398b732279f5f7ee7ed00949ff2db7009f7a2dc705f7c2d16783";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
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
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/fc/f1/8db7daa71f414ddabfa056c4ef792e1461ff655c2ae2928a2b675bfed6b4/asn1crypto-0.24.0.tar.gz";
        sha256 = "9d5c20441baf0cb60a4ac34cc447c6c189024b6b4c6cd7877034f4965c464e49";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/wbond/asn1crypto";
        license = "MIT";
        description = "Fast ASN.1 parser and serializer with definitions for private keys, public keys, certificates, CRL, OCSP, CMS, PKCS#3, PKCS#7, PKCS#8, PKCS#12, PKCS#5, X.509 and TSP";
      };
    };

    "astral" = python.mkDerivation {
      name = "astral-1.10.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/86/05/25c772065bb6384789ca0f6ecc9d0bdd0bc210064e5c78453ee15124082e/astral-1.10.1.tar.gz";
        sha256 = "d2a67243c4503131c856cafb1b1276de52a86e5b8a1d507b7e08bee51cb67bf1";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."pytz"
        self."requests"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/sffjunkie/astral";
        license = "Apache-2.0";
        description = "Calculations for the position of the sun and moon.";
      };
    };

    "async-timeout" = python.mkDerivation {
      name = "async-timeout-3.0.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/a1/78/aae1545aba6e87e23ecab8d212b58bb70e72164b67eb090b81bb17ad38e3/async-timeout-3.0.1.tar.gz";
        sha256 = "0c3c816a028d47f659d6ff5c745cb2acf1f966da1fe5c19c77a70282b25f4c5f";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/aio-libs/async_timeout/";
        license = licenses.asl20;
        description = "Timeout context manager for asyncio programs";
      };
    };

    "attrs" = python.mkDerivation {
      name = "attrs-19.1.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/cc/d9/931a24cc5394f19383fbbe3e1147a0291276afa43a0dc3ed0d6cd9fda813/attrs-19.1.0.tar.gz";
        sha256 = "f0b870f674851ecbfbbbd364d6b5cbdff9dcedbc7f3f5e18a6891057f21fe399";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://www.attrs.org/";
        license = "MIT";
        description = "Classes Without Boilerplate";
      };
    };

    "bcrypt" = python.mkDerivation {
      name = "bcrypt-3.1.6";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/ce/3a/3d540b9f5ee8d92ce757eebacf167b9deedb8e30aedec69a2a072b2399bb/bcrypt-3.1.6.tar.gz";
        sha256 = "44636759d222baa62806bbceb20e96f75a015a6381690d1bc2eda91c01ec02ea";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
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
      name = "certifi-2019.6.16";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/c5/67/5d0548226bcc34468e23a0333978f0e23d28d0b3f0c71a151aef9c3f7680/certifi-2019.6.16.tar.gz";
        sha256 = "945e3ba63a0b9f577b1395204e13c3a231f9bc0223888be653286534e5873695";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://certifi.io/";
        license = licenses.mpl20;
        description = "Python package for providing Mozilla's CA Bundle.";
      };
    };

    "cffi" = python.mkDerivation {
      name = "cffi-1.12.3";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/93/1a/ab8c62b5838722f29f3daffcc8d4bd61844aa9b5f437341cc890ceee483b/cffi-1.12.3.tar.gz";
        sha256 = "041c81822e9f84b1d9c401182e174996f0bae9991f33725d059b771744290774";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."pycparser"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://cffi.readthedocs.org";
        license = "MIT";
        description = "Foreign Function Interface for Python calling C code.";
      };
    };

    "chardet" = python.mkDerivation {
      name = "chardet-3.0.4";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d/chardet-3.0.4.tar.gz";
        sha256 = "84ab92ed1c4d4f16916e05906b6b75a6c0fb5db821cc65e70cbd64a3e2a5eaae";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/chardet/chardet";
        license = licenses.lgpl3;
        description = "Universal encoding detector for Python 2 and 3";
      };
    };

    "colorlog" = python.mkDerivation {
      name = "colorlog-4.0.2";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/fc/30/6ba1282b773e9f44d9cfaafa38b6cc180441307c5fe0edd8db13a8903e3f/colorlog-4.0.2.tar.gz";
        sha256 = "3cf31b25cbc8f86ec01fef582ef3b840950dea414084ed19ab922c8b493f9b42";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/borntyping/python-colorlog";
        license = "MIT License";
        description = "Log formatting with colors!";
      };
    };

    "cryptography" = python.mkDerivation {
      name = "cryptography-2.6.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/07/ca/bc827c5e55918ad223d59d299fff92f3563476c3b00d0a9157d9c0217449/cryptography-2.6.1.tar.gz";
        sha256 = "26c821cbeb683facb966045e2064303029d572a87ee69ca5a1bf54bf55f93ca6";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."asn1crypto"
        self."cffi"
        self."idna"
        self."six"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pyca/cryptography";
        license = licenses.bsdOriginal;
        description = "cryptography is a package which provides cryptographic recipes and primitives to Python developers.";
      };
    };

    "denonavr" = python.mkDerivation {
      name = "denonavr-0.7.9";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/ea/3b/d78b7436adb63d51aea7c286f9c002128db43bf151db41a22f6a2e2a6d82/denonavr-0.7.9.tar.gz";
        sha256 = "d31b5362a6487cf62d21eb663afaf301630b3372393452172c934caee970ad05";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."requests"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/scarface-4711/denonavr";
        license = "MIT";
        description = "Automation Library for Denon AVR receivers";
      };
    };

    "distro" = python.mkDerivation {
      name = "distro-1.4.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/ca/e3/78443d739d7efeea86cbbe0216511d29b2f5ca8dbf51a6f2898432738987/distro-1.4.0.tar.gz";
        sha256 = "362dde65d846d23baee4b5c058c8586f219b5a54be1cf5fc6ff55c4578392f57";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/nir0s/distro";
        license = licenses.asl20;
        description = "Distro - an OS platform information API";
      };
    };

    "geojson" = python.mkDerivation {
      name = "geojson-2.4.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/f8/92/3afac9986bb640dcc8736a69841435af32c8e8ae3d069da560927a4e5eb3/geojson-2.4.1.tar.gz";
        sha256 = "b175e00a76d923d6e7409de0784c147adcdd6e04b311b1d405895a4db3612c9d";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/frewsxcv/python-geojson";
        license = licenses.bsdOriginal;
        description = "Python bindings and utilities for GeoJSON";
      };
    };

    "holidays" = python.mkDerivation {
      name = "holidays-0.9.10";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/16/09/c882bee98acfa310933b654697405260ec7657c78430a14e785ef0f1314b/holidays-0.9.10.tar.gz";
        sha256 = "9f06d143eb708e8732230260636938f2f57114e94defd8fa2082408e0d422d6f";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."python-dateutil"
        self."six"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/dr-prodigy/python-holidays";
        license = "MIT";
        description = "Generate and work with holidays in Python";
      };
    };

    "home-assistant-frontend" = python.mkDerivation {
      name = "home-assistant-frontend-20190705.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/8e/1d/301707510838e64939f9b8dd6c27595828837029e0d23fe3d74878beaf58/home-assistant-frontend-20190705.0.tar.gz";
        sha256 = "5d8373227814c1db5b1be072dee1af4606ea44db213204b6406af281030f1c9e";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/home-assistant/home-assistant-polymer";
        license = licenses.asl20;
        description = "The Home Assistant frontend";
      };
    };

    "homeassistant" = python.mkDerivation {
      name = "homeassistant-0.95.4";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/59/af/afb9dfd4adfcc63a49ca7bcdcd1419f7377fd6acc0ca3aba8980c838c005/homeassistant-0.95.4.tar.gz";
        sha256 = "5be296d8186c279a073c52921d9bc5fa5a8847a3960d80f0faf0982689e07b20";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
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
        self."importlib-metadata"
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
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/4e/17/0e25f808c3ff3b818923a346bf00882fa779489329306970092935c56741/httmock-1.3.0.tar.gz";
        sha256 = "e0bbaced224426bcd994a5f1c64ab60e0c923ea615825c53e6c0190b2a7341fe";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
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
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/ad/13/eb56951b6f7950cadb579ca166e448ba77f9d24efc03edd7e55fa57d04b7/idna-2.8.tar.gz";
        sha256 = "c357b3f628cf53ae2c4c05627ecc484553142ca23264e593d327bcde5e9c3407";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/kjd/idna";
        license = licenses.bsdOriginal;
        description = "Internationalized Domain Names in Applications (IDNA)";
      };
    };

    "idna-ssl" = python.mkDerivation {
      name = "idna-ssl-1.1.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/46/03/07c4894aae38b0de52b52586b24bf189bb83e4ddabfe2e2c8f2419eec6f4/idna-ssl-1.1.0.tar.gz";
        sha256 = "a933e3bb13da54383f9e8f35dc4f9cb9eb9b3b78c6b36f311254d6d0d92c6c7c";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."idna"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/aio-libs/idna-ssl";
        license = "UNKNOWN";
        description = "Patch ssl.match_hostname for Unicode(idna) domains support";
      };
    };

    "ifaddr" = python.mkDerivation {
      name = "ifaddr-0.1.6";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/9f/54/d92bda685093ebc70e2057abfa83ef1b3fb0ae2b6357262a3e19dfe96bb8/ifaddr-0.1.6.tar.gz";
        sha256 = "c19c64882a7ad51a394451dabcbbed72e98b5625ec1e79789924d5ea3e3ecb93";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pydron/ifaddr";
        license = "UNKNOWN";
        description = "Enumerates all IP addresses on all network adapters of the system.";
      };
    };

    "importlib-metadata" = python.mkDerivation {
      name = "importlib-metadata-0.15";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/38/e1/f7c966af017f15701081641ab69f3b08949c0738a7c9ab582d0076187d25/importlib_metadata-0.15.tar.gz";
        sha256 = "027cfc6524613de726789072f95d2e4cc64dd1dee8096d42d13f2ead5bd302f5";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."zipp"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://importlib-metadata.readthedocs.io/";
        license = "Apache Software License";
        description = "Read metadata from Python packages";
      };
    };

    "influxdb" = python.mkDerivation {
      name = "influxdb-5.2.2";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/03/5e/d528d463bca6ff7fb9441df22d65890e39ebbb503e550c1030eef0863e52/influxdb-5.2.2.tar.gz";
        sha256 = "afeff28953a91b4ea1aebf9b5b8258a4488d0e49e2471db15ea43fd2c8533143";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."python-dateutil"
        self."pytz"
        self."requests"
        self."six"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/influxdb/influxdb-python";
        license = "MIT License";
        description = "InfluxDB client";
      };
    };

    "luftdaten" = python.mkDerivation {
      name = "luftdaten-0.6.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/19/af/9446d808c3987106d8986c59484bfd26469ce5516061a099323d1381886b/luftdaten-0.6.1.tar.gz";
        sha256 = "8f4fa021fc23301f97f7ac0872127aa985b902cf3226c34d13f6b5a59c4fb74b";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."aiohttp"
        self."async-timeout"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/fabaff/python-luftdaten";
        license = "MIT";
        description = "Python API for interacting with luftdaten.info.";
      };
    };

    "multidict" = python.mkDerivation {
      name = "multidict-4.5.2";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/7f/8f/b3c8c5b062309e854ce5b726fc101195fbaa881d306ffa5c2ba19efa3af2/multidict-4.5.2.tar.gz";
        sha256 = "024b8129695a952ebd93373e45b5d341dbb87c17ce49637b34000093f243dd4f";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/aio-libs/multidict";
        license = licenses.asl20;
        description = "multidict implementation";
      };
    };

    "netdisco" = python.mkDerivation {
      name = "netdisco-2.6.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/ae/73/2a60ac3292203ac75528b1ae9a475fac6fff690e906cbc13e744701b2436/netdisco-2.6.0.tar.gz";
        sha256 = "2b3aca14a1807712a053f11fd80dc251dd821ee4899aefece515287981817762";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
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
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/25/63/db25e62979c2a716a74950c9ed658dce431b5cb01fde29eb6cba9489a904/paho-mqtt-1.4.0.tar.gz";
        sha256 = "e440a052b46d222e184be3be38676378722072fcd4dfd2c8f509fb861a7b0b79";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://eclipse.org/paho";
        license = "Eclipse Public License v1.0 / Eclipse Distribution License v1.0";
        description = "MQTT version 3.1.1 client class";
      };
    };

    "protobuf" = python.mkDerivation {
      name = "protobuf-3.6.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/1b/90/f531329e628ff34aee79b0b9523196eb7b5b6b398f112bb0c03b24ab1973/protobuf-3.6.1.tar.gz";
        sha256 = "1489b376b0f364bcc6f89519718c057eb191d7ad6f1b395ffd93d1aa45587811";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."six"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://developers.google.com/protocol-buffers/";
        license = "3-Clause BSD License";
        description = "Protocol Buffers";
      };
    };

    "pycparser" = python.mkDerivation {
      name = "pycparser-2.19";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/68/9e/49196946aee219aead1290e00d1e7fdeab8567783e83e1b9ab5585e6206a/pycparser-2.19.tar.gz";
        sha256 = "a988718abfad80b6b157acce7bf130a30876d27603738ac39f140993246b25b3";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/eliben/pycparser";
        license = licenses.bsdOriginal;
        description = "C parser in Python";
      };
    };

    "pyhomematic" = python.mkDerivation {
      name = "pyhomematic-0.1.59";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/70/12/47d628be93a20cd4d89d4e9b868fcee46873068b77a6ff662d4c3a5879fe/pyhomematic-0.1.59.tar.gz";
        sha256 = "4406d9bf49d570ef0ba80be9cf8eb4bd75c08a2909369ebd90b8e94ff07f116e";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/danielperna84/pyhomematic";
        license = "MIT License";
        description = "Homematic interface";
      };
    };

    "pyiss" = python.mkDerivation {
      name = "pyiss-1.0.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/64/70/f42b4f35ba02fe2c3a5cba75a2e6d72f2594a12cc774a3972be7b5bd9d32/pyiss-1.0.1.tar.gz";
        sha256 = "0c745e7a518e6cd0c5814b2dd3ac846a63fd936e0601b10016d030556ddf2772";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."httmock"
        self."requests"
        self."voluptuous"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/HydrelioxGitHub/pyiss";
        license = "MIT";
        description = "A simple python3 library for info about the current International Space Station location";
      };
    };

    "pylaunches" = python.mkDerivation {
      name = "pylaunches-0.2.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/e0/97/d6c0c5f333667b728a4b77e0c1bbe8468b16c668991cbd1c1840b4b3bda8/pylaunches-0.2.0.tar.gz";
        sha256 = "cf8caa472170fc475cac256671a3ebc17e501874272ea8d63489f93c9104beed";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."aiohttp"
        self."async-timeout"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/ludeeus/pylaunches";
        license = "UNKNOWN";
        description = "UNKNOWN";
      };
    };

    "pyotp" = python.mkDerivation {
      name = "pyotp-2.2.7";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/b1/ab/477cda97b6ca7baced5106471cb1ac1fe698d1b035983b9f8ee3422989eb/pyotp-2.2.7.tar.gz";
        sha256 = "be0ffeabddaa5ee53e7204e7740da842d070cf69168247a3d0c08541b84de602";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pyotp/pyotp";
        license = "MIT License";
        description = "Python One Time Password Library";
      };
    };

    "pyowm" = python.mkDerivation {
      name = "pyowm-2.10.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/a9/7b/c527a8acbadb90a323724d719cd137c906436c341071a963372583bbe3b0/pyowm-2.10.0.tar.gz";
        sha256 = "8fd41a18536f4d6c432bc6d9ea69994efb1ea9b43688cf19523659b6f4d86cf7";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."geojson"
        self."requests"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/csparpa/pyowm";
        license = "MIT";
        description = "A Python wrapper around OpenWeatherMap web APIs";
      };
    };

    "python-dateutil" = python.mkDerivation {
      name = "python-dateutil-2.8.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/ad/99/5b2e99737edeb28c71bcbec5b5dda19d0d9ef3ca3e92e3e925e7c0bb364c/python-dateutil-2.8.0.tar.gz";
        sha256 = "c89805f6f4d64db21ed966fda138f8a5ed7a4fdbc1a8ee329ce1b74e3c74da9e";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."six"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://dateutil.readthedocs.io";
        license = "Dual License";
        description = "Extensions to the standard Python datetime module";
      };
    };

    "python-slugify" = python.mkDerivation {
      name = "python-slugify-3.0.2";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/c1/19/c3cf1dc65e89aa999f85a4a3a4924ccac765a6964b405d487b7b7c8bb39f/python-slugify-3.0.2.tar.gz";
        sha256 = "57163ffb345c7e26063435a27add1feae67fa821f1ef4b2f292c25847575d758";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."Unidecode"
        self."text-unidecode"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/un33k/python-slugify";
        license = "MIT";
        description = "A Python Slugify application that handles Unicode";
      };
    };

    "pytz" = python.mkDerivation {
      name = "pytz-2019.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/df/d5/3e3ff673e8f3096921b3f1b79ce04b832e0100b4741573154b72b756a681/pytz-2019.1.tar.gz";
        sha256 = "d747dd3d23d77ef44c6a3526e274af6efeb0a6f1afd5a69ba4d5be4098c8e141";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pythonhosted.org/pytz";
        license = "MIT";
        description = "World timezone definitions, modern and historical";
      };
    };

    "requests" = python.mkDerivation {
      name = "requests-2.22.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/01/62/ddcf76d1d19885e8579acb1b1df26a852b03472c0e46d2b959a714c90608/requests-2.22.0.tar.gz";
        sha256 = "11e007a8a2aa0323f5a921e9e6a2d7e4e67d9877e85773fba9ba6419025cbeb4";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
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
      name = "ruamel.yaml-0.15.97";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/52/f4/7cf7a8bb5d0ddb4311d6503caa3a7505deada47b346b696ddf1aabbb9b3b/ruamel.yaml-0.15.97.tar.gz";
        sha256 = "17dbf6b7362e7aee8494f7a0f5cffd44902a6331fe89ef0853b855a7930ab845";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://bitbucket.org/ruamel/yaml";
        license = "MIT license";
        description = "ruamel.yaml is a YAML parser/emitter that supports roundtrip preservation of comments, seq/map flow style, and map key order";
      };
    };

    "setuptools-scm" = python.mkDerivation {
      name = "setuptools-scm-3.3.3";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/83/44/53cad68ce686585d12222e6769682c4bdb9686808d2739671f9175e2938b/setuptools_scm-3.3.3.tar.gz";
        sha256 = "bd25e1fb5e4d603dcf490f1fde40fb4c595b357795674c3e5cb7f6217ab39ea5";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pypa/setuptools_scm/";
        license = "MIT";
        description = "the blessed package to manage your versions by scm tags";
      };
    };

    "six" = python.mkDerivation {
      name = "six-1.12.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/dd/bf/4138e7bfb757de47d1f4b6994648ec67a51efe58fa907c1e11e350cddfca/six-1.12.0.tar.gz";
        sha256 = "d16a0141ec1a18405cd4ce8b4613101da75da0e9a7aec5bdd4fa804d0e0eba73";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/benjaminp/six";
        license = "MIT";
        description = "Python 2 and 3 compatibility utilities";
      };
    };

    "text-unidecode" = python.mkDerivation {
      name = "text-unidecode-1.2";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/f0/a2/40adaae7cbdd007fb12777e550b5ce344b56189921b9f70f37084c021ca4/text-unidecode-1.2.tar.gz";
        sha256 = "5a1375bb2ba7968740508ae38d92e1f889a0832913cb1c447d5e2046061a396d";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/kmike/text-unidecode/";
        license = "Artistic License";
        description = "The most basic Text::Unidecode port";
      };
    };

    "typing-extensions" = python.mkDerivation {
      name = "typing-extensions-3.7.4";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/59/b6/21774b993eec6e797fbc49e53830df823b69a3cb62f94d36dfb497a0b65a/typing_extensions-3.7.4.tar.gz";
        sha256 = "2ed632b30bb54fc3941c382decfd0ee4148f5c591651c9272473fea2c6397d95";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/python/typing/blob/master/typing_extensions/README.rst";
        license = "PSF";
        description = "Backported and Experimental Type Hints for Python 3.5+";
      };
    };

    "ua-parser" = python.mkDerivation {
      name = "ua-parser-0.8.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/b0/02/94ea43fc432fb112fbb62a89855317c41c210fb5239a2ed9b94ecb63024f/ua-parser-0.8.0.tar.gz";
        sha256 = "97bbcfc9321a3151d96bb5d62e54270247b0e3be0590a6f2ff12329851718dcb";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/ua-parser/uap-python";
        license = "LICENSE.txt";
        description = "Python port of Browserscope's user agent parser";
      };
    };

    "urllib3" = python.mkDerivation {
      name = "urllib3-1.25.3";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/4c/13/2386233f7ee40aa8444b47f7463338f3cbdf00c316627558784e3f542f07/urllib3-1.25.3.tar.gz";
        sha256 = "dbe59173209418ae49d485b87d1681aefa36252ee85884c31346debd19463232";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."certifi"
        self."cryptography"
        self."idna"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://urllib3.readthedocs.io/";
        license = "MIT";
        description = "HTTP library with thread-safe connection pooling, file post, and more.";
      };
    };

    "user-agents" = python.mkDerivation {
      name = "user-agents-2.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/ef/b4/3ae0f6baeddc7264a3de3ebca9fe381d09ebed4ac14fb8510ac4b3d70197/user-agents-2.0.tar.gz";
        sha256 = "792869b990a244f71efea1cb410ecaba99a270a64c5ac37d365bde5d70d6a2fa";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."ua-parser"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/selwin/python-user-agents";
        license = "MIT";
        description = "A library to identify devices (phones, tablets) and their capabilities by parsing (browser/HTTP) user agent strings";
      };
    };

    "voluptuous" = python.mkDerivation {
      name = "voluptuous-0.11.5";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/6e/5e/4e721e30cf175f9e11a5acccf4cd74898c32cae93580308ecd4cf7d2a454/voluptuous-0.11.5.tar.gz";
        sha256 = "567a56286ef82a9d7ae0628c5842f65f516abcb496e74f3f59f1d7b28df314ef";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/alecthomas/voluptuous";
        license = licenses.bsdOriginal;
        description = "# Voluptuous is a Python data validation library";
      };
    };

    "voluptuous-serialize" = python.mkDerivation {
      name = "voluptuous-serialize-2.1.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/62/fb/ee79dabf3b425ac6b8efcef455f64ba29acd981bb286452feda46f3b87b5/voluptuous-serialize-2.1.0.tar.gz";
        sha256 = "d30fef4f1aba251414ec0b315df81a06da7bf35201dcfb1f6db5253d738a154f";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
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
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/57/17/a6acddc5f5993ea6eaf792b2e6c3be55e3e11f3b85206c818572585f61e1/xmltodict-0.11.0.tar.gz";
        sha256 = "8f8d7d40aa28d83f4109a7e8aa86e67a4df202d9538be40c0cb1d70da527b0df";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/martinblech/xmltodict";
        license = "MIT";
        description = "Makes working with XML feel like you are working with JSON";
      };
    };

    "yarl" = python.mkDerivation {
      name = "yarl-1.3.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/fb/84/6d82f6be218c50b547aa29d0315e430cf8a23c52064c92d0a8377d7b7357/yarl-1.3.0.tar.gz";
        sha256 = "024ecdc12bc02b321bc66b41327f930d1c2c543fa9a561b39861da9388ba7aa9";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
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
      name = "zeroconf-0.23.0";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/d7/25/8bbdd4857820e0cdc380c7e0c3543dc01a55247a1d831c712571783e74ec/zeroconf-0.23.0.tar.gz";
        sha256 = "e0c333b967c48f8b2e5cc94a1d4d28893023fb06dfd797ee384a94cdd1d0eef5";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [
        self."ifaddr"
      ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/jstasiak/python-zeroconf";
        license = licenses.lgpl3;
        description = "Pure Python Multicast DNS Service Discovery Library (Bonjour/Avahi compatible)";
      };
    };

    "zipp" = python.mkDerivation {
      name = "zipp-0.5.1";
      src = pkgs.fetchurl {
        url = "https://files.pythonhosted.org/packages/f9/c4/15a1260171956ed4f8190962b1771c7dbca4a39360c15f9c2b77e667a489/zipp-0.5.1.tar.gz";
        sha256 = "ca943a7e809cc12257001ccfb99e3563da9af99d52f261725e96dfe0f9275bc3";
};
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs ++ [ ];
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/jaraco/zipp";
        license = "UNKNOWN";
        description = "Backport of pathlib-compatible object wrapper for zip files";
      };
    };
  };
  localOverridesFile = ./requirements_override.nix;
  localOverrides = import localOverridesFile { inherit pkgs python; };
  commonOverrides = [
    
  ];
  paramOverrides = [
    (overrides { inherit pkgs python; })
  ];
  allOverrides =
    (if (builtins.pathExists localOverridesFile)
     then [localOverrides] else [] ) ++ commonOverrides ++ paramOverrides;

in python.withPackages
   (fix' (pkgs.lib.fold
            extends
            generated
            allOverrides
         )
   )