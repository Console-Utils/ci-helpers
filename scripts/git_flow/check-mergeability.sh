#!/usr/bin/env bash

# Syntax: check-mergeability

# Check whether branch is feature/bugfix and is merged to dev OR is
# dev branch merged to main/master

# shellcheck disable=SC2155

declare -ir success=0
declare -ir wrong_branch_error=1

case "$GITHUB_BASE_REF" in
    dev)
        if [[ "$GITHUB_HEAD_REF" =~ ^(feature|bugfix)/([[:digit:]]+)$ ]]; then
            declare owner="${GITHUB_REPOSITORY%/*}"
            declare repository="${GITHUB_REPOSITORY#*/}"
            declare issue="${BASH_REMATCH[2]}"
            declare responce="$(curl --silent --header "Accept: application/vnd.github.v3+json" \
                --write-out '%{http_code}' \
                "https://api.github.com/repos/$owner/$repository/issues/$issue")"
            declare http_body="$(echo "$responce" | head --lines -1)"
            declare http_code="$(echo "$responce" | tail --lines 1)"

            if [[ "$http_code" -ne 200 || "$(echo "$http_body" | \
                jq --monochrome-output '.pull_request' )" != null ]]; then
                echo "⛔ Source branch must be 'feature/<issue-id>'|'bugfix/<issue-id>' branch \
to be able merged to 'master' or 'main' with real issue id, but now it is '$GITHUB_HEAD_REF'" >&2
                exit "$wrong_branch_error"
            fi
        else
            echo "⛔ Source branch must be 'feature/<number>'|'bugfix/<number>' branch \
to be able merged merged to 'master' or 'main', but now it is '$GITHUB_HEAD_REF'" >&2
        exit "$wrong_branch_error"
        fi
    ;;
    master|main)
        if [[ "$GITHUB_HEAD_REF" != dev ]]; then
            echo "⛔ Source branch must be 'dev' branch \
to be able merged to 'master'|'main', but now it is '$GITHUB_HEAD_REF'" >&2
            exit "$wrong_branch_error"
        fi
    ;;
    *)
        echo "⛔ Base branch must be 'dev'|'master'|'main', but now it is '$GITHUB_BASE_REF'." >&2
        exit "$wrong_branch_error"
    ;;
esac

echo "✅ Branches are correct."
exit "$success"
