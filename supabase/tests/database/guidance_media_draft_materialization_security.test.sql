begin;
select no_plan();

create temporary table materialization_test_state (
  key text primary key,
  value jsonb not null
) on commit drop;
grant select, insert, update on table materialization_test_state to authenticated;

insert into auth.users (
  instance_id, id, aud, role, email, email_confirmed_at, created_at, updated_at
) values
  (
    '00000000-0000-0000-0000-000000000000',
    'c1000000-0000-4000-8000-000000000001',
    'authenticated', 'authenticated', 'materialize-alpha@local.stone-set.invalid',
    clock_timestamp(), clock_timestamp(), clock_timestamp()
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    'c2000000-0000-4000-8000-000000000002',
    'authenticated', 'authenticated', 'materialize-bravo@local.stone-set.invalid',
    clock_timestamp(), clock_timestamp(), clock_timestamp()
  );

insert into public.profiles (
  id, normalized_username, public_display_name, active, must_change_password, reward_timezone
) values
  ('c1000000-0000-4000-8000-000000000001', 'materialize_alpha', 'Materialize Alpha', true, false, 'UTC'),
  ('c2000000-0000-4000-8000-000000000002', 'materialize_bravo', 'Materialize Bravo', true, false, 'UTC');

insert into auth.sessions (id, user_id, created_at, updated_at) values
  (
    'c3000000-0000-4000-8000-000000000001',
    'c1000000-0000-4000-8000-000000000001',
    clock_timestamp(), clock_timestamp()
  ),
  (
    'c3000000-0000-4000-8000-000000000002',
    'c2000000-0000-4000-8000-000000000002',
    clock_timestamp(), clock_timestamp()
  );

insert into public.exercise_definitions (
  id, user_id, canonical_name, normalized_name, revision
) values
  (
    'c4000000-0000-4000-8000-000000000001',
    'c1000000-0000-4000-8000-000000000001',
    'Materialized Press', 'materialized press', 4
  ),
  (
    'c4000000-0000-4000-8000-000000000002',
    'c1000000-0000-4000-8000-000000000001',
    'Text Only Press', 'text only press', 2
  ),
  (
    'c4000000-0000-4000-8000-000000000003',
    'c1000000-0000-4000-8000-000000000001',
    'Archived Press', 'archived press', 3
  );

update public.exercise_definitions
set archived_at = clock_timestamp()
where id = 'c4000000-0000-4000-8000-000000000003';

insert into public.guidance_revisions (
  id, exercise_id, user_id, version_number,
  structured_content_schema_version, structured_content,
  canonical_name_snapshot, normalized_name_snapshot,
  equipment_keys_snapshot, content_hash, revision_hash
) values
  (
    'c5000000-0000-4000-8000-000000000001',
    'c4000000-0000-4000-8000-000000000001',
    'c1000000-0000-4000-8000-000000000001',
    1, 1,
    '{"shortExplanation":"Published source text.","setupSteps":["Brace"],"executionSteps":["Press"],"techniqueCues":[],"commonMistakes":[],"safetyNotes":[]}'::jsonb,
    'Materialized Press', 'materialized press', '[]'::jsonb,
    repeat('1', 64), repeat('2', 64)
  ),
  (
    'c5000000-0000-4000-8000-000000000002',
    'c4000000-0000-4000-8000-000000000002',
    'c1000000-0000-4000-8000-000000000001',
    1, 1,
    '{"shortExplanation":"Text only source.","setupSteps":["Brace"],"executionSteps":["Press"],"techniqueCues":[],"commonMistakes":[],"safetyNotes":[]}'::jsonb,
    'Text Only Press', 'text only press', '[]'::jsonb,
    repeat('3', 64), repeat('4', 64)
  ),
  (
    'c5000000-0000-4000-8000-000000000003',
    'c4000000-0000-4000-8000-000000000003',
    'c1000000-0000-4000-8000-000000000001',
    1, 1,
    '{"shortExplanation":"Archived source.","setupSteps":["Brace"],"executionSteps":["Press"],"techniqueCues":[],"commonMistakes":[],"safetyNotes":[]}'::jsonb,
    'Archived Press', 'archived press', '[]'::jsonb,
    repeat('5', 64), repeat('6', 64)
  );

insert into storage.objects (bucket_id, name, owner_id, metadata) values (
  'exercise-media',
  'c1000000-0000-4000-8000-000000000001/c4000000-0000-4000-8000-000000000001/revisions/c5000000-0000-4000-8000-000000000001/source.png',
  'c1000000-0000-4000-8000-000000000001',
  '{"size":4096,"mimetype":"image/png"}'::jsonb
);

