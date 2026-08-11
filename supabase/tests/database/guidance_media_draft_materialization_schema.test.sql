begin;
select no_plan();

select has_function(
  'public',
  'create_guidance_media_draft_from_revision_v1',
  array['uuid', 'uuid', 'bigint', 'uuid'],
  'versioned public draft-materialization RPC exists'
);

select has_function(
  'private',
  'create_guidance_media_draft_from_revision_v1',
  array['uuid', 'uuid', 'bigint', 'uuid'],
  'hardened private draft-materialization implementation exists'
);

select function_privs_are(
  'public', 'create_guidance_media_draft_from_revision_v1',
  array['uuid', 'uuid', 'bigint', 'uuid'],
  'authenticated', array['EXECUTE'],
  'authenticated receives only the public RPC execution grant'
);

select function_privs_are(
  'public', 'create_guidance_media_draft_from_revision_v1',
  array['uuid', 'uuid', 'bigint', 'uuid'],
  'anon', array[]::text[],
  'anonymous callers cannot execute the public RPC'
);

select function_privs_are(
  'public', 'create_guidance_media_draft_from_revision_v1',
  array['uuid', 'uuid', 'bigint', 'uuid'],
  'service_role', array[]::text[],
  'service role has no product-RPC execution grant'
);

select function_privs_are(
  'private', 'create_guidance_media_draft_from_revision_v1',
  array['uuid', 'uuid', 'bigint', 'uuid'],
  'authenticated', array[]::text[],
  'authenticated cannot execute the private implementation'
);

select function_privs_are(
  'private', 'create_guidance_media_draft_from_revision_v1',
  array['uuid', 'uuid', 'bigint', 'uuid'],
  'anon', array[]::text[],
  'anonymous callers cannot execute the private implementation'
);

select function_privs_are(
  'private', 'create_guidance_media_draft_from_revision_v1',
  array['uuid', 'uuid', 'bigint', 'uuid'],
  'service_role', array[]::text[],
  'service role cannot bypass the private implementation boundary'
);

select ok(
  (
    select procedure.prosecdef
      and procedure.provolatile = 'v'
      and procedure.proconfig = array['search_path=""']::text[]
    from pg_catalog.pg_proc as procedure
    join pg_catalog.pg_namespace as namespace
      on namespace.oid = procedure.pronamespace
    where namespace.nspname = 'private'
      and procedure.proname = 'create_guidance_media_draft_from_revision_v1'
      and pg_catalog.pg_get_function_identity_arguments(procedure.oid)
        = 'p_exercise_id uuid, p_guidance_revision_id uuid, p_expected_exercise_revision bigint, p_idempotency_key uuid'
  ),
  'private implementation is volatile security-definer code with an empty search path'
);

select ok(
  (
    select procedure.prosecdef
      and procedure.provolatile = 'v'
      and procedure.proconfig = array['search_path=""']::text[]
    from pg_catalog.pg_proc as procedure
    join pg_catalog.pg_namespace as namespace
      on namespace.oid = procedure.pronamespace
    where namespace.nspname = 'public'
      and procedure.proname = 'create_guidance_media_draft_from_revision_v1'
      and pg_catalog.pg_get_function_identity_arguments(procedure.oid)
        = 'p_exercise_id uuid, p_guidance_revision_id uuid, p_expected_exercise_revision bigint, p_idempotency_key uuid'
  ),
  'narrow public wrapper is volatile security-definer code with an empty search path'
);

select table_privs_are(
  'public', 'guidance_drafts', 'authenticated', array['SELECT'],
  'RPC addition does not introduce direct draft writes'
);
select table_privs_are(
  'public', 'guidance_media_draft_states', 'authenticated', array['SELECT'],
  'RPC addition does not introduce direct media-state writes'
);
select table_privs_are(
  'public', 'guidance_media_assets', 'authenticated', array['SELECT'],
  'RPC addition preserves media metadata as select-only'
);
select table_privs_are(
  'public', 'guidance_youtube_references', 'authenticated', array['SELECT'],
  'RPC addition preserves YouTube metadata as select-only'
);

select ok(
  (
    select relrowsecurity
    from pg_catalog.pg_class as relation
    join pg_catalog.pg_namespace as namespace on namespace.oid = relation.relnamespace
    where namespace.nspname = 'public' and relation.relname = 'guidance_drafts'
  ) and (
    select relrowsecurity
    from pg_catalog.pg_class as relation
    join pg_catalog.pg_namespace as namespace on namespace.oid = relation.relnamespace
    where namespace.nspname = 'public' and relation.relname = 'guidance_media_assets'
  ),
  'RLS remains enabled on the exposed draft and media tables'
);

select * from finish();
rollback;
