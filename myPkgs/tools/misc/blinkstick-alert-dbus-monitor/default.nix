{ pkgs ? import <nixpkgs> { }, blinkstick-alert-dbus-match ?
  pkgs.callPackage ../blinkstick-alert-dbus-match { }, ... }:

pkgs.writeShellScriptBin "blinkstick-alert-dbus-monitor" ''
  dbus-monitor "interface='org.freedesktop.Notifications'" \
    | grep --line-buffered "^\s*string" \
    | grep --line-buffered -e method -e ":" -e '""' -e urgency -e notify -v \
    | grep --line-buffered '.*(?=string)|(?<=string).*' -oPi \
    | grep --line-buffered -v '^\s*$' \
    | xargs -I '{}' ${blinkstick-alert-dbus-match}/bin/blinkstick-alert-dbus-match {}
''