insert into public.guidance_media_assets (
  id, user_id, exercise_id, guidance_revision_id, bucket_id, object_path,
  mime_type, byte_size, width, height, sha256_hex, alt_text,
  position, is_cover, state, published_at
) values (
  'c6000000-0000-4000-8000-000000000001',
  'c1000000-0000-4000-8000-000000000001',
  'c4000000-0000-4000-8000-000000000001',
  'c5000000-0000-4000-8000-000000000001',
  'exercise-media',
  'c1000000-0000-4000-8000-000000000001/c4000000-0000-4000-8000-000000000001/revisions/c5000000-0000-4000-8000-000000000001/source.png',
  'image/png', 4096, 640, 640, repeat('7', 64),
  'Published setup position', 0, true, 'published', clock_timestamp()
);

insert into public.guidance_youtube_references (
  id, user_id, exercise_id, guidance_revision_id, provider,
  video_id, canonical_watch_url, start_seconds, title_snapshot,
  thumbnail_url_snapshot, validation_status, validated_at, published_at
) values (
  'c7000000-0000-4000-8000-000000000001',
  'c1000000-0000-4000-8000-000000000001',
  'c4000000-0000-4000-8000-000000000001',
  'c5000000-0000-4000-8000-000000000001',
  'youtube', 'dQw4w9WgXcQ',
  'https://www.youtube.com/watch?v=dQw4w9WgXcQ', 12,
  'Validated demonstration',
  'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
  'preview_succeeded', clock_timestamp(), clock_timestamp()
);

set local role anon;
select throws_ok(
  $$select public.create_guidance_media_draft_from_revision_v1(
    'c4000000-0000-4000-8000-000000000001',
    'c5000000-0000-4000-8000-000000000001', 4, gen_random_uuid()
  )$$,
  '42501', null,
  'anonymous callers have function-level denial'
);
reset role;

do $$
begin
  perform set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', 'c1000000-0000-4000-8000-000000000001',
      'role', 'authenticated',
      'session_id', 'c3000000-0000-4000-8000-000000000001',
      'is_anonymous', false
    )::text,
    true
  );
end;
$$;
set local role authenticated;

select throws_ok(
  $$select public.create_guidance_media_draft_from_revision_v1(
    'c4000000-0000-4000-8000-000000000001',
    'c5000000-0000-4000-8000-000000000001', 3, gen_random_uuid()
  )$$,
  '40001', 'stale_exercise_revision',
  'expected exercise revision is enforced before draft creation'
);

select throws_ok(
  $$select public.create_guidance_media_draft_from_revision_v1(
    'c4000000-0000-4000-8000-000000000001',
    'c5000000-0000-4000-8000-000000000099', 4, gen_random_uuid()
  )$$,
  'P0002', 'guidance_revision_not_found',
  'missing source revision returns a bounded not-found error'
);

insert into materialization_test_state (key, value)
select 'created', public.create_guidance_media_draft_from_revision_v1(
  'c4000000-0000-4000-8000-000000000001',
  'c5000000-0000-4000-8000-000000000001',
  4,
  'c8000000-0000-4000-8000-000000000001'
);

select ok(
  (
    select value ->> 'operation' = 'create_guidance_media_draft_from_revision_v1'
      and not (value ->> 'replayed')::boolean
      and value ->> 'correlationId' ~* '^[0-9a-f-]{36}$'
      and value ->> 'exerciseId' = 'c4000000-0000-4000-8000-000000000001'
      and value ->> 'sourceGuidanceRevisionId' = 'c5000000-0000-4000-8000-000000000001'
      and (value ->> 'exerciseRevision')::bigint = 4
      and (value ->> 'draftRevision')::bigint = 1
      and (value ->> 'mediaRevision')::bigint = 1
      and (value ->> 'imageCount')::integer = 1
      and (value ->> 'youtubeCopied')::boolean
      and (value ->> 'reusedPublishedObjects')::boolean
    from materialization_test_state where key = 'created'
  ),
  'owner receives bounded server-confirmed draft and provenance evidence'
);

select is(
  (
    select draft.structured_content
    from public.guidance_drafts as draft
    where draft.id = (
      select (value ->> 'draftId')::uuid
      from materialization_test_state where key = 'created'
    )
  ),
  (
    select revision.structured_content
    from public.guidance_revisions as revision
    where revision.id = 'c5000000-0000-4000-8000-000000000001'
  ),
  'structured guidance is copied exactly from the immutable source revision'
);

