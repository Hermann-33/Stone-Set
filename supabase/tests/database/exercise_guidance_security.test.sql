begin;
select no_plan();

create temporary table exercise_test_state (
  key text primary key,
  value jsonb not null
) on commit drop;
grant select, insert on table exercise_test_state to authenticated;

insert into auth.users (
  instance_id, id, aud, role, email, email_confirmed_at, created_at, updated_at
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '91000000-0000-4000-8000-000000000001',
    'authenticated', 'authenticated', 'exercise-alpha@local.stone-set.invalid',
    clock_timestamp(), clock_timestamp(), clock_timestamp()
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '92000000-0000-4000-8000-000000000002',
    'authenticated', 'authenticated', 'exercise-bravo@local.stone-set.invalid',
    clock_timestamp(), clock_timestamp(), clock_timestamp()
  );

insert into public.profiles (
  id, normalized_username, public_display_name, active, must_change_password, reward_timezone
) values
  (
    '91000000-0000-4000-8000-000000000001',
    'exercise_alpha', 'Exercise Alpha', true, false, 'UTC'
  ),
  (
    '92000000-0000-4000-8000-000000000002',
    'exercise_bravo', 'Exercise Bravo', true, false, 'UTC'
  );

insert into auth.sessions (id, user_id, created_at, updated_at) values
  (
    '93000000-0000-4000-8000-000000000001',
    '91000000-0000-4000-8000-000000000001',
    clock_timestamp(), clock_timestamp()
  ),
  (
    '93000000-0000-4000-8000-000000000002',
    '92000000-0000-4000-8000-000000000002',
    clock_timestamp(), clock_timestamp()
  );

set local role anon;
select throws_ok(
  $$select count(*) from public.muscles$$,
  '42501', null,
  'anon has object-level taxonomy denial'
);
select throws_ok(
  $$select public.create_exercise_v1(
    'Denied', null, '["none"]',
    '[{"muscleId":"a3000000-0000-4000-8000-000000000001","role":"primary","position":1}]',
    false, '94000000-0000-4000-8000-000000000001'
  )$$,
  '42501', null,
  'anon has function-level create denial'
);
select throws_ok(
  $$select public.list_exercises_v1()$$,
  '42501', null,
  'anon has function-level bounded list denial'
);
reset role;

do $$
begin
  perform set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', '91000000-0000-4000-8000-000000000001',
      'role', 'authenticated',
      'session_id', '93000000-0000-4000-8000-000000000001',
      'is_anonymous', true
    )::text,
    true
  );
end;
$$;
set local role authenticated;
select is(
  (select count(*) from public.muscles),
  0::bigint,
  'anonymous Auth session cannot read product taxonomy'
);
select throws_ok(
  $$select public.list_exercises_v1()$$,
  '42501', 'product_identity_not_authorized',
  'anonymous Auth session cannot call product reads'
);
reset role;

do $$
begin
  perform set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', '91000000-0000-4000-8000-000000000001',
      'role', 'authenticated',
      'session_id', '93000000-0000-4000-8000-000000000001',
      'is_anonymous', false
    )::text,
    true
  );
end;
$$;
set local role authenticated;

select is((select count(*) from public.muscles), 13::bigint, 'active session reads fixed taxonomy');
select throws_ok(
  $$update public.muscles set display_name = 'Changed' where stable_key = 'chest'$$,
  '42501', null,
  'authenticated cannot mutate taxonomy at the object layer'
);
select throws_ok(
  $$select public.create_exercise_v1(
    'Malformed muscle', null, '["none"]',
    '[{"muscleId":"not-a-uuid","role":"primary","position":999999999999999999999}]',
    false, '94000000-0000-4000-8000-000000000002'
  )$$,
  '22023', 'invalid_muscle_payload',
  'malformed muscle identity and position return a stable safe validation error'
);
select throws_ok(
  $$select public.create_exercise_v1(
    'Gapped muscles', null, '["none"]',
    '[{"muscleId":"a3000000-0000-4000-8000-000000000001","role":"primary","position":2}]',
    false, '94000000-0000-4000-8000-000000000003'
  )$$,
  '22023', 'invalid_muscle_payload',
  'muscle display positions must be contiguous from one per role'
);

