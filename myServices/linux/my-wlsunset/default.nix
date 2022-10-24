{ pkgs, config, lib, ... }:

with lib;

let cfg = config.services.my-wlsunset;
in {
  options = {
    services.my-wlsunset = {
      enable = mkOption {
        default = false;
        description = "Whether to enable my wlsunset config.";
      };
    };
  };
  config = mkMerge [
    (mkIf cfg.enable (let
      myLocation = if (lib.hasAttrByPath [ "myLocation" ] pkgs) then pkgs.myLocation else { lat = "37.8"; long = "-122.1"; };
    in {
      services.wlsunset.enable = true;
      services.wlsunset.package = pkgs.wlsunset;
      services.wlsunset.latitude = myLocation.lat;
      services.wlsunset.longitude = myLocation.long;
    }))

    (mkIf (cfg.enable && pkgs.hostName == "lappy") {
      services.wlsunset.temperature.day = 5500;
      services.wlsunset.temperature.night = 3700;
      services.wlsunset.gamma = "1.0";
    })

    (mkIf (cfg.enable && pkgs.hostName == "system76-laptop") {
      services.wlsunset.temperature.day = 5500;
      services.wlsunset.temperature.night = 3700;
      services.wlsunset.gamma = "1.0";
    })

    (mkIf (cfg.enable && pkgs.hostName == "melian") {
      services.wlsunset.temperature.day = 5500;
      services.wlsunset.temperature.night = 3700;
      services.wlsunset.gamma = "1.0";
    })
  ];
}