select ok(
  exists (
    select 1
    from public.guidance_media_assets as draft_asset
    join public.guidance_media_assets as source
      on source.id = draft_asset.source_asset_id
     and source.object_path = draft_asset.object_path
     and source.sha256_hex = draft_asset.sha256_hex
     and source.alt_text = draft_asset.alt_text
     and source.position = draft_asset.position
     and source.is_cover = draft_asset.is_cover
    where draft_asset.guidance_draft_id = (
      select (value ->> 'draftId')::uuid
      from materialization_test_state where key = 'created'
    )
      and draft_asset.state = 'ready'
      and source.state = 'published'
  ),
  'image metadata retains source provenance while reusing immutable published bytes'
);

select ok(
  exists (
    select 1
    from public.guidance_youtube_references as draft_reference
    join public.guidance_youtube_references as source
      on source.id = draft_reference.source_reference_id
     and source.video_id = draft_reference.video_id
     and source.canonical_watch_url = draft_reference.canonical_watch_url
     and source.validation_status = draft_reference.validation_status
     and source.validated_at = draft_reference.validated_at
    where draft_reference.guidance_draft_id = (
      select (value ->> 'draftId')::uuid
      from materialization_test_state where key = 'created'
    )
      and source.guidance_revision_id = 'c5000000-0000-4000-8000-000000000001'
  ),
  'YouTube validation evidence retains immutable source provenance'
);

insert into materialization_test_state (key, value)
select 'replayed', public.create_guidance_media_draft_from_revision_v1(
  'c4000000-0000-4000-8000-000000000001',
  'c5000000-0000-4000-8000-000000000001',
  4,
  'c8000000-0000-4000-8000-000000000001'
);

select ok(
  (
    select (replay.value ->> 'replayed')::boolean
      and replay.value ->> 'draftId' = created.value ->> 'draftId'
      and replay.value ->> 'correlationId' = created.value ->> 'correlationId'
    from materialization_test_state as replay
    cross join materialization_test_state as created
    where replay.key = 'replayed' and created.key = 'created'
  ) and (
    select count(*) = 1
    from public.guidance_drafts
    where exercise_id = 'c4000000-0000-4000-8000-000000000001'
  ),
  'same-key replay returns the original result and never creates a second draft'
);

select throws_ok(
  $$select public.create_guidance_media_draft_from_revision_v1(
    'c4000000-0000-4000-8000-000000000002',
    'c5000000-0000-4000-8000-000000000002', 2,
    'c8000000-0000-4000-8000-000000000001'
  )$$,
  '22023', 'idempotency_key_reused',
  'same owner cannot reuse an operation key for a different request'
);

do $capture_conflict$
declare
  v_message text;
  v_detail text;
begin
  begin
    perform public.create_guidance_media_draft_from_revision_v1(
      'c4000000-0000-4000-8000-000000000001',
      'c5000000-0000-4000-8000-000000000001',
      4,
      'c8000000-0000-4000-8000-000000000002'
    );
  exception when serialization_failure then
    get stacked diagnostics v_message = message_text, v_detail = pg_exception_detail;
    insert into materialization_test_state (key, value)
    values ('conflict', jsonb_build_object('message', v_message, 'detail', v_detail::jsonb));
  end;
end;
$capture_conflict$;

select ok(
  (
    select value ->> 'message' = 'guidance_media_draft_already_exists'
      and (value -> 'detail') ?& array[
        'correlationId', 'draftId', 'draftRevision', 'mediaRevision'
      ]
      and (select count(*) from jsonb_object_keys(value -> 'detail')) = 4
      and value -> 'detail' ->> 'draftId' = (
        select created.value ->> 'draftId'
        from materialization_test_state as created where created.key = 'created'
      )
      and (value -> 'detail' ->> 'draftRevision')::bigint = 1
      and (value -> 'detail' ->> 'mediaRevision')::bigint = 1
    from materialization_test_state where key = 'conflict'
  ),
  'different-key concurrent/existing creation returns safe deterministic conflict evidence'
);

insert into materialization_test_state (key, value)
select 'text_only', public.create_guidance_media_draft_from_revision_v1(
  'c4000000-0000-4000-8000-000000000002',
  'c5000000-0000-4000-8000-000000000002',
  2,
  'c8000000-0000-4000-8000-000000000003'
);

select ok(
  (
    select (value ->> 'imageCount')::integer = 0
      and not (value ->> 'youtubeCopied')::boolean
      and (value ->> 'mediaRevision')::bigint = 1
    from materialization_test_state where key = 'text_only'
  ),
  'text-only source produces a valid empty media draft without fabrication'
);

select throws_ok(
  $$select public.create_guidance_media_draft_from_revision_v1(
    'c4000000-0000-4000-8000-000000000003',
    'c5000000-0000-4000-8000-000000000003', 3, gen_random_uuid()
  )$$,
  '55000', 'archived_exercise_cannot_create_guidance_draft',
  'archived exercises cannot materialize a draft'
);

