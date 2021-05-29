{ pkgs ? import <nixpkgs> { }, ... }:

pkgs.writeShellScriptBin "khal-events" ''
  ATNOW=$(${pkgs.khal}/bin/khal at --format "{start-time}-{end-time} {title}" | ${pkgs.gnugrep}/bin/grep "^[^\-]" | ${pkgs.gnused}/bin/sed -e "s/$(${pkgs.coreutils}/bin/date +%F\ %I:%M\ %p)//" | ${pkgs.coreutils}/bin/tail -1);
  if [[ "" == $ATNOW ]]; then
    ATNOW="No events"
  fi
  UPNEXT=$(${pkgs.khal}/bin/khal list "now" "eod" -f "{start-time} {title}" --notstarted | ${pkgs.gnugrep}/bin/grep "^[^ ]" | ${pkgs.gnused}/bin/sed -e "s/^[0-9:]\+ \(AM\|PM\) //g" | ${pkgs.coreutils}/bin/head -2 | ${pkgs.coreutils}/bin/tail -1);
  TODAYMSG=$(${pkgs.coreutils}/bin/date +Today,\ %F);

  if [[ $UPNEXT == $TODAYMSG ]]; then
    UPNEXT="No events";
  fi

  if [[ $UPNEXT == "No events" ]]; then
    MINTUESUNTIL="$UPNEXT";
  else
    MINTUESUNTIL="$(( ($(${pkgs.coreutils}/bin/date +%s -d "today $(${pkgs.khal}/bin/khal list "now" "eod" -f "{start-time}" | ${pkgs.gnugrep}/bin/grep "^[^ ]" | ${pkgs.coreutils}/bin/head -2 | ${pkgs.coreutils}/bin/tail -1)") - $(${pkgs.coreutils}/bin/date +%s)) / 60 ))m till $UPNEXT";
  fi

  [[ $ATNOW == "No events" ]] && echo $MINTUESUNTIL || echo $ATNOW
''
