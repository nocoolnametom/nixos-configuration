{ pkgs ? import <nixpkgs> { }, ... }:

let nodePackages = pkgs.callPackage ./development/node-packages { };
in rec {
  inherit (nodePackages) intelephense coc-phpls bash-language-server;

  "@yaegassy/coc-intelephense" = nodePackages."@yaegassy/coc-intelephense";

  workVpn = pkgs.callPackage ./tools/misc/workVpn { };

  wakatime-zsh-plugin = pkgs.callPackage ./shells/zsh/wakatime-zsh-plugin { };

  myKhal = pkgs.callPackage ./applications/misc/khal {
    inherit (pkgs) lib stdenv python3 fetchpatch glibcLocales;
  };

  khal-events = pkgs.callPackage ./tools/misc/khal-events {
    inherit (pkgs) khal;
  };

  khal-events-json = pkgs.callPackage ./tools/misc/khal-events-json {
    inherit khal-events-plain;
  };

  khal-events-plain = pkgs.callPackage ./tools/misc/khal-events-plain {
    inherit (pkgs) khal;
  };

  khal-today = pkgs.callPackage ./tools/misc/khal-today {
    inherit (pkgs) khal;
    inherit khal-events;
  };

  blinkstick-alert-dbus-monitor =
    pkgs.callPackage ./tools/misc/blinkstick-alert-dbus-monitor { };

  playerctl-fast = pkgs.callPackage ./tools/misc/playerctl-fast { };
}
