with import <nixpkgs> {
  overlays = [
    (self: super: {
      elasticmq-server = self.stdenv.mkDerivation rec {
        name = "elasticmq-server-${version}";
        version = "0.13.11";

        src = self.fetchurl {
          url =
            "https://s3-eu-west-1.amazonaws.com/softwaremill-public/elasticmq-server-${version}.jar";
          sha256 =
            "ce13dc295a77feaa3d279a298c9049237eb2b3b58cb51a315ad27506fb2c2d49";
        };

        unpackPhase = ":";

        buildInputs = [ self.jre self.makeWrapper ];

        installPhase = ''
          mkdir -p $out/{bin,lib}
          install -D $src $out/lib/elasticmq-server.jar
          makeWrapper ${self.jre}/bin/java $out/bin/elasticmq \
            --add-flags "-Dconfig.file=${
              ./.
            }/config/app/dev/elasticmq.conf -jar $out/lib/elasticmq-server.jar"
        '';
      };
    })
  ];
};

let
  projectHome = builtins.toString ./.;
  php = (pkgs.php73.withExtensions ({ enabled, all }:
    with all;
    enabled ++ [ xdebug memcached redis ])).buildEnv {
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
    php.packages.composer
    php.packages.phpstan
    php
    elasticmq-server
    memcached
    redis
    git
  ];

  shellHook = ''
    if [[ -e "${projectHome}" ]]; then
      export PROJECT_HOME="${projectHome}"
      export PATH="$PROJECT_HOME/.php/bin:$PROJECT_HOME/vendor/bin:$PATH"
      [[ -e "$PROJECT_HOME/.git/info/exclude" && ! `grep "^\.php$" "$PROJECT_HOME/.git/info/exclude"` ]] && \
        echo ".php" >> "$PROJECT_HOME/.git/info/exclude"
      rm -Rf "$PROJECT_HOME/.php" && mkdir -p "$PROJECT_HOME/.php/bin"
      ln -s ${redis}/bin/redis "$PROJECT_HOME/.php/bin"
      ln -s ${elasticmq-server}/bin/elasticmq "$PROJECT_HOME/.php/bin"
      ln -s ${memcached}/bin/memcached "$PROJECT_HOME/.php/bin"
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
