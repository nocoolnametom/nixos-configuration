{ pkgs, config, lib ? pkgs.lib, ... }: {
  programs.git.userEmail = "tom@nocoolnametom.com";
  home.packages = with pkgs; [ kitty ];

  services.insync.enable = true;
  services.my-kanshi.enable = true;
  services.my-mako.enable = true;
  services.my-spotifyd.enable = true;
  services.vdirsyncer.enable = true;

  fonts.fontconfig.enable = true
}