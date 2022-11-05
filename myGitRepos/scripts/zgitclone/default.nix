{ pkgs ? import <nixpkgs> { }, stdenv ? pkgs.stdenv, lib ? pkgs.lib
, projectsDir ? "Projects"
, workEmailAddress ? "tdoggett@example.com", currentBrandShort ? "current-brand"
, gitServer ? "git.example.com", ... }:

let nixpkgsChannel = "nixpkgs-unstable";

in pkgs.writeShellScriptBin "zgitclone" ''
  export DIR=""
  export TEAM_DIR="/itx/${currentBrandShort}/sfo/"
  export NAME=""
  export SHOULD_BUILD=1
  export NIX_SHELL=""
  export MAKE_SHELL=0
  export NIXPKGS_HASH=""
  script="${"$"}{0##*/}"
  while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "$script - Clone a work git project"
      echo " "
      echo "$script [options] projectName"
      echo " "
      echo "options:"
      echo "-h, --help                show brief help"
      echo "-n, --name=NAME           specify the directory name (default is projectName)"
      echo "-d, --team-dir=TEAM_DIR   specify a directory path (default is /itx/${currentBrandShort}/sfo/)"
      echo "--no-build                do not run automatic dependency building"
      echo "-N, --nix-shell=<path>    path to a nix file to copy as shell.nix"
      echo "--make-shell=[0,1]        whether or not to build the shell environment"
      echo "-z, --hash                hash for pinning nixpkgs"
      exit 0
      ;;
    -n)
      shift
      if test $# -gt 0; then
        export NAME="$1"
      else
        echo "no name specified"
        exit 1
      fi
      shift
      ;;
    --name*)
      export NAME=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    -z)
      shift
      if test $# -gt 0; then
        export NIXPKGS_HASH="$1"
      else
        echo "no hash specified"
        exit 1
      fi
      shift
      ;;
    --hash*)
      export NIXPKGS_HASH=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    -d)
      shift
      if test $# -gt 0; then
        export TEAM_DIR="$1"
      else
        echo "no directory path specified"
        exit 1
      fi
      shift
      ;;
    --output-dir*)
      export TEAM_DIR=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    --no-build*)
      export SHOULD_BUILD=0
      shift
      ;;
    -N)
      shift
      if test $# -gt 0; then
        export NIX_SHELL="$1"
      else
        echo "no nix file specified"
        exit 1
      fi
      shift
      ;;
    --nix-shell*)
      export NIX_SHELL=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    --make-shell*)
      export MAKE_SHELL=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    *)
      break
      ;;
    esac
  done

  export PROJECT_NAME=$1
  export TEAM_DIR=${"$"}{TEAM_DIR%/}
  export TEAM_DIR=${"$"}{TEAM_DIR#/}
  export TEAM_NAME=${"$"}{STASH_TEAM_NAME//\~/_}
  export PROJECT_NAME=${"$"}{PROJECT_NAME//\~/_}
  if [[ -z "$HOME" ]] ; then
    export HOME="~"
  fi

  if [[ -z "$NAME" ]] ; then
    export NAME="$PROJECT_NAME"
  fi

  export SERVICE_HOST="zgtools"

  if [[ ! -z "$NIX_SHELL" && ${"$"}{NIX_SHELL: -4} != ".nix" ]] ; then
    export NIX_SHELL="$NIX_SHELL/default.nix"
  fi

  if [[ ! -z "$NIX_SHELL" && ! -e "$NIX_SHELL" ]] ; then
    export NIX_SHELL=""
  fi

  if [[ $# -eq 0 ]] ; then
    script="${"$"}{0##*/}"
    echo "Missing projectName"
    $script --help
    exit 0
  fi

  export DIR="$HOME/${projectsDir}/$TEAM_DIR/$NAME"

  if [ ! -d "$DIR" ] ; then
    mkdir -p "$DIR"
    git clone -q --depth=1 "$SERVICE_HOST:$TEAM_DIR/$PROJECT_NAME.git" "$DIR"
  fi
  if [ ! -d "$DIR/.git" ] ; then
    exit
  fi

  mkdir -p "$HOME/.local/share"
  echo "$DIR" >> "$HOME/.local/share/workgits"

  cd "$DIR"

  if [[ -z `git remote get-url zgitlab 2> /dev/null` ]]; then
    git remote add zgitlab "https://${gitServer}/$TEAM_DIR/$PROJECT_NAME.git"
  fi

  git config user.name "Tom Doggett"
  git config user.email "${workEmailAddress}"

  if [[ ! -z "$NIX_SHELL" && -e "$NIX_SHELL" && ! -e ./shell.nix ]]; then
    cp "$NIX_SHELL" ./shell.nix
    if [[ -z "$NIXPKGS_HASH" ]]; then
      NIXPKGS_HASH=`git ls-remote https://github.com/NixOS/nixpkgs.git refs/heads/${nixpkgsChannel} | cut -f 1`
    fi
    sed -i.bak "s~<nixpkgs>~(fetchTarball https://github.com/NixOS/nixpkgs/archive/$NIXPKGS_HASH.tar.gz)~" shell.nix && rm -f shell.nix.bak
    sed -i.bak "s~my_overlay = import.*;~my_overlay = import ${
      toString ../../../overlays.nix
    };~" shell.nix && rm -f shell.nix.bak
    sed -i.bak "s~[\./]\+workInfo\.nix~${
      builtins.toString ../../../../workInfo.nix
    }~" shell.nix && rm -Rf shell.nix.bak
    if [[ ! `git ls-files -o | grep shell.nix` ]] ; then
      git update-index --skip-worktree shell.nix
    fi
  fi

  if [[ ! -z "$NIX_SHELL" && -e "$NIX_SHELL" && -e ./shell.nix && ! -e ./.envrc ]]; then
    echo "eval \"\$(lorri direnv)\"
      eval \"\$shellHook\"
      export GEM_HOME=./.ruby/gem
      export BUNDLE_PATH=./.ruby/gem" > ./.envrc
    [[ -e ./.git/info/exclude && ! `grep "^\.envrc$" ./.git/info/exclude` ]] && \
      echo ".envrc" >> ./.git/info/exclude
    ${pkgs.direnv}/bin/direnv allow
  fi

  mkdir -p .git/info && touch .git/info/exclude && [[ ! `grep "^shell.nix$" .git/info/exclude`  ]] && echo "shell.nix" >> .git/info/exclude

  if [[ $SHOULD_BUILD -eq 1 ]] ; then
    if [[ ! -z "$NIX_SHELL" ]] ; then
      if [[ $MAKE_SHELL -eq 1 ]] ; then
        nix-shell --pure --command ":"
        ${pkgs.coreutils}/bin/timeout 10 lorri watch
      fi

      if [[ -e Gemfile && ! -e Gemfile.lock ]] ; then
        nix-shell --pure --command "bundle install > /dev/null 2>&1"
        ${pkgs.coreutils}/bin/timeout 10 lorri watch
      fi

      if [[ -e package.json && ! -d node_modules ]] ; then
        nix-shell --pure --command "npm ci --progress=false --silent --quiet > /dev/null 2>&1"
        ${pkgs.coreutils}/bin/timeout 10 lorri watch
      fi

      if [[ -e composer.json && ! -d vendor ]] ; then
        nix-shell --pure --command "COMPOSER_MEMORY_LIMIT=-1 composer install -n -q"
        ${pkgs.coreutils}/bin/timeout 10 lorri watch
      fi
    else
      if [[ -e package.json && ! -d node_modules ]] ; then
        ${pkgs.nodejs}/bin/npm ci --progress=false --silent --quiet > /dev/null 2>&1
      fi

      if [[ -e Gemfile && ! -e Gemfile.lock ]] ; then
        ${pkgs.ruby.devEnv}/bin/bundle install > /dev/null 2>&1
      fi

      if [[ -e composer.json && ! -d vendor ]] ; then
        COMPOSER_MEMORY_LIMIT=-1 ${pkgs.phpPackages.composer}/bin/composer install -n -q
      fi
    fi
  fi

  cd - > /dev/null;
''
