begin;
select no_plan();

select has_table('public', 'guidance_media_draft_states', 'media draft revisions exist');
select has_table('public', 'guidance_media_assets', 'media asset metadata exists');
select has_table('public', 'guidance_youtube_references', 'YouTube references exist');
select has_table('public', 'guidance_media_manifests', 'immutable media manifests exist');
select has_table('private', 'media_upload_intents', 'private upload intents exist');
select has_table('private', 'media_publication_reservations', 'private publication reservations exist');
select has_table('private', 'media_publication_reservation_assets', 'reserved copy paths exist');

select col_is_pk('public', 'guidance_media_assets', 'id', 'media assets use UUID identity');
select col_is_pk('public', 'guidance_youtube_references', 'id', 'YouTube references use UUID identity');
select col_is_pk('public', 'guidance_media_manifests', 'guidance_revision_id', 'one manifest exists per revision');
select col_is_pk('private', 'media_upload_intents', 'id', 'upload intents use UUID identity');
select col_is_pk('private', 'media_publication_reservations', 'id', 'publication reservations use UUID identity');

select fk_ok(
  'public', 'guidance_media_assets', array['guidance_draft_id', 'exercise_id', 'user_id'],
  'public', 'guidance_drafts', array['id', 'exercise_id', 'user_id'],
  'draft media ownership follows its guidance draft'
);
select fk_ok(
  'public', 'guidance_media_assets', array['guidance_revision_id', 'exercise_id', 'user_id'],
  'public', 'guidance_revisions', array['id', 'exercise_id', 'user_id'],
  'published media ownership follows its guidance revision'
);
select fk_ok(
  'public', 'guidance_media_manifests', array['guidance_revision_id', 'exercise_id', 'user_id'],
  'public', 'guidance_revisions', array['id', 'exercise_id', 'user_id'],
  'manifest ownership follows its immutable guidance revision'
);

select has_index(
  'public', 'guidance_media_assets', 'guidance_media_assets_draft_idx',
  'draft owner/order lookup is indexed'
);
select has_index(
  'public', 'guidance_media_assets', 'guidance_media_assets_revision_idx',
  'published revision media lookup is indexed'
);
select has_index(
  'private', 'media_upload_intents', 'media_upload_intents_active_idx',
  'active upload intent lookup is indexed'
);
select has_index(
  'private', 'media_publication_reservations', 'media_publication_reservations_active_idx',
  'active publication reservation lookup is indexed'
);

select has_trigger(
  'public', 'guidance_media_assets', 'guidance_media_assets_published_immutable',
  'published media metadata is immutable'
);
select has_trigger(
  'public', 'guidance_youtube_references', 'guidance_youtube_references_published_immutable',
  'published YouTube evidence is immutable'
);
select has_trigger(
  'public', 'guidance_media_manifests', 'guidance_media_manifests_immutable',
  'published manifests are immutable'
);
select has_trigger(
  'public', 'guidance_revisions', 'guidance_revisions_empty_media_manifest',
  'legacy text-only publication receives an explicit empty media manifest'
);

select has_function(
  'public', 'get_guidance_draft_media_manifest_v1', array['uuid', 'uuid'],
  'draft media manifest read RPC exists'
);
select has_function(
  'public', 'get_guidance_revision_media_manifest_v1', array['uuid', 'uuid'],
  'revision media manifest read RPC exists'
);
select has_function(
  'public', 'create_guidance_media_upload_intent_v1',
  array['uuid', 'uuid', 'text', 'text', 'bigint', 'bigint', 'uuid'],
  'bounded upload intent RPC exists'
);
select has_function(
  'public', 'finalize_guidance_media_upload_v1',
  array['uuid', 'bigint', 'integer', 'integer', 'text', 'bigint', 'uuid'],
  'upload evidence finalization RPC exists'
);
select has_function(
  'public', 'save_guidance_media_layout_v1', array['uuid', 'jsonb', 'bigint', 'uuid'],
  'draft layout RPC exists'
);
select has_function(
  'public', 'remove_guidance_media_asset_v1', array['uuid', 'uuid', 'bigint', 'uuid'],
  'draft asset quarantine RPC exists'
);
select has_function(
  'public', 'save_guidance_youtube_reference_v1',
  array['uuid', 'text', 'text', 'integer', 'text', 'text', 'timestamp with time zone', 'bigint', 'uuid'],
  'validated YouTube reference RPC exists'
);
select has_function(
  'public', 'remove_guidance_youtube_reference_v1', array['uuid', 'bigint', 'uuid'],
  'YouTube removal RPC exists'
);
select has_function(
  'public', 'duplicate_guidance_revision_with_media_as_draft_v1',
  array['uuid', 'uuid', 'bigint', 'bigint', 'uuid'],
  'media-aware duplicate-as-draft RPC exists'
);
select has_function(
  'public', 'begin_guidance_media_publication_v1',
  array['uuid', 'uuid', 'bigint', 'bigint', 'bigint', 'uuid'],
  'two-phase publication reservation RPC exists'
);
select has_function(
  'public', 'finalize_guidance_media_publication_v1', array['uuid', 'uuid'],
  'transactional publication finalization RPC exists'
);

