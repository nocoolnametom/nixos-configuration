{ pkgs ? import <nixpkgs> { }
, blinkstick-alert ? pkgs.callPackage ../blinkstick-alert { }, ... }:

pkgs.writeShellScriptBin "blinkstick-alert-dbus-match" ''
  string=$1
  if [[ $string == "Slack" ]]; then
    ${blinkstick-alert}/bin/blinkstick-alert $string
  fi
''
