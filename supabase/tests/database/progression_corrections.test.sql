begin;
select no_plan();

insert into auth.users (
  instance_id, id, aud, role, email, email_confirmed_at, created_at, updated_at
) values
  ('00000000-0000-0000-0000-000000000000','a7100000-0000-4000-8000-000000000001','authenticated','authenticated','progression-alpha@local.stone-set.invalid',clock_timestamp(),clock_timestamp(),clock_timestamp()),
  ('00000000-0000-0000-0000-000000000000','a7100000-0000-4000-8000-000000000002','authenticated','authenticated','progression-bravo@local.stone-set.invalid',clock_timestamp(),clock_timestamp(),clock_timestamp());

insert into public.profiles (
  id, normalized_username, public_display_name, active, must_change_password, reward_timezone
) values
  ('a7100000-0000-4000-8000-000000000001','progression_alpha','Progression Alpha',true,false,'Asia/Kuala_Lumpur'),
  ('a7100000-0000-4000-8000-000000000002','progression_bravo','Progression Bravo',true,false,'Asia/Kuala_Lumpur');

insert into auth.sessions (id, user_id, created_at, updated_at) values
  ('a7200000-0000-4000-8000-000000000001','a7100000-0000-4000-8000-000000000001',clock_timestamp(),clock_timestamp()),
  ('a7200000-0000-4000-8000-000000000002','a7100000-0000-4000-8000-000000000002',clock_timestamp(),clock_timestamp());

insert into public.exercise_definitions (
  id, user_id, canonical_name, normalized_name
) values
  ('a7300000-0000-4000-8000-000000000001','a7100000-0000-4000-8000-000000000001','Bench Press','bench press'),
  ('a7300000-0000-4000-8000-000000000002','a7100000-0000-4000-8000-000000000001','Dumbbell Press','dumbbell press'),
  ('a7300000-0000-4000-8000-000000000003','a7100000-0000-4000-8000-000000000002','Other Exercise','other exercise');

insert into public.guidance_revisions (
  id, exercise_id, user_id, version_number, structured_content_schema_version,
  structured_content, canonical_name_snapshot, normalized_name_snapshot,
  equipment_keys_snapshot, content_hash, revision_hash
) values
  ('a7400000-0000-4000-8000-000000000001','a7300000-0000-4000-8000-000000000001','a7100000-0000-4000-8000-000000000001',1,1,'{}'::jsonb,'Bench Press','bench press','[]'::jsonb,repeat('a',64),repeat('b',64)),
  ('a7400000-0000-4000-8000-000000000002','a7300000-0000-4000-8000-000000000002','a7100000-0000-4000-8000-000000000001',1,1,'{}'::jsonb,'Dumbbell Press','dumbbell press','[]'::jsonb,repeat('c',64),repeat('d',64));

insert into public.routine_drafts (id, user_id, name, status, revision)
values ('a7500000-0000-4000-8000-000000000001','a7100000-0000-4000-8000-000000000001','Progression Routine','published',1);

insert into public.routine_submissions (
  id, author_user_id, routine_draft_id, routine_draft_revision, snapshot,
  content_hash, validation_result, validation_status, status
) values (
  'a7600000-0000-4000-8000-000000000001','a7100000-0000-4000-8000-000000000001',
  'a7500000-0000-4000-8000-000000000001',1,'{}'::jsonb,repeat('e',64),'{}'::jsonb,'valid','published'
);

insert into public.routine_reviews (
  id, submission_id, author_user_id, reviewer_user_id, decision, reviewer_note, content_hash
) values (
  'a7700000-0000-4000-8000-000000000001','a7600000-0000-4000-8000-000000000001',
  'a7100000-0000-4000-8000-000000000001','a7100000-0000-4000-8000-000000000002',
  'approved','Progression test approval',repeat('e',64)
);

insert into public.routine_versions (
  id, user_id, source_routine_draft_id, approved_submission_id, approved_review_id,
  version_number, name, content_hash, effective_date
) values (
  'a7800000-0000-4000-8000-000000000001','a7100000-0000-4000-8000-000000000001',
  'a7500000-0000-4000-8000-000000000001','a7600000-0000-4000-8000-000000000001',
  'a7700000-0000-4000-8000-000000000001',1,'Progression Routine',repeat('e',64),current_date-1
);

insert into public.routine_version_days (
  id, routine_version_id, user_id, day_index, day_type, title, purpose, position
) values (
  'a7900000-0000-4000-8000-000000000001','a7800000-0000-4000-8000-000000000001',
  'a7100000-0000-4000-8000-000000000001',1,'workout','Press','Train',1
);

insert into public.routine_version_prescriptions (
  id, routine_version_id, routine_version_day_id, user_id, position,
  exercise_definition_id, guidance_revision_id, priority, working_sets,
  rep_min, rep_max, rir_target, rest_seconds, load_unit, notes
) values (
  'a7a00000-0000-4000-8000-000000000001','a7800000-0000-4000-8000-000000000001',
  'a7900000-0000-4000-8000-000000000001','a7100000-0000-4000-8000-000000000001',1,
  'a7300000-0000-4000-8000-000000000001','a7400000-0000-4000-8000-000000000001',false,3,
  8,10,2,120,'kg',''
);

