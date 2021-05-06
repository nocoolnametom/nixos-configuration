{ pkgs, ... }: {
  services.lorri.enable = true;
  services.password-store-sync.enable = true;
  services.pass-secret-service.enable = true;
}
