{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.password-store-sync;
in {
  options = {
    services.password-store-sync.enable =
      mkEnableOption "Password store periodic sync";

    services.password-store-sync.interval = mkOption {
      type = types.nullOr types.int;
      default = 300;
      example = literalExample "300";
      description =
        "How often in seconds to synchronise the password store git repository with its default upstream.";
    };
  };

  config = mkIf cfg.enable {

    launchd.user.agents.password-store-sync = {
      command = toString (pkgs.writeShellScript "password-store-sync" ''
        ${pkgs.pass}/bin/pass git pull --rebase && \
        ${pkgs.pass}/bin/pass git push
      '');
      serviceConfig.UserName = "tdoggett";
      serviceConfig.KeepAlive = false;
      serviceConfig.RunAtLoad = true;
      serviceConfig.StartInterval = cfg.interval;
    };

  };
}
