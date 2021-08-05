
{ config, lib, pkgs, ... }:

with lib;

let

  serviceCfg = config.services.zgbackup;

in {
  meta.maintainers = with maintainers; [ pacien ];

  options.services.zgbackup = {
    enable = mkEnableOption "ZG Backup periodic sync";

    frequency = mkOption {
      type = types.str;
      default = "hourly";
      description = ''
        How often to synchronise the password store git repository with its
        default upstream.
        </para><para>
        This value is passed to the systemd timer configuration as the
        <literal>onCalendar</literal> option.
        See
        <citerefentry>
          <refentrytitle>systemd.time</refentrytitle>
          <manvolnum>7</manvolnum>
        </citerefentry>
        for more information about the format.
      '';
    };
  };

  config = mkIf serviceCfg.enable {

    systemd.user.services.zgbackup = {
      Unit = { Description = "ZG Backup sync"; };

      Service = {
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        ExecStart = "${pkgs.myGitRepos.zg_backup}/bin/zg_backup";
        User="tdoggett";
      };
    };

    systemd.user.timers.zgbackup = {
      Unit = { Description = "ZG Backup periodic sync"; };

      Timer = {
        Unit = "zgbackup.service";
        OnCalendar = serviceCfg.frequency;
        Persistent = true;
      };

      Install = { WantedBy = [ "timers.target" ]; };
    };
  };
}
