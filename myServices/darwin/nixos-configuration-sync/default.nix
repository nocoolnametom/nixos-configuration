{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.nixos-configuration-sync;
in {
  options = {
    services.nixos-configuration-sync.enable =
      mkEnableOption "Nixos-configuration repo periodic sync";

    services.nixos-configuration-sync.interval = mkOption {
      type = types.str;
      default = "600";
      example = literalExample "600";
      description =
        "How often in seconds to synchronise the nixos-configuration git repository with its default upstream.";
    };
  };

  config = mkIf cfg.enable {

    launchd.user.agents.nixos-configuration-sync = {
      command = toString (pkgs.writeShellScript "nixos-configuration-sync" ''
        ${pkgs.git}/bin/git pull --rebase -C /User/tdoggett/Projects/nocoolnametom/nixos-configuration && \
        ${pkgs.git}/bin/git push -C /User/tdoggett/Projects/nocoolnametom/nixos-configuration
      '');
      serviceConfig.UserName = "tdoggett";
      serviceConfig.KeepAlive = false;
      serviceConfig.RunAtLoad = true;
      serviceConfig.StartInterval = lib.toInt cfg.interval;
    };

  };
}
