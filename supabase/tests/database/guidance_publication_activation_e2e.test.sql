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

create temporary table activation_probe (
  id integer primary key,
  user_id uuid not null,
  exercise_definition_id uuid not null,
  guidance_revision_id uuid not null
) on commit drop;

create trigger activation_probe_latest_guidance
before insert on activation_probe
for each row
execute function private.resolve_latest_workout_guidance_revision_v1();

insert into activation_probe (id, user_id, exercise_definition_id, guidance_revision_id)
select
  1,
  'fa100000-0000-4000-8000-000000000001',
  (value ->> 'exerciseId')::uuid,
  (select (value ->> 'guidanceRevisionId')::uuid from activation_state where key = 'published_v1')
from activation_state where key = 'exercise';

select is(
  (select guidance_revision_id::text from activation_probe where id = 1),
  (select value ->> 'guidanceRevisionId' from activation_state where key = 'published_v1'),
  'a workout snapshot created after publication pins version 1'
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
  (select guidance_revision_id::text from activation_probe where id = 1),
  (select value ->> 'guidanceRevisionId' from activation_state where key = 'published_v1'),
  'publishing version 2 does not mutate a workout snapshot that already started on version 1'
);

insert into activation_probe (id, user_id, exercise_definition_id, guidance_revision_id)
select
  2,
  'fa100000-0000-4000-8000-000000000001',
  (value ->> 'exerciseId')::uuid,
  (select (value ->> 'guidanceRevisionId')::uuid from activation_state where key = 'published_v1')
from activation_state where key = 'exercise';

select is(
  (select guidance_revision_id::text from activation_probe where id = 2),
  (select value ->> 'guidanceRevisionId' from activation_state where key = 'published_v2'),
  'the next new workout snapshot resolves the newly published version 2'
);

reset role;
select * from finish();
rollback;