select is(
  private.sha256_jsonb(private.media_manifest_canonical(
    '[]'::jsonb,
    jsonb_build_array(
      'youtube',
      'dQw4w9WgXcQ',
      'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      30,
      null,
      'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
      '2026-08-08T01:02:03.004005Z'
    )
  )),
  '098895820f77af9654b3c10dbd7d184047ab70bfb723a7fc9ac25c9668018670',
  'SQL media manifest hash matches the shared fixed-UTC YouTube vector'
);
select is(
  private.sha256_jsonb(jsonb_build_array(
    'stone-set-guidance-bundle-v1',
    repeat('a', 64),
    '098895820f77af9654b3c10dbd7d184047ab70bfb723a7fc9ac25c9668018670'
  )),
  '130a7e445de63c7aa7fb46332a12606a4f4b346688a63fcfe61dcca441c8c269',
  'SQL bundle hash matches the shared fixed vector'
);

select is(
  (
    select count(*) from pg_catalog.pg_class as relation
    join pg_catalog.pg_namespace as namespace on namespace.oid = relation.relnamespace
    where namespace.nspname in ('public', 'private')
      and relation.relname in (
        'guidance_media_draft_states', 'guidance_media_assets',
        'guidance_youtube_references', 'guidance_media_manifests',
        'media_upload_intents', 'media_publication_reservations',
        'media_publication_reservation_assets'
      )
      and not relation.relrowsecurity
  ),
  0::bigint,
  'every media relation has RLS enabled'
);

select results_eq(
  $$
    select policyname
    from pg_catalog.pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname like 'exercise_media_objects_%'
    order by policyname
  $$,
  $$values
    ('exercise_media_objects_delete_quarantined'::text),
    ('exercise_media_objects_insert_own_intent'::text),
    ('exercise_media_objects_select_own_manifest'::text)
  $$,
  'Storage exposes only explicit insert/select/delete media policies and no update policy'
);

select table_privs_are(
  'public', 'guidance_media_assets', 'authenticated', array['SELECT'],
  'authenticated receives read-only media object access'
);
select table_privs_are(
  'public', 'guidance_media_assets', 'anon', array[]::text[],
  'anon has no media metadata object privilege'
);
select table_privs_are(
  'private', 'media_upload_intents', 'authenticated', array[]::text[],
  'upload intents are not directly exposed'
);

select function_privs_are(
  'public', 'create_guidance_media_upload_intent_v1',
  array['uuid', 'uuid', 'text', 'text', 'bigint', 'bigint', 'uuid'],
  'authenticated', array['EXECUTE'],
  'authenticated may execute only the upload-intent entry point'
);
select function_privs_are(
  'public', 'create_guidance_media_upload_intent_v1',
  array['uuid', 'uuid', 'text', 'text', 'bigint', 'bigint', 'uuid'],
  'anon', array[]::text[],
  'anon cannot execute the upload-intent entry point'
);
select function_privs_are(
  'private', 'claim_expired_guidance_media_cleanup_v1', array['integer'],
  'authenticated', array[]::text[],
  'client roles cannot invoke cleanup authority'
);
select function_privs_are(
  'private', 'claim_expired_media_publication_copies_v1', array['integer'],
  'authenticated', array[]::text[],
  'client roles cannot claim orphaned publication copy cleanup'
);
select function_privs_are(
  'private', 'claim_expired_guidance_media_cleanup_v1', array['integer'],
  'service_role', array['EXECUTE'],
  'trusted operator tooling may claim bounded expired draft-media cleanup'
);
select function_privs_are(
  'private', 'claim_expired_media_publication_copies_v1', array['integer'],
  'service_role', array['EXECUTE'],
  'trusted operator tooling may claim bounded orphaned publication-copy cleanup'
);
select function_privs_are(
  'public', 'duplicate_guidance_revision_with_media_as_draft_v1',
  array['uuid', 'uuid', 'bigint', 'bigint', 'uuid'],
  'authenticated', array['EXECUTE'],
  'authenticated may invoke the bounded media-aware duplicate entry point'
);

select is(
  (
    select count(*) from pg_catalog.pg_proc as procedure
    join pg_catalog.pg_namespace as namespace on namespace.oid = procedure.pronamespace
    where namespace.nspname = 'storage'
      and procedure.proname like '%guidance%media%'
  ),
  0::bigint,
  'migration creates no custom function in the managed storage schema'
);

select is(
  (
    select count(*) from pg_catalog.pg_class as relation
    join pg_catalog.pg_namespace as namespace on namespace.oid = relation.relnamespace
    where namespace.nspname = 'storage'
      and relation.relname like '%guidance%media%'
  ),
  0::bigint,
  'migration creates no custom table in the managed storage schema'
);

select * from finish();
rollback;
