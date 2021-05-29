# It's expected to load this via the main machine configuration, but if
# not then remember to symlink this into the expected location!
# `ln -s <absolute path to this file> ~/.nixpkgs/home.nix

{ pkgs, config, lib ? pkgs.lib, hostName ? if lib.hasAttrByPath [ "hostName" ] pkgs then
  (lib.toLower pkgs.hostName)
else
  "nixos-machine", isModule ? false, isDarwin ? false, ... }:

let
  homeDirectory = if (isDarwin || !isModule) then
    (builtins.getEnv "HOME")
  else
    (if (lib.hasAttrByPath [ "home" "homeDirectory" ] config) then
      config.home.homeDirectory
    else
      config.users.users.tdoggett.home);
  myVim = import ./myVim { inherit pkgs; };
in {
  imports = (import ./myHomes { inherit pkgs config hostName; }) ++ (lib.optionals (!isModule) [ ./overlays-import.nix ])
    ++ (lib.optionals (!isDarwin) [ ./myServices/linux ./services-home.nix ])
    ++ (lib.optionals (lib.pathExists ./home.nix) [ ./home.nix ]);

  programs.vim = { inherit (myVim) plugins settings extraConfig; };
  programs.vim.enable = true;

  home.file.".vim/coc-settings.json".text = myVim.cocSettingsFile;
  home.file."intelephense/licence.txt".text = pkgs.workInfo.intelephenseKey;

  programs.gpg.enable = true;
  programs.gpg.homedir = "${homeDirectory}/.gnupg";
  programs.password-store.enable = true;
  programs.password-store.package = pkgs.pass.withExtensions
    (exts: [ exts.pass-genphrase exts.pass-update exts.pass-otp ]);
  programs.password-store.settings = {
    PASSWORD_STORE_DIR = "${homeDirectory}/.password-store";
  };
  programs.git.enable = true;
  programs.git.userName = "Tom Doggett";
  programs.git.signing.key = "5279843C73EB8029F9F6AF0EC4252D5677A319CA";
  programs.git.signing.signByDefault = true;
  programs.git.aliases.co = "checkout";
  programs.git.extraConfig = {
    core.editor = "vim";
    log.decorate = "full";
    rebase.autostash = true;
    pull.rebase = true;
    stash.showPatch = true;
    "color \"status\"" = {
      added = "green";
      changed = "yellow bold";
      untracked = "red bold";
    };
  };
  programs.browserpass.enable = true;
  programs.browserpass.browsers = [ "firefox" "chrome" ];

  programs.ssh.enable = true;
  programs.ssh.matchBlocks = (import ./mySSHConfigs {
    inherit pkgs;
    workInfo = pkgs.workInfo;
    idRsa = toString ./myKeys/private/id_rsa;
    workRsa = toString ./myKeys/private/work_rsa;
    workEsRsa = toString ./myKeys/private/work_es_rsa;
    stageApops = toString ./myKeys/private/stage-apops;
    mysqlAccess = toString ./myKeys/private/mysqlaccess;
  });

  home.packages = import ./myInstalls/homes { inherit pkgs hostName;};

  programs.zsh.enable = true;
  programs.zsh.enableAutosuggestions = true;
  programs.zsh.oh-my-zsh.enable = true;
  programs.zsh.oh-my-zsh.plugins = [
    "aws"
    "command-not-found"
    "direnv"
    "docker"
    "docker-compose"
    "fasd"
    "git"
    "gitfast"
    "jira"
    "lxd"
    "npm"
    "pass"
    "sudo"
  ];
  programs.zsh.oh-my-zsh.custom = "${homeDirectory}/.zsh_custom";
  programs.zsh.oh-my-zsh.theme = "powerlevel9k/powerlevel9k";
  programs.zsh.shellAliases.hm =
    "home-manager -I nixpkgs=/nix/var/nix/profiles/per-user/$USER/channels/unstable";
  programs.zsh.sessionVariables.EDITOR = "vim";
  programs.zsh.sessionVariables.PAGER = "less";
  programs.zsh.sessionVariables.DIRENV_LOG_FORMAT = "";
  programs.zsh.sessionVariables.NIX_AUTO_RUN =
    "1"; # NixOS Auto-installs a program when called, temporarily
  programs.zsh.sessionVariables.TERM = "xterm-256color";
  programs.zsh.sessionVariables.TERMINFO = "${pkgs.kitty}/lib/kitty/terminfo";

  home.file.".zsh_custom/themes/powerlevel9k".source =
    "${pkgs.zsh-powerlevel9k}/share/zsh-powerlevel9k";
  home.file.".zsh_custom/plugins/wakatime".source =
    "${pkgs.myPkgs.wakatime-zsh-plugin}";
}

