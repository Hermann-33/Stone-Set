# Stone Set

Stone Set is a private muscle-growth training system currently in product, architecture, and implementation planning.

The repository is authoritative for product decisions, architecture, implementation state, verification evidence, and handoff context. Chat history is not authoritative.

## Current state

- Initial users: two administratively provisioned accounts
- Public registration: excluded from MVP
- Accepted workout baseline: limited-equipment five-session hypertrophy routine with a strict 60-minute session cap
- Active rank configuration: `rank-v5`
- Active scheduling configuration: `schedule-v2`
- Rank ladder: 20 ranks from Bronze I to Adonis
- Adonis threshold: `5,500 RR`
- Rank pacing target: approximately ten months under the accepted synthetic decent-consistency profile
- Weekly swap limit: two confirmed swaps
- Free-swap system: two non-expiring, uncapped credits monthly; one credit waives one swap's `5 RR` cost
- Mobile client architecture: Flutter
- Web dashboard architecture: Flutter Web
- Backend and authentication architecture: Supabase Auth and Postgres with RLS
- Password storage: Supabase Auth only; no application-table passwords
- Implementation: not started
- Active phase: Phase 0 planning

## Current planning work

The repository now contains:

- a proposed end-to-end application workflow;
- a documentation-only phased implementation plan;
- accepted Flutter and Supabase architecture ADRs;
- a proposed multi-user routine and normalized daily-RR model.

The proposed reward model targets equal maximum weekly RR opportunity for four-, five-, and six-day routines while giving rest items less RR than workout items.

It is not active yet. `rank-v5` and `schedule-v2` remain authoritative until the proposal is audited and explicitly accepted as `rank-v6` and `schedule-v3`.

## Start here

1. Use [`docs/context/NEW_CHAT_BOOTSTRAP.md`](docs/context/NEW_CHAT_BOOTSTRAP.md) for a new conversation.
2. Read [`AGENTS.md`](AGENTS.md).
3. Read the mandatory files under [`docs/context/`](docs/context/).
4. Read the accepted product baselines:
   - [`docs/product/HYPERTROPHY_ROUTINE.md`](docs/product/HYPERTROPHY_ROUTINE.md)
   - [`docs/product/RANK_SYSTEM.md`](docs/product/RANK_SYSTEM.md)
   - [`docs/product/WEEKLY_SCHEDULING.md`](docs/product/WEEKLY_SCHEDULING.md)
5. Read the current planning documents:
   - [`docs/product/APPLICATION_WORKFLOW.md`](docs/product/APPLICATION_WORKFLOW.md)
   - [`docs/product/MULTI_USER_ROUTINE_AND_DAILY_RR_PROPOSAL.md`](docs/product/MULTI_USER_ROUTINE_AND_DAILY_RR_PROPOSAL.md)
   - [`docs/context/IMPLEMENTATION_PLAN.md`](docs/context/IMPLEMENTATION_PLAN.md)
6. Read accepted ADRs under [`docs/decisions/`](docs/decisions/).

## Implementation gate

Do not scaffold Flutter, create a Supabase project, add schema migrations, provision credentials, or claim runtime behavior until:

1. the multi-user reward and scheduling proposal is accepted or replaced;
2. the application workflow is accepted;
3. remaining offline, release, hosting, backup, and operational constraints are decided;
4. the first bounded implementation task is approved.
