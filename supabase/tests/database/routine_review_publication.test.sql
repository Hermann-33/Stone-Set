begin;
select no_plan();

create temporary table routine_test_state (
  key text primary key,
  value jsonb not null
) on commit drop;
grant select, insert, update on table routine_test_state to authenticated;

insert into auth.users (
  instance_id, id, aud, role, email, email_confirmed_at, created_at, updated_at
) values
  ('00000000-0000-0000-0000-000000000000', 'c1000000-0000-4000-8000-000000000001',
   'authenticated', 'authenticated', 'routine-alpha@local.stone-set.invalid',
   clock_timestamp(), clock_timestamp(), clock_timestamp()),
  ('00000000-0000-0000-0000-000000000000', 'c1000000-0000-4000-8000-000000000002',
   'authenticated', 'authenticated', 'routine-bravo@local.stone-set.invalid',
   clock_timestamp(), clock_timestamp(), clock_timestamp());

insert into public.profiles (
  id, normalized_username, public_display_name, active, must_change_password, reward_timezone
) values
  ('c1000000-0000-4000-8000-000000000001', 'routine_alpha', 'Routine Alpha', true, false, 'UTC'),
  ('c1000000-0000-4000-8000-000000000002', 'routine_bravo', 'Routine Bravo', true, false, 'UTC');

insert into public.account_capabilities (user_id, capability_code, is_enabled) values
  ('c1000000-0000-4000-8000-000000000001', 'routine_reviewer', true),
  ('c1000000-0000-4000-8000-000000000002', 'routine_reviewer', true);

insert into auth.sessions (id, user_id, created_at, updated_at) values
  ('c2000000-0000-4000-8000-000000000001', 'c1000000-0000-4000-8000-000000000001', clock_timestamp(), clock_timestamp()),
  ('c2000000-0000-4000-8000-000000000002', 'c1000000-0000-4000-8000-000000000002', clock_timestamp(), clock_timestamp());

insert into public.exercise_definitions (
  id, user_id, canonical_name, normalized_name
) values (
  'c3000000-0000-4000-8000-000000000001',
  'c1000000-0000-4000-8000-000000000001',
  'Routine Test Press', 'routine test press'
);

insert into public.exercise_definition_equipment (
  exercise_id, user_id, equipment_key, position
) values (
  'c3000000-0000-4000-8000-000000000001',
  'c1000000-0000-4000-8000-000000000001', 'none', 1
);
insert into public.exercise_definition_muscles (
  exercise_id, user_id, muscle_id, role, position
) values (
  'c3000000-0000-4000-8000-000000000001',
  'c1000000-0000-4000-8000-000000000001',
  'a3000000-0000-4000-8000-000000000001', 'primary', 1
);

insert into public.guidance_revisions (
  id, exercise_id, user_id, version_number, structured_content_schema_version,
  structured_content, canonical_name_snapshot, normalized_name_snapshot,
  equipment_keys_snapshot, content_hash, revision_hash
) values (
  'c4000000-0000-4000-8000-000000000001',
  'c3000000-0000-4000-8000-000000000001',
  'c1000000-0000-4000-8000-000000000001',
  1, 1, '{}'::jsonb, 'Routine Test Press', 'routine test press', '[]'::jsonb,
  repeat('a', 64), repeat('b', 64)
);

