#!/usr/bin/env bash

# Check whether futher CI jobs can be run by mandating:
# - only feature/bugfix branches merged to dev
# - only dev branch merged to master or main

declare -ir SUCCESS=0
declare -ir WRONG_BRANCH=1

case "$GITHUB_BASE_REF" in
    dev)
        if [[ $GITHUB_HEAD_REF != @(feature|bugfix)/+([[:digit:]]) ]]; then
            echo "Source branch must be 'feature/<number>'|'bugfix/<number>' branch \
when merged to 'dev', but now it is '$GITHUB_HEAD_REF'" >&2
            exit $WRONG_BRANCH
        fi
    ;;
    master|main)
        if [[ $GITHUB_HEAD_REF != dev ]]; then
            echo "Source branch must be 'dev' branch \
when merged to 'master'|'main', but now it is '$GITHUB_HEAD_REF'" >&2
            exit $WRONG_BRANCH
        fi
    ;;
    *)
        echo "Base branch must be 'dev'|'master'|'main', but now it is '$GITHUB_BASE_REF'." >&2
        exit $WRONG_BRANCH
    ;;
esac

exit $SUCCESS