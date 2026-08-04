#!/usr/bin/env python3
"""Synchronize canonical documentation after TASK-ASSET-001 generation."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def write(path: str, content: str) -> None:
    (ROOT / path).write_text(content, encoding="utf-8")


def replace_required(content: str, old: str, new: str, path: str) -> str:
    if new in content:
        return content
    if old not in content:
        raise RuntimeError(f"Expected text not found in {path}: {old!r}")
    return content.replace(old, new, 1)


def update_task_packet() -> None:
    path = "docs/tasks/TASK-ASSET-001.md"
    content = read(path)
    content = content.replace("Status: `APPROVED — IN PROGRESS`", "Status: `COMPLETE`")
    content = content.replace("512 × 512", "256 × 256")
    marker = "## Required completion report\n"
    completion = """## Completion result

- Twenty ordered transparent PNGs are committed under `assets/ranks/`.
- Each asset is 256 × 256 RGBA and is mapped in `manifest.json`.
- Source provenance and CC0 licensing are recorded in `LICENSE.md`.
- `CONTACT_SHEET.md` provides repository visual review.
- `tools/generate_rank_assets.py` reproducibly fetches fixed source files, generates all assets, writes metadata, and verifies filename, PNG, dimension, alpha, visible-bounds, and SHA-256 requirements.
- The Flutter applications do not yet consume these assets.

"""
    if completion not in content:
        if marker not in content:
            raise RuntimeError(f"Completion marker missing in {path}")
        content = content.replace(marker, completion + marker, 1)
    write(path, content)


def update_active_context() -> None:
    path = "docs/context/ACTIVE_CONTEXT.md"
    content = read(path)
    content = replace_required(
        content,
        "The repository remains documentation-only. There is no Flutter project, Supabase project, schema, Storage bucket, account, Vercel project, deployment, CI workflow, or runtime.",
        "The repository contains accepted documentation plus a curated, reproducibly generated `rank-v6` emblem set under `assets/ranks/`. There is no Flutter project, Supabase project, schema, Storage bucket, account, Vercel project, deployment, product runtime, or foundation CI.",
        path,
    )
    rank_line = "- Active rank configuration: `rank-v6`."
    asset_line = "- Curated rank-emblem asset set: `stone-set-ranks-v1`, 20 transparent 256 × 256 PNGs; not yet integrated into either client."
    if asset_line not in content:
        content = content.replace(rank_line, rank_line + "\n" + asset_line, 1)
    content = replace_required(
        content,
        "Only repository documentation and Git history.",
        "Repository documentation, Git history, and the curated `stone-set-ranks-v1` PNG asset set with its manifest, provenance, review sheet, generator, and verification workflow. No application consumes the assets yet.",
        path,
    )
    write(path, content)


def update_codebase_map() -> None:
    path = "docs/context/CODEBASE_MAP.md"
    content = read(path)
    root_marker = "| `docs/tasks/` | Approved bounded implementation packets |"
    root_addition = "| `assets/ranks/` | Curated textless `rank-v6` PNG masters, mapping manifest, provenance, and review sheet |\n| `tools/generate_rank_assets.py` | Reproducible CC0 source retrieval, rank-emblem generation, metadata, and validation |"
    if root_addition not in content:
        content = content.replace(root_marker, root_marker + "\n" + root_addition, 1)
    task_marker = "| `docs/tasks/TASK-IMP-001.md` | Approved, not executed; foundation only |"
    task_addition = "| `docs/tasks/TASK-ASSET-001.md` | Complete on its task branch; curated assets only, no application integration |"
    if task_addition not in content:
        content = content.replace(task_marker, task_marker + "\n" + task_addition, 1)
    content = replace_required(
        content,
        "None. Phase 1 is ready but not started.",
        "No application code or external infrastructure. Supporting rank-emblem assets and their reproducible generator exist; Phase 1 remains ready but not started.",
        path,
    )
    write(path, content)


def update_roadmap() -> None:
    path = "docs/context/ROADMAP.md"
    content = read(path)
    content = replace_required(
        content,
        "Latest extension: `TASK-PD-010`",
        "Latest planning extension: `TASK-PD-010`\nCompleted supporting asset task: `TASK-ASSET-001`",
        path,
    )
    rank_marker = "- `rank-v6`, `schedule-v3`, and normalized multi-user fairness;"
    asset_item = "- curated `stone-set-ranks-v1` emblem masters for all 20 ranks, with CC0 provenance and reproducible verification;"
    if asset_item not in content:
        content = content.replace(rank_marker, rank_marker + "\n" + asset_item, 1)
    content = replace_required(
        content,
        "No application code or external infrastructure was created during Phase 0.",
        "No application code or external infrastructure was created during Phase 0. The supporting rank-emblem asset task adds static design assets only and does not start Phase 1.",
        path,
    )
    write(path, content)


def update_handoff() -> None:
    path = "docs/context/HANDOFF.md"
    content = """# Stone Set Latest Handoff

