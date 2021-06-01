{ config, lib ? pkgs.lib, pkgs, ... }:

with lib;

let
  npmRc = ''
    prefix=~/.npm
    @premieragent:registry=https://${pkgs.workInfo.npmRegistryUrl}/
    //${pkgs.workInfo.npmRegistryUrl}/:always-auth=true
  '';
  syncScript = pkgs.writeShellScript "npmrc-immutable-copy" ''
    ${pkgs.coreutils}/bin/touch .npmrc \
      && $(${pkgs.gnugrep}/bin/grep -v -x -f .npmrc.immutable .npmrc > .npmrcnew || ${pkgs.coreutils}/bin/touch .npmrcnew) \
      && ${pkgs.coreutils}/bin/cat .npmrc.immutable > .npmrc \
      && ${pkgs.coreutils}/bin/cat .npmrcnew >> .npmrc \
      && ${pkgs.coreutils}/bin/rm -f .npmrcnew \
      && ${pkgs.coreutils}/bin/chmod 777 .npmrc \
      && ${pkgs.coreutils}/bin/chown tdoggett:tdoggett .npmrc \
      && exit 0
  '';
in {
  options = {
    services.work-npm = {
      enable = mkEnableOption "Whether to enable work npmrc configuration";
    };
  };

  config = mkIf config.services.work-npm.enable {
    home.file.".npmrc.immutable".text = npmRc;

    systemd.user.services.work-npm-immutable = {
      Unit = {
        Description =
          "Allowing for immutable npmrc config file with login state values";
        ConditionPathExists = "/home/tdoggett/.npmrc.immutable";
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit = false;
        WorkingDirectory = "/home/tdoggett";
        ExecStart = "${syncScript}";
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
