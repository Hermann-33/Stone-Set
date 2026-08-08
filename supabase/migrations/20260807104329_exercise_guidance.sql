begin;

create extension if not exists pgcrypto with schema extensions;

create table public.muscles (
  id uuid primary key,
  stable_key text not null unique,
  display_name text not null,
  display_order integer not null unique,
  active boolean not null default true,
  created_at timestamptz not null default clock_timestamp(),
  constraint muscles_stable_key_format check (stable_key ~ '^[a-z][a-z0-9_]{0,63}$'),
  constraint muscles_display_name_format check (
    char_length(display_name) between 1 and 80
    and display_name = btrim(display_name)
    and display_name !~ '[[:cntrl:]]'
  ),
  constraint muscles_display_order_positive check (display_order > 0)
);

create table public.exercise_definitions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  canonical_name text not null,
  normalized_name text not null,
  variant_key text,
  archived_at timestamptz,
  cloned_from_exercise_id uuid,
  revision bigint not null default 1 check (revision > 0),
  created_at timestamptz not null default clock_timestamp(),
  updated_at timestamptz not null default clock_timestamp(),
  unique (id, user_id),
  foreign key (cloned_from_exercise_id, user_id)
    references public.exercise_definitions (id, user_id) on delete restrict,
  constraint exercise_definitions_name_format check (
    char_length(canonical_name) between 1 and 120
    and canonical_name = btrim(canonical_name)
    and canonical_name !~ '[[:cntrl:]]'
  ),
  constraint exercise_definitions_normalized_name_format check (
    char_length(normalized_name) between 1 and 120
    and normalized_name = btrim(normalized_name)
    and normalized_name = lower(normalized_name)
    and normalized_name !~ '[[:cntrl:]]'
  ),
  constraint exercise_definitions_variant_key_format check (
    variant_key is null or variant_key ~ '^[a-z][a-z0-9_]{0,63}$'
  )
);

create index exercise_definitions_owner_active_name_idx
  on public.exercise_definitions (user_id, normalized_name, id)
  where archived_at is null;
create index exercise_definitions_owner_archived_updated_idx
  on public.exercise_definitions (user_id, archived_at, updated_at desc, id);
create index exercise_definitions_clone_source_idx
  on public.exercise_definitions (cloned_from_exercise_id)
  where cloned_from_exercise_id is not null;

create table public.exercise_definition_equipment (
  exercise_id uuid not null,
  user_id uuid not null,
  equipment_key text not null,
  position integer not null,
  primary key (exercise_id, equipment_key),
  unique (exercise_id, position),
  foreign key (exercise_id, user_id)
    references public.exercise_definitions (id, user_id) on delete cascade,
  constraint exercise_definition_equipment_key_format check (
    equipment_key ~ '^[a-z][a-z0-9_]{0,63}$'
  ),
  constraint exercise_definition_equipment_position_positive check (position > 0)
);

create index exercise_definition_equipment_owner_idx
  on public.exercise_definition_equipment (user_id, equipment_key, exercise_id);

create table public.exercise_definition_muscles (
  exercise_id uuid not null,
  user_id uuid not null,
  muscle_id uuid not null references public.muscles (id) on delete restrict,
  role text not null check (role in ('primary', 'secondary')),
  position integer not null,
  primary key (exercise_id, muscle_id),
  unique (exercise_id, role, position),
  foreign key (exercise_id, user_id)
    references public.exercise_definitions (id, user_id) on delete cascade,
  constraint exercise_definition_muscles_position_positive check (position > 0)
);

create index exercise_definition_muscles_owner_role_idx
  on public.exercise_definition_muscles (user_id, role, muscle_id, exercise_id);
create index exercise_definition_muscles_muscle_idx
  on public.exercise_definition_muscles (muscle_id, exercise_id);

create table public.guidance_drafts (
  id uuid primary key default gen_random_uuid(),
  exercise_id uuid not null,
  user_id uuid not null,
  base_guidance_revision_id uuid,
  structured_content_schema_version integer not null default 1,
  structured_content jsonb not null,
  revision bigint not null default 1 check (revision > 0),
  created_at timestamptz not null default clock_timestamp(),
  updated_at timestamptz not null default clock_timestamp(),
  unique (exercise_id),
  unique (id, user_id),
  foreign key (exercise_id, user_id)
    references public.exercise_definitions (id, user_id) on delete cascade,
  constraint guidance_drafts_schema_version check (structured_content_schema_version = 1),
  constraint guidance_drafts_content_object check (jsonb_typeof(structured_content) = 'object')
);

create index guidance_drafts_owner_updated_idx
  on public.guidance_drafts (user_id, updated_at desc, id);

create table public.guidance_revisions (
  id uuid primary key default gen_random_uuid(),
  exercise_id uuid not null,
  user_id uuid not null,
  version_number bigint not null check (version_number > 0),
  structured_content_schema_version integer not null,
  structured_content jsonb not null,
  canonical_name_snapshot text not null,
  normalized_name_snapshot text not null,
  variant_key_snapshot text,
  equipment_keys_snapshot jsonb not null,
  content_hash text not null,
  revision_hash text not null,
  supersedes_revision_id uuid,
  published_at timestamptz not null default clock_timestamp(),
  unique (id, user_id),
  unique (id, exercise_id, user_id),
  unique (exercise_id, version_number),
  unique (exercise_id, content_hash),
  unique (revision_hash),
  foreign key (exercise_id, user_id)
    references public.exercise_definitions (id, user_id) on delete restrict,
  foreign key (supersedes_revision_id, exercise_id, user_id)
    references public.guidance_revisions (id, exercise_id, user_id) on delete restrict,
  constraint guidance_revisions_schema_version check (structured_content_schema_version = 1),
  constraint guidance_revisions_content_object check (jsonb_typeof(structured_content) = 'object'),
  constraint guidance_revisions_equipment_array check (jsonb_typeof(equipment_keys_snapshot) = 'array'),
  constraint guidance_revisions_content_hash_format check (content_hash ~ '^[0-9a-f]{64}$'),
  constraint guidance_revisions_revision_hash_format check (revision_hash ~ '^[0-9a-f]{64}$')
);

create index guidance_revisions_owner_published_idx
  on public.guidance_revisions (user_id, published_at desc, id);
create index guidance_revisions_exercise_version_desc_idx
  on public.guidance_revisions (exercise_id, version_number desc);
create index guidance_revisions_supersedes_idx
  on public.guidance_revisions (supersedes_revision_id)
  where supersedes_revision_id is not null;

alter table public.guidance_drafts
  add constraint guidance_drafts_base_revision_fkey
  foreign key (base_guidance_revision_id, exercise_id, user_id)
  references public.guidance_revisions (id, exercise_id, user_id) on delete restrict;
create index guidance_drafts_base_revision_idx
  on public.guidance_drafts (base_guidance_revision_id)
  where base_guidance_revision_id is not null;

create table public.guidance_revision_muscles (
  guidance_revision_id uuid not null,
  user_id uuid not null,
  muscle_id uuid not null references public.muscles (id) on delete restrict,
  muscle_key_snapshot text not null,
  role text not null check (role in ('primary', 'secondary')),
  position integer not null,
  primary key (guidance_revision_id, muscle_id),
  unique (guidance_revision_id, role, position),
  foreign key (guidance_revision_id, user_id)
    references public.guidance_revisions (id, user_id) on delete restrict,
  constraint guidance_revision_muscles_key_format check (
    muscle_key_snapshot ~ '^[a-z][a-z0-9_]{0,63}$'
  ),
  constraint guidance_revision_muscles_position_positive check (position > 0)
);

create index guidance_revision_muscles_owner_idx
  on public.guidance_revision_muscles (user_id, guidance_revision_id);
create index guidance_revision_muscles_muscle_idx
  on public.guidance_revision_muscles (muscle_id, guidance_revision_id);

create table private.guidance_mutation_operations (
  user_id uuid not null references public.profiles (id) on delete cascade,
  operation_name text not null,
  idempotency_key uuid not null,
  request_fingerprint text not null,
  correlation_id uuid not null default gen_random_uuid(),
  result jsonb not null,
  created_at timestamptz not null default clock_timestamp(),
  primary key (user_id, operation_name, idempotency_key),
  constraint guidance_mutation_operations_name_format check (
    operation_name ~ '^[a-z][a-z0-9_]{0,63}$'
  ),
  constraint guidance_mutation_operations_fingerprint_format check (
    request_fingerprint ~ '^[0-9a-f]{64}$'
  ),
  constraint guidance_mutation_operations_result_object check (jsonb_typeof(result) = 'object'),
  constraint guidance_mutation_operations_correlation_matches check (
    result ? 'correlationId'
    and result ->> 'correlationId' = correlation_id::text
  )
);

create index guidance_mutation_operations_created_idx
  on private.guidance_mutation_operations (created_at);

revoke all on table public.muscles from public, anon, authenticated, service_role;
revoke all on table public.exercise_definitions from public, anon, authenticated, service_role;
revoke all on table public.exercise_definition_equipment from public, anon, authenticated, service_role;
revoke all on table public.exercise_definition_muscles from public, anon, authenticated, service_role;
revoke all on table public.guidance_drafts from public, anon, authenticated, service_role;
revoke all on table public.guidance_revisions from public, anon, authenticated, service_role;
revoke all on table public.guidance_revision_muscles from public, anon, authenticated, service_role;
revoke all on table private.guidance_mutation_operations from public, anon, authenticated, service_role;

