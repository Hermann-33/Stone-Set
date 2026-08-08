begin;
select no_plan();

select has_table('public', 'muscles', 'muscle taxonomy exists');
select has_table('public', 'exercise_definitions', 'exercise definitions exist');
select has_table('public', 'exercise_definition_equipment', 'ordered exercise equipment exists');
select has_table('public', 'exercise_definition_muscles', 'ordered primary and secondary muscles exist');
select has_table('public', 'guidance_drafts', 'guidance drafts exist');
select has_table('public', 'guidance_revisions', 'immutable guidance revisions exist');
select has_table('public', 'guidance_revision_muscles', 'pinned revision muscles exist');
select has_table('private', 'guidance_mutation_operations', 'private durable mutation replay exists');

select col_is_pk('public', 'muscles', 'id', 'muscles use stable UUID primary keys');
select col_is_pk('public', 'exercise_definitions', 'id', 'exercise definitions use UUID primary keys');
select col_is_pk('public', 'guidance_drafts', 'id', 'guidance drafts use UUID primary keys');
select col_is_pk('public', 'guidance_revisions', 'id', 'guidance revisions use UUID primary keys');
select col_is_pk(
  'private',
  'guidance_mutation_operations',
  array['user_id', 'operation_name', 'idempotency_key'],
  'mutation replay key is actor, operation and idempotency key'
);

select fk_ok(
  'public', 'exercise_definitions', 'user_id',
  'public', 'profiles', 'id',
  'exercise owner references protected profile'
);
select fk_ok(
  'public', 'exercise_definitions',
  array['cloned_from_exercise_id', 'user_id'],
  'public', 'exercise_definitions',
  array['id', 'user_id'],
  'clone provenance cannot cross owner boundaries'
);
select fk_ok(
  'public', 'exercise_definition_equipment',
  array['exercise_id', 'user_id'],
  'public', 'exercise_definitions',
  array['id', 'user_id'],
  'equipment ownership follows its exercise'
);
select fk_ok(
  'public', 'exercise_definition_muscles',
  array['exercise_id', 'user_id'],
  'public', 'exercise_definitions',
  array['id', 'user_id'],
  'muscle assignments cannot forge exercise ownership'
);
select fk_ok(
  'public', 'guidance_drafts',
  array['exercise_id', 'user_id'],
  'public', 'exercise_definitions',
  array['id', 'user_id'],
  'draft ownership follows its exercise'
);
select fk_ok(
  'public', 'guidance_drafts',
  array['base_guidance_revision_id', 'exercise_id', 'user_id'],
  'public', 'guidance_revisions',
  array['id', 'exercise_id', 'user_id'],
  'draft base revision must belong to the same owned exercise'
);
select fk_ok(
  'public', 'guidance_revisions',
  array['exercise_id', 'user_id'],
  'public', 'exercise_definitions',
  array['id', 'user_id'],
  'revision ownership follows its exercise'
);
select fk_ok(
  'public', 'guidance_revisions',
  array['supersedes_revision_id', 'exercise_id', 'user_id'],
  'public', 'guidance_revisions',
  array['id', 'exercise_id', 'user_id'],
  'revision supersession cannot cross exercise or owner boundaries'
);
select fk_ok(
  'public', 'guidance_revision_muscles',
  array['guidance_revision_id', 'user_id'],
  'public', 'guidance_revisions',
  array['id', 'user_id'],
  'pinned muscle ownership follows its revision'
);

select has_index(
  'public', 'exercise_definitions', 'exercise_definitions_owner_active_name_idx',
  'active owner/name lookup has a partial index'
);
select has_index(
  'public', 'exercise_definition_equipment', 'exercise_definition_equipment_owner_idx',
  'equipment owner/filter path is indexed'
);
select has_index(
  'public', 'exercise_definition_muscles', 'exercise_definition_muscles_owner_role_idx',
  'muscle owner/role/filter path is indexed'
);
select has_index(
  'public', 'guidance_revisions', 'guidance_revisions_exercise_version_desc_idx',
  'revision history path is indexed'
);
select has_index(
  'private', 'guidance_mutation_operations', 'guidance_mutation_operations_pkey',
  'idempotency replay has a unique primary index'
);

