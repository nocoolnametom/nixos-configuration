{ config, lib, pkgs, ... }:

with lib;

let cfg = config.networking;

in {

  # This loads the machine configuration files based on the declared hostname
  config = mkMerge [
    (mkIf ((toLower cfg.hostName) == "zg02911vm")
      (import ./zg02911vm { inherit config lib pkgs; }))
    (mkIf ((toLower cfg.hostName) == "lappy")
      (import ./lappy { inherit config lib pkgs; }))
  ];
}
