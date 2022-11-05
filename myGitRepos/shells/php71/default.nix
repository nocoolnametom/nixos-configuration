 with import <nixpkgs> { };

let
  pinned = {
    phpPkgs = (import (fetchTarball
      # Pinned to just before 7.1 support was dropped
      "https://github.com/NixOS/nixpkgs/archive/705cd7f814ba224189647ae494a51fd2ee06b44f.tar.gz")
      { }).pkgs;
  };
  projectHome = builtins.toString ./.;
  php = pinned.phpPkgs.php71;
  phpPackages = pinned.phpPkgs.php71Packages;
in pkgs.mkShell rec {
  # This is the list of packages used for this environment:
  buildInputs = [
    phpPackages.composer
    phpPackages.phpstan
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
      ln -s ${phpPackages.composer}/bin/composer "$PROJECT_HOME/.php/bin"
      ln -s ${phpPackages.phpstan}/bin/phpstan "$PROJECT_HOME/.php/bin"
    fi
  '';
}