insert into public.muscles (id, stable_key, display_name, display_order) values
  ('a3000000-0000-4000-8000-000000000001', 'chest', 'Chest', 1),
  ('a3000000-0000-4000-8000-000000000002', 'back', 'Back', 2),
  ('a3000000-0000-4000-8000-000000000003', 'anterior_deltoids', 'Anterior deltoids', 3),
  ('a3000000-0000-4000-8000-000000000004', 'lateral_deltoids', 'Lateral deltoids', 4),
  ('a3000000-0000-4000-8000-000000000005', 'posterior_deltoids', 'Posterior deltoids', 5),
  ('a3000000-0000-4000-8000-000000000006', 'biceps', 'Biceps', 6),
  ('a3000000-0000-4000-8000-000000000007', 'triceps', 'Triceps', 7),
  ('a3000000-0000-4000-8000-000000000008', 'forearms', 'Forearms', 8),
  ('a3000000-0000-4000-8000-000000000009', 'quadriceps', 'Quadriceps', 9),
  ('a3000000-0000-4000-8000-00000000000a', 'hamstrings', 'Hamstrings', 10),
  ('a3000000-0000-4000-8000-00000000000b', 'glutes', 'Glutes', 11),
  ('a3000000-0000-4000-8000-00000000000c', 'calves', 'Calves', 12),
  ('a3000000-0000-4000-8000-00000000000d', 'abdominals', 'Abdominals', 13)
on conflict (id) do update set
  stable_key = excluded.stable_key,
  display_name = excluded.display_name,
  display_order = excluded.display_order,
  active = true;

create or replace function private.normalize_exercise_name(p_value text)
returns text
language sql
immutable
strict
set search_path = ''
as $$
  select lower(regexp_replace(
    btrim(normalize(p_value, NFC)),
    U&'([[:space:]]|[\00A0\1680\2000-\200A\2028\2029\202F\205F\3000])+',
    ' ',
    'g'
  ));
$$;

create or replace function private.normalize_guidance_string(p_value text)
returns text
language sql
immutable
strict
set search_path = ''
as $$
  select btrim(normalize(replace(replace(p_value, E'\r\n', E'\n'), E'\r', E'\n'), NFC));
$$;

create or replace function private.sha256_text(p_value text)
returns text
language sql
immutable
strict
set search_path = ''
as $$
  select encode(extensions.digest(convert_to(p_value, 'UTF8'), 'sha256'), 'hex');
$$;

create or replace function private.sha256_jsonb(p_value jsonb)
returns text
language sql
immutable
strict
set search_path = ''
as $$
  select private.sha256_text(p_value::text);
$$;

create or replace function private.require_product_actor()
returns uuid
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_user_id uuid;
begin
  select context.user_id
  into v_user_id
  from private.current_session_context(true, false) as context;

  if v_user_id is null then
    raise exception using errcode = '42501', message = 'product_identity_not_authorized';
  end if;
  return v_user_id;
end;
$$;

create or replace function private.normalize_guidance_content(
  p_content jsonb,
  p_for_publication boolean
)
returns jsonb
language plpgsql
stable
set search_path = ''
as $$
declare
  v_allowed_keys text[] := array[
    'shortExplanation',
    'setupSteps',
    'executionSteps',
    'techniqueCues',
    'commonMistakes',
    'safetyNotes'
  ];
  v_key text;
  v_value jsonb;
  v_item jsonb;
  v_normalized text;
  v_short text;
  v_array jsonb;
  v_result jsonb := '{}'::jsonb;
  v_setup_count integer := 0;
  v_execution_count integer := 0;
