#!/usr/bin/env python3
"""Convert the official LVNL (Dutch ANSP) airspace feed to an OpenAir file.

LVNL publishes the Dutch airspace from its aeronautical database as a public
ArcGIS feature service, refreshed every AIRAC cycle. This script reads every
VFR-relevant layer and writes OpenAir in the same style as the community
Netherlands file (class letters for CTR/TMA/CTA, Q for danger-type areas).

Usage: python3 lvnl_to_openair.py <output.txt>
"""

import datetime
import json
import sys
import urllib.parse
import urllib.request

SERVICE = ("https://services-eu1.arcgis.com/OtUwzhpKSdeXgRIB/arcgis/rest/services/"
           "Airspaces_data/FeatureServer")

# layer id -> (OpenAir AC class, or None to use the feature's own Class field)
LAYERS = {
    15: None,     # CTR
    14: None,     # TMA
    13: None,     # CTA
    12: None,     # VFR area
    7: "D",       # ATZ
    8: "TMZ",     # TMZ / RTMZ
    10: "RMZ",    # RMZ
    19: "P",      # Prohibited
    18: "R",      # Restricted
    3: "R",       # TSA
    5: "R",       # TRA
    17: "Q",      # Danger
    6: "Q",       # Parajump
    16: "Q",      # Climb area
    9: "Q",       # Helicopter protection zones
    1: "Q",       # Low flying area
    11: "GSEC",   # Glider area
}

PAGE_SIZE = 1000


def fetch_layer(layer_id):
    features = []
    offset = 0
    while True:
        params = urllib.parse.urlencode({
            "where": "1=1",
            "outFields": "*",
            "outSR": "4326",
            "f": "geojson",
            "resultOffset": offset,
            "resultRecordCount": PAGE_SIZE,
        })
        req = urllib.request.Request(f"{SERVICE}/{layer_id}/query?{params}",
                                     headers={"User-Agent": "AirspaceDownloader/2.0"})
        with urllib.request.urlopen(req, timeout=60) as resp:
            data = json.load(resp)
        if "error" in data:
            raise RuntimeError(f"layer {layer_id}: {data['error']}")
        page = data.get("features", [])
        features.extend(page)
        if len(page) < PAGE_SIZE and not data.get("properties", {}).get("exceededTransferLimit"):
            return features
        offset += len(page)


def fmt_limit(value, unit, ref):
    if value is None:
        return "SFC"
    unit = (unit or "").upper()
    ref = (ref or "").upper()
    value = int(round(value))
    if unit == "FL":
        return "UNL" if value >= 999 else f"FL{value:03d}"
    if value == 0 and ref in ("SFC", "GND", ""):
        return "SFC"
    if ref in ("SFC", "GND"):
        return f"{value}FT AGL"
    return f"{value}FT MSL"


def dms(value, pos, neg, deg_width):
    hemi = pos if value >= 0 else neg
    total = int(round(abs(value) * 3600))
    d, rem = divmod(total, 3600)
    m, s = divmod(rem, 60)
    return f"{d:0{deg_width}d}:{m:02d}:{s:02d} {hemi}"


def outer_rings(geometry):
    if not geometry:
        return []
    if geometry["type"] == "Polygon":
        return [geometry["coordinates"][0]]
    if geometry["type"] == "MultiPolygon":
        return [poly[0] for poly in geometry["coordinates"]]
    return []


def name_for(props):
    designator = (props.get("Designator") or "").strip()
    name = (props.get("Name") or "").strip()
    if designator and name and designator.upper() not in name.upper():
        return f"{designator} {name}"
    return name or designator or "UNNAMED"


def simplify(points, tolerance):
    # Iterative Douglas-Peucker; LVNL densifies arcs into thousands of vertices
    if len(points) < 3:
        return points
    keep = [False] * len(points)
    keep[0] = keep[-1] = True
    stack = [(0, len(points) - 1)]
    while stack:
        first, last = stack.pop()
        (x1, y1), (x2, y2) = points[first], points[last]
        dx, dy = x2 - x1, y2 - y1
        seg_len_sq = dx * dx + dy * dy
        max_dist, index = 0.0, None
        for i in range(first + 1, last):
            px, py = points[i]
            if seg_len_sq == 0:
                dist_sq = (px - x1) ** 2 + (py - y1) ** 2
            else:
                t = max(0.0, min(1.0, ((px - x1) * dx + (py - y1) * dy) / seg_len_sq))
                dist_sq = (px - x1 - t * dx) ** 2 + (py - y1 - t * dy) ** 2
            if dist_sq > max_dist:
                max_dist, index = dist_sq, i
        if index is not None and max_dist > tolerance * tolerance:
            keep[index] = True
            stack.append((first, index))
            stack.append((index, last))
    return [p for p, k in zip(points, keep) if k]


def write_record(out, ac_class, name, upper, lower, ring):
    points = [tuple(p[:2]) for p in ring]
    if len(points) > 1 and points[0] == points[-1]:
        points = points[:-1]
    # ~15 m; well below the 1 arc-second (~30 m) resolution of OpenAir DP lines
    points = simplify(points, 0.00015)
    lines = []
    for lon, lat in points:
        line = f"DP {dms(lat, 'N', 'S', 2)} {dms(lon, 'E', 'W', 3)}"
        if not lines or lines[-1] != line:
            lines.append(line)
    if len(lines) < 3:
        return False
    out.write(f"AC {ac_class}\n")
    out.write(f"AN {name}\n")
    out.write(f"AH {upper}\n")
    out.write(f"AL {lower}\n")
    out.write("\n".join(lines) + "\n")
    out.write("*\n")
    return True


def main():
    if len(sys.argv) != 2:
        print(__doc__.strip().splitlines()[-1])
        return 2

    records = []
    effective = set()
    for layer_id, fixed_class in LAYERS.items():
        for feature in fetch_layer(layer_id):
            props = feature.get("properties") or {}
            ac_class = fixed_class or (props.get("Class") or "").strip().upper() or "D"
            upper = fmt_limit(props.get("UpperLimit"), props.get("UpperLimitUnit"),
                              props.get("UpperLimitReference"))
            lower = fmt_limit(props.get("LowerLimit"), props.get("LowerLimitUnit"),
                              props.get("LowerLimitReference"))
            if props.get("EffectiveDate"):
                effective.add(datetime.datetime.fromtimestamp(
                    props["EffectiveDate"] / 1000, datetime.timezone.utc).date())
            for ring in outer_rings(feature.get("geometry")):
                records.append((ac_class, name_for(props), upper, lower, ring))

    if not records:
        print("No airspaces returned by LVNL", file=sys.stderr)
        return 1

    records.sort(key=lambda r: (r[0], r[1]))
    airac = ", ".join(str(d) for d in sorted(effective)) or "unknown"
    written = 0
    with open(sys.argv[1], "w", encoding="utf-8", newline="\n") as out:
        out.write("*" * 60 + "\n")
        out.write("* Airspace for the Netherlands\n")
        out.write("* Source: LVNL open data (geoportaal.lvnl.nl), Airspaces_data\n")
        out.write(f"* AIRAC effective date: {airac}\n")
        out.write(f"* Generated: {datetime.date.today()}\n")
        out.write("* NOT OFFICIAL for navigation. Always check the AIP and NOTAMs.\n")
        out.write("*" * 60 + "\n*\n")
        for record in records:
            if write_record(out, *record):
                written += 1

    print(f"{written} airspaces, AIRAC {airac}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
