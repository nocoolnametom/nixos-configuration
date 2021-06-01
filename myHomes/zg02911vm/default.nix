{ pkgs, config, lib ? pkgs.lib, ... }: {
  programs.git.userEmail = "tdoggett@zillowgroup.com";
  programs.my-i3status-rust.enable = true;
  programs.mailcap.enable = true;

  services.lorri.enable = true;
  services.nixos-configuration-sync.enable = true;
  services.password-store-sync.enable = true;
  services.pass-secret-service.enable = true;
}
