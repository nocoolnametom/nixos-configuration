with import <nixpkgs> { };

let projectHome = builtins.toString ./.;
in pkgs.mkShell rec {
  # This is the list of packages used for this environment. If it's here then it's available within
  # the shell:
  buildInputs = with pkgs; [ nodejs nodePackages.node-gyp ];

  # This sets up the environment within the shell, places the composer `vendor/bin` directory within
  # the path so you can run phpunit from the command line, and symlinks the installed binaries to
  # `.php/bin` so they can be used in IDEs or however you may need them.
  shellHook = ''
    if [[ -e "${projectHome}" ]]; then
      export PROJECT_HOME="${projectHome}"
      export PATH="$PROJECT_HOME/.node/bin:$PROJECT_HOME/node_modules/.bin:$PATH"
      mkdir -p "$PROJECT_HOME/.node"
      [[ -e "$PROJECT_HOME/.git/info/exclude" && ! `grep "^\.node$" "$PROJECT_HOME/.git/info/exclude"` ]] && \
        echo ".node" >> "$PROJECT_HOME/.git/info/exclude"
      rm -rf "$PROJECT_HOME/.node/bin" && mkdir "$PROJECT_HOME/.node/bin"
      ln -s ${nodejs}/bin/nodejs "$PROJECT_HOME/.node/bin"
      ln -s ${pkgs.nodePackages.node-gyp}/bin/node-gyp "$PROJECT_HOME/.node/bin"
    fi
  '';
}
