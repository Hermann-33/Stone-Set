begin;
select no_plan();

select has_table('public', 'profiles', 'profiles table exists');
select has_table('public', 'user_preferences', 'user preferences table exists');
select has_table('public', 'account_capabilities', 'account capabilities table exists');
select has_table('public', 'client_compatibility_config', 'compatibility table exists');
select has_table('public', 'account_status_events', 'account status events table exists');
select has_table('private', 'account_security_state', 'private account security state exists');
select has_table('private', 'revoked_auth_sessions', 'private selected-session revocations exist');
select has_table('private', 'password_change_proofs', 'private password proofs exist');

select col_is_pk('public', 'profiles', 'id', 'profile id is the primary key');
select has_column('public', 'profiles', 'public_display_name', 'profile uses canonical display-name column');
select has_column('public', 'profiles', 'active', 'profile uses canonical active column');
select col_is_pk('public', 'user_preferences', 'user_id', 'preferences are one-to-one with profile');
select has_column('public', 'user_preferences', 'load_unit', 'preferences use canonical load-unit column');
select has_column('public', 'user_preferences', 'appearance_mode', 'preferences use canonical appearance column');
select has_column(
  'public',
  'client_compatibility_config',
  'minimum_mobile_build',
  'compatibility stores the mobile minimum separately'
);
select has_column(
  'public',
  'client_compatibility_config',
  'minimum_dashboard_build',
  'compatibility stores the dashboard minimum separately'
);
select col_is_pk(
  'public',
  'account_capabilities',
  array['user_id', 'capability_code'],
  'capability key is user and bounded capability'
);
select fk_ok(
  'public',
  'profiles',
  'id',
  'auth',
  'users',
  'id',
  'profile references Auth user'
);
select fk_ok(
  'public',
  'user_preferences',
  'user_id',
  'public',
  'profiles',
  'id',
  'preferences reference profile'
);

select has_index(
  'public',
  'profiles',
  'profiles_normalized_username_key',
  'normalized username has a unique index'
);
select has_index(
  'public',
  'account_status_events',
  'account_status_events_user_occurred_idx',
  'identity audit owner/time lookup is indexed'
);
select has_index(
  'private',
  'revoked_auth_sessions',
  'revoked_auth_sessions_user_revoked_idx',
  'session revocation lookup is indexed'
);

select has_function(
  'public',
  'get_authenticated_bootstrap',
  array['text', 'text', 'integer', 'integer', 'uuid'],
  'authenticated bootstrap RPC exists'
);
select has_function(
  'public',
  'complete_required_password_change',
  array['uuid'],
  'password completion RPC exists'
);
select has_function(
  'public',
  'operator_revoke_sessions',
  array['uuid', 'text', 'uuid', 'text', 'uuid'],
  'operator revocation RPC exists'
);

select ok(
  not has_table_privilege('anon', 'public.profiles', 'SELECT'),
  'anon has no profile object access'
);
select ok(
  has_table_privilege('authenticated', 'public.profiles', 'SELECT'),
  'authenticated has explicit profile SELECT object access'
);
select ok(
  not has_table_privilege('authenticated', 'public.profiles', 'UPDATE'),
  'authenticated has no direct profile UPDATE object access'
);
select ok(
  not has_table_privilege('authenticated', 'public.account_capabilities', 'UPDATE'),
  'authenticated cannot update capabilities'
);
select ok(
  not has_table_privilege('authenticated', 'private.account_security_state', 'SELECT'),
  'authenticated cannot read private security state'
);
select ok(
  not has_schema_privilege('anon', 'private', 'USAGE'),
  'anon cannot use the private schema'
);
select ok(
  not has_table_privilege('authenticated', 'public.account_status_events', 'INSERT'),
  'authenticated cannot append identity audit events'
);
select ok(
  not has_table_privilege('service_role', 'public.profiles', 'SELECT')
  and not has_table_privilege('service_role', 'public.profiles', 'INSERT')
  and not has_table_privilege('service_role', 'public.profiles', 'UPDATE')
  and not has_table_privilege('service_role', 'public.profiles', 'DELETE'),
  'service role receives no direct profile table privilege'
);

select ok(
  has_function_privilege(
    'authenticated',
    'public.get_authenticated_bootstrap(text,text,integer,integer,uuid)',
    'EXECUTE'
  ),
  'authenticated can execute bootstrap'
);
select ok(
  not has_function_privilege(
    'anon',
    'public.get_authenticated_bootstrap(text,text,integer,integer,uuid)',
    'EXECUTE'
  ),
  'anon cannot execute bootstrap'
);
select ok(
  not has_function_privilege(
    'authenticated',
    'public.operator_account_status(text)',
    'EXECUTE'
  ),
  'authenticated cannot execute operator status'
);
select ok(
  has_function_privilege(
    'service_role',
    'public.operator_account_status(text)',
    'EXECUTE'
  ),
  'service role can execute operator status'
);
select ok(
  not exists (
    select 1
    from pg_catalog.pg_proc as procedure
    cross join lateral aclexplode(
      coalesce(procedure.proacl, acldefault('f', procedure.proowner))
    ) as privilege
    where procedure.oid = 'public.complete_required_password_change(uuid)'::regprocedure
      and privilege.grantee = 0
      and privilege.privilege_type = 'EXECUTE'
  ),
  'PUBLIC cannot execute password completion'
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
        'get_authenticated_bootstrap',
        'update_my_profile',
        'update_my_preferences',
        'complete_required_password_change',
        'operator_link_identity',
        'operator_set_active',
        'operator_require_password_change',
        'operator_revoke_sessions',
        'operator_account_status',
        'current_live_auth_session_context',
        'current_session_context',
        'current_session_is_authorized',
        'add_identity_event',
        'normalize_username',
        'set_revision_timestamp',
        'validate_profile_timezone',
        'protect_profile_server_fields',
        'protect_preference_server_fields'
      )
      and privilege.grantee = 0
      and privilege.privilege_type = 'EXECUTE'
  ),
  'PUBLIC executes none of the identity functions'
);
select ok(
  not exists (
    select 1
    from pg_catalog.pg_proc as procedure
    join pg_catalog.pg_namespace as namespace on namespace.oid = procedure.pronamespace
    where namespace.nspname = 'public'
      and procedure.proname like 'operator_%'
      and has_function_privilege('authenticated', procedure.oid, 'EXECUTE')
  ),
  'authenticated executes no operator function'
);
select ok(
  not exists (
    select 1
    from pg_catalog.pg_proc as procedure
    join pg_catalog.pg_namespace as namespace on namespace.oid = procedure.pronamespace
    where namespace.nspname = 'public'
      and procedure.proname in (
        'get_authenticated_bootstrap',
        'update_my_profile',
        'update_my_preferences',
        'complete_required_password_change'
      )
      and has_function_privilege('anon', procedure.oid, 'EXECUTE')
  ),
  'anon executes no authenticated identity function'
);

select results_eq(
  $$
    select environment
    from public.client_compatibility_config
    where is_current
    order by environment
  $$,
  $$values ('local'::text)$$,
  'migration installs only a non-blocking local compatibility row'
);

select * from finish();
rollback;
