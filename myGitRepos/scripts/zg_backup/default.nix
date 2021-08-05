{ pkgs ? import <nixpkgs> { }
, stdenv ? pkgs.stdenv
, projectsDir ? if stdenv.isDarwin then "Projects" else "projects"
, workShortName ? "example"
, workDir ? "${projectsDir}/itx"
, sourceListFile ? ".local/share/workgits"
, ... }:

pkgs.writeShellScriptBin "zg_backup" ''
  host=`hostname -s`
  projects="$HOME/${projectsDir}"
  work="$HOME/${workDir}"

  originaldir="$(pwd)"
  dest=`[[ -z $DESTINATION ]] && echo "$projects/backup/$host" || echo "$DESTINATION"`;
  [[ ! -e "$dest" ]] && mkdir -p "$dest"
  cd "$dest"
  while IFS= read -r gitdir
  do
    if [ -d $gitdir ]; then
      subdir=${"$"}{gitdir//$work/}
      name=${"$"}{subdir//\//_}
      if [ -d $name ]; then
        rm -Rf $name
      fi
      git clone -q --bare $gitdir $name
      if [ -e $name.tar.gz ]; then
        rm -f $name.tar.gz $name.unstaged.patch $name.staged.patch
      fi
      tar -zcf $name.tar.gz $name && rm -Rf $name
      cd $gitdir
      if [[ $(git status --porcelain) ]]; then
        [[ $(git ls-files --others --exclude-standard) ]] && rm -Rf __untracked __untrackedFiles && \
          git ls-files --others --exclude-standard >> __untracked && mkdir __untrackedFiles && \
          rsync -qav --files-from=__untracked $(pwd) ./__untrackedFiles && \
          rm -f __untracked __untrackedFiles/__untracked && tar -zcf $dest/$name.untrackedFiles.tar.gz __untrackedFiles && rm -rf __untrackedFiles
        [[ $(git diff --binary) ]] && git diff --binary >> $dest/$name.unstaged.patch
        [[ $(git diff --cached --binary) ]] && git diff --cached --binary >> $dest/$name.staged.patch
      fi
      cd - > /dev/null;
    fi
  done < "$HOME/${sourceListFile}"
  cd $originaldir > /dev/null;
''
