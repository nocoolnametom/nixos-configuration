# with import <nixpkgs> { };
# Pinned to just before 7.2 support was dropped
with import (fetchTarball
  "https://github.com/NixOS/nixpkgs-channels/archive/705cd7f814ba224189647ae494a51fd2ee06b44f.tar.gz")
  { };

let
  projectHome = builtins.toString ./.;
  php = pkgs.php71;
in pkgs.mkShell rec {
  # This is the list of packages used for this environment:
  buildInputs = with pkgs; [
    php71Packages.composer
    php71Packages.phpstan
    php
    git
  ];

  shellHook = ''
    if [[ -e "${projectHome}" ]]; then
      export PROJECT_HOME="${projectHome}"
      export PATH="$PROJECT_HOME/.php/bin:$PROJECT_HOME/vendor/bin:$PATH"
      [[ -e "$PROJECT_HOME/.git/info/exclude" && ! `grep "^\.php$" "$PROJECT_HOME/.git/info/exclude"` ]] && \
        echo ".php" >> "$PROJECT_HOME/.git/info/exclude"
      rm -Rf "$PROJECT_HOME/.php" && mkdir -p "$PROJECT_HOME/.php/bin"
      ln -s ${php}/bin/php "$PROJECT_HOME/.php/bin"
      ln -s ${php71Packages.composer}/bin/composer "$PROJECT_HOME/.php/bin"
      ln -s ${php71Packages.phpstan}/bin/phpstan "$PROJECT_HOME/.php/bin"
    fi
  '';
}
