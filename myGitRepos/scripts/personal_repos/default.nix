{ pkgs ? import <nixpkgs> { }, lib ? pkgs.lib
, personalgitclone ? pkgs.callPackage ../personalgitclone { }, shells ? { }
, personalProjectList ? { }, ... }:

let
  buildProjectList = projectList:
    lib.concatStrings (lib.mapAttrsToList (service: namespace:
      ''

        # ${service} projects
      '' + lib.concatStrings (lib.mapAttrsToList (namespace: projects:
        lib.concatMapStrings (project:
          "${personalgitclone}/bin/personalgitclone"
          + (if service == "github" then " -g" else "")
          + (if service == "gitlab" then " -b" else "")
          + (if lib.hasAttrByPath [ "shell" ] project then
            " -N ${project.shell}"
          else
            "") + (if lib.hasAttrByPath [ "new-name" ] project then
              " -n \"${project.new-name}\""
            else
              "") + (if lib.hasAttrByPath [ "directory" ] project then
                " -d \"${project.directory}\""
              else
                "") + (if lib.hasAttrByPath [ "build" ] project then
                  (if project.build then "" else " --no-build")
                else
                  "") + " --make-shell=$SHOULD_BUILD"
          + (if lib.hasPrefix "~" namespace then " \"" else " ")
          + "${namespace}" + (if lib.hasPrefix "~" namespace then ''"'' else "")
          + " ${project.repo}" + "\n") projects) namespace)) projectList);
in pkgs.writeShellScriptBin "personal_repos" ''
  export SHOULD_BUILD=0

  script="${"$"}{0##*/}"
  while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "$script - Build the entire personal project ecosystem"
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

  export URLS_ACTIVE=0 && ping -q -W1 -c1 github.com &>/dev/null && export URLS_ACTIVE=1

  if [ $URLS_ACTIVE -eq 1 ]; then

    # Remove listing of current personal git repos
    if [ -e "$HOME/.local/share/personalgits" ]; then
      rm "$HOME/.local/share/personalgits"
    fi

    ${buildProjectList personalProjectList}
  else
    echo "Your machine can't reach github.com!  Aborting..."
  fi
''
