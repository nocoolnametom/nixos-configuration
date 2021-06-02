{ pkgs, config, lib ? pkgs.lib, ... }: {
  programs.git.userEmail = "tom@nocoolnametom.com";

  fonts.fontconfig.enable = true;

  gtk.enable = true;
  gtk.gtk3.extraConfig = { gtk-decoration-layout = "appmenu:none"; };

  programs.bash.enable = true;
  programs.feh.enable = true;
  programs.go.enable = true;
  programs.mailcap.enable = true;
  programs.my-i3status-rust.enable = true;
  programs.my-kitty.enable = true;
  programs.my-neomutt.enable = true;
  programs.my-newsboat.enable = true;
  programs.my-sway.enable = true;
  programs.my-tuir.enable = true;
  programs.zsh.enable = true;

  services.davmail-config.enable = true;
  services.gpg-agent.enable = true;
  services.insync.enable = true;
  services.kbfs.enable = true;
  services.kbfs.mountPoint = "keybase";
  services.keybase.enable = true;
  services.lorri.enable = true;
  services.mbsync.enable = true;
  services.my-kanshi.enable = true;
  services.my-mako.enable = true;
  services.my-spotifyd.enable = true;
  services.my-wlsunset.enable = true;
  services.nixos-configuration-sync.enable = true;
  services.pass-secret-service.enable = true;
  services.password-store-sync.enable = true;
  services.playerctld.enable = true;
  services.vdirsyncer.enable = true;
  services.work-npm.enable = true;

  systemd.user.startServices = true;
}
