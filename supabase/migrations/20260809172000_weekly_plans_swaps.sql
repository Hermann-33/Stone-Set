begin;

create table public.training_weeks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  routine_version_id uuid not null,
  week_start date not null,
  week_end date not null,
  reward_timezone text not null,
  rank_config_version text not null default 'rank-v6',
  schedule_config_version text not null default 'schedule-v3',
  confirmed_swap_count integer not null default 0 check (confirmed_swap_count between 0 and 2),
  created_at timestamptz not null default clock_timestamp(),
  unique (user_id, week_start),
  unique (id, user_id),
  foreign key (routine_version_id, user_id)
    references public.routine_versions (id, user_id) on delete restrict,
  constraint training_weeks_monday_start check (extract(isodow from week_start) = 1),
  constraint training_weeks_seven_days check (week_end = week_start + 6),
  constraint training_weeks_rank_config check (rank_config_version = 'rank-v6'),
  constraint training_weeks_schedule_config check (schedule_config_version = 'schedule-v3')
);

create index training_weeks_owner_start_idx
  on public.training_weeks (user_id, week_start desc, id);
create index training_weeks_routine_version_idx
  on public.training_weeks (routine_version_id);

create table public.training_week_items (
  id uuid primary key default gen_random_uuid(),
  week_id uuid not null,
  user_id uuid not null,
  original_day_index integer not null check (original_day_index between 1 and 7),
  original_date date not null,
  assigned_date date not null,
  item_type text not null check (item_type in ('workout', 'rest')),
  routine_version_day_id uuid not null references public.routine_version_days (id) on delete restrict,
  allocated_rr integer not null check (allocated_rr >= 0),
  allocated_base_xp integer not null check (allocated_base_xp >= 0),
  allocated_missed_penalty_rr integer not null check (allocated_missed_penalty_rr >= 0),
  lock_state text not null default 'open' check (lock_state in ('open', 'locked')),
  created_at timestamptz not null default clock_timestamp(),
  unique (week_id, original_day_index),
  unique (week_id, original_date),
  constraint training_week_items_assigned_date_unique unique (week_id, assigned_date)
    deferrable initially deferred,
  unique (id, week_id, user_id),
  foreign key (week_id, user_id)
    references public.training_weeks (id, user_id) on delete cascade
);

create index training_week_items_owner_week_date_idx
  on public.training_week_items (user_id, week_id, assigned_date, id);
create index training_week_items_routine_day_idx
  on public.training_week_items (routine_version_day_id);

create table public.free_swap_wallets (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  balance integer not null default 0 check (balance >= 0),
  lifetime_granted integer not null default 0 check (lifetime_granted >= 0),
  lifetime_consumed integer not null default 0 check (lifetime_consumed >= 0),
  updated_at timestamptz not null default clock_timestamp(),
  constraint free_swap_wallet_totals check (lifetime_granted >= lifetime_consumed)
);

create table public.monthly_free_swap_grants (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  grant_month date not null,
  quantity integer not null default 2 check (quantity = 2),
  created_at timestamptz not null default clock_timestamp(),
  unique (user_id, grant_month),
  constraint monthly_free_swap_grants_month_start check (extract(day from grant_month) = 1)
);

create index monthly_free_swap_grants_owner_month_idx
  on public.monthly_free_swap_grants (user_id, grant_month desc);

create table public.weekly_swaps (
  id uuid primary key default gen_random_uuid(),
  week_id uuid not null,
  user_id uuid not null,
  swap_number integer not null check (swap_number between 1 and 2),
  first_item_id uuid not null,
  second_item_id uuid not null,
  first_date date not null,
  second_date date not null,
  payment_method text not null default 'free_credit' check (payment_method = 'free_credit'),
  created_at timestamptz not null default clock_timestamp(),
  unique (week_id, swap_number),
  foreign key (week_id, user_id)
    references public.training_weeks (id, user_id) on delete cascade,
  foreign key (first_item_id, week_id, user_id)
    references public.training_week_items (id, week_id, user_id) on delete restrict,
  foreign key (second_item_id, week_id, user_id)
    references public.training_week_items (id, week_id, user_id) on delete restrict,
  constraint weekly_swaps_distinct_items check (first_item_id <> second_item_id),
  constraint weekly_swaps_distinct_dates check (first_date <> second_date)
);