insert into exercise_test_state (key, value)
select 'created', public.create_exercise_v1(
  '  Bench   Press  ',
  null,
  '["barbell"]',
  '[
    {"muscleId":"a3000000-0000-4000-8000-000000000001","role":"primary","position":1},
    {"muscleId":"a3000000-0000-4000-8000-000000000007","role":"secondary","position":1}
  ]',
  false,
  '94000000-0000-4000-8000-000000000010'
);

select is(
  (select value ->> 'exerciseRevision' from exercise_test_state where key = 'created'),
  '1',
  'create returns the first authoritative exercise revision'
);
select ok(
  not (select (value ->> 'replayed')::boolean from exercise_test_state where key = 'created')
  and (select value ->> 'correlationId' from exercise_test_state where key = 'created')
      ~* '^[0-9a-f-]{36}$',
  'first mutation result has correlation evidence and replayed false'
);
select is(
  (select canonical_name from public.exercise_definitions),
  'Bench Press',
  'server normalizes canonical display whitespace'
);
select is(
  (select normalized_name from public.exercise_definitions),
  'bench press',
  'server owns lowercase duplicate normalization'
);
select is((select count(*) from public.exercise_definitions), 1::bigint, 'owner reads own exercise');
select is((select count(*) from public.exercise_definition_equipment), 1::bigint, 'owner reads equipment');
select is((select count(*) from public.exercise_definition_muscles), 2::bigint, 'owner reads ordered muscles');
select is((select count(*) from public.guidance_drafts), 1::bigint, 'create also creates one owner draft');

insert into exercise_test_state (key, value)
select 'create_replay', public.create_exercise_v1(
    '  Bench   Press  ', null, '["barbell"]',
    '[
      {"muscleId":"a3000000-0000-4000-8000-000000000001","role":"primary","position":1},
      {"muscleId":"a3000000-0000-4000-8000-000000000007","role":"secondary","position":1}
    ]',
    false, '94000000-0000-4000-8000-000000000010'
  );
select is(
  (select value - 'replayed' from exercise_test_state where key = 'create_replay'),
  (select value - 'replayed' from exercise_test_state where key = 'created'),
  'identical create retry preserves the exact safe result and correlation evidence'
);
select ok(
  (select (value ->> 'replayed')::boolean from exercise_test_state where key = 'create_replay'),
  'identical create retry is explicitly marked replayed'
);
select is((select count(*) from public.exercise_definitions), 1::bigint, 'idempotent retry creates no duplicate row');

select throws_ok(
  $$select public.create_exercise_v1(
    'Bench Press', null, '["barbell"]',
    '[{"muscleId":"a3000000-0000-4000-8000-000000000001","role":"primary","position":1}]',
    false, '94000000-0000-4000-8000-000000000011'
  )$$,
  'P0001', 'duplicate_exercise_confirmation_required',
  'normalized duplicate requires explicit confirmation'
);
select lives_ok(
  $$select public.create_exercise_v1(
    'Bench Press', null, '["barbell"]',
    '[{"muscleId":"a3000000-0000-4000-8000-000000000001","role":"primary","position":1}]',
    true, '94000000-0000-4000-8000-000000000012'
  )$$,
  'explicit confirmation creates a separate owned definition'
);
select is((select count(*) from public.exercise_definitions), 2::bigint, 'confirmed duplicate does not overwrite source');
select throws_ok(
  $$select public.create_exercise_v1(
    'Different', null, '["barbell"]',
    '[{"muscleId":"a3000000-0000-4000-8000-000000000001","role":"primary","position":1}]',
    false, '94000000-0000-4000-8000-000000000010'
  )$$,
  '22023', 'idempotency_key_reused',
  'idempotency key cannot be replayed with a different request fingerprint'
);

select throws_ok(
  format(
    'update public.exercise_definitions set archived_at = clock_timestamp() where id = %L',
    (select value ->> 'exerciseId' from exercise_test_state where key = 'created')
  ),
  '42501', null,
  'authenticated direct table mutation is denied despite owner RLS'
);

