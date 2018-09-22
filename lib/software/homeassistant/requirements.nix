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
      name = "MarkupSafe-1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/4d/de/32d741db316d8fdb7680822dd37001ef7a448255de9699ab4bfcbdf4172b/MarkupSafe-1.0.tar.gz"; sha256 = "a6be69091dac236ea9c6bc7d012beab42010fa914c459791d627dad4910eb665"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/pallets/markupsafe";
        license = licenses.bsdOriginal;
        description = "Implements a XML/HTML/XHTML Markup safe string for Python";
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
      name = "SQLAlchemy-1.2.12";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/25/c9/b0552098cee325425a61efdf380c51b5c721e459081c85bbb860f501c091/SQLAlchemy-1.2.12.tar.gz"; sha256 = "c5951d9ef1d5404ed04bae5a16b60a0779087378928f997a294d1229c6ca4d3e"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.sqlalchemy.org";
        license = licenses.mit;
        description = "Database Abstraction Library";
      };
    };



    "aiohttp" = python.mkDerivation {
      name = "aiohttp-3.4.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/70/27/6098b4b60a3302a97f8ec97eb85d42f55a2fa904da4a369235a8e3b84352/aiohttp-3.4.4.tar.gz"; sha256 = "51afec6ffa50a9da4cdef188971a802beb1ca8e8edb40fa429e5e529db3475fa"; };
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
      name = "aiohue-1.7.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/10/4c/4c79aeebac5f53bf0dc72125b9e15fdf1020f84ac47e92b466ea68e2a536/aiohue-1.7.0.tar.gz"; sha256 = "26989babdc3f38575164b60b9536309271d58db005a03045b6e9cca4fc5201d8"; };
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
      name = "astral-1.6.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/cc/cc/65ca157e967756a8f08b1cf1c0a1a30c83ed32c50dbe83c557874ce101ca/astral-1.6.1.tar.gz"; sha256 = "ab0c08f2467d35fcaeb7bad15274743d3ac1ad18b5391f64a0058a9cd192d37d"; };
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
      name = "async-timeout-3.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/35/82/6c7975afd97661e6115eee5105359ee191a71ff3267fde081c7c8d05fae6/async-timeout-3.0.0.tar.gz"; sha256 = "b3c0ddc416736619bd4a95ca31de8da6920c3b9a140c64dbef2b2fa7bf521287"; };
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
      name = "bcrypt-3.1.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f3/ec/bb6b384b5134fd881b91b6aa3a88ccddaad0103857760711a5ab8c799358/bcrypt-3.1.4.tar.gz"; sha256 = "67ed1a374c9155ec0840214ce804616de49c3df9c5bc66740687c1c9b1cd9e8d"; };
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
      name = "certifi-2018.8.24";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e1/0f/f8d5e939184547b3bdc6128551b831a62832713aa98c2ccdf8c47ecc7f17/certifi-2018.8.24.tar.gz"; sha256 = "376690d6f16d32f9d1fe8932551d80b23e9d393a8578c5633a2ed39a64861638"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://certifi.io/";
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
      name = "colorlog-3.1.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/2c/a8/8ce4f59cf1fcbb9ebe750fcbab723146d95687c37256ed367a11d9f74265/colorlog-3.1.4.tar.gz"; sha256 = "418db638c9577f37f0fae4914074f395847a728158a011be2a193ac491b9779d"; };
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
      self."ipaddress"
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
      name = "denonavr-0.7.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/34/aa/d847a754290ae1cf35b308fc0a20beaa665343d612652ec76c8ea2fdbcf1/denonavr-0.7.5.tar.gz"; sha256 = "9946936113af851c10629fc32bc5f4901048be4a1eebdb679245ad4f7779d3bc"; };
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
      name = "distro-1.3.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d2/42/3b059929a920cd9d4e91e7a5e35f0d2ed75211f8f4e877be9d1bde9fdf46/distro-1.3.0.tar.gz"; sha256 = "224041cef9600e72d19ae41ba006e71c05c4dc802516da715d7fda55ba3d8742"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/nir0s/distro";
        license = licenses.asl20;
        description = "Distro - an OS platform information API";
      };
    };



    "home-assistant-frontend" = python.mkDerivation {
      name = "home-assistant-frontend-20180920.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/48/ee/535e6867da6f0f97d77489f3d3ce892ad1d2bef4b3015cdbbd9fab1f4456/home-assistant-frontend-20180920.0.tar.gz"; sha256 = "228e341c9b1668d0477710919c29ad4dc0a264f0f3e5270f21cb1b0c3546f3b9"; };
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
      name = "homeassistant-0.78.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f8/78/80a988a4655c09409eb8a9a3eedc5ff690c055652db810b6638fe2100f07/homeassistant-0.78.2.tar.gz"; sha256 = "925cc8afc016defac0032de35039d8e61d73e1e6e392316dd171021c63ff6592"; };
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
      self."pytz"
      self."requests"
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
      name = "httmock-1.2.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/7c/6d/85a552ccefdd4bfd4c628934baba8109c4647363a5536a9ff9b1463cf045/httmock-1.2.6.tar.gz"; sha256 = "4696306d1ff835c3ca865fdef2684d7e130b4120cc00126f862ba4797b1602ac"; };
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
      name = "idna-2.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/65/c4/80f97e9c9628f3cac9b98bfca0402ede54e0563b56482e3e6e45c43c4935/idna-2.7.tar.gz"; sha256 = "684a38a6f903c1d71d6d5fac066b58d7768af4de2b832e426ec79c30daa94a16"; };
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
      name = "ifaddr-0.1.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/12/40/97ef30db32e0c798fc557af403ea263dbeae8d334571603f02e19f4021a0/ifaddr-0.1.4.zip"; sha256 = "cf2a8fbb578da2844d999a0a453825f660ed2d3fc47dcffc5f673dd8de4f0f8b"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."ipaddress"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pydron/ifaddr";
        license = "";
        description = "Enumerates all IP addresses on all network adapters of the system.";
      };
    };



    "ipaddress" = python.mkDerivation {
      name = "ipaddress-1.0.22";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/97/8d/77b8cedcfbf93676148518036c6b1ce7f8e14bf07e95d7fd4ddcb8cc052f/ipaddress-1.0.22.tar.gz"; sha256 = "b146c751ea45cad6188dd6cf2d9b757f6f4f8d6ffb96a023e6f2e26eea02a72c"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/phihag/ipaddress";
        license = licenses.psfl;
        description = "IPv4/IPv6 manipulation library";
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
        homepage = "https://github.com/fabaff/python-luftdaten";
        license = licenses.mit;
        description = "Python API for interacting with luftdaten.info.";
      };
    };



    "multidict" = python.mkDerivation {
      name = "multidict-4.4.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b3/5f/5c29cde8511c95fad045b9ecaf2e76f0da18761e8363a82594f5a58c2ced/multidict-4.4.2.tar.gz"; sha256 = "3c11e92c3dfc321014e22fb442bc9eb70e01af30d6ce442026b0c35723448c66"; };
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
      name = "netdisco-2.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/73/96/c54725fe0180c7cf79d60fe204b34f4425083ffc74ad4d105e82d9c45e02/netdisco-2.1.0.tar.gz"; sha256 = "00da6b9565e781286cf3fbfa50489d4ddade091800a1bcdf9e48cd4db90659da"; };
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
      name = "pyotp-2.2.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/67/69/131f5ad63de40c30f3be88d891e4a2ea1b69398528db99bc1e5c543422fa/pyotp-2.2.6.tar.gz"; sha256 = "dd9130dd91a0340d89a0f06f887dbd76dd07fb95a8886dc4bc401239f2eebd69"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pyotp/pyotp";
        license = licenses.bsdOriginal;
        description = "Python One Time Password Library";
      };
    };



    "pytz" = python.mkDerivation {
      name = "pytz-2018.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ca/a9/62f96decb1e309d6300ebe7eee9acfd7bccaeedd693794437005b9067b44/pytz-2018.5.tar.gz"; sha256 = "ffb9ef1de172603304d9d2819af6f5ece76f2e85ec10692a524dd876e72bf277"; };
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
      name = "requests-2.19.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/54/1f/782a5734931ddf2e1494e4cd615a51ff98e1879cbe9eecbdfeaf09aa75e9/requests-2.19.1.tar.gz"; sha256 = "ec22d826a36ed72a7358ff3fe56cbd4ba69dd7a6718ffd450ff0e9df7a47ce6a"; };
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



    "six" = python.mkDerivation {
      name = "six-1.11.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/16/d8/bc6316cf98419719bd59c91742194c111b6f2e85abac88e496adefaf7afe/six-1.11.0.tar.gz"; sha256 = "70e8a77beed4562e7f14fe23a786b54f6296e34344c23bc42f07b15018ff98e9"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pypi.python.org/pypi/six/";
        license = licenses.mit;
        description = "Python 2 and 3 compatibility utilities";
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
      name = "urllib3-1.23";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/3c/d2/dc5471622bd200db1cd9319e02e71bc655e9ea27b8e0ce65fc69de0dac15/urllib3-1.23.tar.gz"; sha256 = "a68ac5e15e76e7e5dd2b8f94007233e01effe3e50e8daddf69acfd81cb686baf"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."certifi"
      self."cryptography"
      self."idna"
      self."ipaddress"
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
      name = "yarl-1.2.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/43/b8/057c3e5b546ff4b24263164ecda13f6962d85c9dc477fcc0bcdcb3adb658/yarl-1.2.6.tar.gz"; sha256 = "c8cbc21bbfa1dd7d5386d48cc814fe3d35b80f60299cdde9279046f399c3b0d8"; };
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