create index weekly_swaps_owner_week_idx
  on public.weekly_swaps (user_id, week_id, swap_number);

revoke all on table public.training_weeks from public, anon, authenticated, service_role;
revoke all on table public.training_week_items from public, anon, authenticated, service_role;
revoke all on table public.free_swap_wallets from public, anon, authenticated, service_role;
revoke all on table public.monthly_free_swap_grants from public, anon, authenticated, service_role;
revoke all on table public.weekly_swaps from public, anon, authenticated, service_role;

grant select on table public.training_weeks to authenticated;
grant select on table public.training_week_items to authenticated;
grant select on table public.free_swap_wallets to authenticated;
grant select on table public.monthly_free_swap_grants to authenticated;
grant select on table public.weekly_swaps to authenticated;

alter table public.training_weeks enable row level security;
alter table public.training_week_items enable row level security;
alter table public.free_swap_wallets enable row level security;
alter table public.monthly_free_swap_grants enable row level security;
alter table public.weekly_swaps enable row level security;

create policy training_weeks_owner_select
  on public.training_weeks for select to authenticated
  using (user_id = (select auth.uid()));
create policy training_week_items_owner_select
  on public.training_week_items for select to authenticated
  using (user_id = (select auth.uid()));
create policy free_swap_wallets_owner_select
  on public.free_swap_wallets for select to authenticated
  using (user_id = (select auth.uid()));
create policy monthly_free_swap_grants_owner_select
  on public.monthly_free_swap_grants for select to authenticated
  using (user_id = (select auth.uid()));
create policy weekly_swaps_owner_select
  on public.weekly_swaps for select to authenticated
  using (user_id = (select auth.uid()));

