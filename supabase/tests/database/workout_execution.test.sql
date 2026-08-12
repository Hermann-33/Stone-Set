begin;
select no_plan();

create temporary table workout_test_state (
  key text primary key,
  value jsonb not null
) on commit drop;
grant select, insert, update on table workout_test_state to authenticated;

insert into auth.users (
  instance_id, id, aud, role, email, email_confirmed_at, created_at, updated_at
) values
  ('00000000-0000-0000-0000-000000000000', 'e1000000-0000-4000-8000-000000000001',
   'authenticated', 'authenticated', 'workout-alpha@local.stone-set.invalid',
   clock_timestamp(), clock_timestamp(), clock_timestamp()),
  ('00000000-0000-0000-8000-000000000000', 'e1000000-0000-4000-8000-000000000002',
   'authenticated', 'authenticated', 'workout-bravo@local.stone-set.invalid',
   clock_timestamp(), clock_timestamp(), clock_timestamp());

insert into public.profiles (
  id, normalized_username, public_display_name, active, must_change_password, reward_timezone
) values
  ('e1000000-0000-4000-8000-000000000001', 'workout_alpha', 'Workout Alpha', true, false, 'Asia/Kuala_Lumpur'),
  ('e1000000-0000-4000-8000-000000000002', 'workout_bravo', 'Workout Bravo', true, false, 'Asia/Kuala_Lumpur');

insert into auth.sessions (id, user_id, created_at, updated_at) values
  ('e2000000-0000-4000-8000-000000000001', 'e1000000-0000-4000-8000-000000000001', clock_timestamp(), clock_timestamp()),
  ('e2000000-0000-4000-8000-000000000002', 'e1000000-0000-4000-8000-000000000002', clock_timestamp(), clock_timestamp());

insert into public.exercise_definitions (
  id, user_id, canonical_name, normalized_name, revision
) values (
  'e3000000-0000-4000-8000-000000000001',
  'e1000000-0000-4000-8000-000000000001',
  'Workout Test Squat', 'workout test squat', 1
);

insert into public.guidance_revisions (
  id, exercise_id, user_id, version_number,
  structured_content_schema_version, structured_content,
  canonical_name_snapshot, normalized_name_snapshot, variant_key_snapshot,
  equipment_keys_snapshot, content_hash, revision_hash
) values (
  'e4000000-0000-4000-8000-000000000001',
  'e3000000-0000-4000-8000-000000000001',
  'e1000000-0000-4000-8000-000000000001',
  1, 1, '{}'::jsonb,
  'Workout Test Squat', 'workout test squat', null,
  '[]'::jsonb, repeat('b', 64), repeat('c', 64)
);

-- The immutable routine below deliberately pins v1. A later finalized v2
-- exists before the workout starts and must be selected for the new session.
insert into public.guidance_revisions (
  id, exercise_id, user_id, version_number,
  structured_content_schema_version, structured_content,
  canonical_name_snapshot, normalized_name_snapshot, variant_key_snapshot,
  equipment_keys_snapshot, content_hash, revision_hash, supersedes_revision_id
) values (
  'e4000000-0000-4000-8000-000000000002',
  'e3000000-0000-4000-8000-000000000001',
  'e1000000-0000-4000-8000-000000000001',
  2, 1, '{}'::jsonb,
  'Workout Test Squat', 'workout test squat', null,
  '[]'::jsonb, repeat('e', 64), repeat('f', 64),
  'e4000000-0000-4000-8000-000000000001'
);

insert into public.guidance_media_manifests (
  guidance_revision_id, exercise_id, user_id, schema_version,
  canonical_manifest, manifest_hash, bundle_hash, publication_fingerprint
) values (
  'e4000000-0000-4000-8000-000000000002',
  'e3000000-0000-4000-8000-000000000001',
  'e1000000-0000-4000-8000-000000000001',
  1,
  jsonb_build_array('stone-set-guidance-media-manifest-v1'),
  repeat('1', 64), repeat('2', 64), repeat('3', 64)
);

insert into public.routine_drafts (
  id, user_id, name, description, status, revision
) values (
  'e5000000-0000-4000-8000-000000000001',
  'e1000000-0000-4000-8000-000000000001',
  'Workout Test Routine', '', 'published', 1
);

