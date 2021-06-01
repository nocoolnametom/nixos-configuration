{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.programs.my-newsboat;
in {
  options = {
    programs.my-newsboat = {
      enable = mkOption {
        default = false;
        description = "Whether to enable my newsboat config and settings";
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
      };
    };
  };
  config = mkIf cfg.enable {
    programs.newsboat.enable = true;
    programs.newsboat.urls = [
      {
        url = "http://xkcd.com/atom.xml";
        # tags = [ "foo" "bar" ];
        title = "XKCD";
      }
      {
        url = "http://www.nytimes.com/services/xml/rss/nyt/HomePage.xml";
        title = "NY Times";
      }
      {
        url = "http://www.engadget.com/rss.xml";
        title = "Engadget";
      }
      {
        url = "http://feeds.arstechnica.com/arstechnica/index/";
        title = "Ars Technica";
      }
      {
        url = "https://m.signalvnoise.com/feed";
        title = "Signal v. Noise";
      }
    ];
    programs.newsboat.maxItems = 10;
    programs.newsboat.reloadThreads = 5;
    programs.newsboat.autoReload = true;
    programs.newsboat.reloadTime = 60;
    programs.newsboat.browser = "${pkgs.xdg_utils}/bin/xdg-open";
    programs.newsboat.queries = { };
    programs.newsboat.extraConfig = cfg.extraConfig + ''
      # unbind keys
      unbind-key ENTER
      unbind-key j
      unbind-key k
      unbind-key J
      unbind-key K
      unbind-key ^R
      unbind-key ^N
      unbind-key ^P
      unbind-key TAB

      # bind keys - vim style
      bind-key j down
      bind-key k up
      bind-key l open
      bind-key h quit
      bind-key ^R toggle-article-read
      bind-key ^P prev-feed
      bind-key ^N next-feed
      bind-key TAB next-unread
    '';
  };
}