create or replace function private.ensure_monthly_free_swap_grant(
  p_user_id uuid,
  p_reward_timezone text
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_local_date date;
  v_grant_month date;
  v_inserted integer;
begin
  v_local_date := (clock_timestamp() at time zone p_reward_timezone)::date;
  v_grant_month := date_trunc('month', v_local_date::timestamp)::date;

  insert into public.free_swap_wallets (user_id)
  values (p_user_id)
  on conflict (user_id) do nothing;

  insert into public.monthly_free_swap_grants (user_id, grant_month, quantity)
  values (p_user_id, v_grant_month, 2)
  on conflict (user_id, grant_month) do nothing;

  get diagnostics v_inserted = row_count;
  if v_inserted = 1 then
    update public.free_swap_wallets
    set balance = balance + 2,
        lifetime_granted = lifetime_granted + 2,
        updated_at = clock_timestamp()
    where user_id = p_user_id;
  end if;
end;
$$;

create or replace function private.materialize_training_week_items(
  p_week_id uuid,
  p_user_id uuid,
  p_routine_version_id uuid,
  p_week_start date
)
returns void
language sql
security definer
set search_path = ''
as $$
  with source as (
    select
      d.id as routine_version_day_id,
      d.day_index,
      d.position,
      d.day_type,
      (p_week_start + (d.position - 1))::date as scheduled_date,
      case when d.day_type = 'workout' then 4 else 1 end as item_weight
    from public.routine_version_days as d
    where d.routine_version_id = p_routine_version_id
      and d.user_id = p_user_id
    order by d.position
  ),
  rr_exact as (
    select
      source.*,
      110::numeric * item_weight / sum(item_weight) over () as exact_value
    from source
  ),
  rr_floor as (
    select
      rr_exact.*,
      floor(exact_value)::integer as base_value,
      exact_value - floor(exact_value) as fractional_value
    from rr_exact
  ),
  rr_ranked as (
    select
      rr_floor.*,
      110 - sum(base_value) over () as remainder_count,
      row_number() over (order by fractional_value desc, scheduled_date asc) as remainder_rank
    from rr_floor
  ),
  rr_allocated as (
    select
      rr_ranked.*,
      base_value + case when remainder_rank <= remainder_count then 1 else 0 end as allocated_value
    from rr_ranked
  ),
  penalty_exact as (
    select
      source.routine_version_day_id,
      source.scheduled_date,
      95::numeric / count(*) over () as exact_value
    from source
    where source.day_type = 'workout'
  ),
  penalty_floor as (
    select
      penalty_exact.*,
      floor(exact_value)::integer as base_value,
      exact_value - floor(exact_value) as fractional_value
    from penalty_exact
  ),
  penalty_ranked as (
    select
      penalty_floor.*,
      95 - sum(base_value) over () as remainder_count,
      row_number() over (order by fractional_value desc, scheduled_date asc) as remainder_rank
    from penalty_floor
  ),
  penalty_allocated as (
    select
      penalty_ranked.routine_version_day_id,
      penalty_ranked.base_value
        + case when penalty_ranked.remainder_rank <= penalty_ranked.remainder_count then 1 else 0 end
        as allocated_value
    from penalty_ranked
  )
  insert into public.training_week_items (
    week_id,
    user_id,
    original_day_index,
    original_date,
    assigned_date,
    item_type,
    routine_version_day_id,
    allocated_rr,
    allocated_base_xp,
    allocated_missed_penalty_rr,
    lock_state
  )
  select
    p_week_id,
    p_user_id,
    rr_allocated.day_index,
    rr_allocated.scheduled_date,
    rr_allocated.scheduled_date,
    rr_allocated.day_type,
    rr_allocated.routine_version_day_id,
    rr_allocated.allocated_value,
    rr_allocated.allocated_value,
    coalesce(penalty_allocated.allocated_value, 0),
    'open'
  from rr_allocated
  left join penalty_allocated
    on penalty_allocated.routine_version_day_id = rr_allocated.routine_version_day_id
  order by rr_allocated.position;
$$;

create or replace function private.free_swap_wallet_payload(p_user_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'userId', wallet.user_id::text,
    'balance', wallet.balance,
    'lifetimeGranted', wallet.lifetime_granted,
    'lifetimeConsumed', wallet.lifetime_consumed
  )
  from public.free_swap_wallets as wallet
  where wallet.user_id = p_user_id;
$$;

create or replace function private.training_week_payload(
  p_week_id uuid,
  p_user_id uuid,
  p_local_date date
)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id', week.id::text,
    'userId', week.user_id::text,
    'routineVersionId', week.routine_version_id::text,
    'weekStart', week.week_start::text,
    'weekEnd', week.week_end::text,
    'rewardTimezone', week.reward_timezone,
    'rankConfigVersion', week.rank_config_version,
    'scheduleConfigVersion', week.schedule_config_version,
    'confirmedSwapCount', week.confirmed_swap_count,
    'items', coalesce((
      select jsonb_agg(
        jsonb_build_object(
          'id', item.id::text,
          'weekId', item.week_id::text,
          'routineVersionDayId', item.routine_version_day_id::text,
          'originalDayIndex', item.original_day_index,
          'originalDate', item.original_date::text,
          'currentDate', item.assigned_date::text,
          'itemType', item.item_type,
          'title', day.title,
          'purpose', nullif(day.purpose, ''),
          'allocatedRr', item.allocated_rr,
          'allocatedBaseXp', item.allocated_base_xp,
          'allocatedMissedPenaltyRr', item.allocated_missed_penalty_rr,
          'lockState', item.lock_state,
          'isToday', item.assigned_date = p_local_date
        )
        order by item.assigned_date, item.original_day_index
      )
      from public.training_week_items as item
      join public.routine_version_days as day
        on day.id = item.routine_version_day_id
      where item.week_id = week.id
        and item.user_id = p_user_id
    ), '[]'::jsonb)
  )
  from public.training_weeks as week
  where week.id = p_week_id
    and week.user_id = p_user_id;
