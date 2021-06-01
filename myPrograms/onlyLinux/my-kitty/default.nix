{ pkgs, config, lib, ... }:

with lib;

let cfg = config.programs.my-kitty;
in {
  options = {
    programs.my-kitty = {
      enable = mkOption {
        default = false;
        description = "Whether to enable my kitty config.";
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable { programs.kitty.enable = true; })
    (mkIf (cfg.enable && pkgs.hostName == "lappy") {
      programs.kitty.font = {
        package = pkgs.cascadia-code;
        name = "Cascadia Code 13";
      };
      programs.kitty.settings = {
        font_size = "8.0";
        cursor_stop_blinking_after = "15.0";
        mouse_hide_wait = "3.0";
        focus_follows_mouse = true;
        visual_bell_duration = "0.25";
        #hide_window_decorations = true;
        scrollback_lines = 50000;
        copy_on_select = true;
        strip_trailing_spaces = "smart";
        enable_audio_bell = false;
        window_alert_on_bell = true;
        shell = "zsh";
        editor = "vim";
        term = "xterm-256color";
        update_check_interval = 0;
        foreground = "#e5e9f0";
        selection_foreground = "#d8dee9";
        selection_background = "#4c566a";
        background = "#2e3440";
        background_opacity = "0.9";
        inactive_text_alpha = "0.9";

        # Jellybean colors
        #Black
        color0 = "#2e3440";
        color8 = "#434c5e";
        #Red
        color1 = "#d08770";
        color9 = "#bf616a";
        #Green
        color2 = "#8fbcbb";
        color10 = "#a3be8c";
        #Yellow
        color3 = "#ebcb8b";
        color11 = "#ebcb8b";
        #Blue
        color4 = "#88c0d0";
        color12 = "#81a1c1";
        #Magenta
        color5 = "#5e81ac";
        color13 = "#b48ead";
        #Cyan
        color6 = "#6eb5f3";
        color14 = "#8fbcbb";
        #White
        color7 = "#d8dee9";
        color15 = "#eceff4";
      };
      programs.kitty.keybindings = { };
      programs.kitty.extraConfig = "";
    })
  ];
}
