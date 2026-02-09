#!/bin/bash

################################################################################
# Airspace Downloader for Europe
# Downloads OpenAir format airspace files from various sources
# Author: iFuel Manager Development Team
# Date: February 8, 2026
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
OUTPUT_DIR="output"
TEMP_DIR="temp"
LOG_FILE="download.log"

# Create directories
mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Print header
print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║         European Airspace Downloader (OpenAir)            ║${NC}"
    echo -e "${BLUE}║                    Version 1.0                             ║${NC}"
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

# Download function with progress
download_file() {
    local url="$1"
    local output="$2"
    local description="$3"

    echo -n "  → $description... "

    if wget -q --show-progress --progress=bar:force:noscroll -O "$output" "$url" 2>&1 | tail -1; then
        local size=$(du -h "$output" | cut -f1)
        echo -e "${GREEN}✓${NC} ($size)"
        log "SUCCESS: Downloaded $description ($size)"
        return 0
    else
        rm -f "$output"
        echo -e "${RED}✗ Failed${NC}"
        log "FAILED: Could not download $description from $url"
        return 1
    fi
}

# Start
print_header
log "Starting Airspace Downloader"

################################################################################
# 1. FRANCE - From GitHub (planeur-net)
################################################################################
section "1. France (planeur-net GitHub)"

download_file \
    "https://planeur-net.github.io/airspace/france.txt" \
    "$OUTPUT_DIR/france_2026.txt" \
    "France airspace (Feb 2026)"

################################################################################
# 2. GERMANY - From GitHub (bubeck/airspace_germany)
################################################################################
section "2. Germany (GitHub Repository)"

download_file \
    "https://raw.githubusercontent.com/bubeck/airspace_germany/main/source/airspace_germany.txt" \
    "$OUTPUT_DIR/germany_2026.txt" \
    "Germany airspace (GitHub)"

################################################################################
# 3. GERMANY - Official DAEC
################################################################################
section "3. Germany (DAEC Official)"

download_file \
    "https://www.daec.de/media/files/Dateien/Fachbereiche/Luftraum_und_Flugsicherheit/2025_06_Airspace_Germany_DAeC.txt" \
    "$OUTPUT_DIR/germany_daec_2025.txt" \
    "Germany DAEC official (June 2025)"

################################################################################
# 4. SWITZERLAND - From openair-rs
################################################################################
section "4. Switzerland (openair-rs)"

download_file \
    "https://raw.githubusercontent.com/dbrgn/openair-rs/master/example_data/Switzerland.txt" \
    "$OUTPUT_DIR/switzerland_2026.txt" \
    "Switzerland airspace"

################################################################################
# 5. XCSoar Repository - Multiple Countries
################################################################################
section "5. XCSoar Data Repository"

BASE_URL="https://raw.githubusercontent.com/XCSoar/xcsoar-data-content/master"

declare -A xcsoar_files=(
    ["czechia"]="data/content/airspace/country/CZ-ASP-National-XCSoar.txt"
    ["netherlands"]="data/content/airspace/country/NL-ASP-National-XCSoar.txt"
)

for country in "${!xcsoar_files[@]}"; do
    file_path="${xcsoar_files[$country]}"
    url="${BASE_URL}/${file_path}"
    output_file="$OUTPUT_DIR/${country}_2025.txt"

    download_file "$url" "$output_file" "$country (XCSoar)"
done

################################################################################
# 6. SoaringWeb - European Countries
################################################################################
section "6. SoaringWeb (Multiple European Countries)"

# Belgium (2 files - weekdays and weekends)
download_file \
    "https://soaringweb.org/Airspace/BE/BELLUX_WEEK_20240331.txt" \
    "$OUTPUT_DIR/belgium_weekdays_2024.txt" \
    "Belgium weekdays"

download_file \
    "https://soaringweb.org/Airspace/BE/BELLUX_W-END_20240331.txt" \
    "$OUTPUT_DIR/belgium_weekends_2024.txt" \
    "Belgium weekends"

# Italy
download_file \
    "https://soaringweb.org/Airspace/IT/ITA_ASP_17-APR-2025-2504_V03.txt" \
    "$OUTPUT_DIR/italy_2025.txt" \
    "Italy (Apr 2025)"

# Croatia
download_file \
    "https://soaringweb.org/Airspace/HR/HRV-2012.txt" \
    "$OUTPUT_DIR/croatia_2012.txt" \
    "Croatia"

# Spain
download_file \
    "https://soaringweb.org/Airspace/ES/SUASpain202509.txt" \
    "$OUTPUT_DIR/spain_2025.txt" \
    "Spain (Sep 2025)"

# Portugal
download_file \
    "https://soaringweb.org/Airspace/PT/Portugal_mainland_may_2020_v1.3.txt" \
    "$OUTPUT_DIR/portugal_2020.txt" \
    "Portugal"

# Poland
download_file \
    "https://soaringweb.org/Airspace/PL/Polska_2024-08-19.txt" \
    "$OUTPUT_DIR/poland_2024.txt" \
    "Poland (Aug 2024)"

# Greece
download_file \
    "https://soaringweb.org/Airspace/GR/greece_03.txt" \
    "$OUTPUT_DIR/greece_2025.txt" \
    "Greece"

