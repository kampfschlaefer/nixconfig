{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (lib.overrideDerivation pwsafe (attrs: {
      name = "pwsafe-0.96";
      version = "0.96";
      src = fetchurl {
        url = "mirror://sourceforge/passwordsafe/pwsafe-0.96BETA-src.tgz";
        sha256 = "1205rgc064bxwbw14yjbjf0z3kkdbxa47c07q8jz3rs6fnxv17lq";
      };

      enableParallelBuilding = true;

      installPhase = ''
        mkdir -p $out/bin \
                 $out/share/applications \
                 $out/share/pwsafe/xml \
                 $out/share/icons/hicolor/48x48/apps \
                 $out/share/doc/passwordsafe/help \
                 $out/share/man/man1 \
                 $out/share/locale

        (cd help && make -f Makefile.linux)

        (cd src/ui/wxWidgets/I18N && make mos)
        cp -dr src/ui/wxWidgets/I18N/mos/* $out/share/locale/

        cp README.txt docs/ReleaseNotes.txt docs/ChangeLog.txt \
          LICENSE install/copyright $out/share/doc/passwordsafe

        cp src/ui/wxWidgets/GCCUnicodeRelease/pwsafe $out/bin/
        cp install/graphics/pwsafe.png $out/share/icons/hicolor/48x48/apps
        cp docs/pwsafe.1 $out/share/man/man1
        cp xml/* $out/share/pwsafe/xml
      '';
    }))
  ];
}
