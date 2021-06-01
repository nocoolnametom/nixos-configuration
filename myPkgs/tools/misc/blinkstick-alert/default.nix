{ pkgs ? import <nixpkgs> { }, ... }:

pkgs.writeShellScriptBin "blinkstick-alert" ''
  # Shell script to modify the BlinkStick cude at work to notify of new chat messages 
  if [ "$1" == "weechat" ]; then
    ${pkgs.python3Packages.BlinkStick}/bin/blinkstick --blink --repeats=5 --set-color="0000ff"
  fi
  if [ "$1" == "Slack" ]; then
    ${pkgs.python3Packages.BlinkStick}/bin/blinkstick --blink --repeats=10 --set-color="00ff00"
  fi
''
