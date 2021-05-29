{ pkgs, hostName ? pkgs.hostName, lib ? pkgs.lib, ... }:

let hostFile = ./. + builtins.toPath ("/" + hostName);
in (lib.optionals (builtins.pathExists hostFile)
  (import hostFile { inherit pkgs; })) ++ (with pkgs; [
    # These packages will be installed in the user scope on ALL machines (maybe put them into the system scope?)
    myGitRepos.zg_backup
    myGitRepos.zgitclone
    myGitRepos.work_repos
    myGitRepos.personalgitclone
    myGitRepos.personal_repos
    myPkgs.workVpn
    myPkgs.intelephense
    myPkgs.bash-language-server
    ctags
    nodejs-14_x
  ])
