{ pkgs ? import <nixpkgs> { }, ... }:

rec {
  workVpn = pkgs.callPackage ./tools/misc/workVpn { };
  wakatime-zsh-plugin = pkgs.callPackage ./shells/zsh/wakatime-zsh-plugin { };
}
