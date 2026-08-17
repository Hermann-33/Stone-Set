begin;
select plan(5);

create temporary table activation_state (
  key text primary key,
  value jsonb not null
) on commit drop;
grant select, insert, update on table activation_state to authenticated;

insert into auth.users (
  instance_id, id, aud, role, email, email_confirmed_at, created_at, updated_at
) values (
  '00000000-0000-0000-0000-000000000000',
  'fa100000-0000-4000-8000-000000000001',
  'authenticated', 'authenticated', 'guidance-activation@local.stone-set.invalid',
  clock_timestamp(), clock_timestamp(), clock_timestamp()
);

insert into public.profiles (
  id, normalized_username, public_display_name, active, must_change_password, reward_timezone
) values (
  'fa100000-0000-4000-8000-000000000001',
  'guidance_activation', 'Guidance Activation', true, false, 'Asia/Kuala_Lumpur'
);

insert into auth.sessions (id, user_id, created_at, updated_at) values (
  'fa200000-0000-4000-8000-000000000001',
  'fa100000-0000-4000-8000-000000000001',
  clock_timestamp(), clock_timestamp()
);

do $$
begin
  perform set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', 'fa100000-0000-4000-8000-000000000001',
      'role', 'authenticated',
      'session_id', 'fa200000-0000-4000-8000-000000000001',
      'is_anonymous', false
    )::text,
    true
  );
end;
$$;
set local role authenticated;

insert into activation_state (key, value)
select 'exercise', public.create_exercise_v1(
  'Guidance Activation Squat', null, '["none"]'::jsonb,
  jsonb_build_array(
    jsonb_build_object(
      'muscleId', (select id::text from public.muscles order by stable_key limit 1),
      'role', 'primary',
      'position', 1
    )
  ),
  false, 'fa300000-0000-4000-8000-000000000001'
);

insert into activation_state (key, value)
select 'draft_v1', public.save_guidance_draft_v1(
  (select (value ->> 'draftId')::uuid from activation_state where key = 'exercise'),
  '{
    "shortExplanation":"Published version one.",
    "setupSteps":["Set up version one"],
    "executionSteps":["Execute version one"],
    "techniqueCues":[],
    "commonMistakes":[],
    "safetyNotes":[]
  }'::jsonb,
  1,
  'fa300000-0000-4000-8000-000000000002'
);

insert into activation_state (key, value)
select 'reservation_v1', public.begin_guidance_media_publication_v1(
  (select (value ->> 'exerciseId')::uuid from activation_state where key = 'exercise'),
  (select (value ->> 'draftId')::uuid from activation_state where key = 'exercise'),
  (select (value ->> 'exerciseRevision')::bigint from activation_state where key = 'exercise'),
  (select (value ->> 'draftRevision')::bigint from activation_state where key = 'draft_v1'),
  (
    select (public.get_guidance_draft_media_manifest_v1(
      (select (value ->> 'exerciseId')::uuid from activation_state where key = 'exercise'),
      (select (value ->> 'draftId')::uuid from activation_state where key = 'exercise')
    ) ->> 'mediaRevision')::bigint
  ),
  'fa300000-0000-4000-8000-000000000003'
);

insert into activation_state (key, value)
select 'published_v1', public.finalize_guidance_media_publication_v1(
  (select (value ->> 'reservationId')::uuid from activation_state where key = 'reservation_v1'),
  'fa300000-0000-4000-8000-000000000004'
);

select is(
  (select (value ->> 'versionNumber')::integer from activation_state where key = 'published_v1'),
  1,
  'first atomic dashboard publication creates immutable guidance version 1'
);

reset role;

insert into public.routine_drafts (
  id, user_id, name, description, status, revision
) values (
  'fa400000-0000-4000-8000-000000000001',
  'fa100000-0000-4000-8000-000000000001',
  'Guidance Activation Routine', '', 'published', 1
);

insert into public.routine_submissions (
  id, author_user_id, routine_draft_id, routine_draft_revision,
  snapshot, content_hash, validation_result, validation_status, status
) values (
  'fa500000-0000-4000-8000-000000000001',
  'fa100000-0000-4000-8000-000000000001',
  'fa400000-0000-4000-8000-000000000001',
  1, '{}'::jsonb, repeat('d', 64), '{}'::jsonb, 'valid', 'published'
);

insert into public.routine_reviews (
  id, submission_id, author_user_id, reviewer_user_id,
  decision, reviewer_note, content_hash
) values (
  'fa600000-0000-4000-8000-000000000001',
  'fa500000-0000-4000-8000-000000000001',
  'fa100000-0000-4000-8000-000000000001',
  'fa100000-0000-4000-8000-000000000001',
  'approved', 'Guidance activation fixture', repeat('d', 64)
);