$$;

create or replace function public.get_or_create_current_week_v1()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_timezone text;
  v_local_date date;
  v_week_start date;
  v_week_end date;
  v_routine_version_id uuid;
  v_week_id uuid;
  v_created boolean := false;
begin
  select profile.reward_timezone
  into v_timezone
  from public.profiles as profile
  where profile.id = v_user_id;

  if v_timezone is null then
    raise exception using errcode = '42501', message = 'profile_not_available';
  end if;

  v_local_date := (clock_timestamp() at time zone v_timezone)::date;
  v_week_start := v_local_date - (extract(isodow from v_local_date)::integer - 1);
  v_week_end := v_week_start + 6;

  perform private.ensure_monthly_free_swap_grant(v_user_id, v_timezone);

  select week.id
  into v_week_id
  from public.training_weeks as week
  where week.user_id = v_user_id
    and week.week_start = v_week_start;

  if v_week_id is null then
    select version.id
    into v_routine_version_id
    from public.routine_versions as version
    where version.user_id = v_user_id
      and version.effective_date <= v_week_start
    order by version.effective_date desc, version.version_number desc, version.id desc
    limit 1;

    if v_routine_version_id is null then
      return jsonb_build_object(
        'status', 'no_published_routine',
        'wallet', private.free_swap_wallet_payload(v_user_id)
      );
    end if;

    insert into public.training_weeks (
      user_id,
      routine_version_id,
      week_start,
      week_end,
      reward_timezone
    )
    values (
      v_user_id,
      v_routine_version_id,
      v_week_start,
      v_week_end,
      v_timezone
    )
    on conflict (user_id, week_start) do nothing
    returning id into v_week_id;

    if v_week_id is not null then
      v_created := true;
    else
      select week.id
      into v_week_id
      from public.training_weeks as week
      where week.user_id = v_user_id
        and week.week_start = v_week_start;
    end if;
  end if;

  if v_created then
    perform private.materialize_training_week_items(
      v_week_id,
      v_user_id,
      v_routine_version_id,
      v_week_start
    );
  end if;

  update public.training_week_items
  set lock_state = 'locked'
  where week_id = v_week_id
    and user_id = v_user_id
    and assigned_date < v_local_date
    and lock_state = 'open';

  return jsonb_build_object(
    'status', 'ready',
    'week', private.training_week_payload(v_week_id, v_user_id, v_local_date),
    'wallet', private.free_swap_wallet_payload(v_user_id)
  );
end;
$$;

