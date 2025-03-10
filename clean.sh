#! /bin/bash

VERBOSE=false
KEEPBRANCHES=''

while [[ $# -gt 0 ]]; do
  case $1 in
    -k|--keep)
        shift
        while [[ $# -gt 0 ]] && [[ ! "$1" =~ ^- ]]; do
            if [[ -z "$keepBranches" ]]; then
                keepBranches="$1" 
            else
                keepBranches+="|$1" 
            fi
            shift
        done
      ;;
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

if ! [ -d .git ]; then
    echo "Not a git repo"
fi;

MAINBRANCH=$(git branch -l main master --format '%(refname:short)')

if [[ -z "$MAINBRANCH" ]]; then
    echo "Could not determine the main branch (main/master)"
    exit 1
fi

if $VERBOSE ; then
    echo 'Switching branches'
    git switch $MAINBRANCH
else
    git switch $MAINBRANCH &> /dev/null
fi

if $VERBOSE ; then
    echo 'Running git fetch --prune'
fi

git fetch --prune

if $VERBOSE ; then
    echo "Deleting local branches..."
fi

if [[ -n "$KEEPBRANCHES" ]]; then
    git for-each-ref --format '%(refname:short)' refs/heads | grep -Ev "^($MAINBRANCH|$KEEPBRANCHES)$" | xargs git branch -D
else
    git for-each-ref --format '%(refname:short)' refs/heads | grep -v "^$MAINBRANCH$" | xargs git branch -D
fi