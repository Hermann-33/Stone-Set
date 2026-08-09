begin;
select no_plan();

create temporary table media_test_state (
  key text primary key,
  value jsonb not null
) on commit drop;
grant select, insert, update on table media_test_state to authenticated;

insert into auth.users (
  instance_id, id, aud, role, email, email_confirmed_at, created_at, updated_at
) values
  (
    '00000000-0000-0000-0000-000000000000',
    'a1000000-0000-4000-8000-000000000001',
    'authenticated', 'authenticated', 'media-alpha@local.stone-set.invalid',
    clock_timestamp(), clock_timestamp(), clock_timestamp()
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    'a2000000-0000-4000-8000-000000000002',
    'authenticated', 'authenticated', 'media-bravo@local.stone-set.invalid',
    clock_timestamp(), clock_timestamp(), clock_timestamp()
  );

insert into public.profiles (
  id, normalized_username, public_display_name, active, must_change_password, reward_timezone
) values
  ('a1000000-0000-4000-8000-000000000001', 'media_alpha', 'Media Alpha', true, false, 'UTC'),
  ('a2000000-0000-4000-8000-000000000002', 'media_bravo', 'Media Bravo', true, false, 'UTC');

insert into auth.sessions (id, user_id, created_at, updated_at) values
  (
    'a3000000-0000-4000-8000-000000000001',
    'a1000000-0000-4000-8000-000000000001',
    clock_timestamp(), clock_timestamp()
  ),
  (
    'a3000000-0000-4000-8000-000000000002',
    'a2000000-0000-4000-8000-000000000002',
    clock_timestamp(), clock_timestamp()
  );

set local role anon;
select throws_ok(
  $$select count(*) from public.guidance_media_assets$$,
  '42501', null,
  'anon has object-level media metadata denial'
);
select throws_ok(
  $$select public.create_guidance_media_upload_intent_v1(
    gen_random_uuid(), gen_random_uuid(), 'image/png', 'png', 1, 1, gen_random_uuid()
  )$$,
  '42501', null,
  'anon has function-level upload-intent denial'
);
reset role;

do $$
begin
  perform set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', 'a1000000-0000-4000-8000-000000000001',
      'role', 'authenticated',
      'session_id', 'a3000000-0000-4000-8000-000000000001',
      'is_anonymous', false
    )::text,
    true
  );
end;
$$;
set local role authenticated;

insert into media_test_state (key, value)
select 'exercise', public.create_exercise_v1(
  'Media Bench Press', null, '["none"]'::jsonb,
  jsonb_build_array(
    jsonb_build_object(
      'muscleId', (select id::text from public.muscles order by stable_key limit 1),
      'role', 'primary',
      'position', 1
    )
  ),
  false, 'b1000000-0000-4000-8000-000000000001'
);

insert into media_test_state (key, value)
select 'guidance', public.save_guidance_draft_v1(
  (select (value ->> 'draftId')::uuid from media_test_state where key = 'exercise'),
  '{
    "shortExplanation":"Controlled media guidance.",
    "setupSteps":["Set up safely"],
    "executionSteps":["Move with control"],
    "techniqueCues":[],
    "commonMistakes":[],
    "safetyNotes":[]
  }'::jsonb,
  1,
  'b1000000-0000-4000-8000-000000000002'
);

insert into media_test_state (key, value)
select 'intent', public.create_guidance_media_upload_intent_v1(
  (select (value ->> 'exerciseId')::uuid from media_test_state where key = 'exercise'),
  (select (value ->> 'draftId')::uuid from media_test_state where key = 'exercise'),
  'image/png', '.PNG', 2, 1,
  'b1000000-0000-4000-8000-000000000003'
);

select ok(
  (select value ->> 'objectPath' like 'a1000000-0000-4000-8000-000000000001/%/drafts/%/%.png'
   from media_test_state where key = 'intent')
  and (select value ->> 'bucketId' = 'exercise-media' from media_test_state where key = 'intent')
  and (select (value ->> 'mediaRevision')::bigint = 2 from media_test_state where key = 'intent'),
  'owner receives an exact immutable pending path and advanced media revision'
);

select is(
  jsonb_array_length(
    public.get_guidance_draft_media_manifest_v1(
      (select (value ->> 'exerciseId')::uuid from media_test_state where key = 'exercise'),
      (select (value ->> 'draftId')::uuid from media_test_state where key = 'exercise')
    ) -> 'images'
  ),
  0,
  'an unfinished upload intent is not misrepresented as a finalized draft image'
);