insert into public.routine_submissions (
  id, author_user_id, routine_draft_id, routine_draft_revision,
  snapshot, content_hash, validation_result, validation_status, status
) values (
  'e6000000-0000-4000-8000-000000000001',
  'e1000000-0000-4000-8000-000000000001',
  'e5000000-0000-4000-8000-000000000001',
  1, '{}'::jsonb, repeat('d', 64), '{}'::jsonb, 'valid', 'published'
);

insert into public.routine_reviews (
  id, submission_id, author_user_id, reviewer_user_id,
  decision, reviewer_note, content_hash
) values (
  'e7000000-0000-4000-8000-000000000001',
  'e6000000-0000-4000-8000-000000000001',
  'e1000000-0000-4000-8000-000000000001',
  'e1000000-0000-4000-8000-000000000002',
  'approved', 'Workout test approval', repeat('d', 64)
);

insert into public.routine_versions (
  id, user_id, source_routine_draft_id, approved_submission_id, approved_review_id,
  version_number, name, description, content_hash, effective_date
) values (
  'e8000000-0000-4000-8000-000000000001',
  'e1000000-0000-4000-8000-000000000001',
  'e5000000-0000-4000-8000-000000000001',
  'e6000000-0000-4000-8000-000000000001',
  'e7000000-0000-4000-8000-000000000001',
  1, 'Workout Test Routine', '', repeat('d', 64),
  ((clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date
    - (extract(isodow from (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date)::integer - 1))
);

insert into public.routine_version_days (
  routine_version_id, user_id, day_index, day_type, title, purpose, position
)
select
  'e8000000-0000-4000-8000-000000000001'::uuid,
  'e1000000-0000-4000-8000-000000000001'::uuid,
  g,
  case
    when g in (
      extract(isodow from (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date)::integer,
      ((extract(isodow from (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date)::integer % 7) + 1)
    ) then 'workout'
    else 'rest'
  end,
  case when g = extract(isodow from (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date)::integer
       then 'Today Workout'
       when g = ((extract(isodow from (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date)::integer % 7) + 1)
       then 'Next Workout'
       else 'Rest' end,
  case when g in (
      extract(isodow from (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date)::integer,
      ((extract(isodow from (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date)::integer % 7) + 1)
    ) then 'Train' else 'Recover' end,
  g
from generate_series(1, 7) as g;

insert into public.routine_version_prescriptions (
  routine_version_id, routine_version_day_id, user_id, position,
  exercise_definition_id, guidance_revision_id, priority, working_sets,
  rep_min, rep_max, rir_target, rest_seconds, load_unit, notes
)
select
  d.routine_version_id,
  d.id,
  d.user_id,
  1,
  'e3000000-0000-4000-8000-000000000001'::uuid,
  'e4000000-0000-4000-8000-000000000001'::uuid,
  true, 2, 8, 12, 2, 90, 'kg', ''
from public.routine_version_days d
where d.routine_version_id = 'e8000000-0000-4000-8000-000000000001'
  and d.day_type = 'workout';

do $$ begin perform set_config('request.jwt.claims', jsonb_build_object(
  'sub','e1000000-0000-4000-8000-000000000001','role','authenticated',
  'session_id','e2000000-0000-4000-8000-000000000001','is_anonymous',false
)::text, true); end $$;
set local role authenticated;

insert into workout_test_state (key, value)
select 'week', public.get_or_create_current_week_v1();

insert into workout_test_state (key, value)
select 'today_item', jsonb_build_object('id', id::text)
from public.training_week_items
where assigned_date = (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date
  and item_type = 'workout';

insert into workout_test_state (key, value)
select 'future_item', jsonb_build_object('id', id::text)
from public.training_week_items
where assigned_date > (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date
  and item_type = 'workout'
order by assigned_date
limit 1;

insert into workout_test_state (key, value)
select 'rest_item', jsonb_build_object('id', id::text)
from public.training_week_items
where item_type = 'rest'
order by assigned_date
limit 1;

select throws_ok(
  format('select public.start_workout_v1(%L::uuid)', (select value ->> 'id' from workout_test_state where key='future_item')),
  '22023', 'workout_not_today', 'future workout cannot start'
);
select throws_ok(
  format('select public.start_workout_v1(%L::uuid)', (select value ->> 'id' from workout_test_state where key='rest_item')),
  '22023', 'workout_item_is_rest', 'rest item cannot start'
);

insert into workout_test_state (key, value)
select 'started', public.start_workout_v1(
  ((select value ->> 'id' from workout_test_state where key='today_item'))::uuid
);

select is((select count(*) from public.workout_sessions), 1::bigint, 'today workout starts exactly one session');
select is((select count(*) from public.workout_session_exercises), 1::bigint, 'session snapshots one exercise');
select is((select count(*) from public.workout_set_entries), 2::bigint, 'session creates planned set rows');
select is((select lock_state from public.training_week_items where id=((select value ->> 'id' from workout_test_state where key='today_item'))::uuid), 'locked', 'starting locks the plan item');
select is(
  (select value -> 'session' -> 'exercises' -> 0 ->> 'guidanceRevisionId' from workout_test_state where key='started'),
  'e4000000-0000-4000-8000-000000000002',
  'new workout resolves latest finalized published guidance instead of immutable routine pin'
);

reset role;

-- Publication after session start must not rewrite or supersede the active
-- workout snapshot. The duplicate start below must still return v2.
insert into public.guidance_revisions (
  id, exercise_id, user_id, version_number,
  structured_content_schema_version, structured_content,
  canonical_name_snapshot, normalized_name_snapshot, variant_key_snapshot,
  equipment_keys_snapshot, content_hash, revision_hash, supersedes_revision_id
) values (
  'e4000000-0000-4000-8000-000000000003',
  'e3000000-0000-4000-8000-000000000001',
  'e1000000-0000-4000-8000-000000000001',
  3, 1, '{}'::jsonb,
  'Workout Test Squat', 'workout test squat', null,
  '[]'::jsonb, repeat('4', 64), repeat('5', 64),
  'e4000000-0000-4000-8000-000000000002'
);

insert into public.guidance_media_manifests (
  guidance_revision_id, exercise_id, user_id, schema_version,
  canonical_manifest, manifest_hash, bundle_hash, publication_fingerprint
) values (
  'e4000000-0000-4000-8000-000000000003',
  'e3000000-0000-4000-8000-000000000001',
  'e1000000-0000-4000-8000-000000000001',
  1,
  jsonb_build_array('stone-set-guidance-media-manifest-v1'),
  repeat('6', 64), repeat('7', 64), repeat('8', 64)
);

set local role authenticated;
insert into workout_test_state (key, value)
select 'started_again', public.start_workout_v1(
  ((select value ->> 'id' from workout_test_state where key='today_item'))::uuid
);
select is(
  (select value -> 'session' ->> 'id' from workout_test_state where key='started_again'),
  (select value -> 'session' ->> 'id' from workout_test_state where key='started'),
  'duplicate start returns the same session'
);
select is(
  (select value -> 'session' -> 'exercises' -> 0 ->> 'guidanceRevisionId' from workout_test_state where key='started_again'),
  'e4000000-0000-4000-8000-000000000002',
  'later publication does not rewrite an already-started workout snapshot'
);

insert into workout_test_state (key, value)
select 'synced', public.sync_workout_v1(
  ((select value -> 'session' ->> 'id' from workout_test_state where key='started'))::uuid,
  1,
  jsonb_build_array(
    jsonb_build_object(
      'sessionExerciseId', (select value -> 'session' -> 'exercises' -> 0 ->> 'id' from workout_test_state where key='started'),
      'setIndex', 1, 'loadValue', 80, 'loadUnit', 'kg', 'repetitions', 10, 'rir', 2, 'completed', true
    ),
    jsonb_build_object(
      'sessionExerciseId', (select value -> 'session' -> 'exercises' -> 0 ->> 'id' from workout_test_state where key='started'),
      'setIndex', 2, 'loadValue', 82.5, 'loadUnit', 'kg', 'repetitions', 9, 'rir', 2, 'completed', true
    )
  )
);
select is((select last_client_revision from public.workout_sessions), 1::bigint, 'sync advances client revision');
select is((select count(*) from public.workout_set_entries where completed), 2::bigint, 'sync stores completed set values');

select public.sync_workout_v1(
  ((select value -> 'session' ->> 'id' from workout_test_state where key='started'))::uuid,
  1,
  jsonb_build_array(
    jsonb_build_object(
      'sessionExerciseId', (select value -> 'session' -> 'exercises' -> 0 ->> 'id' from workout_test_state where key='started'),
      'setIndex', 1, 'loadValue', 1, 'loadUnit', 'kg', 'repetitions', 1, 'rir', 1, 'completed', false
    )
  )
);
select is((select load_value::numeric from public.workout_set_entries where set_index=1), 80.000::numeric, 'same revision is idempotent');

insert into workout_test_state (key, value)
select 'completed_result', public.submit_workout_v1(
  ((select value -> 'session' ->> 'id' from workout_test_state where key='started'))::uuid,
  2,
  (select jsonb_agg(jsonb_build_object(
    'sessionExerciseId', session_exercise_id::text,
    'setIndex', set_index,
    'loadValue', load_value,
    'loadUnit', load_unit,
    'repetitions', repetitions,
    'rir', rir,
    'completed', completed
  ) order by set_index) from public.workout_set_entries)
);
select is((select value -> 'result' ->> 'status' from workout_test_state where key='completed_result'), 'completed', 'all completed sets submit as completed');
select is((select state from public.workout_sessions), 'submitted', 'submit closes the session');
select is((select count(*) from public.workout_results), 1::bigint, 'submit creates one immutable result');

insert into workout_test_state (key, value)
select 'duplicate_submit', public.submit_workout_v1(
  ((select value -> 'session' ->> 'id' from workout_test_state where key='started'))::uuid,
  2,
  '[]'::jsonb
);
select is(
  (select value -> 'result' ->> 'id' from workout_test_state where key='duplicate_submit'),
  (select value -> 'result' ->> 'id' from workout_test_state where key='completed_result'),
  'duplicate submit returns the existing result'
);

reset role;

-- Reassign the second workout item to today after the first session is immutable,
-- so the same focused fixture can exercise the partial-result path.
update public.training_week_items
set assigned_date = case
  when id = ((select value ->> 'id' from workout_test_state where key='today_item'))::uuid
    then (select original_date from public.training_week_items where id=((select value ->> 'id' from workout_test_state where key='future_item'))::uuid)
  when id = ((select value ->> 'id' from workout_test_state where key='future_item'))::uuid
    then (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date
  else assigned_date
end
where id in (
  ((select value ->> 'id' from workout_test_state where key='today_item'))::uuid,
  ((select value ->> 'id' from workout_test_state where key='future_item'))::uuid
);

do $$ begin perform set_config('request.jwt.claims', jsonb_build_object(
  'sub','e1000000-0000-4000-8000-000000000001','role','authenticated',
  'session_id','e2000000-0000-4000-8000-000000000001','is_anonymous',false
)::text, true); end $$;
set local role authenticated;

insert into workout_test_state (key, value)
select 'partial_started', public.start_workout_v1(
  ((select value ->> 'id' from workout_test_state where key='future_item'))::uuid
);
insert into workout_test_state (key, value)
select 'partial_result', public.submit_workout_v1(
  ((select value -> 'session' ->> 'id' from workout_test_state where key='partial_started'))::uuid,
  1,
  jsonb_build_array(
    jsonb_build_object(
      'sessionExerciseId', (select value -> 'session' -> 'exercises' -> 0 ->> 'id' from workout_test_state where key='partial_started'),
      'setIndex', 1, 'loadValue', 70, 'loadUnit', 'kg', 'repetitions', 8, 'rir', 3, 'completed', true
    ),
    jsonb_build_object(
      'sessionExerciseId', (select value -> 'session' -> 'exercises' -> 0 ->> 'id' from workout_test_state where key='partial_started'),
      'setIndex', 2, 'loadValue', null, 'loadUnit', 'kg', 'repetitions', null, 'rir', null, 'completed', false
    )
  )
);
select is((select value -> 'result' ->> 'status' from workout_test_state where key='partial_result'), 'partial', 'incomplete planned sets submit as partial');

reset role;

do $$ begin perform set_config('request.jwt.claims', jsonb_build_object(
  'sub','e1000000-0000-4000-8000-000000000002','role','authenticated',
  'session_id','e2000000-0000-4000-8000-000000000002','is_anonymous',false
)::text, true); end $$;
set local role authenticated;
select throws_ok(
  format('select public.start_workout_v1(%L::uuid)', (select value ->> 'id' from workout_test_state where key='future_item')),
  '42501', 'workout_item_not_found', 'other user cannot start the first user workout'
);
select is((select count(*) from public.workout_sessions), 0::bigint, 'other user cannot read first user sessions');
select is((select count(*) from public.workout_results), 0::bigint, 'other user cannot read first user results');
reset role;

select * from finish();
rollback;
