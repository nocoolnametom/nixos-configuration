{ pkgs, lib ? pkgs.lib, config, ... }: {
  modifier = "Mod4";
  left = "h";
  down = "j";
  up = "k";
  right = "l";
  terminal = "${pkgs.kitty}/bin/kitty";
  wrapperFeatures = { };
  extraSessionCommands = ''
    export WLR_DRM_NO_MODIFIERS=1;
    export SDL_VIDEODRIVER=wayland;
    export MOZ_ENABLE_WAYLAND=1;
    export MOZ_DBUS_REMOTE=1;
    export XCURSOR_SIZE=36;
    export BEMENU_BACKEND=wayland;
    # needs qt5.qtwayland in systemPackages
    export QT_QPA_PLATFORM=wayland;
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1;
    # Fix for some Java AWT applications (e.g. Android Studio),
    # use this if they aren't displayed properly:
    export _JAVA_AWT_WM_NONREPARENTING=1;

    exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK DBUS_SESSION_BUS_ADDRESS
    exec systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK DBUS_SESSION_BUS_ADDRESS
  '';
  extraOptions = [ ];
  config = {
    fonts = {
      names = [ "DejaVu Sans Mono" "FontAwesome5Free" ];
      style = "Bold Semi-Condensed";
      size = 9.0;
    };
    window = {

      commands = [
        # Per-application layout rules
        {
          command = "move scratchpad";
          criteria = {
            title = "^DavMail Gateway$";
            class = "davmail-DavGateway";
          };
        }
      ];
    };
    floating = { criteria = [ ]; };
    focus = { };
    assigns = { };
    keycodebindings = { };
    colors = { };
    bars = [{
      fonts = {
        names = [ "DejaVu Sans Mono" "FontAwesome5Free" ];
        style = "Bold Semi-Condensed";
        size = 9.0;
      };
      position = "top";
      trayOutput = "*";
      statusCommand =
        "${pkgs.i3status-rust}/bin/i3status-rs ~/.config/i3status-rust/config.toml";
      colors = {
        separator = "#666666";
        background = "#222222";
        statusline = "#dddddd";
        focusedWorkspace = {
          border = "#0088CC";
          background = "#0088CC";
          text = "#ffffff";
        };
        activeWorkspace = {
          border = "#333333";
          background = "#333333";
          text = "#ffffff";
        };
        inactiveWorkspace = {
          border = "#333333";
          background = "#333333";
          text = "#888888";
        };
        urgentWorkspace = {
          border = "#2f343a";
          background = "#900000";
          text = "#ffffff";
        };
      };
    }];
    gaps = { };
    modes = { };
    keybindings = { # Special keyboard controls
      "XF86AudioRaiseVolume" =
        "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
      "XF86AudioLowerVolume" =
        "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
      "XF86AudioMute" =
        "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
      "XF86AudioMicMute" =
        "exec ${pkgs.pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
      "XF86AudioPlay" =
        "exec ${pkgs.myPkgs.playerctl-fast}/bin/playerctl-fast play-pause";
      "XF86AudioPrev" =
        "exec ${pkgs.myPkgs.playerctl-fast}/bin/playerctl-fast previous";
      "XF86AudioNext" =
        "exec ${pkgs.myPkgs.playerctl-fast}/bin/playerctl-fast next";
      "--locked XF86MonBrightnessUp" =
        "exec --no-startup-id ${pkgs.light}/bin/light -A 10";
      "--locked XF86MonBrightnessDown" =
        "exec --no-startup-id ${pkgs.light}/bin/light -U 10";
    };
    input = { };
    output = lib.optionalAttrs (!config.services.kanshi.enable) {
      # "eDP-1" = {
      #   pos = "0 200";
      #   res = "1920x1080";
      # };
      # "DP-1" = {
      #   pos = "1920 0";
      #   res = "2560x1440";
      #   transform = "270";
      # };
      # "DP-2" = {
      #   pos = "1920 0";
      #   res = "2560x1440";
      #   transform = "270";
      # };
    };
    startup = [{
      command =
        "${pkgs.myPkgs.blinkstick-alert-dbus-monitor}/bin/blinkstick-alert-dbus-monitor";
    }];
  };
  extraConfig = ''
    # Lock/Unlock screen with laptop lid
    bindswitch --locked lid:on output eDP-1 disable
    bindswitch --locked lid:off output eDP-1 enable

    # DBus programs
    # exec ${pkgs.myPkgs.blinkstick-alert-dbus-monitor}/bin/blinkstick-alert-dbus-monitor &

    ### Idle configuration
    exec ${pkgs.swayidle}/bin/swayidle -w \
      timeout 1200 '${pkgs.sway}/bin/swaymsg "output * dpms off"' resume '${pkgs.sway}/bin/swaymsg "output * dpms on"'
  '';
}
