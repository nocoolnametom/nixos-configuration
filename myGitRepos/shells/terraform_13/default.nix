with import <nixpkgs> { };

let projectHome = builtins.toString ./.;
  tfPkg = pkgs.terraform_0_13;
in pkgs.mkShell rec {
  # This is the list of packages used for this environment. If it's here then it's available within
  # the shell:
  buildInputs = with pkgs; [ tfPkg ];

  # This sets up the environment within the shell, places the composer `vendor/bin` directory within
  # the path so you can run phpunit from the command line, and symlinks the installed binaries to
  # `.php/bin` so they can be used in IDEs or however you may need them.
  shellHook = ''
    if [[ -e "${projectHome}" ]]; then
      export PROJECT_HOME="${projectHome}"
      export PATH="$PROJECT_HOME/.tf/bin:$PATH"
      mkdir -p "$PROJECT_HOME/.tf"
      [[ -e "$PROJECT_HOME/.git/info/exclude" && ! `grep "^\.tf$" "$PROJECT_HOME/.git/info/exclude"` ]] && \
        echo ".tf" >> "$PROJECT_HOME/.git/info/exclude"
      rm -rf "$PROJECT_HOME/.tf/bin" && mkdir "$PROJECT_HOME/.tf/bin"
      ln -s ${tfPkg}/bin/terraform "$PROJECT_HOME/.tf/bin"
    fi
  '';
}
