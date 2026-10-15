#!/bin/bash

################################################################################
# Airspace Downloader
# Downloads OpenAir format airspace files listed in sources.txt
# Author: Bi7Wis3 Development Team
# Date: October 16, 2026
#
# Usage: ./download_airspaces.sh [filter]
#   filter  optional; only download sources whose name or region contains it
#           e.g. ./download_airspaces.sh germany   or   ./download_airspaces.sh Europe
#
# A download only replaces output/<name>.txt when it is a valid OpenAir file.
# If the new file differs from the existing one, the old version is moved to
# output/archive/<name>_<date>.txt so earlier releases are never lost.
################################################################################

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SOURCES_FILE="sources.txt"
OUTPUT_DIR="output"
ARCHIVE_DIR="$OUTPUT_DIR/archive"
TEMP_DIR="temp"
LOG_FILE="download.log"
USER_AGENT="AirspaceDownloader/2.0"
FILTER="${1:-}"

source "$SCRIPT_DIR/scripts/openair_lib.sh"

mkdir -p "$OUTPUT_DIR" "$ARCHIVE_DIR" "$TEMP_DIR"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Print header
print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║              Airspace Downloader (OpenAir)                 ║${NC}"
    echo -e "${BLUE}║                       Version 2.0                          ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Print section header
section() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  $1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

# Download one source. Prints status, returns 0 on success.
download_file() {
    local name="$1"
    local description="$2"
    local url="$3"
    local target="$OUTPUT_DIR/$name.txt"
    local tmp="$TEMP_DIR/$name.txt"

    printf "  → %-45s " "$description"

    if [ "$url" = "lvnl://airspace" ]; then
        # Converted from the official LVNL data feed instead of a plain download
        if ! python3 -I "$SCRIPT_DIR/scripts/lvnl_to_openair.py" "$tmp" 2>>"$LOG_FILE" || [ ! -s "$tmp" ]; then
            rm -f "$tmp"
            echo -e "${RED}✗ LVNL conversion failed (see $LOG_FILE)${NC}"
            log "FAILED: $name LVNL conversion"
            return 1
        fi
    else
        local http_code
        http_code=$(curl -sL --fail -m 120 -A "$USER_AGENT" -o "$tmp" -w "%{http_code}" "$url" 2>/dev/null)
        if [ $? -ne 0 ] || [ ! -s "$tmp" ]; then
            rm -f "$tmp"
            echo -e "${RED}✗ Failed (HTTP ${http_code:-?})${NC}"
            log "FAILED: $name HTTP ${http_code:-?} $url"
            return 1
        fi
    fi

    # Generated files embed today's date; compare without comment lines
    # so an unchanged AIRAC doesn't create a new archive copy every run
    if [ -f "$target" ] && cmp -s <(grep -av '^\*' "$tmp") <(grep -av '^\*' "$target"); then
        rm -f "$tmp"
        echo -e "${GREEN}✓${NC} unchanged ($(openair_count "$target") airspaces)"
        log "UNCHANGED: $name"
        return 0
    fi

    local reason
    if ! reason=$(openair_check "$tmp"); then
        rm -f "$tmp"
        echo -e "${RED}✗ Not an OpenAir file ($reason)${NC}"
        log "INVALID: $name ($reason) $url"
        return 1
    fi

    local count
    count=$(openair_count "$tmp")
    local size
    size=$(du -h "$tmp" | cut -f1)

    local note=""
    if [ -f "$target" ]; then
        local archived
        archived="$ARCHIVE_DIR/${name}_$(date -r "$target" '+%Y-%m-%d').txt"
        mv "$target" "$archived"
        note=" ${BLUE}(old version → $archived)${NC}"
        log "ARCHIVED: $target -> $archived"
    fi
    mv "$tmp" "$target"
    echo -e "${GREEN}✓${NC} $count airspaces, $size$note"
    log "SUCCESS: $name ($count airspaces, $size) $url"
    return 0
}

# Start
print_header
log "Starting Airspace Downloader${FILTER:+ (filter: $FILTER)}"

if [ ! -f "$SOURCES_FILE" ]; then
    echo -e "${RED}✗ $SOURCES_FILE not found${NC}"
    exit 1
fi

ok=0
failed=0
failed_list=()
current_region=""

while IFS='|' read -r region name description url || [ -n "$region" ]; do
    region=$(trim "$region")
    [ -z "$region" ] && continue
    [[ "$region" == \#* ]] && continue
    name=$(trim "${name:-}")
    description=$(trim "${description:-}")
    url=$(trim "${url:-}")

    if [ -z "$name" ] || [ -z "$url" ]; then
        echo -e "${YELLOW}⚠ Skipping malformed line: $region | $name${NC}"
        continue
    fi
    if [ -n "$FILTER" ] && [[ "${region,,} ${name,,}" != *"${FILTER,,}"* ]]; then
        continue
    fi

    if [ "$region" != "$current_region" ]; then
        section "$region"
        current_region="$region"
    fi

    if download_file "$name" "$description" "$url"; then
        ok=$((ok + 1))
    else
        failed=$((failed + 1))
        failed_list+=("$name  $url")
    fi
done < "$SOURCES_FILE"

################################################################################
# SUMMARY
################################################################################
section "Download Summary"
echo ""
echo -e "${GREEN}✓ Downloaded / up to date: $ok${NC}"
if [ "$failed" -gt 0 ]; then
    echo -e "${RED}✗ Failed: $failed${NC}"
    for f in "${failed_list[@]}"; do
        echo -e "    ${RED}•${NC} $f"
    done
    echo ""
    echo "  Failed sources keep their previous file in $OUTPUT_DIR/ (if any)."
    echo "  Update the URL in $SOURCES_FILE - SoaringWeb renames files on each release."
fi
echo ""
echo "  Current files : $OUTPUT_DIR/   ($(find "$OUTPUT_DIR" -maxdepth 1 -type f -name '*.txt' | wc -l) files)"
echo "  Old versions  : $ARCHIVE_DIR/   ($(find "$ARCHIVE_DIR" -maxdepth 1 -type f -name '*.txt' | wc -l) files)"
log "Done: $ok ok, $failed failed"

rm -rf "$TEMP_DIR"
echo ""
echo -e "${BLUE}Log saved to: $LOG_FILE${NC}"
echo ""
echo "Next steps:"
echo "  • Load files from '$OUTPUT_DIR/' in your navigation app"
echo "  • Add your own old files with: ./add_airspace.sh <file.txt>... "
echo ""

[ "$failed" -eq 0 ]
