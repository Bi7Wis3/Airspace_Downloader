#!/bin/bash

################################################################################
# Add your own (old) OpenAir files to the archive
#
# Usage: ./add_airspace.sh <file.txt> [more files or folders...]
#   e.g. ./add_airspace.sh ~/Downloads/Airspaces
#        ./add_airspace.sh Dutch.airspace2020.txt austria_2020.txt
#
# Each file is validated and copied to output/archive/ under its own filename.
# Existing files are never overwritten; identical copies are skipped.
################################################################################

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ARCHIVE_DIR="$SCRIPT_DIR/output/archive"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

source "$SCRIPT_DIR/scripts/openair_lib.sh"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <file.txt|folder> [...]"
    exit 1
fi

mkdir -p "$ARCHIVE_DIR"

added=0
skipped=0
rejected=0

add_one() {
    local file="$1"
    local base
    base=$(basename "$file")
    # .sua/.air/.openair are OpenAir too; store everything as .txt for the app
    local dest="$ARCHIVE_DIR/${base%.*}.txt"

    local reason
    if ! reason=$(openair_check "$file"); then
        echo -e "${RED}✗${NC} $base - $reason"
        rejected=$((rejected + 1))
        return
    fi

    if [ -f "$dest" ]; then
        if cmp -s "$file" "$dest"; then
            echo -e "${YELLOW}=${NC} $base - already in archive"
            skipped=$((skipped + 1))
            return
        fi
        local n=2
        while [ -f "$ARCHIVE_DIR/${base%.*}_$n.txt" ]; do n=$((n + 1)); done
        dest="$ARCHIVE_DIR/${base%.*}_$n.txt"
    fi

    cp -p "$file" "$dest"
    echo -e "${GREEN}✓${NC} $base → output/archive/$(basename "$dest") ($(openair_count "$file") airspaces)"
    added=$((added + 1))
}

for arg in "$@"; do
    if [ -d "$arg" ]; then
        while IFS= read -r -d '' f; do
            add_one "$f"
        done < <(find "$arg" -type f \( -iname '*.txt' -o -iname '*.sua' -o -iname '*.air' -o -iname '*.openair' \) -print0 | sort -z)
    elif [ -f "$arg" ]; then
        add_one "$arg"
    else
        echo -e "${RED}✗${NC} $arg - not found"
        rejected=$((rejected + 1))
    fi
done

echo ""
echo "Added: $added   Already there: $skipped   Rejected: $rejected"
