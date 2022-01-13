#!/usr/bin/env bash

declare -ir success="0"
declare -ir wrong_tag_error="1"

declare tag="$1"
declare versioning="$2"

case "$versioning" in
  semantic)
    declare pattern='v[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+'
    ;;
  *)
    declare pattern='v[[:digit:]]+\.[[:digit:]]+'
    ;;
esac

if [[ "$tag" =~ $pattern ]]; then
  echo "✅ Tag is correct."
  exit $success
fi

echo "⛔ Release tag must have $versioning versioning format but not it is '$tag'."
exit "$wrong_tag_error"

