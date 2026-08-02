# Stone Set Active Context

Updated: 2026-08-03

## Current state

Stone Set is a private personal muscle-growth training application in product discovery. The repository contains no application code, runtime, database, external integration, deployment, or accepted technical stack.

The first product-domain baseline is now accepted: a limited-equipment hypertrophy routine with a hard 60-minute session cap.

## Active phase

`Phase 0 — Product discovery and governance`

The user's phrase "phase one" referred to beginning the first product-definition workstream. Repository Phase 1 remains the later technical foundation phase and is still blocked by incomplete discovery.

## Latest completed work

`TASK-PD-001` reviewed the supplied workout routine against current primary resistance-training research, corrected the routine for the 60-minute constraint, and documented the accepted baseline in `docs/product/HYPERTROPHY_ROUTINE.md`.

## Verified product facts

- Repository: `Hermann-33/Stone-Set`
- Initial user: repository owner
- Product direction: personal muscle-growth training application
- Initial gym boundary: Smith machine, dumbbells/bench, cable station, pulldown, seated row, leg extension, leg curl, and hanging-knee-raise setup
- Weekly structure: five resistance-training sessions and two non-lifting days
- Maximum session duration: 60 minutes including warm-up
- Program objective: maximize practical hypertrophy while preserving progression quality and recovery
- Progression: repetitions first, then load
- Effort: compounds normally 1-2 RIR; isolations normally 0-2 RIR
- Technology stack: not selected
- Implementation: not started

## Active task

No implementation task is active.

The next work remains product discovery, not code generation.

## Current blockers

Implementation cannot be scoped responsibly until the workout execution and logging workflow is defined, including timers, set entry, progression recommendations, substitutions, missed sessions, equipment conflicts, and user overrides.

## Exact next action

Define the first complete app workflow from opening the app before a session through recording the final set and generating the next-session prescription.

## Do-not-touch boundaries

- Do not scaffold application code.
- Do not select a stack.
- Do not add authentication, persistence, external services, analytics, telemetry, or deployment.
- Do not expand into nutrition or sleep planning.
- Do not create speculative ADRs.
- Do not treat research-derived guidance as medical diagnosis.
- Do not change the accepted workout baseline without recording the reason and affected evidence.

## Relevant decisions

No architecture ADR has been accepted yet.

The accepted product-domain baseline is `docs/product/HYPERTROPHY_ROUTINE.md`.