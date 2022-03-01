(self: super: let
    originals = import ./default.nix { pkgs = super; };
    workInfo = if (super.lib.hasAttrByPath [ "workInfo" ] super) then
      super.workInfo
    else {
      userName = "tdoggett";
    };
  in {
  myPkgs = rec {
    inherit (originals)
      wakatime-zsh-plugin intelephense coc-phpls bash-language-server
      khal-events khal-events-json khal-events-plain khal-today
      blinkstick-alert-dbus-monitor playerctl-fast;
    "@yaegassy/coc-intelephense" = originals."@yaegassy/coc-intelephense";
    workVpn = originals.workVpn.override rec {
      username = workInfo.userName;
      passName = "zillow.okta.com/${username}";
      vpnName = workInfo.workVpnName;
      vpnUrl = workInfo.workVpnUrl;
    };
  };
  sway = super.sway.overrideAttrs ( old: rec {
    version = "1.6.1-override";

    src = super.fetchFromGitHub {
      owner = "swaywm";
      repo = "sway";
      rev = "1.6";
      sha256 = "0vnplva11yafhbijrk68wy7pw0psn9jm0caaymswq1s951xsn1c8";
    };
  });
})
