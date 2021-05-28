{ pkgs ? (import <nixpkgs> { }), lib ? pkgs.lib, ... }:

let
  plugins = [ 
    # Put the NPM name of the package here and make sure it's also build as part of myPkgs!
    "coc-phpls"
  ];
  myPkgs = (import ../../../myPkgs { inherit pkgs; });
  nodePackage2VimPackage = name: pkgs.vimUtils.buildVimPluginFrom2Nix {
      # pname = lib.last (lib.splitString "/" name);
      pname = name;
      inherit (myPkgs.${name}) version meta;
      src = "${myPkgs.${name}}/lib/node_modules/${name}";
    };
in (lib.genAttrs plugins nodePackage2VimPackage) // {
  # This is the easiest way for namespaced NPM packages
  coc-intelephense = let name = "@yaegassy/coc-intelephense"; in pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "coc-intelephense";
    inherit (myPkgs.${name}) version meta;
    src = "${myPkgs.${name}}/lib/node_modules/${name}";
  };
}
