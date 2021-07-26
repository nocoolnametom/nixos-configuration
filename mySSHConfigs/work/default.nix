{ pkgs ? (import <nixpkgs> { }), lib ? pkgs.lib, gitServer ? ""
, currentBrandStagingDomain ? "", currentBrandProdServicesDomain ? ""
, meadowDomain ? lib.replaceStrings [ "stage" ] [ "meadow" ]
  currentBrandStagingDomain
  # When sending in the path to the private key make sure it's a string!
  # try referencing the file by path once via something like
  # idRsa = if lib.pathExists ../idRsa then toString ../idRsa else ""
, idRsa ? "", workRsa ? "", workEsRsa ? "", stageApops ? "", mysqlAccess ? ""
, ... }:

{ } // (lib.optionalAttrs (workEsRsa != "") {
  bastionProdServices = {
    host = "bastion.${currentBrandProdServicesDomain}";
    user = "es";
    identityFile = workEsRsa;
    identitiesOnly = true;
    port = null;
    forwardX11 = false;
    forwardX11Trusted = false;
    hostname = "bastion.${currentBrandProdServicesDomain}";
    serverAliveInterval = 0;
    compression = null;
    proxyCommand = null;
    extraOptions = {
      UserKnownHostsFile = "/dev/null";
      ForwardAgent = "yes";
      ControlMaster = "auto";
      ControlPath = "~/.ssh/stage-%r@%h:%p";
      ControlPersist = "5m";
    };
  };
}) // (lib.optionalAttrs (stageApops != "") {
  bastionWorkStaging = {
    host = "bastion.${currentBrandStagingDomain}";
    user = "apops";
    identityFile = stageApops;
    identitiesOnly = true;
    port = null;
    forwardX11 = false;
    forwardX11Trusted = false;
    hostname = "bastion.${currentBrandStagingDomain}";
    serverAliveInterval = 0;
    compression = null;
    proxyCommand = null;
    extraOptions = {
      ForwardAgent = "yes";
      ControlMaster = "auto";
      ControlPath = "~/.ssh/stage-%r@%h:%p";
      ControlPersist = "5m";
    };
  };
  bastionWorkMeadow = {
    host = "bastion.${meadowDomain}";
    user = "apops";
    identityFile = stageApops;
    identitiesOnly = true;
    port = null;
    forwardX11 = false;
    forwardX11Trusted = false;
    hostname = "bastion.${meadowDomain}";
    serverAliveInterval = 0;
    compression = null;
    proxyCommand = null;
    extraOptions = {
      ForwardAgent = "yes";
      ControlMaster = "auto";
      ControlPath = "~/.ssh/stage-%r@%h:%p";
      ControlPersist = "5m";
    };
  };
  bastionStagingDomain = {
    host = builtins.concatStringsSep " " [
      "10.130.128.*"
      "10.130.129.*"
      "10.130.13?.*"
      "10.130.14?.*"
      "10.130.15?.*"
      "10.130.16?.*"
      "10.130.17?.*"
      "10.130.18?.*"
      "10.130.190.*"
      "10.130.191.*"
    ];
    proxyCommand = "ssh bastion.${currentBrandStagingDomain} -W %h:%p";
    identityFile = stageApops;
    identitiesOnly = true;
    user = "apops";
    extraOptions = {
      HostKeyAlgorithms = "-ssh-rsa";
      UserKnownHostsFile = "/dev/null";
      StrictHostKeyChecking = "no";
    };
  };
  bastionMeadowDomain = {
    host = builtins.concatStringsSep " " [
      "!10.130.190.*"
      "!10.130.191.*"
      "10.130.19?.*"
      "10.130.200.*"
      "10.130.201.*"
      "10.130.202.*"
      "10.130.203.*"
      "10.130.204.*"
      "10.130.205.*"
      "10.130.206.*"
      "10.130.207.*"
    ];
    proxyCommand = "ssh bastion.${meadowDomain} -W %h:%p";
    identityFile = stageApops;
    identitiesOnly = true;
    user = "apops";
    extraOptions = {
      HostKeyAlgorithms = "-ssh-rsa";
      UserKnownHostsFile = "/dev/null";
      StrictHostKeyChecking = "no";
    };
  };
}) // (lib.optionalAttrs (mysqlAccess != "") {
  stageAws = {
    host = "stage.aws";
    hostname = "bastion.${currentBrandStagingDomain}";
    identityFile = mysqlAccess;
    user = "mysqlaccess";
  };
  meadowAws = {
    host = "meadow.aws";
    hostname = "bastion.${meadowDomain}";
    identityFile = mysqlAccess;
    user = "mysqlaccess";
  };
}) // (lib.optionalAttrs (workRsa != "") {
  tdoggett5 = {
    host = "tdoggett5";
    hostname = "tdoggett5";
    identityFile = workRsa;
    user = "tdoggett";
  };
  zg02911 = {
    host = builtins.concatStringsSep " " [
      "zg02911"
      "ZG02011"
      "zg02911.local"
      "ZG02911.local"
    ];
    hostname = "192.168.86.66";
    identityFile = workRsa;
    user = "tdoggett";
  };
  zg02911vm = {
    host = builtins.concatStringsSep " " [
      "zg02911vm"
      "ZG02011VM"
      "zg02911vm.local"
      "ZG02911VM.local"
    ];
    hostname = "192.168.86.48";
    identityFile = workRsa;
    user = "tdoggett";
  };
  workTools = {
    host = "zgtools";
    hostname = gitServer;
    identityFile = workRsa;
    user = "git";
  };
  workToolsFull = {
    host = gitServer;
    hostname = gitServer;
    identityFile = workRsa;
    user = "git";
  };
}) // (lib.optionalAttrs (idRsa != "") {
  hardtofindmormonvideos = {
    host = "hardtofindmormonvideos";
    hostname = "hardtofindmormonvideos.com";
    proxyCommand = "ssh tdoggett5 -W %h:%p";
    identityFile = idRsa;
    user = "root";
  };
})
