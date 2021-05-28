# Remember to symlink this into the expected location!
# `ln -s <absolute path to this file> ~/.nixpkgs/darwin-configuration.nix

{ config, pkgs, options, lib ? pkgs.lib, ... }:

let
  workInfo = if pkgs.lib.pathExists ./workInfo.nix then
    (import ./workInfo.nix { inherit pkgs lib; })
  else
    (import ./workInfo_example.nix { inherit pkgs lib; });
in {
  imports =
    [ <home-manager/nix-darwin> ./overlays-import.nix ./myServices/darwin ]
    ++ (lib.optionals (lib.pathExists ./configuration.nix)
      [ ./configuration.nix ]);

  environment.variables = { EDITOR = "vim"; };

  programs.zsh.interactiveShellInit = ''
    # Reload environment variables
    if test -f /etc/zshenv; then
      source /etc/zshenv
    fi
  '';

  nixpkgs.overlays = import ./overlays.nix ++ [
    (self: super: {
      hostName = config.networking.hostName;
    })
  ];

  # List packages installed in system profile. To search by name, run: $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.awscli
    pkgs.curl
    pkgs.direnv
    pkgs.pinentry_mac
    pkgs.nixfmt
    pkgs.myGitRepos.zgitclone
    pkgs.myGitRepos.work_repos
    pkgs.silver-searcher
    pkgs.tmux
  ];
  environment.variables = {
    HOME = "/Users/tdoggett";
    PAGER = "less -R";
    EDTIOR = "vim";
  };
  environment.shellAliases = {
    hm = "home-manager";
    rm = "rm -i";
    cp = "cp -i";
    ls = "ls -G";
  };

  # Scripts to be run after activating a generation for a user
  system.activationScripts.extraUserActivation.text =
    let home = builtins.getEnv "HOME";
    in "";

  # Home Manager
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.tdoggett = import ./home.dist.nix {
    inherit pkgs config;
    hostName = lib.toLower config.networking.hostName;
    isModule = true;
    isDarwin = true;
  };

  # Use a custom configuration.nix location. $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # MacOS Settings
  system.defaults.finder.AppleShowAllExtensions = true;
  system.defaults.dock.autohide = true;
  system.defaults.dock.orientation = "left";
  system.defaults.dock.showhidden = true;
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  # Computer Host Name
  networking.hostName = "ZG02911";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  # Enable lorri daemon
  services.lorri.enable = true;

  # GnuPG
  programs.gnupg.agent.enable = true;

  services.password-store-sync.enable = true;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing. $ darwin-rebuild changelog
  system.stateVersion = 4;
}
