begin;

create table public.rank_definitions (
  rank_id text primary key,
  display_name text not null,
  minimum_rr integer not null unique check (minimum_rr >= 0),
  display_order integer not null unique check (display_order > 0)
);

insert into public.rank_definitions (rank_id, display_name, minimum_rr, display_order) values
  ('bronze_i', 'Bronze I', 0, 1),
  ('bronze_ii', 'Bronze II', 100, 2),
  ('bronze_iii', 'Bronze III', 200, 3),
  ('silver_i', 'Silver I', 325, 4),
  ('silver_ii', 'Silver II', 475, 5),
  ('silver_iii', 'Silver III', 650, 6),
  ('gold_i', 'Gold I', 825, 7),
  ('gold_ii', 'Gold II', 1025, 8),
  ('gold_iii', 'Gold III', 1250, 9),
  ('platinum_i', 'Platinum I', 1500, 10),
  ('platinum_ii', 'Platinum II', 1775, 11),
  ('platinum_iii', 'Platinum III', 2075, 12),
  ('diamond_i', 'Diamond I', 2400, 13),
  ('diamond_ii', 'Diamond II', 2750, 14),
  ('diamond_iii', 'Diamond III', 3125, 15),
  ('elite', 'Elite', 3525, 16),
  ('champion', 'Champion', 3950, 17),
  ('apex', 'Apex', 4400, 18),
  ('prodigy', 'Prodigy', 4900, 19),
  ('adonis', 'Adonis', 5500, 20);

create table public.rank_accounts (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  rr_balance integer not null default 0 check (rr_balance >= 0),
  lifetime_xp integer not null default 0 check (lifetime_xp >= 0),
  rank_id text not null default 'bronze_i' references public.rank_definitions (rank_id) on delete restrict,
  updated_at timestamptz not null default clock_timestamp()
);

create table public.rr_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  source_type text not null check (source_type in ('workout_reward', 'rest_reward', 'missed_workout', 'paid_swap')),
  source_id uuid not null,
  delta integer not null check (delta <> 0),
  created_at timestamptz not null default clock_timestamp(),
  unique (user_id, source_type, source_id)
);

create index rr_ledger_owner_created_idx
  on public.rr_ledger (user_id, created_at desc, id);

create table public.xp_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  source_type text not null check (source_type in ('workout_reward', 'rest_reward')),
  source_id uuid not null,
  delta integer not null check (delta > 0),
  created_at timestamptz not null default clock_timestamp(),
  unique (user_id, source_type, source_id)
);

create index xp_ledger_owner_created_idx
  on public.xp_ledger (user_id, created_at desc, id);

revoke all on table public.rank_definitions from public, anon, authenticated, service_role;
revoke all on table public.rank_accounts from public, anon, authenticated, service_role;
revoke all on table public.rr_ledger from public, anon, authenticated, service_role;
revoke all on table public.xp_ledger from public, anon, authenticated, service_role;

grant select on table public.rank_definitions to authenticated;
grant select on table public.rank_accounts to authenticated;
grant select on table public.rr_ledger to authenticated;
grant select on table public.xp_ledger to authenticated;

alter table public.rank_accounts enable row level security;
alter table public.rr_ledger enable row level security;
alter table public.xp_ledger enable row level security;

create policy rank_accounts_owner_select
  on public.rank_accounts for select to authenticated
  using (user_id = (select auth.uid()));
create policy rr_ledger_owner_select
  on public.rr_ledger for select to authenticated
  using (user_id = (select auth.uid()));
create policy xp_ledger_owner_select
  on public.xp_ledger for select to authenticated
  using (user_id = (select auth.uid()));

