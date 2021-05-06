{ pkgs, lib ? pkgs.lib, ... }:
let
  shells = lib.mapAttrs' (name: v: (lib.nameValuePair name (./. + "/${name}")))
    (lib.filterAttrs (name: type: type == "directory") (builtins.readDir ./.));
in shells
