# Stone Set Audit Log — Continued

This volume preserves `docs/context/AUDIT_LOG.md` unchanged and continues material audit history from `TASK-PD-008` onward.

## 2026-08-04 — TASK-PD-008 — Multi-user normalization activation audit

### Scope

- accept or reject the proposed daily normalized rank economy;
- activate canonical rank, scheduling, and workflow specifications if accepted;
- preserve Adonis, multipliers, swaps, free credits, history, and server authority;
- synchronize current context without implementing code.

### Accepted result

- `rank-v6` and `schedule-v3` activated;
- 4–6 workout days and 7 plan items supported;
- fixed weekly RR pools and 4:1 workout/rest allocation accepted;
- 95 RR weekly missed-workout penalty pool accepted;
- maximum two rewarded PRs per week accepted;
- failed-week threshold below 60% workout completion accepted;
- application workflow promoted to accepted;
- no production migration required because no runtime or history existed.

### Verdict

`COMPLETE`

---

## 2026-08-04 — TASK-PL-002 — Implementation-constraint closure audit

### Accepted result

- `routine-validator-v1` and independent reviewed publication;
- SQLite local drafts through `sqflite`;
- online session start, offline continuation, pending online finalization, and 24-hour grace;
- Android API 24+ initial release; iOS deferred;
- Vercel static dashboard hosting;
- local/staging/production Supabase separation;
- Pro daily backup retention, encrypted independent exports, RPO 24 hours, RTO 4 hours;
- two Owner accounts, MFA enforcement, least privilege, and quarterly restore tests;
- approved `TASK-IMP-001` packet.

### Verdict

`COMPLETE`

---

## 2026-08-04 — TASK-PD-009 — Exercise guidance and media audit

### Accepted result

- dashboard-managed workout explanations and exercise guidance;
- user-owned immutable guidance revisions;
- private `exercise-media` Supabase Storage bucket;
- image validation, metadata stripping, limits, alt text, and immutable object identity;
- one optional YouTube video per guidance revision;
- official YouTube IFrame playback with no autoplay, download, cache, background play, or reward;
- active-session offline text and prefetched image behavior;
- separate Storage-object backup and restore reconciliation;
- Phase 3 and Phase 5 implementation sequence expanded without changing foundation scope.

### Verdict

`COMPLETE`

---

## 2026-08-04 — TASK-PD-010 — Mobile and dashboard login-page audit

### Scope

- make login pages explicit for both clients;
- define shared account, provisioning, credential, session, route-guard, logout, and recovery behavior;
- preserve Supabase Auth ownership and the approved foundation boundary;
- synchronize planning documents without implementation.

### Findings

1. Supabase password sign-in requires an email or phone identity, while Stone Set wants a username-oriented interface.
2. A deterministic operator-provisioned internal email alias preserves the username UX without adding a public username resolver.
3. Both clients need explicit session restoration and route guards to avoid private-content flashes.
4. Generic errors are required to limit account enumeration.
5. A forced first-login password change is appropriate for operator-created temporary credentials.
6. Mobile logout and involuntary expiry must preserve unsynchronized workout drafts safely.
7. Public self-service recovery is unnecessary for two privately provisioned users and would require a separate contact-email workflow.

### Accepted decisions

- Android native login screen and responsive web `/login` page;
- same provisioned username/password account on both clients;
- internal Supabase email alias derived from normalized username and configured auth domain;
- no signup, social login, anonymous login, magic link, or public recovery;
- first-login password change;
- persistent sessions and protected routes;
- generic login and disabled-profile failures;
- Supabase rate limits, with CAPTCHA deferred to release hardening;
- independent mobile and dashboard sessions;
- dashboard logout cache cleanup and back-navigation privacy;
- mobile sync/stay/discard logout flow;
- same-account quarantine for drafts after involuntary session loss;
- operator-managed temporary-password recovery and optional session revocation;
- Phase 2 renamed and expanded to identity, login, sessions, profiles, and ownership.

### Verification

- both client surfaces are explicitly covered;
- passwords remain exclusively in Supabase Auth;
- no public username directory is introduced;
- no service-role key is required in either client;
- login does not alter rank, routine, media, or scheduling rules;
- `TASK-IMP-001` remains foundation-only;
- no code, project, account, credential, schema, deployment, or runtime was created.

### Risks

- auth alias configuration must remain consistent across provisioning and clients;
- operator-managed recovery creates an availability dependency;
- persistent dashboard sessions require careful shared-device logout behavior;
- draft quarantine and same-account recovery require strong tests.

### Phase result

```text
Phase 0 — COMPLETE
Phase 1 — READY, NOT STARTED
```

### Verdict

`COMPLETE`