insert into routine_test_state (key, value) values (
  'valid_days',
  jsonb_build_array(
    jsonb_build_object('dayIndex', 1, 'kind', 'workout', 'title', 'Day 1', 'purpose', 'Train', 'prescriptions', jsonb_build_array(
      jsonb_build_object('exerciseId','c3000000-0000-4000-8000-000000000001','guidanceRevisionId','c4000000-0000-4000-8000-000000000001','position',1,'sets',3,'minReps',8,'maxReps',12,'rir',2,'restSeconds',90,'priority',true,'loadUnit','kg','notes',''),
      jsonb_build_object('exerciseId','c3000000-0000-4000-8000-000000000001','guidanceRevisionId','c4000000-0000-4000-8000-000000000001','position',2,'sets',3,'minReps',8,'maxReps',12,'rir',2,'restSeconds',90,'priority',false,'loadUnit','kg','notes',''),
      jsonb_build_object('exerciseId','c3000000-0000-4000-8000-000000000001','guidanceRevisionId','c4000000-0000-4000-8000-000000000001','position',3,'sets',3,'minReps',8,'maxReps',12,'rir',2,'restSeconds',90,'priority',false,'loadUnit','kg','notes',''))),
    jsonb_build_object('dayIndex', 2, 'kind', 'workout', 'title', 'Day 2', 'purpose', 'Train', 'prescriptions', jsonb_build_array(
      jsonb_build_object('exerciseId','c3000000-0000-4000-8000-000000000001','guidanceRevisionId','c4000000-0000-4000-8000-000000000001','position',1,'sets',3,'minReps',8,'maxReps',12,'rir',2,'restSeconds',90,'priority',true,'loadUnit','kg','notes',''),
      jsonb_build_object('exerciseId','c3000000-0000-4000-8000-000000000001','guidanceRevisionId','c4000000-0000-4000-8000-000000000001','position',2,'sets',3,'minReps',8,'maxReps',12,'rir',2,'restSeconds',90,'priority',false,'loadUnit','kg','notes',''),
      jsonb_build_object('exerciseId','c3000000-0000-4000-8000-000000000001','guidanceRevisionId','c4000000-0000-4000-8000-000000000001','position',3,'sets',3,'minReps',8,'maxReps',12,'rir',2,'restSeconds',90,'priority',false,'loadUnit','kg','notes',''))),
    jsonb_build_object('dayIndex', 3, 'kind', 'rest', 'title', 'Rest', 'purpose', 'Recover', 'prescriptions', '[]'::jsonb),
    jsonb_build_object('dayIndex', 4, 'kind', 'workout', 'title', 'Day 4', 'purpose', 'Train', 'prescriptions', jsonb_build_array(
      jsonb_build_object('exerciseId','c3000000-0000-4000-8000-000000000001','guidanceRevisionId','c4000000-0000-4000-8000-000000000001','position',1,'sets',3,'minReps',8,'maxReps',12,'rir',2,'restSeconds',90,'priority',true,'loadUnit','kg','notes',''),
      jsonb_build_object('exerciseId','c3000000-0000-4000-8000-000000000001','guidanceRevisionId','c4000000-0000-4000-8000-000000000001','position',2,'sets',3,'minReps',8,'maxReps',12,'rir',2,'restSeconds',90,'priority',false,'loadUnit','kg','notes',''),
      jsonb_build_object('exerciseId','c3000000-0000-4000-8000-000000000001','guidanceRevisionId','c4000000-0000-4000-8000-000000000001','position',3,'sets',3,'minReps',8,'maxReps',12,'rir',2,'restSeconds',90,'priority',false,'loadUnit','kg','notes',''))),
    jsonb_build_object('dayIndex', 5, 'kind', 'rest', 'title', 'Rest', 'purpose', 'Recover', 'prescriptions', '[]'::jsonb),
    jsonb_build_object('dayIndex', 6, 'kind', 'workout', 'title', 'Day 6', 'purpose', 'Train', 'prescriptions', jsonb_build_array(
      jsonb_build_object('exerciseId','c3000000-0000-4000-8000-000000000001','guidanceRevisionId','c4000000-0000-4000-8000-000000000001','position',1,'sets',3,'minReps',8,'maxReps',12,'rir',2,'restSeconds',90,'priority',true,'loadUnit','kg','notes',''),
      jsonb_build_object('exerciseId','c3000000-0000-4000-8000-000000000001','guidanceRevisionId','c4000000-0000-4000-8000-000000000001','position',2,'sets',3,'minReps',8,'maxReps',12,'rir',2,'restSeconds',90,'priority',false,'loadUnit','kg','notes',''),
      jsonb_build_object('exerciseId','c3000000-0000-4000-8000-000000000001','guidanceRevisionId','c4000000-0000-4000-8000-000000000001','position',3,'sets',3,'minReps',8,'maxReps',12,'rir',2,'restSeconds',90,'priority',false,'loadUnit','kg','notes',''))),
    jsonb_build_object('dayIndex', 7, 'kind', 'rest', 'title', 'Rest', 'purpose', 'Recover', 'prescriptions', '[]'::jsonb)
  )
);

set local role anon;
select throws_ok(
  $$select public.list_my_routines_v1()$$,
  '42501', null, 'anonymous cannot call routine APIs'
);
reset role;

do $$ begin perform set_config('request.jwt.claims', jsonb_build_object(
  'sub','c1000000-0000-4000-8000-000000000001','role','authenticated',
  'session_id','c2000000-0000-4000-8000-000000000001','is_anonymous',false
)::text, true); end $$;
set local role authenticated;

