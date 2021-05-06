with import <nixpkgs> { };

let
  projectHome = builtins.toString ./.;
  kibana = pkgs.stdenv.mkDerivation rec {
    name = "wrapped-kibana";
    version = pkgs.kibana.version;
    original = pkgs.kibana;
    phases = [ "installPhase" ];
    buildInputs = [ pkgs.makeWrapper ];
    installPhase = ''
      mkdir -p $out/bin
      ln -s ${pkgs.kibana}/bin/kibana $out/bin/kibana
      wrapProgram $out/bin/kibana --add-flags "-c ${
        builtins.toString ./.
      }/.kibana/config/kibana.yml"
    '';
  };
in pkgs.mkShell rec {
  # This is the list of packages used for this environment. If it's here then it's available within
  # the shell:
  buildInputs = with pkgs; [ elasticsearch kibana nodejs scala sbt ];

  # This sets up the environment within the shell, places the composer `vendor/bin` directory within
  # the path so you can run phpunit from the command line, and symlinks the installed binaries to
  # `.php/bin` so they can be used in IDEs or however you may need them.
  shellHook = ''
    if [[ -e "${projectHome}" ]]; then
      export PROJECT_HOME="${projectHome}"
      export PATH="$PROJECT_HOME/.node/bin:$PROJECT_HOME/node_modules/.bin:$PATH"
      [[ -e "$PROJECT_HOME/.git/info/exclude" && ! `grep "^\.kibana$" "$PROJECT_HOME/.git/info/exclude"` ]] && \
        echo ".kibana" >> "$PROJECT_HOME/.git/info/exclude"
      mkdir -p "$PROJECT_HOME/.kibana/{config,data}"
      export KIBANA_HOME="$PROJECT_HOME/.kibana"
      export BABEL_CACHE_PATH="$PROJECT_HOME/.kibana/data/.babelcache.json"
      [[ ! -e "$PROJECT_HOME/.kibana/config/kibana.yml" ]] && cp -a ${pkgs.kibana}/libexec/kibana/* "$PROJECT_HOME/.kibana/" && chmod -R 777 "$PROJECT_HOME/.kibana" && \
        echo "path.data: \"$PROJECT_HOME/.kibana/data\"" >> "$PROJECT_HOME/.kibana/config/kibana.yml"
      [[ -e "$PROJECT_HOME/.git/info/exclude" && ! `grep "^\.elasticsearch$" "$PROJECT_HOME/.git/info/exclude"` ]] && \
        echo ".elasticsearch" >> "$PROJECT_HOME/.git/info/exclude"
      mkdir -p "$PROJECT_HOME/.elasticsearch/{data,logs,config}"
      export ES_HOME=${pkgs.elasticsearch}
      export ES_PATH_CONF="$PROJECT_HOME/.elasticsearch/config"
      [[ ! -e "$PROJECT_HOME/.elasticsearch/config/jvm.options" ]] && cp ${pkgs.elasticsearch}/config/jvm.options "$PROJECT_HOME/.elasticsearch/config/jvm.options" && chmod 777 "$PROJECT_HOME/.elasticsearch/config/jvm.options"
      [[ ! -e "$PROJECT_HOME/.elasticsearch/config/log4j2.properties" ]] && cp ${pkgs.elasticsearch}/config/log4j2.properties "$PROJECT_HOME/.elasticsearch/config/log4j2.properties" && chmod 777 "$PROJECT_HOME/.elasticsearch/config/log4j2.properties"
      [[ ! -e "$PROJECT_HOME/.elasticsearch/config/elasticsearch.yml" ]] && cp ${pkgs.elasticsearch}/config/elasticsearch.yml "$PROJECT_HOME/.elasticsearch/config/elasticsearch.yml" && chmod 777 "$PROJECT_HOME/.elasticsearch/config/elasticsearch.yml" && \
        echo "path.data: \"$PROJECT_HOME/.elasticsearch/data\"" >> "$PROJECT_HOME/.elasticsearch/config/elasticsearch.yml" && \
        echo "path.logs: \"$PROJECT_HOME/.elasticsearch/logs\"" >> "$PROJECT_HOME/.elasticsearch/config/elasticsearch.yml"
      mkdir -p "$PROJECT_HOME/.node"
      [[ -e "$PROJECT_HOME/.git/info/exclude" && ! `grep "^\.node$" "$PROJECT_HOME/.git/info/exclude"` ]] && \
        echo ".node" >> "$PROJECT_HOME/.git/info/exclude"
      rm -rf "$PROJECT_HOME/.node/bin" && mkdir "$PROJECT_HOME/.node/bin"
      ln -s ${nodejs}/bin/nodejs "$PROJECT_HOME/.node/bin"
    fi
  '';
}
