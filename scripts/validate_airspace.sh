#!/bin/bash

################################################################################
# Airspace File Validator
# Validates OpenAir format airspace files
# Author: Bi7Wis3 Development Team
#
# Usage: ./scripts/validate_airspace.sh <file.txt|folder> [...]
################################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

source "$(cd "$(dirname "$0")" && pwd)/openair_lib.sh"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <airspace_file.txt>"
    echo "   or: $0 output/          (to check all files in a folder)"
    exit 1
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║            OpenAir Airspace File Validator                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

total_files=0
valid_files=0
invalid_files=0

validate_one() {
    local file="$1"
    total_files=$((total_files + 1))

    local reason
    if ! reason=$(openair_check "$file"); then
        echo -e "${RED}✗${NC} $file - $reason"
        invalid_files=$((invalid_files + 1))
        return
    fi

    if ! LC_ALL=C grep -aqE '^[[:space:]]*AN[[:space:]]' "$file"; then
        echo -e "${YELLOW}⚠${NC} $file - No AN (Airspace Name) commands found (might be OK)"
    fi

    echo -e "${GREEN}✓${NC} $file - Valid ($(openair_count "$file") airspaces, $(du -h "$file" | cut -f1))"
    valid_files=$((valid_files + 1))
}

for arg in "$@"; do
    if [ -d "$arg" ]; then
        while IFS= read -r -d '' f; do
            validate_one "$f"
        done < <(find "$arg" -type f -name '*.txt' -print0 | sort -z)
    elif [ -f "$arg" ]; then
        validate_one "$arg"
    else
        echo -e "${RED}✗${NC} $arg - File not found"
        total_files=$((total_files + 1))
        invalid_files=$((invalid_files + 1))
    fi
done

# Summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Summary:"
echo "  Total files:   $total_files"
echo -e "  ${GREEN}Valid files:   $valid_files${NC}"
if [ "$invalid_files" -gt 0 ]; then
    echo -e "  ${RED}Invalid files: $invalid_files${NC}"
fi
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

[ "$invalid_files" -eq 0 ]
