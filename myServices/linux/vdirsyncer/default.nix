{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.vdirsyncer;

in {
  options.services.vdirsyncer = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = ''
        Enable vdirsyncer to get new calendar items
      '';
    };
    frequency = mkOption {
      type = types.str;
      default = "hourly";
      description = ''
        How often to run vdirsyncer.  This value is passed to the systemd
        timer configuration as the onCalendar option.  See
        <citerefentry>
          <refentrytitle>systemd.time</refentrytitle>
          <manvolnum>7</manvolnum>
        </citerefentry>
        for more information about the format.
      '';
    };
  };

  config = mkIf cfg.enable {

    xdg.configFile."vdirsyncer/config".text = ''
      [general]
      status_path = "~/.local/state/vdirsyncer/status/"

      [pair work_calendar]
      a = "work_local"
      b = "work_remote"
      collections = ["from a", "from b"]
      metadata = ["color"]
      conflict_resolution = "b wins"

      [storage work_local]
      type = "filesystem"
      path = "~/.calendars/work"
      fileext = ".ics"

      [storage work_remote]
      read_only = true
      type = "caldav"
      url = "http://localhost:1080/users/tdoggett@zillowgroup.com/calendar/"
      username = "tdoggett@zillowgroup.com"
      password = "FakePassword"
      start_date = "datetime.now() - timedelta(days=1)"
      end_date = "datetime.now() + timedelta(days=30)"
    '';

    systemd.user.timers.vdirsyncer = {
      Unit = { Description = "vdirsyncer calendar synchronization"; };

      Timer = {
        OnCalendar = cfg.frequency;
        Unit = "vdirsyncer.service";
      };

      Install = { WantedBy = [ "timers.target" ]; };
    };

    systemd.user.services.vdirsyncer = {
      Unit = { Description = "vdirsyncer calendar synchronization"; };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer sync";
      };
    };
  };

}
