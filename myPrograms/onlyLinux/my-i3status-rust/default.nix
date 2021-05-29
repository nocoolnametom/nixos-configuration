{ pkgs, config ? pkgs.config, lib ? pkgs.lib, ... }:

with lib;

let cfg = config.programs.my-i3status-rust;
in {
  options = {
    programs.my-i3status-rust = {
      enable = mkOption {
        default = false;
        description = ''
          Whether to enable the i3status-rust configuration
        '';
      };
    };
  };
  config = mkMerge [
    (mkIf (cfg.enable && lib.hasAttrByPath ["i3status-rust"] config.programs) {
      programs.i3status-rust = {
        enable = true;
      };
    })
    (mkIf (cfg.enable && lib.hasAttrByPath ["i3status-rust"] config.programs && pkgs.hostName == "lappy") {
      programs.i3status-rust.bars = {
        top = {
          icons = "awesome5";
          theme = "slickq";
          blocks = [
            {
              # Upcoming Events
              block = "custom";
              command = "${pkgs.myPkgs.khal-events-json}/bin/khal-events-json";
              json = true;
              interval = 30;
              hide_when_empty = true;
            }
            {
              block = "focused_window";
              max_width = 50;
              show_marks = "visible";
            }
            {
              block = "pomodoro";
              length = 45;
              break_length = 5;
              use_nag = true;
              nag_path = "${pkgs.sway}/bin/swaynag";
            }
            {
              # WH-1000XM4 Headphones
              block = "bluetooth";
              mac = "94:DB:56:F7:B2:38";
              hide_disconnected = true;
            }
            {
              block = "sound";
            }
            {
              block = "keyboard_layout";
              driver = "sway";
            }
            {
              block = "maildir";
              interval = 60;
              inboxes = ["${config.home.homeDirectory}/Mail/protonmail/Inbox" "${config.home.homeDirectory}/Mail/work/Inbox"];
              threshold_warning = 1;
              threshold_critical = 10;
              display_type = "new";
            }
            {
              block = "time";
              interval = 60;
              format = "%a %d/%m %R";
            }
            {
              block = "battery";
              driver = "upower";
              allow_missing = true;
              hide_missing = true;
            }
          ];
        };
      };
    })
  ];
}