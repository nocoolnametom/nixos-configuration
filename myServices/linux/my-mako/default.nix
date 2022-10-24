{ pkgs, config, lib, ... }:

with lib;

let cfg = config.services.my-mako;
in {
  options = {
    services.my-mako = {
      enable = mkOption {
        default = false;
        description = "Whether to enable my mako config.";
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      programs.mako.enable = true;

      systemd.user.services.mako = {
        Unit = {
          Description = "Mako notification daemon";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          Type = "dbus";
          BusName = "org.freedesktop.Notifications";
          ExecStart = "${pkgs.mako}/bin/mako";
        };
      };
    })
    (mkIf (cfg.enable && pkgs.hostName == "lappy") {
      programs.mako.maxVisible = 5;
      programs.mako.sort = "-time";
      programs.mako.output = null;
      programs.mako.layer = "top";
      programs.mako.anchor = "top-right";
      programs.mako.font = "Liberation Sans 12";
      programs.mako.backgroundColor = "#285577FF";
      programs.mako.textColor = "#FFFFFFFF";
      programs.mako.width = 300;
      programs.mako.height = 100;
      programs.mako.margin = "10";
      programs.mako.padding = "6";
      programs.mako.borderSize = 3;
      programs.mako.borderColor = "#8EC07CFF";
      programs.mako.borderRadius = 10;
      programs.mako.progressColor = "over #5588AAFF";
      programs.mako.icons = true;
      programs.mako.maxIconSize = 64;
      programs.mako.iconPath = null;
      programs.mako.markup = true;
      programs.mako.actions = true;
      programs.mako.format = "<b>%s</b>\\n%b";
      programs.mako.defaultTimeout = 10000;
      programs.mako.ignoreTimeout = false;
      programs.mako.groupBy = "app-name,urgency";
    })
    (mkIf (cfg.enable && pkgs.hostName == "system76-laptop") {
      programs.mako.maxVisible = 5;
      programs.mako.sort = "-time";
      programs.mako.output = null;
      programs.mako.layer = "top";
      programs.mako.anchor = "top-right";
      programs.mako.font = "Liberation Sans 12";
      programs.mako.backgroundColor = "#285577FF";
      programs.mako.textColor = "#FFFFFFFF";
      programs.mako.width = 300;
      programs.mako.height = 100;
      programs.mako.margin = "10";
      programs.mako.padding = "6";
      programs.mako.borderSize = 3;
      programs.mako.borderColor = "#8EC07CFF";
      programs.mako.borderRadius = 10;
      programs.mako.progressColor = "over #5588AAFF";
      programs.mako.icons = true;
      programs.mako.maxIconSize = 64;
      programs.mako.iconPath = null;
      programs.mako.markup = true;
      programs.mako.actions = true;
      programs.mako.format = "<b>%s</b>\\n%b";
      programs.mako.defaultTimeout = 10000;
      programs.mako.ignoreTimeout = false;
      programs.mako.groupBy = "app-name,urgency";
    })
    (mkIf (cfg.enable && pkgs.hostName == "melian") {
      programs.mako.maxVisible = 5;
      programs.mako.sort = "-time";
      programs.mako.output = null;
      programs.mako.layer = "top";
      programs.mako.anchor = "top-right";
      programs.mako.font = "Liberation Sans 12";
      programs.mako.backgroundColor = "#285577FF";
      programs.mako.textColor = "#FFFFFFFF";
      programs.mako.width = 300;
      programs.mako.height = 100;
      programs.mako.margin = "10";
      programs.mako.padding = "6";
      programs.mako.borderSize = 3;
      programs.mako.borderColor = "#8EC07CFF";
      programs.mako.borderRadius = 10;
      programs.mako.progressColor = "over #5588AAFF";
      programs.mako.icons = true;
      programs.mako.maxIconSize = 64;
      programs.mako.iconPath = null;
      programs.mako.markup = true;
      programs.mako.actions = true;
      programs.mako.format = "<b>%s</b>\\n%b";
      programs.mako.defaultTimeout = 10000;
      programs.mako.ignoreTimeout = false;
      programs.mako.groupBy = "app-name,urgency";
    })
  ];
}

