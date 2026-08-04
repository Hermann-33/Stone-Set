# Stone Set Reward-Eligible Routine Rules

Updated: 2026-08-04
Status: `ACCEPTED PRODUCT BASELINE`
Task: `TASK-PL-002`

## Purpose

This document defines when a user-created hypertrophy routine may participate in `rank-v6` rewards.

The normalized weekly RR economy assumes that every reward-eligible routine represents meaningful, structured resistance training. A user must not obtain the full weekly RR opportunity from an empty, token, or mechanically trivial routine.

These rules are product-integrity controls, not medical advice and not a claim that one exact routine is optimal for every person.

## Evidence boundary

The 2026 ACSM position stand reports that resistance training should be performed at least twice weekly with all major muscle groups engaged, and that hypertrophy is enhanced by higher weekly volume, including approximately ten or more sets per muscle group. Frequency itself is less important for hypertrophy when weekly volume is equated.

Stone Set uses those findings as reviewer guidance rather than pretending that a simple automatic rule can determine whether every individualized routine is physiologically ideal.

Primary references:

- Currier BS et al. *Resistance Training Prescription for Muscle Function, Hypertrophy, and Physical Performance in Healthy Adults*. Med Sci Sports Exerc. 2026;58(4):851-872. PMID: 41843416.
- Schoenfeld BJ et al. *Dose-response relationship between weekly resistance training volume and increases in muscle mass*. J Sports Sci. 2017. PMID: 27433992.
- Schoenfeld BJ et al. *How many times per week should a muscle be trained to maximize muscle hypertrophy?* J Sports Sci. 2019. PMID: 30558493.

## Routine lifecycle

```text
draft
  -> submitted_for_review
  -> approved
  -> published
  -> archived
```

Rules:

1. Users edit only their own drafts.
2. A draft is never reward eligible.
3. Submission runs the complete hard validator.
4. A different authorized reviewer must approve the version.
5. Self-approval is prohibited.
6. Reviewers may approve or reject; they may not silently edit another user's draft.
7. Publication creates an immutable version and schedules future-week activation.
8. The last approved published version remains active while a replacement is pending or rejected.
9. Emergency operator override is permitted only through controlled administrative tooling with a required reason and immutable audit event.
10. A routine version cannot receive normalized RR before approval and publication.

For the initial two-user product, each account may review the other account's submitted routine. Authorization is stored in protected server-controlled role data, never user-editable profile metadata.

## Hard structural validator

A reward-eligible routine version must satisfy every rule below.

### Weekly structure

```text
exact day slots = 7
workout days = 4 through 6
programmed rest days = 1 through 3
weekly working sets = 32 through 100
```

- Every weekday appears exactly once.
- Every day contains exactly one workout or rest item.
- No duplicate workout-day, exercise-order, or set-order positions are permitted.
- Unscheduled extra training remains outside the reward-bearing routine.

### Workout structure

Each workout item must contain:

```text
exercise prescriptions = 3 through 10
working sets = 8 through 20
priority exercises = at least 1
estimated duration = 20 through 60 minutes, including warm-up
```

Each exercise prescription must contain:

```text
working sets per exercise = 1 through 6
rep-range lower bound = 5 through 30
rep-range upper bound = lower bound through 30
RIR target = 0 through 5
prescribed rest = 30 through 300 seconds
```

Bodyweight movements may omit an external load value only when the exercise variant explicitly identifies bodyweight loading.

### Duration estimator

The publication validator uses a deterministic estimate:

```text
warm-up allowance = 480 seconds
working-set execution allowance = 45 seconds per set
standalone exercise transition = 45 seconds
superset-group transition = 60 seconds
standalone rest = prescribed rest between working sets
superset rest = prescribed rest once per completed round
```

```text
estimatedSessionSeconds =
  warmUpAllowance
  + workingSetExecutionTime
  + interSetOrRoundRestTime
  + exerciseOrGroupTransitionTime
```

A routine cannot be approved when the estimate is below 20 minutes or above the accepted 60-minute hard cap.

## Human review checklist

Passing the hard validator is necessary but not sufficient.

The reviewer confirms that:

1. the routine has a coherent hypertrophy purpose;
2. exercise selection is compatible with the user's declared equipment;
3. priority exercises and weekly volume are not obviously token or fabricated work;
4. intended major muscle groups receive meaningful weekly exposure;
5. hypertrophy-priority muscle groups generally approach at least ten weekly working sets unless an explicit reason is recorded;
6. training frequency and recovery distribution are plausible for the routine;
7. the routine contains progression targets, repetition ranges, RIR, and rest prescriptions;
8. the duration estimate is credible and the session can remain within 60 minutes;
9. duplicate variants or cosmetic exercise renaming are not used to inflate apparent routine complexity;
10. the routine does not rely on medical diagnosis or ignore a declared protected limitation.

A reviewer rejection must use at least one structured reason and may include a note.

## Material-change rule

Every new published routine version requires review. MVP does not attempt to classify some reward-bearing changes as automatically safe.

This deliberately conservative rule is acceptable for two initial users and prevents loopholes involving many small edits.

Non-reward text such as draft notes may be edited without affecting the published version. Any change to a day, exercise, order, set, repetition range, RIR, rest value, priority, equipment variant, or progression prescription requires a new reviewed version.

## Anti-gaming rules

1. The client cannot set `rewardEligible`, `approvedBy`, or `approvedAt`.
2. Authors cannot approve their own versions.
3. The reviewer cannot rewrite the submitted prescription during approval.
4. Hard validation runs server-side again at approval and publication.
5. An approved version's hash is stored; publication fails if the content changed after approval.
6. Published versions are immutable.
7. Historical weeks retain the exact version and validation result used at materialization.
8. Exercise aliases resolve to canonical exercise variants for duplicate detection.
9. Extra workouts and extra sets earn no RR or XP.
10. Shortening or deleting future routines does not alter already materialized weeks.
11. A rejected or expired submission leaves the last approved routine active.
12. Manual override requires a separate privileged operation and audit reason.

## Required records

```text
routineReview = {
  routineVersionId,
  authorUserId,
  reviewerUserId,
  submittedContentHash,
  hardValidationResult,
  reviewStatus: "approved" | "rejected",
  rejectionReasons[],
  reviewerNote,
  reviewedAt,
  overrideActorId,
  overrideReason
}
```

```text
routineEligibilitySnapshot = {
  routineVersionId,
  workoutDayCount,
  restDayCount,
  weeklyWorkingSets,
  estimatedSessionSecondsByDay,
  validatorVersion,
  approvedReviewId,
  contentHash,
  rewardEligible,
  activatedAt
}
```

## Required validation fixtures

The implementation must test at least:

- valid 4-, 5-, and 6-workout-day routines;
- only 3 workout days;
- 7 workout days and no rest day;
- workout with fewer than 3 exercises;
- workout with fewer than 8 working sets;
- workout exceeding 20 working sets;
- weekly total below 32 or above 100 sets;
- estimated workout below 20 or above 60 minutes;
- invalid rep, RIR, rest, or ordering values;
- duplicate canonical exercise aliases used as fake complexity;
- self-approval attempt;
- approval after submitted content changes;
- publication without approval;
- rejected replacement preserving the current approved routine;
- emergency override with and without an audit reason.

## Versioning

The initial validator configuration is:

```text
routine-validator-v1
```

Future changes require a new validator version. Historical routine versions and materialized weeks must retain the validator version and stored eligibility result used at the time.