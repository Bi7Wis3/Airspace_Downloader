# 🚀 Quick Start Guide

Get up and running with the Airspace Downloader in 60 seconds!

## One-Line Install & Run

```bash
cd Airspace_Downloader && chmod +x *.sh scripts/*.sh && ./download_airspaces.sh
```

## Step-by-Step

### 1. Download Airspace Files
```bash
./download_airspaces.sh              # everything in sources.txt
./download_airspaces.sh belgium      # only matching sources
```

### 2. Add Your Own Old Files
```bash
./add_airspace.sh ~/Downloads/Airspaces          # a whole folder
./add_airspace.sh Dutch.airspace2020.txt         # or single files
```

### 3. Verify Files
```bash
./scripts/validate_airspace.sh output/
```

### 4. Use the Files
- `output/` - the latest version of every source
- `output/archive/` - older versions and the files you added

## What You Get

- **62 sources** covering 41 countries
- Netherlands generated from official LVNL data, current every AIRAC
- Belgium/Luxembourg 2026 files from LVZC
- Old versions are never deleted

## Update a Country

Edit its URL in `sources.txt`. See [README.md](README.md) for the format.

## Automate Updates
```bash
0 2 * * 0 /path/to/Airspace_Downloader/download_airspaces.sh
```

## Safety Reminder ⚠️

**These files are NOT certified for navigation!**
- Always check official NOTAMs
- Verify airspace status before flight
- Use as reference only

---

**Happy flying!** ✈️
