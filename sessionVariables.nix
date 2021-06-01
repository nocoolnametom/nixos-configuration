{ pkgs, config, homeDirectory, ...}: {
    EDITOR = "vim";
    PAGER = "less -R";
    DIRENV_LOG_FORMAT = "";
    NIX_AUTO_RUN = "1"; # NixOS Auto-installs a program when called, temporarily
    TERM = "xterm-256color";
    TERMINFO = "${pkgs.kitty}/lib/kitty/terminfo";
    PASSWORD_STORE_DIR = "${homeDirectory}/.password-store";
}