begin;
select plan(4);

insert into auth.users (
  instance_id, id, aud, role, email, email_confirmed_at, created_at, updated_at
) values (
  '00000000-0000-0000-0000-000000000000',
  'f1000000-0000-4000-8000-000000000001',
  'authenticated', 'authenticated', 'guidance-freshness@local.stone-set.invalid',
  clock_timestamp(), clock_timestamp(), clock_timestamp()
);

insert into public.profiles (
  id, normalized_username, public_display_name, active, must_change_password, reward_timezone
) values (
  'f1000000-0000-4000-8000-000000000001',
  'guidance_freshness', 'Guidance Freshness', true, false, 'Asia/Kuala_Lumpur'
);

insert into public.exercise_definitions (
  id, user_id, canonical_name, normalized_name, revision
) values (
  'f2000000-0000-4000-8000-000000000001',
  'f1000000-0000-4000-8000-000000000001',
  'Guidance Freshness Squat', 'guidance freshness squat', 1
);

insert into public.guidance_revisions (
  id, exercise_id, user_id, version_number,
  structured_content_schema_version, structured_content,
  canonical_name_snapshot, normalized_name_snapshot, variant_key_snapshot,
  equipment_keys_snapshot, content_hash, revision_hash
) values
  (
    'f3000000-0000-4000-8000-000000000001',
    'f2000000-0000-4000-8000-000000000001',
    'f1000000-0000-4000-8000-000000000001',
    1, 1, '{}'::jsonb,
    'Guidance Freshness Squat', 'guidance freshness squat', null,
    '[]'::jsonb, repeat('1', 64), repeat('2', 64)
  ),
  (
    'f3000000-0000-4000-8000-000000000002',
    'f2000000-0000-4000-8000-000000000001',
    'f1000000-0000-4000-8000-000000000001',
    2, 1, '{}'::jsonb,
    'Guidance Freshness Squat', 'guidance freshness squat', null,
    '[]'::jsonb, repeat('3', 64), repeat('4', 64)
  );

select ok(
  exists (
    select 1
    from pg_trigger
    where tgrelid = 'public.workout_session_exercises'::regclass
      and tgname = 'workout_session_exercises_latest_guidance_before_insert'
      and not tgisinternal
  ),
  'new workout-session exercise inserts have the latest-guidance resolver trigger'
);

create temporary table guidance_resolution_probe (
  id integer primary key,
  user_id uuid not null,
  exercise_definition_id uuid not null,
  guidance_revision_id uuid not null
) on commit drop;

create trigger guidance_resolution_probe_latest_guidance
before insert on guidance_resolution_probe
for each row
execute function private.resolve_latest_workout_guidance_revision_v1();

insert into guidance_resolution_probe (
  id, user_id, exercise_definition_id, guidance_revision_id
) values (
  1,
  'f1000000-0000-4000-8000-000000000001',
  'f2000000-0000-4000-8000-000000000001',
  'f3000000-0000-4000-8000-000000000001'
);

select is(
  (select guidance_revision_id::text from guidance_resolution_probe where id = 1),
  'f3000000-0000-4000-8000-000000000002',
  'a new workout snapshot resolves the latest finalized published revision'
);

insert into public.guidance_revisions (
  id, exercise_id, user_id, version_number,
  structured_content_schema_version, structured_content,
  canonical_name_snapshot, normalized_name_snapshot, variant_key_snapshot,
  equipment_keys_snapshot, content_hash, revision_hash, supersedes_revision_id
) values (
  'f3000000-0000-4000-8000-000000000003',
  'f2000000-0000-4000-8000-000000000001',
  'f1000000-0000-4000-8000-000000000001',
  3, 1, '{}'::jsonb,
  'Guidance Freshness Squat', 'guidance freshness squat', null,
  '[]'::jsonb, repeat('5', 64), repeat('6', 64),
  'f3000000-0000-4000-8000-000000000002'
);

select is(
  (select guidance_revision_id::text from guidance_resolution_probe where id = 1),
  'f3000000-0000-4000-8000-000000000002',
  'later publication does not rewrite an already-created workout snapshot'
);

insert into guidance_resolution_probe (
  id, user_id, exercise_definition_id, guidance_revision_id
) values (
  2,
  'f1000000-0000-4000-8000-000000000001',
  'f2000000-0000-4000-8000-000000000001',
  'f3000000-0000-4000-8000-000000000001'
);

select is(
  (select guidance_revision_id::text from guidance_resolution_probe where id = 2),
  'f3000000-0000-4000-8000-000000000003',
  'the next new workout snapshot resolves the newly published revision'
);

select * from finish();
rollback;