do $capture_stale_media$
declare
  v_detail text;
  v_sqlstate text;
begin
  perform public.create_guidance_media_upload_intent_v1(
    (select (value ->> 'exerciseId')::uuid from media_test_state where key = 'exercise'),
    (select (value ->> 'draftId')::uuid from media_test_state where key = 'exercise'),
    'image/png', 'png', 2, 1,
    'b1000000-0000-4000-8000-000000000004'
  );
exception when others then
  get stacked diagnostics v_detail = pg_exception_detail, v_sqlstate = returned_sqlstate;
  insert into media_test_state (key, value) values (
    'stale', jsonb_build_object('sqlstate', v_sqlstate, 'detail', v_detail::jsonb)
  );
end;
$capture_stale_media$;

select ok(
  (select value ->> 'sqlstate' = '40001'
     and value -> 'detail' ?& array['correlationId', 'exerciseRevision', 'draftRevision', 'mediaRevision']
     and value -> 'detail' ->> 'draftRevision' = '2'
     and value -> 'detail' ->> 'mediaRevision' = '2'
     and value -> 'detail' ->> 'correlationId' ~* '^[0-9a-f-]{36}$'
     and value::text not like '%Controlled media guidance.%'
   from media_test_state where key = 'stale'),
  'stale media DETAIL exposes only safe camelCase revisions and fresh correlation evidence'
);

insert into storage.objects (bucket_id, name, owner_id, metadata)
select
  'exercise-media',
  value ->> 'objectPath',
  'a1000000-0000-4000-8000-000000000001',
  '{"size":1024,"mimetype":"image/png"}'::jsonb
from media_test_state where key = 'intent';

insert into media_test_state (key, value)
select 'finalized', public.finalize_guidance_media_upload_v1(
  (select (value ->> 'intentId')::uuid from media_test_state where key = 'intent'),
  1024, 640, 480, repeat('a', 64), 2,
  'b1000000-0000-4000-8000-000000000005'
);

select is(
  (select value ->> 'state' from media_test_state where key = 'finalized'),
  'ready',
  'finalize accepts matching Storage metadata and marks the draft asset ready'
);

select is(
  jsonb_array_length(
    public.get_guidance_draft_media_manifest_v1(
      (select (value ->> 'exerciseId')::uuid from media_test_state where key = 'exercise'),
      (select (value ->> 'draftId')::uuid from media_test_state where key = 'exercise')
    ) -> 'images'
  ),
  1,
  'a finalized upload becomes visible in the draft media manifest'
);

insert into media_test_state (key, value)
select 'layout', public.save_guidance_media_layout_v1(
  (select (value ->> 'draftId')::uuid from media_test_state where key = 'exercise'),
  jsonb_build_array(jsonb_build_object(
    'assetId', (select value ->> 'assetId' from media_test_state where key = 'intent'),
    'altText', 'Athlete demonstrating the setup',
    'position', 0,
    'isCover', true
  )),
  3,
  'b1000000-0000-4000-8000-000000000006'
);

insert into media_test_state (key, value)
select 'youtube', public.save_guidance_youtube_reference_v1(
  (select (value ->> 'draftId')::uuid from media_test_state where key = 'exercise'),
  'dQw4w9WgXcQ',
  'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
  30,
  null,
  'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
  clock_timestamp(),
  4,
  'b1000000-0000-4000-8000-000000000007'
);

insert into media_test_state (key, value)
select 'reservation', public.begin_guidance_media_publication_v1(
  (select (value ->> 'exerciseId')::uuid from media_test_state where key = 'exercise'),
  (select (value ->> 'draftId')::uuid from media_test_state where key = 'exercise'),
  1, 2, 5,
  'b1000000-0000-4000-8000-000000000008'
);

select ok(
  (select jsonb_array_length(value -> 'copies') = 1
     and not (value ->> 'noChange')::boolean
     and value ->> 'manifestHash' ~ '^[0-9a-f]{64}$'
     and value ->> 'bundleHash' ~ '^[0-9a-f]{64}$'
   from media_test_state where key = 'reservation'),
  'begin publication reserves one exact copy and deterministic hash evidence'
);

insert into storage.objects (bucket_id, name, owner_id, metadata)
select
  'exercise-media',
  copy ->> 'destinationPath',
  'a1000000-0000-4000-8000-000000000001',
  '{"size":1024,"mimetype":"image/png"}'::jsonb
