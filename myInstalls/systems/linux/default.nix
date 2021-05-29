{ pkgs, ... }: with pkgs; [
  rsync
  screen
  unzip
  gnumake
  glibcLocales
  gitAndTools.gitFull
  gitAndTools.git-extras
]