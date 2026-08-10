begin;

create table public.exercise_progression_settings (
  user_id uuid not null references public.profiles (id) on delete cascade,
  exercise_definition_id uuid not null,
  progression_protected boolean not null default false,
  pain_flagged boolean not null default false,
  preferred_substitute_exercise_id uuid,
  manual_next_load numeric(10,3),
  note text not null default '',
  updated_at timestamptz not null default clock_timestamp(),
  primary key (user_id, exercise_definition_id),
  foreign key (exercise_definition_id, user_id)
    references public.exercise_definitions (id, user_id) on delete cascade,
  foreign key (preferred_substitute_exercise_id, user_id)
    references public.exercise_definitions (id, user_id) on delete restrict,
  constraint exercise_progression_settings_not_self_substitute check (
    preferred_substitute_exercise_id is null
    or preferred_substitute_exercise_id <> exercise_definition_id
  ),
  constraint exercise_progression_settings_manual_load check (
    manual_next_load is null or manual_next_load >= 0
  ),
  constraint exercise_progression_settings_note check (char_length(note) <= 500)
);

create index exercise_progression_settings_substitute_idx
  on public.exercise_progression_settings (user_id, preferred_substitute_exercise_id)
  where preferred_substitute_exercise_id is not null;

create table public.progress_corrections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  kind text not null check (kind in ('rr', 'xp')),
  delta integer not null check (delta <> 0),
  reason text not null,
  reverses_correction_id uuid,
  created_at timestamptz not null default clock_timestamp(),
  unique (id, user_id),
  foreign key (reverses_correction_id, user_id)
    references public.progress_corrections (id, user_id) on delete restrict,
  constraint progress_corrections_reason check (
    char_length(btrim(reason)) between 1 and 500
  )
);

create unique index progress_corrections_one_reversal_idx
  on public.progress_corrections (reverses_correction_id)
  where reverses_correction_id is not null;
create index progress_corrections_owner_created_idx
  on public.progress_corrections (user_id, created_at desc, id);

alter table public.rr_ledger
  drop constraint if exists rr_ledger_source_type_check;
alter table public.rr_ledger
  add constraint rr_ledger_source_type_check
  check (source_type in ('workout_reward', 'rest_reward', 'missed_workout', 'paid_swap', 'manual_correction'));

alter table public.xp_ledger
  drop constraint if exists xp_ledger_source_type_check;
alter table public.xp_ledger
  add constraint xp_ledger_source_type_check
  check (source_type in ('workout_reward', 'rest_reward', 'manual_correction'));
alter table public.xp_ledger
  drop constraint if exists xp_ledger_delta_check;
alter table public.xp_ledger
  add constraint xp_ledger_delta_check check (delta <> 0);

revoke all on table public.exercise_progression_settings from public, anon, authenticated, service_role;
revoke all on table public.progress_corrections from public, anon, authenticated, service_role;
grant select on table public.exercise_progression_settings to authenticated;
grant select on table public.progress_corrections to authenticated;

alter table public.exercise_progression_settings enable row level security;
alter table public.progress_corrections enable row level security;

create policy exercise_progression_settings_owner_select
  on public.exercise_progression_settings for select to authenticated
  using (user_id = (select auth.uid()));
create policy progress_corrections_owner_select
  on public.progress_corrections for select to authenticated
  using (user_id = (select auth.uid()));

