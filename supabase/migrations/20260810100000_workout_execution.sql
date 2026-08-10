begin;

create table public.workout_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  weekly_plan_item_id uuid not null unique references public.training_week_items (id) on delete restrict,
  state text not null default 'active' check (state in ('active', 'submitted')),
  started_at timestamptz not null default clock_timestamp(),
  submitted_at timestamptz,
  prescription_snapshot jsonb not null check (jsonb_typeof(prescription_snapshot) = 'object'),
  last_client_revision bigint not null default 0 check (last_client_revision >= 0),
  created_at timestamptz not null default clock_timestamp(),
  updated_at timestamptz not null default clock_timestamp(),
  unique (id, user_id)
);

create index workout_sessions_owner_state_idx
  on public.workout_sessions (user_id, state, started_at desc, id);

create table public.workout_session_exercises (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.workout_sessions (id) on delete cascade,
  user_id uuid not null,
  position integer not null check (position > 0),
  exercise_definition_id uuid not null references public.exercise_definitions (id) on delete restrict,
  guidance_revision_id uuid not null references public.guidance_revisions (id) on delete restrict,
  title text not null,
  priority boolean not null default false,
  working_sets integer not null check (working_sets between 1 and 20),
  rep_min integer not null check (rep_min between 0 and 100),
  rep_max integer not null check (rep_max between 0 and 100 and rep_max >= rep_min),
  rir_target integer not null check (rir_target between 0 and 20),
  rest_seconds integer not null check (rest_seconds between 0 and 3600),
  load_unit text not null check (load_unit in ('kg', 'lb', 'bodyweight', 'none')),
  notes text not null default '',
  unique (session_id, position),
  unique (id, session_id, user_id),
  foreign key (session_id, user_id)
    references public.workout_sessions (id, user_id) on delete cascade
);

create index workout_session_exercises_owner_session_idx
  on public.workout_session_exercises (user_id, session_id, position);

create table public.workout_set_entries (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null,
  session_exercise_id uuid not null,
  user_id uuid not null,
  set_index integer not null check (set_index between 1 and 20),
  load_value numeric(10,3),
  load_unit text not null check (load_unit in ('kg', 'lb', 'bodyweight', 'none')),
  repetitions integer check (repetitions between 0 and 100),
  rir integer check (rir between 0 and 20),
  completed boolean not null default false,
  client_revision bigint not null default 0 check (client_revision >= 0),
  updated_at timestamptz not null default clock_timestamp(),
  unique (session_exercise_id, set_index),
  foreign key (session_exercise_id, session_id, user_id)
    references public.workout_session_exercises (id, session_id, user_id) on delete cascade
);

create index workout_set_entries_owner_session_idx
  on public.workout_set_entries (user_id, session_id, session_exercise_id, set_index);

create table public.workout_results (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null unique,
  user_id uuid not null,
  status text not null check (status in ('completed', 'partial')),
  planned_sets integer not null check (planned_sets > 0),
  completed_sets integer not null check (completed_sets > 0 and completed_sets <= planned_sets),
  submitted_at timestamptz not null default clock_timestamp(),
  foreign key (session_id, user_id)
    references public.workout_sessions (id, user_id) on delete restrict
);

create index workout_results_owner_submitted_idx
  on public.workout_results (user_id, submitted_at desc, id);

revoke all on table public.workout_sessions from public, anon, authenticated, service_role;
revoke all on table public.workout_session_exercises from public, anon, authenticated, service_role;
revoke all on table public.workout_set_entries from public, anon, authenticated, service_role;
revoke all on table public.workout_results from public, anon, authenticated, service_role;

grant select on table public.workout_sessions to authenticated;
grant select on table public.workout_session_exercises to authenticated;
grant select on table public.workout_set_entries to authenticated;
grant select on table public.workout_results to authenticated;

alter table public.workout_sessions enable row level security;
alter table public.workout_session_exercises enable row level security;
alter table public.workout_set_entries enable row level security;
alter table public.workout_results enable row level security;

create policy workout_sessions_owner_select
  on public.workout_sessions for select to authenticated
  using (user_id = (select auth.uid()));
create policy workout_session_exercises_owner_select
  on public.workout_session_exercises for select to authenticated
  using (user_id = (select auth.uid()));
create policy workout_set_entries_owner_select
  on public.workout_set_entries for select to authenticated
  using (user_id = (select auth.uid()));
create policy workout_results_owner_select
  on public.workout_results for select to authenticated
  using (user_id = (select auth.uid()));