insert into exercise_test_state (key, value)
select 'saved', public.save_guidance_draft_v1(
  (select (value ->> 'draftId')::uuid from exercise_test_state where key = 'created'),
  '{
    "shortExplanation":"Press safely.",
    "setupSteps":["Lie back."],
    "executionSteps":["Press up."],
    "techniqueCues":["Brace."],
    "commonMistakes":["Flaring elbows."],
    "safetyNotes":["Use a spotter."]
  }',
  1,
  '94000000-0000-4000-8000-000000000020'
);
select is(
  (select value ->> 'draftRevision' from exercise_test_state where key = 'saved'),
  '2',
  'draft save increments optimistic revision'
);
select throws_ok(
  $$select public.save_guidance_draft_v1(
    (select (value ->> 'draftId')::uuid from exercise_test_state where key = 'created'),
    '{"shortExplanation":"Stale","setupSteps":[],"executionSteps":["Move"],"techniqueCues":[],"commonMistakes":[],"safetyNotes":[]}',
    1,
    '94000000-0000-4000-8000-000000000021'
  )$$,
  '40001', 'stale_guidance_draft_revision',
  'stale autosave cannot overwrite newer server content'
);
do $capture_stale_draft$
declare
  v_detail text;
  v_sqlstate text;
begin
  perform public.save_guidance_draft_v1(
    (select (value ->> 'draftId')::uuid from exercise_test_state where key = 'created'),
    '{"shortExplanation":"Stale","setupSteps":[],"executionSteps":["Move"],"techniqueCues":[],"commonMistakes":[],"safetyNotes":[]}',
    1,
    '94000000-0000-4000-8000-000000000023'
  );
exception
  when others then
    get stacked diagnostics
      v_detail = pg_exception_detail,
      v_sqlstate = returned_sqlstate;
    insert into exercise_test_state (key, value)
    values (
      'stale_draft_detail',
      jsonb_build_object('sqlstate', v_sqlstate, 'detail', v_detail::jsonb)
    );