from media_test_state,
lateral jsonb_array_elements(value -> 'copies') as copy
where key = 'reservation';

insert into media_test_state (key, value)
select 'published', public.finalize_guidance_media_publication_v1(
  (select (value ->> 'reservationId')::uuid from media_test_state where key = 'reservation'),
  'b1000000-0000-4000-8000-000000000009'
);

select ok(
  (select value ->> 'guidanceRevisionId' ~* '^[0-9a-f-]{36}$'
     and value ->> 'manifestHash' ~ '^[0-9a-f]{64}$'
     and value ->> 'bundleHash' ~ '^[0-9a-f]{64}$'
     and not (value ->> 'noChange')::boolean
   from media_test_state where key = 'published'),
  'final publication returns immutable revision and media/bundle hash evidence'
);
select is(
  (select count(*) from public.guidance_media_assets where state = 'published'),
  1::bigint,
  'owner reads one immutable published media row'
);
select is(
  (select count(*) from public.guidance_media_manifests),
  1::bigint,
  'publication persists exactly one versioned media manifest'
);
select is(
  (select count(*) from public.guidance_youtube_references where guidance_revision_id is not null),
  1::bigint,
  'publication pins one immutable YouTube reference'
);
select is(
  (
    select source_reference_id
    from public.guidance_youtube_references
    where guidance_revision_id is not null
  ),
  null::uuid,
  'publication never pins immutable history to a mutable draft reference'
);

insert into media_test_state (key, value)
select 'duplicated', public.duplicate_guidance_revision_with_media_as_draft_v1(
  (select (value ->> 'exerciseId')::uuid from media_test_state where key = 'exercise'),
  (select (value ->> 'guidanceRevisionId')::uuid from media_test_state where key = 'published'),
  3, 5,
  'b1000000-0000-4000-8000-000000000010'
);
select ok(
  (select (value ->> 'imageCount')::integer = 1
     and (value ->> 'youtubeCopied')::boolean
     and (value ->> 'reusedPublishedObjects')::boolean
     and (value ->> 'mediaRevision')::bigint = 6
   from media_test_state where key = 'duplicated'),
  'media-aware duplicate copies owned immutable metadata without copying bytes'
);
select is(
  (
    select count(*) from public.guidance_media_assets as draft_asset
    join public.guidance_media_assets as published
      on published.id = draft_asset.source_asset_id
     and published.object_path = draft_asset.object_path
    where draft_asset.guidance_draft_id is not null
      and draft_asset.state = 'ready'
      and published.state = 'published'
  ),
  1::bigint,
  'duplicated draft safely references one owned immutable published object'
);

insert into media_test_state (key, value)
select 'relayout_clone', public.save_guidance_media_layout_v1(
  (select (value ->> 'draftId')::uuid from media_test_state where key = 'exercise'),
  jsonb_build_array(jsonb_build_object(
    'assetId', (select id from public.guidance_media_assets
                where guidance_draft_id is not null and state = 'ready'),
    'altText', 'Updated reuse of the published setup image',
    'position', 0,
    'isCover', true
  )),
  6,
  'b1000000-0000-4000-8000-000000000013'
);

insert into media_test_state (key, value)
select 'republish_reservation', public.begin_guidance_media_publication_v1(
  (select (value ->> 'exerciseId')::uuid from media_test_state where key = 'exercise'),
  (select (value ->> 'draftId')::uuid from media_test_state where key = 'exercise'),
  1, 3, 7,
  'b1000000-0000-4000-8000-000000000011'
);
select ok(
  (
    select copy ->> 'sourcePath' = published.object_path
      and copy ->> 'destinationPath' <> published.object_path
    from media_test_state,
    lateral jsonb_array_elements(value -> 'copies') as copy,
    lateral (
      select object_path from public.guidance_media_assets
      where state = 'published' limit 1
    ) as published
    where key = 'republish_reservation'
  ),
  'next publication can copy the immutable published source to a new revision path'
);

