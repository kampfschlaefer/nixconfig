{ stdenv ? null, fetchurl ? null, ... }:

let
  pkgs = import ../../../nixpkgs {};
  mystdenv = if stdenv != null then stdenv else pkgs.stdenv;
  myfetchurl = if fetchurl != null then fetchurl else pkgs.fetchurl;

in
myfetchurl {
  url = https://github.com/blynkkk/blynk-server/releases/download/v0.20.1/server-0.20.1.jar;
  sha256 = "0rpbxf5vm41lhmwzjy028cm3519kaw9c6kg25bfd4hkshh37lqrk";
}