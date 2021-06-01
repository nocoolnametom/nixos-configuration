{ pkgs, config ? pkgs.config, lib ? pkgs.lib, hostName ? pkgs.hostName, ... }:

with lib;

let
  cfg = config.programs.my-sway;
  swayConfigPath = ./. + "/${pkgs.hostName}";
  swayConfig = if (!builtins.pathExists swayConfigPath) then {
    wrapperFeatures = { };
    extraSessionCommands = "";
    extraOptions = [ ];
    config = {
      fonts = { };
      window = { commands = [ ]; };
      floating = { criteria = [ ]; };
      focus = { };
      assigns = { };
      keycodebindings = { };
      colors = { };
      bars = [ ];
      gaps = { };
      modes = { };
      keybindings = { };
      input = { };
      output = { };
      startup = [ ];
    };
    extraConfig = "";
  } else
    (import swayConfigPath { inherit pkgs config; });
in {
  options = {
    programs.my-sway = {
      enable = mkOption {
        default = false;
        description = ''
          Whether to enable the sway configuration
        '';
      };
    };
  };
  config = mkMerge [
    (mkIf (cfg.enable) {
      home.packages = [ pkgs.qt5.qtwayland ];
      wayland.windowManager.sway.enable = true;
      wayland.windowManager.sway.package = null;
      wayland.windowManager.sway.systemdIntegration =
        true; # Adds `sway-session.target` for services to target against
      wayland.windowManager.sway.xwayland = true;
      wayland.windowManager.sway.wrapperFeatures = { }
        // swayConfig.wrapperFeatures;
      wayland.windowManager.sway.extraSessionCommands = ""
        + swayConfig.extraSessionCommands;
      wayland.windowManager.sway.extraOptions = [ ] ++ swayConfig.extraOptions;
      wayland.windowManager.sway.config = {
        fonts = swayConfig.config.fonts;
        window = {
          titlebar = false;
          border = 1;
          commands = [
            # Zoom layout rules
            {
              command = "floating disable";
              criteria = {
                title = "^Zoom Meeting$";
                shell = "xdg_shell";
              };
            }
            {
              command = "floating disable";
              criteria = {
                title = "^Zoom - Licensed Account$";
                shell = "xdg_shell";
              };
            }
          ] ++ swayConfig.config.window.commands;
        };
        floating = {
          titlebar = true;
          modifier = "${config.wayland.windowManager.sway.config.modifier}";
          criteria = [
            {
              title = "^ProtonMail Bridge$";
              shell = "";
            }
            {
              title = "^Firefox - Sharing Indicator$";
              shell = "xdg_shell";
            }
            {
              title = "^DavMail Gateway$";
              class = "davmail-DavGateway";
            }
            {
              title = "^zoom$";
              shell = "xdg_shell";
            }
            {
              title = "^Zoom$";
              shell = "xdg_shell";
            }
            {
              title = "^zoom_linux_float_message_reminder$";
              shell = "xdg_shell";
            }
            {
              title = "^Settings$";
              shell = "xdg_shell";
            }
            {
              title = "^Create Breakout Rooms$";
              shell = "xdg_shell";
            }
            {
              title = "^Recording Alert$";
              shell = "xdg_shell";
            }
            {
              title = "^Advanced Sharing Options\\.\\.\\.$";
              shell = "xdg_shell";
            }
          ] ++ swayConfig.config.floating.criteria;
        };
        focus = { } // swayConfig.config.focus;
        assigns = { } // swayConfig.config.assigns;
        workspaceLayout = "default";
        workspaceAutoBackAndForth =
          true; # Pressing the current workspace will send you to the previous workspace
        modifier = if (lib.hasAttrByPath [ "modifier" ] swayConfig) then
          swayConfig.modifier
        else
          "Mod4";
        keycodebindings = { } // swayConfig.config.keycodebindings;
        colors = { } // swayConfig.config.colors;
        bars = [ ] ++ swayConfig.config.bars;
        gaps = { } // swayConfig.config.gaps;
        modes = {
          resize = {
            "${config.wayland.windowManager.sway.config.left}" =
              "resize shrink width 10 px";
            "${config.wayland.windowManager.sway.config.down}" =
              "resize grow height 10 px";
            "${config.wayland.windowManager.sway.config.up}" =
              "resize shrink height 10 px";
            "${config.wayland.windowManager.sway.config.right}" =
              "resize grow width 10 px";
            Left = "resize shrink width 10 px";
            Down = "resize grow height 10 px";
            Up = "resize shrink height 10 px";
            Right = "resize grow width 10 px";
          };
        } // swayConfig.config.modes;
        menu = let
          package = if (config.wayland.windowManager.sway.package == "") then
            config.wayland.windowManager.sway.package
          else
            pkgs.sway;
        in "${pkgs.dmenu}/bin/dmenu_path | ${pkgs.bemenu}/bin/bemenu | ${pkgs.findutils}/bin/xargs ${package}/bin/swaymsg exec --";
        terminal = if (lib.hasAttrByPath [ "terminal" ] swayConfig) then
          swayConfig.terminal
        else
          "${pkgs.kitty}/bin/kitty";
        left = if (lib.hasAttrByPath [ "left" ] swayConfig) then
          swayConfig.left
        else
          "h";
        down = if (lib.hasAttrByPath [ "down" ] swayConfig) then
          swayConfig.down
        else
          "j";
        up = if (lib.hasAttrByPath [ "up" ] swayConfig) then
          swayConfig.up
        else
          "k";
        right = if (lib.hasAttrByPath [ "right" ] swayConfig) then
          swayConfig.right
        else
          "l";
        keybindings = # This function simply allows us to overwrite and extend from HM's default keybindings
          let
            menu = config.wayland.windowManager.sway.config.menu;
            left = config.wayland.windowManager.sway.config.left;
            right = config.wayland.windowManager.sway.config.right;
            up = config.wayland.windowManager.sway.config.up;
            down = config.wayland.windowManager.sway.config.down;
            modifier = config.wayland.windowManager.sway.config.modifier;
          in lib.mkOptionDefault ({
            "${modifier}+d" = "exec ${menu}";
            "${modifier}+Shift+c" = if config.services.kanshi.enable then
              "exec swaymsg reload"
            else
              "reload";

            # Workspace 10
            "${modifier}+0" = "workspace number 10";
            "${modifier}+Shift+0" = "move container to workspace number 10";

            # Clear last mako notification
            "Control+Space" = "exec ${pkgs.mako}/bin/makoctl dismiss";
            # Clear all mako notification
            "Control+Shift+Period" = "exec ${pkgs.mako}/bin/makoctl dismiss -a";
            # Invoke make notification context
            "Control+Shift+Grave" = "exec ${pkgs.mako}/bin/makoctl invoke";

            # Moving around
            "${modifier}+Shift+Mod1+Control+${left}" = "focus left";
            "${modifier}+Shift+Mod1+Control+${down}" = "focus down";
            "${modifier}+Shift+Mod1+Control+${up}" = "focus up";
            "${modifier}+Shift+Mod1+Control+${right}" = "focus right";
            # Move the focused window with the same, but add Shift
            "Shift+Mod1+Control+${left}" = "move left";
            "Shift+Mod1+Control+${down}" = "move down";
            "Shift+Mod1+Control+${up}" = "move up";
            "Shift+Mod1+Control+${right}" = "move right";
            # Ditto, with arrow keys
            "${modifier}+Shift+Left" = "move left";
            "${modifier}+Shift+Down" = "move down";
            "${modifier}+Shift+Up" = "move up";
            "${modifier}+Shift+Right" = "move right";

            "${modifier}+h" = "splith";
            "${modifier}+v" = "splitv";
          } // swayConfig.config.keybindings);
        bindkeysToCode = false;
        input = {
          "type:keyboard" = {
            xkb_layout = "us,gr";
            xkb_variant =
              ",polytonic"; # This starts with a comma to apply `polytonic` to the `gr` layout
            xkb_options = "grp:alt_space_toggle";
          };
        } // swayConfig.config.input;
        output = {
          "*".bg =
            "${pkgs.nixos-artwork.wallpapers.stripes-logo}/share/backgrounds/nixos/nix-wallpaper-stripes-logo.png fill";
        } // swayConfig.config.output;
        startup = [
          # {
          #   # This allows all services that interact with sway to reload when sway reloads (like kanshi, for instance)
          #   # It's okay if it run twice on load...
          #   command = "systemctl restart --user sway-session.target";
          #   always = true;
          # }
          # This would be best figured out with systemd
          # {
          #   command = "${pkgs.davmail}/bin/davmail";
          # }
          {
            command =
              "${pkgs.systemd}bin/systemctl --user restart mako.service";
            always = true;
          }
        ] ++ swayConfig.config.startup;
      };
      wayland.windowManager.sway.extraConfig = ''
        # Hide mouse cursor on inactivity
        seat * hide_cursor 5000
      '' + swayConfig.extraConfig;
    })
  ];
}
