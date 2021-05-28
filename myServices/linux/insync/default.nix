{ pkgs ? import <nixpkgs> { }, config ? pkgs.config, lib ? pkgs.lib, ... }:

with lib;

let cfg = config.services.insync;
in {
  options = {
    services.insync = {
      enable = mkOption {
        default = false;
        description = ''
          Whether to enable the insync headless daemon
        '';
      };
      package = mkOption {
        type = lib.types.package;
        default = pkgs.insync;
        defaultText = literalExample "${pkgs.insync}";
        description = ''
          Insync package to use.
        '';
      };
    };
  };
  config = mkIf cfg.enable ({
    home.packages = [ cfg.package ];
    systemd.user.services.insync = {
      Unit = {
        Description = "Insync";
        After = [ "local-fs.target" "network.target" ];
      };
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${cfg.package}/bin/insync start";
        ExecStop = "${cfg.package}/bin/insync quit";
      };
      Install = { WantedBy = [ "default.target" ]; };
    };
  });
}
