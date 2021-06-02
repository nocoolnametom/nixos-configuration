{ pkgs, hostName ? pkgs.hostName, lib ? pkgs.lib, ... }:

let hostFile = ./. + builtins.toPath ("/" + hostName);
in (lib.optionals (builtins.pathExists hostFile)
  (import hostFile { inherit pkgs; })) ++ (with pkgs; [
    # These packages will be installed in the user scope on ALL machines (maybe put them into the system scope?)
    ctags
    myGitRepos.personal_repos
    myGitRepos.personalgitclone
    myGitRepos.work_repos
    myGitRepos.zg_backup
    myGitRepos.zgitclone
    myPkgs.bash-language-server
    myPkgs.intelephense
    myPkgs.workVpn
    nixfmt
    nodejs-14_x
    pandoc
    sysstat
    unzip
    xdg-utils # xdg-utils provides automatic opening of applications, like firefox when a URL is clicked
  ])
