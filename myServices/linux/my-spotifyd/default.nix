{ pkgs, config, lib, ... }:

with lib;

let cfg = config.services.my-spotifyd;

in {
  options = {
    services.my-spotifyd = {
      enable = mkOption {
        default = false;
        description = "Whether to enable my spotifyd config.";
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      services.spotifyd.enable = true;
      services.spotifyd.settings = {
        global = {
          username = "oey8uvlx90107ncq7chxkh504";
          password_cmd =
            "${pkgs.pass}/bin/pass Media/Spotify.com | ${pkgs.coreutils}/bin/head -1";
          device_name = "nix_${pkgs.hostName}";
          backend = "pulseaudio";
          device_type = "computer";
        };
      };
    })
    (mkIf (cfg.enable && pkgs.hostName == "lappy") {
      services.spotifyd.package = pkgs.spotifyd.override {
          withPulseAudio = true;
          withMpris = true;
          libpulseaudio = pkgs.libpulseaudio;
          dbus = pkgs.dbus;
        };
      services.spotifyd.settings.global.backend = "pulseaudio";
    })
  ];
}