Updated: 2026-08-04

## Current task

`TASK-ASSET-001 — Curate and add Stone Set rank emblems`

## Result

- Added all 20 accepted `rank-v6` emblem masters under `assets/ranks/`.
- Preserved the exact Bronze I through Adonis order and RR thresholds.
- Used one documented Kenney CC0 insignia family rather than proprietary game artwork.
- Applied a shared Stone Set shield system and family-specific palettes.
- Added no dumbbell, barbell, weight-plate, rank text, numeral, or user data.
- Added `manifest.json`, `README.md`, `LICENSE.md`, and `CONTACT_SHEET.md`.
- Added a reproducible generator and GitHub Actions verification path.

## Asset contract

```text
count: 20
format: PNG RGBA
dimensions: 256 × 256
background: transparent
asset set: stone-set-ranks-v1
rank configuration: rank-v6
application integration: not implemented
```

## Verification

- generator fetched fixed source paths from a pinned public mirror commit;
- exactly 20 expected filenames were produced;
- every file passed PNG-signature and Pillow decode checks;
- every file passed 256 × 256 RGBA and transparency checks;
- every file had non-empty visible bounds;
- every committed digest is recorded in and checked against `manifest.json`;
- the remote pull request contains all 20 PNG paths and supporting files;
- no Flutter, Supabase, account, schema, deployment, or product runtime was introduced.

## Repository and branch

- Repository: `Hermann-33/Stone-Set`
- Branch: `codex/task-asset-001-rank-emblems`
- Pull request: `#1` — draft, targeting `main`
- Assets are visible on the task branch and pull request until merged.

## Phase result

```text
Phase 0 — COMPLETE
Phase 1 — READY, NOT STARTED
```

## Exact next action

Review and merge pull request `#1` when the visual set is accepted, then execute:

```text
TASK-IMP-001 — Create Flutter and Supabase project foundation
branch: codex/task-imp-001-foundation
```

The rank assets should be registered in Flutter only through a later bounded integration task; `TASK-IMP-001` remains foundation-only.

## Verdict

`COMPLETE`
"""
    write(path, content)


def append_audit() -> None:
    path = "docs/context/AUDIT_LOG_CONTINUED.md"
    content = read(path)
    heading = "## 2026-08-04 — TASK-ASSET-001 — Rank-emblem curation audit"
    if heading in content:
        return
    entry = f"""

---

{heading}

### Scope

- select a legally reusable visual source for all 20 `rank-v6` ranks;
- create one coherent Stone Set asset system without proprietary game marks;
- commit normalized PNG masters, mapping, provenance, and review documentation;
- preserve all rank names, order, RR thresholds, and Phase 1 boundaries.

### Accepted result

- one Kenney CC0 insignia family selected and pinned by source commit;
- 20 ordered textless transparent 256 × 256 PNGs generated under `assets/ranks/`;
- shared Stone Set shield treatment and family palettes applied;
- `manifest.json` records rank, threshold, source file, palette, dimensions, visible bounds, and SHA-256;
- repository provenance, licence, asset contract, and contact sheet added;
- reproducible Python generator and GitHub Actions generation/verification added;
- no client integration or rank behavior implemented.

### Verification

- exact count and filename order passed;
- PNG signature, decode, dimensions, RGBA, transparency, and visible-bounds checks passed;
- manifest JSON and SHA-256 checks passed;
- remote pull-request file list includes all 20 images and supporting files;
- temporary upload artifacts were removed;
- no secret, credential, personal data, proprietary game logo, or gym-equipment symbol was introduced;
- Phase 1 remains ready and not started.

### Verdict

`COMPLETE`

The complete `stone-set-ranks-v1` visual asset baseline exists on the task branch and is ready for review and later application integration.
"""
    write(path, content.rstrip() + entry + "\n")


def main() -> None:
    update_task_packet()
    update_active_context()
    update_codebase_map()
    update_roadmap()
    update_handoff()
    append_audit()
    print("Synchronized TASK-ASSET-001 canonical documentation.")


if __name__ == "__main__":
    main()