create or replace function private.workout_session_payload(
  p_session_id uuid,
  p_user_id uuid
)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id', s.id::text,
    'userId', s.user_id::text,
    'planItemId', s.weekly_plan_item_id::text,
    'state', s.state,
    'startedAt', s.started_at,
    'lastClientRevision', s.last_client_revision,
    'exercises', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'id', e.id::text,
          'position', e.position,
          'exerciseDefinitionId', e.exercise_definition_id::text,
          'guidanceRevisionId', e.guidance_revision_id::text,
          'title', e.title,
          'priority', e.priority,
          'workingSets', e.working_sets,
          'repMin', e.rep_min,
          'repMax', e.rep_max,
          'rirTarget', e.rir_target,
          'restSeconds', e.rest_seconds,
          'loadUnit', e.load_unit,
          'notes', e.notes
        ) order by e.position
      )
      from public.workout_session_exercises e
      where e.session_id = s.id and e.user_id = p_user_id
    ), '[]'::jsonb),
    'sets', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'sessionExerciseId', se.session_exercise_id::text,
          'setIndex', se.set_index,
          'loadValue', se.load_value,
          'loadUnit', se.load_unit,
          'repetitions', se.repetitions,
          'rir', se.rir,
          'completed', se.completed,
          'clientRevision', se.client_revision
        ) order by ex.position, se.set_index
      )
      from public.workout_set_entries se
      join public.workout_session_exercises ex on ex.id = se.session_exercise_id
      where se.session_id = s.id and se.user_id = p_user_id
    ), '[]'::jsonb)
  )
  from public.workout_sessions s
  where s.id = p_session_id and s.user_id = p_user_id;
$$;

