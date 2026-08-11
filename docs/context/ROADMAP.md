# Stone Set Roadmap

Updated: 2026-08-11

Stone Set is a private two-user MVP. Product implementation and the minimal private release through
`TASK-IMP-008` are complete.

## Completed product phases

```text
Phase 0   Product/architecture planning                     COMPLETE
Phase 1   TASK-IMP-001 Foundation                           COMPLETE
Phase 2A  TASK-IMP-002A Identity/sessions                   COMPLETE
Phase 2B  TASK-IMP-002B Shared UI + Android shell/Home      COMPLETE
Phase 2C  TASK-IMP-002C Dashboard shell/Overview            COMPLETE
Phase 3A  TASK-IMP-003A Exercise library/guidance           COMPLETE
Phase 3B  TASK-IMP-003B Private media/YouTube               COMPLETE
Phase 3C  TASK-IMP-003C Routine/review/publication          COMPLETE
Phase 4   TASK-IMP-004 Weekly plans/free/paid swaps         COMPLETE
Phase 5A  TASK-IMP-005A Workout logger/SQLite/sync          COMPLETE
Phase 5B  TASK-IMP-005B Workout guidance/media playback     COMPLETE + MERGED
Phase 6   TASK-IMP-006 RR/XP/rank/wallet/Progress           COMPLETE
Phase 7   TASK-IMP-007 progression/protection/corrections   COMPLETE
```

## Final original phase — TASK-IMP-008

```text
Status: COMPLETE — MERGED THROUGH PR #25
Branch: codex/task-imp-008-minimal-release
Mode: FAST TWO-USER PRIVATE RELEASE
```

008 contains only what is required to run the finished product:

- one hosted Supabase backend with the accepted schema;
- private media Storage bucket;
- production bootstrap configuration;
- public Flutter production defines;
- private Android APK build path;
- Flutter Web dashboard build/deploy path;
- exactly two operator-provisioned users;
- short smoke/rollback/backup instructions.

Deliberately excluded:

- staging;
- Play Store/AAB;
- custom release signing infrastructure;
- public signup/email recovery;
- enterprise observability;
- security certification programmes;
- multi-region/HA;
- formal RPO/RTO or restore drills;
- new feature development.

## Post-release presentation modernization — TASK-IMP-009

```text
Status: COMPLETE AND MERGED
Branch: codex/task-imp-009-mobile-ui-polish
Packet: docs/tasks/TASK-IMP-009.md
Pull request: #31
Merge commit: e59303d5acd4dbfe6706822b100913c531dc9297
```

TASK-IMP-009 is a deliberate post-release Flutter Android presentation, accessibility and
event-driven-motion modernization. It is not part of the original implementation phase sequence
and does not reopen completed product, backend, persistence or release behavior.

Its completion gate passed at final head `f3f41bd95294e73b00c10f42f24ea43c4571411c`:
coherent shared visual system and mobile polish, protected product behavior, reduced motion and
accessibility, reviewed goldens, Android release artifacts, unchanged API 24 thresholds,
documentation, Git and final-head CI.

## Post-release multiplier correction — TASK-IMP-010

```text
Status: COMPLETE
Branch: codex/task-imp-010-consistency-multiplier
Packet: docs/tasks/TASK-IMP-010.md
```

PR #34 merged the verified code at `12eb3010064a7e17774c5c1ce564badce8b68d6a`; final-head CI and
private-release builds pass. The committed migration was applied through Supabase migration history
to production project `pjltldrernuvrjsnmcqg` and verified against the existing account and progress
payload at authoritative base `1.00×`. The code replaces the authenticated Home fixture multiplier,
preserves the intentional fixture preview and introduces no client write authority. Full perfect-week
streak evaluation is deferred until authoritative weekly finalization/protection evidence exists.

No weekly/swap work is authorized. TASK-IMP-011 remains non-executable until its own packet is
created, reviewed and approved.
