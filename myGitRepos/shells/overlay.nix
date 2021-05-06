(self: super: {
  myGitShells = let shells = super.callPackage ./default.nix { };
  in rec {
    inherit (shells)
      node php72 php72-redis php72AndNode php73 php73-redis php73AndNode php74
      zg-apops zg-crm-messagetemplate-bundle zg-crm-search-index-batch-job
      zg-dispatcher-model zg-goodcop zg-leadrouting-handler zg-web-crm;
  };
})
