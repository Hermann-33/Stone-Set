begin;

create schema private authorization postgres;

revoke all on schema private from public, anon, authenticated, service_role;
grant usage on schema private to authenticated, service_role;

alter default privileges for role postgres in schema public revoke all on tables from public, anon, authenticated, service_role;
alter default privileges for role postgres in schema public revoke all on sequences from public, anon, authenticated, service_role;
alter default privileges for role postgres in schema public revoke all on functions from public, anon, authenticated, service_role;
alter default privileges for role postgres in schema private revoke all on tables from public, anon, authenticated, service_role;
alter default privileges for role postgres in schema private revoke all on sequences from public, anon, authenticated, service_role;
alter default privileges for role postgres in schema private revoke all on functions from public, anon, authenticated, service_role;

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  normalized_username text not null unique,
  public_display_name text not null,
  active boolean not null default false,
  must_change_password boolean not null default true,
  reward_timezone text not null default 'UTC',
  revision bigint not null default 1 check (revision > 0),
  created_at timestamptz not null default clock_timestamp(),
  updated_at timestamptz not null default clock_timestamp(),
  constraint profiles_normalized_username_format check (
    normalized_username ~ '^[a-z][a-z0-9_]{2,31}$'
  ),
  constraint profiles_public_display_name_format check (
    char_length(public_display_name) between 1 and 80
    and public_display_name = btrim(public_display_name)
    and public_display_name !~ '[[:cntrl:]]'
  )
);

create table public.user_preferences (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  load_unit text not null default 'kg' check (load_unit in ('kg', 'lb')),
  appearance_mode text not null default 'system' check (appearance_mode in ('system', 'light', 'dark')),
  reduced_motion boolean not null default false,
  haptics_enabled boolean not null default true,
  rest_timer_sound_enabled boolean not null default true,
  workout_reminders_enabled boolean not null default false,
  reminder_local_time time without time zone,
  locale text not null default 'en' check (locale ~ '^[a-z]{2,3}([_-][A-Z]{2})?$'),
  revision bigint not null default 1 check (revision > 0),
  created_at timestamptz not null default clock_timestamp(),
  updated_at timestamptz not null default clock_timestamp(),
  constraint user_preferences_reminder_local_time_required check (
    not workout_reminders_enabled or reminder_local_time is not null
  )
);

create table public.account_capabilities (
  user_id uuid not null references public.profiles (id) on delete cascade,
  capability_code text not null check (capability_code in ('routine_reviewer')),
  is_enabled boolean not null default false,
  revision bigint not null default 1 check (revision > 0),
  created_at timestamptz not null default clock_timestamp(),
  updated_at timestamptz not null default clock_timestamp(),
  primary key (user_id, capability_code)
);

create table public.client_compatibility_config (
  id uuid primary key default gen_random_uuid(),
  environment text not null check (environment in ('local', 'staging', 'production')),
  config_version integer not null check (config_version > 0),
  minimum_mobile_build integer not null check (minimum_mobile_build > 0),
  minimum_dashboard_build integer not null check (minimum_dashboard_build > 0),
  minimum_schema_contract integer not null check (minimum_schema_contract > 0),
  recommended_mobile_build integer not null check (recommended_mobile_build >= minimum_mobile_build),
  maintenance_mode boolean not null default false,
  read_only_mode boolean not null default false,
  message_code text not null default 'available' check (
    message_code ~ '^[a-z][a-z0-9_]{0,63}$'
  ),
  message_text text,
  features jsonb not null default '{}'::jsonb check (jsonb_typeof(features) = 'object'),
  is_current boolean not null default false,
  active_from timestamptz not null default clock_timestamp(),
  created_at timestamptz not null default clock_timestamp(),
  unique (environment, config_version),
  constraint client_compatibility_message_text check (
    message_text is null or (
      char_length(message_text) between 1 and 300
      and message_text !~ '[[:cntrl:]]'
    )
  )
);

create unique index client_compatibility_one_current_per_environment
  on public.client_compatibility_config (environment)
  where is_current;

create table public.account_status_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  event_code text not null check (
    event_code in (
      'profile_linked',
      'account_activated',
      'account_deactivated',
      'password_change_required',
      'password_change_completed',
      'sessions_revoked_selected',
      'sessions_revoked_global'
    )
  ),
  source text not null check (source in ('operator', 'authenticated_user', 'system')),
  actor_user_id uuid,
  auth_session_id uuid,
  correlation_id uuid not null default gen_random_uuid(),
  detail_code text check (
    detail_code is null or detail_code ~ '^[a-z][a-z0-9_]{0,63}$'
  ),
  occurred_at timestamptz not null default clock_timestamp()
);

create index account_status_events_user_occurred_idx
  on public.account_status_events (user_id, occurred_at desc);