create or replace function private.progression_payload(p_user_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with latest_version as (
    select version.id
    from public.routine_versions as version
    where version.user_id = p_user_id
      and version.effective_date <= current_date
    order by version.effective_date desc, version.version_number desc, version.id desc
    limit 1
  ),
  current_prescriptions as (
    select distinct on (prescription.exercise_definition_id)
      prescription.exercise_definition_id,
      exercise.canonical_name,
      prescription.load_unit,
      prescription.rep_max,
      prescription.rir_target
    from public.routine_version_prescriptions as prescription
    join public.exercise_definitions as exercise
      on exercise.id = prescription.exercise_definition_id
     and exercise.user_id = prescription.user_id
    where prescription.user_id = p_user_id
      and prescription.routine_version_id = (select id from latest_version)
    order by prescription.exercise_definition_id, prescription.position
  ),
  recommendation_rows as (
    select
      prescription.exercise_definition_id,
      prescription.canonical_name,
      prescription.load_unit,
      coalesce(setting.progression_protected, false) as progression_protected,
      coalesce(setting.pain_flagged, false) as pain_flagged,
      setting.preferred_substitute_exercise_id,
      substitute.canonical_name as preferred_substitute_name,
      setting.manual_next_load,
      coalesce(setting.note, '') as note,
      performance.latest_load,
      case
        when coalesce(setting.progression_protected, false) then 'protected'
        when coalesce(setting.pain_flagged, false) then 'hold'
        when setting.manual_next_load is not null then 'override'
        when performance.session_exercise_id is null then 'no_data'
        when prescription.load_unit in ('bodyweight', 'none') then 'hold'
        when performance.can_increase then 'increase'
        else 'hold'
      end as recommendation_state,
      case
        when coalesce(setting.progression_protected, false) then null
        when coalesce(setting.pain_flagged, false) then performance.latest_load
        when setting.manual_next_load is not null then setting.manual_next_load
        when performance.session_exercise_id is null then null
        when prescription.load_unit in ('bodyweight', 'none') then null
        when performance.can_increase and prescription.load_unit = 'kg' then performance.latest_load + 2.5
        when performance.can_increase and prescription.load_unit = 'lb' then performance.latest_load + 5
        else performance.latest_load
      end as suggested_load,
      case
        when coalesce(setting.progression_protected, false) then 'Progression is protected for this exercise.'
        when coalesce(setting.pain_flagged, false) then 'Pain is flagged, so load progression is paused.'
        when setting.manual_next_load is not null then 'Using your manual next-load override.'
        when performance.session_exercise_id is null then 'No comparable submitted workout is available yet.'
        when prescription.load_unit in ('bodyweight', 'none') then 'This prescription does not use a numeric load.'
        when performance.can_increase then 'All prescribed sets reached the top of the rep range at or above target RIR.'
        else 'Holding the latest comparable load until all progression conditions are met.'
      end as reason
    from current_prescriptions as prescription
    left join public.exercise_progression_settings as setting
      on setting.user_id = p_user_id
     and setting.exercise_definition_id = prescription.exercise_definition_id
    left join public.exercise_definitions as substitute
      on substitute.id = setting.preferred_substitute_exercise_id
     and substitute.user_id = p_user_id
    left join lateral (
      select
        session_exercise.id as session_exercise_id,
        stats.latest_load,
        (
          result.status = 'completed'
          and stats.completed_count = session_exercise.working_sets
          and stats.all_top
          and stats.min_load is not null
          and stats.min_load = stats.max_load
        ) as can_increase
      from public.workout_results as result
      join public.workout_sessions as session
        on session.id = result.session_id
       and session.user_id = result.user_id
      join public.training_week_items as item
        on item.id = session.weekly_plan_item_id
       and item.user_id = result.user_id
      join public.workout_session_exercises as session_exercise
        on session_exercise.session_id = session.id
       and session_exercise.user_id = result.user_id
      join public.routine_version_prescriptions as historical_prescription
        on historical_prescription.routine_version_day_id = item.routine_version_day_id
       and historical_prescription.user_id = result.user_id
       and historical_prescription.position = session_exercise.position
      cross join lateral (
        select
          count(*) filter (where entry.completed)::integer as completed_count,
          min(entry.load_value) filter (where entry.completed) as min_load,
          max(entry.load_value) filter (where entry.completed) as max_load,
          max(entry.load_value) filter (where entry.completed) as latest_load,
          coalesce(bool_and(
            entry.repetitions >= session_exercise.rep_max
            and entry.rir >= session_exercise.rir_target
          ) filter (where entry.completed), false) as all_top
        from public.workout_set_entries as entry
        where entry.session_id = session.id
          and entry.session_exercise_id = session_exercise.id
          and entry.user_id = result.user_id
      ) as stats
      where result.user_id = p_user_id
        and historical_prescription.exercise_definition_id = prescription.exercise_definition_id
        and session_exercise.exercise_definition_id = historical_prescription.exercise_definition_id
        and session_exercise.load_unit = prescription.load_unit
        and stats.completed_count > 0
      order by result.submitted_at desc, result.id desc
      limit 1
    ) as performance on true
  )
  select jsonb_build_object(
    'recommendations', coalesce((
      select jsonb_agg(jsonb_build_object(
        'exerciseId', row.exercise_definition_id::text,
        'exerciseName', row.canonical_name,
        'loadUnit', row.load_unit,
        'state', row.recommendation_state,
        'latestLoad', row.latest_load,
        'suggestedLoad', row.suggested_load,
        'reason', row.reason,
        'setting', jsonb_build_object(
          'exerciseId', row.exercise_definition_id::text,
          'progressionProtected', row.progression_protected,
          'painFlagged', row.pain_flagged,
          'preferredSubstituteExerciseId', row.preferred_substitute_exercise_id::text,
          'preferredSubstituteName', row.preferred_substitute_name,
          'manualNextLoad', row.manual_next_load,
          'note', row.note
        )
      ) order by row.canonical_name, row.exercise_definition_id)
      from recommendation_rows as row
    ), '[]'::jsonb),
    'substituteOptions', coalesce((
      select jsonb_agg(jsonb_build_object(
        'exerciseId', exercise.id::text,
        'exerciseName', exercise.canonical_name
      ) order by exercise.canonical_name, exercise.id)
      from public.exercise_definitions as exercise
      where exercise.user_id = p_user_id
        and exercise.archived_at is null
        and exists (
          select 1
          from public.guidance_revisions as guidance
          where guidance.user_id = p_user_id
            and guidance.exercise_id = exercise.id
        )
    ), '[]'::jsonb),
    'corrections', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', correction.id::text,
        'kind', correction.kind,
        'delta', correction.delta,
        'reason', correction.reason,
        'reversesCorrectionId', correction.reverses_correction_id::text,
        'reversed', exists (
          select 1
          from public.progress_corrections as reversal
          where reversal.user_id = p_user_id
            and reversal.reverses_correction_id = correction.id
        ),
        'createdAt', correction.created_at
      ) order by correction.created_at desc, correction.id desc)
      from (
        select *
        from public.progress_corrections
        where user_id = p_user_id
        order by created_at desc, id desc
        limit 50
      ) as correction
    ), '[]'::jsonb)
  );