end;
$capture_stale_draft$;
select ok(
  (select value ->> 'sqlstate' = '40001'
     and value -> 'detail' ?& array['correlationId', 'draftRevision']
     and value -> 'detail' ->> 'draftRevision' = '2'
     and value -> 'detail' ->> 'correlationId' ~* '^[0-9a-f-]{36}$'
     and not (value -> 'detail' ? 'exerciseRevision')
     and value::text not like '%Press safely.%'
   from exercise_test_state where key = 'stale_draft_detail'),
  'stale draft DETAIL exposes only safe camelCase conflict and correlation evidence'
);
select ok(
  (public.validate_guidance_draft_v1(
    (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
    (select (value ->> 'draftId')::uuid from exercise_test_state where key = 'created'),
    1,
    2
  ) ->> 'valid')::boolean,
  'server validation accepts complete structured plain text'
);
select throws_ok(
  $$select public.validate_guidance_draft_v1(
    (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
    (select (value ->> 'draftId')::uuid from exercise_test_state where key = 'created'),
    null,
    2
  )$$,
  '22023', 'invalid_guidance_validation_request',
  'validation rejects missing optimistic revision evidence'
);
select throws_ok(
  $$select public.save_guidance_draft_v1(
    (select (value ->> 'draftId')::uuid from exercise_test_state where key = 'created'),
    '{"shortExplanation":"Bad","setupSteps":[""],"executionSteps":[],"techniqueCues":[],"commonMistakes":[],"safetyNotes":[]}',
    2,
    '94000000-0000-4000-8000-000000000022'
  )$$,
  '22023', 'invalid_guidance_list_item',
  'blank structured list entries are rejected'
);

insert into exercise_test_state (key, value)
select 'published', public.publish_guidance_revision_v1(
  (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
  (select (value ->> 'draftId')::uuid from exercise_test_state where key = 'created'),
  1,
  2,
  '94000000-0000-4000-8000-000000000030'
);
select is((select count(*) from public.guidance_revisions), 1::bigint, 'publish creates one immutable revision');
select is(
  (select content_hash from public.guidance_revisions),
  'd91923f6c59a2ead20f6c9247f96793fbd64ddfb02d6db0286ab3dc4b5760d2e',
  'canonical content serialization matches the committed SHA-256 golden vector'
);
select is(
  (select jsonb_agg(muscle_key_snapshot order by role, position) from public.guidance_revision_muscles),
  '["chest", "triceps"]'::jsonb,
  'published revision pins ordered stable muscle evidence'
);
select is(
  (select equipment_keys_snapshot from public.guidance_revisions),
  '["barbell"]'::jsonb,
  'published revision pins ordered equipment evidence'
);
select ok(
  (select content_hash ~ '^[0-9a-f]{64}$' and revision_hash ~ '^[0-9a-f]{64}$'
   from public.guidance_revisions),
  'content and revision hashes are lowercase SHA-256 hex'
);

insert into exercise_test_state (key, value)
select 'no_change_publish', public.publish_guidance_revision_v1(
  (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
  (select (value ->> 'draftId')::uuid from exercise_test_state where key = 'created'),
  1,
  3,
  '94000000-0000-4000-8000-000000000031'
);
select ok(
  (select (value ->> 'noChange')::boolean from exercise_test_state where key = 'no_change_publish'),
  'publishing identical canonical content returns an explicit no-change result'
);
select is((select count(*) from public.guidance_revisions), 1::bigint, 'no-change publication creates no duplicate history');
insert into exercise_test_state (key, value)
select 'publish_replay', public.publish_guidance_revision_v1(
    (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
    (select (value ->> 'draftId')::uuid from exercise_test_state where key = 'created'),
    1, 2, '94000000-0000-4000-8000-000000000030'
  );
select is(
  (select value - 'replayed' from exercise_test_state where key = 'publish_replay'),
  (select value - 'replayed' from exercise_test_state where key = 'published'),
  'publication retry preserves its original result after draft base advancement'
);
select ok(
  (select (value ->> 'replayed')::boolean from exercise_test_state where key = 'publish_replay'),
  'publication retry is explicitly marked replayed'
);

insert into exercise_test_state (key, value)
select 'modified_after_publish', public.save_guidance_draft_v1(
  (select (value ->> 'draftId')::uuid from exercise_test_state where key = 'created'),
  '{
    "shortExplanation":"A local edit to replace.",
    "setupSteps":["Different setup."],
    "executionSteps":[],
    "techniqueCues":[],
    "commonMistakes":[],
    "safetyNotes":[]
  }',
  3,
  '94000000-0000-4000-8000-000000000060'
);
insert into exercise_test_state (key, value)
select 'duplicated_revision', public.duplicate_guidance_revision_as_draft_v1(
  (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
  (select (value ->> 'guidanceRevisionId')::uuid from exercise_test_state where key = 'published'),
  4,
  '94000000-0000-4000-8000-000000000061'
);
select ok(
  not (select (value ->> 'noChange')::boolean from exercise_test_state where key = 'duplicated_revision')
  and not (select (value ->> 'replayed')::boolean from exercise_test_state where key = 'duplicated_revision'),
  'duplicate revision replaces a changed current draft and reports first execution'
);
select is(
  (select structured_content ->> 'shortExplanation' from public.guidance_drafts
   where id = (select (value ->> 'draftId')::uuid from exercise_test_state where key = 'created')),
  'Press safely.',
  'duplicate revision restores the immutable historical structured content'
);
insert into exercise_test_state (key, value)
select 'duplicate_revision_replay', public.duplicate_guidance_revision_as_draft_v1(
  (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
  (select (value ->> 'guidanceRevisionId')::uuid from exercise_test_state where key = 'published'),
  4,
  '94000000-0000-4000-8000-000000000061'
);
select is(
  (select value - 'replayed' from exercise_test_state where key = 'duplicate_revision_replay'),
  (select value - 'replayed' from exercise_test_state where key = 'duplicated_revision'),
  'duplicate-revision retry preserves result and correlation evidence'
);
select ok(
  (select (value ->> 'replayed')::boolean from exercise_test_state where key = 'duplicate_revision_replay'),
  'duplicate-revision retry is explicitly marked replayed'
);
select throws_ok(
  $$select public.duplicate_guidance_revision_as_draft_v1(
    (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
    (select (value ->> 'guidanceRevisionId')::uuid from exercise_test_state where key = 'published'),
    4,
    '94000000-0000-4000-8000-000000000062'
  )$$,
  '40001', 'stale_guidance_draft_revision',
  'duplicate revision rejects a stale current-draft revision'
);

select throws_ok(
  $$select public.update_exercise_v1(
    (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
    'Incline Bench Press', null, '["barbell"]',
    '[{"muscleId":"a3000000-0000-4000-8000-000000000001","role":"primary","position":1}]',
    1, false, '94000000-0000-4000-8000-000000000032'
  )$$,
  'P0001', 'published_exercise_identity_locked',
  'canonical identity cannot be redefined after first publication'
);
select throws_ok(
  $$select public.update_exercise_v1(
    (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
    'Bench Press', null, '["barbell"]',
    '[{"muscleId":"a3000000-0000-4000-8000-000000000001","role":"primary","position":1}]',
    0, false, '94000000-0000-4000-8000-000000000033'
  )$$,
  '40001', 'stale_exercise_revision',
  'stale exercise update is rejected before any child replacement'
);
do $capture_stale_exercise$
declare
  v_detail text;
  v_sqlstate text;
begin
  perform public.update_exercise_v1(
    (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
    'Bench Press', null, '["barbell"]',
    '[{"muscleId":"a3000000-0000-4000-8000-000000000001","role":"primary","position":1}]',
    0, false, '94000000-0000-4000-8000-000000000037'
  );
exception
  when others then
    get stacked diagnostics
      v_detail = pg_exception_detail,
      v_sqlstate = returned_sqlstate;
    insert into exercise_test_state (key, value)
    values (
      'stale_exercise_detail',
      jsonb_build_object('sqlstate', v_sqlstate, 'detail', v_detail::jsonb)
    );
end;
$capture_stale_exercise$;
select ok(
  (select value ->> 'sqlstate' = '40001'
     and value -> 'detail' ?& array['correlationId', 'exerciseRevision']
     and value -> 'detail' ->> 'exerciseRevision' = '1'
     and value -> 'detail' ->> 'correlationId' ~* '^[0-9a-f-]{36}$'
     and not (value -> 'detail' ? 'draftRevision')
   from exercise_test_state where key = 'stale_exercise_detail'),
  'stale exercise DETAIL exposes safe current revision and correlation evidence'
);
select isnt(
  (select value -> 'detail' ->> 'correlationId'
   from exercise_test_state where key = 'stale_draft_detail'),
  (select value -> 'detail' ->> 'correlationId'
   from exercise_test_state where key = 'stale_exercise_detail'),
  'independent stale exceptions receive fresh correlation identifiers'
);

insert into exercise_test_state (key, value)
select 'updated', public.update_exercise_v1(
  (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
  'Bench Press', null, '["barbell"]',
  '[
    {"muscleId":"a3000000-0000-4000-8000-000000000001","role":"primary","position":1},
    {"muscleId":"a3000000-0000-4000-8000-000000000003","role":"secondary","position":1}
  ]',
  1, true, '94000000-0000-4000-8000-000000000034'
);
select is(
  (select value ->> 'exerciseRevision' from exercise_test_state where key = 'updated'),
  '2',
  'content-only muscle reassignment advances the exercise revision'
);
insert into exercise_test_state (key, value)
select 'archived', public.set_exercise_archived_v1(
  (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
  true, 2, '94000000-0000-4000-8000-000000000035'
);
insert into exercise_test_state (key, value)
select 'unarchived', public.set_exercise_archived_v1(
  (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
  false, 3, '94000000-0000-4000-8000-000000000036'
);
select is(
  (select value ->> 'exerciseRevision' from exercise_test_state where key = 'unarchived'),
  '4',
  'archive and restore are reversible optimistic mutations'
);

insert into exercise_test_state (key, value)
select 'cloned', public.clone_exercise_v1(
    (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
    'Bench Press Copy', false, '94000000-0000-4000-8000-000000000040'
  );
select ok(
  (select value ->> 'exerciseId' from exercise_test_state where key = 'cloned') is not null,
  'owner can clone a readable owned exercise'
);
select is(
  (select count(*) from public.exercise_definitions
   where cloned_from_exercise_id =
     (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created')),
  1::bigint,
  'clone records immutable source provenance'
);

insert into exercise_test_state (key, value)
select 'save_replay', public.save_guidance_draft_v1(
  (select (value ->> 'draftId')::uuid from exercise_test_state where key = 'created'),
  '{
    "shortExplanation":"Press safely.",
    "setupSteps":["Lie back."],
    "executionSteps":["Press up."],
    "techniqueCues":["Brace."],
    "commonMistakes":["Flaring elbows."],
    "safetyNotes":["Use a spotter."]
  }',
  1,
  '94000000-0000-4000-8000-000000000020'
);
insert into exercise_test_state (key, value)
select 'update_replay', public.update_exercise_v1(
  (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
  'Bench Press', null, '["barbell"]',
  '[
    {"muscleId":"a3000000-0000-4000-8000-000000000001","role":"primary","position":1},
    {"muscleId":"a3000000-0000-4000-8000-000000000003","role":"secondary","position":1}
  ]',
  1, true, '94000000-0000-4000-8000-000000000034'
);
insert into exercise_test_state (key, value)
select 'archive_replay', public.set_exercise_archived_v1(
  (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
  true, 2, '94000000-0000-4000-8000-000000000035'
);
insert into exercise_test_state (key, value)
select 'unarchive_replay', public.set_exercise_archived_v1(
  (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
  false, 3, '94000000-0000-4000-8000-000000000036'
);
insert into exercise_test_state (key, value)
select 'clone_replay', public.clone_exercise_v1(
  (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
  'Bench Press Copy', false, '94000000-0000-4000-8000-000000000040'
);
select is(
  (
    select count(*)
    from (values
      ('save_replay', 'saved'),
      ('update_replay', 'updated'),
      ('archive_replay', 'archived'),
      ('unarchive_replay', 'unarchived'),
      ('clone_replay', 'cloned')
    ) as replay(replay_key, original_key)
    join exercise_test_state as replayed on replayed.key = replay.replay_key
    join exercise_test_state as original on original.key = replay.original_key
    where not (replayed.value ->> 'replayed')::boolean
       or replayed.value - 'replayed' <> original.value - 'replayed'
  ),
  0::bigint,
  'save, update, archive, unarchive and clone retries preserve correlation evidence and report replayed true'
);
select is(
  (public.list_exercises_v1(
    null, 'all', 'all', array[]::text[], array[]::text[], 'name_asc', 1, 1
  ) ->> 'total')::bigint,
  3::bigint,
  'bounded owner list returns exact total independently of page size'
);
select is(
  jsonb_array_length(public.list_exercises_v1(
    null, 'all', 'all', array[]::text[], array[]::text[], 'name_asc', 1, 1
  ) -> 'items'),
  1,
  'bounded owner list returns only the requested page size'
);
select is(
  (public.list_exercises_v1(
    null, 'all', 'published', array[]::text[], array[]::text[], 'publication_desc', 1, 50
  ) ->> 'total')::bigint,
  1::bigint,
  'publication filter is applied before exact total and pagination'
);
select is(
  (public.list_exercises_v1(
    'copy', 'active', 'all', array['barbell'],
    array['anterior_deltoids'],
    'updated_desc', 1, 50
  ) ->> 'total')::bigint,
  1::bigint,
  'search, archive, equipment and muscle filters compose server-side'
);
select is(
  (public.list_exercises_v1(
    null, 'all', 'all', array[]::text[],
    array['chest', 'anterior_deltoids'], 'name_asc', 1, 50
  ) ->> 'total')::bigint,
  2::bigint,
  'plural muscle filter requires every selected stable key'
);
select is(
  (public.list_exercises_v1(
    null, 'all', 'all', array['barbell', 'bench'],
    array[]::text[], 'name_asc', 1, 50
  ) ->> 'total')::bigint,
  0::bigint,
  'plural equipment filter requires every selected stable key'
);
select ok(
  ((public.list_exercises_v1(
    'copy', 'all', 'all', array[]::text[], array[]::text[], 'name_asc', 1, 50
  ) -> 'items' -> 0) ?& array[
    'createdAt', 'clonedFromExerciseId', 'latestGuidanceRevisionId',
    'latestGuidanceVersion', 'published'
  ]),
  'camelCase list summary carries creation, clone and publication evidence'
);
select throws_ok(
  $$select public.list_exercises_v1(
    null, 'all', 'all', array[]::text[], array[]::text[], 'name_asc', 1, 101
  )$$,
  '22023', 'invalid_exercise_list_request',
  'bounded list rejects page sizes over one hundred'
);

reset role;

select is(
  (
    select count(*)
    from exercise_test_state
    where key in (
      'created', 'saved', 'published', 'no_change_publish', 'modified_after_publish',
      'duplicated_revision', 'updated', 'archived', 'unarchived', 'cloned'
    )
      and (
        value ->> 'correlationId' is null
        or (value ->> 'replayed')::boolean
      )
  ),
  0::bigint,
  'every first retryable mutation result carries correlation evidence and replayed false'
);
select results_eq(
  $$
    select distinct operation_name
    from private.guidance_mutation_operations
    order by operation_name
  $$,
  $$values
    ('clone_exercise_v1'::text),
    ('create_exercise_v1'::text),
    ('duplicate_guidance_revision_as_draft_v1'::text),
    ('publish_guidance_revision_v1'::text),
    ('save_guidance_draft_v1'::text),
    ('set_exercise_archived_v1'::text),
    ('update_exercise_v1'::text)
  $$,
  'every retryable mutation family stores durable safe replay evidence'
);

select throws_ok(
  $$update public.guidance_revisions set version_number = 99$$,
  '42501', 'immutable_product_record',
  'even privileged ordinary updates cannot mutate published revisions'
);
select throws_ok(
  $$delete from public.guidance_revision_muscles$$,
  '42501', 'immutable_product_record',
  'even privileged ordinary deletes cannot remove pinned muscle evidence'
);
select throws_ok(
  $$delete from public.muscles where stable_key = 'chest'$$,
  '42501', 'immutable_product_record',
  'fixed taxonomy rows reject ordinary deletion'
);
select ok(
  not exists (
    select 1 from private.guidance_mutation_operations
    where result::text like '%Press safely.%'
  ),
  'durable mutation replay never stores complete guidance text'
);
select ok(
  position(
    'pg_advisory_xact_lock' in
    pg_get_functiondef('private.load_mutation_result(uuid,text,uuid,text)'::regprocedure)
  ) > 0,
  'idempotency replay serializes concurrent use of the same key'
);
select ok(
  position(
    'stone_set_exercise_duplicate:' in
    pg_get_functiondef('private.create_exercise_v1(text,text,jsonb,jsonb,boolean,uuid)'::regprocedure)
  ) > 0,
  'duplicate detection is serialized per owner'
);
select isnt(
  private.sha256_jsonb(jsonb_build_array('a', jsonb_build_array('first', 'second'))),
  private.sha256_jsonb(jsonb_build_array('a', jsonb_build_array('second', 'first'))),
  'canonical hashing treats ordered arrays as semantically significant'
);
select is(
  private.normalize_exercise_name(U&' E\0301lite\00A0 Press '),
  U&'\00E9lite press',
  'server NFC and explicit Unicode whitespace normalization matches the Dart contract'
);
select is(
  private.normalize_guidance_string(E'Tabs\tstay'),
  E'Tabs\tstay',
  'tab is preserved while disallowed control characters remain rejected'
);
select is(
  private.sha256_jsonb(jsonb_build_array(
    'stone-set-guidance-content-v1',
    U&'\00E9lite press',
    null,
    jsonb_build_array('dumbbell', 'bench'),
    jsonb_build_array('chest'),
    jsonb_build_array(),
    E'Line 1\nLine 2',
    jsonb_build_array('Brace'),
    jsonb_build_array('Press "up"'),
    jsonb_build_array(),
    jsonb_build_array(),
    jsonb_build_array()
  )),
  '932f2beb29b193d000915b6be781f527c8b1d1eabc9fa5f2c14ee8089ff704f4',
  'SQL canonical content hashing matches the literal shared Dart golden vector'
);
select is(
  private.sha256_jsonb(jsonb_build_array(
    'stone-set-guidance-revision-v1',
    '11111111-1111-4111-8111-111111111111',
    '22222222-2222-4222-8222-222222222222',
    3,
    '932f2beb29b193d000915b6be781f527c8b1d1eabc9fa5f2c14ee8089ff704f4',
    null
  )),
  '91e6a2615d09fe1cea9060d03fbb74a547558edc2122bab7f9850a1d824750d1',
  'SQL canonical revision hashing matches the literal shared Dart golden vector'
);

do $$
begin
  perform set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', '92000000-0000-4000-8000-000000000002',
      'role', 'authenticated',
      'session_id', '93000000-0000-4000-8000-000000000002',
      'is_anonymous', false
    )::text,
    true
  );
end;
$$;
set local role authenticated;
select is((select count(*) from public.exercise_definitions), 0::bigint, 'cross-user exercise reads are denied');
select is((select count(*) from public.guidance_drafts), 0::bigint, 'cross-user draft reads are denied');
select is((select count(*) from public.guidance_revisions), 0::bigint, 'cross-user revision reads are denied');
select is(
  (public.list_exercises_v1(
    null, 'all', 'all', array[]::text[], array[]::text[], 'name_asc', 1, 100
  ) ->> 'total')::bigint,
  0::bigint,
  'bounded list returns no cross-user rows or count leakage'
);
select throws_ok(
  $$select public.clone_exercise_v1(
    (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
    'Stolen Copy', false, '94000000-0000-4000-8000-000000000041'
  )$$,
  'P0002', 'exercise_not_found',
  'cross-user clone is denied without revealing a readable source'
);
select throws_ok(
  $$select public.duplicate_guidance_revision_as_draft_v1(
    (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
    (select (value ->> 'guidanceRevisionId')::uuid from exercise_test_state where key = 'published'),
    5,
    '94000000-0000-4000-8000-000000000042'
  )$$,
  'P0002', 'guidance_revision_not_found',
  'cross-user revision duplication is denied without revealing a readable source'
);
reset role;

update public.profiles
set active = false
where id = '92000000-0000-4000-8000-000000000002';
set local role authenticated;
select is((select count(*) from public.muscles), 0::bigint, 'disabled profile cannot read taxonomy');
select throws_ok(
  $$select public.create_exercise_v1(
    'Disabled', null, '["none"]',
    '[{"muscleId":"a3000000-0000-4000-8000-000000000001","role":"primary","position":1}]',
    false, '94000000-0000-4000-8000-000000000050'
  )$$,
  '42501', 'product_identity_not_authorized',
  'disabled profile cannot call product mutations'
);
reset role;

update public.profiles
set must_change_password = true
where id = '91000000-0000-4000-8000-000000000001';
do $$
begin
  perform set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', '91000000-0000-4000-8000-000000000001',
      'role', 'authenticated',
      'session_id', '93000000-0000-4000-8000-000000000001',
      'is_anonymous', false
    )::text,
    true
  );
end;
$$;
set local role authenticated;
select is((select count(*) from public.exercise_definitions), 0::bigint, 'password-change-required session cannot read products');
select throws_ok(
  $$select public.set_exercise_archived_v1(
    (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
    true, 1, '94000000-0000-4000-8000-000000000051'
  )$$,
  '42501', 'product_identity_not_authorized',
  'password-change-required session cannot mutate products'
);
reset role;

update public.profiles
set must_change_password = false
where id = '91000000-0000-4000-8000-000000000001';
insert into private.revoked_auth_sessions (session_id, user_id, reason_code)
values (
  '93000000-0000-4000-8000-000000000001',
  '91000000-0000-4000-8000-000000000001',
  'exercise_test_revocation'
);
set local role authenticated;
select is((select count(*) from public.exercise_definitions), 0::bigint, 'selected revocation denies products despite residual JWT');
select throws_ok(
  $$select public.validate_guidance_draft_v1(
    (select (value ->> 'exerciseId')::uuid from exercise_test_state where key = 'created'),
    (select (value ->> 'draftId')::uuid from exercise_test_state where key = 'created'),
    1, 3
  )$$,
  '42501', 'product_identity_not_authorized',
  'selected revocation denies validation RPC despite residual JWT'
);
reset role;

delete from private.revoked_auth_sessions
where session_id = '93000000-0000-4000-8000-000000000001';
insert into private.account_security_state (user_id, sessions_revoked_before)
values (
  '91000000-0000-4000-8000-000000000001',
  clock_timestamp()
)
on conflict (user_id) do update
set sessions_revoked_before = excluded.sessions_revoked_before;
set local role authenticated;
select is(
  (select count(*) from public.exercise_definitions),
  0::bigint,
  'global revocation cutoff denies product rows despite a residual JWT'
);
select throws_ok(
  $$select public.list_exercises_v1()$$,
  '42501', 'product_identity_not_authorized',
  'global revocation cutoff denies bounded read RPC despite a residual JWT'
);
reset role;

select * from finish();
rollback;
