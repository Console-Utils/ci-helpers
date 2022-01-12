#!/usr/bin/env bash

# Check whether futher CI jobs can be run by mandating:
# - only feature/bugfix branches merged to main/master

# shellcheck disable=SC2155

declare -ir SUCCESS=0
declare -ir WRONG_BRANCH=1

case "$GITHUB_BASE_REF" in
    master|main)
        if [[ $GITHUB_HEAD_REF =~ ^(feature|bugfix)/([[:digit:]]+)$ ]]; then
            declare owner=${GITHUB_REPOSITORY#*/}
            declare repository=${GITHUB_REPOSITORY%/*}
            declare issue=${BASH_REMATCH[2]}
            declare responce=$(curl --silent --header "Accept: application/vnd.github.v3+json" \
                --write-out '%{http_code}' \
                "https://api.github.com/repos/$owner/$repository/issues/$issue")
            declare http_body=$(echo "$responce" | head --lines -1)
            declare http_code=$(echo "$responce" | tail --lines 1)

            echo owner = "$owner"
            echo repository = "$repository"
            echo issue = "$issue"
            echo http_body = "$http_body"
            echo http_code = "$http_code"

            if [[ $http_code -ne 200 || $(echo "$http_body" | jq '.pull_request' ) != null ]]; then
                echo "Source branch must be 'feature/<issue-id>'|'bugfix/<issue-id>' branch \
to be able merged to 'master' or 'main' with real issue id, but now it is '$GITHUB_HEAD_REF'" >&2
                exit $WRONG_BRANCH
            fi
        fi

        echo "Source branch must be 'feature/<number>'|'bugfix/<number>' branch \
to be able merged merged to 'master' or 'main', but now it is '$GITHUB_HEAD_REF'" >&2
        exit $WRONG_BRANCH
    ;;
    *)
        echo "Base branch must be 'master'|'main', but now it is '$GITHUB_BASE_REF'." >&2
        exit $WRONG_BRANCH
    ;;
esac

exit $SUCCESS
