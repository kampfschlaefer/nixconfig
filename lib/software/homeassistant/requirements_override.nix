{ pkgs, python }:

self: super: {
  "ua-parser" = python.overrideDerivation super."ua-parser" (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ super."PyYAML" ];
  });
}