{ pkgs ? (import <nixpkgs> { }), ... }:

pkgs.vimUtils.buildVimPlugin {
  pname = "vim-php-cs-fixer";
  version = "1.0.0-20210325";
  src = pkgs.fetchFromGitHub {
    owner = "stephpy";
    repo = "vim-php-cs-fixer";
    rev = "63f59b4";
    sha256 = "1h2srg19dl0wvvq9hfgmq1pkqs3h1h1ks757fn88bp94i077xv44";
  };
}
