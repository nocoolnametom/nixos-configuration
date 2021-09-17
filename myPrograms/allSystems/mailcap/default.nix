{ config, lib ? pkgs.lib, pkgs, ... }:

with lib;

let
  mailcapSource = lib.concatStringsSep " " ([''
    # auto view using w3m
    text/html; ${pkgs.w3m}/bin/w3m -I %{charset} -T text/html; copiousoutput;
  ''] ++ (lib.optionals (pkgs.hostName == "lappy") [''
    ###############################################################################
    # Commands below this point are meant for Linux and an X Window System.
    ###############################################################################

    # imv is a simple and effective image viewer
    # Note that tuir returns a list of urls for imgur albums, so we don't put quotes
    # around the `%s`
    image/x-imgur-album; ${pkgs.curl}/bin/curl -Osw '%{filename_effective}\n' %s | ${pkgs.imv}/bin/imv ; test=test -n "$WAYLAND_DISPLAY"
    image/*; ${pkgs.curl}/bin/curl '%s' | ${pkgs.imv}/bin/imv - ; test=test -n "$WAYLAND_DISPLAY"

    # Youtube videos are assigned a custom mime-type, which can be streamed with
    # vlc or youtube-dl.
    video/x-youtube; ${pkgs.vlc}/bin/vlc '%s' --width 640 --height 480; test=test -n "$DISPLAY"
    video/x-youtube; ${pkgs.youtube-dl}/bin/youtube-dl -q -o - '%s' | ${pkgs.mpv}/bin/mpv - --autofit 640x480; test=test -n "$DISPLAY"

    # Mpv is a simple and effective video streamer
    video/webm; ${pkgs.mpv}/bin/mpv '%s' --autofit 640x480 --loop=inf; test=test -n "$DISPLAY"
    video/*; ${pkgs.mpv}/bin/mpv '%s' --autofit 640x480 --loop=inf; test=test -n "$DISPLAY"
  '']) ++ (lib.optionals (pkgs.hostName == "system76-laptop") [''
    ###############################################################################
    # Commands below this point are meant for Linux and an X Window System.
    ###############################################################################

    # imv is a simple and effective image viewer
    # Note that tuir returns a list of urls for imgur albums, so we don't put quotes
    # around the `%s`
    image/x-imgur-album; ${pkgs.curl}/bin/curl -Osw '%{filename_effective}\n' %s | ${pkgs.imv}/bin/imv ; test=test -n "$WAYLAND_DISPLAY"
    image/*; ${pkgs.curl}/bin/curl '%s' | ${pkgs.imv}/bin/imv - ; test=test -n "$WAYLAND_DISPLAY"

    # Youtube videos are assigned a custom mime-type, which can be streamed with
    # vlc or youtube-dl.
    video/x-youtube; ${pkgs.vlc}/bin/vlc '%s' --width 640 --height 480; test=test -n "$DISPLAY"
    video/x-youtube; ${pkgs.youtube-dl}/bin/youtube-dl -q -o - '%s' | ${pkgs.mpv}/bin/mpv - --autofit 640x480; test=test -n "$DISPLAY"

    # Mpv is a simple and effective video streamer
    video/webm; ${pkgs.mpv}/bin/mpv '%s' --autofit 640x480 --loop=inf; test=test -n "$DISPLAY"
    video/*; ${pkgs.mpv}/bin/mpv '%s' --autofit 640x480 --loop=inf; test=test -n "$DISPLAY"
  '']));
in {
  options = {
    programs.mailcap = {
      enable = mkEnableOption
        "Whether to enable mailcap file type program associations";
    };
  };

  config = mkIf config.programs.mailcap.enable {
    home.file.".mailcap".text = mailcapSource;
  };
}
