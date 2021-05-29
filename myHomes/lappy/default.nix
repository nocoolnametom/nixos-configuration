{ pkgs, config, lib ? pkgs.lib, ... }: {
  programs.git.userEmail = "tom@nocoolnametom.com";

  fonts.fontconfig.enable = true;

  programs.my-i3status-rust.enable = true;

  services.insync.enable = true;
  services.lorri.enable = true;
  services.my-kanshi.enable = true;
  services.my-mako.enable = true;
  services.my-spotifyd.enable = true;
  services.pass-secret-service.enable = true;
  services.password-store-sync.enable = true;
  services.vdirsyncer.enable = true;
}
