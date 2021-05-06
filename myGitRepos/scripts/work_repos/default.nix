{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib
, zgitclone ? pkgs.callPackage ../zgitclone { }, gitServer ? "git.example.com"
, shells ? { }, workProjectList ? { }, ... }:

let
  buildProjectList = projectList:
    lib.concatStrings (lib.mapAttrsToList (directory: projects:
      lib.concatMapStrings (project:
        "${zgitclone}/bin/zgitclone"
        + (if lib.hasAttrByPath [ "shell" ] project then
          " -N ${project.shell}"
        else
          "") + (if lib.hasAttrByPath [ "new-name" ] project then
            " -n \"${project.new-name}\""
          else
            "") + (if lib.hasAttrByPath [ "directory" ] project then
              " -d \"${project.directory}\""
            else
              (if directory != "default" then " -d \"${directory}\"" else ""))
        + (if lib.hasAttrByPath [ "build" ] project then
          (if project.build then "" else " --no-build")
        else
          "") + " --make-shell=$SHOULD_BUILD" + " ${project.repo}" + "\n")
      projects) projectList);
in pkgs.writeShellScriptBin "work_repos" (''
  export SHOULD_BUILD=0

  script="${"$"}{0##*/}"
  while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "$script - Build the entire work project ecosystem"
      echo " "
      echo "$script [options]"
      echo " "
      echo "options:"
      echo "-h, --help       show brief help"
      echo "--build-shells   build all applicable Nix shells"
      exit 0
      ;;
    --build-shells*)
      export SHOULD_BUILD=1
      shift
      ;;
    *)
      break
      ;;
    esac
  done

  export URLS_ACTIVE=0 && curl -I -m 1 -X GET "${gitServer}" &>/dev/null && export URLS_ACTIVE=1

  if [ $URLS_ACTIVE -eq 1 ]; then

    # Remove listing of current work git repos
    if [ -e ${builtins.getEnv "HOME"}/.local/share/workgits ]; then
      rm ${builtins.getEnv "HOME"}/.local/share/workgits
    fi

    ${buildProjectList workProjectList}
  else
    echo "Your machine can't reach ${gitServer}!  Aborting..."
  fi
'')
