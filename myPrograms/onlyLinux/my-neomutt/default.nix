{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.programs.my-neomutt;
  mbsyncAccounts =
    filter (a: a.mbsync.enable) (attrValues config.accounts.email.accounts);
  genAccountMailboxes = account:
    "mailboxes " + builtins.concatStringsSep " " (map (pattern:
      ''
        ${config.accounts.email.maildirBasePath}/${account.name}/"${
          if (toLower pattern) != "inbox" then pattern else "Inbox"
        }"'') account.mbsync.patterns);
  genNamedMailboxes = account:
    builtins.concatStringsSep "\n" ([
      ''
        named-mailboxes "${
          (toUpper (concatStrings (take 1 (stringToCharacters account.name))))
          + (concatStrings (drop 1 (stringToCharacters account.name)))
        }" ="${account.name}/Inbox"''
    ] ++ (map (pattern:
      ''
        named-mailboxes "  ${
          head (splitString " " (last (splitString "/" (toLower pattern))))
        }" ="${account.name}/${pattern}"'')
      (filter (x: (toLower x) != "inbox") account.mbsync.patterns)));
  mailboxes =
    builtins.concatStringsSep "\n" (map genAccountMailboxes mbsyncAccounts);
  newNamedMailboxes =
    builtins.concatStringsSep "\n" (map genNamedMailboxes mbsyncAccounts);
in {
  options = {
    programs.my-neomutt = {
      enable = mkOption {
        default = false;
        description = "Whether to enable my neomutt config.";
      };
    };
  };
  config = mkIf cfg.enable {
    programs.neomutt.enable = true;
    programs.neomutt.sidebar = {
      enable = true;
      width = 25;
      shortPath = true;
      format = "%B %* [%?N?%N / ?%S]";
    };
    programs.neomutt.binds = [
      # Sidebar Binds
      {
        map = [ "index" ];
        key = "<F4>";
        action = "sidebar-toggle-visible";
      }
      {
        map = [ "pager" ];
        key = "<F4>";
        action = "sidebar-toggle-visible";
      }
      {
        map = [ "index" ];
        key = "\\Cp";
        action = "sidebar-prev";
      }
      {
        map = [ "pager" ];
        key = "\\Cp";
        action = "sidebar-prev";
      }
      {
        map = [ "index" ];
        key = "\\Cn";
        action = "sidebar-next";
      }
      {
        map = [ "pager" ];
        key = "\\Cn";
        action = "sidebar-next";
      }
      {
        map = [ "index" ];
        key = "\\Co";
        action = "sidebar-open";
      }
      {
        map = [ "pager" ];
        key = "\\Co";
        action = "sidebar-open";
      }
    ]; # See binds module, this is a list of binds
    programs.neomutt.macros = [ ]; # Also a list of binds
    programs.neomutt.sort = "threads"; # other options, too
    programs.neomutt.vimKeys = true;
    programs.neomutt.checkStatsInterval = null; # or a number, like 60?
    programs.neomutt.editor = "vim +/^$ ++1";
    programs.neomutt.settings = {
        # sidebar
        folder = "${config.accounts.email.maildirBasePath}";
        sidebar_folder_indent = "no";
        sidebar_divider_char = "' | '";
        sidebar_delim_chars = "'/'";
        sidebar_indent_string = "'  '";
        # general
        mail_check_stats = "yes";
        tmpdir = "${config.accounts.email.maildirBasePath}/tmp";
        sort_browser = "reverse-date";
        sort_aux = "last-date-received";
        realname = "'Tom Doggett'";
        use_from = "yes";
        new_mail_command = ''
          "${pkgs.libnotify}/bin/notify-send --icon '${pkgs.neomutt}/share/doc/neomutt/logo/neomutt.svg' 'New Email' '%n new messages, %u unread.' &"'';
        # basic options
        wait_key = "no";
        mbox_type = "Maildir";
        timeout = "3";
        mail_check = "5";
        copy = "yes";
        delete = "yes";
        quit = "yes";
        # compose view options
        use_envelope_from = "yes";
        edit_headers = "yes";
        fast_reply = "yes";
        askcc = "yes";
        fcc_attach = "yes";
        forward_format = "'Fwd: %s'";
        forward_decode = "yes";
        attribution = "'On %d, %n wrote:'";
        reply_to = "yes";
        reverse_name = "yes";
        include = "yes";
        forward_quote = "yes";
        text_flowed = "yes";
        # encryption
        pgp_default_key = "5279843C73EB8029F9F6AF0EC4252D5677A319CA";
        crypt_use_gpgme = "yes"; # use gpg for signing and encryption
        crypt_autosign = "yes"; # automatically sign all outgoing mail
        crypt_autoencrypt = "no"; # do not automatically encrypt all outgoing mail
        crypt_verify_sig = "yes"; # verify incoming signed mail
        crypt_replysign = "yes"; # automatically sign replies to encrypted mail
        crypt_replyencrypt =
          "yes"; # automatically encrypt replies to encrypted mail
        crypt_replysignencrypted =
          "yes"; # automatically encrypt replies to signed mail
        pgp_check_gpg_decrypt_status_fd =
          "yes"; # Use GPG when mutt makes calls to PGP
        pgp_self_encrypt = "yes"; # Save a copy of the encrypted outgoing mail
      };
    programs.neomutt.extraConfig = ''
      ${newNamedMailboxes}

      auto_view text/html
      unset collapse_unread
      unset confirmappend
      unset move
      unset mark_old
      unset beep_new
      unset sig_dashes
      unset mime_forward

      # Colors
      color   normal      white default
      color   attachment  brightyellow default
      color   hdrdefault  cyan default
      color   indicator   black cyan
      color   markers     brightred default
      color   quoted      green default
      color   signature   cyan default
      color   status      brightgreen blue
      color   tilde       blue default
      color   tree        red default
      color   header      brightgreen default ^From:
      color   header      brightcyan default ^To:
      color   header      brightcyan default ^Reply-To:
      color   header      brightcyan default ^Cc:
      color   header      brightblue default ^Subject:
      color   body        brightred default [\-\.+_a-zA-Z0-9]+@[\-\.a-zA-Z0-9]+
      color   body        brightblue default (https?|ftp)://[\-\.,/%~_:?&=\#a-zA-Z0-9]+

      # Fix Vim-Keys configuration oddness with carraige return
      bind index   \Cm    display-message
    '';
  };
}