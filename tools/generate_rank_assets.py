#!/usr/bin/env python3
"""Generate Stone Set's curated rank-v6 emblem assets.

Base insignia geometry comes from Kenney's CC0 Ranks pack (70x). The script
uses fixed source-file mappings and applies a shared Stone Set shield system,
family palettes, normalization, provenance, and integrity checks.
"""

from __future__ import annotations

import hashlib
import json
import tempfile
import urllib.request
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageOps

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets" / "ranks"
SOURCE_COMMIT = "d80270f77bf820c92c796b55ddf685b8b6298a44"
SOURCE_BASE = (
    "https://raw.githubusercontent.com/Kiril-P/Polygon-Protocol/"
    f"{SOURCE_COMMIT}/assets/kenney_ranks-pack/PNG/Retina/Gold"
)
SIZE = 256
SCALE = 2

RANKS = [
    (1, "Bronze I", 0, "01_bronze_i.png", 1, "bronze", 1),
    (2, "Bronze II", 100, "02_bronze_ii.png", 2, "bronze", 2),
    (3, "Bronze III", 200, "03_bronze_iii.png", 3, "bronze", 3),
    (4, "Silver I", 325, "04_silver_i.png", 14, "silver", 1),
    (5, "Silver II", 475, "05_silver_ii.png", 15, "silver", 2),
    (6, "Silver III", 650, "06_silver_iii.png", 16, "silver", 3),
    (7, "Gold I", 825, "07_gold_i.png", 29, "gold", 1),
    (8, "Gold II", 1025, "08_gold_ii.png", 30, "gold", 2),
    (9, "Gold III", 1250, "09_gold_iii.png", 31, "gold", 3),
    (10, "Platinum I", 1500, "10_platinum_i.png", 46, "platinum", 1),
    (11, "Platinum II", 1775, "11_platinum_ii.png", 47, "platinum", 2),
    (12, "Platinum III", 2075, "12_platinum_iii.png", 48, "platinum", 3),
    (13, "Diamond I", 2400, "13_diamond_i.png", 52, "diamond", 1),
    (14, "Diamond II", 2750, "14_diamond_ii.png", 53, "diamond", 2),
    (15, "Diamond III", 3125, "15_diamond_iii.png", 54, "diamond", 3),
    (16, "Elite", 3525, "16_elite.png", 65, "elite", 1),
    (17, "Champion", 3950, "17_champion.png", 66, "champion", 2),
    (18, "Apex", 4400, "18_apex.png", 67, "apex", 3),
    (19, "Prodigy", 4900, "19_prodigy.png", 69, "prodigy", 4),
    (20, "Adonis", 5500, "20_adonis.png", 73, "adonis", 5),
]

# inner, outer-low, outer-mid, outer-high, emblem-low, emblem-mid, emblem-high
PALETTES = {
    "bronze": ("#17100E", "#653820", "#A86137", "#E2A071", "#7B4326", "#C97843", "#F3C09B"),
    "silver": ("#13171C", "#4D5964", "#8796A3", "#DCE5EA", "#64727E", "#AEBBC5", "#F8FCFF"),
    "gold": ("#18130A", "#76500F", "#B67D18", "#F2D276", "#956113", "#D99A25", "#FFF0A8"),
    "platinum": ("#0E1820", "#365F70", "#6EA9BC", "#DDF8FF", "#4E8292", "#96D3E2", "#F7FEFF"),
    "diamond": ("#081522", "#15527C", "#2EA7D7", "#C6F7FF", "#1D78A6", "#52D6F5", "#F1FDFF"),
    "elite": ("#130A0E", "#44141F", "#85243A", "#ED5A75", "#5E1727", "#C42F50", "#FFD2DA"),
    "champion": ("#08142D", "#163D7A", "#2D6FD1", "#B8D4FF", "#A16B13", "#E0A62D", "#FFE6A0"),
    "apex": ("#10091D", "#3B1C63", "#6931A0", "#D6B4FF", "#4D2478", "#9D5EE8", "#F4E7FF"),
    "prodigy": ("#061820", "#145B6D", "#1FA6B9", "#B9FBFF", "#493276", "#8B67CF", "#FFF0B8"),
    "adonis": ("#16130E", "#7B5618", "#C18A2B", "#FFE7A3", "#B6BCC5", "#E9EEF3", "#FFFFFF"),
}