select results_eq(
  $$
    select id::text, stable_key, display_name, display_order
    from public.muscles
    order by display_order
  $$,
  $$values
    ('a3000000-0000-4000-8000-000000000001', 'chest', 'Chest', 1),
    ('a3000000-0000-4000-8000-000000000002', 'back', 'Back', 2),
    ('a3000000-0000-4000-8000-000000000003', 'anterior_deltoids', 'Anterior deltoids', 3),
    ('a3000000-0000-4000-8000-000000000004', 'lateral_deltoids', 'Lateral deltoids', 4),
    ('a3000000-0000-4000-8000-000000000005', 'posterior_deltoids', 'Posterior deltoids', 5),
    ('a3000000-0000-4000-8000-000000000006', 'biceps', 'Biceps', 6),
    ('a3000000-0000-4000-8000-000000000007', 'triceps', 'Triceps', 7),
    ('a3000000-0000-4000-8000-000000000008', 'forearms', 'Forearms', 8),
    ('a3000000-0000-4000-8000-000000000009', 'quadriceps', 'Quadriceps', 9),
    ('a3000000-0000-4000-8000-00000000000a', 'hamstrings', 'Hamstrings', 10),
    ('a3000000-0000-4000-8000-00000000000b', 'glutes', 'Glutes', 11),
    ('a3000000-0000-4000-8000-00000000000c', 'calves', 'Calves', 12),
    ('a3000000-0000-4000-8000-00000000000d', 'abdominals', 'Abdominals', 13)
  $$,
  'migration installs the exact immutable taxonomy matrix'
);

select has_trigger('public', 'muscles', 'muscles_immutable', 'taxonomy has immutable trigger');
select has_trigger(
  'public', 'guidance_revisions', 'guidance_revisions_immutable',
  'published revisions have immutable trigger'
);
select has_trigger(
  'public', 'guidance_revision_muscles', 'guidance_revision_muscles_immutable',
  'pinned muscle evidence has immutable trigger'
);
select has_trigger(
  'public', 'exercise_definitions', 'exercise_definitions_require_children',
  'exercise completeness is enforced at transaction completion'
);

select has_function(
  'public', 'create_exercise_v1',
  array['text', 'text', 'jsonb', 'jsonb', 'boolean', 'uuid'],
  'versioned create exercise RPC exists'
);
select has_function(
  'public', 'update_exercise_v1',
  array['uuid', 'text', 'text', 'jsonb', 'jsonb', 'bigint', 'boolean', 'uuid'],
  'versioned update exercise RPC exists'
);
select has_function(
  'public', 'set_exercise_archived_v1',
  array['uuid', 'boolean', 'bigint', 'uuid'],
  'versioned archive RPC exists'
);
select has_function(
  'public', 'save_guidance_draft_v1',
  array['uuid', 'jsonb', 'bigint', 'uuid'],
  'versioned draft save RPC exists'
);
select has_function(
  'public', 'validate_guidance_draft_v1',
  array['uuid', 'uuid', 'bigint', 'bigint'],
  'versioned validation RPC exists'
);
select has_function(
  'public', 'publish_guidance_revision_v1',
  array['uuid', 'uuid', 'bigint', 'bigint', 'uuid'],
  'versioned publish RPC exists'
);
select has_function(
  'public', 'clone_exercise_v1',
  array['uuid', 'text', 'boolean', 'uuid'],
  'versioned owned clone RPC exists'
);
select has_function(
  'public', 'duplicate_guidance_revision_as_draft_v1',
  array['uuid', 'uuid', 'bigint', 'uuid'],
  'versioned duplicate revision as draft RPC exists'
);
select has_function(
  'public', 'list_exercises_v1',
  array['text', 'text', 'text', 'text[]', 'text[]', 'text', 'integer', 'integer'],
  'bounded permission-filtered exercise list RPC exists'
);

