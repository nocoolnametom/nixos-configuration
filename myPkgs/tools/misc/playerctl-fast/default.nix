{ pkgs ? import <nixpkgs> { }, ... }:

pkgs.writeShellScriptBin "playerctl-fast" ''
  set -euo pipefail

  case "${"$"}{1:-}" in
    next)
      MEMBER=Next
      ;;

    previous)
      MEMBER=Previous
      ;;

    play)
      MEMBER=Play
      ;;

    pause)
      MEMBER=Pause
      ;;

    play-pause)
      MEMBER=PlayPause
      ;;

    *)
      echo "Usage: $0 next|previous|play|pause|play-pause"
      exit 1
      ;;

  esac

  exec ${pkgs.dbus}/bin/dbus-send                                                     \
    --print-reply                                                                     \
    --dest="org.mpris.MediaPlayer2.$(${pkgs.playerctl}/bin/playerctl -l | head -n 1)" \
    /org/mpris/MediaPlayer2                                                           \
    "org.mpris.MediaPlayer2.Player.$MEMBER"
''
