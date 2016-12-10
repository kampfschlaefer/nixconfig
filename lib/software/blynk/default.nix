{ stdenv ? null, fetchurl ? null, ... }:

let
  pkgs = import ../../../nixpkgs {};
  mystdenv = if stdenv != null then stdenv else pkgs.stdenv;
  myfetchurl = if fetchurl != null then fetchurl else pkgs.fetchurl;

in
myfetchurl {
  url = https://github.com/blynkkk/blynk-server/releases/download/v0.20.1/server-0.20.1.jar;
  sha256 = "40242b47aa61eeba880181ba4191ff8b37c6c2c82d951e398d3a920c91b00954";
}