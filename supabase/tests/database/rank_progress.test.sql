begin;
select no_plan();

insert into auth.users (
  instance_id, id, aud, role, email, email_confirmed_at, created_at, updated_at
) values
  ('00000000-0000-0000-0000-000000000000','f1000000-0000-4000-8000-000000000001','authenticated','authenticated','progress-alpha@local.stone-set.invalid',clock_timestamp(),clock_timestamp(),clock_timestamp()),
  ('00000000-0000-0000-0000-000000000000','f1000000-0000-4000-8000-000000000002','authenticated','authenticated','progress-bravo@local.stone-set.invalid',clock_timestamp(),clock_timestamp(),clock_timestamp());

insert into public.profiles (
  id, normalized_username, public_display_name, active, must_change_password, reward_timezone
) values
  ('f1000000-0000-4000-8000-000000000001','progress_alpha','Progress Alpha',true,false,'Asia/Kuala_Lumpur'),
  ('f1000000-0000-4000-8000-000000000002','progress_bravo','Progress Bravo',true,false,'Asia/Kuala_Lumpur');

insert into auth.sessions (id, user_id, created_at, updated_at) values
  ('f2000000-0000-4000-8000-000000000001','f1000000-0000-4000-8000-000000000001',clock_timestamp(),clock_timestamp()),
  ('f2000000-0000-4000-8000-000000000002','f1000000-0000-4000-8000-000000000002',clock_timestamp(),clock_timestamp());

insert into public.routine_drafts (id, user_id, name, status, revision)
values ('f3000000-0000-4000-8000-000000000001','f1000000-0000-4000-8000-000000000001','Progress Test','published',1);

insert into public.routine_submissions (
  id, author_user_id, routine_draft_id, routine_draft_revision, snapshot,
  content_hash, validation_result, validation_status, status
) values (
  'f4000000-0000-4000-8000-000000000001','f1000000-0000-4000-8000-000000000001',
  'f3000000-0000-4000-8000-000000000001',1,'{}'::jsonb,repeat('a',64),'{}'::jsonb,'valid','published'
);

insert into public.routine_reviews (
  id, submission_id, author_user_id, reviewer_user_id, decision, reviewer_note, content_hash
) values (
  'f5000000-0000-4000-8000-000000000001','f4000000-0000-4000-8000-000000000001',
  'f1000000-0000-4000-8000-000000000001','f1000000-0000-4000-8000-000000000002',
  'approved','Progress test approval',repeat('a',64)
);

insert into public.routine_versions (
  id, user_id, source_routine_draft_id, approved_submission_id, approved_review_id,
  version_number, name, content_hash, effective_date
) values (
  'f6000000-0000-4000-8000-000000000001','f1000000-0000-4000-8000-000000000001',
  'f3000000-0000-4000-8000-000000000001','f4000000-0000-4000-8000-000000000001',
  'f5000000-0000-4000-8000-000000000001',1,'Progress Test',repeat('a',64),current_date-30
);

insert into public.routine_version_days (
  id, routine_version_id, user_id, day_index, day_type, title, purpose, position
) values
  ('f7000000-0000-4000-8000-000000000001','f6000000-0000-4000-8000-000000000001','f1000000-0000-4000-8000-000000000001',1,'workout','Workout','Train',1),
  ('f7000000-0000-4000-8000-000000000002','f6000000-0000-4000-8000-000000000001','f1000000-0000-4000-8000-000000000001',2,'rest','Rest','Recover',2);

