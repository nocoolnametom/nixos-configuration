with import <nixpkgs> { };

pkgs.mkShell rec {
  # This is the list of packages used for this environment:
  buildInputs = with pkgs; [
    git
    docker
    docker-compose
    nodejs
    nodePackages.node-gyp
  ];

  shellHook = ''
  '';

}
