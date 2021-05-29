{ pkgs ? import <nixpkgs> { }, ... }:

let nodePackages = pkgs.callPackage ./development/node-packages { };
in rec {
  inherit (nodePackages) intelephense coc-phpls bash-language-server;

  "@yaegassy/coc-intelephense" = nodePackages."@yaegassy/coc-intelephense";

  workVpn = pkgs.callPackage ./tools/misc/workVpn { };

  wakatime-zsh-plugin = pkgs.callPackage ./shells/zsh/wakatime-zsh-plugin { };

  khal-events = pkgs.callPackage ./tools/misc/khal-events { };

  khal-events-json = pkgs.callPackage ./tools/misc/khal-events-json {
    inherit khal-events-plain;
  };

  khal-events-plain = pkgs.callPackage ./tools/misc/khal-events-plain { };

  khal-today =
    pkgs.callPackage ./tools/misc/khal-today { inherit khal-events; };
}
