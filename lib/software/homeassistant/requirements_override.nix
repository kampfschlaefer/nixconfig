{ pkgs, python }:

self: super: with pkgs.python36Packages; {
  "homeassistant" = python.overrideDerivation super."homeassistant" (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [
      super.distro
      super.paho-mqtt
      super.aiohue
      super.home-assistant-frontend
      super.colorlog
      super.luftdaten
      super.pyotp
    ];
    patches = [
      ./scan_interval.patch
    ];
  });
  "home-assistant-frontend" = python.overrideDerivation super."home-assistant-frontend" (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ super."user-agents" ];
  });
  "ua-parser" = python.overrideDerivation super."ua-parser" (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ super."PyYAML" ];
  });
}