create or replace function private.refresh_progress_for_user(
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
  v_rr integer;
  v_xp integer;
  v_rank_id text;
begin
  v_local_date := (clock_timestamp() at time zone p_reward_timezone)::date;

  insert into public.rank_accounts (user_id)
  values (p_user_id)
  on conflict (user_id) do nothing;

  insert into public.rr_ledger (user_id, source_type, source_id, delta, created_at)
  select
    result.user_id,
    'workout_reward',
    result.id,
    floor(item.allocated_rr::numeric * result.completed_sets / result.planned_sets)::integer,
    result.submitted_at
  from public.workout_results as result
  join public.workout_sessions as session
    on session.id = result.session_id and session.user_id = result.user_id
  join public.training_week_items as item
    on item.id = session.weekly_plan_item_id and item.user_id = result.user_id
  where result.user_id = p_user_id
    and floor(item.allocated_rr::numeric * result.completed_sets / result.planned_sets)::integer <> 0
  on conflict (user_id, source_type, source_id) do nothing;

  insert into public.xp_ledger (user_id, source_type, source_id, delta, created_at)
  select
    result.user_id,
    'workout_reward',
    result.id,
    floor(item.allocated_base_xp::numeric * result.completed_sets / result.planned_sets)::integer,
    result.submitted_at
  from public.workout_results as result
  join public.workout_sessions as session
    on session.id = result.session_id and session.user_id = result.user_id
  join public.training_week_items as item
    on item.id = session.weekly_plan_item_id and item.user_id = result.user_id
  where result.user_id = p_user_id
    and floor(item.allocated_base_xp::numeric * result.completed_sets / result.planned_sets)::integer > 0
  on conflict (user_id, source_type, source_id) do nothing;

  insert into public.rr_ledger (user_id, source_type, source_id, delta, created_at)
  select
    item.user_id,
    'rest_reward',
    item.id,
    item.allocated_rr,
    (item.assigned_date::timestamp at time zone p_reward_timezone)
  from public.training_week_items as item
  where item.user_id = p_user_id
    and item.item_type = 'rest'
    and item.assigned_date <= v_local_date
    and item.allocated_rr <> 0
  on conflict (user_id, source_type, source_id) do nothing;

  insert into public.xp_ledger (user_id, source_type, source_id, delta, created_at)
  select
    item.user_id,
    'rest_reward',
    item.id,
    item.allocated_base_xp,
    (item.assigned_date::timestamp at time zone p_reward_timezone)
  from public.training_week_items as item
  where item.user_id = p_user_id
    and item.item_type = 'rest'
    and item.assigned_date <= v_local_date
    and item.allocated_base_xp > 0
  on conflict (user_id, source_type, source_id) do nothing;

  insert into public.rr_ledger (user_id, source_type, source_id, delta, created_at)
  select
    item.user_id,
    'missed_workout',
    item.id,
    -item.allocated_missed_penalty_rr,
    ((item.assigned_date + 1)::timestamp at time zone p_reward_timezone)
  from public.training_week_items as item
  where item.user_id = p_user_id
    and item.item_type = 'workout'
    and item.assigned_date < v_local_date
    and item.allocated_missed_penalty_rr > 0
    and not exists (
      select 1
      from public.workout_sessions as session
      where session.user_id = p_user_id
        and session.weekly_plan_item_id = item.id
    )
  on conflict (user_id, source_type, source_id) do nothing;

  select greatest(0, coalesce(sum(entry.delta), 0))::integer
  into v_rr
  from public.rr_ledger as entry
  where entry.user_id = p_user_id;

  select greatest(0, coalesce(sum(entry.delta), 0))::integer
  into v_xp
  from public.xp_ledger as entry
  where entry.user_id = p_user_id;

  select definition.rank_id
  into v_rank_id
  from public.rank_definitions as definition
  where definition.minimum_rr <= v_rr
  order by definition.minimum_rr desc
  limit 1;

  update public.rank_accounts
  set rr_balance = v_rr,
      lifetime_xp = v_xp,
      rank_id = coalesce(v_rank_id, 'bronze_i'),
      updated_at = clock_timestamp()
  where user_id = p_user_id;
end;
$$;

create or replace function private.progress_payload(p_user_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with account_state as (
    select
      account.*,
      current_rank.minimum_rr as current_minimum,
      next_rank.rank_id as next_rank_id,
      next_rank.minimum_rr as next_minimum
    from public.rank_accounts as account
    join public.rank_definitions as current_rank on current_rank.rank_id = account.rank_id
    left join public.rank_definitions as next_rank
      on next_rank.display_order = current_rank.display_order + 1
    where account.user_id = p_user_id
  )
  select jsonb_build_object(
    'account', jsonb_build_object(
      'userId', state.user_id::text,
      'rrBalance', state.rr_balance,
      'lifetimeXp', state.lifetime_xp,
      'rankId', state.rank_id,
      'currentMinimum', state.current_minimum,
      'nextRankId', state.next_rank_id,
      'nextMinimum', state.next_minimum,
      'progress', case
        when state.next_minimum is null then 1.0
        else least(1.0, greatest(0.0,
          (state.rr_balance - state.current_minimum)::numeric /
          nullif(state.next_minimum - state.current_minimum, 0)
        ))
      end
    ),
    'ranks', (
      select jsonb_agg(jsonb_build_object(
        'id', definition.rank_id,
        'displayName', definition.display_name,
        'minimumRr', definition.minimum_rr
      ) order by definition.display_order)
      from public.rank_definitions as definition
    ),
    'transactions', coalesce((
      select jsonb_agg(transaction_row.payload order by transaction_row.created_at desc, transaction_row.id desc)
      from (
        select
          entry.id,
          entry.created_at,
          jsonb_build_object(
            'id', entry.id::text,
            'kind', 'rr',
            'sourceType', entry.source_type,
            'sourceId', entry.source_id::text,
            'delta', entry.delta,
            'createdAt', entry.created_at
          ) as payload
        from public.rr_ledger as entry
        where entry.user_id = p_user_id
        union all
        select
          entry.id,
          entry.created_at,
          jsonb_build_object(
            'id', entry.id::text,
            'kind', 'xp',
            'sourceType', entry.source_type,
            'sourceId', entry.source_id::text,
            'delta', entry.delta,
            'createdAt', entry.created_at
          ) as payload
        from public.xp_ledger as entry
        where entry.user_id = p_user_id
        order by created_at desc, id desc
        limit 50
      ) as transaction_row
    ), '[]'::jsonb),
    'workouts', coalesce((
      select jsonb_agg(jsonb_build_object(
        'resultId', result.id::text,
        'planItemId', item.id::text,
        'date', item.assigned_date::text,
        'status', result.status,
        'plannedSets', result.planned_sets,
        'completedSets', result.completed_sets,
        'submittedAt', result.submitted_at
      ) order by result.submitted_at desc, result.id desc)
      from public.workout_results as result
      join public.workout_sessions as session
        on session.id = result.session_id and session.user_id = result.user_id
      join public.training_week_items as item
        on item.id = session.weekly_plan_item_id and item.user_id = result.user_id
      where result.user_id = p_user_id
    ), '[]'::jsonb)
  )
  from account_state as state;
$$;

create or replace function public.get_progress_v1()
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_timezone text;
begin
  select profile.reward_timezone
  into v_timezone
  from public.profiles as profile
  where profile.id = v_user_id;

  if v_timezone is null then
    raise exception using errcode = '42501', message = 'profile_not_available';
  end if;

  perform private.refresh_progress_for_user(v_user_id, v_timezone);
  return private.progress_payload(v_user_id);
end;
$$;

alter table public.weekly_swaps
  drop constraint if exists weekly_swaps_payment_method_check;
alter table public.weekly_swaps
  add constraint weekly_swaps_payment_method_check
  check (payment_method in ('free_credit', 'rr'));

create or replace function public.confirm_weekly_swap_v2(
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
  v_free_balance integer;
  v_rr_balance integer;
  v_swap_count integer;
  v_swap_id uuid;
  v_result jsonb;
begin
  select profile.reward_timezone
  into v_timezone
  from public.profiles as profile
  where profile.id = v_user_id;

  if v_timezone is null then
    raise exception using errcode = '42501', message = 'profile_not_available';
  end if;

  perform private.ensure_monthly_free_swap_grant(v_user_id, v_timezone);

  select wallet.balance
  into v_free_balance
  from public.free_swap_wallets as wallet
  where wallet.user_id = v_user_id
  for update;

  if coalesce(v_free_balance, 0) > 0 then
    v_result := public.confirm_weekly_swap_v1(p_week_id, p_first_item_id, p_second_item_id);
    return v_result || jsonb_build_object('paymentMethod', 'free_credit', 'rrCharged', 0);
  end if;

  perform private.refresh_progress_for_user(v_user_id, v_timezone);

  select account.rr_balance
  into v_rr_balance
  from public.rank_accounts as account
  where account.user_id = v_user_id
  for update;

  if coalesce(v_rr_balance, 0) < 5 then
    raise exception using errcode = '22023', message = 'paid_swap_insufficient_rr';
  end if;

  update public.free_swap_wallets
  set balance = balance + 1,
      lifetime_granted = lifetime_granted + 1,
      updated_at = clock_timestamp()
  where user_id = v_user_id;

  v_result := public.confirm_weekly_swap_v1(p_week_id, p_first_item_id, p_second_item_id);

  update public.free_swap_wallets
  set lifetime_granted = lifetime_granted - 1,
      lifetime_consumed = lifetime_consumed - 1,
      updated_at = clock_timestamp()
  where user_id = v_user_id;

  select week.confirmed_swap_count
  into v_swap_count
  from public.training_weeks as week
  where week.id = p_week_id and week.user_id = v_user_id;

  select swap.id
  into v_swap_id
  from public.weekly_swaps as swap
  where swap.week_id = p_week_id
    and swap.user_id = v_user_id
    and swap.swap_number = v_swap_count;

  if v_swap_id is null then
    raise exception using errcode = '22023', message = 'paid_swap_record_missing';
  end if;

  update public.weekly_swaps
  set payment_method = 'rr'
  where id = v_swap_id and user_id = v_user_id;

  insert into public.rr_ledger (user_id, source_type, source_id, delta)
  values (v_user_id, 'paid_swap', v_swap_id, -5)
  on conflict (user_id, source_type, source_id) do nothing;

  perform private.refresh_progress_for_user(v_user_id, v_timezone);

  v_result := public.get_or_create_current_week_v1();
  return v_result || jsonb_build_object('paymentMethod', 'rr', 'rrCharged', 5);
end;
$$;

revoke all on function public.get_progress_v1() from public, anon, authenticated, service_role;
revoke all on function public.confirm_weekly_swap_v2(uuid, uuid, uuid) from public, anon, authenticated, service_role;
grant execute on function public.get_progress_v1() to authenticated;
grant execute on function public.confirm_weekly_swap_v2(uuid, uuid, uuid) to authenticated;

commit;
