begin;
select no_plan();

select ok(
  to_regprocedure('public.get_training_week_item_detail_v1(uuid)') is not null,
  'week item detail RPC exists'
);

select is(
  (
    select p.prosecdef
    from pg_proc as p
    where p.oid = 'public.get_training_week_item_detail_v1(uuid)'::regprocedure
  ),
  false,
  'week item detail RPC is security invoker'
);

select is(
  has_function_privilege(
    'anon',
    'public.get_training_week_item_detail_v1(uuid)',
    'EXECUTE'
  ),
  false,
  'anonymous role cannot execute week item detail RPC'
);

select is(
  has_function_privilege(
    'authenticated',
    'public.get_training_week_item_detail_v1(uuid)',
    'EXECUTE'
  ),
  true,
  'authenticated role can execute week item detail RPC'
);

select like(
  pg_get_functiondef('public.get_training_week_item_detail_v1(uuid)'::regprocedure),
  '%item.user_id = auth.uid()%','week item detail RPC enforces caller ownership'
);

select like(
  pg_get_functiondef('public.get_training_week_item_detail_v1(uuid)'::regprocedure),
  '%left join public.routine_version_days%',
  'week item detail RPC preserves a row for rest items without requiring workout prescriptions'
);

select * from finish();
rollback;
