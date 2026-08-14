# Stone Set Task Packets

This directory stores bounded execution packets approved for Codex or another implementation agent.

A task packet is authoritative only when its status/repository state match current facts, prerequisites are satisfied, and it does not conflict with accepted ADRs/product specifications. Agents must inspect the repository before implementation.

## Current packets

| Task | Status | Purpose |
|---|---|---|
| `TASK-IMP-001.md` | Complete and merged | Flutter/Dart workspace, local Supabase, quality and CI foundation |
| `TASK-IMP-002A.md` | Complete and merged | Private identity, login, sessions, profiles, ownership and operator tooling |
| `TASK-IMP-002B.md` | Complete and merged | Shared UI plus fixture-only Android shell, Home and rank hero |
| `TASK-IMP-002C.md` | Complete and merged | Fixture-only responsive dashboard shell, Overview and productivity primitives |
| `TASK-IMP-003A.md` | Complete and merged through PR #14 | Exercise library, structured guidance, immutable publication and browser recovery |
| `TASK-IMP-003B.md` | Complete and merged | Private exercise media and YouTube |
| `TASK-IMP-003C.md` | Complete and merged; review lifecycle later retired | Routine authoring and direct owner publication |
| `TASK-IMP-004.md` | Complete and merged | Weekly plans, swaps and free-swap credits |
| `TASK-IMP-005A.md` | Complete and merged | Workout logger, SQLite autosave and offline sync |
| `TASK-IMP-005B.md` | Complete and merged | Workout guidance and media playback |
| `TASK-IMP-006.md` | Complete and merged | Authoritative RR, XP, rank, wallet and Progress |
| `TASK-IMP-007.md` | Complete and merged | Progression, substitutions, protection and corrections |
| `TASK-IMP-008.md` | Complete and merged | Minimal private release |
| `TASK-IMP-009.md` | Complete and merged through PR #31 | Android visual system and motion modernization |
| `TASK-IMP-010.md` | Complete; code merged through PR #34 and production migration verified | Authoritative base consistency multiplier and Home fixture-leak correction |
| `TASK-IMP-011.md` | Partial; engineering/deployment complete, approved content pending | Exercise media authoring completion and approved production population |
| `TASK-IMP-012.md` | Partial; distribution complete, backup/phone confirmation pending | Permanent Android signing and private automatic Firebase distribution |
| `TASK-IMP-013A.md` | Merged; physical device acceptance residual | Offline-first cached mobile shell, synchronization and Home rank refresh |
| `TASK-IMP-014.md` | Partial only at owner content-publication boundary; engineering/deployment complete | Guidance/media publication feedback and latest-published activation for newly started workouts |
| `TASK-IMP-015.md` | Complete and deployed through PR #56 | Week-day detail browsing, deliberate long-press swaps, and reliable workout start |
| `TASK-IMP-016.md` | Complete and merged through PR #54 | Vercel build-rate-limit repair with globstar feature-branch suppression and main-only production builds |

## TASK-IMP-015 deployed state

```text
PR #56                  MERGED
runtime main            d7efd7fb35e25dac27094e2e8fb6be41f751ce1d
Foundation CI #414      31782008565 — PASS
production Supabase     20260814080728_training_week_item_detail
private Android #73     31782531713 — PASS
release                 0.1.0 (1000073), Firebase 3evhve7djjghg
```

The Week screen now uses tap for read-only day detail and long press for swap selection. The new owner-scoped Week-detail RPC is live in production. Safe local workout switching preserves pending edits and clears only synchronized stale local state before the existing authoritative online start.

## TASK-IMP-014 deployed state

Implementation PR #48 merged at:

```text
7c805c085761605363e5d266940449a0c8400647
Foundation CI #390 / 31630620692 — PASS
```

Production Supabase records:

```text
20260812190919_latest_published_guidance_for_new_workouts
```

Vercel production deployment `dpl_ApzpAb69cf6pe5BuL3jY5q6jYmAp` is `READY`, targets production, aliases `stone-set.vercel.app`, and was built from that exact main SHA.

Remaining TASK-IMP-014 action is owner-controlled: validate the affected YouTube preview(s) through genuine playback and click Publish. Engineering must not fabricate preview evidence or publish owner content automatically.

After publication, the next newly started workout receives the newest finalized guidance/media bundle; an already-started workout remains pinned to its immutable session snapshot. No Android update is required for TASK-IMP-014.

## TASK-IMP-016 deployed state

Final deployment policy is governed by ADR-0014:

```text
feature/PR branches: ** => deployment disabled
main: deployment enabled
unaffected main changes: ignore-build.sh may skip the Flutter Web build
```

Final correction PR #54 merged at:

```text
d11c3bde5fd8612e75363202e0ddadb210dc0b35
Foundation CI #403 / 31672810958 — PASS
```

Vercel production deployment `dpl_EFKM4aZXk1zzQ7d2peiJKWPRePFd` is `READY`, targets production, and aliases `stone-set.vercel.app`. The public production URL returned HTTP 200 after activation.

## Independent residual boundaries

- `TASK-IMP-011`: only explicitly approved exercise image/YouTube content remains; never fabricate or scrape selections.
- `TASK-IMP-012`: independent signing-key backup and phone confirmation remain external gates.
- `TASK-IMP-013A`: real-device airplane-mode acceptance remains external.
- `TASK-IMP-014`: owner YouTube preview/publish remains external.
- ADR-0003 continues to require online authoritative workout start; offline-created sessions remain a separate future decision.

The original independent-review portion of TASK-IMP-003C is superseded. Current routine publication remains direct by the owner after validation.
