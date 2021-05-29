{ pkgs, config, lib ? pkgs.lib, ... }: {
  programs.git.userEmail = "tdoggett@zillowgroup.com";
  home.packages = with pkgs; [ kitty ];
}