insert into routine_test_state (key, value)
select 'created', public.create_routine_draft_v1(
  'Four Day Routine', 'First review flow', 'c5000000-0000-4000-8000-000000000001'
);
select is((select value ->> 'routineDraftRevision' from routine_test_state where key='created'), '1', 'owner creates a seven-day server draft');
select is(jsonb_array_length(public.get_routine_draft_v1(
  (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='created')
) -> 'days'), 7, 'new routine has exactly seven editable day slots');
select ok((public.create_routine_draft_v1(
  'Four Day Routine', 'First review flow', 'c5000000-0000-4000-8000-000000000001'
) ->> 'replayed')::boolean, 'routine create retries replay without duplicate draft creation');

insert into routine_test_state (key, value)
select 'saved', public.save_routine_draft_v1(
  (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='created'),
  'Four Day Routine', 'First review flow',
  (select value from routine_test_state where key='valid_days'),
  1, 'c5000000-0000-4000-8000-000000000002'
);
select is((select value ->> 'routineDraftRevision' from routine_test_state where key='saved'), '2', 'owner save advances optimistic revision');
select throws_ok(
  $$select public.save_routine_draft_v1(
    (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='created'),
    'Stale Save', '', (select value from routine_test_state where key='valid_days'), 1,
    'c5000000-0000-4000-8000-000000000088'
  )$$,
  '40001', 'routine_draft_revision_conflict', 'stale owner save cannot overwrite the current revision'
);
select ok((public.validate_routine_draft_v1(
  (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='created'), 2
) ->> 'valid')::boolean, 'server validator accepts the bounded valid routine');

insert into routine_test_state (key, value)
select 'submitted', public.submit_routine_v1(
  (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='created'),
  2, 'c5000000-0000-4000-8000-000000000003'
);
select is((select count(*) from public.routine_submissions), 1::bigint, 'submission freezes one immutable snapshot');
select is(
  public.get_routine_draft_v1(
    (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='created')
  ) ->> 'latestSubmissionId',
  (select value ->> 'submissionId' from routine_test_state where key='submitted'),
  'owner draft exposes its latest submission for the separate publication step'
);
select throws_ok(
  $$select public.approve_routine_submission_v1(
    (select (value ->> 'submissionId')::uuid from routine_test_state where key='submitted'),
    'Self approval', 'c5000000-0000-4000-8000-000000000004'
  )$$,
  '42501', 'routine_self_review_denied', 'author cannot approve own submission'
);
reset role;

do $$ begin perform set_config('request.jwt.claims', jsonb_build_object(
  'sub','c1000000-0000-4000-8000-000000000002','role','authenticated',
  'session_id','c2000000-0000-4000-8000-000000000002','is_anonymous',false
)::text, true); end $$;
set local role authenticated;
select is((select count(*) from public.routine_drafts), 0::bigint, 'second user cannot read owner drafts');
select throws_ok(
  $$select public.save_routine_draft_v1(
    (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='created'),
    'Stolen', '', (select value from routine_test_state where key='valid_days'), 2,
    'c5000000-0000-4000-8000-000000000005'
  )$$,
  'P0002', 'routine_draft_not_found', 'second user cannot edit owner draft'
);
select is(jsonb_array_length(public.list_routine_review_queue_v1() -> 'items'), 1, 'reviewer sees submitted routine queue');
insert into routine_test_state (key, value)
select 'approved', public.approve_routine_submission_v1(
  (select (value ->> 'submissionId')::uuid from routine_test_state where key='submitted'),
  'Looks good', 'c5000000-0000-4000-8000-000000000006'
);
select is((select value ->> 'status' from routine_test_state where key='approved'), 'approved', 'reviewer approves submitted routine');
reset role;

do $$ begin perform set_config('request.jwt.claims', jsonb_build_object(
  'sub','c1000000-0000-4000-8000-000000000001','role','authenticated',
  'session_id','c2000000-0000-4000-8000-000000000001','is_anonymous',false
)::text, true); end $$;
set local role authenticated;
insert into routine_test_state (key, value)
select 'published_one', public.publish_approved_routine_submission_v1(
  (select (value ->> 'submissionId')::uuid from routine_test_state where key='submitted'),
  current_date + (8 - extract(isodow from current_date)::integer),
  'c5000000-0000-4000-8000-000000000007'
);
select is((select value ->> 'versionNumber' from routine_test_state where key='published_one'), '1', 'approved submission publishes immutable version one');

