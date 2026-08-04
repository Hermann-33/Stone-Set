# TASK-ASSET-001 — Curate and add Stone Set rank emblems

Status: `COMPLETE`
Approved by: user request on 2026-08-04
Target: supporting product-asset work before Phase 1

## Objective

Curate, normalize, document, and commit one legally reusable emblem for each of Stone Set's 20 accepted `rank-v6` ranks without implementing rank behavior or application UI.

## Mandatory repository reads

1. `AGENTS.md`
2. `docs/context/ACTIVE_CONTEXT.md`
3. `docs/context/PROJECT_BRIEF.md`
4. `docs/context/ARCHITECTURE.md`
5. `docs/context/CODEBASE_MAP.md`
6. `docs/context/ROADMAP.md`
7. `docs/context/WORKFLOW.md`
8. `docs/context/HANDOFF.md`
9. `docs/product/RANK_SYSTEM.md`
10. this task packet

## Verified starting state

- Repository: `Hermann-33/Stone-Set`.
- Base branch: `main` at `9164a52cce2043f02717f2c457897d116edd3f9c`.
- Repository contains documentation only.
- Phase 0 is complete and Phase 1 is ready but not started.
- `rank-v6` defines 20 ranks from Bronze I through Adonis.
- No application asset directory or rank artwork exists.

## Branch and Git requirements

- Work only on `codex/task-asset-001-rank-emblems`.
- Do not modify `main` directly.
- Commit messages must contain `TASK-ASSET-001`.
- Do not rewrite history or force-push.
- Report the final branch, commit, verification, and remaining integration work.

## Accepted visual-source decision

Use the Kenney `Ranks pack (70×)` as the sole base-art family.

Reasons:

- Creative Commons CC0;
- more than 70 coherent fictional rank insignia;
- textless transparent PNG and vector source variants;
- sufficient internal families for three-division ranks and standalone upper ranks;
- avoids copying proprietary game rank marks;
- one source family is more coherent than mixing unrelated packs.

Attribution is not required by CC0, but Stone Set will retain provenance and optional credit in the repository.

## Exact scope

1. Create `assets/ranks/`.
2. Add exactly 20 transparent PNG files with these names:

```text
01_bronze_i.png
02_bronze_ii.png
03_bronze_iii.png
04_silver_i.png
05_silver_ii.png
06_silver_iii.png
07_gold_i.png
08_gold_ii.png
09_gold_iii.png
10_platinum_i.png
11_platinum_ii.png
12_platinum_iii.png
13_diamond_i.png
14_diamond_ii.png
15_diamond_iii.png
16_elite.png
17_champion.png
18_apex.png
19_prodigy.png
20_adonis.png
```

3. Normalize each asset to a 256 × 256 transparent canvas.
4. Preserve one coherent rendering language and strong small-size readability.
5. Use increasing internal complexity for I, II, and III within each three-tier rank family.
6. Use distinct but progressively more prestigious palettes for Elite through Adonis.
7. Add `assets/ranks/README.md` describing mapping, intended usage, and integration constraints.
8. Add `assets/ranks/LICENSE.md` recording CC0 source and optional credit.
9. Add `assets/ranks/manifest.json` recording rank, RR threshold, source index, palette, dimensions, and SHA-256 digest.
10. Add a visual contact sheet for repository review only.
11. Synchronize current-state, codebase-map, roadmap, handoff, and append-only audit documentation.

## Visual mapping

| Stone Set family | Kenney source geometry |
|---|---|
| Bronze I–III | `rank001`–`rank003`: bar plus one, two, or three stars |
| Silver I–III | `rank014`–`rank016`: chevron plus one, two, or three stars |
| Gold I–III | `rank029`–`rank031`: framed bars plus one, two, or three stars |
| Platinum I–III | `rank046`–`rank048`: chevron and lower bar plus one, two, or three stars |
| Diamond I–III | `rank052`–`rank054`: one, two, or three diamond marks |
| Elite | `rank065`: singular four-point prestige star |
| Champion | `rank066`: prestige star and chevron |
| Apex | `rank067`: angular peak frame |
| Prodigy | `rank069`: triple ascending peak frame |
| Adonis | `rank073`: framed central diamonds and stars |

## Palette mapping

- Bronze: warm dark bronze.
- Silver: neutral polished silver.
- Gold: warm gold.
- Platinum: cool blue-white platinum.
- Diamond: cyan-blue crystal.
- Elite: black titanium and crimson.
- Champion: royal blue and gold.
- Apex: obsidian and violet.
- Prodigy: cyan, violet, and pale gold.
- Adonis: white, platinum, and radiant gold.

## Non-goals

- Flutter asset registration or UI integration;
- rank logic, RR calculations, persistence, or finalization;
- login, authentication, profiles, routines, workouts, or media features;
- Supabase, Storage, Vercel, CI, or external infrastructure;
- redesigning `rank-v6` names, order, or thresholds;
- embedding rank names, letters, or numerals into the images;
- proprietary game logos or unclear-license artwork.

## Protected boundaries

- Preserve `rank-v6` exactly.
- Preserve Adonis at 5,500 RR.
- Do not claim Phase 1 has started.
- Do not place secrets, credentials, personal data, or private media in Git.
- Do not use dumbbells, barbells, weight plates, or other gym-equipment symbols.
- Do not create a competing rank configuration.

## Acceptance criteria

1. Exactly 20 expected PNGs exist.
2. Every PNG is 256 × 256 RGBA with a transparent background.
3. Every PNG has non-empty visible bounds and no clipped artwork.
4. Filenames map exactly to the accepted rank order.
5. Every family progresses visibly from I to III.
6. Elite through Adonis are visibly distinct and increasingly prestigious.
7. No image contains embedded rank text or gym-equipment imagery.
8. All artwork derives from the documented CC0 source family.
9. Manifest digests match the committed PNG bytes.
10. Contact-sheet review shows coherent alignment, scale, and palette hierarchy.
11. Documentation accurately states that assets exist but are not integrated into an application.
12. The final diff contains no unrelated changes.

## Required verification

- expected filename and file-count assertion;
- PNG signature and Pillow decode;
- 256 × 256 dimension assertion;
- RGBA/transparency assertion;
- non-empty alpha-bounds assertion;
- SHA-256 manifest assertion;
- visual contact-sheet review;
- JSON parse and schema-field checks;
- `git diff --check` equivalent through generated-content validation;
- branch comparison against `main`.

## Completion result

- Twenty ordered transparent PNGs are committed under `assets/ranks/`.
- Each asset is 256 × 256 RGBA and is mapped in `manifest.json`.
- Source provenance and CC0 licensing are recorded in `LICENSE.md`.
- `CONTACT_SHEET.md` provides repository visual review.
- `tools/generate_rank_assets.py` reproducibly fetches fixed source files, generates all assets, writes metadata, and verifies filename, PNG, dimension, alpha, visible-bounds, and SHA-256 requirements.
- The Flutter applications do not yet consume these assets.

## Required completion report

```text
Verdict: COMPLETE | PARTIAL | FAIL
Task ID: TASK-ASSET-001
Branch:
Commit:
Files changed:
Assets added:
Source and licence:
Transformations:
Checks run:
Results:
Documentation updated:
Explicitly not implemented:
Risks or blockers:
Exact next action:
```