insert into public.routine_versions (
  id, user_id, source_routine_draft_id, approved_submission_id, approved_review_id,
  version_number, name, description, content_hash, effective_date
) values (
  'fa700000-0000-4000-8000-000000000001',
  'fa100000-0000-4000-8000-000000000001',
  'fa400000-0000-4000-8000-000000000001',
  'fa500000-0000-4000-8000-000000000001',
  'fa600000-0000-4000-8000-000000000001',
  1, 'Guidance Activation Routine', '', repeat('d', 64),
  ((clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date
    - (extract(isodow from (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date)::integer - 1))
);

insert into public.routine_version_days (
  routine_version_id, user_id, day_index, day_type, title, purpose, position
)
select
  'fa700000-0000-4000-8000-000000000001'::uuid,
  'fa100000-0000-4000-8000-000000000001'::uuid,
  g,
  case
    when g in (
      extract(isodow from (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date)::integer,
      ((extract(isodow from (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date)::integer % 7) + 1)
    ) then 'workout'
    else 'rest'
  end,
  case
    when g = extract(isodow from (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date)::integer
      then 'First Activation Workout'
    when g = ((extract(isodow from (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date)::integer % 7) + 1)
      then 'Second Activation Workout'
    else 'Rest'
  end,
  case
    when g in (
      extract(isodow from (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date)::integer,
      ((extract(isodow from (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date)::integer % 7) + 1)
    ) then 'Train'
    else 'Recover'
  end,
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
  (select (value ->> 'exerciseId')::uuid from activation_state where key = 'exercise'),
  (select (value ->> 'guidanceRevisionId')::uuid from activation_state where key = 'published_v1'),
  true, 2, 8, 12, 2, 90, 'kg', ''
from public.routine_version_days d
where d.routine_version_id = 'fa700000-0000-4000-8000-000000000001'
  and d.day_type = 'workout';

set local role authenticated;

insert into activation_state (key, value)
select 'week', public.get_or_create_current_week_v1();

insert into activation_state (key, value)
select 'today_item', jsonb_build_object('id', id::text)
from public.training_week_items
where user_id = 'fa100000-0000-4000-8000-000000000001'
  and assigned_date = (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date
  and item_type = 'workout';

insert into activation_state (key, value)
select 'future_item', jsonb_build_object('id', id::text)
from public.training_week_items
where user_id = 'fa100000-0000-4000-8000-000000000001'
  and assigned_date > (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date
  and item_type = 'workout'
order by assigned_date
limit 1;

insert into activation_state (key, value)
select 'started_v1', public.start_workout_v1(
  ((select value ->> 'id' from activation_state where key = 'today_item'))::uuid
);

select is(
  (select value -> 'session' -> 'exercises' -> 0 ->> 'guidanceRevisionId'
   from activation_state where key = 'started_v1'),
  (select value ->> 'guidanceRevisionId' from activation_state where key = 'published_v1'),
  'a real workout started after publication pins version 1'
);

insert into activation_state (key, value)
select 'draft_v2', public.save_guidance_draft_v1(
  (select (value ->> 'draftId')::uuid from activation_state where key = 'exercise'),
  '{
    "shortExplanation":"Published version two from a later dashboard edit.",
    "setupSteps":["Set up version two"],
    "executionSteps":["Execute version two"],
    "techniqueCues":["New cue"],
    "commonMistakes":[],
    "safetyNotes":[]
  }'::jsonb,
  (select revision from public.guidance_drafts where id =
    (select (value ->> 'draftId')::uuid from activation_state where key = 'exercise')),
  'fa300000-0000-4000-8000-000000000005'
);

insert into activation_state (key, value)
select 'reservation_v2', public.begin_guidance_media_publication_v1(
  (select (value ->> 'exerciseId')::uuid from activation_state where key = 'exercise'),
  (select (value ->> 'draftId')::uuid from activation_state where key = 'exercise'),
  (select (value ->> 'exerciseRevision')::bigint from activation_state where key = 'exercise'),
  (select (value ->> 'draftRevision')::bigint from activation_state where key = 'draft_v2'),
  (
    select (public.get_guidance_draft_media_manifest_v1(
      (select (value ->> 'exerciseId')::uuid from activation_state where key = 'exercise'),
      (select (value ->> 'draftId')::uuid from activation_state where key = 'exercise')
    ) ->> 'mediaRevision')::bigint
  ),
  'fa300000-0000-4000-8000-000000000006'
);

insert into activation_state (key, value)
select 'published_v2', public.finalize_guidance_media_publication_v1(
  (select (value ->> 'reservationId')::uuid from activation_state where key = 'reservation_v2'),
  'fa300000-0000-4000-8000-000000000007'
);

select is(
  (select (value ->> 'versionNumber')::integer from activation_state where key = 'published_v2'),
  2,
  'second atomic dashboard publication creates immutable guidance version 2'
);

select is(
  (select value -> 'session' -> 'exercises' -> 0 ->> 'guidanceRevisionId'
   from activation_state where key = 'started_v1'),
  (select value ->> 'guidanceRevisionId' from activation_state where key = 'published_v1'),
  'publishing version 2 does not mutate the already-started workout payload'
);

reset role;

update public.training_week_items
set assigned_date = case
  when id = ((select value ->> 'id' from activation_state where key = 'today_item'))::uuid
    then (select original_date from public.training_week_items
          where id = ((select value ->> 'id' from activation_state where key = 'future_item'))::uuid)
  when id = ((select value ->> 'id' from activation_state where key = 'future_item'))::uuid
    then (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date
  else assigned_date
end
where id in (
  ((select value ->> 'id' from activation_state where key = 'today_item'))::uuid,
  ((select value ->> 'id' from activation_state where key = 'future_item'))::uuid
);

set local role authenticated;

insert into activation_state (key, value)
select 'started_v2', public.start_workout_v1(
  ((select value ->> 'id' from activation_state where key = 'future_item'))::uuid
);

select is(
  (select value -> 'session' -> 'exercises' -> 0 ->> 'guidanceRevisionId'
   from activation_state where key = 'started_v2'),
  (select value ->> 'guidanceRevisionId' from activation_state where key = 'published_v2'),
  'the next real workout start resolves the newly published version 2'
);

reset role;
select * from finish();
rollback;