insert into media_test_state (key, value)
select 'removed_clone', public.remove_guidance_media_asset_v1(
  (select (value ->> 'draftId')::uuid from media_test_state where key = 'exercise'),
  (select id from public.guidance_media_assets
   where guidance_draft_id = (select (value ->> 'draftId')::uuid
                              from media_test_state where key = 'exercise')
     and state = 'ready'),
  7,
  'b1000000-0000-4000-8000-000000000012'
);
select ok(
  (select not (value ->> 'requiresStorageDelete')::boolean
   from media_test_state where key = 'removed_clone'),
  'removing cloned draft metadata never authorizes deletion of published source bytes'
);
select is(
  (select count(*) from storage.objects where bucket_id = 'exercise-media'),
  0::bigint,
  'ordinary SQL/object-list enumeration is denied despite authorized object downloads'
);
select throws_ok(
  $$delete from storage.objects
    where name = (
      select object_path from public.guidance_media_assets
      where state = 'published' limit 1
    )$$,
  'P0001', null,
  'direct SQL cannot bypass the Storage API deletion boundary'
);
reset role;
select is(
  (select count(*) from storage.objects as object
   join public.guidance_media_assets as asset on asset.object_path = object.name
   where asset.state = 'published'
     and asset.user_id = 'a1000000-0000-4000-8000-000000000001'),
  1::bigint,
  'published Storage bytes and immutable history remain after cloned draft removal'
);
select is(
  (select count(*) from private.claim_expired_guidance_media_cleanup_v1(100)),
  0::bigint,
  'cleanup never claims a cloned path that immutable published metadata references'
);
set local role authenticated;
select ok(
  (select (public.duplicate_guidance_revision_with_media_as_draft_v1(
    (select (value ->> 'exerciseId')::uuid from media_test_state where key = 'exercise'),
    (select (value ->> 'guidanceRevisionId')::uuid from media_test_state where key = 'published'),
    3, 5,
    'b1000000-0000-4000-8000-000000000010'
  ) ->> 'replayed')::boolean),
  'media-aware duplicate replay returns its original result despite later draft changes'
);

select throws_ok(
  $$update public.guidance_media_assets set alt_text = 'forged' where state = 'published'$$,
  '42501', null,
  'authenticated cannot directly mutate published media metadata'
);
select throws_ok(
  $$delete from public.guidance_media_manifests$$,
  '42501', null,
  'authenticated cannot directly delete immutable manifests'
);
select is(
  (with changed as (
     update storage.objects set metadata = '{"size":1}'::jsonb
     where bucket_id = 'exercise-media' returning 1
   ) select count(*) from changed),
  0::bigint,
  'Storage UPDATE/upsert has no policy path'
);

reset role;
do $$
begin
  perform set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', 'a2000000-0000-4000-8000-000000000002',
      'role', 'authenticated',
      'session_id', 'a3000000-0000-4000-8000-000000000002',
      'is_anonymous', false
    )::text,
    true
  );
end;
$$;
set local role authenticated;

select is((select count(*) from public.guidance_media_assets), 0::bigint, 'cross-user media rows are denied');
select is((select count(*) from public.guidance_youtube_references), 0::bigint, 'cross-user YouTube rows are denied');
select is((select count(*) from public.guidance_media_manifests), 0::bigint, 'cross-user manifests are denied');
select throws_ok(
  $$insert into storage.objects (bucket_id, name, owner_id, metadata) values (
    'exercise-media',
    'a1000000-0000-4000-8000-000000000001/forged.png',
    'a2000000-0000-4000-8000-000000000002',
    '{"size":4,"mimetype":"image/png"}'::jsonb
  )$$,
  '42501', null,
  'cross-user caller cannot forge an object into another owner path'
);
select throws_ok(
  $$select public.duplicate_guidance_revision_with_media_as_draft_v1(
    (select (value ->> 'exerciseId')::uuid from media_test_state where key = 'exercise'),
    (select (value ->> 'guidanceRevisionId')::uuid from media_test_state where key = 'published'),
    3, 8, gen_random_uuid()
  )$$,
  'P0002', 'guidance_revision_not_found',
  'cross-user caller cannot duplicate another owner media history'
);

reset role;
do $$
begin
  perform set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', 'a1000000-0000-4000-8000-000000000001',
      'role', 'authenticated',
      'session_id', 'a3000000-0000-4000-8000-000000000099',
      'is_anonymous', false
    )::text,
    true
  );
end;
$$;
set local role authenticated;
select throws_ok(
  $$select public.get_guidance_revision_media_manifest_v1(
    (select (value ->> 'exerciseId')::uuid from media_test_state where key = 'exercise'),
    (select (value ->> 'guidanceRevisionId')::uuid from media_test_state where key = 'published')
  )$$,
  '42501', 'product_identity_not_authorized',
  'missing/revoked session evidence denies the media read RPC'
);
select is((select count(*) from public.guidance_media_assets), 0::bigint, 'missing session evidence denies row reads');

select * from finish();
rollback;