create table private.account_security_state (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  password_change_required_at timestamptz,
  sessions_revoked_before timestamptz,
  last_operator_password_audit_id uuid,
  revision bigint not null default 1 check (revision > 0),
  created_at timestamptz not null default clock_timestamp(),
  updated_at timestamptz not null default clock_timestamp()
);

create table private.revoked_auth_sessions (
  session_id uuid primary key,
  user_id uuid not null references public.profiles (id) on delete cascade,
  revoked_at timestamptz not null default clock_timestamp(),
  reason_code text not null check (reason_code ~ '^[a-z][a-z0-9_]{0,63}$'),
  correlation_id uuid not null default gen_random_uuid()
);

create index revoked_auth_sessions_user_revoked_idx
  on private.revoked_auth_sessions (user_id, revoked_at desc);

create table private.password_change_proofs (
  auth_audit_event_id uuid primary key,
  user_id uuid not null references public.profiles (id) on delete cascade,
  auth_session_id uuid not null,
  requirement_started_at timestamptz not null,
  completed_at timestamptz not null default clock_timestamp(),
  correlation_id uuid not null
);

create index password_change_proofs_user_completed_idx
  on private.password_change_proofs (user_id, completed_at desc);

revoke all on table public.profiles from public, anon, authenticated, service_role;
revoke all on table public.user_preferences from public, anon, authenticated, service_role;
revoke all on table public.account_capabilities from public, anon, authenticated, service_role;
revoke all on table public.client_compatibility_config from public, anon, authenticated, service_role;
revoke all on table public.account_status_events from public, anon, authenticated, service_role;
revoke all on all tables in schema private from public, anon, authenticated, service_role;
revoke all on all sequences in schema private from public, anon, authenticated, service_role;

create or replace function private.normalize_username(p_username text)
returns text
language sql
immutable
strict
set search_path = ''
as $$
  select lower(btrim(p_username));
$$;

create or replace function private.set_revision_timestamp()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.revision := old.revision + 1;
  new.updated_at := clock_timestamp();
  return new;
end;
$$;

create or replace function private.validate_profile_timezone()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if not exists (
    select 1
    from pg_catalog.pg_timezone_names
    where name = new.reward_timezone
  ) then
    raise exception using
      errcode = '23514',
      message = 'invalid_reward_timezone';
  end if;
  return new;
end;
$$;

create or replace function private.protect_profile_server_fields()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if current_user in ('anon', 'authenticated') and (
    new.id is distinct from old.id
    or new.normalized_username is distinct from old.normalized_username
    or new.active is distinct from old.active
    or new.must_change_password is distinct from old.must_change_password
    or new.revision is distinct from old.revision
    or new.created_at is distinct from old.created_at
    or new.updated_at is distinct from old.updated_at
  ) then
    raise exception using
      errcode = '42501',
      message = 'profile_server_fields_are_immutable';
  end if;
  return new;
end;
$$;

create or replace function private.protect_preference_server_fields()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if current_user in ('anon', 'authenticated') and (
    new.user_id is distinct from old.user_id
    or new.revision is distinct from old.revision
    or new.created_at is distinct from old.created_at
    or new.updated_at is distinct from old.updated_at
  ) then
    raise exception using
      errcode = '42501',
      message = 'preference_server_fields_are_immutable';
  end if;
  return new;
end;
$$;

create trigger profiles_validate_timezone
before insert or update of reward_timezone on public.profiles
for each row execute function private.validate_profile_timezone();

create trigger profiles_protect_server_fields
before update on public.profiles
for each row execute function private.protect_profile_server_fields();

create trigger profiles_set_revision_timestamp
before update on public.profiles
for each row execute function private.set_revision_timestamp();

create trigger user_preferences_protect_server_fields
before update on public.user_preferences
for each row execute function private.protect_preference_server_fields();

create trigger user_preferences_set_revision_timestamp
before update on public.user_preferences
for each row execute function private.set_revision_timestamp();

create trigger account_capabilities_set_revision_timestamp
before update on public.account_capabilities
for each row execute function private.set_revision_timestamp();

create trigger account_security_state_set_revision_timestamp
before update on private.account_security_state
for each row execute function private.set_revision_timestamp();

create or replace function private.current_live_auth_session_context()
returns table (user_id uuid, session_id uuid)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_claims jsonb := auth.jwt();
  v_session_text text;
  v_session_id uuid;
begin
  if v_user_id is null
     or not (v_claims ? 'is_anonymous')
     or lower(v_claims ->> 'is_anonymous') <> 'false' then
    return;
  end if;

  v_session_text := v_claims ->> 'session_id';
  if v_session_text is null
     or v_session_text !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then
    return;
  end if;
  v_session_id := v_session_text::uuid;

  return query
  select v_user_id, v_session_id
  from auth.sessions as session
  where session.id = v_session_id
    and session.user_id = v_user_id;
