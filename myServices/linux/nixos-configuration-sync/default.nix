{ config, lib, pkgs, ... }:

with lib;

let

  serviceCfg = config.services.nixos-configuration-sync;

in {
  meta.maintainers = with maintainers; [ pacien ];

  options.services.nixos-configuration-sync = {
    enable = mkEnableOption "Nixos-configuration repo periodic sync";

    interval = mkOption {
      type = types.str;
      default = "*:0";
      description = ''
        How often to synchronise the nixos-configuration git repository with its
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

    systemd.user.services.nixos-configuration-sync = {
      Unit = { Description = "NixOS configuration repo sync"; };

      Service = {
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        ExecStart = toString (pkgs.writeShellScript "nixos-configuration-sync" ''
          ${pkgs.git}/bin/git pull --rebase -C /home/tdoggett/projects/nocoolnametom/nixos-configuration && \
          ${pkgs.git}/bin/git push -C /home/tdoggett/projects/nocoolnametom/nixos-configuration
        '');
      };
    };

    systemd.user.timers.nixos-configuration-sync = {
      Unit = { Description = "NixOS configuration repo periodic sync"; };

      Timer = {
        Unit = "nixos-configuration-sync.service";
        OnCalendar = serviceCfg.interval;
        Persistent = true;
      };

      Install = { WantedBy = [ "timers.target" ]; };
    };
  };
}