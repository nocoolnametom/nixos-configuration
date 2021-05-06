{ pkgs ? import <nixpkgs> { }, ... }:

rec {
  zgitclone = pkgs.callPackage ./scripts/zgitclone { };
  work_repos = pkgs.callPackage ./scripts/work_repos { inherit zgitclone; };
  zg_backup = pkgs.callPackage ./scripts/zg_backup { };
  personalgitclone = pkgs.callPackage ./scripts/personalgitclone { };
  personal_repos =
    pkgs.callPackage ./scripts/personal_repos { inherit personalgitclone; };
}