insert into routine_test_state (key, value)
select 'duplicated', public.duplicate_routine_version_as_draft_v1(
  (select (value ->> 'routineVersionId')::uuid from routine_test_state where key='published_one'),
  'Second Routine', 'c5000000-0000-4000-8000-000000000008'
);
select is(
  public.get_routine_draft_v1(
    (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='duplicated')
  ) ->> 'baseVersionId',
  (select value ->> 'routineVersionId' from routine_test_state where key='published_one'),
  'duplicated draft persists exact published-version provenance'
);
insert into routine_test_state (key, value)
select 'submitted_two', public.submit_routine_v1(
  (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='duplicated'),
  1, 'c5000000-0000-4000-8000-000000000009'
);
reset role;

do $$ begin perform set_config('request.jwt.claims', jsonb_build_object(
  'sub','c1000000-0000-4000-8000-000000000002','role','authenticated',
  'session_id','c2000000-0000-4000-8000-000000000002','is_anonymous',false
)::text, true); end $$;
set local role authenticated;
select public.approve_routine_submission_v1(
  (select (value ->> 'submissionId')::uuid from routine_test_state where key='submitted_two'),
  null, 'c5000000-0000-4000-8000-00000000000a'
);
reset role;

do $$ begin perform set_config('request.jwt.claims', jsonb_build_object(
  'sub','c1000000-0000-4000-8000-000000000001','role','authenticated',
  'session_id','c2000000-0000-4000-8000-000000000001','is_anonymous',false
)::text, true); end $$;
set local role authenticated;
insert into routine_test_state (key, value)
select 'published_two', public.publish_approved_routine_submission_v1(
  (select (value ->> 'submissionId')::uuid from routine_test_state where key='submitted_two'),
  current_date + (15 - extract(isodow from current_date)::integer),
  'c5000000-0000-4000-8000-00000000000b'
);
select results_eq(
  $$select version_number from public.routine_versions order by source_routine_draft_id$$,
  $$values (1::bigint), (1::bigint)$$,
  'separate routines each publish their own version one'
);

insert into routine_test_state (key, value)
select 'invalid', public.create_routine_draft_v1(
  'Invalid Routine', '', 'c5000000-0000-4000-8000-00000000000c'
);
select ok(not (public.validate_routine_draft_v1(
  (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='invalid'), 1
) ->> 'valid')::boolean, 'invalid all-rest routine returns structured validation issues');
select ok(jsonb_array_length(public.validate_routine_draft_v1(
  (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='invalid'), 1
) -> 'issues') > 0, 'validator issues expose code and path contracts');

insert into routine_test_state (key, value)
select 'reject_draft', public.duplicate_routine_version_as_draft_v1(
  (select (value ->> 'routineVersionId')::uuid from routine_test_state where key='published_one'),
  'Reject Me', 'c5000000-0000-4000-8000-00000000000d'
);
insert into routine_test_state (key, value)
select 'reject_submission', public.submit_routine_v1(
  (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='reject_draft'),
  1, 'c5000000-0000-4000-8000-00000000000e'
);
reset role;

do $$ begin perform set_config('request.jwt.claims', jsonb_build_object(
  'sub','c1000000-0000-4000-8000-000000000002','role','authenticated',
  'session_id','c2000000-0000-4000-8000-000000000002','is_anonymous',false
)::text, true); end $$;
set local role authenticated;
select throws_ok(
  $$select public.duplicate_routine_version_as_draft_v1(
    (select (value ->> 'routineVersionId')::uuid from routine_test_state where key='published_one'),
    'Cross-user copy', 'c5000000-0000-4000-8000-000000000099'
  )$$,
  'P0002', 'routine_version_not_found', 'cross-user version duplication is denied'
);
select is(
  public.reject_routine_submission_v1(
    (select (value ->> 'submissionId')::uuid from routine_test_state where key='reject_submission'),
    'Needs a clearer progression plan.', 'c5000000-0000-4000-8000-00000000000f'
  ) ->> 'status',
  'rejected', 'reviewer can reject with a required reason'
);
reset role;

select throws_ok(
  $$update public.routine_versions set name = 'Mutated'$$,
  '42501', 'immutable_routine_version', 'published versions reject ordinary mutation'
);
select is((select count(*) from private.routine_mutation_operations where result ?& array['correlationId','replayed']), 13::bigint, 'routine mutations retain bounded replay evidence');

select * from finish();
rollback;
