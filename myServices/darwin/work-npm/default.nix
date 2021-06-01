{ config, lib ? pkgs.lib, pkgs, ... }:

with lib;

let
  npmRc = ''
    prefix=~/.npm
    @premieragent:registry=https://${pkgs.workInfo.npmRegistryUrl}/
    //${pkgs.workInfo.npmRegistryUrl}/:always-auth=true
  '';
  syncScript = pkgs.writeShellScript "npmrc-immutable-copy" ''
    [[ -e .npmrc.immutable ]] \
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
    launchd.user.agents.work-npm-immutable = {
      WorkingDirectory = "/Users/tdoggett";
      command = "${syncScript}";
      serviceConfig.UserName = "tdoggett";
      serviceConfig.KeepAlive = false;
      serviceConfig.RunAtLoad = true;
    };
  };
}