select is(
  (
    select count(*)
    from pg_catalog.pg_class as relation
    join pg_catalog.pg_namespace as namespace on namespace.oid = relation.relnamespace
    where namespace.nspname = 'public'
      and relation.relname in (
        'muscles', 'exercise_definitions', 'exercise_definition_equipment',
        'exercise_definition_muscles', 'guidance_drafts', 'guidance_revisions',
        'guidance_revision_muscles'
      )
      and not relation.relrowsecurity
  ),
  0::bigint,
  'every exposed exercise/guidance table has RLS enabled'
);

select is(
  (
    select count(*)
    from (
      values
        ('public', 'muscles'),
        ('public', 'exercise_definitions'),
        ('public', 'exercise_definition_equipment'),
        ('public', 'exercise_definition_muscles'),
        ('public', 'guidance_drafts'),
        ('public', 'guidance_revisions'),
        ('public', 'guidance_revision_muscles'),
        ('private', 'guidance_mutation_operations')
    ) as object(schema_name, table_name)
    cross join (values ('anon'), ('authenticated'), ('service_role')) as actor(role_name)
    cross join (values ('SELECT'), ('INSERT'), ('UPDATE'), ('DELETE')) as access(privilege_name)
    where has_table_privilege(
      actor.role_name,
      format('%I.%I', object.schema_name, object.table_name),
      access.privilege_name
    ) is distinct from (
      actor.role_name = 'authenticated'
      and object.schema_name = 'public'
      and access.privilege_name = 'SELECT'
    )
  ),
  0::bigint,
  'object privileges match the complete intended role matrix'
);

select is(
  (
    select count(*)
    from pg_catalog.pg_proc as procedure
    join pg_catalog.pg_namespace as namespace on namespace.oid = procedure.pronamespace
    cross join (values ('anon'), ('authenticated'), ('service_role')) as actor(role_name)
    where namespace.nspname in ('public', 'private')
      and procedure.proname in (
        'create_exercise_v1', 'update_exercise_v1', 'set_exercise_archived_v1',
        'save_guidance_draft_v1', 'validate_guidance_draft_v1',
        'publish_guidance_revision_v1', 'clone_exercise_v1',
        'duplicate_guidance_revision_as_draft_v1', 'list_exercises_v1'
      )
      and has_function_privilege(actor.role_name, procedure.oid, 'EXECUTE') is distinct from (
        actor.role_name = 'authenticated'
      )
  ),
  0::bigint,
  'public and private RPC execution matches the intended authenticated-only matrix'
);

select ok(
  not exists (
    select 1
    from pg_catalog.pg_proc as procedure
    join pg_catalog.pg_namespace as namespace on namespace.oid = procedure.pronamespace
    cross join lateral aclexplode(
      coalesce(procedure.proacl, acldefault('f', procedure.proowner))
    ) as privilege
    where namespace.nspname in ('public', 'private')
      and procedure.proname in (
        'normalize_exercise_name', 'normalize_guidance_string', 'sha256_text', 'sha256_jsonb',
        'require_product_actor', 'normalize_guidance_content', 'validate_equipment_payload',
        'validate_muscle_payload', 'exercise_identity_fingerprint', 'load_mutation_result',
        'store_mutation_result', 'reject_immutable_change', 'assert_exercise_children_complete',
        'replace_exercise_children', 'exercise_duplicate_exists', 'create_exercise_v1',
        'update_exercise_v1', 'set_exercise_archived_v1', 'save_guidance_draft_v1',
        'validate_guidance_draft_v1', 'publish_guidance_revision_v1', 'clone_exercise_v1',
        'duplicate_guidance_revision_as_draft_v1', 'list_exercises_v1'
      )
      and privilege.grantee = 0
      and privilege.privilege_type = 'EXECUTE'
  ),
  'PUBLIC executes no exercise/guidance function'
);

select * from finish();
rollback;
