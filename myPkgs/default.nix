{ pkgs ? import <nixpkgs> { }, ... }:

let
  nodePackages = pkgs.callPackage ./development/node-packages { };
in rec {
  inherit (nodePackages) intelephense coc-phpls "@yaegassy/coc-intelephense" bash-language-server;
  workVpn = pkgs.callPackage ./tools/misc/workVpn { };
  wakatime-zsh-plugin = pkgs.callPackage ./shells/zsh/wakatime-zsh-plugin { };
}
