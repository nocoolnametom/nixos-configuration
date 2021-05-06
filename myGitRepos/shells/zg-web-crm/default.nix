with import <nixpkgs> { };

let
  projectHome = builtins.toString ./.;
  php = (pkgs.php73.withExtensions
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
  buildInputs = with pkgs; [
    git
    cacert
    docker
    docker-compose
    compass
    ruby.devEnv
    gnumake
    php.packages.composer
    php.packages.phpstan
    php
    nodejs
    nodePackages.node-gyp
  ];

  shellHook = ''
    if [[ -e "${projectHome}" ]]; then
      export PROJECT_HOME="${projectHome}"
      export PATH="$PROJECT_HOME/.node/bin:$PROJECT_HOME/.php/bin:$PROJECT_HOME/node_modules/.bin:$PROJECT_HOME/vendor/bin:$PATH"
      export GEM_HOME=./.ruby/gem
      export BUNDLE_PATH=./.ruby/gem
      export GIT_SSL_CAINFO="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      [[ -e "$PROJECT_HOME/.git/info/exclude" && ! `grep "^\.php$" "$PROJECT_HOME/.git/info/exclude"` ]] && \
        echo ".php" >> "$PROJECT_HOME/.git/info/exclude"
      [[ -e "$PROJECT_HOME/.git/info/exclude" && ! `grep "^\.node$" "$PROJECT_HOME/.git/info/exclude"` ]] && \
        echo ".node" >> "$PROJECT_HOME/.git/info/exclude"
      [[ -e "$PROJECT_HOME/.git/info/exclude" && ! `grep "^\.ruby$" "$PROJECT_HOME/.git/info/exclude"` ]] && \
        echo ".ruby" >> "$PROJECT_HOME/.git/info/exclude"
      rm -Rf "$PROJECT_HOME/.php" && mkdir -p "$PROJECT_HOME/.php/bin"
      rm -Rf "$PROJECT_HOME/.node" && mkdir -p "$PROJECT_HOME/.node/bin"
      rm -Rf "$PROJECT_HOME/.ruby/bin" && mkdir -p "$PROJECT_HOME/.ruby/bin"
      ln -s ${php}/bin/php "$PROJECT_HOME/.php/bin"
      ln -s ${php.packages.composer}/bin/composer "$PROJECT_HOME/.php/bin"
      ln -s ${php.packages.phpstan}/bin/phpstan "$PROJECT_HOME/.php/bin"
      ln -s ${nodejs}/bin/nodejs "$PROJECT_HOME/.node/bin"
      ln -s ${pkgs.nodePackages.node-gyp}/bin/node-gyp "$PROJECT_HOME/.node/bin"
      ln -s ${ruby}/bin/ruby "$PROJECT_HOME/.ruby/bin"
      ln -s ${compass}/bin/compass "$PROJECT_HOME/.ruby/bin"
      ln -s ${ruby.devEnv}/bin/bundle "$PROJECT_HOME/.ruby/bin"
    fi
  '';

}
