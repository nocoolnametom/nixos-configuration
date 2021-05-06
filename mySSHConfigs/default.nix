{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib, workInfo, idRsa ? ""
, workRsa ? "", workEsRsa ? "", stageApops ? "", mysqlAccess ? "", ... }:

{ } // (import ./personal { inherit pkgs idRsa; })
// (if lib.pathExists ./work/default.nix then
  (import ./work {
    inherit pkgs idRsa workRsa workEsRsa stageApops mysqlAccess;
    inherit (workInfo)
      gitServer currentBrandStagingDomain currentBrandProdServicesDomain;
  })
else
  { })
