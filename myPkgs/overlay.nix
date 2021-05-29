(self: super: {
  myPkgs = let
    originals = import ./default.nix { pkgs = super; };
    workInfo = if (super.lib.hasAttrByPath [ "workInfo" ] super) then
      super.workInfo
    else {
      userName = "tdoggett";
    };
  in rec {
    inherit (originals)
      wakatime-zsh-plugin intelephense coc-phpls bash-language-server
      khal-events khal-events-json khal-events-plain khal-today;
    "@yaegassy/coc-intelephense" = originals."@yaegassy/coc-intelephense";
    workVpn = originals.workVpn.override rec {
      username = workInfo.userName;
      passName = "zillow.okta.com/${username}";
      vpnName = "Zillow VPN";
      vpnUrl = "sfo.vpn.zillowgroup.com";
    };
  };
})
