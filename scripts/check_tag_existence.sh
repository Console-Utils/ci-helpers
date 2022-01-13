#!/usr/bin/env bash

# Syntax: check_tag_existence

# Check whether the last commit is marked with the version tag
#
# Assumptions:
# - HEAD is now at merge commit created by pull request

declare -ir success=0
declare -ir no_tag_error=1

git checkout HEAD^2

last_tag="$(git tag | sed --regexp-extended --quiet '/v/p' | sort --reverse | head --lines 1)"

if [[ -z "$last_tag" ]]; then
    echo "⛔ No version tag found." >&2
    exit $no_tag_error
fi

current_sha="$(git rev-parse HEAD)"
last_tag_sha="$(git rev-parse "$last_tag")"

if [[ "$last_tag_sha" != "$current_sha" ]]; then
    echo "⛔ '$current_sha' must have '$last_tag', which points now to '$last_tag_sha' commit." >&2
    exit "$no_tag_error"
fi

echo "✅ Tag exists."
exit "$success"
