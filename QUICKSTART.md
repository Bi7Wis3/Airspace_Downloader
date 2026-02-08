# 🚀 Quick Start Guide

Get up and running with European Airspace Downloader in 60 seconds!

## One-Line Install & Run

```bash
cd Airspace_Downloader && chmod +x download_airspaces.sh && ./download_airspaces.sh
```

## Step-by-Step

### 1. Navigate to Project
```bash
cd /path/to/Airspace_Downloader
```

### 2. Make Scripts Executable
```bash
chmod +x download_airspaces.sh
chmod +x scripts/*.sh
```

### 3. Download Airspace Files
```bash
./download_airspaces.sh
```

### 4. Verify Downloaded Files
```bash
./scripts/validate_airspace.sh output/*.txt
```

### 5. Use the Files
```bash
ls -lh output/
```

## What You Get

After running, you'll have:
- **8 airspace files** in the `output/` directory
- **6 European countries** covered
- **~2.1 MB** total size
- **3,838+ individual airspaces**

## Countries Included

✅ Czech Republic (281 airspaces)
✅ France (1,616 airspaces)
✅ Germany (677 airspaces) - 3 versions!
✅ Netherlands (166 airspaces)
✅ Slovakia (86 airspaces)
✅ Switzerland (334 airspaces)

## Next Steps

### Load in Your App
1. Copy files to your navigation device
2. Import into XCSoar, SeeYou, LK8000, etc.
3. Or use with iFuel Manager app

### Get More Countries
Check `README.md` for links to download:
- Austria, Belgium, Denmark, Spain, Italy
- UK, Poland, Norway, Sweden, Finland
- And 20+ more European countries

### Automate Updates
Add to crontab for weekly updates:
```bash
0 2 * * 0 /path/to/Airspace_Downloader/download_airspaces.sh
```

## Need Help?

- 📖 Read the full [README.md](README.md)
- 🐛 Report issues on GitHub
- 💬 Join aviation communities linked in README

## Safety Reminder ⚠️

**These files are NOT certified for navigation!**
- Always check official NOTAMs
- Verify airspace status before flight
- Use as reference only

---

**Happy flying!** ✈️
