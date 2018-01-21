{ pkgs, python }:

self: super: {
  "homeassistant" = python.overrideDerivation super."homeassistant" (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [
      super."distro"
      super."paho-mqtt"
      super."phue"
      super."home-assistant-frontend"
      super."colorlog"
      super."luftdaten"
    ];
  });
  "home-assistant-frontend" = python.overrideDerivation super."home-assistant-frontend" (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ super."user-agents" ];
  });
  "ua-parser" = python.overrideDerivation super."ua-parser" (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ super."PyYAML" ];
  });
}