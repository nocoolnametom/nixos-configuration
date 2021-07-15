{ pkgs ? import <nixpkgs> { }, khal ? pkgs.khal, khal-events ? pkgs.callPackage ../khal-events { }
, ... }:

pkgs.writeShellScriptBin "khal-today" ''
  SECONDS=$((60 - $(${pkgs.coreutils}/bin/date +%S)))
  while [ : ]
  do
    clear
    ${khal-events}/bin/khal-events
    echo ""
    ${khal}/bin/khal list "`${pkgs.coreutils}/bin/date +%F\ %I:%M\ %p`" "`${pkgs.coreutils}/bin/date --date='tomorrow' +%Y-%m-%d\ 11:59\ PM`" -f "{start-time}-{end-time} {title}" --notstarted
    ${pkgs.coreutils}/bin/sleep $SECONDS
    SECONDS=60
  done
''
