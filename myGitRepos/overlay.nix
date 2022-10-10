(self: super: {
  myGitRepos = let
    workInfo = if (super.lib.hasAttrByPath [ "workInfo" ] super) then
      super.workInfo
    else {
      currentBrand = "";
      emailAddress = "";
      gitServer = "";
    };
    scripts = import ./default.nix { pkgs = super; };
    # Load `shells` from overlaid package or load from filesystem if present
    shells = if (super.lib.hasAttrByPath [ "myGitShells" ] super) then
      super.myGitShells
    else
      super.callPackage ./shells { };
    workProjectList = (if super.lib.pathExists ../../workProjectList then
      (import ../../workProjectList { inherit shells; })
    else
      { });
    personalProjectList = import ./personalProjectList { inherit shells; };
  in rec {
    inherit (scripts) zg_backup personalgitclone;
    zgitclone = scripts.zgitclone.override {
      currentBrandShort = builtins.replaceStrings [ " " ] [ "-" ]
        (super.lib.toLower workInfo.currentBrand);
      workEmailAddress = workInfo.emailAddress;
      gitServer = workInfo.gitServer;
    };
    personal_repos =
      scripts.personal_repos.override { inherit shells personalProjectList; };
    work_repos = scripts.work_repos.override {
      inherit zgitclone shells workProjectList;
      gitServer = workInfo.gitServer;
    };
  };
})
