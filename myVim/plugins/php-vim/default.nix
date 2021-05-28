{ pkgs ? (import <nixpkgs> { }), ... }:

pkgs.vimUtils.buildVimPluginFrom2Nix {
  pname = "php-vim";
  version = "1.2.0-20190325";
  src = pkgs.fetchFromGitHub {
    owner = "StanAngeloff";
    repo = "php.vim";
    rev = "bbad8f6";
    sha256 = "1cgsigripdzhwlzyplppv54n4dsgcl64cvfma7b9s0fvgmba3y76";
  };
}