# Romania
download_file \
    "https://soaringweb.org/Airspace/RO/RomaniaFEB2024.txt" \
    "$OUTPUT_DIR/romania_2024.txt" \
    "Romania (Feb 2024)"

# Ireland
download_file \
    "https://soaringweb.org/Airspace/EI/Ireland_2025.txt" \
    "$OUTPUT_DIR/ireland_2025.txt" \
    "Ireland (2025)"

# Slovenia
download_file \
    "https://soaringweb.org/Airspace/SI/si_2016.04.txt" \
    "$OUTPUT_DIR/slovenia_2016.txt" \
    "Slovenia"

# Slovakia (SoaringWeb version)
download_file \
    "https://soaringweb.org/Airspace/SK/AS_LBB_18_APR_2024.txt" \
    "$OUTPUT_DIR/slovakia_soaringweb_2024.txt" \
    "Slovakia (SoaringWeb)"

# Macedonia
download_file \
    "https://soaringweb.org/Airspace/MK/macedonia_airspace_lo_2018.txt" \
    "$OUTPUT_DIR/macedonia_2018.txt" \
    "Macedonia"

# Norway
download_file \
    "https://soaringweb.org/Airspace/NO/Norway_2025.txt" \
    "$OUTPUT_DIR/norway_2025.txt" \
    "Norway (2025)"

# Denmark
download_file \
    "https://soaringweb.org/Airspace/DK/DK-OpenAir-AMDT07-20250520.txt" \
    "$OUTPUT_DIR/denmark_2025.txt" \
    "Denmark (May 2025)"

# Bulgaria
download_file \
    "https://soaringweb.org/Airspace/BG/BGair_23.txt" \
    "$OUTPUT_DIR/bulgaria_2023.txt" \
    "Bulgaria"

# Hungary
download_file \
    "https://soaringweb.org/Airspace/HU/HunSUA2024_v2.txt" \
    "$OUTPUT_DIR/hungary_2024.txt" \
    "Hungary (2024)"

################################################################################
# 7. Additional Sources
################################################################################
section "7. Additional European Sources"

# Finland (from aviamaps)
download_file \
    "https://aviamaps.com/api/finland.txt" \
    "$OUTPUT_DIR/finland_2025.txt" \
    "Finland (aviamaps)"

# Switzerland (SoaringWeb - more comprehensive version)
download_file \
    "https://soaringweb.org/Airspace/CH/SFVS-FSVV_CH-Airspace25_eDABS_MAR25.txt" \
    "$OUTPUT_DIR/switzerland_soaringweb_2025.txt" \
    "Switzerland (SoaringWeb Mar 2025)"

################################################################################
# 8. Baltic States & Eastern Europe
################################################################################
section "8. Baltic States & Eastern Europe"

# Lithuania
download_file \
    "https://soaringweb.org/Airspace/LT/Oro_erdve_2025_v_01.txt" \
    "$OUTPUT_DIR/lithuania_2025.txt" \
    "Lithuania (2025)"

# Latvia
download_file \
    "https://soaringweb.org/Airspace/LV/lv_2014_05_04.txt" \
    "$OUTPUT_DIR/latvia_2014.txt" \
    "Latvia"

# Estonia
download_file \
    "https://soaringweb.org/Airspace/EE/Estonia_Airspace_June_2015.txt" \
    "$OUTPUT_DIR/estonia_2015.txt" \
    "Estonia (June 2015)"

# Russia
download_file \
    "https://soaringweb.org/Airspace/RU/russia_1310.txt" \
    "$OUTPUT_DIR/russia_2013.txt" \
    "Russia"

# Ukraine
download_file \
    "https://soaringweb.org/Airspace/UA/ukraine-gliding-airspace-2021.txt" \
    "$OUTPUT_DIR/ukraine_2021.txt" \
    "Ukraine (2021)"

################################################################################
# SUMMARY
################################################################################
section "Download Summary"

echo ""
total_files=$(ls -1 "$OUTPUT_DIR"/*.txt 2>/dev/null | wc -l)
total_size=$(du -ch "$OUTPUT_DIR"/*.txt 2>/dev/null | tail -1 | cut -f1)

if [ $total_files -gt 0 ]; then
    echo -e "${GREEN}✓ Successfully downloaded: $total_files files${NC}"
    echo -e "${GREEN}✓ Total size: $total_size${NC}"
    echo ""
    echo "Files saved to: $OUTPUT_DIR/"
    echo ""

    # List downloaded files
    echo "Downloaded files:"
    ls -lh "$OUTPUT_DIR"/*.txt | awk '{printf "  %-35s %6s\n", $9, $5}'

    log "Download complete: $total_files files, $total_size total"
##################
# checkink for valid files... 
###################
    ./scripts/validate_airspace.sh ./output/*
else
    echo -e "${RED}✗ No files downloaded${NC}"
    log "ERROR: No files were successfully downloaded"
    exit 1
fi

################################################################################
# CLEANUP
################################################################################
echo ""
rm -rf "$TEMP_DIR"
echo -e "${BLUE}Log saved to: $LOG_FILE${NC}"
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    DOWNLOAD COMPLETE!                      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Next steps:"
echo "  1. Check the files in '$OUTPUT_DIR/' directory"
echo "  2. Load them in your navigation app"
echo "  3. See README.md for more download sources"
echo ""
