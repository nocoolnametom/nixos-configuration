{ pkgs, config, lib ? pkgs.lib, ... }: {
  programs.git.userEmail = "tdoggett@zillowgroup.com";
  programs.mailcap.enable = true;
  programs.my-i3status-rust.enable = true;
  programs.my-tuir.enable = true;

  services.davmail-config.enable = true;
  services.lorri.enable = true;
  services.nixos-configuration-sync.enable = true;
  services.password-store-sync.enable = true;
  services.pass-secret-service.enable = true;
  services.work-npm.enable = true;
}
