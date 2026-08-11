begin;

alter table public.rank_accounts
  add column if not exists active_consistency_multiplier numeric(3, 2) not null default 1.00;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'rank_accounts_active_consistency_multiplier_check'
      and conrelid = 'public.rank_accounts'::regclass
  ) then
    alter table public.rank_accounts
      add constraint rank_accounts_active_consistency_multiplier_check
      check (active_consistency_multiplier in (1.00, 1.50, 2.00, 2.50));
  end if;
end
$$;

comment on column public.rank_accounts.active_consistency_multiplier is
  'Server-owned active multiplier. TASK-IMP-010 initializes the authoritative base only; weekly streak evaluation is deferred.';

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
      'activeConsistencyMultiplier', state.active_consistency_multiplier,
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

revoke all on function private.progress_payload(uuid) from public, anon, authenticated, service_role;

commit;
