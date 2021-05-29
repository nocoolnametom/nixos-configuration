[
  (import ./myPkgs/overlay.nix)
  (self: super: {
    workInfo = if super.lib.pathExists ./workInfo.nix then
      (import ./workInfo.nix { pkgs = super; })
    else
      (import ./workInfo_example.nix { pkgs = super; });
  })
  (import ./myGitRepos/overlay.nix)
]
