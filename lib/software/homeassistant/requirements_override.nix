{ pkgs, python }:

self: super: with pkgs.python36Packages; {
  "homeassistant" = python.overrideDerivation super."homeassistant" (old: {
    /* propagatedBuildInputs = old.propagatedBuildInputs ++ [
    ]; */
    patches = [
      ./pytz_dependency.patch
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