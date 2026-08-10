begin;

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

  v_swap_id := (v_result -> 'swap' ->> 'id')::uuid;
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

  v_result := jsonb_set(
    v_result,
    '{wallet}',
    private.free_swap_wallet_payload(v_user_id),
    true
  );
  return v_result || jsonb_build_object('paymentMethod', 'rr', 'rrCharged', 5);
end;
$$;

commit;