insert into public.training_weeks (
  id, user_id, routine_version_id, week_start, week_end, reward_timezone
) values (
  'a7b00000-0000-4000-8000-000000000001','a7100000-0000-4000-8000-000000000001',
  'a7800000-0000-4000-8000-000000000001',
  (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date
    - (extract(isodow from (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date)::integer - 1),
  (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date
    - (extract(isodow from (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date)::integer - 1) + 6,
  'Asia/Kuala_Lumpur'
);

insert into public.training_week_items (
  id, week_id, user_id, original_day_index, original_date, assigned_date, item_type,
  routine_version_day_id, allocated_rr, allocated_base_xp, allocated_missed_penalty_rr, lock_state
) values (
  'a7c00000-0000-4000-8000-000000000001','a7b00000-0000-4000-8000-000000000001',
  'a7100000-0000-4000-8000-000000000001',1,
  (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date,
  (clock_timestamp() at time zone 'Asia/Kuala_Lumpur')::date,
  'workout','a7900000-0000-4000-8000-000000000001',20,20,19,'open'
);

set local role anon;
select throws_ok($$select public.get_progression_v1()$$,'42501',null,'anonymous cannot load progression');
reset role;

do $$ begin perform set_config('request.jwt.claims', jsonb_build_object(
  'sub','a7100000-0000-4000-8000-000000000001','role','authenticated',
  'session_id','a7200000-0000-4000-8000-000000000001','is_anonymous',false
)::text, true); end $$;
set local role authenticated;

select is(
  public.get_progression_v1() #>> '{recommendations,0,state}',
  'no_data',
  'new exercise starts with no comparable data'
);

select public.update_progression_setting_v1(
  'a7300000-0000-4000-8000-000000000001',true,false,null,null,''
);
select is(
  public.get_progression_v1() #>> '{recommendations,0,state}',
  'protected',
  'protection overrides recommendation'
);

select public.update_progression_setting_v1(
  'a7300000-0000-4000-8000-000000000001',false,false,null,85,''
);
select is(
  public.get_progression_v1() #>> '{recommendations,0,state}',
  'override',
  'manual next load overrides automatic recommendation'
);
select is(
  (public.get_progression_v1() #>> '{recommendations,0,suggestedLoad}')::numeric,
  85::numeric,
  'manual override returns exact next load'
);

select public.update_progression_setting_v1(
  'a7300000-0000-4000-8000-000000000001',false,false,
  'a7300000-0000-4000-8000-000000000002',null,'Use dumbbells'
);
select public.start_workout_v1('a7c00000-0000-4000-8000-000000000001');
select is(
  (select exercise_definition_id from public.workout_session_exercises where user_id='a7100000-0000-4000-8000-000000000001'),
  'a7300000-0000-4000-8000-000000000002'::uuid,
  'preferred substitute is snapped into workout session'
);
select is(
  (select guidance_revision_id from public.workout_session_exercises where user_id='a7100000-0000-4000-8000-000000000001'),
  'a7400000-0000-4000-8000-000000000002'::uuid,
  'substitute uses latest immutable guidance revision'
);

select public.apply_progress_correction_v1('rr',10,'Add missing RR');
select is((select delta from public.rr_ledger where source_type='manual_correction'),10,'RR correction writes exact ledger delta');
select is((select rr_balance from public.rank_accounts),10,'RR correction refreshes rank account');

select public.apply_progress_correction_v1('xp',20,'Add missing XP');
select is((select delta from public.xp_ledger where source_type='manual_correction'),20,'XP correction writes exact ledger delta');
select is((select lifetime_xp from public.rank_accounts),20,'XP correction refreshes lifetime XP');

select public.reverse_progress_correction_v1(
  (select id from public.progress_corrections where kind='rr' and reverses_correction_id is null limit 1),
  'Undo RR correction'
);
select is((select sum(delta)::integer from public.rr_ledger where source_type='manual_correction'),0,'RR reversal is exact opposite delta');
select is((select rr_balance from public.rank_accounts),0,'reversal refreshes RR account');
select throws_ok(
  $$select public.reverse_progress_correction_v1(
    (select id from public.progress_corrections where kind='rr' and reverses_correction_id is null limit 1),
    'Duplicate reversal'
  )$$,
  '22023',null,'correction can only be reversed once'
);

reset role;
do $$ begin perform set_config('request.jwt.claims', jsonb_build_object(
  'sub','a7100000-0000-4000-8000-000000000002','role','authenticated',
  'session_id','a7200000-0000-4000-8000-000000000002','is_anonymous',false
)::text, true); end $$;
set local role authenticated;
select is((select count(*) from public.exercise_progression_settings),0::bigint,'other user cannot read progression settings');
select is((select count(*) from public.progress_corrections),0::bigint,'other user cannot read corrections');
select throws_ok(
  $$select public.update_progression_setting_v1(
    'a7300000-0000-4000-8000-000000000001',false,false,null,null,''
  )$$,
  '42501',null,'other user cannot mutate progression setting'
);
reset role;

select * from finish();
rollback;
