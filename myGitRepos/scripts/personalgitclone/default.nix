{ pkgs ? import <nixpkgs> { }, stdenv ? pkgs.stdenv
, projectsDir ? "Projects", ... }:

let nixpkgsChannel = "nixpkgs-unstable";
in pkgs.writeShellScriptBin "personalgitclone" ''
  export DIR=""
  export NAME=""
  export SHOULD_BUILD=1
  export NIX_SHELL=""
  export MAKE_SHELL=0
  # Default service is Github
  export USE_GITHUB=1
  export USE_GITLAB=0
  export PIN=0
  script="${"$"}{0##*/}"
  while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "$script - Clone a personal git project"
      echo " "
      echo "$script [options] username repoName"
      echo " "
      echo "options:"
      echo "-h, --help                show brief help"
      echo "-g, --github              use Github as the remote service [default]"
      echo "-b, --gitlab              use Gitlab as the remote service"
      echo "-n, --name=NAME           specify the directory name (default is repoName)"
      echo "-d, --output-dir=DIR      specify an absolute directory path (default is ~/${projectsDir}/<userName>/<repoName>)"
      echo "--no-build                do not run automatic dependency building"
      echo "-N, --nix-shell=<path>    path to a nix file to copy as shell.nix"
      echo "-p, --pin                 pin the nixpkgs for the shell.nix if given"
      echo "--make-shell=[0,1]        whether or not to build the shell environment"
      exit 0
      ;;
    -g|--github)
      export USE_GITHUB=1
      export USE_GITLAB=0
      shift
      ;;
    -b|--gitlab)
      export USE_GITHUB=0
      export USE_GITLAB=1
      shift
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
    -d)
      shift
      if test $# -gt 0; then
        export DIR="$1"
      else
        echo "no directory path specified"
        exit 1
      fi
      shift
      ;;
    --output-dir*)
      export DIR=`echo $1 | sed -e 's/^[^=]*=//g'`
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
    -p|--pin)
      export PIN=1
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

  export REMOTE_USER_NAME=$1
  export REMOTE_PROJECT_NAME=$2
  export USER_NAME=${"$"}{REMOTE_USER_NAME//\~/_}
  export PROJECT_NAME=${"$"}{REMOTE_PROJECT_NAME//\~/_}
  if [[ -z "$HOME" ]] ; then
    export HOME="~"
  fi

  if [[ -z "$NAME" ]] ; then
    export NAME="$PROJECT_NAME"
  fi

  if [[ $USE_GITHUB -eq 1 ]] ; then
    export SERVICE_HOST="github"
  fi
  if [[ $USE_GITLAB -eq 1 ]] ; then
    export SERVICE_HOST="gitlab"
  fi

  export MY_SERVICE_PATH="$SERVICE_HOST:nocoolnametom"

  if [[ ! -z "$NIX_SHELL" && ${"$"}{NIX_SHELL: -4} != ".nix" ]] ; then
    export NIX_SHELL="$NIX_SHELL/default.nix"
  fi

  if [[ ! -z "$NIX_SHELL" && ! -e "$NIX_SHELL" ]] ; then
    export NIX_SHELL=""
  fi

  if [[ $# -eq 0 || $# -eq 1 ]] ; then
    script="${"$"}{0##*/}"
    echo "Missing userName and/or repoName"
    $script --help
    exit 0
  fi

  if [[ -z "$DIR" ]] ; then
    export DIR="$HOME/${projectsDir}/$USER_NAME/$NAME"
  fi

  if [ ! -d "$DIR" ] ; then
    mkdir -p "$DIR"
    git clone -q --depth=1 "$SERVICE_HOST:$REMOTE_USER_NAME/$REMOTE_PROJECT_NAME.git" "$DIR"
  fi
  if [ ! -d "$DIR/.git" ] ; then
    exit
  fi

  mkdir -p "$HOME/.local/share"
  echo "$DIR" >> "$HOME/.local/share/personalgits"

  cd "$DIR"

  if [[ $USE_GITLAB -eq 1 && -z `git remote get-url gitlabhttp 2> /dev/null` ]]; then
    git remote add gitlabhttp "https://gitlab.com/$REMOTE_USER_NAME/$REMOTE_PROJECT_NAME.git"
  fi

  git remote set-url --push origin "$MY_SERVICE_PATH/$PROJECT_NAME.git"
  git config user.name "Tom Doggett"
  git config user.email "nocoolnametom@gmail.com"

  if [[ ! -z "$NIX_SHELL" && -e "$NIX_SHELL" && ! -e ./shell.nix ]]; then
    cp "$NIX_SHELL" ./shell.nix
    if [[ $PIN -eq 1 ]] ; then
      latestHash=`git ls-remote git://github.com/NixOS/nixpkgs.git | grep refs/heads/${nixpkgsChannel} | cut -f 1`
      sed -i.bak "s~<nixpkgs>~(fetchTarball https://github.com/NixOS/nixpkgs/archive/$latestHash.tar.gz)~" shell.nix && rm -f shell.nix.bak
      sed -i.bak "s~my_overlay = import.*;~my_overlay = import ${
        toString ../../../overlays.nix
      };~" shell.nix && rm -f shell.nix.bak
    fi
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

  mkdir -p .git/info && touch .git/info/exclude && echo "shell.nix" >> .git/info/exclude

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
      if [[ -e Gemfile && ! -e Gemfile.lock ]] ; then
        ${pkgs.ruby.devEnv}/bin/bundle install > /dev/null 2>&1
      fi

      if [[ -e package.json && ! -d node_modules ]] ; then
        ${pkgs.nodejs}/bin/npm ci --progress=false --silent --quiet > /dev/null 2>&1
      fi

      if [[ -e composer.json && ! -d vendor ]] ; then
        COMPOSER_MEMORY_LIMIT=-1 ${pkgs.phpPackages.composer}/bin/composer install -n -q
      fi
    fi
  fi

  cd - > /dev/null;
''
