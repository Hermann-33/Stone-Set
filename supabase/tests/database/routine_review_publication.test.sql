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
  $$select public.publish_routine_draft_v1(
    '00000000-0000-4000-8000-000000000001'::uuid, 1,
    'c5000000-0000-4000-8000-000000000001'::uuid
  )$$,
  '42501', null, 'anonymous cannot publish a routine'
);
reset role;

do $$ begin perform set_config('request.jwt.claims', jsonb_build_object(
  'sub','c1000000-0000-4000-8000-000000000001','role','authenticated',
  'session_id','c2000000-0000-4000-8000-000000000001','is_anonymous',false
)::text, true); end $$;
set local role authenticated;

insert into routine_test_state (key, value)
select 'created', public.create_routine_draft_v1(
  'Four Day Routine', 'Direct publication flow', 'c5000000-0000-4000-8000-000000000002'
);
select is(
  (select value ->> 'routineDraftRevision' from routine_test_state where key='created'),
  '1',
  'owner creates a routine draft'
);

insert into routine_test_state (key, value)
select 'saved', public.save_routine_draft_v1(
  (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='created'),
  'Four Day Routine', 'Direct publication flow',
  (select value from routine_test_state where key='valid_days'),
  1, 'c5000000-0000-4000-8000-000000000003'
);
select is(
  (select value ->> 'routineDraftRevision' from routine_test_state where key='saved'),
  '2',
  'owner save advances optimistic revision'
);
select ok((public.validate_routine_draft_v1(
  (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='created'), 2
) ->> 'valid')::boolean, 'server validator accepts a valid routine');

select throws_ok(
  $$select public.submit_routine_v1(
    (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='created'),
    2, 'c5000000-0000-4000-8000-000000000004'
  )$$,
  '42501', null, 'legacy submission RPC is unavailable to application users'
);

insert into routine_test_state (key, value)
select 'published', public.publish_routine_draft_v1(
  (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='created'),
  2, 'c5000000-0000-4000-8000-000000000005'
);
select is(
  (select value ->> 'status' from routine_test_state where key='published'),
  'published',
  'owner publishes directly without review'
);
select is(
  (select value ->> 'versionNumber' from routine_test_state where key='published'),
  '1',
  'direct publication creates immutable version one'
);
select is(
  (select value ->> 'effectiveDate' from routine_test_state where key='published'),
  date_trunc('week', current_date)::date::text,
  'published version becomes effective for the current training week'
);
select is(
  public.get_routine_draft_v1(
    (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='created')
  ) ->> 'status',
  'published',
  'published routine is read only'
);
select is(
  (select count(*) from public.routine_versions where source_routine_draft_id =
    (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='created')),
  1::bigint,
  'direct publication stores exactly one version'
);
select is(
  (select approved_submission_id from public.routine_versions where source_routine_draft_id =
    (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='created')),
  null::uuid,
  'direct publication requires no approval submission'
);
select is(
  (select approved_review_id from public.routine_versions where source_routine_draft_id =
    (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='created')),
  null::uuid,
  'direct publication requires no review record'
);
select ok((public.publish_routine_draft_v1(
  (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='created'),
  2, 'c5000000-0000-4000-8000-000000000005'
) ->> 'replayed')::boolean, 'publish retry replays without a duplicate version');

reset role;

do $$ begin perform set_config('request.jwt.claims', jsonb_build_object(
  'sub','c1000000-0000-4000-8000-000000000002','role','authenticated',
  'session_id','c2000000-0000-4000-8000-000000000002','is_anonymous',false
)::text, true); end $$;
set local role authenticated;
select throws_ok(
  $$select public.publish_routine_draft_v1(
    (select (value ->> 'routineDraftId')::uuid from routine_test_state where key='created'),
    2, 'c5000000-0000-4000-8000-000000000006'
  )$$,
  'P0002', 'publishable_routine_draft_not_found', 'another user cannot publish the owner routine'
);

reset role;
select * from finish();
rollback;