select throws_ok(
  $$select public.create_guidance_media_draft_from_revision_v1(
    'c4000000-0000-4000-8000-000000000003',
    'c5000000-0000-4000-8000-000000000003', 2, gen_random_uuid()
  )$$,
  '55000', 'archived_exercise_cannot_create_guidance_draft',
  'archived denial precedes revision evidence disclosure'
);

reset role;
do $$
begin
  perform set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', 'c2000000-0000-4000-8000-000000000002',
      'role', 'authenticated',
      'session_id', 'c3000000-0000-4000-8000-000000000002',
      'is_anonymous', false
    )::text,
    true
  );
end;
$$;
set local role authenticated;

select throws_ok(
  $$select public.create_guidance_media_draft_from_revision_v1(
    'c4000000-0000-4000-8000-000000000001',
    'c5000000-0000-4000-8000-000000000001', 4, gen_random_uuid()
  )$$,
  'P0002', 'exercise_not_found',
  'cross-user caller receives no source or ownership evidence'
);

reset role;
update public.profiles
set active = false
where id = 'c1000000-0000-4000-8000-000000000001';
do $$
begin
  perform set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', 'c1000000-0000-4000-8000-000000000001',
      'role', 'authenticated',
      'session_id', 'c3000000-0000-4000-8000-000000000001',
      'is_anonymous', false
    )::text,
    true
  );
end;
$$;
set local role authenticated;

select throws_ok(
  $$select public.create_guidance_media_draft_from_revision_v1(
    'c4000000-0000-4000-8000-000000000003',
    'c5000000-0000-4000-8000-000000000003', 3, gen_random_uuid()
  )$$,
  '42501', 'product_identity_not_authorized',
  'disabled profiles cannot materialize drafts'
);

reset role;
update public.profiles
set active = true, must_change_password = true
where id = 'c1000000-0000-4000-8000-000000000001';
set local role authenticated;

select throws_ok(
  $$select public.create_guidance_media_draft_from_revision_v1(
    'c4000000-0000-4000-8000-000000000003',
    'c5000000-0000-4000-8000-000000000003', 3, gen_random_uuid()
  )$$,
  '42501', 'product_identity_not_authorized',
  'password-change-required profiles cannot materialize drafts'
);

reset role;
update public.profiles
set must_change_password = false
where id = 'c1000000-0000-4000-8000-000000000001';
do $$
begin
  perform set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', 'c1000000-0000-4000-8000-000000000001',
      'role', 'authenticated',
      'session_id', 'c3000000-0000-4000-8000-000000000001',
      'is_anonymous', true
    )::text,
    true
  );
end;
$$;
set local role authenticated;

select throws_ok(
  $$select public.create_guidance_media_draft_from_revision_v1(
    'c4000000-0000-4000-8000-000000000003',
    'c5000000-0000-4000-8000-000000000003', 3, gen_random_uuid()
  )$$,
  '42501', 'product_identity_not_authorized',
  'authenticated-role anonymous identities cannot materialize drafts'
);

reset role;
do $$
begin
  perform set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', 'c1000000-0000-4000-8000-000000000001',
      'role', 'authenticated',
      'session_id', 'c3000000-0000-4000-8000-000000000001',
      'is_anonymous', false
    )::text,
    true
  );
end;
$$;
insert into private.revoked_auth_sessions (session_id, user_id, revoked_at, reason_code)
values (
  'c3000000-0000-4000-8000-000000000001',
  'c1000000-0000-4000-8000-000000000001',
  clock_timestamp(),
  'materialization_test'
);
set local role authenticated;

select throws_ok(
  $$select public.create_guidance_media_draft_from_revision_v1(
    'c4000000-0000-4000-8000-000000000003',
    'c5000000-0000-4000-8000-000000000003', 3, gen_random_uuid()
  )$$,
  '42501', 'product_identity_not_authorized',
  'revoked sessions cannot materialize drafts'
);

reset role;
select throws_ok(
  $$delete from public.guidance_media_assets
    where id = 'c6000000-0000-4000-8000-000000000001'$$,
  '55000', 'published_media_is_immutable',
  'source metadata remains immutable after draft materialization'
);
select is(
  (
    select count(*) from storage.objects
    where bucket_id = 'exercise-media'
      and name = 'c1000000-0000-4000-8000-000000000001/c4000000-0000-4000-8000-000000000001/revisions/c5000000-0000-4000-8000-000000000001/source.png'
  ),
  1::bigint,
  'materialization reuses and does not overwrite or copy the published object'
);

select * from finish();
rollback;