create or replace function private.apply_workout_snapshot(
  p_user_id uuid,
  p_session_id uuid,
  p_client_revision bigint,
  p_sets jsonb
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_session public.workout_sessions%rowtype;
  v_set jsonb;
  v_exercise_id uuid;
  v_set_index integer;
  v_load_unit text;
  v_load_value numeric;
  v_repetitions integer;
  v_rir integer;
  v_completed boolean;
begin
  if p_client_revision is null or p_client_revision < 0 then
    raise exception using errcode = '22023', message = 'invalid_client_revision';
  end if;
  if jsonb_typeof(p_sets) <> 'array' then
    raise exception using errcode = '22023', message = 'invalid_set_payload';
  end if;

  select * into v_session
  from public.workout_sessions
  where id = p_session_id and user_id = p_user_id
  for update;

  if not found then
    raise exception using errcode = '42501', message = 'workout_session_not_found';
  end if;
  if v_session.state <> 'active' then
    raise exception using errcode = '22023', message = 'workout_already_submitted';
  end if;
  if p_client_revision <= v_session.last_client_revision then
    return;
  end if;

  for v_set in select value from jsonb_array_elements(p_sets)
  loop
    begin
      v_exercise_id := (v_set ->> 'sessionExerciseId')::uuid;
      v_set_index := (v_set ->> 'setIndex')::integer;
      v_load_unit := coalesce(v_set ->> 'loadUnit', 'none');
      v_load_value := nullif(v_set ->> 'loadValue', '')::numeric;
      v_repetitions := nullif(v_set ->> 'repetitions', '')::integer;
      v_rir := nullif(v_set ->> 'rir', '')::integer;
      v_completed := coalesce((v_set ->> 'completed')::boolean, false);
    exception when others then
      raise exception using errcode = '22023', message = 'invalid_set_payload';
    end;

    if not exists (
      select 1
      from public.workout_set_entries se
      where se.session_id = p_session_id
        and se.user_id = p_user_id
        and se.session_exercise_id = v_exercise_id
        and se.set_index = v_set_index
    ) then
      raise exception using errcode = '22023', message = 'unknown_workout_set';
    end if;
    if v_load_unit not in ('kg', 'lb', 'bodyweight', 'none')
      or v_load_value is not null and v_load_value < 0
      or v_repetitions is not null and (v_repetitions < 0 or v_repetitions > 100)
      or v_rir is not null and (v_rir < 0 or v_rir > 20) then
      raise exception using errcode = '22023', message = 'invalid_set_values';
    end if;

    update public.workout_set_entries
    set load_value = v_load_value,
        load_unit = v_load_unit,
        repetitions = v_repetitions,
        rir = v_rir,
        completed = v_completed,
        client_revision = p_client_revision,
        updated_at = clock_timestamp()
    where session_id = p_session_id
      and user_id = p_user_id
      and session_exercise_id = v_exercise_id
      and set_index = v_set_index;
  end loop;

  update public.workout_sessions
  set last_client_revision = p_client_revision,
      updated_at = clock_timestamp()
  where id = p_session_id and user_id = p_user_id;
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
  )
  values (
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
    p.position,
    p.exercise_definition_id,
    p.guidance_revision_id,
    e.canonical_name,
    p.priority,
    p.working_sets,
    p.rep_min,
    p.rep_max,
    p.rir_target,
    p.rest_seconds,
    p.load_unit,
    p.notes
  from public.routine_version_prescriptions p
  join public.exercise_definitions e on e.id = p.exercise_definition_id
  where p.routine_version_day_id = v_item.routine_version_day_id
    and p.user_id = v_user_id
  order by p.position;

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
    e.id,
    v_user_id,
    generated.set_index,
    e.load_unit
  from public.workout_session_exercises e
  cross join lateral generate_series(1, e.working_sets) as generated(set_index)
  where e.session_id = v_session_id
  order by e.position, generated.set_index;

  update public.training_week_items
  set lock_state = 'locked'
  where id = p_plan_item_id and user_id = v_user_id;

  return jsonb_build_object('session', private.workout_session_payload(v_session_id, v_user_id));
end;
$$;

create or replace function public.sync_workout_v1(
  p_session_id uuid,
  p_client_revision bigint,
  p_sets jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
begin
  perform private.apply_workout_snapshot(v_user_id, p_session_id, p_client_revision, p_sets);
  return jsonb_build_object('session', private.workout_session_payload(p_session_id, v_user_id));
end;
$$;

create or replace function public.submit_workout_v1(
  p_session_id uuid,
  p_client_revision bigint,
  p_sets jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_session public.workout_sessions%rowtype;
  v_result public.workout_results%rowtype;
  v_planned integer;
  v_completed integer;
begin
  select * into v_session
  from public.workout_sessions
  where id = p_session_id and user_id = v_user_id
  for update;

  if not found then
    raise exception using errcode = '42501', message = 'workout_session_not_found';
  end if;

  if v_session.state = 'submitted' then
    select * into v_result
    from public.workout_results
    where session_id = p_session_id and user_id = v_user_id;
    return jsonb_build_object(
      'session', private.workout_session_payload(p_session_id, v_user_id),
      'result', jsonb_build_object(
        'id', v_result.id::text,
        'sessionId', v_result.session_id::text,
        'status', v_result.status,
        'plannedSets', v_result.planned_sets,
        'completedSets', v_result.completed_sets,
        'submittedAt', v_result.submitted_at
      )
    );
  end if;

  perform private.apply_workout_snapshot(v_user_id, p_session_id, p_client_revision, p_sets);

  select count(*)::integer,
         count(*) filter (where completed)::integer
  into v_planned, v_completed
  from public.workout_set_entries
  where session_id = p_session_id and user_id = v_user_id;

  if v_completed = 0 then
    raise exception using errcode = '22023', message = 'workout_no_completed_sets';
  end if;

  insert into public.workout_results (
    session_id,
    user_id,
    status,
    planned_sets,
    completed_sets
  ) values (
    p_session_id,
    v_user_id,
    case when v_completed = v_planned then 'completed' else 'partial' end,
    v_planned,
    v_completed
  )
  returning * into v_result;

  update public.workout_sessions
  set state = 'submitted',
      submitted_at = v_result.submitted_at,
      updated_at = clock_timestamp()
  where id = p_session_id and user_id = v_user_id;

  return jsonb_build_object(
    'session', private.workout_session_payload(p_session_id, v_user_id),
    'result', jsonb_build_object(
      'id', v_result.id::text,
      'sessionId', v_result.session_id::text,
      'status', v_result.status,
      'plannedSets', v_result.planned_sets,
      'completedSets', v_result.completed_sets,
      'submittedAt', v_result.submitted_at
    )
  );
end;
$$;

revoke all on function public.start_workout_v1(uuid) from public, anon;
revoke all on function public.sync_workout_v1(uuid, bigint, jsonb) from public, anon;
revoke all on function public.submit_workout_v1(uuid, bigint, jsonb) from public, anon;
grant execute on function public.start_workout_v1(uuid) to authenticated;
grant execute on function public.sync_workout_v1(uuid, bigint, jsonb) to authenticated;
grant execute on function public.submit_workout_v1(uuid, bigint, jsonb) to authenticated;

commit;
