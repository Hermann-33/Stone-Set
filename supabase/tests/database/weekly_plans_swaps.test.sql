begin;
select no_plan();

create temporary table weekly_test_state (
  key text primary key,
  value jsonb not null
) on commit drop;
grant select, insert, update on table weekly_test_state to authenticated;

insert into auth.users (
  instance_id, id, aud, role, email, email_confirmed_at, created_at, updated_at
) values
  ('00000000-0000-0000-0000-000000000000', 'd1000000-0000-4000-8000-000000000001',
   'authenticated', 'authenticated', 'week-alpha@local.stone-set.invalid',
   clock_timestamp(), clock_timestamp(), clock_timestamp()),
  ('00000000-0000-0000-0000-000000000000', 'd1000000-0000-4000-8000-000000000002',
   'authenticated', 'authenticated', 'week-bravo@local.stone-set.invalid',
   clock_timestamp(), clock_timestamp(), clock_timestamp());

insert into public.profiles (
  id, normalized_username, public_display_name, active, must_change_password, reward_timezone
) values
  ('d1000000-0000-4000-8000-000000000001', 'week_alpha', 'Week Alpha', true, false, 'Asia/Kuala_Lumpur'),
  ('d1000000-0000-4000-8000-000000000002', 'week_bravo', 'Week Bravo', true, false, 'Asia/Kuala_Lumpur');

insert into auth.sessions (id, user_id, created_at, updated_at) values
  ('d2000000-0000-4000-8000-000000000001', 'd1000000-0000-4000-8000-000000000001', clock_timestamp(), clock_timestamp()),
  ('d2000000-0000-4000-8000-000000000002', 'd1000000-0000-4000-8000-000000000002', clock_timestamp(), clock_timestamp());

insert into public.routine_drafts (
  id, user_id, name, description, status, revision
) values (
  'd3000000-0000-4000-8000-000000000001',
  'd1000000-0000-4000-8000-000000000001',
  'Weekly Test Routine', '', 'published', 1
);

insert into public.routine_submissions (
  id, author_user_id, routine_draft_id, routine_draft_revision,
  snapshot, content_hash, validation_result, validation_status, status
) values (
  'd4000000-0000-4000-8000-000000000001',
  'd1000000-0000-4000-8000-000000000001',
  'd3000000-0000-4000-8000-000000000001',
  1, '{}'::jsonb, repeat('a', 64), '{}'::jsonb, 'valid', 'published'
);

insert into public.routine_reviews (
  id, submission_id, author_user_id, reviewer_user_id,
  decision, reviewer_note, content_hash
) values (
  'd5000000-0000-4000-8000-000000000001',
  'd4000000-0000-4000-8000-000000000001',
  'd1000000-0000-4000-8000-000000000001',
  'd1000000-0000-4000-8000-000000000002',
  'approved', 'Weekly test approval', repeat('a', 64)
);

insert into public.routine_versions (
  id, user_id, source_routine_draft_id, approved_submission_id, approved_review_id,
  version_number, name, description, content_hash, effective_date
) values (
  'd6000000-0000-4000-8000-000000000001',
  'd1000000-0000-4000-8000-000000000001',
  'd3000000-0000-4000-8000-000000000001',
  'd4000000-0000-4000-8000-000000000001',
  'd5000000-0000-4000-8000-000000000001',
  1, 'Weekly Test Routine', '', repeat('a', 64),
  current_date - (extract(isodow from current_date)::integer - 1)
);

insert into public.routine_version_days (
  id, routine_version_id, user_id, day_index, day_type, title, purpose, position
) values
  ('d7000000-0000-4000-8000-000000000001','d6000000-0000-4000-8000-000000000001','d1000000-0000-4000-8000-000000000001',1,'workout','Push','Train',1),
  ('d7000000-0000-4000-8000-000000000002','d6000000-0000-4000-8000-000000000001','d1000000-0000-4000-8000-000000000001',2,'workout','Pull','Train',2),
  ('d7000000-0000-4000-8000-000000000003','d6000000-0000-4000-8000-000000000001','d1000000-0000-4000-8000-000000000001',3,'rest','Rest','Recover',3),
  ('d7000000-0000-4000-8000-000000000004','d6000000-0000-4000-8000-000000000001','d1000000-0000-4000-8000-000000000001',4,'workout','Legs','Train',4),
  ('d7000000-0000-4000-8000-000000000005','d6000000-0000-4000-8000-000000000001','d1000000-0000-4000-8000-000000000001',5,'workout','Upper','Train',5),
  ('d7000000-0000-4000-8000-000000000006','d6000000-0000-4000-8000-000000000001','d1000000-0000-4000-8000-000000000001',6,'workout','Lower','Train',6),
  ('d7000000-0000-4000-8000-000000000007','d6000000-0000-4000-8000-000000000001','d1000000-0000-4000-8000-000000000001',7,'rest','Rest','Recover',7);

set local role anon;
select throws_ok(
  $$select public.get_or_create_current_week_v1()$$,
  '42501', null, 'anonymous cannot materialize a week'
);
reset role;

