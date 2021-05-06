with import <nixpkgs> { };

let
  projectHome = builtins.toString ./.;
  workInfo = (if lib.pathExists ../../workInfo.nix then
    (import ../../workInfo.nix { inherit pkgs; })
  else {
    currentBrandStagingDomain = "stage.sample-amazon.com";
  });
in pkgs.mkShell rec {
  # This is the list of packages used for this environment. If it's here then it's available within
  # the shell:
  buildInputs = with pkgs;
    [
      libressl
      terraform
      ansible
      docker
      python2
      python2Packages.virtualenv
      python2Packages.pip
      python2Packages.cffi
      python2Packages.cryptography
    ] ++ (if pkgs.stdenv.isDarwin then [ pkgs.darwin.cctools ] else [ ]);

  shellHook = ''
    if [[ -e "${projectHome}" ]]; then
      export PROJECT_HOME="${projectHome}"
      [[ -e "$PROJECT_HOME/.git/info/exclude" && ! `grep "^\.cache$" "$PROJECT_HOME/.git/info/exclude"` ]] && \
        echo ".cache" >> "$PROJECT_HOME/.git/info/exclude"
      mkdir -p "$PROJECT_HOME/.cache"
      chmod 777 "$PROJECT_HOME/.cache"
      if [[ ! -e "$PROJECT_HOME/.cache/apopsclient" ]]; then
        ${python2Packages.virtualenv}/bin/virtualenv "$PROJECT_HOME/.cache/apopsclient"
        source "$PROJECT_HOME/.cache/apopsclient/bin/activate"
        "$PROJECT_HOME/.cache/apopsclient/bin/pip" install --extra-index-url https://pypi.${workInfo.currentBrandStagingDomain} apopscli
      else
        source "$PROJECT_HOME/.cache/apopsclient/bin/activate"
      fi
    fi
  '';
}
