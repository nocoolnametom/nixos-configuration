{ pkgs, config, lib ? pkgs.lib, ... }: {
  programs.git.userEmail = "tdoggett@zillowgroup.com";
  programs.mailcap.enable = true;
  programs.my-tuir.enable = true;
}
