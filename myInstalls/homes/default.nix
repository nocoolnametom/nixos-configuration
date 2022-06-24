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
    # myPkgs.bash-language-server # Causing failures when built
    # myPkgs.intelephense # Causing failures when built
    myPkgs.workVpn
    nixfmt
    nodejs-16_x
    pandoc
    rsync
    unzip
    xdg-utils # xdg-utils provides automatic opening of applications, like firefox when a URL is clicked
  ])
