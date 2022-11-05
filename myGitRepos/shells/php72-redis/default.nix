with import <nixpkgs> { };

let
  pinned = {
    phpPkgs = (import (fetchTarball
      # Pinned to just before 7.2 support was dropped
      "https://github.com/NixOS/nixpkgs/archive/db2a5bf3b90ff57f0012369543782cb36c399076.tar.gz")
      { }).pkgs;
  };
  projectHome = builtins.toString ./.;
  php = (pinned.phpPkgs.php72.withExtensions
    ({ enabled, all }: with all; enabled ++ [ xdebug yaml redis ])).buildEnv {
      # extensions = e: with e; phpBase.enabledExtensions ++ [ xdebug yaml];
      extraConfig = ''
        log_errors = 1
        error_log = ${builtins.toString ./.}/.php/php_errors.log
        date.timezone = America/Los_Angeles
        xdebug.remote_enable = 1
        xdebug.remote_autostart = 1
      '';
    };
in pkgs.mkShell rec {
  # This is the list of packages used for this environment:
  buildInputs = [
    php.packages.composer
    php.packages.phpstan
    php
    pkgs.redis
    pkgs.git
  ];

  shellHook = ''
    if [[ -e "${projectHome}" ]]; then
      export PROJECT_HOME="${projectHome}"
      export PATH="$PROJECT_HOME/.php/bin:$PROJECT_HOME/vendor/bin:$PATH"
      [[ -e "$PROJECT_HOME/.git/info/exclude" && ! `grep "^\.php$" "$PROJECT_HOME/.git/info/exclude"` ]] && \
        echo ".php" >> "$PROJECT_HOME/.git/info/exclude"
      rm -Rf "$PROJECT_HOME/.php" && mkdir -p "$PROJECT_HOME/.php/bin"
      ln -s ${pkgs.redis}/bin/redis "$PROJECT_HOME/.php/bin"
      ln -s ${php}/bin/php "$PROJECT_HOME/.php/bin"
      ln -s ${php.packages.composer}/bin/composer "$PROJECT_HOME/.php/bin"
      ln -s ${php.packages.phpstan}/bin/phpstan "$PROJECT_HOME/.php/bin"
    fi
  '';
}
