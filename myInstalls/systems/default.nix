{ pkgs, hostName ? pkgs.hostName, lib ? pkgs.lib, stdenv ? pkgs.stdenv, ... }:

(if (stdenv.isLinux && builtins.pathExists ./linux) then
  import ./linux { inherit pkgs; }
else
  [ ]) ++ (if (stdenv.isDarwin && builtins.pathExists ./darwin) then
    import ./darwin { inherit pkgs; }
  else
    [ ]) ++ (with pkgs; [
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