begin
  if p_content is null
     or jsonb_typeof(p_content) <> 'object'
     or not (p_content ?& v_allowed_keys)
     or (p_content - v_allowed_keys) <> '{}'::jsonb then
    raise exception using errcode = '22023', message = 'invalid_guidance_content_shape';
  end if;

  if jsonb_typeof(p_content -> 'shortExplanation') <> 'string' then
    raise exception using errcode = '22023', message = 'invalid_guidance_short_explanation';
  end if;
  v_short := private.normalize_guidance_string(p_content ->> 'shortExplanation');
  if char_length(v_short) > 2000
     or replace(replace(v_short, E'\n', ''), E'\t', '') ~ '[[:cntrl:]]'
     or (p_for_publication and char_length(v_short) < 1) then
    raise exception using errcode = '22023', message = 'invalid_guidance_short_explanation';
  end if;
  v_result := jsonb_build_object('shortExplanation', v_short);

  foreach v_key in array array[
    'setupSteps',
    'executionSteps',
    'techniqueCues',
    'commonMistakes',
    'safetyNotes'
  ] loop
    v_value := p_content -> v_key;
    if jsonb_typeof(v_value) <> 'array' or jsonb_array_length(v_value) > 50 then
      raise exception using errcode = '22023', message = 'invalid_guidance_list';
    end if;
    v_array := '[]'::jsonb;
    for v_item in select value from jsonb_array_elements(v_value) loop
      if jsonb_typeof(v_item) <> 'string' then
        raise exception using errcode = '22023', message = 'invalid_guidance_list_item';
      end if;
      v_normalized := private.normalize_guidance_string(v_item #>> '{}');
      if char_length(v_normalized) not between 1 and 500
         or replace(replace(v_normalized, E'\n', ''), E'\t', '') ~ '[[:cntrl:]]' then
        raise exception using errcode = '22023', message = 'invalid_guidance_list_item';
      end if;
      v_array := v_array || jsonb_build_array(v_normalized);
    end loop;
    v_result := v_result || jsonb_build_object(v_key, v_array);
    if v_key = 'setupSteps' then
      v_setup_count := jsonb_array_length(v_array);
    elsif v_key = 'executionSteps' then
      v_execution_count := jsonb_array_length(v_array);
    end if;
  end loop;

  if p_for_publication and v_setup_count + v_execution_count = 0 then
    raise exception using errcode = '22023', message = 'guidance_steps_required';
  end if;
  return v_result;
end;
$$;

create or replace function private.validate_equipment_payload(p_equipment jsonb)
returns void
language plpgsql
immutable
set search_path = ''
as $$
declare
  v_count integer;
begin
  if p_equipment is null or jsonb_typeof(p_equipment) <> 'array' then
    raise exception using errcode = '22023', message = 'invalid_equipment_payload';
  end if;
  v_count := jsonb_array_length(p_equipment);
  if v_count not between 1 and 10
     or exists (
       select 1
       from jsonb_array_elements(p_equipment) with ordinality as item(value, position)
       where jsonb_typeof(item.value) <> 'string'
          or (item.value #>> '{}') !~ '^[a-z][a-z0-9_]{0,63}$'
     )
     or (
       select count(distinct item.value #>> '{}')
       from jsonb_array_elements(p_equipment) as item(value)
     ) <> v_count then
    raise exception using errcode = '22023', message = 'invalid_equipment_payload';
  end if;
end;
$$;

create or replace function private.validate_muscle_payload(p_muscles jsonb)
returns void
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_count integer;
begin
  if p_muscles is null or jsonb_typeof(p_muscles) <> 'array' then
    raise exception using errcode = '22023', message = 'invalid_muscle_payload';
  end if;
  v_count := jsonb_array_length(p_muscles);
  if v_count not between 1 and 13 then
    raise exception using errcode = '22023', message = 'invalid_muscle_payload';
  end if;
  if exists (
    select 1
    from jsonb_array_elements(p_muscles) as item(value)
    where jsonb_typeof(item.value) <> 'object'
       or not (item.value ?& array['muscleId', 'role', 'position'])
       or (item.value - array['muscleId', 'role', 'position']) <> '{}'::jsonb
       or jsonb_typeof(item.value -> 'muscleId') <> 'string'
       or (item.value ->> 'muscleId') !~* '^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
       or item.value ->> 'role' not in ('primary', 'secondary')
       or jsonb_typeof(item.value -> 'position') <> 'number'
       or (item.value ->> 'position') !~ '^([1-9]|1[0-3])$'
  ) then
    raise exception using errcode = '22023', message = 'invalid_muscle_payload';
  end if;
  if not exists (
    select 1 from jsonb_array_elements(p_muscles) as item(value)
    where item.value ->> 'role' = 'primary'
  ) then
    raise exception using errcode = '22023', message = 'invalid_muscle_payload';
  end if;
  if (
    select count(distinct lower(item.value ->> 'muscleId'))
    from jsonb_array_elements(p_muscles) as item(value)
  ) <> v_count then
    raise exception using errcode = '22023', message = 'invalid_muscle_payload';
  end if;
  if exists (
    select 1
    from jsonb_array_elements(p_muscles) as item(value)
    left join public.muscles as muscle
      on muscle.id::text = lower(item.value ->> 'muscleId')
     and muscle.active
    where muscle.id is null
  ) then
    raise exception using errcode = '22023', message = 'invalid_muscle_payload';
  end if;
  if exists (
    select 1
    from (
      select
        item.value ->> 'role' as role,
        count(*) as row_count,
        count(distinct item.value ->> 'position') as distinct_position_count,
        min((item.value ->> 'position')::integer) as minimum_position,
        max((item.value ->> 'position')::integer) as maximum_position
      from jsonb_array_elements(p_muscles) as item(value)
      group by item.value ->> 'role'
    ) as positions
    where positions.distinct_position_count <> positions.row_count
       or positions.minimum_position <> 1
       or positions.maximum_position <> positions.row_count
  ) then
    raise exception using errcode = '22023', message = 'invalid_muscle_payload';
  end if;
end;
$$;

create or replace function private.exercise_identity_fingerprint(
  p_normalized_name text,
  p_variant_key text,
  p_equipment jsonb
)
returns text
language sql
immutable
set search_path = ''
as $$
  select private.sha256_jsonb(jsonb_build_array(
    p_normalized_name,
    p_variant_key,
    coalesce(
      (select jsonb_agg(value #>> '{}' order by value #>> '{}')
       from jsonb_array_elements(p_equipment)),
      '[]'::jsonb
    )
  ));
$$;

create or replace function private.load_mutation_result(
  p_user_id uuid,
  p_operation_name text,
  p_idempotency_key uuid,
  p_request_fingerprint text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_operation private.guidance_mutation_operations%rowtype;
begin
  if p_idempotency_key is null
     or p_operation_name !~ '^[a-z][a-z0-9_]{0,63}$'
     or p_request_fingerprint !~ '^[0-9a-f]{64}$' then
    raise exception using errcode = '22023', message = 'invalid_idempotency_request';
  end if;
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(
      'stone_set_mutation:' || p_user_id::text || ':' || p_operation_name || ':' || p_idempotency_key::text,
      0
    )
  );
  select * into v_operation
  from private.guidance_mutation_operations
  where user_id = p_user_id
    and operation_name = p_operation_name
    and idempotency_key = p_idempotency_key;
  if found then
    if v_operation.request_fingerprint <> p_request_fingerprint then
      raise exception using errcode = '22023', message = 'idempotency_key_reused';
    end if;
    return v_operation.result || jsonb_build_object('replayed', true);
  end if;
  return null;
end;
$$;

create or replace function private.store_mutation_result(
  p_user_id uuid,
  p_operation_name text,
  p_idempotency_key uuid,
  p_request_fingerprint text,
  p_result jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_correlation_id uuid := gen_random_uuid();
  v_stored_result jsonb;
begin
  v_stored_result := p_result || jsonb_build_object('correlationId', v_correlation_id);
  insert into private.guidance_mutation_operations (
    user_id, operation_name, idempotency_key, request_fingerprint, correlation_id, result
  ) values (
    p_user_id, p_operation_name, p_idempotency_key, p_request_fingerprint,
    v_correlation_id, v_stored_result
  );
  return v_stored_result || jsonb_build_object('replayed', false);
end;
$$;

create or replace function private.reject_immutable_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception using errcode = '42501', message = 'immutable_product_record';
end;
$$;

create or replace function private.assert_exercise_children_complete()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_exercise_id uuid := coalesce(
    nullif(to_jsonb(new) ->> 'exercise_id', '')::uuid,
    nullif(to_jsonb(old) ->> 'exercise_id', '')::uuid,
    nullif(to_jsonb(new) ->> 'id', '')::uuid,
    nullif(to_jsonb(old) ->> 'id', '')::uuid
  );
begin
  if exists (select 1 from public.exercise_definitions where id = v_exercise_id) then
    if not exists (
      select 1 from public.exercise_definition_muscles
      where exercise_id = v_exercise_id and role = 'primary'
    ) then
      raise exception using errcode = '23514', message = 'exercise_primary_muscle_required';
    end if;
    if (select count(*) from public.exercise_definition_equipment where exercise_id = v_exercise_id)
       not between 1 and 10 then
      raise exception using errcode = '23514', message = 'exercise_equipment_count_invalid';
    end if;
  end if;
  return null;
end;
$$;

create trigger muscles_immutable
before update or delete on public.muscles
for each row execute function private.reject_immutable_change();
create trigger guidance_revisions_immutable
before update or delete on public.guidance_revisions
for each row execute function private.reject_immutable_change();
create trigger guidance_revision_muscles_immutable
before update or delete on public.guidance_revision_muscles
for each row execute function private.reject_immutable_change();

create trigger exercise_definitions_revision_timestamp
before update on public.exercise_definitions
for each row execute function private.set_revision_timestamp();
create trigger guidance_drafts_revision_timestamp
before update on public.guidance_drafts
for each row execute function private.set_revision_timestamp();

create constraint trigger exercise_definitions_require_children
after insert or update on public.exercise_definitions
deferrable initially deferred
for each row execute function private.assert_exercise_children_complete();
create constraint trigger exercise_equipment_require_complete
after insert or update or delete on public.exercise_definition_equipment
deferrable initially deferred
for each row execute function private.assert_exercise_children_complete();
create constraint trigger exercise_muscles_require_complete
after insert or update or delete on public.exercise_definition_muscles
deferrable initially deferred
for each row execute function private.assert_exercise_children_complete();

create or replace function private.replace_exercise_children(
  p_user_id uuid,
  p_exercise_id uuid,
  p_equipment jsonb,
  p_muscles jsonb
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  perform private.validate_equipment_payload(p_equipment);
  perform private.validate_muscle_payload(p_muscles);

  delete from public.exercise_definition_equipment where exercise_id = p_exercise_id;
  insert into public.exercise_definition_equipment (
    exercise_id, user_id, equipment_key, position
  )
  select p_exercise_id, p_user_id, item.value #>> '{}', item.position::integer
  from jsonb_array_elements(p_equipment) with ordinality as item(value, position);

  delete from public.exercise_definition_muscles where exercise_id = p_exercise_id;
  insert into public.exercise_definition_muscles (
    exercise_id, user_id, muscle_id, role, position
  )
  select
    p_exercise_id,
    p_user_id,
    (item.value ->> 'muscleId')::uuid,
    item.value ->> 'role',
    (item.value ->> 'position')::integer
  from jsonb_array_elements(p_muscles) as item(value);
end;
$$;

create or replace function private.exercise_duplicate_exists(
  p_user_id uuid,
  p_exclude_exercise_id uuid,
  p_normalized_name text,
  p_variant_key text,
  p_equipment jsonb
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.exercise_definitions as exercise
    where exercise.user_id = p_user_id
      and exercise.id is distinct from p_exclude_exercise_id
      and exercise.normalized_name = p_normalized_name
      and exercise.variant_key is not distinct from p_variant_key
      and (
        select array_agg(equipment.equipment_key order by equipment.equipment_key)
        from public.exercise_definition_equipment as equipment
        where equipment.exercise_id = exercise.id
      ) = (
        select array_agg(item.value #>> '{}' order by item.value #>> '{}')
        from jsonb_array_elements(p_equipment) as item(value)
      )
  );
$$;

create or replace function private.create_exercise_v1(
  p_canonical_name text,
  p_variant_key text,
  p_equipment jsonb,
  p_muscles jsonb,
  p_duplicate_confirmed boolean,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_canonical_name text;
  v_normalized_name text;
  v_variant_key text := nullif(p_variant_key, '');
  v_fingerprint text;
  v_replayed jsonb;
  v_exercise public.exercise_definitions%rowtype;
  v_draft public.guidance_drafts%rowtype;
  v_result jsonb;
begin
  if p_canonical_name is null or p_duplicate_confirmed is null then
    raise exception using errcode = '22023', message = 'invalid_exercise_payload';
  end if;
  v_canonical_name := regexp_replace(
    btrim(normalize(p_canonical_name, NFC)),
    U&'([[:space:]]|[\00A0\1680\2000-\200A\2028\2029\202F\205F\3000])+',
    ' ',
    'g'
  );
  v_normalized_name := private.normalize_exercise_name(p_canonical_name);
  if char_length(v_canonical_name) not between 1 and 120
     or v_canonical_name !~ '[^[:space:]]'
     or v_canonical_name ~ '[[:cntrl:]]'
     or (v_variant_key is not null and v_variant_key !~ '^[a-z][a-z0-9_]{0,63}$') then
    raise exception using errcode = '22023', message = 'invalid_exercise_payload';
  end if;
  perform private.validate_equipment_payload(p_equipment);
  perform private.validate_muscle_payload(p_muscles);

  v_fingerprint := private.sha256_jsonb(jsonb_build_array(
    v_canonical_name, v_variant_key, p_equipment, p_muscles, p_duplicate_confirmed
  ));
  v_replayed := private.load_mutation_result(
    v_user_id, 'create_exercise_v1', p_idempotency_key, v_fingerprint
  );
  if v_replayed is not null then return v_replayed; end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended('stone_set_exercise_duplicate:' || v_user_id::text, 0)
  );
  if private.exercise_duplicate_exists(
    v_user_id, null, v_normalized_name, v_variant_key, p_equipment
  ) and not p_duplicate_confirmed then
    raise exception using errcode = 'P0001', message = 'duplicate_exercise_confirmation_required';
  end if;

  insert into public.exercise_definitions (
    user_id, canonical_name, normalized_name, variant_key
  ) values (
    v_user_id, v_canonical_name, v_normalized_name, v_variant_key
  ) returning * into v_exercise;
  perform private.replace_exercise_children(v_user_id, v_exercise.id, p_equipment, p_muscles);

  insert into public.guidance_drafts (
    exercise_id, user_id, structured_content
  ) values (
    v_exercise.id,
    v_user_id,
    jsonb_build_object(
      'shortExplanation', '',
      'setupSteps', jsonb_build_array(),
      'executionSteps', jsonb_build_array(),
      'techniqueCues', jsonb_build_array(),
      'commonMistakes', jsonb_build_array(),
      'safetyNotes', jsonb_build_array()
    )
  ) returning * into v_draft;

  v_result := jsonb_build_object(
    'operation', 'create_exercise_v1',
    'exerciseId', v_exercise.id,
    'exerciseRevision', v_exercise.revision,
    'draftId', v_draft.id,
    'draftRevision', v_draft.revision,
    'duplicateConfirmed', p_duplicate_confirmed
  );
  return private.store_mutation_result(
    v_user_id, 'create_exercise_v1', p_idempotency_key, v_fingerprint, v_result
  );
end;
$$;

create or replace function public.create_exercise_v1(
  p_canonical_name text,
  p_variant_key text,
  p_equipment jsonb,
  p_muscles jsonb,
  p_duplicate_confirmed boolean,
  p_idempotency_key uuid
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
  select private.create_exercise_v1(
    p_canonical_name, p_variant_key, p_equipment, p_muscles,
    p_duplicate_confirmed, p_idempotency_key
  );
$$;

create or replace function private.update_exercise_v1(
  p_exercise_id uuid,
  p_canonical_name text,
  p_variant_key text,
  p_equipment jsonb,
  p_muscles jsonb,
  p_expected_revision bigint,
  p_duplicate_confirmed boolean,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_canonical_name text;
  v_normalized_name text;
  v_variant_key text := nullif(p_variant_key, '');
  v_fingerprint text;
  v_replayed jsonb;
  v_exercise public.exercise_definitions%rowtype;
  v_existing_equipment text[];
  v_requested_equipment text[];
  v_result jsonb;
begin
  if p_exercise_id is null or p_canonical_name is null
     or p_expected_revision is null or p_duplicate_confirmed is null then
    raise exception using errcode = '22023', message = 'invalid_exercise_payload';
  end if;
  v_canonical_name := regexp_replace(
    btrim(normalize(p_canonical_name, NFC)),
    U&'([[:space:]]|[\00A0\1680\2000-\200A\2028\2029\202F\205F\3000])+',
    ' ',
    'g'
  );
  v_normalized_name := private.normalize_exercise_name(p_canonical_name);
  if char_length(v_canonical_name) not between 1 and 120
     or v_canonical_name ~ '[[:cntrl:]]'
     or (v_variant_key is not null and v_variant_key !~ '^[a-z][a-z0-9_]{0,63}$') then
    raise exception using errcode = '22023', message = 'invalid_exercise_payload';
  end if;
  perform private.validate_equipment_payload(p_equipment);
  perform private.validate_muscle_payload(p_muscles);
  v_fingerprint := private.sha256_jsonb(jsonb_build_array(
    p_exercise_id, v_canonical_name, v_variant_key, p_equipment, p_muscles,
    p_expected_revision, p_duplicate_confirmed
  ));
  v_replayed := private.load_mutation_result(
    v_user_id, 'update_exercise_v1', p_idempotency_key, v_fingerprint
  );
  if v_replayed is not null then return v_replayed; end if;

  select * into v_exercise
  from public.exercise_definitions
  where id = p_exercise_id and user_id = v_user_id
  for update;
  if not found then raise exception using errcode = 'P0002', message = 'exercise_not_found'; end if;
  if v_exercise.revision <> p_expected_revision then
    raise exception using
      errcode = '40001',
      message = 'stale_exercise_revision',
      detail = jsonb_build_object(
        'correlationId', gen_random_uuid(),
        'exerciseRevision', v_exercise.revision
      )::text;
  end if;

  select array_agg(equipment_key order by equipment_key) into v_existing_equipment
  from public.exercise_definition_equipment where exercise_id = p_exercise_id;
  select array_agg(item.value #>> '{}' order by item.value #>> '{}') into v_requested_equipment
  from jsonb_array_elements(p_equipment) as item(value);
  if exists (
    select 1 from public.guidance_revisions where exercise_id = p_exercise_id
  ) and (
    v_exercise.canonical_name is distinct from v_canonical_name
    or v_exercise.variant_key is distinct from v_variant_key
    or v_existing_equipment is distinct from v_requested_equipment
  ) then
    raise exception using errcode = 'P0001', message = 'published_exercise_identity_locked';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended('stone_set_exercise_duplicate:' || v_user_id::text, 0)
  );
  if private.exercise_duplicate_exists(
    v_user_id, p_exercise_id, v_normalized_name, v_variant_key, p_equipment
  ) and not p_duplicate_confirmed then
    raise exception using errcode = 'P0001', message = 'duplicate_exercise_confirmation_required';
  end if;

  update public.exercise_definitions
  set canonical_name = v_canonical_name,
      normalized_name = v_normalized_name,
      variant_key = v_variant_key
  where id = p_exercise_id
  returning * into v_exercise;
  perform private.replace_exercise_children(v_user_id, p_exercise_id, p_equipment, p_muscles);
  v_result := jsonb_build_object(
    'operation', 'update_exercise_v1',
    'exerciseId', v_exercise.id,
    'exerciseRevision', v_exercise.revision
  );
  return private.store_mutation_result(
    v_user_id, 'update_exercise_v1', p_idempotency_key, v_fingerprint, v_result
  );
end;
$$;

create or replace function public.update_exercise_v1(
  p_exercise_id uuid,
  p_canonical_name text,
  p_variant_key text,
  p_equipment jsonb,
  p_muscles jsonb,
  p_expected_revision bigint,
  p_duplicate_confirmed boolean,
  p_idempotency_key uuid
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
  select private.update_exercise_v1(
    p_exercise_id, p_canonical_name, p_variant_key, p_equipment, p_muscles,
    p_expected_revision, p_duplicate_confirmed, p_idempotency_key
  );
$$;

create or replace function private.set_exercise_archived_v1(
  p_exercise_id uuid,
  p_archived boolean,
  p_expected_revision bigint,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_fingerprint text := private.sha256_jsonb(jsonb_build_array(
    p_exercise_id, p_archived, p_expected_revision
  ));
  v_replayed jsonb;
  v_exercise public.exercise_definitions%rowtype;
  v_result jsonb;
begin
  if p_exercise_id is null or p_archived is null or p_expected_revision is null then
    raise exception using errcode = '22023', message = 'invalid_archive_request';
  end if;
  v_replayed := private.load_mutation_result(
    v_user_id, 'set_exercise_archived_v1', p_idempotency_key, v_fingerprint
  );
  if v_replayed is not null then return v_replayed; end if;
  select * into v_exercise
  from public.exercise_definitions
  where id = p_exercise_id and user_id = v_user_id
  for update;
  if not found then raise exception using errcode = 'P0002', message = 'exercise_not_found'; end if;
  if v_exercise.revision <> p_expected_revision then
    raise exception using
      errcode = '40001',
      message = 'stale_exercise_revision',
      detail = jsonb_build_object(
        'correlationId', gen_random_uuid(),
        'exerciseRevision', v_exercise.revision
      )::text;
  end if;
  if (v_exercise.archived_at is not null) = p_archived then
    v_result := jsonb_build_object(
      'operation', 'set_exercise_archived_v1',
      'exerciseId', v_exercise.id,
      'exerciseRevision', v_exercise.revision,
      'archived', p_archived,
      'noChange', true
    );
  else
    update public.exercise_definitions
    set archived_at = case when p_archived then clock_timestamp() else null end
    where id = p_exercise_id
    returning * into v_exercise;
    v_result := jsonb_build_object(
      'operation', 'set_exercise_archived_v1',
      'exerciseId', v_exercise.id,
      'exerciseRevision', v_exercise.revision,
      'archived', p_archived,
      'noChange', false
    );
  end if;
  return private.store_mutation_result(
    v_user_id, 'set_exercise_archived_v1', p_idempotency_key, v_fingerprint, v_result
  );
end;
$$;

create or replace function public.set_exercise_archived_v1(
  p_exercise_id uuid,
  p_archived boolean,
  p_expected_revision bigint,
  p_idempotency_key uuid
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
  select private.set_exercise_archived_v1(
    p_exercise_id, p_archived, p_expected_revision, p_idempotency_key
  );
$$;

create or replace function private.save_guidance_draft_v1(
  p_draft_id uuid,
  p_structured_content jsonb,
  p_expected_revision bigint,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_normalized jsonb := private.normalize_guidance_content(p_structured_content, false);
  v_fingerprint text;
  v_replayed jsonb;
  v_draft public.guidance_drafts%rowtype;
  v_result jsonb;
begin
  if p_draft_id is null or p_expected_revision is null then
    raise exception using errcode = '22023', message = 'invalid_draft_save_request';
  end if;
  v_fingerprint := private.sha256_jsonb(jsonb_build_array(
    p_draft_id, private.sha256_jsonb(v_normalized), p_expected_revision
  ));
  v_replayed := private.load_mutation_result(
    v_user_id, 'save_guidance_draft_v1', p_idempotency_key, v_fingerprint
  );
  if v_replayed is not null then return v_replayed; end if;
  select * into v_draft
  from public.guidance_drafts
  where id = p_draft_id and user_id = v_user_id
  for update;
  if not found then raise exception using errcode = 'P0002', message = 'guidance_draft_not_found'; end if;
  if v_draft.revision <> p_expected_revision then
    raise exception using
      errcode = '40001',
      message = 'stale_guidance_draft_revision',
      detail = jsonb_build_object(
        'correlationId', gen_random_uuid(),
        'draftRevision', v_draft.revision
      )::text;
  end if;
  if v_draft.structured_content = v_normalized then
    v_result := jsonb_build_object(
      'operation', 'save_guidance_draft_v1',
      'draftId', v_draft.id,
      'draftRevision', v_draft.revision,
      'noChange', true
    );
  else
    update public.guidance_drafts
    set structured_content = v_normalized
    where id = p_draft_id
    returning * into v_draft;
    v_result := jsonb_build_object(
      'operation', 'save_guidance_draft_v1',
      'draftId', v_draft.id,
      'draftRevision', v_draft.revision,
      'noChange', false
    );
  end if;
  return private.store_mutation_result(
    v_user_id, 'save_guidance_draft_v1', p_idempotency_key, v_fingerprint, v_result
  );
end;
$$;

create or replace function public.save_guidance_draft_v1(
  p_draft_id uuid,
  p_structured_content jsonb,
  p_expected_revision bigint,
  p_idempotency_key uuid
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
  select private.save_guidance_draft_v1(
    p_draft_id, p_structured_content, p_expected_revision, p_idempotency_key
  );
$$;

create or replace function private.validate_guidance_draft_v1(
  p_exercise_id uuid,
  p_draft_id uuid,
  p_expected_exercise_revision bigint,
  p_expected_draft_revision bigint
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_exercise public.exercise_definitions%rowtype;
  v_draft public.guidance_drafts%rowtype;
begin
  if p_exercise_id is null
     or p_draft_id is null
     or p_expected_exercise_revision is null
     or p_expected_draft_revision is null then
    raise exception using
      errcode = '22023',
      message = 'invalid_guidance_validation_request';
  end if;

  select * into v_exercise
  from public.exercise_definitions
  where id = p_exercise_id and user_id = v_user_id;
  select * into v_draft
  from public.guidance_drafts
  where id = p_draft_id and exercise_id = p_exercise_id and user_id = v_user_id;
  if v_exercise.id is null or v_draft.id is null then
    raise exception using errcode = 'P0002', message = 'guidance_draft_not_found';
  end if;
  if v_exercise.revision <> p_expected_exercise_revision then
    raise exception using
      errcode = '40001',
      message = 'stale_exercise_revision',
      detail = jsonb_build_object(
        'correlationId', gen_random_uuid(),
        'exerciseRevision', v_exercise.revision,
        'draftRevision', v_draft.revision
      )::text;
  end if;
  if v_draft.revision <> p_expected_draft_revision then
    raise exception using
      errcode = '40001',
      message = 'stale_guidance_draft_revision',
      detail = jsonb_build_object(
        'correlationId', gen_random_uuid(),
        'exerciseRevision', v_exercise.revision,
        'draftRevision', v_draft.revision
      )::text;
  end if;
  if v_exercise.archived_at is not null then
    return jsonb_build_object(
      'valid', false,
      'issues', jsonb_build_array(jsonb_build_object(
        'code', 'exercise_archived', 'path', 'exercise'
      ))
    );
  end if;
  perform private.normalize_guidance_content(v_draft.structured_content, true);
  return jsonb_build_object(
    'valid', true,
    'issues', jsonb_build_array(),
    'exerciseRevision', v_exercise.revision,
    'draftRevision', v_draft.revision
  );
exception
  when sqlstate '22023' then
    if sqlerrm = 'invalid_guidance_validation_request' then
      raise;
    end if;
    return jsonb_build_object(
      'valid', false,
      'issues', jsonb_build_array(jsonb_build_object(
        'code', sqlerrm, 'path', 'structuredContent'
      )),
      'exerciseRevision', v_exercise.revision,
      'draftRevision', v_draft.revision
    );
end;
$$;

create or replace function public.validate_guidance_draft_v1(
  p_exercise_id uuid,
  p_draft_id uuid,
  p_expected_exercise_revision bigint,
  p_expected_draft_revision bigint
)
returns jsonb
language sql
volatile
security invoker
set search_path = ''
as $$
  select private.validate_guidance_draft_v1(
    p_exercise_id, p_draft_id, p_expected_exercise_revision, p_expected_draft_revision
  );
$$;

create or replace function private.publish_guidance_revision_v1(
  p_exercise_id uuid,
  p_draft_id uuid,
  p_expected_exercise_revision bigint,
  p_expected_draft_revision bigint,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_fingerprint text := private.sha256_jsonb(jsonb_build_array(
    p_exercise_id, p_draft_id, p_expected_exercise_revision, p_expected_draft_revision
  ));
  v_replayed jsonb;
  v_exercise public.exercise_definitions%rowtype;
  v_draft public.guidance_drafts%rowtype;
  v_content jsonb;
  v_equipment jsonb;
  v_primary_muscles jsonb;
  v_secondary_muscles jsonb;
  v_canonical jsonb;
  v_content_hash text;
  v_existing public.guidance_revisions%rowtype;
  v_previous public.guidance_revisions%rowtype;
  v_revision public.guidance_revisions%rowtype;
  v_revision_envelope jsonb;
  v_result jsonb;
begin
  if p_exercise_id is null or p_draft_id is null
     or p_expected_exercise_revision is null or p_expected_draft_revision is null then
    raise exception using errcode = '22023', message = 'invalid_publish_request';
  end if;
  v_replayed := private.load_mutation_result(
    v_user_id, 'publish_guidance_revision_v1', p_idempotency_key, v_fingerprint
  );
  if v_replayed is not null then return v_replayed; end if;

  select * into v_exercise
  from public.exercise_definitions
  where id = p_exercise_id and user_id = v_user_id
  for update;
  if not found then raise exception using errcode = 'P0002', message = 'exercise_not_found'; end if;
  perform 1 from public.exercise_definition_equipment
    where exercise_id = p_exercise_id order by position for update;
  perform 1 from public.exercise_definition_muscles
    where exercise_id = p_exercise_id order by role, position for update;
  select * into v_draft
  from public.guidance_drafts
  where id = p_draft_id and exercise_id = p_exercise_id and user_id = v_user_id
  for update;
  if not found then raise exception using errcode = 'P0002', message = 'guidance_draft_not_found'; end if;
  if v_exercise.revision <> p_expected_exercise_revision then
    raise exception using
      errcode = '40001',
      message = 'stale_exercise_revision',
      detail = jsonb_build_object(
        'correlationId', gen_random_uuid(),
        'exerciseRevision', v_exercise.revision,
        'draftRevision', v_draft.revision
      )::text;
  end if;
  if v_draft.revision <> p_expected_draft_revision then
    raise exception using
      errcode = '40001',
      message = 'stale_guidance_draft_revision',
      detail = jsonb_build_object(
        'correlationId', gen_random_uuid(),
        'exerciseRevision', v_exercise.revision,
        'draftRevision', v_draft.revision
      )::text;
  end if;
  if v_exercise.archived_at is not null then
    raise exception using errcode = 'P0001', message = 'archived_exercise_cannot_publish';
  end if;

  v_content := private.normalize_guidance_content(v_draft.structured_content, true);
  select jsonb_agg(equipment_key order by position) into v_equipment
  from public.exercise_definition_equipment where exercise_id = p_exercise_id;
  select coalesce(jsonb_agg(muscle.stable_key order by assignment.position), '[]'::jsonb)
  into v_primary_muscles
  from public.exercise_definition_muscles as assignment
  join public.muscles as muscle on muscle.id = assignment.muscle_id
  where assignment.exercise_id = p_exercise_id and assignment.role = 'primary';
  select coalesce(jsonb_agg(muscle.stable_key order by assignment.position), '[]'::jsonb)
  into v_secondary_muscles
  from public.exercise_definition_muscles as assignment
  join public.muscles as muscle on muscle.id = assignment.muscle_id
  where assignment.exercise_id = p_exercise_id and assignment.role = 'secondary';

  v_canonical := jsonb_build_array(
    'stone-set-guidance-content-v1',
    v_exercise.normalized_name,
    v_exercise.variant_key,
    v_equipment,
    v_primary_muscles,
    v_secondary_muscles,
    v_content ->> 'shortExplanation',
    v_content -> 'setupSteps',
    v_content -> 'executionSteps',
    v_content -> 'techniqueCues',
    v_content -> 'commonMistakes',
    v_content -> 'safetyNotes'
  );
  v_content_hash := private.sha256_jsonb(v_canonical);

  select * into v_existing
  from public.guidance_revisions
  where exercise_id = p_exercise_id and content_hash = v_content_hash;
  if found then
    v_result := jsonb_build_object(
      'operation', 'publish_guidance_revision_v1',
      'exerciseId', p_exercise_id,
      'guidanceRevisionId', v_existing.id,
      'versionNumber', v_existing.version_number,
      'contentHash', v_existing.content_hash,
      'revisionHash', v_existing.revision_hash,
      'draftRevision', v_draft.revision,
      'noChange', true
    );
    return private.store_mutation_result(
      v_user_id, 'publish_guidance_revision_v1', p_idempotency_key, v_fingerprint, v_result
    );
  end if;

  select * into v_previous
  from public.guidance_revisions
  where exercise_id = p_exercise_id
  order by version_number desc
  limit 1
  for update;

  v_revision.id := gen_random_uuid();
  v_revision.version_number := coalesce(v_previous.version_number, 0) + 1;
  v_revision_envelope := jsonb_build_array(
    'stone-set-guidance-revision-v1',
    p_exercise_id::text,
    v_user_id::text,
    v_revision.version_number,
    v_content_hash,
    case when v_previous.id is null then null else to_jsonb(v_previous.id::text) end
  );

  insert into public.guidance_revisions (
    id,
    exercise_id,
    user_id,
    version_number,
    structured_content_schema_version,
    structured_content,
    canonical_name_snapshot,
    normalized_name_snapshot,
    variant_key_snapshot,
    equipment_keys_snapshot,
    content_hash,
    revision_hash,
    supersedes_revision_id
  ) values (
    v_revision.id,
    p_exercise_id,
    v_user_id,
    v_revision.version_number,
    1,
    v_content,
    v_exercise.canonical_name,
    v_exercise.normalized_name,
    v_exercise.variant_key,
    v_equipment,
    v_content_hash,
    private.sha256_jsonb(v_revision_envelope),
    v_previous.id
  ) returning * into v_revision;

  insert into public.guidance_revision_muscles (
    guidance_revision_id, user_id, muscle_id, muscle_key_snapshot, role, position
  )
  select
    v_revision.id,
    v_user_id,
    assignment.muscle_id,
    muscle.stable_key,
    assignment.role,
    assignment.position
  from public.exercise_definition_muscles as assignment
  join public.muscles as muscle on muscle.id = assignment.muscle_id
  where assignment.exercise_id = p_exercise_id
  order by assignment.role, assignment.position;

  update public.guidance_drafts
  set base_guidance_revision_id = v_revision.id,
      structured_content = v_content
  where id = p_draft_id
  returning * into v_draft;

  v_result := jsonb_build_object(
    'operation', 'publish_guidance_revision_v1',
    'exerciseId', p_exercise_id,
    'guidanceRevisionId', v_revision.id,
    'versionNumber', v_revision.version_number,
    'contentHash', v_revision.content_hash,
    'revisionHash', v_revision.revision_hash,
    'draftRevision', v_draft.revision,
    'noChange', false
  );
  return private.store_mutation_result(
    v_user_id, 'publish_guidance_revision_v1', p_idempotency_key, v_fingerprint, v_result
  );
end;
$$;

create or replace function public.publish_guidance_revision_v1(
  p_exercise_id uuid,
  p_draft_id uuid,
  p_expected_exercise_revision bigint,
  p_expected_draft_revision bigint,
  p_idempotency_key uuid
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
  select private.publish_guidance_revision_v1(
    p_exercise_id, p_draft_id, p_expected_exercise_revision,
    p_expected_draft_revision, p_idempotency_key
  );
$$;

create or replace function private.clone_exercise_v1(
  p_source_exercise_id uuid,
  p_canonical_name text,
  p_duplicate_confirmed boolean,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_source public.exercise_definitions%rowtype;
  v_source_draft public.guidance_drafts%rowtype;
  v_canonical_name text;
  v_normalized_name text;
  v_equipment jsonb;
  v_muscles jsonb;
  v_fingerprint text;
  v_replayed jsonb;
  v_exercise public.exercise_definitions%rowtype;
  v_draft public.guidance_drafts%rowtype;
  v_result jsonb;
begin
  if p_source_exercise_id is null or p_duplicate_confirmed is null then
    raise exception using errcode = '22023', message = 'invalid_clone_request';
  end if;
  select * into v_source
  from public.exercise_definitions
  where id = p_source_exercise_id and user_id = v_user_id
  for update;
  if not found then raise exception using errcode = 'P0002', message = 'exercise_not_found'; end if;
  select * into v_source_draft
  from public.guidance_drafts
  where exercise_id = p_source_exercise_id and user_id = v_user_id
  for update;
  if not found then raise exception using errcode = 'P0002', message = 'guidance_draft_not_found'; end if;

  v_canonical_name := regexp_replace(
    btrim(normalize(coalesce(p_canonical_name, v_source.canonical_name), NFC)),
    U&'([[:space:]]|[\00A0\1680\2000-\200A\2028\2029\202F\205F\3000])+', ' ', 'g'
  );
  v_normalized_name := private.normalize_exercise_name(v_canonical_name);
  if char_length(v_canonical_name) not between 1 and 120 or v_canonical_name ~ '[[:cntrl:]]' then
    raise exception using errcode = '22023', message = 'invalid_exercise_payload';
  end if;
  select jsonb_agg(equipment_key order by position) into v_equipment
  from public.exercise_definition_equipment where exercise_id = p_source_exercise_id;
  select jsonb_agg(jsonb_build_object(
    'muscleId', muscle_id,
    'role', role,
    'position', position
  ) order by role, position) into v_muscles
  from public.exercise_definition_muscles where exercise_id = p_source_exercise_id;

  v_fingerprint := private.sha256_jsonb(jsonb_build_array(
    p_source_exercise_id, v_canonical_name, p_duplicate_confirmed
  ));
  v_replayed := private.load_mutation_result(
    v_user_id, 'clone_exercise_v1', p_idempotency_key, v_fingerprint
  );
  if v_replayed is not null then return v_replayed; end if;
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended('stone_set_exercise_duplicate:' || v_user_id::text, 0)
  );
  if private.exercise_duplicate_exists(
    v_user_id, null, v_normalized_name, v_source.variant_key, v_equipment
  ) and not p_duplicate_confirmed then
    raise exception using errcode = 'P0001', message = 'duplicate_exercise_confirmation_required';
  end if;

  insert into public.exercise_definitions (
    user_id, canonical_name, normalized_name, variant_key, cloned_from_exercise_id
  ) values (
    v_user_id, v_canonical_name, v_normalized_name, v_source.variant_key, v_source.id
  ) returning * into v_exercise;
  perform private.replace_exercise_children(v_user_id, v_exercise.id, v_equipment, v_muscles);
  insert into public.guidance_drafts (
    exercise_id, user_id, structured_content
  ) values (
    v_exercise.id, v_user_id, v_source_draft.structured_content
  ) returning * into v_draft;
  v_result := jsonb_build_object(
    'operation', 'clone_exercise_v1',
    'sourceExerciseId', v_source.id,
    'exerciseId', v_exercise.id,
    'exerciseRevision', v_exercise.revision,
    'draftId', v_draft.id,
    'draftRevision', v_draft.revision
  );
  return private.store_mutation_result(
    v_user_id, 'clone_exercise_v1', p_idempotency_key, v_fingerprint, v_result
  );
end;
$$;

create or replace function public.clone_exercise_v1(
  p_source_exercise_id uuid,
  p_canonical_name text,
  p_duplicate_confirmed boolean,
  p_idempotency_key uuid
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
  select private.clone_exercise_v1(
    p_source_exercise_id, p_canonical_name, p_duplicate_confirmed, p_idempotency_key
  );
$$;

create or replace function private.duplicate_guidance_revision_as_draft_v1(
  p_exercise_id uuid,
  p_guidance_revision_id uuid,
  p_expected_draft_revision bigint,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_source public.guidance_revisions%rowtype;
  v_exercise public.exercise_definitions%rowtype;
  v_draft public.guidance_drafts%rowtype;
  v_fingerprint text := private.sha256_jsonb(jsonb_build_array(
    p_exercise_id, p_guidance_revision_id, p_expected_draft_revision
  ));
  v_replayed jsonb;
  v_result jsonb;
begin
  if p_exercise_id is null or p_guidance_revision_id is null
     or p_expected_draft_revision is null then
    raise exception using errcode = '22023', message = 'invalid_duplicate_revision_request';
  end if;
  v_replayed := private.load_mutation_result(
    v_user_id,
    'duplicate_guidance_revision_as_draft_v1',
    p_idempotency_key,
    v_fingerprint
  );
  if v_replayed is not null then return v_replayed; end if;

  select * into v_source
  from public.guidance_revisions
  where id = p_guidance_revision_id
    and exercise_id = p_exercise_id
    and user_id = v_user_id;
  if not found then
    raise exception using errcode = 'P0002', message = 'guidance_revision_not_found';
  end if;
  select * into v_exercise
  from public.exercise_definitions
  where id = p_exercise_id and user_id = v_user_id
  for update;
  if not found then
    raise exception using errcode = 'P0002', message = 'exercise_not_found';
  end if;
  if v_exercise.archived_at is not null then
    raise exception using errcode = 'P0001', message = 'archived_exercise_is_read_only';
  end if;
  perform 1
  from public.guidance_revisions
  where id = p_guidance_revision_id
    and exercise_id = p_exercise_id
    and user_id = v_user_id
  for key share;
  select * into v_draft
  from public.guidance_drafts
  where exercise_id = v_source.exercise_id and user_id = v_user_id
  for update;
  if not found then
    raise exception using errcode = 'P0002', message = 'guidance_draft_not_found';
  end if;
  if v_draft.revision <> p_expected_draft_revision then
    raise exception using
      errcode = '40001',
      message = 'stale_guidance_draft_revision',
      detail = jsonb_build_object(
        'correlationId', gen_random_uuid(),
        'exerciseRevision', v_exercise.revision,
        'draftRevision', v_draft.revision
      )::text;
  end if;

  if v_draft.base_guidance_revision_id = v_source.id
     and v_draft.structured_content = v_source.structured_content then
    v_result := jsonb_build_object(
      'operation', 'duplicate_guidance_revision_as_draft_v1',
      'exerciseId', v_source.exercise_id,
      'sourceGuidanceRevisionId', v_source.id,
      'draftId', v_draft.id,
      'draftRevision', v_draft.revision,
      'noChange', true
    );
  else
    update public.guidance_drafts
    set base_guidance_revision_id = v_source.id,
        structured_content = v_source.structured_content
    where id = v_draft.id
    returning * into v_draft;
    v_result := jsonb_build_object(
      'operation', 'duplicate_guidance_revision_as_draft_v1',
      'exerciseId', v_source.exercise_id,
      'sourceGuidanceRevisionId', v_source.id,
      'draftId', v_draft.id,
      'draftRevision', v_draft.revision,
      'noChange', false
    );
  end if;
  return private.store_mutation_result(
    v_user_id,
    'duplicate_guidance_revision_as_draft_v1',
    p_idempotency_key,
    v_fingerprint,
    v_result
  );
end;
$$;

create or replace function public.duplicate_guidance_revision_as_draft_v1(
  p_exercise_id uuid,
  p_guidance_revision_id uuid,
  p_expected_draft_revision bigint,
  p_idempotency_key uuid
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
  select private.duplicate_guidance_revision_as_draft_v1(
    p_exercise_id, p_guidance_revision_id, p_expected_draft_revision, p_idempotency_key
  );
$$;

create or replace function public.list_exercises_v1(
  p_search text default null,
  p_archive_filter text default 'active',
  p_publication_filter text default 'all',
  p_equipment_keys text[] default array[]::text[],
  p_muscle_keys text[] default array[]::text[],
  p_sort text default 'name_asc',
  p_page integer default 1,
  p_page_size integer default 50
)
returns jsonb
language plpgsql
stable
security invoker
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_search text := lower(btrim(normalize(coalesce(p_search, ''), NFC)));
  v_total bigint;
  v_items jsonb;
begin
  if v_user_id is null
     or not private.current_session_is_authorized(true, false) then
    raise exception using errcode = '42501', message = 'product_identity_not_authorized';
  end if;
  if char_length(v_search) > 120
     or p_archive_filter is null
     or p_archive_filter not in ('all', 'active', 'archived')
     or p_publication_filter is null
     or p_publication_filter not in ('all', 'published', 'unpublished')
     or p_sort is null
     or p_sort not in ('name_asc', 'name_desc', 'updated_asc', 'updated_desc', 'publication_desc')
     or p_page is null
     or p_page not between 1 and 100000
     or p_page_size is null
     or p_page_size not between 1 and 100
     or cardinality(coalesce(p_equipment_keys, array[]::text[])) > 10
     or cardinality(coalesce(p_muscle_keys, array[]::text[])) > 13
     or exists (
       select 1 from unnest(coalesce(p_equipment_keys, array[]::text[])) as key(value)
       where key.value !~ '^[a-z][a-z0-9_]{0,63}$'
     )
     or exists (
       select 1 from unnest(coalesce(p_muscle_keys, array[]::text[])) as key(value)
       where key.value !~ '^[a-z][a-z0-9_]{0,63}$'
     )
     or (
       select count(distinct key.value)
       from unnest(coalesce(p_equipment_keys, array[]::text[])) as key(value)
     ) <> cardinality(coalesce(p_equipment_keys, array[]::text[]))
     or (
       select count(distinct key.value)
       from unnest(coalesce(p_muscle_keys, array[]::text[])) as key(value)
     ) <> cardinality(coalesce(p_muscle_keys, array[]::text[]))
     or exists (
       select 1
       from unnest(coalesce(p_muscle_keys, array[]::text[])) as key(value)
       where not exists (
         select 1 from public.muscles as muscle
         where muscle.stable_key = key.value and muscle.active
       )
     ) then
    raise exception using errcode = '22023', message = 'invalid_exercise_list_request';
  end if;

  with filtered as (
    select exercise.id
    from public.exercise_definitions as exercise
    left join public.guidance_drafts as draft on draft.exercise_id = exercise.id
    where exercise.user_id = v_user_id
      and (
        v_search = ''
        or position(v_search in lower(exercise.canonical_name)) > 0
        or position(v_search in lower(coalesce(draft.structured_content ->> 'shortExplanation', ''))) > 0
      )
      and (
        p_archive_filter = 'all'
        or (p_archive_filter = 'active' and exercise.archived_at is null)
        or (p_archive_filter = 'archived' and exercise.archived_at is not null)
      )
      and (
        p_publication_filter = 'all'
        or (
          p_publication_filter = 'published'
          and exists (
            select 1 from public.guidance_revisions as revision
            where revision.exercise_id = exercise.id
          )
        )
        or (
          p_publication_filter = 'unpublished'
          and not exists (
            select 1 from public.guidance_revisions as revision
            where revision.exercise_id = exercise.id
          )
        )
      )
      and (
        not exists (
          select 1
          from unnest(coalesce(p_equipment_keys, array[]::text[])) as selected(value)
          where not exists (
            select 1 from public.exercise_definition_equipment as equipment
            where equipment.exercise_id = exercise.id
              and equipment.equipment_key = selected.value
          )
        )
      )
      and (
        not exists (
          select 1
          from unnest(coalesce(p_muscle_keys, array[]::text[])) as selected(value)
          where not exists (
            select 1
            from public.exercise_definition_muscles as assignment
            join public.muscles as muscle on muscle.id = assignment.muscle_id
            where assignment.exercise_id = exercise.id
              and muscle.stable_key = selected.value
          )
        )
      )
  )
  select count(*) into v_total from filtered;

  with filtered as (
    select
      exercise.*,
      draft.id as draft_id,
      draft.revision as draft_revision,
      exists (
        select 1 from public.guidance_revisions as revision
        where revision.exercise_id = exercise.id
      ) as is_published
    from public.exercise_definitions as exercise
    left join public.guidance_drafts as draft on draft.exercise_id = exercise.id
    where exercise.user_id = v_user_id
      and (
        v_search = ''
        or position(v_search in lower(exercise.canonical_name)) > 0
        or position(v_search in lower(coalesce(draft.structured_content ->> 'shortExplanation', ''))) > 0
      )
      and (
        p_archive_filter = 'all'
        or (p_archive_filter = 'active' and exercise.archived_at is null)
        or (p_archive_filter = 'archived' and exercise.archived_at is not null)
      )
      and (
        p_publication_filter = 'all'
        or (
          p_publication_filter = 'published'
          and exists (
            select 1 from public.guidance_revisions as revision
            where revision.exercise_id = exercise.id
          )
        )
        or (
          p_publication_filter = 'unpublished'
          and not exists (
            select 1 from public.guidance_revisions as revision
            where revision.exercise_id = exercise.id
          )
        )
      )
      and (
        not exists (
          select 1
          from unnest(coalesce(p_equipment_keys, array[]::text[])) as selected(value)
          where not exists (
            select 1 from public.exercise_definition_equipment as equipment
            where equipment.exercise_id = exercise.id
              and equipment.equipment_key = selected.value
          )
        )
      )
      and (
        not exists (
          select 1
          from unnest(coalesce(p_muscle_keys, array[]::text[])) as selected(value)
          where not exists (
            select 1
            from public.exercise_definition_muscles as assignment
            join public.muscles as muscle on muscle.id = assignment.muscle_id
            where assignment.exercise_id = exercise.id
              and muscle.stable_key = selected.value
          )
        )
      )
  ),
  page as (
    select *
    from filtered
    order by
      case when p_sort = 'name_asc' then normalized_name end asc,
      case when p_sort = 'name_desc' then normalized_name end desc,
      case when p_sort = 'updated_asc' then updated_at end asc,
      case when p_sort = 'updated_desc' then updated_at end desc,
      case when p_sort = 'publication_desc' then is_published end desc,
      case when p_sort = 'publication_desc' then updated_at end desc,
      id
    limit p_page_size
    offset ((p_page - 1)::bigint * p_page_size)
  )
  select coalesce(jsonb_agg(jsonb_build_object(
    'id', page.id,
    'userId', page.user_id,
    'canonicalName', page.canonical_name,
    'normalizedName', page.normalized_name,
    'variantKey', page.variant_key,
    'archivedAt', page.archived_at,
    'clonedFromExerciseId', page.cloned_from_exercise_id,
    'revision', page.revision,
    'createdAt', page.created_at,
    'updatedAt', page.updated_at,
    'equipmentKeys', coalesce((
      select jsonb_agg(equipment.equipment_key order by equipment.position)
      from public.exercise_definition_equipment as equipment
      where equipment.exercise_id = page.id
    ), '[]'::jsonb),
    'primaryMuscleIds', coalesce((
      select jsonb_agg(muscle.muscle_id order by muscle.position)
      from public.exercise_definition_muscles as muscle
      where muscle.exercise_id = page.id and muscle.role = 'primary'
    ), '[]'::jsonb),
    'secondaryMuscleIds', coalesce((
      select jsonb_agg(muscle.muscle_id order by muscle.position)
      from public.exercise_definition_muscles as muscle
      where muscle.exercise_id = page.id and muscle.role = 'secondary'
    ), '[]'::jsonb),
    'published', page.is_published,
    'draftId', page.draft_id,
    'draftRevision', page.draft_revision,
    'latestGuidanceRevisionId', (
      select revision.id
      from public.guidance_revisions as revision
      where revision.exercise_id = page.id
      order by revision.version_number desc
      limit 1
    ),
    'latestGuidanceVersion', (
      select revision.version_number
      from public.guidance_revisions as revision
      where revision.exercise_id = page.id
      order by revision.version_number desc
      limit 1
    )
  ) order by
    case when p_sort = 'name_asc' then page.normalized_name end asc,
    case when p_sort = 'name_desc' then page.normalized_name end desc,
    case when p_sort = 'updated_asc' then page.updated_at end asc,
    case when p_sort = 'updated_desc' then page.updated_at end desc,
    case when p_sort = 'publication_desc' then page.is_published end desc,
    case when p_sort = 'publication_desc' then page.updated_at end desc,
    page.id
  ), '[]'::jsonb)
  into v_items
  from page;

  return jsonb_build_object(
    'items', v_items,
    'total', v_total,
    'page', p_page,
    'pageSize', p_page_size
  );
end;
$$;

alter table public.muscles enable row level security;
alter table public.exercise_definitions enable row level security;
alter table public.exercise_definition_equipment enable row level security;
alter table public.exercise_definition_muscles enable row level security;
alter table public.guidance_drafts enable row level security;
alter table public.guidance_revisions enable row level security;
alter table public.guidance_revision_muscles enable row level security;
alter table private.guidance_mutation_operations enable row level security;

create policy muscles_select_authenticated
on public.muscles
for select
to authenticated
using (
  active
  and (select private.current_session_is_authorized(true, false))
);

create policy exercise_definitions_select_own
on public.exercise_definitions
for select
to authenticated
using (
  (select auth.uid()) = user_id
  and (select private.current_session_is_authorized(true, false))
);
create policy exercise_definitions_update_own
on public.exercise_definitions
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

create policy exercise_definition_equipment_select_own
on public.exercise_definition_equipment
for select
to authenticated
using (
  (select auth.uid()) = user_id
  and (select private.current_session_is_authorized(true, false))
);
create policy exercise_definition_muscles_select_own
on public.exercise_definition_muscles
for select
to authenticated
using (
  (select auth.uid()) = user_id
  and (select private.current_session_is_authorized(true, false))
);

create policy guidance_drafts_select_own
on public.guidance_drafts
for select
to authenticated
using (
  (select auth.uid()) = user_id
  and (select private.current_session_is_authorized(true, false))
);
create policy guidance_drafts_update_own
on public.guidance_drafts
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

create policy guidance_revisions_select_own
on public.guidance_revisions
for select
to authenticated
using (
  (select auth.uid()) = user_id
  and (select private.current_session_is_authorized(true, false))
);
create policy guidance_revision_muscles_select_own
on public.guidance_revision_muscles
for select
to authenticated
using (
  (select auth.uid()) = user_id
  and (select private.current_session_is_authorized(true, false))
);

grant select on table public.muscles to authenticated;
grant select on table public.exercise_definitions to authenticated;
grant select on table public.exercise_definition_equipment to authenticated;
grant select on table public.exercise_definition_muscles to authenticated;
grant select on table public.guidance_drafts to authenticated;
grant select on table public.guidance_revisions to authenticated;
grant select on table public.guidance_revision_muscles to authenticated;

revoke all on function public.create_exercise_v1(text, text, jsonb, jsonb, boolean, uuid)
  from public, anon, authenticated, service_role;
revoke all on function public.update_exercise_v1(uuid, text, text, jsonb, jsonb, bigint, boolean, uuid)
  from public, anon, authenticated, service_role;
revoke all on function public.set_exercise_archived_v1(uuid, boolean, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function public.save_guidance_draft_v1(uuid, jsonb, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function public.validate_guidance_draft_v1(uuid, uuid, bigint, bigint)
  from public, anon, authenticated, service_role;
revoke all on function public.publish_guidance_revision_v1(uuid, uuid, bigint, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function public.clone_exercise_v1(uuid, text, boolean, uuid)
  from public, anon, authenticated, service_role;
revoke all on function public.duplicate_guidance_revision_as_draft_v1(uuid, uuid, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function public.list_exercises_v1(text, text, text, text[], text[], text, integer, integer)
  from public, anon, authenticated, service_role;

revoke all on function private.normalize_exercise_name(text)
  from public, anon, authenticated, service_role;
revoke all on function private.normalize_guidance_string(text)
  from public, anon, authenticated, service_role;
revoke all on function private.sha256_text(text)
  from public, anon, authenticated, service_role;
revoke all on function private.sha256_jsonb(jsonb)
  from public, anon, authenticated, service_role;
revoke all on function private.require_product_actor()
  from public, anon, authenticated, service_role;
revoke all on function private.normalize_guidance_content(jsonb, boolean)
  from public, anon, authenticated, service_role;
revoke all on function private.validate_equipment_payload(jsonb)
  from public, anon, authenticated, service_role;
revoke all on function private.validate_muscle_payload(jsonb)
  from public, anon, authenticated, service_role;
revoke all on function private.exercise_identity_fingerprint(text, text, jsonb)
  from public, anon, authenticated, service_role;
revoke all on function private.load_mutation_result(uuid, text, uuid, text)
  from public, anon, authenticated, service_role;
revoke all on function private.store_mutation_result(uuid, text, uuid, text, jsonb)
  from public, anon, authenticated, service_role;
revoke all on function private.reject_immutable_change()
  from public, anon, authenticated, service_role;
revoke all on function private.assert_exercise_children_complete()
  from public, anon, authenticated, service_role;
revoke all on function private.replace_exercise_children(uuid, uuid, jsonb, jsonb)
  from public, anon, authenticated, service_role;
revoke all on function private.exercise_duplicate_exists(uuid, uuid, text, text, jsonb)
  from public, anon, authenticated, service_role;
revoke all on function private.create_exercise_v1(text, text, jsonb, jsonb, boolean, uuid)
  from public, anon, authenticated, service_role;
revoke all on function private.update_exercise_v1(uuid, text, text, jsonb, jsonb, bigint, boolean, uuid)
  from public, anon, authenticated, service_role;
revoke all on function private.set_exercise_archived_v1(uuid, boolean, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function private.save_guidance_draft_v1(uuid, jsonb, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function private.validate_guidance_draft_v1(uuid, uuid, bigint, bigint)
  from public, anon, authenticated, service_role;
revoke all on function private.publish_guidance_revision_v1(uuid, uuid, bigint, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function private.clone_exercise_v1(uuid, text, boolean, uuid)
  from public, anon, authenticated, service_role;
revoke all on function private.duplicate_guidance_revision_as_draft_v1(uuid, uuid, bigint, uuid)
  from public, anon, authenticated, service_role;

grant execute on function private.create_exercise_v1(text, text, jsonb, jsonb, boolean, uuid)
  to authenticated;
grant execute on function private.update_exercise_v1(uuid, text, text, jsonb, jsonb, bigint, boolean, uuid)
  to authenticated;
grant execute on function private.set_exercise_archived_v1(uuid, boolean, bigint, uuid)
  to authenticated;
grant execute on function private.save_guidance_draft_v1(uuid, jsonb, bigint, uuid)
  to authenticated;
grant execute on function private.validate_guidance_draft_v1(uuid, uuid, bigint, bigint)
  to authenticated;
grant execute on function private.publish_guidance_revision_v1(uuid, uuid, bigint, bigint, uuid)
  to authenticated;
grant execute on function private.clone_exercise_v1(uuid, text, boolean, uuid)
  to authenticated;
grant execute on function private.duplicate_guidance_revision_as_draft_v1(uuid, uuid, bigint, uuid)
  to authenticated;

grant execute on function public.create_exercise_v1(text, text, jsonb, jsonb, boolean, uuid)
  to authenticated;
grant execute on function public.update_exercise_v1(uuid, text, text, jsonb, jsonb, bigint, boolean, uuid)
  to authenticated;
grant execute on function public.set_exercise_archived_v1(uuid, boolean, bigint, uuid)
  to authenticated;
grant execute on function public.save_guidance_draft_v1(uuid, jsonb, bigint, uuid)
  to authenticated;
grant execute on function public.validate_guidance_draft_v1(uuid, uuid, bigint, bigint)
  to authenticated;
grant execute on function public.publish_guidance_revision_v1(uuid, uuid, bigint, bigint, uuid)
  to authenticated;
grant execute on function public.clone_exercise_v1(uuid, text, boolean, uuid)
  to authenticated;
grant execute on function public.duplicate_guidance_revision_as_draft_v1(uuid, uuid, bigint, uuid)
  to authenticated;
grant execute on function public.list_exercises_v1(text, text, text, text[], text[], text, integer, integer)
  to authenticated;

comment on column public.guidance_revisions.content_hash is
  'SHA-256 of canonical JSON array stone-set-guidance-content-v1; ordered equipment, muscles and guidance arrays are semantically significant.';
comment on column public.guidance_revisions.revision_hash is
  'SHA-256 of canonical JSON array stone-set-guidance-revision-v1: exercise ID, owner ID, version number, content hash and supersession ID.';
comment on table private.guidance_mutation_operations is
  'Private durable idempotency replay evidence. Stores request fingerprints and safe result envelopes, never complete guidance content.';

commit;
