# with import <nixpkgs> { };
# Pinned to just before 7.2 support was dropped
with import (fetchTarball
  "https://github.com/NixOS/nixpkgs-channels/archive/db2a5bf3b90ff57f0012369543782cb36c399076.tar.gz")
  { };

let
  projectHome = builtins.toString ./.;
  php = (pkgs.php72.withExtensions
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
  # This is the list of packages used for this environment. If it's here then it's available within
  # the shell:
  buildInputs = with pkgs; [
    php.packages.composer
    php.packages.phpstan
    php
    nodejs
    nodePackages.node-gyp
  ];

  # This sets up the environment within the shell, places the composer `vendor/bin` directory within
  # the path so you can run phpunit from the command line, and symlinks the installed binaries to
  # `.php/bin` so they can be used in IDEs or however you may need them.
  shellHook = ''
    if [[ -e "${projectHome}" ]]; then
      export PROJECT_HOME="${projectHome}"
      export PATH="$PROJECT_HOME/.node/bin:$PROJECT_HOME/.php/bin:$PROJECT_HOME/node_modules/.bin:$PROJECT_HOME/vendor/bin:$PATH"
      rm -Rf "$PROJECT_HOME/.php" && mkdir -p "$PROJECT_HOME/.php/bin"
      rm -Rf "$PROJECT_HOME/.node" && mkdir -p "$PROJECT_HOME/.node/bin"
      [[ -e "$PROJECT_HOME/.git/info/exclude" && ! `grep "^\.php$" "$PROJECT_HOME/.git/info/exclude"` ]] && \
        echo ".php" >> "$PROJECT_HOME/.git/info/exclude"
      [[ -e "$PROJECT_HOME/.git/info/exclude" && ! `grep "^\.node$" "$PROJECT_HOME/.git/info/exclude"` ]] && \
        echo ".node" >> "$PROJECT_HOME/.git/info/exclude"
      ln -s ${php}/bin/php "$PROJECT_HOME/.php/bin"
      ln -s ${php.packages.composer}/bin/composer "$PROJECT_HOME/.php/bin"
      ln -s ${php.packages.phpstan}/bin/phpstan "$PROJECT_HOME/.php/bin"
      ln -s ${nodejs}/bin/nodejs "$PROJECT_HOME/.node/bin"
      ln -s ${pkgs.nodePackages.node-gyp}/bin/node-gyp "$PROJECT_HOME/.node/bin"
    fi
  '';
}
