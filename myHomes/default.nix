{ pkgs, lib ? pkgs.lib, hostName, ... }:

let
  machines = lib.mapAttrsToList (name: v: name)
    (lib.filterAttrs (name: type: type == "directory") (builtins.readDir ./.));
in builtins.concatMap (machine:
  lib.optionals (hostName == machine)
  [ (./. + builtins.toPath ("/" + machine)) ]) machines
