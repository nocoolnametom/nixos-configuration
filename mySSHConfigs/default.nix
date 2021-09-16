{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib, workInfo, idRsa ? ""
, workRsa ? "", workEsRsa ? "", stageApops ? "", meadowApops ? "", mysqlAccess ? "", ... }:

{ } // (import ./personal { inherit pkgs idRsa; })
// (if lib.pathExists ./work/default.nix then
  (import ./work {
    inherit pkgs idRsa workRsa workEsRsa stageApops mysqlAccess meadowApops;
    inherit (workInfo)
      gitServer currentBrandStagingDomain currentBrandProdServicesDomain;
  })
else
  { })
