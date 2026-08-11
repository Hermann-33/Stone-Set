begin;
select no_plan();

insert into auth.users (
  instance_id, id, aud, role, email, email_confirmed_at, created_at, updated_at
) values
  ('00000000-0000-0000-0000-000000000000','e1000000-0000-4000-8000-000000000001','authenticated','authenticated','multiplier-alpha@local.stone-set.invalid',clock_timestamp(),clock_timestamp(),clock_timestamp()),
  ('00000000-0000-0000-0000-000000000000','e1000000-0000-4000-8000-000000000002','authenticated','authenticated','multiplier-bravo@local.stone-set.invalid',clock_timestamp(),clock_timestamp(),clock_timestamp());

insert into public.profiles (
  id, normalized_username, public_display_name, active, must_change_password, reward_timezone
) values
  ('e1000000-0000-4000-8000-000000000001','multiplier_alpha','Multiplier Alpha',true,false,'Asia/Kuala_Lumpur'),
  ('e1000000-0000-4000-8000-000000000002','multiplier_bravo','Multiplier Bravo',true,false,'Asia/Kuala_Lumpur');

insert into auth.sessions (id, user_id, created_at, updated_at) values
  ('e2000000-0000-4000-8000-000000000001','e1000000-0000-4000-8000-000000000001',clock_timestamp(),clock_timestamp()),
  ('e2000000-0000-4000-8000-000000000002','e1000000-0000-4000-8000-000000000002',clock_timestamp(),clock_timestamp());

insert into public.rank_accounts (user_id, rr_balance, lifetime_xp, rank_id)
values ('e1000000-0000-4000-8000-000000000001',321,654,'silver_i');

select is(
  (select active_consistency_multiplier from public.rank_accounts where user_id='e1000000-0000-4000-8000-000000000001'),
  1.00::numeric,
  'new rank accounts default to the authoritative base multiplier'
);

update public.rank_accounts set active_consistency_multiplier=1.50
where user_id='e1000000-0000-4000-8000-000000000001';
select is((select active_consistency_multiplier from public.rank_accounts),1.50::numeric,'1.50 is an accepted future ladder value');
update public.rank_accounts set active_consistency_multiplier=2.00
where user_id='e1000000-0000-4000-8000-000000000001';
select is((select active_consistency_multiplier from public.rank_accounts),2.00::numeric,'2.00 is an accepted future ladder value');
update public.rank_accounts set active_consistency_multiplier=2.50
where user_id='e1000000-0000-4000-8000-000000000001';
select is((select active_consistency_multiplier from public.rank_accounts),2.50::numeric,'2.50 is an accepted future ladder value');
select throws_ok(
  $$update public.rank_accounts set active_consistency_multiplier=1.25 where user_id='e1000000-0000-4000-8000-000000000001'$$,
  '23514', null, 'unsupported multiplier values are rejected'
);
select is((select rr_balance from public.rank_accounts),321,'multiplier changes preserve RR');
select is((select lifetime_xp from public.rank_accounts),654,'multiplier changes preserve XP');
select is((select rank_id from public.rank_accounts),'silver_i','multiplier changes preserve rank');
update public.rank_accounts set active_consistency_multiplier=1.00
where user_id='e1000000-0000-4000-8000-000000000001';

set local role anon;
select throws_ok($$select public.get_progress_v1()$$,'42501',null,'anonymous cannot load multiplier state');
reset role;

do $$ begin perform set_config('request.jwt.claims', jsonb_build_object(
  'sub','e1000000-0000-4000-8000-000000000001','role','authenticated',
  'session_id','e2000000-0000-4000-8000-000000000001','is_anonymous',false
)::text, true); end $$;
set local role authenticated;

select is((select count(*) from public.rank_accounts),1::bigint,'owner can read their rank account');
select throws_ok(
  $$update public.rank_accounts set active_consistency_multiplier=1.50 where user_id='e1000000-0000-4000-8000-000000000001'$$,
  '42501', null, 'authenticated owner cannot update server-owned multiplier'
);
select is(
  public.get_progress_v1() #>> '{account,activeConsistencyMultiplier}',
  '1.00',
  'progress payload exposes authoritative base multiplier'
);
select is(
  jsonb_typeof(public.get_progress_v1() #> '{account,activeConsistencyMultiplier}'),
  'number',
  'progress payload multiplier is numeric'
);

reset role;
do $$ begin perform set_config('request.jwt.claims', jsonb_build_object(
  'sub','e1000000-0000-4000-8000-000000000002','role','authenticated',
  'session_id','e2000000-0000-4000-8000-000000000002','is_anonymous',false
)::text, true); end $$;
set local role authenticated;
select is((select count(*) from public.rank_accounts),0::bigint,'cross-user multiplier state is denied');
reset role;

select * from finish();
rollback;
