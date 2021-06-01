{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.networking;
  machines = lib.mapAttrsToList (name: v: name)
    (lib.filterAttrs (name: type: type == "directory") (builtins.readDir ./.));
in {
  config = mkMerge (builtins.map (machine:
    (mkIf ((toLower cfg.hostName) == machine)
      (import (./. + builtins.toPath ("/" + machine)) {
        inherit config lib pkgs;
      }))) machines);
}
