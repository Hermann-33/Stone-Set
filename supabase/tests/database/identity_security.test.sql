begin;
select no_plan();

insert into auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  email_confirmed_at,
  created_at,
  updated_at
) values
  (
    '00000000-0000-0000-0000-000000000000',
    '10000000-0000-4000-8000-000000000001',
    'authenticated',
    'authenticated',
    'alpha@local.stone-set.invalid',
    clock_timestamp(),
    clock_timestamp(),
    clock_timestamp()
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '20000000-0000-4000-8000-000000000002',
    'authenticated',
    'authenticated',
    'bravo@local.stone-set.invalid',
    clock_timestamp(),
    clock_timestamp(),
    clock_timestamp()
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    '30000000-0000-4000-8000-000000000003',
    'authenticated',
    'authenticated',
    'charlie@local.stone-set.invalid',
    clock_timestamp(),
    clock_timestamp(),
    clock_timestamp()
  );

select lives_ok(
  $$select public.operator_link_identity(
    '10000000-0000-4000-8000-000000000001',
    'alpha_01',
    'Alpha One',
    'UTC',
    '30000000-0000-4000-8000-000000000003'
  )$$,
  'operator links first synthetic identity'
);
select lives_ok(
  $$select public.operator_link_identity(
    '20000000-0000-4000-8000-000000000002',
    'bravo_02',
    'Bravo Two',
    'UTC',
    '30000000-0000-4000-8000-000000000004'
  )$$,
  'operator links second synthetic identity'
);
select throws_ok(
  $$select public.operator_link_identity(
    '30000000-0000-4000-8000-000000000003',
    'alpha_01',
    'Charlie Three',
    'UTC',
    '30000000-0000-4000-8000-000000000007'
  )$$,
  '23505',
  null,
  'duplicate normalized username is impossible'
);
select throws_ok(
  $$select public.operator_link_identity(
    '30000000-0000-4000-8000-000000000003',
    ' Invalid_Name ',
    'Charlie Three',
    'UTC',
    '30000000-0000-4000-8000-000000000008'
  )$$,
  '22023',
  'invalid_normalized_username',
  'operator linkage requires an already normalized username'
);
select throws_ok(
  $$select public.operator_link_identity(
    '30000000-0000-4000-8000-000000000003',
    'charlie_03',
    'Charlie Three',
    'Not/A_Timezone',
    '30000000-0000-4000-8000-000000000009'
  )$$,
  '23514',
  'invalid_reward_timezone',
  'profile linkage rejects a non-IANA timezone'
);
select lives_ok(
  $$select public.operator_set_active(
    '10000000-0000-4000-8000-000000000001',
    true,
    '30000000-0000-4000-8000-000000000005'
  )$$,
  'operator activates first identity'
);
select lives_ok(
  $$select public.operator_set_active(
    '20000000-0000-4000-8000-000000000002',
    true,
    '30000000-0000-4000-8000-000000000006'
  )$$,
  'operator activates second identity'
);

insert into auth.sessions (id, user_id, created_at, updated_at)
values
  (
    '40000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000001',
    clock_timestamp(),
    clock_timestamp()
  ),
  (
    '40000000-0000-4000-8000-000000000002',
    '20000000-0000-4000-8000-000000000002',
    clock_timestamp(),
    clock_timestamp()
  );

set local role anon;
select throws_ok(
  $$select count(*) from public.profiles$$,
  '42501',
  null,
  'anon role has object-level profile denial'
);
select throws_ok(
  $$select count(*) from public.client_compatibility_config$$,
  '42501',
  null,
  'anon role has object-level compatibility denial'
);
reset role;

do $$
begin
  perform set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', '10000000-0000-4000-8000-000000000001',
      'role', 'authenticated',
      'session_id', '40000000-0000-4000-8000-000000000001',
      'is_anonymous', true
    )::text,
    true
  );
end;
$$;
set local role authenticated;
select is(
  (select count(*) from public.client_compatibility_config),
  0::bigint,
  'anonymous Auth identity is denied despite authenticated DB role'
);
reset role;

do $$
begin
  perform set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', '10000000-0000-4000-8000-000000000001',
      'role', 'authenticated',
      'session_id', '40000000-0000-4000-8000-000000000001',
      'is_anonymous', false
    )::text,
    true
  );
end;
$$;
set local role authenticated;
select is(
  (select count(*) from public.client_compatibility_config),
  1::bigint,
  'active owner can read current safe compatibility while password change is required'
);
select is(
  (select count(*) from public.profiles),
  0::bigint,
  'direct profile read is denied while password change is required'
);
select throws_ok(
  $$update public.profiles set active = false where id = '10000000-0000-4000-8000-000000000001'$$,
  '42501',
  null,
  'object privilege denies direct active-state update'
);
select throws_ok(
  $$update public.profiles set must_change_password = false where id = '10000000-0000-4000-8000-000000000001'$$,
  '42501',
  null,
  'object privilege denies direct password-flag update'
);
select throws_ok(
  $$update public.profiles set normalized_username = 'changed_01' where id = '10000000-0000-4000-8000-000000000001'$$,
  '42501',
  null,
  'object privilege denies direct username update'
);
select throws_ok(
  $$update public.account_capabilities set is_enabled = true where user_id = '10000000-0000-4000-8000-000000000001'$$,
  '42501',
  null,
  'object privilege denies direct capability update'
);
select throws_ok(
  $$select public.complete_required_password_change('50000000-0000-4000-8000-000000000001')$$,
  'P0001',
  'password_change_evidence_missing',
  'password flag cannot clear without Auth audit evidence'
);
reset role;

