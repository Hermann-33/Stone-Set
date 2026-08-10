# TASK-PD-020 — Bound the Android visual and motion modernization

Status: `IN REVIEW — DOCUMENTATION ONLY`
Date: 2026-08-11
Branch: `codex/task-pd-020-plan-mobile-ui-polish`

## Objective

Audit the accepted Android presentation requirements against the current implementation and create
a bounded implementation packet for a coherent Stone Set mobile visual, component and motion
upgrade. This planning task does not authorize or perform runtime work.

## Verified starting state

```text
main                         704922c — Remove routine review gate and publish directly
working tree                 clean before planning edits
implementation              complete through TASK-IMP-008
private release              deployed/configured as recorded by ACTIVE_CONTEXT.md
routine publication         direct owner validation and publication
TASK-IMP-009                 absent
ROADMAP authority            explicitly says no TASK-IMP-009 is planned
approved UI-polish packet    absent
```

`ACTIVE_CONTEXT.md` is higher current-state authority than stale lower documents that still
describe independent routine review or pre-release phase boundaries. No retired reviewer queue,
reviewer capability, approval/rejection step or second-user publication dependency may return.

## Audit result

The current mobile application already has the protected four-destination shell, authenticated
session routing, Home/rank presentation, weekly schedule and swaps, active workout logger,
guidance, Progress and an honest Profile placeholder. The shared UI package provides semantic
colors, basic typography, cards, status surfaces, motion durations and the accepted 20-rank asset
mapping.

The most material presentation gaps are:

- shared foundation tokens still identify themselves as temporary rather than a complete design
  system;
- typography exposes only a subset of the accepted semantic roles;
- most component themes and feature surfaces retain stock Material presentation;
- surface depth, shape hierarchy, focus treatment and state presentation are inconsistent;
- Week, workout and Progress use feature-local raw cards/chips/fields instead of one coherent
  component language;
- Home rank motion covers a basic initial/progress transition but not the full accepted coordinated
  initial, RR-change, rank-up and rank-down presentation contract;
- loading, empty, error, pending, stale and synchronization states need a consistent visual system;
- visually significant coverage is concentrated on Home/rank rather than the complete production
  mobile surface.

The audit also found two boundaries that generic design guidance must not override:

1. Profile currently exposes verified identity context but no connected settings product. A polish
   task must not invent preference persistence or claim unavailable settings exist.
2. The implemented workout route is the active logger. A visual task must not create a new product
   workflow merely because aspirational documentation describes a separate overview.

## Planning decision

`docs/tasks/TASK-IMP-009.md` is created as a draft, non-executable packet. It defines a
design-system-first Android presentation upgrade with exact product, authority, accessibility,
motion, performance, verification and Git boundaries.

No new ADR is required for the drafted work because it remains inside accepted Flutter,
Riverpod/go_router, mobile information architecture, presentation and client/server boundaries.
An ADR is required before implementation if review introduces a durable architecture, public
contract, persistence, authorization, external-service or deployment change.

## Governance gate

Runtime implementation is blocked until repository authority is changed in a later explicit
approval step that:

1. reviews and accepts `TASK-IMP-009` without unresolved product or architecture ambiguity;
2. changes its status to `APPROVED — NOT EXECUTED`;
3. updates `ACTIVE_CONTEXT.md` and `ROADMAP.md` so they authorize the packet and no longer state
   that no `TASK-IMP-009` is planned;
4. identifies `codex/task-imp-009-mobile-ui-polish` as the executable branch;
5. preserves the direct-owner routine-publication override and every server-authority boundary.

Until all five conditions are recorded in the repository, no file under `apps/mobile/` or
`packages/ui/` may be changed for this modernization.

## Files changed by this planning task

- `docs/tasks/TASK-PD-020.md`
- `docs/tasks/TASK-IMP-009.md`
- `docs/tasks/README.md`
- append-only entry in `docs/context/AUDIT_LOG_CONTINUED_3.md`

## Explicitly unchanged

- application, package and generated source;
- dependencies and lockfiles;
- Supabase, SQLite, Auth, Storage and remote infrastructure;
- Android build configuration and release artifacts;
- routes, workflows, navigation destinations and product behavior;
- accepted ADRs and product specifications;
- historical audit records.

## Planning verification

- task-packet required-section validation;
- repository/document validation where available;
- relative-link validation;
- `git diff --check`;
- documentation-only path review;
- secret and personal-data scan;
- append-only audit validation;
- complete diff and clean-tree review.

Android builds, widget suites, goldens and API 24 profiling are intentionally deferred because this
planning diff contains Markdown only. They are mandatory gates in the drafted implementation
packet.

## Exact next action

```text
Review and approve TASK-IMP-009 through repository authority.
packet: docs/tasks/TASK-IMP-009.md
future implementation branch: codex/task-imp-009-mobile-ui-polish
```