insert into public.training_weeks (
  id, user_id, routine_version_id, week_start, week_end, reward_timezone
) values (
  'f8000000-0000-4000-8000-000000000001','f1000000-0000-4000-8000-000000000001',
  'f6000000-0000-4000-8000-000000000001',
  (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date
    - (extract(isodow from (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date)::integer - 1),
  (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date
    - (extract(isodow from (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date)::integer - 1) + 6,
  'Asia/Kuala_Lumpur'
);

insert into public.training_week_items (
  id, week_id, user_id, original_day_index, original_date, assigned_date, item_type,
  routine_version_day_id, allocated_rr, allocated_base_xp, allocated_missed_penalty_rr, lock_state
) values
  ('f9000000-0000-4000-8000-000000000001','f8000000-0000-4000-8000-000000000001','f1000000-0000-4000-8000-000000000001',1,current_date-10,current_date-10,'workout','f7000000-0000-4000-8000-000000000001',110,20,19,'locked'),
  ('f9000000-0000-4000-8000-000000000002','f8000000-0000-4000-8000-000000000001','f1000000-0000-4000-8000-000000000001',2,current_date-9,current_date-9,'workout','f7000000-0000-4000-8000-000000000001',20,20,19,'locked'),
  ('f9000000-0000-4000-8000-000000000003','f8000000-0000-4000-8000-000000000001','f1000000-0000-4000-8000-000000000001',3,current_date-8,current_date-8,'rest','f7000000-0000-4000-8000-000000000002',5,5,0,'locked'),
  ('f9000000-0000-4000-8000-000000000004','f8000000-0000-4000-8000-000000000001','f1000000-0000-4000-8000-000000000001',4,current_date-7,current_date-7,'workout','f7000000-0000-4000-8000-000000000001',20,20,19,'locked'),
  ('f9000000-0000-4000-8000-000000000005','f8000000-0000-4000-8000-000000000001','f1000000-0000-4000-8000-000000000001',5,(clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date+1,(clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date+1,'workout','f7000000-0000-4000-8000-000000000001',20,20,19,'open'),
  ('f9000000-0000-4000-8000-000000000006','f8000000-0000-4000-8000-000000000001','f1000000-0000-4000-8000-000000000001',6,(clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date+2,(clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date+2,'workout','f7000000-0000-4000-8000-000000000001',20,20,19,'open');

insert into public.workout_sessions (
  id, user_id, weekly_plan_item_id, state, started_at, submitted_at, prescription_snapshot, last_client_revision
) values
  ('fa000000-0000-4000-8000-000000000001','f1000000-0000-4000-8000-000000000001','f9000000-0000-4000-8000-000000000001','submitted',clock_timestamp()-interval '10 days',clock_timestamp()-interval '10 days','{}'::jsonb,1),
  ('fa000000-0000-4000-8000-000000000002','f1000000-0000-4000-8000-000000000001','f9000000-0000-4000-8000-000000000002','submitted',clock_timestamp()-interval '9 days',clock_timestamp()-interval '9 days','{}'::jsonb,1);

insert into public.workout_results (
  id, session_id, user_id, status, planned_sets, completed_sets, submitted_at
) values
  ('fb000000-0000-4000-8000-000000000001','fa000000-0000-4000-8000-000000000001','f1000000-0000-4000-8000-000000000001','completed',10,10,clock_timestamp()-interval '10 days'),
  ('fb000000-0000-4000-8000-000000000002','fa000000-0000-4000-8000-000000000001','f1000000-0000-4000-8000-000000000001','partial',10,5,clock_timestamp()-interval '9 days');

-- The current month's normal grant has already happened. One of its two credits remains.
insert into public.free_swap_wallets (user_id, balance, lifetime_granted, lifetime_consumed)
values ('f1000000-0000-4000-8000-000000000001',1,2,1);
insert into public.monthly_free_swap_grants (user_id, grant_month, quantity)
values (
  'f1000000-0000-4000-8000-000000000001',
  date_trunc('month', clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date,
  2
);

set local role anon;
select throws_ok($$select public.get_progress_v1()$$,'42501',null,'anonymous cannot load progress');
reset role;

do $$ begin perform set_config('request.jwt.claims', jsonb_build_object(
  'sub','f1000000-0000-4000-8000-000000000001','role','authenticated',
  'session_id','f2000000-0000-4000-8000-000000000001','is_anonymous',false
)::text, true); end $$;
set local role authenticated;

select public.get_progress_v1();
select is((select count(*) from public.rr_ledger),4::bigint,'full, partial, rest and missed RR score once');
select is((select count(*) from public.xp_ledger),3::bigint,'full, partial and rest XP score once');
select is((select rr_balance from public.rank_accounts),106,'RR is full + partial + rest - missed');
select is((select lifetime_xp from public.rank_accounts),35,'XP is full + partial + rest');
select is((select rank_id from public.rank_accounts),'bronze_ii','rank follows existing thresholds');
select is((select delta from public.rr_ledger where source_type='workout_reward' and source_id='fb000000-0000-4000-8000-000000000002'),10,'partial RR is proportional');
select is((select delta from public.xp_ledger where source_type='workout_reward' and source_id='fb000000-0000-4000-8000-000000000002'),10,'partial XP is proportional');

select public.get_progress_v1();
select is((select count(*) from public.rr_ledger),4::bigint,'RR refresh is idempotent');
select is((select count(*) from public.xp_ledger),3::bigint,'XP refresh is idempotent');

select public.confirm_weekly_swap_v2(
  'f8000000-0000-4000-8000-000000000001','f9000000-0000-4000-8000-000000000005','f9000000-0000-4000-8000-000000000006'
);
select is((select balance from public.free_swap_wallets),0,'free credit is used first');
select is((select payment_method from public.weekly_swaps where swap_number=1),'free_credit','first swap is free');
select is((select rr_balance from public.rank_accounts),106,'free swap does not consume RR');

select public.confirm_weekly_swap_v2(
  'f8000000-0000-4000-8000-000000000001','f9000000-0000-4000-8000-000000000005','f9000000-0000-4000-8000-000000000006'
);
select is((select payment_method from public.weekly_swaps where swap_number=2),'rr','second swap falls back to RR');
select is((select delta from public.rr_ledger where source_type='paid_swap'),-5,'paid swap costs exactly 5 RR');
select is((select rr_balance from public.rank_accounts),101,'paid swap immediately updates RR');

reset role;
do $$ begin perform set_config('request.jwt.claims', jsonb_build_object(
  'sub','f1000000-0000-4000-8000-000000000002','role','authenticated',
  'session_id','f2000000-0000-4000-8000-000000000002','is_anonymous',false
)::text, true); end $$;
set local role authenticated;
select is((select count(*) from public.rank_accounts),0::bigint,'other user cannot read rank account');
select is((select count(*) from public.rr_ledger),0::bigint,'other user cannot read RR ledger');
select is((select count(*) from public.xp_ledger),0::bigint,'other user cannot read XP ledger');
reset role;

select * from finish();
rollback;