insert into auth.audit_log_entries (instance_id, id, payload, created_at)
values (
  '00000000-0000-0000-0000-000000000000',
  '60000000-0000-4000-8000-000000000001',
  jsonb_build_object(
    'action', 'user_updated_password',
    'actor_id', '10000000-0000-4000-8000-000000000001'
  ),
  clock_timestamp()
);

set local role authenticated;
select lives_ok(
  $$select public.complete_required_password_change('50000000-0000-4000-8000-000000000002')$$,
  'matching post-requirement Auth audit evidence clears the flag'
);
select is((select count(*) from public.profiles), 1::bigint, 'owner reads only own profile');
select is((select count(*) from public.user_preferences), 1::bigint, 'owner reads only own preferences');
select results_eq(
  $$select capability_code from public.account_capabilities where is_enabled = false$$,
  $$values ('routine_reviewer'::text)$$,
  'bounded routine reviewer capability is server managed and disabled by default'
);
select ok(
  (select count(*) from public.account_status_events) >= 1,
  'owner can read only their safe account status events after password completion'
);
select is(
  (select count(*) from public.profiles where normalized_username = 'bravo_02'),
  0::bigint,
  'cross-user profile read is denied'
);
select throws_ok(
  $$select public.complete_required_password_change('50000000-0000-4000-8000-000000000003')$$,
  'P0001',
  'password_change_not_required',
  'password proof cannot be replayed after completion'
);
select lives_ok(
  format(
    'select public.update_my_profile(%L, %L, %s)',
    'Alpha Prime',
    'UTC',
    (select revision from public.profiles where id = '10000000-0000-4000-8000-000000000001')
  ),
  'owner updates permitted profile fields through the narrow RPC'
);
select lives_ok(
  $$select public.update_my_preferences(
    'lb',
    'dark',
    true,
    false,
    false,
    false,
    null,
    'en',
    1
  )$$,
  'owner updates preferences through the narrow RPC'
);
select throws_ok(
  $$select public.update_my_preferences(
    'kg',
    'system',
    false,
    true,
    true,
    false,
    null,
    'en',
    1
  )$$,
  '40001',
  'stale_preferences_revision',
  'stale preference revision is denied'
);
reset role;

select lives_ok(
  $$select public.operator_revoke_sessions(
    '10000000-0000-4000-8000-000000000001',
    'selected',
    '40000000-0000-4000-8000-000000000001',
    'test_selected_revocation',
    '70000000-0000-4000-8000-000000000001'
  )$$,
  'operator records selected application-session revocation'
);

set local role authenticated;
select is(
  (select count(*) from public.profiles),
  0::bigint,
  'selected application revocation denies data despite residual JWT lifetime'
);
select is(
  public.get_authenticated_bootstrap(
    'local',
    'dashboard',
    1,
    1,
    '70000000-0000-4000-8000-000000000002'
  ) ->> 'state',
  'session_expired',
  'bootstrap reports deterministic session loss after selected revocation'
);
reset role;

select lives_ok(
  $$select public.operator_revoke_sessions(
    '20000000-0000-4000-8000-000000000002',
    'global',
    null,
    'test_global_revocation',
    '80000000-0000-4000-8000-000000000000'
  )$$,
  'operator records a global Stone Set session cutoff'
);
do $$
begin
  perform set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', '20000000-0000-4000-8000-000000000002',
      'role', 'authenticated',
      'session_id', '40000000-0000-4000-8000-000000000002',
      'is_anonymous', false
    )::text,
    true
  );
end;
$$;
set local role authenticated;
select is(
  public.get_authenticated_bootstrap(
    'local',
    'android',
    1,
    1,
    '80000000-0000-4000-8000-000000000003'
  ) ->> 'state',
  'session_expired',
  'global cutoff denies an older session without claiming JWT destruction'
);
reset role;

insert into auth.sessions (id, user_id, created_at, updated_at)
values (
  '40000000-0000-4000-8000-000000000003',
  '20000000-0000-4000-8000-000000000002',
  clock_timestamp(),
  clock_timestamp()
);
do $$
begin
  perform set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', '20000000-0000-4000-8000-000000000002',
      'role', 'authenticated',
      'session_id', '40000000-0000-4000-8000-000000000003',
      'is_anonymous', false
    )::text,
    true
  );
end;
$$;
set local role authenticated;
select is(
  public.get_authenticated_bootstrap(
    'local',
    'android',
    1,
    1,
    '80000000-0000-4000-8000-000000000004'
  ) ->> 'state',
  'password_change_required',
  'a fresh post-cutoff session is usable when the active profile still requires password change'
);
reset role;

select lives_ok(
  $$select public.operator_set_active(
    '20000000-0000-4000-8000-000000000002',
    false,
    '80000000-0000-4000-8000-000000000001'
  )$$,
  'operator deactivates second identity and sets the global cutoff'
);
do $$
begin
  perform set_config(
    'request.jwt.claims',
    jsonb_build_object(
      'sub', '20000000-0000-4000-8000-000000000002',
      'role', 'authenticated',
      'session_id', '40000000-0000-4000-8000-000000000003',
      'is_anonymous', false
    )::text,
    true
  );
end;
$$;
set local role authenticated;
select is(
  public.get_authenticated_bootstrap(
    'local',
    'android',
    1,
    1,
    '80000000-0000-4000-8000-000000000002'
  ) ->> 'state',
  'profile_disabled',
  'bootstrap reports disabled profile before denying protected data'
);
select is((select count(*) from public.profiles), 0::bigint, 'disabled profile is denied by RLS');
reset role;

select * from finish();
rollback;
