with import <nixpkgs> { };

let
  pinned = {
    elasticMqPkgs = (import (fetchTarball
      # Pinned to elasticmq-server-bin-0.14.6
      "https://github.com/NixOS/nixpkgs/archive/d8aee48e778a7d63d3782d389d4c67ba4a9187fb.tar.gz")
      { }).pkgs;
    phpPkgs = (import (fetchTarball
      # Pinned to just before 7.4 support was dropped
      "https://github.com/NixOS/nixpkgs/archive/ba45a559b5c42e123af07272b0241a73dcfa03b0.tar.gz")
      { }).pkgs;
  };
  projectHome = builtins.toString ./.;
  php = (pinned.phpPkgs.php74.withExtensions ({ enabled, all }:
    with all;
    enabled ++ [ xdebug memcached redis ])).buildEnv {
      # extensions = e: with e; phpBase.enabledExtensions ++ [ xdebug yaml redis ];
      extraConfig = ''
        log_errors = 1
        error_log = ${builtins.toString ./.}/.php/php_errors.log
        date.timezone = America/Los_Angeles
        xdebug.remote_enable = 1
        xdebug.remote_autostart = 1
      '';
    };
    elasticmq-server = pinned.elasticMqPkgs.elasticmq-server-bin;
in pkgs.mkShell rec {
  # This is the list of packages used for this environment:
  buildInputs = [
    php.packages.composer
    php.packages.phpstan
    php
    elasticmq-server
    pkgs.memcached
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
      ln -s ${pkgs.redis}/bin/redis-server "$PROJECT_HOME/.php/bin"
      ln -s ${elasticmq-server}/bin/elasticmq "$PROJECT_HOME/.php/bin"
      ln -s ${pkgs.memcached}/bin/memcached "$PROJECT_HOME/.php/bin"
      ln -s ${php}/bin/php "$PROJECT_HOME/.php/bin"
      ln -s ${php.packages.composer}/bin/composer "$PROJECT_HOME/.php/bin"
      ln -s ${php.packages.phpstan}/bin/phpstan "$PROJECT_HOME/.php/bin"
      if [[ ! -e "$PROJECT_HOME/config/app/dev/elasticmq.conf" ]]; then
        mkdir -p "$PROJECT_HOME/config/app/dev" && \
          cp "$PROJECT_HOME/config/app/example/elasticmq.conf" "$PROJECT_HOME/config/app/dev/elasticmq.conf"
      fi
    fi
  '';
}
