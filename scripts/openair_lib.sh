#!/bin/bash
# Shared OpenAir helpers. Source this file; do not run it.
# Files are often Latin-1 with CRLF line endings, so grep runs in C locale with -a.

# Number of airspaces (AC records) in a file
openair_count() {
    LC_ALL=C grep -acE '^[[:space:]]*AC[[:space:]]' "$1"
}

# Prints a reason and returns 1 when the file is not usable OpenAir
openair_check() {
    local file="$1"
    if [ ! -s "$file" ]; then
        echo "empty file"
        return 1
    fi
    if LC_ALL=C head -c 2048 "$file" | grep -aqiE '<!doctype html|<html'; then
        echo "got a web page instead of a file"
        return 1
    fi
    if [ "$(openair_count "$file")" -eq 0 ]; then
        echo "no AC records"
        return 1
    fi
    if ! LC_ALL=C grep -aqE '^[[:space:]]*(DP|DC|DB|DA|V[[:space:]]+X=)' "$file"; then
        echo "no geometry (DP/DC/DB/V X=)"
        return 1
    fi
    return 0
}
