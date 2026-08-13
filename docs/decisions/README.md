# Stone Set Architecture Decision Records

This directory stores durable accepted decisions. It must not be used as a dumping ground for brainstorming.

## Status values

- `Proposed`
- `Accepted`
- `Superseded`
- `Rejected`
- `Deprecated`

## Naming

```text
ADR-0001-short-decision-title.md
ADR-0002-short-decision-title.md
```

Use sequential numbers. Never reuse a number or rewrite accepted history to make a later decision look original.

## ADR trigger

Create an ADR before durable changes to architecture, public contracts, persistence ownership, authentication, authorization, material security or privacy controls, external services, deployment, or repository governance.

## Current accepted decisions

| ADR | Decision | Status |
|---|---|---|
| `ADR-0001-flutter-client-platforms.md` | Separate Flutter mobile and Flutter Web clients with shared Dart packages | Accepted |
| `ADR-0002-supabase-backend-auth-and-persistence.md` | Hosted Supabase Auth and Postgres with RLS and no application-table password storage | Accepted |
| `ADR-0003-local-workout-drafts-and-online-finalization.md` | SQLite local workout drafts, online session start, outbox synchronization, and server-authoritative finalization | Accepted |
| `ADR-0004-android-first-and-vercel-dashboard-hosting.md` | Android-first mobile release and Vercel-hosted static Flutter Web dashboard | Accepted |
| `ADR-0005-supabase-production-operations-and-recovery.md` | Separate environments, Pro daily backups, encrypted logical exports, MFA, least privilege, and restore drills | Accepted |
| `ADR-0006-exercise-media-storage-and-youtube-embedding.md` | Private Supabase Storage images, versioned exercise guidance, and policy-compliant YouTube embedding | Accepted |
| `ADR-0007-path-sensitive-ci-gates.md` | Fail-closed path-sensitive CI with API 24 reserved for performance-relevant mobile changes | Accepted |
| `ADR-0008-guidance-revision-draft-materialization.md` | Atomic owner-scoped editable draft creation from immutable guidance/media revisions | Accepted |
| `ADR-0009-private-android-app-distribution.md` | Permanent Android signing and private Firebase App Distribution | Accepted |
| `ADR-0010-offline-first-mobile-cache-and-synchronization.md` | Same-owner cached authenticated shell, owner-scoped SQLite read snapshots, coherent mobile synchronization, and live Home refresh | Accepted |
| `ADR-0011-latest-published-guidance-for-new-workouts.md` | Resolve the latest finalized owner guidance/media bundle when a new workout snapshot is created while preserving started-workout immutability | Accepted |
| `ADR-0013-ci-controlled-vercel-production-deployment.md` | Token-authenticated post-CI prebuilt Vercel deployment attempt | Superseded by ADR-0014 |
| `ADR-0014-main-only-vercel-git-deployment.md` | Suppress all feature/PR Vercel preview builds with a globstar rule while retaining the existing main production Git deployment | Accepted |

ADR-0006 extends the accepted Supabase architecture to include Storage for exercise images. It does not modify ADR-0002's Auth, Postgres, RLS, credential, or server-authority decisions. ADR-0007 changes only which verification lanes a diff activates; it does not weaken any gate or threshold.
ADR-0008 completes the existing immutable guidance/media authoring lifecycle; it introduces no new
media store, sharing model or publication authority.
TASK-IMP-011 implements ADR-0008 through merged PR #38 and the verified production migration. No
new media store, sharing model or publication authority was introduced.
ADR-0009 supersedes only ADR-0004's temporary debug-signed/manual Android delivery boundary.
ADR-0010 extends the existing SQLite/mobile-session architecture to cached private read snapshots and a
central synchronization boundary after one successful online bootstrap. It deliberately preserves
ADR-0003's online workout-start rule; offline-created workout sessions require a later superseding ADR.
ADR-0011 preserves immutable routine/materialization history but moves content-only guidance/media
activation to creation of a new workout-session exercise snapshot. Existing started sessions remain
pinned to their original revision, and YouTube preview evidence remains mandatory for new video
publication.
ADR-0013 was a stronger exact-main post-CI deployment design but required a `VERCEL_TOKEN` that the
repository does not have; its first production run failed closed before deployment. ADR-0014 supersedes
that attempt by using the existing Vercel Git authorization, minimatch globstar suppression for every
feature/PR branch, `main` as the only enabled Git build branch, and the existing ignored-build guard for
unaffected main commits.

These ADRs authorize architecture and bounded implementation planning. External project creation, credentials, production deployment, and product feature implementation require an explicit approved task packet.

## Template

```markdown
# ADR-XXXX: Decision title

## Status

Proposed | Accepted | Superseded | Rejected | Deprecated

- Date: YYYY-MM-DD
- Type:
- Supersedes:
- Preserves:

## Context

## Decision criteria

## Options considered

## Decision

## Consequences

## Security, privacy, data, and operational impact

## Scope boundaries

## Rollback or supersession rule

## Activation evidence
```
