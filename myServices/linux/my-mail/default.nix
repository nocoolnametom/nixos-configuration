{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.my-mail;

in {
  options.services.my-mail = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = ''
        Enable vdirsyncer to get new calendar items
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.neomutt pkgs.protonmail-bridge ];

    programs.mbsync.enable = true;
    programs.msmtp.enable = true;
    services.mbsync.enable = true;

    accounts.email = {
      maildirBasePath = config.home.homeDirectory + "/Mail";

      accounts = {
        protonmail = {
          primary = true;
          neomutt.enable = true;
          neomutt.sendMailCommand =
            "${pkgs.msmtp}/bin/msmtp -C ${config.xdg.configHome}/msmtp/config -a protonmail";
          neomutt.extraConfig = ''
            color status cyan default
            set hostname = 'nocoolnametom.com'
            set mbox = "+Archive"

            # Macros
            macro index o "<shell-escape>${pkgs.isync}/bin/mbsync protonmail<enter>" "run mbsync to sync mail for this account"
            macro index,pager J "<save-message>+Spam<enter>" "move to junk folder"
            macro index,pager A "<save-message>+Archive<enter>" "mark as read and move to the archive"
            macro index,pager I "<save-message>+Inbox<enter>" "move message to the inbox"
          '';
          passwordCommand = ''echo "${pkgs.workInfo.protonmailBridgePassword}"'';
          address = "tom@nocoolnametom.com";
          userName = "tom@nocoolnametom.com";
          realName = "Tom Doggett";
          flavor = "plain";
          folders = {
            inbox = "Inbox";
            sent = "Sent";
            trash = "Trash";
          };
          imap = {
            host = "127.0.0.1";
            port = 1143;
            tls = {
              enable = false;
              useStartTls = false;
            };
          };
          smtp = {
            host = "127.0.0.1";
            port = 1025;
            tls = {
              enable = true;
              useStartTls = true;
            };
          };
          gpg = {
            key = "5279843C73EB8029F9F6AF0EC4252D5677A319CA";
            signByDefault = true;
            encryptByDefault = false;
          };
          maildir = { path = "protonmail"; };
          signature = {
            text = ''
              --
              Tom Doggett
              tom@nocoolnametom.com
            '';
            showSignature = "append";
          };
          mbsync = {
            enable = true;
            create = "both";
            expunge = "both";
            patterns = [ "INBOX" "Archive" "Sent" "Trash" ];
            extraConfig.account = { SSLVersions = "TLSv1.2"; };
            extraConfig.channel.MaxMessages = 1000;
            extraConfig.channel.ExpireUnread = true;
          };
          msmtp = {
            enable = true;
            extraConfig = { tls_certcheck = "off"; };
          };
        };
        gmail = {
          primary = false;
          neomutt.enable = false;
          neomutt.sendMailCommand =
            "${pkgs.msmtp}/bin/msmtp -C ${config.xdg.configHome}/msmtp/config -a gmail";
          neomutt.extraConfig = ''
            color status red default
            set hostname = "gmail.com"
            set mbox = '+All'

            # Macros
            macro index o "<shell-escape>${pkgs.isync}/bin/mbsync gmail<enter>" "run mbsync to sync mail for this account"
            macro index,pager J "<save-message>+[Gmail]/Spam<enter>" "move to junk folder"
            macro index,pager A "<save-message>+[Gmail]/All<tab><enter>" "mark as read and move to the archive"
            macro index,pager I "<save-message>+Inbox<enter>" "move message to the inbox"
          '';
          passwordCommand = "${pkgs.pass}/bin/pass show _Security/gmailAppPassword | head -1";
          flavor = "gmail.com";
          address = "nocoolnametom@gmail.com";
          realName = "Tom Doggett";
          gpg = {
            key = "5279843C73EB8029F9F6AF0EC4252D5677A319CA";
            signByDefault = true;
            encryptByDefault = false;
          };
          maildir = { path = "gmail"; };
          signature = {
            text = "";
            showSignature = "none";
          };
          mbsync = {
            enable = false;
            create = "both";
            expunge = "both";
            patterns = [
              "INBOX"
              "\\[Gmail\\]/All Mail"
              "\\[Gmail\\]/Sent Mail"
              "\\[Gmail\\]/Drafts"
              "\\[Gmail\\]/Trash"
            ];
            extraConfig.account = { SSLVersions = "TLSv1.2"; };
            extraConfig.channel.MaxMessages = 1000;
            extraConfig.channel.ExpireUnread = true;
          };
          msmtp = {
            enable = false;
            extraConfig = { };
          };
        };
        work = {
          primary = false;
          neomutt.enable = true;
          neomutt.sendMailCommand =
            "${pkgs.msmtp}/bin/msmtp -C ${config.xdg.configHome}/msmtp/config -a work";
          neomutt.extraConfig = ''
            set ssl_force_tls = no
            color status blue default
            set hostname = '${pkgs.workInfo.orgUrl}'
            set mbox = '+All'

            # Macros
            macro index o "<shell-escape>${pkgs.isync}/bin/mbsync work<enter>" "run mbsync to sync mail for this account"
            macro index,pager J "<save-message>+Junk\ Email<enter>" "move to junk folder"
            macro index,pager A "<save-message>+Archive<enter>" "mark as read and move to the archive"
            macro index,pager I "<save-message>+Inbox<enter>" "move message to the inbox"
          '';
          passwordCommand = ''echo "doesntmatter"'';
          address = pkgs.workInfo.emailAddress;
          userName = pkgs.workInfo.emailAddress;
          realName = "Tom Doggett";
          flavor = "plain";
          folders = {
            inbox = "Inbox";
            sent = "Sent";
            drafts = "Drafts";
            trash = "Trash";
          };
          imap = {
            host = "localhost";
            port = 1145;
            tls = {
              enable = false;
              useStartTls = false;
            };
          };
          smtp = {
            host = "localhost";
            port = 1146;
            tls = {
              enable = false;
              useStartTls = false;
            };
          };
          gpg = {
            key = "5279843C73EB8029F9F6AF0EC4252D5677A319CA";
            signByDefault = true;
            encryptByDefault = false;
          };
          maildir = { path = "work"; };
          signature = {
            text = ''
              --
              Tom Doggett
              Senior Software Engineer
              ${pkgs.workInfo.orgName}
              ${pkgs.workInfo.emailAddress}
            '';
            showSignature = "append";
          };
          mbsync = {
            enable = true;
            create = "both";
            expunge = "both";
            patterns = [ "INBOX" "Archive" "Drafts" "Sent" "Trash" ];
            extraConfig.account = { AuthMechs = "LOGIN"; };
            extraConfig.channel.MaxMessages = 1000;
            extraConfig.channel.ExpireUnread = true;
          };
          msmtp = {
            enable = true;
            extraConfig = { };
          };
        };
      };
    };
  };

}