do $$ begin perform set_config('request.jwt.claims', jsonb_build_object(
  'sub','d1000000-0000-4000-8000-000000000001','role','authenticated',
  'session_id','d2000000-0000-4000-8000-000000000001','is_anonymous',false
)::text, true); end $$;
set local role authenticated;

insert into weekly_test_state (key, value)
select 'first_load', public.get_or_create_current_week_v1();

select is(
  (select value ->> 'status' from weekly_test_state where key='first_load'),
  'ready',
  'published routine materializes the current week'
);
select is((select count(*) from public.training_weeks), 1::bigint, 'one week is created');
select is((select count(*) from public.training_week_items), 7::bigint, 'exactly seven week items are created');
select is((select sum(allocated_rr) from public.training_week_items), 110::bigint, 'weekly RR allocation sums to 110');
select is((select sum(allocated_base_xp) from public.training_week_items), 110::bigint, 'weekly base XP allocation sums to 110');
select is((select sum(allocated_missed_penalty_rr) from public.training_week_items), 95::bigint, 'weekly missed penalty allocation sums to 95');
select is((select count(*) from public.training_week_items where item_type='workout' and allocated_rr=20), 5::bigint, 'five-day workout allocation is 20 each');
select is((select count(*) from public.training_week_items where item_type='rest' and allocated_rr=5), 2::bigint, 'five-day rest allocation is 5 each');
select is((select balance from public.free_swap_wallets), 2, 'first load grants two free swaps');
select is((select count(*) from public.monthly_free_swap_grants), 1::bigint, 'monthly grant is created once');

select public.get_or_create_current_week_v1();
select is((select count(*) from public.training_weeks), 1::bigint, 'week materialization is idempotent');
select is((select count(*) from public.monthly_free_swap_grants), 1::bigint, 'monthly grant is idempotent');
select is((select balance from public.free_swap_wallets), 2, 'retry does not duplicate free credits');

insert into weekly_test_state (key, value)
select 'open_items', jsonb_agg(jsonb_build_object('id', id::text, 'date', current_date::text) order by current_date)
from (
  select id, current_date
  from public.training_week_items
  where lock_state='open'
  order by current_date
  limit 3
) as available;

select ok(
  jsonb_array_length((select value from weekly_test_state where key='open_items')) >= 2,
  'current week exposes at least two swappable dates for the focused flow'
);

insert into weekly_test_state (key, value)
select 'swap_one', public.confirm_weekly_swap_v1(
  (select id from public.training_weeks limit 1),
  ((select value from weekly_test_state where key='open_items') -> 0 ->> 'id')::uuid,
  ((select value from weekly_test_state where key='open_items') -> 1 ->> 'id')::uuid
);
select is((select balance from public.free_swap_wallets), 1, 'first swap consumes one free credit');
select is((select confirmed_swap_count from public.training_weeks), 1, 'first swap increments weekly count');
select is((select count(*) from public.weekly_swaps), 1::bigint, 'first swap writes one record');
select is(
  (select current_date::text from public.training_week_items where id=((select value from weekly_test_state where key='open_items') -> 0 ->> 'id')::uuid),
  ((select value from weekly_test_state where key='open_items') -> 1 ->> 'date'),
  'first item receives second date'
);

select public.confirm_weekly_swap_v1(
  (select id from public.training_weeks limit 1),
  ((select value from weekly_test_state where key='open_items') -> 0 ->> 'id')::uuid,
  ((select value from weekly_test_state where key='open_items') -> 2 ->> 'id')::uuid
);
select is((select balance from public.free_swap_wallets), 0, 'second swap consumes second free credit');
select is((select confirmed_swap_count from public.training_weeks), 2, 'second swap reaches weekly limit');
select throws_ok(
  format(
    'select public.confirm_weekly_swap_v1(%L::uuid,%L::uuid,%L::uuid)',
    (select id::text from public.training_weeks limit 1),
    ((select value from weekly_test_state where key='open_items') -> 0 ->> 'id'),
    ((select value from weekly_test_state where key='open_items') -> 1 ->> 'id')
  ),
  '22023', 'weekly_swap_limit_reached', 'third swap is rejected'
);

reset role;

do $$ begin perform set_config('request.jwt.claims', jsonb_build_object(
  'sub','d1000000-0000-4000-8000-000000000002','role','authenticated',
  'session_id','d2000000-0000-4000-8000-000000000002','is_anonymous',false
)::text, true); end $$;
set local role authenticated;
select is((select count(*) from public.training_weeks), 0::bigint, 'second user cannot read first user week');
select is((select count(*) from public.training_week_items), 0::bigint, 'second user cannot read first user items');
select is((select count(*) from public.free_swap_wallets), 0::bigint, 'second user cannot read first user wallet');
select throws_ok(
  format(
    'select public.confirm_weekly_swap_v1(%L::uuid,%L::uuid,%L::uuid)',
    (select value -> 'week' ->> 'id' from weekly_test_state where key='first_load'),
    ((select value from weekly_test_state where key='open_items') -> 0 ->> 'id'),
    ((select value from weekly_test_state where key='open_items') -> 1 ->> 'id')
  ),
  '22023', 'weekly_swap_not_current', 'second user cannot mutate first user week'
);
reset role;

select * from finish();
rollback;
