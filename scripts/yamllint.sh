#!/usr/bin/env bash

# Syntax: yamllint {{config}} {{files}}

declare -ir success=0
declare -ir wrong_format_error=1

declare config="$1"
declare files=("${@:1}")

declare -i error_count=0
for file in "${files[@]}"; do
    echo "Linting $file:"
    yamllint --strict --config-file "$config" "$file" || error_count+=1
done

(( error_count == 0 )) && {
    echo "✅ Files are correct."
    exit "$success"
}

echo "⛔ Yaml files must have '$config' file format, but now it is wrong."
exit "$wrong_format_error"
