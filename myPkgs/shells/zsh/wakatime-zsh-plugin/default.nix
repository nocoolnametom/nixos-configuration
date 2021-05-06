{ pkgs ? import <nixpkgs> { }, ... }:

with pkgs;
stdenv.mkDerivation rec {
  version = "0.2.1";
  baseName = "wakatime-zsh-plugin";
  name = "${baseName}-${version}";

  src = fetchFromGitHub {
    rev = "7ccbc8d";
    owner = "sobolevn";
    repo = baseName;
    sha256 = "0vb3l22vz4pc45111zdp0w430hhkdd7449xks2q9m160x8vx9qxf";
  };

  installPhase = ''
    mkdir -p $out
    cp -a * $out/
  '';
}
