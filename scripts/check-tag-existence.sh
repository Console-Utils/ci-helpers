#!/usr/bin/env bash

# Check whether futher CI jobs can be run by mandating:
# - last version tag existence on last commit
#
# Assumptions:
# - HEAD is now at merge commit created by pull request

declare -ir SUCCESS=0
declare -ir NO_TAG_ERROR=1

git checkout HEAD^2

last_tag=$(git tag | sed --regexp-extended --quiet '/v/p' | sort --reverse | head --lines 1)

if [[ -z $last_tag ]]; then
    echo "No version tag found." >&2
    exit $NO_TAG_ERROR
fi

current_sha=$(git rev-parse HEAD)
last_tag_sha=$(git rev-parse "$last_tag")

if [[ "$last_tag_sha" != "$current_sha" ]]; then
    echo "'$current_sha' must have '$last_tag', which points now to '$last_tag_sha' commit." >&2
    exit $NO_TAG_ERROR
fi

exit $SUCCESS