$$;

create or replace function public.get_progression_v1()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
begin
  return private.progression_payload(v_user_id);
end;
$$;

create or replace function public.update_progression_setting_v1(
  p_exercise_definition_id uuid,
  p_progression_protected boolean,
  p_pain_flagged boolean,
  p_preferred_substitute_exercise_id uuid,
  p_manual_next_load numeric,
  p_note text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
begin
  if not exists (
    select 1
    from public.exercise_definitions
    where id = p_exercise_definition_id
      and user_id = v_user_id
      and archived_at is null
  ) then
    raise exception using errcode = '42501', message = 'progression_exercise_not_found';
  end if;

  if p_preferred_substitute_exercise_id = p_exercise_definition_id then
    raise exception using errcode = '22023', message = 'progression_substitute_same_exercise';
  end if;

  if p_preferred_substitute_exercise_id is not null and not exists (
    select 1
    from public.exercise_definitions as exercise
    where exercise.id = p_preferred_substitute_exercise_id
      and exercise.user_id = v_user_id
      and exercise.archived_at is null
      and exists (
        select 1
        from public.guidance_revisions as guidance
        where guidance.exercise_id = exercise.id
          and guidance.user_id = v_user_id
      )
  ) then
    raise exception using errcode = '22023', message = 'progression_substitute_invalid';
  end if;

  if p_manual_next_load is not null and p_manual_next_load < 0 then
    raise exception using errcode = '22023', message = 'progression_manual_load_invalid';
  end if;
  if char_length(coalesce(p_note, '')) > 500 then
    raise exception using errcode = '22023', message = 'progression_note_too_long';
  end if;

  insert into public.exercise_progression_settings (
    user_id,
    exercise_definition_id,
    progression_protected,
    pain_flagged,
    preferred_substitute_exercise_id,
    manual_next_load,
    note,
    updated_at
  ) values (
    v_user_id,
    p_exercise_definition_id,
    coalesce(p_progression_protected, false),
    coalesce(p_pain_flagged, false),
    p_preferred_substitute_exercise_id,
    p_manual_next_load,
    coalesce(p_note, ''),
    clock_timestamp()
  )
  on conflict (user_id, exercise_definition_id) do update set
    progression_protected = excluded.progression_protected,
    pain_flagged = excluded.pain_flagged,
    preferred_substitute_exercise_id = excluded.preferred_substitute_exercise_id,
    manual_next_load = excluded.manual_next_load,
    note = excluded.note,
    updated_at = excluded.updated_at;

  return private.progression_payload(v_user_id);
end;
$$;

create or replace function public.apply_progress_correction_v1(
  p_kind text,
  p_delta integer,
  p_reason text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_timezone text;
  v_correction public.progress_corrections%rowtype;
begin
  if p_kind not in ('rr', 'xp') then
    raise exception using errcode = '22023', message = 'progress_correction_kind_invalid';
  end if;
  if p_delta is null or p_delta = 0 then
    raise exception using errcode = '22023', message = 'progress_correction_delta_invalid';
  end if;
  if char_length(btrim(coalesce(p_reason, ''))) not between 1 and 500 then
    raise exception using errcode = '22023', message = 'progress_correction_reason_invalid';
  end if;

  insert into public.progress_corrections (user_id, kind, delta, reason)
  values (v_user_id, p_kind, p_delta, btrim(p_reason))
  returning * into v_correction;

  if p_kind = 'rr' then
    insert into public.rr_ledger (user_id, source_type, source_id, delta)
    values (v_user_id, 'manual_correction', v_correction.id, p_delta);
  else
    insert into public.xp_ledger (user_id, source_type, source_id, delta)
    values (v_user_id, 'manual_correction', v_correction.id, p_delta);
  end if;

  select reward_timezone into v_timezone
  from public.profiles where id = v_user_id;
  perform private.refresh_progress_for_user(v_user_id, v_timezone);

  return jsonb_build_object(
    'account', private.progress_payload(v_user_id) -> 'account',
    'correction', jsonb_build_object(
      'id', v_correction.id::text,
      'kind', v_correction.kind,
      'delta', v_correction.delta,
      'reason', v_correction.reason,
      'reversesCorrectionId', null,
      'reversed', false,
      'createdAt', v_correction.created_at
    )
  );
end;
$$;

create or replace function public.reverse_progress_correction_v1(
  p_correction_id uuid,
  p_reason text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_timezone text;
  v_original public.progress_corrections%rowtype;
  v_reversal public.progress_corrections%rowtype;
begin
  select * into v_original
  from public.progress_corrections
  where id = p_correction_id and user_id = v_user_id
  for update;

  if not found then
    raise exception using errcode = '42501', message = 'progress_correction_not_found';
  end if;
  if v_original.reverses_correction_id is not null then
    raise exception using errcode = '22023', message = 'progress_correction_reversal_not_reversible';
  end if;
  if exists (
    select 1 from public.progress_corrections
    where user_id = v_user_id and reverses_correction_id = v_original.id
  ) then
    raise exception using errcode = '22023', message = 'progress_correction_already_reversed';
  end if;
  if char_length(btrim(coalesce(p_reason, ''))) not between 1 and 500 then
    raise exception using errcode = '22023', message = 'progress_correction_reason_invalid';
  end if;

  insert into public.progress_corrections (
    user_id, kind, delta, reason, reverses_correction_id
  ) values (
    v_user_id, v_original.kind, -v_original.delta, btrim(p_reason), v_original.id
  )
  returning * into v_reversal;

  if v_reversal.kind = 'rr' then
    insert into public.rr_ledger (user_id, source_type, source_id, delta)
    values (v_user_id, 'manual_correction', v_reversal.id, v_reversal.delta);
  else
    insert into public.xp_ledger (user_id, source_type, source_id, delta)
    values (v_user_id, 'manual_correction', v_reversal.id, v_reversal.delta);
  end if;

  select reward_timezone into v_timezone
  from public.profiles where id = v_user_id;
  perform private.refresh_progress_for_user(v_user_id, v_timezone);

  return jsonb_build_object(
    'account', private.progress_payload(v_user_id) -> 'account',
    'correction', jsonb_build_object(
      'id', v_reversal.id::text,
      'kind', v_reversal.kind,
      'delta', v_reversal.delta,
      'reason', v_reversal.reason,
      'reversesCorrectionId', v_reversal.reverses_correction_id::text,
      'reversed', false,
      'createdAt', v_reversal.created_at
    )
  );
end;
$$;

create or replace function public.start_workout_v1(p_plan_item_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_timezone text;
  v_local_date date;
  v_item record;
  v_session_id uuid;
begin
  select reward_timezone into v_timezone
  from public.profiles
  where id = v_user_id;
  v_local_date := (clock_timestamp() at time zone v_timezone)::date;

  select item.*, week.routine_version_id
  into v_item
  from public.training_week_items item
  join public.training_weeks week on week.id = item.week_id
  where item.id = p_plan_item_id and item.user_id = v_user_id
  for update of item;

  if not found then
    raise exception using errcode = '42501', message = 'workout_item_not_found';
  end if;
  if v_item.item_type <> 'workout' then
    raise exception using errcode = '22023', message = 'workout_item_is_rest';
  end if;
  if v_item.assigned_date <> v_local_date then
    raise exception using errcode = '22023', message = 'workout_not_today';
  end if;

  select id into v_session_id
  from public.workout_sessions
  where weekly_plan_item_id = p_plan_item_id and user_id = v_user_id;

  if v_session_id is not null then
    return jsonb_build_object('session', private.workout_session_payload(v_session_id, v_user_id));
  end if;

  insert into public.workout_sessions (
    user_id,
    weekly_plan_item_id,
    prescription_snapshot
  ) values (
    v_user_id,
    p_plan_item_id,
    jsonb_build_object(
      'routineVersionId', v_item.routine_version_id::text,
      'routineVersionDayId', v_item.routine_version_day_id::text
    )
  )
  returning id into v_session_id;

  insert into public.workout_session_exercises (
    session_id,
    user_id,
    position,
    exercise_definition_id,
    guidance_revision_id,
    title,
    priority,
    working_sets,
    rep_min,
    rep_max,
    rir_target,
    rest_seconds,
    load_unit,
    notes
  )
  select
    v_session_id,
    v_user_id,
    prescription.position,
    coalesce(setting.preferred_substitute_exercise_id, prescription.exercise_definition_id),
    coalesce(substitute_guidance.id, prescription.guidance_revision_id),
    coalesce(substitute.canonical_name, original.canonical_name),
    prescription.priority,
    prescription.working_sets,
    prescription.rep_min,
    prescription.rep_max,
    prescription.rir_target,
    prescription.rest_seconds,
    prescription.load_unit,
    prescription.notes
  from public.routine_version_prescriptions as prescription
  join public.exercise_definitions as original
    on original.id = prescription.exercise_definition_id
   and original.user_id = prescription.user_id
  left join public.exercise_progression_settings as setting
    on setting.user_id = v_user_id
   and setting.exercise_definition_id = prescription.exercise_definition_id
  left join public.exercise_definitions as substitute
    on substitute.id = setting.preferred_substitute_exercise_id
   and substitute.user_id = v_user_id
   and substitute.archived_at is null
  left join lateral (
    select guidance.id
    from public.guidance_revisions as guidance
    where guidance.user_id = v_user_id
      and guidance.exercise_id = substitute.id
    order by guidance.version_number desc, guidance.id desc
    limit 1
  ) as substitute_guidance on substitute.id is not null
  where prescription.routine_version_day_id = v_item.routine_version_day_id
    and prescription.user_id = v_user_id
  order by prescription.position;

  if not exists (
    select 1 from public.workout_session_exercises where session_id = v_session_id
  ) then
    raise exception using errcode = '22023', message = 'workout_has_no_prescriptions';
  end if;

  insert into public.workout_set_entries (
    session_id,
    session_exercise_id,
    user_id,
    set_index,
    load_unit
  )
  select
    v_session_id,
    exercise.id,
    v_user_id,
    generated.set_index,
    exercise.load_unit
  from public.workout_session_exercises as exercise
  cross join lateral generate_series(1, exercise.working_sets) as generated(set_index)
  where exercise.session_id = v_session_id
  order by exercise.position, generated.set_index;

  update public.training_week_items
  set lock_state = 'locked'
  where id = p_plan_item_id and user_id = v_user_id;

  return jsonb_build_object('session', private.workout_session_payload(v_session_id, v_user_id));
end;
$$;

revoke all on function public.get_progression_v1() from public, anon;
revoke all on function public.update_progression_setting_v1(uuid, boolean, boolean, uuid, numeric, text) from public, anon;
revoke all on function public.apply_progress_correction_v1(text, integer, text) from public, anon;
revoke all on function public.reverse_progress_correction_v1(uuid, text) from public, anon;
revoke all on function public.start_workout_v1(uuid) from public, anon;

grant execute on function public.get_progression_v1() to authenticated;
grant execute on function public.update_progression_setting_v1(uuid, boolean, boolean, uuid, numeric, text) to authenticated;
grant execute on function public.apply_progress_correction_v1(text, integer, text) to authenticated;
grant execute on function public.reverse_progress_correction_v1(uuid, text) to authenticated;
grant execute on function public.start_workout_v1(uuid) to authenticated;

commit;
