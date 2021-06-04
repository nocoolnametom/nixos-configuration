{ config, lib ? pkgs.lib, pkgs, ... }:

with lib;

let
  davmailConfig = ''
    #############################################################
    # Basic settings

    # Server or workstation mode
    davmail.server=true
    # connection mode auto, EWS or WebDav
    davmail.mode=O365Manual
    # base Exchange OWA or EWS url
    davmail.url=https://outlook.office365.com/EWS/Exchange.asmx

    # Listener ports
    davmail.caldavPort=1080
    davmail.imapPort=1145
    davmail.ldapPort=1389
    davmail.popPort=
    davmail.smtpPort=1146

    # OAuth settings
    davmail.oauth.clientId=${pkgs.workInfo.oauthClientId}
    davmail.oauth.tenantId=${pkgs.workInfo.oauthTenantId}
    davmail.oauth.redirectUri=https://login.microsoftonline.com/common/oauth2/nativeclient
    davmail.oauth.persistToken=true

    #############################################################
    # Network settings

    # Network proxy settings
    davmail.enableProxy=false
    davmail.useSystemProxies=false
    davmail.proxyHost=
    davmail.proxyPort=
    davmail.proxyUser=
    davmail.proxyPassword=

    # proxy ecxlude list
    davmail.noProxyFor=

    # allow remote connection to DavMail
    davmail.allowRemote=false
    # bind server sockets to a specific address
    davmail.bindAddress=
    # client connection timeout in seconds - default 300, 0 to disable
    davmail.clientSoTimeout=0

    # DavMail listeners SSL configuration
    davmail.ssl.keystoreType=
    davmail.ssl.keystoreFile=
    davmail.ssl.keystorePass=
    davmail.ssl.keyPass=

    # Accept specified certificate even if invalid according to trust store
    davmail.server.certificate.hash=

    # disable SSL for specified listeners
    davmail.ssl.nosecurecaldav=false
    davmail.ssl.nosecureimap=false
    davmail.ssl.nosecureldap=false
    davmail.ssl.nosecurepop=false
    davmail.ssl.nosecuresmtp=false

    # disable update check
    davmail.disableUpdateCheck=true

    # Send keepalive character during large folder and messages download
    davmail.enableKeepalive=true
    # Message count limit on folder retrieval
    davmail.folderSizeLimit=
    # Default windows domain for NTLM and basic authentication
    davmail.defaultDomain=

    #############################################################
    # Caldav settings

    # override default alarm sound
    davmail.caldavAlarmSound=
    # retrieve only future calendar events
    davmail.caldavPastDelay=0
    # EWS only: enable server managed meeting notifications
    davmail.caldavAutoSchedule=true
    # WebDav only: force event update to trigger ActiveSync clients update
    davmail.forceActiveSyncUpdate=false ?
    # ?
    davmail.caldavEditNotifications=false
    # ?
    davmail.carddavReadPhoto=true

    #############################################################
    # IMAP settings

    # Delete messages immediately on IMAP STORE Deleted flag
    davmail.imapAutoExpunge=true
    # Enable IDLE support, set polling delay in minutes
    davmail.imapIdleDelay=
    # Always reply to IMAP RFC822.SIZE requests with Exchange approximate message size for performance reasons
    davmail.imapAlwaysApproxMsgSize=false

    #############################################################
    # POP settings

    # Delete messages on server after 30 days
    davmail.keepDelay=30
    # Delete messages in server sent folder after 90 days
    davmail.sentKeepDelay=0
    # Mark retrieved messages read on server
    davmail.popMarkReadOnRetr=false

    #############################################################
    # SMTP settings

    # let Exchange save a copy of sent messages in Sent folder
    davmail.smtpSaveInSent=true

    #############################################################
    # Loggings settings

    # log file path, leave empty for default path
    davmail.logFilePath=.cache/davmail
    # maximum log file size, use Log4J syntax, set to 0 to use an external rotation mechanism, e.g. logrotate
    davmail.logFileSize=1MB
    # log levels
    log4j.logger.davmail=WARN
    log4j.logger.httpclient.wire=WARN
    log4j.logger.org.apache.commons.httpclient=WARN
    log4j.logger.org.apache.http.wire=WARN
    log4j.logger.org.apache.http=WARN
    log4j.rootLogger=WARN

    #############################################################
    # Workstation only settings

    # smartcard access settings
    davmail.ssl.pkcs11Config=
    davmail.ssl.pkcs11Library=

    # SSL settings for mutual authentication
    davmail.ssl.clientKeystoreType=
    davmail.ssl.clientKeystoreFile=
    davmail.ssl.clientKeystorePass=

    # disable all balloon notifications
    davmail.disableGuiNotifications=false
    # disable tray icon color switch on activity
    davmail.disableTrayActivitySwitch=false
    # disable startup balloon notifications
    davmail.showStartupBanner=false

    # enable transparent client Kerberos authentication
    davmail.enableKerberos=false

    # Anything below this line is preserved through HM updates
  '';
in {
  options = {
    services.davmail-config = {
      enable = mkEnableOption "Whether to enable davmail configuration";
    };
  };

  config = mkIf config.services.davmail-config.enable {
    home.file.".davmail.properties.immutable".text = davmailConfig;

    systemd.user.services.davmail-immutable = {
      Unit = {
        Description =
          "Allowing for immutable davmail config file with login state values";
        ConditionPathExists = "/home/tdoggett/.davmail.properties.immutable";
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit= false;
        WorkingDirectory = "/home/tdoggett";
        ExecStart = "${pkgs.writeShellScript "davmail-immutable-copy" ''
          ${pkgs.coreutils}/bin/touch .davmail.properties \
            && $(${pkgs.gnugrep}/bin/grep -v -x -f .davmail.properties.immutable .davmail.properties > .davmailnew.properties || ${pkgs.coreutils}/bin/touch .davmailnew.properties) \
            && ${pkgs.coreutils}/bin/cat .davmail.properties.immutable > .davmail.properties \
            && ${pkgs.coreutils}/bin/cat .davmailnew.properties >> .davmail.properties \
            && ${pkgs.coreutils}/bin/rm -f .davmailnew.properties \
            && ${pkgs.coreutils}/bin/chmod 777 .davmail.properties \
            && ${pkgs.coreutils}/bin/chown tdoggett:tdoggett .davmail.properties \
            && exit 0
        ''}";
      };

      Install.WantedBy = [ "default.target" ];
    };

  };
}
