#!/bin/bash

################################################################################
# Airspace File Validator
# Validates OpenAir format airspace files
# Author: iFuel Manager Development Team
################################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if file provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <airspace_file.txt>"
    echo "   or: $0 output/*.txt  (to check all files)"
    exit 1
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║            OpenAir Airspace File Validator                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

total_files=0
valid_files=0
invalid_files=0

# Validate each file
for file in "$@"; do
    total_files=$((total_files + 1))

    if [ ! -f "$file" ]; then
        echo -e "${RED}✗${NC} $file - File not found"
        invalid_files=$((invalid_files + 1))
        continue
    fi

    # Check file size
    size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    if [ "$size" -eq 0 ]; then
        echo -e "${RED}✗${NC} $file - Empty file"
        invalid_files=$((invalid_files + 1))
        continue
    fi

    # Check for basic OpenAir commands
    has_ac=$(grep -c "^AC " "$file" || true)
    has_an=$(grep -c "^AN " "$file" || true)
    has_geometry=$(grep -c "^\(DP\|DC\|V X=\)" "$file" || true)

    if [ "$has_ac" -eq 0 ]; then
        echo -e "${RED}✗${NC} $file - No AC (Airspace Class) commands found"
        invalid_files=$((invalid_files + 1))
        continue
    fi

    if [ "$has_an" -eq 0 ]; then
        echo -e "${YELLOW}⚠${NC} $file - No AN (Airspace Name) commands found (might be OK)"
    fi

    if [ "$has_geometry" -eq 0 ]; then
        echo -e "${RED}✗${NC} $file - No geometry commands (DP/DC/V X=) found"
        invalid_files=$((invalid_files + 1))
        continue
    fi

    # File looks valid
    human_size=$(du -h "$file" | cut -f1)
    echo -e "${GREEN}✓${NC} $file - Valid ($has_ac airspaces, $human_size)"
    valid_files=$((valid_files + 1))
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

if [ "$invalid_files" -gt 0 ]; then
    exit 1
else
    exit 0
fi
