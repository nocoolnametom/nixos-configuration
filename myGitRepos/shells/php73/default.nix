with import <nixpkgs> { };

let
  pinned = {
    phpPkgs = (import (fetchTarball
      # Pinned to just before 7.3 support was dropped
      "https://github.com/NixOS/nixpkgs/archive/68c650d0f4003285dfa4715ebd211e726b3ac964.tar.gz")
      { }).pkgs;
  };
  projectHome = builtins.toString ./.;
  php = (pinned.phpPkgs.php73.withExtensions
    ({ enabled, all }: with all; enabled ++ [ xdebug yaml ])).buildEnv {
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
    pkgs.git
  ];

  shellHook = ''
    if [[ -e "${projectHome}" ]]; then
      export PROJECT_HOME="${projectHome}"
      export PATH="$PROJECT_HOME/.php/bin:$PROJECT_HOME/vendor/bin:$PATH"
      [[ -e "$PROJECT_HOME/.git/info/exclude" && ! `grep "^\.php$" "$PROJECT_HOME/.git/info/exclude"` ]] && \
        echo ".php" >> "$PROJECT_HOME/.git/info/exclude"
      rm -Rf "$PROJECT_HOME/.php" && mkdir -p "$PROJECT_HOME/.php/bin"
      ln -s ${php}/bin/php "$PROJECT_HOME/.php/bin"
      ln -s ${php.packages.composer}/bin/composer "$PROJECT_HOME/.php/bin"
      ln -s ${php.packages.phpstan}/bin/phpstan "$PROJECT_HOME/.php/bin"
    fi
  '';
}
