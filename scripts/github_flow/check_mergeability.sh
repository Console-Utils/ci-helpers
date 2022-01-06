#!/usr/bin/env bash

# Check whether futher CI jobs can be run by mandating:
# - only feature/bugfix branches merged to main/master

declare -ir SUCCESS=0
declare -ir WRONG_BRANCH=1

case "$GITHUB_BASE_REF" in
    master|main)
        if [[ $GITHUB_HEAD_REF != @(feature|bugfix)/[[:digit:]] ]]; then
            echo "Source branch must be 'feature/<number>'|'bugfix/<number>' branch \
when merged to \"master\" or \"main\", but now it is \"$GITHUB_HEAD_REF\"" >&2
            exit $WRONG_BRANCH
        fi
    ;;
    *)
        echo "Base branch must be 'master'|'main', but now it is \"$GITHUB_BASE_REF\"." >&2
        exit $WRONG_BRANCH
    ;;
esac

exit $SUCCESS
