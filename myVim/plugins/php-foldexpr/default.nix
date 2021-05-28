{ pkgs ? (import <nixpkgs> { }), ... }:

pkgs.vimUtils.buildVimPlugin {
  pname = "php-foldexpr.vim";
  version = "1.2";
  src = pkgs.fetchFromGitHub {
    owner = "swekaj";
    repo = "php-foldexpr.vim";
    rev = "1.2";
    sha256 = "0pcxdaxj95ja5vyg7s0zgzbg2khxffpydjd41mnk135l3zfysg6r";
  };
}