create or replace function public.confirm_weekly_swap_v1(
  p_week_id uuid,
  p_first_item_id uuid,
  p_second_item_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_timezone text;
  v_local_date date;
  v_week_start date;
  v_week public.training_weeks%rowtype;
  v_first public.training_week_items%rowtype;
  v_second public.training_week_items%rowtype;
  v_wallet public.free_swap_wallets%rowtype;
  v_swap public.weekly_swaps%rowtype;
begin
  if p_first_item_id = p_second_item_id then
    raise exception using errcode = '22023', message = 'weekly_swap_invalid_selection';
  end if;

  select profile.reward_timezone
  into v_timezone
  from public.profiles as profile
  where profile.id = v_user_id;

  v_local_date := (clock_timestamp() at time zone v_timezone)::date;
  v_week_start := v_local_date - (extract(isodow from v_local_date)::integer - 1);

  select week.*
  into v_week
  from public.training_weeks as week
  where week.id = p_week_id
    and week.user_id = v_user_id
  for update;

  if not found or v_week.week_start <> v_week_start then
    raise exception using errcode = '22023', message = 'weekly_swap_not_current';
  end if;

  update public.training_week_items
  set lock_state = 'locked'
  where week_id = p_week_id
    and user_id = v_user_id
    and assigned_date < v_local_date
    and lock_state = 'open';

  perform 1
  from public.training_week_items as item
  where item.week_id = p_week_id
    and item.user_id = v_user_id
    and item.id in (p_first_item_id, p_second_item_id)
  order by item.id
  for update;

  select item.*
  into v_first
  from public.training_week_items as item
  where item.id = p_first_item_id
    and item.week_id = p_week_id
    and item.user_id = v_user_id;

  select item.*
  into v_second
  from public.training_week_items as item
  where item.id = p_second_item_id
    and item.week_id = p_week_id
    and item.user_id = v_user_id;

  if v_first.id is null or v_second.id is null then
    raise exception using errcode = '22023', message = 'weekly_swap_invalid_selection';
  end if;

  if v_first.lock_state <> 'open'
     or v_second.lock_state <> 'open'
     or v_first.assigned_date < v_local_date
     or v_second.assigned_date < v_local_date then
    raise exception using errcode = '22023', message = 'weekly_item_locked';
  end if;

  if v_week.confirmed_swap_count >= 2 then
    raise exception using errcode = '22023', message = 'weekly_swap_limit_reached';
  end if;

  select wallet.*
  into v_wallet
  from public.free_swap_wallets as wallet
  where wallet.user_id = v_user_id
  for update;

  if v_wallet.user_id is null or v_wallet.balance < 1 then
    raise exception using errcode = '22023', message = 'free_swap_unavailable';
  end if;

  set constraints training_week_items_assigned_date_unique deferred;

  update public.training_week_items
  set assigned_date = case
    when id = p_first_item_id then v_second.assigned_date
    when id = p_second_item_id then v_first.assigned_date
    else assigned_date
  end
  where id in (p_first_item_id, p_second_item_id)
    and week_id = p_week_id
    and user_id = v_user_id;

  update public.free_swap_wallets
  set balance = balance - 1,
      lifetime_consumed = lifetime_consumed + 1,
      updated_at = clock_timestamp()
  where user_id = v_user_id;

  update public.training_weeks
  set confirmed_swap_count = confirmed_swap_count + 1
  where id = p_week_id
    and user_id = v_user_id
  returning * into v_week;

  insert into public.weekly_swaps (
    week_id,
    user_id,
    swap_number,
    first_item_id,
    second_item_id,
    first_date,
    second_date
  )
  values (
    p_week_id,
    v_user_id,
    v_week.confirmed_swap_count,
    p_first_item_id,
    p_second_item_id,
    v_first.assigned_date,
    v_second.assigned_date
  )
  returning * into v_swap;

  return jsonb_build_object(
    'week', private.training_week_payload(p_week_id, v_user_id, v_local_date),
    'wallet', private.free_swap_wallet_payload(v_user_id),
    'swap', jsonb_build_object(
      'id', v_swap.id::text,
      'weekId', v_swap.week_id::text,
      'userId', v_swap.user_id::text,
      'swapNumber', v_swap.swap_number,
      'firstItemId', v_swap.first_item_id::text,
      'secondItemId', v_swap.second_item_id::text,
      'firstDate', v_swap.first_date::text,
      'secondDate', v_swap.second_date::text,
      'createdAt', v_swap.created_at::text
    )
  );
end;
$$;

revoke all on function public.get_or_create_current_week_v1() from public, anon, authenticated, service_role;
revoke all on function public.confirm_weekly_swap_v1(uuid, uuid, uuid) from public, anon, authenticated, service_role;
grant execute on function public.get_or_create_current_week_v1() to authenticated;
grant execute on function public.confirm_weekly_swap_v1(uuid, uuid, uuid) to authenticated;

commit;
