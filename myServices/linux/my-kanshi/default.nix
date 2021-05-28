{ pkgs, config, lib, ... }:

with lib;

let cfg = config.services.my-kanshi;
in {
  options = {
    services.my-kanshi = {
      enable = mkOption {
        default = false;
        description = "Whether to enable my kanshi config.";
      };
      package = mkOption {
        type = types.package;
        default = pkgs.kanshi;
        defaultText = literalExample "pkgs.kanshi";
        description = ''
          kanshi derivation to use.
        '';
      };
    };
  };
  config = mkMerge [

    (mkIf cfg.enable {
      services.kanshi.enable = true;
      services.kanshi.package = cfg.package;
      services.kanshi.extraConfig = "";
      services.kanshi.systemdTarget =
        if config.wayland.windowManager.sway.systemdIntegration then
          "sway-session.target"
        else
          "graphical-session.target";
    })

    (mkIf (cfg.enable && pkgs.hostName == "lappy") {
      services.kanshi.profiles = {
        justLaptop = {
          outputs = [{
            criteria = "eDP-1";
            status = "enable"; # null, "enable", "disable"
            mode = "1920x1080";
            position = "0,0"; # null, or example
            scale = null; # null or int
            transform = null;
          }];
        };
        laptopWithDell1 = {
          outputs = [
            {
              criteria = "eDP-1";
              status = "enable"; # null, "enable", "disable"
              mode = "1920x1080";
              position = "0,200"; # null, or example
              scale = null; # null or int
              transform = null;
            }
            {
              criteria = "DP-1";
              status = "enable"; # null, "enable", "disable"
              mode = "2560x1440";
              position = "1920,0"; # null, or example
              scale = null; # null or int
              transform = "90";
            }
          ];
        };
        laptopWithDell2 = {
          outputs = [
            {
              criteria = "eDP-1";
              status = "enable"; # null, "enable", "disable"
              mode = "1920x1080";
              position = "0,200"; # null, or example
              scale = null; # null or int
              transform = null;
            }
            {
              criteria = "DP-2";
              status = "enable"; # null, "enable", "disable"
              mode = "2560x1440";
              position = "1920,0"; # null, or example
              scale = null; # null or int
              transform = "90";
            }
          ];
        };
        onlyDell1 = {
          outputs = [{
            criteria = "DP-1";
            status = "enable"; # null, "enable", "disable"
            mode = "2560x1440";
            position = "0,0"; # null, or example
            scale = null; # null or int
            transform = "90";
          }];
        };
        onlyDell2 = {
          outputs = [{
            criteria = "DP-2";
            status = "enable"; # null, "enable", "disable"
            mode = "2560x1440";
            position = "0,0"; # null, or example
            scale = null; # null or int
            transform = "90";
          }];
        };
      };
    })

  ];
}

