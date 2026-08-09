begin;

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

  -- The assigned-date unique constraint is DEFERRABLE INITIALLY DEFERRED,
  -- so no SET CONSTRAINTS statement is required here.
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

commit;