end;
$$;

create or replace function private.current_session_context(
  p_require_active boolean,
  p_allow_password_change_required boolean
)
returns table (user_id uuid, session_id uuid)
language sql
stable
security definer
set search_path = ''
as $$
  select live.user_id, live.session_id
  from private.current_live_auth_session_context() as live
  left join public.profiles as profile on profile.id = live.user_id
  left join private.account_security_state as security on security.user_id = profile.id
  where not exists (
      select 1
      from private.revoked_auth_sessions as revoked
      where revoked.session_id = live.session_id
        and revoked.user_id = live.user_id
    )
    and (
      select session.created_at
      from auth.sessions as session
      where session.id = live.session_id
        and session.user_id = live.user_id
    ) > coalesce(
      security.sessions_revoked_before,
      '-infinity'::timestamptz
    )
    and (not p_require_active or coalesce(profile.active, false))
    and (
      p_allow_password_change_required
      or coalesce(not profile.must_change_password, false)
    );
$$;

create or replace function private.current_session_is_authorized(
  p_require_active boolean default true,
  p_allow_password_change_required boolean default false
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from private.current_session_context(
      p_require_active,
      p_allow_password_change_required
    )
  );
$$;

alter table public.profiles enable row level security;
alter table public.user_preferences enable row level security;
alter table public.account_capabilities enable row level security;
alter table public.client_compatibility_config enable row level security;
alter table public.account_status_events enable row level security;

create policy profiles_select_own_active
on public.profiles
for select
to authenticated
using (
  (select auth.uid()) = id
  and (select private.current_session_is_authorized(true, false))
);

create policy profiles_update_own_active
on public.profiles
for update
to authenticated
using (
  (select auth.uid()) = id
  and (select private.current_session_is_authorized(true, false))
)
with check (
  (select auth.uid()) = id
  and (select private.current_session_is_authorized(true, false))
);

create policy user_preferences_select_own_active
on public.user_preferences
for select
to authenticated
using (
  (select auth.uid()) = user_id
  and (select private.current_session_is_authorized(true, false))
);

create policy user_preferences_update_own_active
on public.user_preferences
for update
to authenticated
using (
  (select auth.uid()) = user_id
  and (select private.current_session_is_authorized(true, false))
)
with check (
  (select auth.uid()) = user_id
  and (select private.current_session_is_authorized(true, false))
);

create policy account_capabilities_select_own_active
on public.account_capabilities
for select
to authenticated
using (
  (select auth.uid()) = user_id
  and (select private.current_session_is_authorized(true, false))
);

create policy client_compatibility_select_current
on public.client_compatibility_config
for select
to authenticated
using (
  is_current
  and (select auth.uid()) is not null
  and (select private.current_session_is_authorized(true, true))
);

create policy account_status_events_select_own_active
on public.account_status_events
for select
to authenticated
using (
  (select auth.uid()) = user_id
  and (select private.current_session_is_authorized(true, false))
);

