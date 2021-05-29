{ pkgs, hostName ? pkgs.hostName, lib ? pkgs.lib, stdenv ? pkgs.stdenv, ... }:

let hostFile = ./. + builtins.toPath ("/by-name/" + hostName);
in (lib.optionals (builtins.pathExists hostFile)
  (import hostFile { inherit pkgs; }))
++ (lib.optionals (stdenv.isLinux && builtins.pathExists ./linux)
  (import ./linux { inherit pkgs; }))
++ (lib.optionals (stdenv.isDarwin && builtins.pathExists ./darwin)
  (import ./darwin { inherit pkgs; })) ++ (with pkgs; [
    # These packages are installed in all systems, darwin AND linux
    awscli
    curl
    direnv
    nixfmt
    silver-searcher
    tmux
    wget
    zsh
  ])
