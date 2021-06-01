{ config, lib, pkgs, ... }:

with lib;

let
  browsers = [ "chrome" "chromium" "firefox" "vivaldi" ];
  passff = pkgs.passff-host.override {
    pass = pkgs.pass-otp;
  };
in {
  options = {
    programs.passff = {
      enable = mkEnableOption "the passff extension host application";

      browsers = mkOption {
        type = types.listOf (types.enum browsers);
        default = browsers;
        example = [ "firefox" ];
        description = "Which browsers to install browserpass for";
      };
    };
  };

  config = mkIf config.programs.passff.enable {
    home.file = foldl' (a: b: a // b) { } (concatMap (x:
      with pkgs.stdenv;
      if x == "chrome" then
        let
          dir = if isDarwin then
            "Library/Application Support/Google/Chrome/NativeMessagingHosts"
          else
            ".config/google-chrome/NativeMessagingHosts";
        in [{
          "${dir}/passff.json".source =
            "${passff}/share/passff-host/passff.json";
        }]
      else if x == "chromium" then
        let
          dir = if isDarwin then
            "Library/Application Support/Chromium/NativeMessagingHosts"
          else
            ".config/chromium/NativeMessagingHosts";
        in [{
          "${dir}/passff.json".source =
            "${passff}/share/passff-host/passff.json";
        }]
      else if x == "firefox" then
        let
          dir = if isDarwin then
            "Library/Application Support/Mozilla/NativeMessagingHosts"
          else
            ".mozilla/native-messaging-hosts";
        in [{
          "${dir}/passff.json".source =
            "${passff}/share/passff-host/passff.json";
        }]
      else if x == "vivaldi" then
        let
          dir = if isDarwin then
            "Library/Application Support/Vivaldi/NativeMessagingHosts"
          else
            ".config/vivaldi/NativeMessagingHosts";
        in [{
          "${dir}/passff.json".source =
          "${passff}/share/passff-host/passff.json";
        }]
      else
        throw "unknown browser ${x}") config.programs.passff.browsers);
  };
}