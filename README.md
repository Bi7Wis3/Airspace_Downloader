# 🌍 Airspace Downloader

**Automated, validated OpenAir airspace downloads for 41 countries, with version history**

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-2.0-green.svg)
![Sources](https://img.shields.io/badge/sources-62-brightgreen.svg)
![Countries](https://img.shields.io/badge/countries-41-brightgreen.svg)
![Airspaces](https://img.shields.io/badge/airspaces-35,411-orange.svg)

---

## 🎯 What is This?

**Airspace Downloader** is a bash tool that downloads OpenAir airspace files from the best free
sources worldwide, validates every file, and keeps older versions instead of overwriting them.
For pilots of paramotors, paragliders, hang gliders, gliders and light aircraft who load
airspace into apps such as XCSoar, SeeYou, XCTrack, LK8000 or iFuel Navigator.

### Highlights

- 🚀 **One command**: `./download_airspaces.sh` fetches all 62 sources
- 📝 **One list**: every source is a line in [`sources.txt`](sources.txt). Updating a country means changing one URL
- ✅ **Validated**: empty files, 404s, HTML error pages and Cloudflare challenges are rejected; the last good file stays in place
- 🗂️ **Version history**: a changed source moves the previous file to `output/archive/`. Nothing is ever deleted
- 📥 **Your own files**: `./add_airspace.sh` validates and archives old files you already have
- 🇳🇱 **Official Dutch data**: Netherlands is generated from LVNL's open data feed every AIRAC
- 🇧🇪 **Belgium 2026**: the latest LVZC release, with fixed syntax and corrected areas
- 🎯 **Filters**: `./download_airspaces.sh belgium` updates just what you need

---

## ⚠️ Disclaimer

**THESE AIRSPACE FILES ARE NOT CERTIFIED FOR NAVIGATION OR FLIGHT PLANNING.**

```
┌─────────────────────────────────────────────────────────────┐
│  ⚠️  IMPORTANT SAFETY NOTICE                                │
├─────────────────────────────────────────────────────────────┤
│  ❌ DO NOT use as primary navigational aid                  │
│  ❌ DO NOT rely solely on this data for flight safety       │
│  ✅ ALWAYS refer to official charts, the AIP and NOTAMs     │
│  ✅ ALWAYS check current airspace status before flight      │
│                                                             │
│  You assume all risk of use. The maintainers accept no      │
│  liability for errors, omissions, or consequences of use.   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### Requirements

- Linux, macOS, or Windows with WSL / Git Bash
- `bash` 4+, `curl`
- `python3` (only for the Netherlands LVNL conversion; standard library only)

### Run

```bash
git clone https://github.com/Bi7Wis3/Airspace_Downloader.git
cd Airspace_Downloader
chmod +x download_airspaces.sh add_airspace.sh scripts/*.sh

./download_airspaces.sh
```

All files are now in `output/`. A full run takes about a minute.

---

## 🧰 Commands & Options

### `download_airspaces.sh [filter]`

Downloads every source in `sources.txt`, or only the ones whose **name or region** contains the filter
(case-insensitive).

```bash
./download_airspaces.sh                # all 62 sources
./download_airspaces.sh netherlands    # netherlands + netherlands_community
./download_airspaces.sh belgium        # the 4 Belgian files
./download_airspaces.sh Americas       # a whole region
```

For each source it:

1. downloads to a temporary file (or, for `lvnl://airspace`, runs the LVNL converter),
2. validates it: not empty, not a web page, has `AC` records and geometry,
3. skips it when identical to the current file (comment lines are ignored, so generated
   headers with today's date don't count as a change),
4. otherwise moves the current file to `output/archive/<name>_<date>.txt` and installs the new one.

Output per line: airspace count and size, `unchanged`, or the reason for a failure (HTTP code, not OpenAir, …).
The summary lists every failed source with its URL. Exit code is `0` only when all sources succeeded,
which makes it cron-friendly.

### `add_airspace.sh <file|folder> [...]`

Adds OpenAir files you already have, for example old releases that are no longer online, to `output/archive/`.

```bash
./add_airspace.sh ~/Downloads/Airspaces            # every .txt/.sua/.air/.openair in a folder (recursive)
./add_airspace.sh Dutch.airspace2020.txt EHv14_5.txt
```

- Every file is validated first; invalid files are rejected with the reason.
- The original filename is kept (stored as `.txt`).
- Never overwrites: identical copies are skipped (`=`), and a different file with the same name is stored as `name_2.txt`, `name_3.txt`, …

### `scripts/validate_airspace.sh <file|folder> [...]`

Checks files without downloading anything.

```bash
./scripts/validate_airspace.sh output/                      # current files + archive
./scripts/validate_airspace.sh output/france.txt
```

Reports the airspace count and size per file, warns when `AN` names are missing, and exits non-zero if
any file is invalid.

### `scripts/lvnl_to_openair.py <output.txt>`

Converts the official LVNL airspace feed to OpenAir on its own (used automatically by the downloader).

```bash
python3 scripts/lvnl_to_openair.py netherlands.txt
# 329 airspaces, AIRAC 2026-10-01
```

---

## 🗂️ Where Files Go

```
output/
├── germany.txt                      ← always the latest valid version, stable name
├── netherlands.txt
├── ...
└── archive/
    ├── germany_2026-06-12.txt       ← previous version, dated by when it was downloaded
    ├── belgium_weekdays_2024.txt
    └── Dutch.airspace2020.txt       ← your own files from add_airspace.sh
```

Stable names in `output/` make it easy to sync or copy to a device. Every older version stays available
in `output/archive/`. Both folders are git-ignored.

---

## 📝 The Source List (`sources.txt`)

One source per line:

```
region | name | description | url
```

| Field | Meaning |
|---|---|
| `region` | Section heading in the output, and usable as a filter (`Europe`, `Americas`, `Other`) |
| `name` | Output file name: `output/<name>.txt`. Keep it stable and without a year |
| `description` | Shown while downloading; put the release date here |
| `url` | `http(s)://…` download link, or `lvnl://airspace` for the Dutch LVNL feed |

```
Europe | germany     | Germany (DAeC Sep 2026)                    | https://www.daec.de/media/files/Dateien/Fachbereiche/Luftraum_und_Flugsicherheit/2026_09_Airspace_Germany_OA1.txt
Europe | netherlands | Netherlands (official LVNL, current AIRAC) | lvnl://airspace
```

- **Update a country:** replace its URL (and the date in the description).
- **Add a country:** add a line.
- **Disable a source:** put `#` in front of the line.

> 💡 SoaringWeb renames files with every release. The current filename for most countries is in
> [XCSoar's airspace index](https://github.com/XCSoar/xcsoar-data-content/tree/master/data/remote/airspace),
> which is synced automatically from SoaringWeb and DAeC.

---

## 🌐 Coverage

**62 sources · 41 countries · 35,411 airspaces · 21 MB** (verified October 2026)

### Europe (31 countries)

| Country | Source | Release |
|---|---|---|
| 🇧🇪🇱🇺 Belgium & Luxembourg | LVZC: weekdays, weekdays gliding, weekends, EBR78 | Mar 2026 |
| 🇧🇬 Bulgaria | SoaringWeb | 2023 |
| 🇭🇷 Croatia | SoaringWeb | 2012 ⚠️ |
| 🇨🇿 Czechia | SoaringWeb, XCSoar | Aug 2025 |
| 🇩🇰 Denmark | SoaringWeb | Feb 2026 |
| 🇪🇪 Estonia | SoaringWeb | 2015 ⚠️ |
| 🇫🇮 Finland | SoaringWeb, Aviamaps, PIK static, PIK daily | 2026 / live |
| 🇫🇷 France | SoaringWeb, Planeur-Net | Jul 2026 / live |
| 🇩🇪 Germany | DAeC (official), GitHub mirror, border, military low-flying | Sep 2026 |
| 🇬🇷 Greece | SoaringWeb | old ⚠️ |
| 🇭🇺 Hungary | SoaringWeb | 2026 |
| 🇮🇸 Iceland | SoaringWeb | 2018 |
| 🇮🇪 Ireland | SoaringWeb | 2025 |
| 🇮🇹 Italy | SoaringWeb | Apr 2025 |
| 🇱🇻 Latvia | SoaringWeb | 2014 ⚠️ |
| 🇱🇹 Lithuania | SoaringWeb | 2026 |
| 🇲🇰 North Macedonia | SoaringWeb | 2018 |
| 🇳🇱 Netherlands | **LVNL official feed** + community file | every AIRAC / Feb 2025 |
| 🇳🇴 Norway | SoaringWeb | 2025 |
| 🇵🇱 Poland | SoaringWeb | Jul 2026 |
| 🇵🇹 Portugal | SoaringWeb | 2020 |
| 🇷🇴 Romania | SoaringWeb | May 2025 |
| 🇷🇺 Russia | SoaringWeb | 2013 ⚠️ |
| 🇸🇰 Slovakia | SoaringWeb, XCSoar | Apr 2024 |
| 🇸🇮 Slovenia | SoaringWeb | 2016 ⚠️ |
| 🇪🇸 Spain | SoaringWeb (full + reduced) | Jul 2026 |
| 🇸🇪 Sweden | SoaringWeb | Aug 2026 |
| 🇨🇭 Switzerland | SoaringWeb (SFVS), segelflug.ch eDABS | Mar 2026 |
| 🇺🇦 Ukraine | SoaringWeb | 2021 |
| 🇬🇧 United Kingdom | asselect.uk (generated from the UK AIP) | live |
| 🌍 Thermal hotspots | glidinghotspots.eu (overlay, not airspace) | live |

### Americas (4 countries)

| Country | Source | Release |
|---|---|---|
| 🇺🇸 USA | SoaringWeb | Sep 2026 |
| 🇨🇦 Canada | SoaringWeb (2 versions), XCSoar, Canada/US border | v3.23 |
| 🇧🇷 Brazil | SoaringWeb | 2017 |
| 🇨🇴 Colombia | SoaringWeb | 2018 |

### Asia, Oceania & Africa (6 countries)

| Country | Source | Release |
|---|---|---|
| 🇦🇺 Australia | SoaringWeb (with/without FIA), HG/PG site guide | Jul 2026 |
| 🇳🇿 New Zealand | SoaringWeb | 2024 |
| 🇮🇱 Israel | SoaringWeb | Oct 2025 |
| 🇯🇵 Japan | SoaringWeb | 2019 |
| 🇿🇦 South Africa | SoaringWeb, XCSoar | Jan 2025 |
| 🇲🇼 Malawi | XCSoar | — |

⚠️ = more than 5 years old. Treat it as a rough guide only.

### Not available as free OpenAir

**Austria** (no current free file; keep an old one with `add_airspace.sh`), Serbia, Bosnia, Montenegro,
Albania, Turkey, Belarus, Moldova, and most of Asia, Africa and South America.
[openAIP](https://www.openaip.net) covers every country, but its export bucket currently requires a Google
Cloud billing account and its API needs a personal key.

---

## 🇳🇱 Netherlands: Official LVNL Data

`lvnl://airspace` isn't a file download. `scripts/lvnl_to_openair.py` reads the
**Airspaces_data** feed that LVNL (Dutch Air Traffic Control) publishes as open data on
[geoportaal.lvnl.nl](https://geoportaal.lvnl.nl). It comes straight from LVNL's aeronautical
database and is **refreshed every AIRAC cycle**, so it picks up airspace changes such as the new
structure from **AIRAC 26 November 2026** without waiting for a community file.

| LVNL layer | OpenAir class |
|---|---|
| CTR, TMA, CTA, VFR area | airspace class from the data (A–E) |
| ATZ | `D` |
| TMZ / RMZ | `TMZ` / `RMZ` |
| Prohibited / Restricted, TSA, TRA | `P` / `R` |
| Danger, Parajump, Climb area, Helicopter zones, Low flying area | `Q` |
| Glider area | `GSEC` |

FIR, IFR, ACC sector and delegated-area layers are left out. LVNL draws arcs with thousands of
points, so polygons are simplified (Douglas–Peucker, ~15 m). That keeps the file around 730 KB
with no visible loss at 1-arc-second OpenAir resolution. The file header shows the AIRAC effective date.

The community file (by Nico B, covering up to FL095 over the mainland) is still available as
`netherlands_community`.

## 🇧🇪 Belgium: LVZC Yearly Release

LVZC (Liga van Vlaamse Zweefvliegclubs) publishes new Belgian files each year around **31 March** at
[lvzc.be → Luchtruimbestanden](https://www.lvzc.be/index.php/luchtruim/luchtruimbestanden).
The 2026 release fixes many problems in earlier files: areas that weren't closed, arc (`DA` → `DB`)
and circle definitions, center points, and class typos. Four files are included:

| Name | Use |
|---|---|
| `belgium_weekdays` | Weekdays when the military is active, everything |
| `belgium_weekdays_gliding` | Weekdays, gliding (GAA) version |
| `belgium_weekends` | Weekends and holidays, below FL095 |
| `belgium_ebr78_notam` | Load **only** when EBR78 is activated by NOTAM |

When LVZC publishes next year's folder, update these 4 URLs in `sources.txt`.

---

## 🎨 OpenAir Format

```
AC P                          # class: P, R, Q, A–G, CTR, TMZ, RMZ, GSEC, …
AN EHP 25                     # name
AH 2000FT MSL                 # ceiling
AL SFC                        # floor
AF 132.350                    # frequency (optional)
DP 52:03:43 N 004:18:20 E     # polygon point
V X=52:10:47 N 005:13:38 E    # center for circles/arcs
V D=-                         # arc direction (+ clockwise, default)
DB 52:00:00 N 005:00:00 E, 52:05:00 N 005:10:00 E   # arc between two points
DA 5, 270, 90                 # arc: radius NM, start bearing, end bearing
DC 0.5                        # circle, radius NM
```

Many published files are **Latin-1 / Windows-1252 with CRLF** line endings, use `V X = ` with spaces,
or write coordinates without a space (`49:29:37N`). The validator handles all of these, and your app's
parser should too.

Spec: [Naviter OpenAir format support](https://github.com/naviter/seeyou_file_formats/blob/main/OpenAir_File_Format_Support.md)

---

## 🛠️ Compatible Software

- **Android/iOS:** XCTrack, iFuel Navigator, XCSoar, LK8000
- **Desktop:** XCSoar, SeeYou, LK8000
- **Devices:** LXNav, Oudie, Skytraxx, Flymaster (via their converters)

---

## 📁 Project Structure

```
Airspace_Downloader/
├── download_airspaces.sh         ← Main download script
├── add_airspace.sh               ← Add your own (old) files to the archive
├── sources.txt                   ← The list of sources - edit this
├── scripts/
│   ├── openair_lib.sh            ← Shared OpenAir checks (sourced by the scripts)
│   ├── validate_airspace.sh      ← Validation tool
│   └── lvnl_to_openair.py        ← Netherlands LVNL feed → OpenAir
├── output/                       ← Latest version of every source (git-ignored)
│   └── archive/                  ← Previous versions and your own files
├── download.log                  ← Run history (git-ignored)
├── README.md
├── QUICKSTART.md
├── CHANGELOG.md
└── LICENSE
```

---

## 🔧 Automation

```bash
# crontab -e: update every Sunday at 2 AM, appending output to a log
0 2 * * 0 /path/to/Airspace_Downloader/download_airspaces.sh >> /path/to/airspace_cron.log 2>&1
```

Because unchanged files are skipped, the archive only grows when a source really changes. The script
exits non-zero when any source fails, so cron or a CI job can alert you.

---

## 🐛 Troubleshooting

**`✗ Failed (HTTP 404)`**: the source renamed its file. Find the new name on the source site (or in
[XCSoar's index](https://github.com/XCSoar/xcsoar-data-content/tree/master/data/remote/airspace)) and update `sources.txt`.
Your previous file in `output/` is kept.

**`✗ Not an OpenAir file (got a web page instead of a file)`**: the site returned an error or a bot
challenge page (e.g. Cloudflare). Try again later, or download it in a browser and use `add_airspace.sh`.

**`✗ LVNL conversion failed`**: check `python3 --version` and your connection, then see `download.log`.

**`Permission denied`**: `chmod +x download_airspaces.sh add_airspace.sh scripts/*.sh`

**`curl: command not found`**: `sudo apt install curl` (Debian/Ubuntu), `sudo dnf install curl` (Fedora), `brew install curl` (macOS)

---

## 🤝 Contributing

Found a newer file or a new country? Update `sources.txt`, run
`./download_airspaces.sh <name>` to verify it, and open a pull request.

Ideas: openAIP integration (per-user API key), more official ANSP feeds like LVNL, KML/GeoJSON export.

---

## 📞 Airspace Data Issues

Report errors in the data to the original maintainers:
[SoaringWeb](https://soaringweb.org/Airspace/) ·
[LVNL](https://geoportaal.lvnl.nl) ·
[LVZC](https://www.lvzc.be/) ·
[DAeC](https://www.daec.de/) ·
[planeur-net](https://github.com/planeur-net/airspace/issues) ·
[asselect](https://asselect.uk/)

---

## 📜 License

MIT, see [LICENSE](LICENSE). The airspace data itself belongs to its providers and is subject to their terms.

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md). Version 2.0 (October 2026) adds the source list, the archive,
`add_airspace.sh`, filters, the LVNL Netherlands converter, Belgium 2026 and many new countries.

---

## 🙏 Acknowledgments

**SoaringWeb** (John Leibacher) · **LVNL** · **LVZC** · **DAeC** · **planeur-net** · **asselect.uk** ·
**segelflug.ch** · **PIK** · **Aviamaps** · **XCSoar team** · and all volunteer maintainers who keep airspace data current.

---

<div align="center">

**Airspace Downloader v2.0**

[Report Bug](https://github.com/Bi7Wis3/Airspace_Downloader/issues) • [Request Feature](https://github.com/Bi7Wis3/Airspace_Downloader/issues) • [Contribute](https://github.com/Bi7Wis3/Airspace_Downloader/pulls)

**Last Updated:** October 16, 2026

**⚠️ Always check NOTAMs and official charts before flight! ⚠️**

</div>