create or replace function private.add_identity_event(
  p_user_id uuid,
  p_event_code text,
  p_source text,
  p_actor_user_id uuid,
  p_auth_session_id uuid,
  p_correlation_id uuid,
  p_detail_code text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_event_id uuid := gen_random_uuid();
begin
  insert into public.account_status_events (
    id,
    user_id,
    event_code,
    source,
    actor_user_id,
    auth_session_id,
    correlation_id,
    detail_code
  ) values (
    v_event_id,
    p_user_id,
    p_event_code,
    p_source,
    p_actor_user_id,
    p_auth_session_id,
    coalesce(p_correlation_id, gen_random_uuid()),
    p_detail_code
  );
  return v_event_id;
end;
$$;

create or replace function private.get_authenticated_bootstrap(
  p_environment text,
  p_client_kind text,
  p_client_build integer,
  p_schema_contract integer,
  p_correlation_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_correlation_id uuid := coalesce(p_correlation_id, gen_random_uuid());
  v_user_id uuid;
  v_session_id uuid;
  v_profile public.profiles%rowtype;
  v_preferences public.user_preferences%rowtype;
  v_compatibility public.client_compatibility_config%rowtype;
  v_state text := 'authenticated';
  v_capabilities jsonb := '[]'::jsonb;
begin
  if p_environment not in ('local', 'staging', 'production')
     or p_client_kind not in ('android', 'dashboard')
     or p_client_build is null
     or p_client_build < 1
     or p_schema_contract is null
     or p_schema_contract < 1 then
    raise exception using errcode = '22023', message = 'invalid_bootstrap_request';
  end if;

  select context.user_id, context.session_id
  into v_user_id, v_session_id
  from private.current_live_auth_session_context() as context;

  if v_user_id is null then
    return jsonb_build_object(
      'state', 'session_expired',
      'correlationId', v_correlation_id,
      'serverTime', clock_timestamp(),
      'schemaContract', 1
    );
  end if;

  select * into v_profile
  from public.profiles
  where id = v_user_id;

  if not found then
    return jsonb_build_object(
      'state', 'profile_unavailable',
      'correlationId', v_correlation_id,
      'serverTime', clock_timestamp(),
      'schemaContract', 1
    );
  end if;

  if not v_profile.active then
    return jsonb_build_object(
      'state', 'profile_disabled',
      'correlationId', v_correlation_id,
      'serverTime', clock_timestamp(),
      'schemaContract', 1
    );
  end if;

  if not private.current_session_is_authorized(true, true) then
    return jsonb_build_object(
      'state', 'session_expired',
      'correlationId', v_correlation_id,
      'serverTime', clock_timestamp(),
      'schemaContract', 1
    );
  end if;

  select * into v_compatibility
  from public.client_compatibility_config
  where environment = p_environment
    and is_current
    and active_from <= clock_timestamp()
  order by config_version desc
  limit 1;

  if not found then
    return jsonb_build_object(
      'state', 'server_unavailable',
      'correlationId', v_correlation_id,
      'serverTime', clock_timestamp(),
      'schemaContract', 1
    );
  end if;

  if v_compatibility.maintenance_mode then
    v_state := 'maintenance';
  elsif (
          p_client_kind = 'android'
          and p_client_build < v_compatibility.minimum_mobile_build
        )
        or (
          p_client_kind = 'dashboard'
          and p_client_build < v_compatibility.minimum_dashboard_build
        )
        or p_schema_contract < v_compatibility.minimum_schema_contract then
    v_state := 'client_incompatible';
  elsif v_profile.must_change_password then
    v_state := 'password_change_required';
  end if;

  select * into v_preferences
  from public.user_preferences
  where user_id = v_user_id;

  select coalesce(
    jsonb_agg(capability_code order by capability_code)
      filter (where is_enabled),
    '[]'::jsonb
  ) into v_capabilities
  from public.account_capabilities
  where user_id = v_user_id;

  return jsonb_build_object(
    'state', v_state,
    'correlationId', v_correlation_id,
    'serverTime', clock_timestamp(),
    'schemaContract', 1,
    'readOnly', v_compatibility.read_only_mode,
    'compatibility', jsonb_build_object(
      'configVersion', v_compatibility.config_version,
      'minimumBuild', case
        when p_client_kind = 'android' then v_compatibility.minimum_mobile_build
        else v_compatibility.minimum_dashboard_build
      end,
      'recommendedMobileBuild', v_compatibility.recommended_mobile_build,
      'messageCode', v_compatibility.message_code,
      'messageText', v_compatibility.message_text,
      'features', v_compatibility.features
    ),
    'profile', jsonb_build_object(
      'id', v_profile.id,
      'username', v_profile.normalized_username,
      'displayName', v_profile.public_display_name,
      'active', v_profile.active,
      'mustChangePassword', v_profile.must_change_password,
      'rewardTimezone', v_profile.reward_timezone,
      'revision', v_profile.revision
    ),
    'preferences', jsonb_build_object(
      'loadUnit', v_preferences.load_unit,
      'appearanceMode', v_preferences.appearance_mode,
      'reducedMotion', v_preferences.reduced_motion,
      'hapticsEnabled', v_preferences.haptics_enabled,
      'restTimerSoundEnabled', v_preferences.rest_timer_sound_enabled,
      'workoutRemindersEnabled', v_preferences.workout_reminders_enabled,
      'reminderLocalTime', v_preferences.reminder_local_time,
      'locale', v_preferences.locale,
      'revision', v_preferences.revision
    ),
    'capabilities', v_capabilities
  );
end;
$$;

create or replace function public.get_authenticated_bootstrap(
  p_environment text,
  p_client_kind text,
  p_client_build integer,
  p_schema_contract integer,
  p_correlation_id uuid default null
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
  select private.get_authenticated_bootstrap(
    p_environment,
    p_client_kind,
    p_client_build,
    p_schema_contract,
    p_correlation_id
  );
$$;

create or replace function private.update_my_profile(
  p_public_display_name text,
  p_reward_timezone text,
  p_expected_revision bigint
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid;
  v_profile public.profiles%rowtype;
begin
  select context.user_id into v_user_id
  from private.current_session_context(true, false) as context;
  if v_user_id is null then
    raise exception using errcode = '42501', message = 'identity_not_authorized';
  end if;
  if p_public_display_name is null or p_reward_timezone is null or p_expected_revision is null then
    raise exception using errcode = '22023', message = 'invalid_profile_update';
  end if;

  update public.profiles
  set public_display_name = p_public_display_name,
      reward_timezone = p_reward_timezone
  where id = v_user_id
    and revision = p_expected_revision
  returning * into v_profile;

  if not found then
    raise exception using errcode = '40001', message = 'stale_profile_revision';
  end if;
  return jsonb_build_object(
    'displayName', v_profile.public_display_name,
    'rewardTimezone', v_profile.reward_timezone,
    'revision', v_profile.revision
  );
end;
$$;

create or replace function public.update_my_profile(
  p_public_display_name text,
  p_reward_timezone text,
  p_expected_revision bigint
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
  select private.update_my_profile(
    p_public_display_name,
    p_reward_timezone,
    p_expected_revision
  );
$$;

create or replace function private.update_my_preferences(
  p_load_unit text,
  p_appearance_mode text,
  p_reduced_motion boolean,
  p_haptics_enabled boolean,
  p_rest_timer_sound_enabled boolean,
  p_workout_reminders_enabled boolean,
  p_reminder_local_time time without time zone,
  p_locale text,
  p_expected_revision bigint
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid;
  v_preferences public.user_preferences%rowtype;
begin
  select context.user_id into v_user_id
  from private.current_session_context(true, false) as context;
  if v_user_id is null then
    raise exception using errcode = '42501', message = 'identity_not_authorized';
  end if;

  update public.user_preferences
  set load_unit = p_load_unit,
      appearance_mode = p_appearance_mode,
      reduced_motion = p_reduced_motion,
      haptics_enabled = p_haptics_enabled,
      rest_timer_sound_enabled = p_rest_timer_sound_enabled,
      workout_reminders_enabled = p_workout_reminders_enabled,
      reminder_local_time = p_reminder_local_time,
      locale = p_locale
  where user_id = v_user_id
    and revision = p_expected_revision
  returning * into v_preferences;

  if not found then
    raise exception using errcode = '40001', message = 'stale_preferences_revision';
  end if;
  return jsonb_build_object(
    'loadUnit', v_preferences.load_unit,
    'appearanceMode', v_preferences.appearance_mode,
    'reducedMotion', v_preferences.reduced_motion,
    'hapticsEnabled', v_preferences.haptics_enabled,
    'restTimerSoundEnabled', v_preferences.rest_timer_sound_enabled,
    'workoutRemindersEnabled', v_preferences.workout_reminders_enabled,
    'reminderLocalTime', v_preferences.reminder_local_time,
    'locale', v_preferences.locale,
    'revision', v_preferences.revision
  );
end;
$$;

create or replace function public.update_my_preferences(
  p_load_unit text,
  p_appearance_mode text,
  p_reduced_motion boolean,
  p_haptics_enabled boolean,
  p_rest_timer_sound_enabled boolean,
  p_workout_reminders_enabled boolean,
  p_reminder_local_time time without time zone,
  p_locale text,
  p_expected_revision bigint
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
  select private.update_my_preferences(
    p_load_unit,
    p_appearance_mode,
    p_reduced_motion,
    p_haptics_enabled,
    p_rest_timer_sound_enabled,
    p_workout_reminders_enabled,
    p_reminder_local_time,
    p_locale,
    p_expected_revision
  );
$$;

create or replace function private.complete_required_password_change(
  p_correlation_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid;
  v_session_id uuid;
  v_requirement_started_at timestamptz;
  v_audit_event_id uuid;
  v_correlation_id uuid := coalesce(p_correlation_id, gen_random_uuid());
begin
  select context.user_id, context.session_id
  into v_user_id, v_session_id
  from private.current_session_context(true, true) as context;
  if v_user_id is null then
    raise exception using errcode = '42501', message = 'identity_not_authorized';
  end if;

  select security.password_change_required_at
  into v_requirement_started_at
  from private.account_security_state as security
  join public.profiles as profile on profile.id = security.user_id
  where security.user_id = v_user_id
    and profile.must_change_password
  for update of security, profile;

  if v_requirement_started_at is null then
    raise exception using errcode = 'P0001', message = 'password_change_not_required';
  end if;

  select audit.id
  into v_audit_event_id
  from auth.audit_log_entries as audit
  where audit.payload ->> 'action' = 'user_updated_password'
    and audit.payload ->> 'actor_id' ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    and (audit.payload ->> 'actor_id')::uuid = v_user_id
    and audit.created_at > v_requirement_started_at
    and audit.created_at >= clock_timestamp() - interval '24 hours'
    and not exists (
      select 1
      from private.password_change_proofs as proof
      where proof.auth_audit_event_id = audit.id
    )
  order by audit.created_at desc
  limit 1;

  if v_audit_event_id is null then
    raise exception using errcode = 'P0001', message = 'password_change_evidence_missing';
  end if;

  insert into private.password_change_proofs (
    auth_audit_event_id,
    user_id,
    auth_session_id,
    requirement_started_at,
    correlation_id
  ) values (
    v_audit_event_id,
    v_user_id,
    v_session_id,
    v_requirement_started_at,
    v_correlation_id
  );

  update public.profiles
  set must_change_password = false
  where id = v_user_id;

  update private.account_security_state
  set password_change_required_at = null
  where user_id = v_user_id;

  perform private.add_identity_event(
    v_user_id,
    'password_change_completed',
    'authenticated_user',
    v_user_id,
    v_session_id,
    v_correlation_id,
    'auth_audit_verified'
  );

  return jsonb_build_object(
    'completed', true,
    'correlationId', v_correlation_id
  );
end;
$$;

create or replace function public.complete_required_password_change(
  p_correlation_id uuid default null
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
  select private.complete_required_password_change(p_correlation_id);
$$;

create or replace function private.operator_link_identity(
  p_user_id uuid,
  p_normalized_username text,
  p_public_display_name text,
  p_reward_timezone text,
  p_correlation_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_correlation_id uuid := coalesce(p_correlation_id, gen_random_uuid());
  v_username text := private.normalize_username(p_normalized_username);
begin
  if v_username <> p_normalized_username
     or v_username !~ '^[a-z][a-z0-9_]{2,31}$' then
    raise exception using errcode = '22023', message = 'invalid_normalized_username';
  end if;
  if not exists (select 1 from auth.users where id = p_user_id) then
    raise exception using errcode = '23503', message = 'auth_user_not_found';
  end if;

  insert into public.profiles (
    id,
    normalized_username,
    public_display_name,
    active,
    must_change_password,
    reward_timezone
  ) values (
    p_user_id,
    v_username,
    p_public_display_name,
    false,
    true,
    p_reward_timezone
  );

  insert into public.user_preferences (user_id) values (p_user_id);
  insert into public.account_capabilities (
    user_id,
    capability_code,
    is_enabled
  ) values (
    p_user_id,
    'routine_reviewer',
    false
  );
  insert into private.account_security_state (
    user_id,
    password_change_required_at
  ) values (
    p_user_id,
    clock_timestamp()
  );

  perform private.add_identity_event(
    p_user_id,
    'profile_linked',
    'operator',
    null,
    null,
    v_correlation_id,
    'provisioned_inactive'
  );
  perform private.add_identity_event(
    p_user_id,
    'password_change_required',
    'operator',
    null,
    null,
    v_correlation_id,
    'initial_password'
  );

  return jsonb_build_object(
    'userId', p_user_id,
    'username', v_username,
    'active', false,
    'mustChangePassword', true,
    'correlationId', v_correlation_id
  );
end;
$$;

create or replace function public.operator_link_identity(
  p_user_id uuid,
  p_normalized_username text,
  p_public_display_name text,
  p_reward_timezone text,
  p_correlation_id uuid default null
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
  select private.operator_link_identity(
    p_user_id,
    p_normalized_username,
    p_public_display_name,
    p_reward_timezone,
    p_correlation_id
  );
$$;

create or replace function private.operator_set_active(
  p_user_id uuid,
  p_active boolean,
  p_correlation_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_correlation_id uuid := coalesce(p_correlation_id, gen_random_uuid());
begin
  update public.profiles
  set active = p_active
  where id = p_user_id;
  if not found then
    raise exception using errcode = 'P0002', message = 'profile_not_found';
  end if;

  if not p_active then
    update private.account_security_state
    set sessions_revoked_before = clock_timestamp()
    where user_id = p_user_id;
  end if;

  perform private.add_identity_event(
    p_user_id,
    case when p_active then 'account_activated' else 'account_deactivated' end,
    'operator',
    null,
    null,
    v_correlation_id,
    case when p_active then 'operator_reactivated' else 'operator_deactivated' end
  );
  return jsonb_build_object(
    'userId', p_user_id,
    'active', p_active,
    'correlationId', v_correlation_id
  );
end;
$$;

create or replace function public.operator_set_active(
  p_user_id uuid,
  p_active boolean,
  p_correlation_id uuid default null
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
  select private.operator_set_active(p_user_id, p_active, p_correlation_id);
$$;

create or replace function private.operator_require_password_change(
  p_user_id uuid,
  p_observed_auth_audit_id uuid,
  p_correlation_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_correlation_id uuid := coalesce(p_correlation_id, gen_random_uuid());
begin
  if not exists (
    select 1
    from auth.audit_log_entries as audit
    where audit.id = p_observed_auth_audit_id
      and audit.payload ->> 'action' = 'user_updated_password'
      and audit.payload ->> 'actor_id' ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
      and (audit.payload ->> 'actor_id')::uuid = p_user_id
  ) then
    raise exception using errcode = '22023', message = 'operator_password_audit_not_observed';
  end if;

  update public.profiles
  set must_change_password = true
  where id = p_user_id;
  if not found then
    raise exception using errcode = 'P0002', message = 'profile_not_found';
  end if;

  update private.account_security_state
  set password_change_required_at = clock_timestamp(),
      sessions_revoked_before = clock_timestamp(),
      last_operator_password_audit_id = p_observed_auth_audit_id
  where user_id = p_user_id;
  if not found then
    raise exception using errcode = 'P0002', message = 'security_state_not_found';
  end if;

  perform private.add_identity_event(
    p_user_id,
    'password_change_required',
    'operator',
    null,
    null,
    v_correlation_id,
    'operator_password_reset'
  );
  perform private.add_identity_event(
    p_user_id,
    'sessions_revoked_global',
    'operator',
    null,
    null,
    v_correlation_id,
    'password_reset_cutoff'
  );

  return jsonb_build_object(
    'userId', p_user_id,
    'mustChangePassword', true,
    'sessionsRevoked', 'global',
    'correlationId', v_correlation_id
  );
end;
$$;

create or replace function public.operator_require_password_change(
  p_user_id uuid,
  p_observed_auth_audit_id uuid,
  p_correlation_id uuid default null
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
  select private.operator_require_password_change(
    p_user_id,
    p_observed_auth_audit_id,
    p_correlation_id
  );
$$;

create or replace function private.operator_revoke_sessions(
  p_user_id uuid,
  p_scope text,
  p_session_id uuid default null,
  p_reason_code text default 'operator_revocation',
  p_correlation_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_correlation_id uuid := coalesce(p_correlation_id, gen_random_uuid());
begin
  if p_reason_code !~ '^[a-z][a-z0-9_]{0,63}$' then
    raise exception using errcode = '22023', message = 'invalid_reason_code';
  end if;
  if not exists (select 1 from public.profiles where id = p_user_id) then
    raise exception using errcode = 'P0002', message = 'profile_not_found';
  end if;

  if p_scope = 'selected' then
    if p_session_id is null or not exists (
      select 1
      from auth.sessions
      where id = p_session_id and user_id = p_user_id
    ) then
      raise exception using errcode = '22023', message = 'session_not_found_for_user';
    end if;
    insert into private.revoked_auth_sessions (
      session_id,
      user_id,
      reason_code,
      correlation_id
    ) values (
      p_session_id,
      p_user_id,
      p_reason_code,
      v_correlation_id
    ) on conflict (session_id) do update
      set revoked_at = clock_timestamp(),
          reason_code = excluded.reason_code,
          correlation_id = excluded.correlation_id;
  elsif p_scope = 'global' then
    if p_session_id is not null then
      raise exception using errcode = '22023', message = 'global_scope_rejects_session_id';
    end if;
    update private.account_security_state
    set sessions_revoked_before = clock_timestamp()
    where user_id = p_user_id;
    if not found then
      raise exception using errcode = 'P0002', message = 'security_state_not_found';
    end if;
  else
    raise exception using errcode = '22023', message = 'invalid_revocation_scope';
  end if;

  perform private.add_identity_event(
    p_user_id,
    case when p_scope = 'selected'
      then 'sessions_revoked_selected'
      else 'sessions_revoked_global'
    end,
    'operator',
    null,
    p_session_id,
    v_correlation_id,
    p_reason_code
  );
  return jsonb_build_object(
    'userId', p_user_id,
    'scope', p_scope,
    'sessionId', p_session_id,
    'correlationId', v_correlation_id,
    'accessTokenLimitation', 'issued_jwt_valid_until_expiry'
  );
end;
$$;

create or replace function public.operator_revoke_sessions(
  p_user_id uuid,
  p_scope text,
  p_session_id uuid default null,
  p_reason_code text default 'operator_revocation',
  p_correlation_id uuid default null
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
  select private.operator_revoke_sessions(
    p_user_id,
    p_scope,
    p_session_id,
    p_reason_code,
    p_correlation_id
  );
$$;

create or replace function private.operator_account_status(
  p_normalized_username text
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_profile public.profiles%rowtype;
  v_security private.account_security_state%rowtype;
  v_sessions jsonb;
  v_latest_password_audit jsonb;
begin
  select * into v_profile
  from public.profiles
  where normalized_username = private.normalize_username(p_normalized_username);
  if not found then
    raise exception using errcode = 'P0002', message = 'profile_not_found';
  end if;

  select * into v_security
  from private.account_security_state
  where user_id = v_profile.id;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'sessionId', session.id,
        'createdAt', session.created_at,
        'updatedAt', session.updated_at,
        'notAfter', session.not_after,
        'applicationRevoked', revoked.session_id is not null
      ) order by session.created_at desc
    ),
    '[]'::jsonb
  ) into v_sessions
  from auth.sessions as session
  left join private.revoked_auth_sessions as revoked on revoked.session_id = session.id
  where session.user_id = v_profile.id;

  select jsonb_build_object(
    'eventId', audit.id,
    'createdAt', audit.created_at
  ) into v_latest_password_audit
  from auth.audit_log_entries as audit
  where audit.payload ->> 'action' = 'user_updated_password'
    and audit.payload ->> 'actor_id' ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
    and (audit.payload ->> 'actor_id')::uuid = v_profile.id
  order by audit.created_at desc
  limit 1;

  return jsonb_build_object(
    'userId', v_profile.id,
    'username', v_profile.normalized_username,
    'active', v_profile.active,
    'mustChangePassword', v_profile.must_change_password,
    'passwordChangeRequiredAt', v_security.password_change_required_at,
    'sessionsRevokedBefore', v_security.sessions_revoked_before,
    'latestPasswordAudit', v_latest_password_audit,
    'sessions', v_sessions,
    'accessTokenLimitation', 'issued_jwt_valid_until_expiry'
  );
end;
$$;

create or replace function public.operator_account_status(
  p_normalized_username text
)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.operator_account_status(p_normalized_username);
$$;

insert into public.client_compatibility_config (
  environment,
  config_version,
  minimum_mobile_build,
  minimum_dashboard_build,
  minimum_schema_contract,
  recommended_mobile_build,
  maintenance_mode,
  read_only_mode,
  message_code,
  message_text,
  features,
  is_current
) values (
  'local',
  1,
  1,
  1,
  1,
  1,
  false,
  false,
  'available',
  null,
  '{}'::jsonb,
  true
);

grant select on public.profiles to authenticated;
grant select on public.user_preferences to authenticated;
grant select on public.account_capabilities to authenticated;
grant select on public.client_compatibility_config to authenticated;
grant select on public.account_status_events to authenticated;

revoke all on function public.get_authenticated_bootstrap(text, text, integer, integer, uuid) from public, anon, authenticated, service_role;
revoke all on function public.update_my_profile(text, text, bigint) from public, anon, authenticated, service_role;
revoke all on function public.update_my_preferences(text, text, boolean, boolean, boolean, boolean, time without time zone, text, bigint) from public, anon, authenticated, service_role;
revoke all on function public.complete_required_password_change(uuid) from public, anon, authenticated, service_role;
revoke all on function public.operator_link_identity(uuid, text, text, text, uuid) from public, anon, authenticated, service_role;
revoke all on function public.operator_set_active(uuid, boolean, uuid) from public, anon, authenticated, service_role;
revoke all on function public.operator_require_password_change(uuid, uuid, uuid) from public, anon, authenticated, service_role;
revoke all on function public.operator_revoke_sessions(uuid, text, uuid, text, uuid) from public, anon, authenticated, service_role;
revoke all on function public.operator_account_status(text) from public, anon, authenticated, service_role;
revoke all on all functions in schema private from public, anon, authenticated, service_role;

grant execute on function private.current_session_is_authorized(boolean, boolean) to authenticated;
grant execute on function private.get_authenticated_bootstrap(text, text, integer, integer, uuid) to authenticated;
grant execute on function private.update_my_profile(text, text, bigint) to authenticated;
grant execute on function private.update_my_preferences(text, text, boolean, boolean, boolean, boolean, time without time zone, text, bigint) to authenticated;
grant execute on function private.complete_required_password_change(uuid) to authenticated;

grant execute on function public.get_authenticated_bootstrap(text, text, integer, integer, uuid) to authenticated;
grant execute on function public.update_my_profile(text, text, bigint) to authenticated;
grant execute on function public.update_my_preferences(text, text, boolean, boolean, boolean, boolean, time without time zone, text, bigint) to authenticated;
grant execute on function public.complete_required_password_change(uuid) to authenticated;

grant execute on function private.operator_link_identity(uuid, text, text, text, uuid) to service_role;
grant execute on function private.operator_set_active(uuid, boolean, uuid) to service_role;
grant execute on function private.operator_require_password_change(uuid, uuid, uuid) to service_role;
grant execute on function private.operator_revoke_sessions(uuid, text, uuid, text, uuid) to service_role;
grant execute on function private.operator_account_status(text) to service_role;

grant execute on function public.operator_link_identity(uuid, text, text, text, uuid) to service_role;
grant execute on function public.operator_set_active(uuid, boolean, uuid) to service_role;
grant execute on function public.operator_require_password_change(uuid, uuid, uuid) to service_role;
grant execute on function public.operator_revoke_sessions(uuid, text, uuid, text, uuid) to service_role;
grant execute on function public.operator_account_status(text) to service_role;

commit;
