# Changelog

All notable changes to the European Airspace Downloader project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-10-16

### Added
- `sources.txt`: all sources in one editable list (region | name | description | url)
- `add_airspace.sh`: validate and add your own (old) OpenAir files or folders to `output/archive/`
- Automatic archive: a changed source moves the previous version to `output/archive/<name>_<date>.txt`
- Netherlands from official LVNL open data (`scripts/lvnl_to_openair.py`), current every AIRAC
- Belgium/Luxembourg 2026 files from LVZC (weekdays all, weekdays gliding, weekends, EBR78)
- New sources: UK, Sweden, Iceland, Finland PIK, USA, Canada, Brazil, Colombia, Australia,
  New Zealand, Israel, Japan, South Africa, Malawi (62 sources in total)
- Optional filter argument: `./download_airspaces.sh netherlands`

### Changed
- SoaringWeb URLs moved to soaring.silentflight.ca, updated to the latest releases
  (Spain, Poland, Romania, Denmark, Hungary, Lithuania, Switzerland, France, Czechia)
- Germany DAeC updated to September 2026
- Stable output names without a year (`output/germany.txt`); dates live in the archive
- Validator accepts folders and handles Latin-1/CRLF files

### Fixed
- Script stopped at the first failed download (`set -e`)
- Failed downloads were reported as successful and left empty files
- Error pages (HTML) were saved as airspace files
- Validator was called with a folder and always failed
- 8 dead links (404): Netherlands XCSoar, Spain, Poland, Romania, Denmark, Hungary, Lithuania, Switzerland
- `token.txt` was not in `.gitignore`

## [1.0.0] - 2026-02-08

### Added
- Initial release of European Airspace Downloader
- Main download script (`download_airspaces.sh`)
- Validation script for OpenAir files
- Comprehensive README with multiple country sources
- MIT License
- Quick start guide
- Support for **25 files covering 21 European countries**:
  - Belgium (BE) - Weekdays & Weekends
  - Bulgaria (BG)
  - Croatia (HR)
  - Czech Republic (CZ)
  - Denmark (DK)
  - Finland (FI)
  - France (FR)
  - Germany (DE) - 2 versions
  - Greece (GR)
  - Hungary (HU)
  - Ireland (IE)
  - Italy (IT)
  - North Macedonia (MK)
  - Netherlands (NL)
  - Norway (NO)
  - Poland (PL)
  - Portugal (PT)
  - Romania (RO)
  - Slovakia (SK)
  - Slovenia (SI)
  - Spain (ES)
  - Switzerland (CH) - 2 versions
- Automated download from multiple sources:
  - GitHub repositories (planeur-net, bubeck, XCSoar)
  - Official aviation authorities (DAEC)
  - Open source projects (openair-rs)
- Logging system for download tracking
- Color-coded terminal output
- File size reporting
- Download summary statistics
- .gitignore for clean repository
- Project structure with output/ and scripts/ directories

### Features
- **Total Coverage**: 11,122 individual airspaces
- **Total Size**: 7.0 MB (compressed text format)
- **Update Sources**:
  - Weekly updates (France)
  - Daily updates (Germany)
  - Regular updates from XCSoar
- **Validation**: Automatic OpenAir format validation
- **Error Handling**: Graceful failure with logging
- **Cross-Platform**: Works on Linux, macOS, WSL

### Documentation
- Main README.md (11 KB)
- QUICKSTART.md for rapid deployment
- LICENSE file with aviation disclaimer
- Inline script documentation
- Source attribution for all downloads

### Known Limitations
- Austria download currently unavailable (404 errors)
- Belgium files require manual download
- Spain/Italy require manual download from sources
- Some remote XCSoar files are unavailable

## [Unreleased]

### Planned Features
- [ ] Add Austria official source when URL fixed
- [ ] Add Belgium airspace
- [ ] Add Spain airspace
- [ ] Add Italy airspace
- [ ] Add UK airspace
- [ ] Add Poland airspace
- [ ] Implement checksum verification
- [ ] Add automatic update detection
- [ ] Create GUI version
- [ ] Docker container support
- [ ] Parallel downloads for speed
- [ ] Support for other formats (KML, GeoJSON)
- [ ] Windows batch file version
- [ ] macOS compatibility improvements
- [ ] File comparison tool (diff between versions)
- [ ] Airspace statistics generator
- [ ] Integration with flight planning software

### Future Enhancements
- [ ] Web interface for file selection
- [ ] Mobile app for direct download to phone
- [ ] Automatic NOTAM integration
- [ ] Airspace change notifications
- [ ] Historical version archive
- [ ] Community contributions system
- [ ] Multi-language support
- [ ] Flight logging integration

---

## Version History

| Version | Date | Downloads | Countries | Size | Airspaces |
|---------|------|-----------|-----------|------|-----------|
| 1.0.0 | 2026-02-08 | 25 files | 21 countries | 7.0 MB | 11,122 |

---

**Maintainer:** iFuel Manager Development Team
**Repository:** https://github.com/Bi7Wis3/Airspace_Downloader
**Issues:** https://github.com/Bi7Wis3/Airspace_Downloader/issues
