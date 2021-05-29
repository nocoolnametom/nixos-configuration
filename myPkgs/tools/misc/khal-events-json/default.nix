{ pkgs ? import <nixpkgs> { }
, khal-events-plain ? pkgs.callPackage ../khal-events-plain { }, ... }:

pkgs.writeShellScriptBin "khal-events-json" ''
   json_escape () {
     printf '%s' "$1" | python -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
  }

   MINUTES=`${khal-events-plain}/bin/khal-events-plain | sed "s/^\([^ ]\+\) .*/\1/g"`
   EVENT=`${khal-events-plain}/bin/khal-events-plain | sed "s/^[^ ]\+ \(.*\)/\1/g" | ${pkgs.jq}/bin/jq -aR . | sed "s/^\"//g" | sed "s/\"$//g"`
   TEXT="–${"$"}{MINUTES}m ⭲ $EVENT"

   if [[ $MINUTES == "-1" ]]; then
     # IDLE - No more events today
     STATE=Idle
     ICON=
     TEXT=
   elif [[ $MINUTES == "0" ]]; then
     # GOOD - Event currently happening
     STATE=Good
     ICON=calendar
     TEXT="$EVENT"
   elif [[ $MINUTES -lt 6 ]]; then
     # CRITICAL - Five minutes before
     STATE=Critical
     ICON=calendar
   elif [[ $MINUTES -lt 16 ]]; then
     # WARNING - Fifteen minutes before
     STATE=Warning
     ICON=calendar
   elif [[ $MINUTES -lt 61 ]]; then
     # WARNING - One hour before
     STATE=Warning
     ICON=calendar
   else
     # INFO - More than one hour before
     STATE=Idle
     ICON=calendar
   fi;

   echo "{\"icon\": \"$ICON\", \"state\":  \"$STATE\", \"text\": \"$TEXT\"}";
''