def rgba(value: str, alpha: int = 255) -> tuple[int, int, int, int]:
    value = value.lstrip("#")
    return tuple(int(value[index : index + 2], 16) for index in (0, 2, 4)) + (alpha,)


def shield_points(size: int, inset: int = 0) -> list[tuple[int, int]]:
    return [
        (size // 2, 14 + inset),
        (size - 41 - inset, 52 + inset // 2),
        (size - 41 - inset, 172 - inset // 2),
        (size // 2, size - 14 - inset),
        (41 + inset, 172 - inset // 2),
        (41 + inset, 52 + inset // 2),
    ]


def recolor(source: Image.Image, low: str, mid: str, high: str) -> Image.Image:
    source = source.convert("RGBA")
    alpha = source.getchannel("A")
    grayscale = ImageOps.grayscale(source)
    colored = ImageOps.colorize(
        grayscale,
        black=low,
        mid=mid,
        white=high,
        blackpoint=0,
        midpoint=145,
        whitepoint=255,
    ).convert("RGBA")
    colored.putalpha(alpha)
    return colored


def fit_visible(image: Image.Image, maximum_width: int, maximum_height: int) -> Image.Image:
    bounds = image.getchannel("A").getbbox()
    if bounds is None:
        raise ValueError("Source insignia has no visible pixels")
    cropped = image.crop(bounds)
    ratio = min(maximum_width / cropped.width, maximum_height / cropped.height)
    return cropped.resize(
        (max(1, round(cropped.width * ratio)), max(1, round(cropped.height * ratio))),
        Image.Resampling.LANCZOS,
    )


def fetch_source(source_number: int, directory: Path) -> Image.Image:
    target = directory / f"rank{source_number:03d}.png"
    url = f"{SOURCE_BASE}/rank{source_number:03d}.png"
    with urllib.request.urlopen(url, timeout=30) as response:
        target.write_bytes(response.read())
    image = Image.open(target).convert("RGBA")
    if image.size != (128, 128):
        raise ValueError(f"Unexpected source dimensions for {url}: {image.size}")
    return image


def make_badge(source: Image.Image, palette_name: str, level: int, minimum_rr: int) -> Image.Image:
    canvas_size = SIZE * SCALE
    inner, outer_low, outer_mid, outer_high, emblem_low, emblem_mid, emblem_high = PALETTES[palette_name]
    canvas = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))

    def scaled(points: list[tuple[int, int]]) -> list[tuple[int, int]]:
        return [(x * SCALE, y * SCALE) for x, y in points]

    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).polygon(
        [(x * SCALE, (y + 5) * SCALE) for x, y in shield_points(SIZE)],
        fill=(0, 0, 0, 96),
    )
    canvas.alpha_composite(shadow)

    outer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    outer_draw = ImageDraw.Draw(outer)
    outer_draw.polygon(scaled(shield_points(SIZE)), fill=rgba(outer_low))
    outer_draw.polygon(
        scaled([(128, 14), (215, 52), (215, 66), (128, 29), (41, 66), (41, 52)]),
        fill=rgba(outer_high),
    )
    canvas.alpha_composite(outer)

    middle = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(middle).polygon(scaled(shield_points(SIZE, 11)), fill=rgba(outer_mid))
    canvas.alpha_composite(middle)

    center = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    center_draw = ImageDraw.Draw(center)
    center_draw.polygon(scaled(shield_points(SIZE, 23)), fill=rgba(inner))
    center_draw.polygon(
        scaled([(128, 37), (191, 66), (191, 98), (128, 73), (65, 98), (65, 66)]),
        fill=rgba(outer_mid, 30),
    )
    canvas.alpha_composite(center)

    line_layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    line_draw = ImageDraw.Draw(line_layer)
    ring_total = 1 + int(minimum_rr >= 825) + int(minimum_rr >= 3525 and level >= 3)
    for ring in range(ring_total):
        points = scaled(shield_points(SIZE, 25 + ring * 5))
        line_draw.line(points + [points[0]], fill=rgba(outer_high, 190), width=2 * SCALE, joint="curve")
    canvas.alpha_composite(line_layer)

    if minimum_rr >= 2400:
        nodes = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
        nodes_draw = ImageDraw.Draw(nodes)
        positions = [(66, 76), (190, 76)]
        if minimum_rr >= 3525:
            positions += [(75, 169), (181, 169)]
        radius = (3 + min(level, 4)) * SCALE
        for x, y in positions:
            nodes_draw.ellipse(
                (x * SCALE - radius, y * SCALE - radius, x * SCALE + radius, y * SCALE + radius),
                fill=rgba(emblem_mid),
                outline=rgba(emblem_high),
                width=2 * SCALE,
            )
        canvas.alpha_composite(nodes)

    insignia = recolor(source, emblem_low, emblem_mid, emblem_high)
    if palette_name == "diamond":
        maximum_width, maximum_height = 154, 70
    elif minimum_rr >= 3525:
        maximum_width, maximum_height = 161, 112
    else:
        maximum_width, maximum_height = 167, 90
    insignia = fit_visible(insignia, maximum_width * SCALE, maximum_height * SCALE)
    x_position = (canvas_size - insignia.width) // 2
    y_position = round(canvas_size * 0.45 - insignia.height / 2)
    canvas.alpha_composite(insignia, (x_position, y_position))

    keystone = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    keystone_draw = ImageDraw.Draw(keystone)
    center_x, center_y = 128 * SCALE, 194 * SCALE
    width = (7 + level) * SCALE
    height = (5 + level // 2) * SCALE
    keystone_draw.polygon(
        [(center_x, center_y - height), (center_x + width, center_y), (center_x, center_y + height), (center_x - width, center_y)],
        fill=rgba(emblem_mid),
        outline=rgba(emblem_high),
        width=2 * SCALE,
    )
    canvas.alpha_composite(keystone)

    final = canvas.resize((SIZE, SIZE), Image.Resampling.LANCZOS)
    return final.quantize(colors=16, method=Image.Quantize.FASTOCTREE, dither=Image.Dither.NONE).convert("RGBA")


def write_documents(entries: list[dict[str, object]]) -> None:
    readme = """# Stone Set rank emblems

Status: `CURATED ASSET BASELINE — NOT YET INTEGRATED`

This directory contains the 20 textless emblems for Stone Set's accepted `rank-v6` ladder.

## Asset contract

- exactly one PNG per rank;
- stable ordered filenames;
- 256 x 256 RGBA with transparency;
- no embedded rank text, number, Roman numeral, or gym-equipment symbol;
- intended for Android and Flutter Web;
- application integration is deferred to a later implementation packet.

All emblems use one shared Stone Set shield treatment and insignia geometry from one CC0 Kenney source family. `manifest.json` is the authoritative rank-to-file mapping. `CONTACT_SHEET.md` is for repository review only.
"""
    license_text = f"""# Rank-emblem source and licence

## Base artwork

- Source: **Kenney Ranks pack (70x)**
- Creator: **Kenney**
- Licence: **Creative Commons CC0 1.0**
- Retrieval mirror commit: `{SOURCE_COMMIT}`

Attribution is not required by CC0. Stone Set retains this record as provenance.

## Stone Set transformations

Selected Gold retina PNGs are recolored, scaled, centered, placed in a shared Stone Set shield treatment, and normalized to transparent 256 x 256 PNGs. No proprietary game logo or trademarked rank artwork is included.
"""
    contact_lines = [
        "# Stone Set rank-emblem contact sheet",
        "",
        "Runtime code must use `manifest.json`; this page is for visual review.",
        "",
    ]
    for start in range(0, len(entries), 5):
        group = entries[start : start + 5]
        contact_lines.append("| " + " | ".join(f"{item['order']:02d} — {item['rank']}" for item in group) + " |")
        contact_lines.append("|" + "|".join(["---"] * len(group)) + "|")
        contact_lines.append("| " + " | ".join(f'<img src="{item["filename"]}" width="128" alt="{item["rank"]} rank emblem">' for item in group) + " |")
        contact_lines.append("| " + " | ".join(f"{item['minimumRR']:,} RR" for item in group) + " |")
        contact_lines.append("")

    (OUTPUT / "README.md").write_text(readme, encoding="utf-8")
    (OUTPUT / "LICENSE.md").write_text(license_text, encoding="utf-8")
    (OUTPUT / "CONTACT_SHEET.md").write_text("\n".join(contact_lines), encoding="utf-8")


def verify(entries: list[dict[str, object]]) -> None:
    expected = [row[3] for row in RANKS]
    actual = sorted(path.name for path in OUTPUT.glob("[0-9][0-9]_*.png"))
    if actual != expected:
        raise AssertionError(f"Unexpected rank files: {actual}")
    for entry in entries:
        path = OUTPUT / str(entry["filename"])
        raw = path.read_bytes()
        if not raw.startswith(b"\x89PNG\r\n\x1a\n"):
            raise AssertionError(f"Invalid PNG signature: {path}")
        if hashlib.sha256(raw).hexdigest() != entry["sha256"]:
            raise AssertionError(f"Digest mismatch: {path}")
        with Image.open(path) as image:
            if image.size != (SIZE, SIZE) or image.mode != "RGBA":
                raise AssertionError(f"Invalid image contract: {path}, {image.size}, {image.mode}")
            alpha = image.getchannel("A")
            if alpha.getbbox() is None or alpha.getextrema() != (0, 255):
                raise AssertionError(f"Missing non-empty transparency: {path}")


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    for stale in OUTPUT.glob("[0-9][0-9]_*.png"):
        stale.unlink()

    entries: list[dict[str, object]] = []
    with tempfile.TemporaryDirectory(prefix="stone-set-ranks-") as temp_directory:
        source_directory = Path(temp_directory)
        for order, name, minimum_rr, filename, source_number, palette, level in RANKS:
            source = fetch_source(source_number, source_directory)
            image = make_badge(source, palette, level, minimum_rr)
            target = OUTPUT / filename
            image.save(target, "PNG", optimize=True, compress_level=9)
            raw = target.read_bytes()
            bounds = image.getchannel("A").getbbox()
            entries.append(
                {
                    "order": order,
                    "rank": name,
                    "minimumRR": minimum_rr,
                    "filename": filename,
                    "dimensions": {"width": SIZE, "height": SIZE},
                    "format": "PNG",
                    "alpha": True,
                    "sourcePack": "Kenney Ranks pack (70x)",
                    "sourceVariant": "Gold retina PNG",
                    "sourceFile": f"rank{source_number:03d}.png",
                    "sourceLicense": "CC0-1.0",
                    "palette": palette,
                    "sha256": hashlib.sha256(raw).hexdigest(),
                    "visibleBounds": {"left": bounds[0], "top": bounds[1], "right": bounds[2], "bottom": bounds[3]},
                }
            )

    manifest = {
        "schemaVersion": 1,
        "rankConfiguration": "rank-v6",
        "assetSet": "stone-set-ranks-v1",
        "generatedOn": "2026-08-04",
        "source": {
            "name": "Kenney Ranks pack (70x)",
            "author": "Kenney",
            "license": "CC0-1.0",
            "mirrorCommit": SOURCE_COMMIT,
        },
        "assets": entries,
    }
    (OUTPUT / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    write_documents(entries)
    verify(entries)
    print(f"Generated and verified {len(entries)} Stone Set rank emblems in {OUTPUT}")


if __name__ == "__main__":
    main()
