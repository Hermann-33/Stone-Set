begin;

create table public.routine_drafts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  name text not null,
  description text not null default '',
  status text not null default 'draft' check (status in ('draft', 'submitted', 'approved', 'published', 'archived')),
  base_routine_version_id uuid,
  revision bigint not null default 1 check (revision > 0),
  created_at timestamptz not null default clock_timestamp(),
  updated_at timestamptz not null default clock_timestamp(),
  unique (id, user_id),
  constraint routine_drafts_name_format check (
    char_length(name) between 1 and 120 and name = btrim(name) and name !~ '[[:cntrl:]]'
  ),
  constraint routine_drafts_description_format check (char_length(description) <= 2000)
);

create index routine_drafts_owner_updated_idx
  on public.routine_drafts (user_id, updated_at desc, id);

create table public.routine_draft_days (
  id uuid primary key default gen_random_uuid(),
  routine_draft_id uuid not null references public.routine_drafts (id) on delete cascade,
  user_id uuid not null,
  day_index integer not null check (day_index between 1 and 7),
  day_type text not null check (day_type in ('workout', 'rest')),
  title text not null default '',
  purpose text not null default '',
  position integer not null check (position between 1 and 7),
  unique (routine_draft_id, day_index),
  unique (routine_draft_id, position),
  unique (id, routine_draft_id, user_id),
  foreign key (routine_draft_id, user_id)
    references public.routine_drafts (id, user_id) on delete cascade,
  constraint routine_draft_days_title_format check (
    char_length(title) <= 120 and title = btrim(title) and title !~ '[[:cntrl:]]'
  ),
  constraint routine_draft_days_purpose_format check (char_length(purpose) <= 500)
);

create index routine_draft_days_owner_draft_idx
  on public.routine_draft_days (user_id, routine_draft_id, position);

create table public.routine_draft_prescriptions (
  id uuid primary key default gen_random_uuid(),
  routine_draft_id uuid not null,
  routine_draft_day_id uuid not null,
  user_id uuid not null,
  position integer not null check (position between 1 and 20),
  exercise_definition_id uuid not null,
  guidance_revision_id uuid not null,
  priority boolean not null default false,
  working_sets integer not null check (working_sets between 0 and 100),
  rep_min integer not null check (rep_min between 0 and 100),
  rep_max integer not null check (rep_max between 0 and 100),
  rir_target integer not null check (rir_target between 0 and 20),
  rest_seconds integer not null check (rest_seconds between 0 and 3600),
  load_unit text not null check (load_unit in ('kg', 'lb', 'bodyweight', 'none')),
  notes text not null default '',
  unique (routine_draft_day_id, position),
  foreign key (routine_draft_day_id, routine_draft_id, user_id)
    references public.routine_draft_days (id, routine_draft_id, user_id) on delete cascade,
  foreign key (exercise_definition_id, user_id)
    references public.exercise_definitions (id, user_id) on delete restrict,
  foreign key (guidance_revision_id, exercise_definition_id, user_id)
    references public.guidance_revisions (id, exercise_id, user_id) on delete restrict,
  constraint routine_draft_prescriptions_notes_format check (char_length(notes) <= 1000)
);

create index routine_draft_prescriptions_owner_draft_idx
  on public.routine_draft_prescriptions (user_id, routine_draft_id, routine_draft_day_id, position);
create index routine_draft_prescriptions_exercise_idx
  on public.routine_draft_prescriptions (exercise_definition_id);
create index routine_draft_prescriptions_guidance_idx
  on public.routine_draft_prescriptions (guidance_revision_id);

create table public.routine_submissions (
  id uuid primary key default gen_random_uuid(),
  author_user_id uuid not null references public.profiles (id) on delete restrict,
  routine_draft_id uuid not null,
  routine_draft_revision bigint not null check (routine_draft_revision > 0),
  snapshot jsonb not null check (jsonb_typeof(snapshot) = 'object'),
  content_hash text not null check (content_hash ~ '^[0-9a-f]{64}$'),
  validation_result jsonb not null check (jsonb_typeof(validation_result) = 'object'),
  validation_status text not null check (validation_status in ('valid', 'invalid')),
  status text not null default 'submitted' check (status in ('submitted', 'approved', 'rejected', 'published')),
  submitted_at timestamptz not null default clock_timestamp(),
  decided_at timestamptz,
  unique (routine_draft_id, routine_draft_revision),
  unique (id, author_user_id),
  foreign key (routine_draft_id, author_user_id)
    references public.routine_drafts (id, user_id) on delete restrict
);

create index routine_submissions_author_status_idx
  on public.routine_submissions (author_user_id, status, submitted_at desc, id);
create index routine_submissions_queue_idx
  on public.routine_submissions (submitted_at, id) where status = 'submitted';

create table public.routine_reviews (
  id uuid primary key default gen_random_uuid(),
  submission_id uuid not null unique references public.routine_submissions (id) on delete restrict,
  author_user_id uuid not null,
  reviewer_user_id uuid not null references public.profiles (id) on delete restrict,
  decision text not null check (decision in ('approved', 'rejected')),
  reason text,
  reviewer_note text,
  content_hash text not null check (content_hash ~ '^[0-9a-f]{64}$'),
  reviewed_at timestamptz not null default clock_timestamp(),
  foreign key (submission_id, author_user_id)
    references public.routine_submissions (id, author_user_id) on delete restrict,
  constraint routine_reviews_not_self check (reviewer_user_id <> author_user_id),
  constraint routine_reviews_rejection_reason check (
    decision <> 'rejected' or (reason is not null and char_length(btrim(reason)) between 1 and 1000)
  ),
  constraint routine_reviews_note_format check (
    reviewer_note is null or char_length(reviewer_note) <= 2000
  )
);

create index routine_reviews_author_idx
  on public.routine_reviews (author_user_id, reviewed_at desc, id);
create index routine_reviews_reviewer_idx
  on public.routine_reviews (reviewer_user_id, reviewed_at desc, id);

create table public.routine_versions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete restrict,
  source_routine_draft_id uuid not null,
  approved_submission_id uuid not null unique references public.routine_submissions (id) on delete restrict,
  approved_review_id uuid not null unique references public.routine_reviews (id) on delete restrict,
  version_number bigint not null check (version_number > 0),
  name text not null,
  description text not null default '',
  content_hash text not null check (content_hash ~ '^[0-9a-f]{64}$'),
  effective_date date not null,
  published_at timestamptz not null default clock_timestamp(),
  unique (source_routine_draft_id, version_number),
  unique (id, user_id),
  foreign key (source_routine_draft_id, user_id)
    references public.routine_drafts (id, user_id) on delete restrict
);

create index routine_versions_owner_history_idx
  on public.routine_versions (user_id, version_number desc, id);
create index routine_versions_draft_idx
  on public.routine_versions (source_routine_draft_id, version_number desc);

alter table public.routine_drafts
  add constraint routine_drafts_base_version_fkey
  foreign key (base_routine_version_id, user_id)
  references public.routine_versions (id, user_id) on delete restrict;
create index routine_drafts_base_version_idx
  on public.routine_drafts (base_routine_version_id)
  where base_routine_version_id is not null;

create table public.routine_version_days (
  id uuid primary key default gen_random_uuid(),
  routine_version_id uuid not null,
  user_id uuid not null,
  day_index integer not null check (day_index between 1 and 7),
  day_type text not null check (day_type in ('workout', 'rest')),
  title text not null default '',
  purpose text not null default '',
  position integer not null check (position between 1 and 7),
  unique (routine_version_id, day_index),
  unique (routine_version_id, position),
  unique (id, routine_version_id, user_id),
  foreign key (routine_version_id, user_id)
    references public.routine_versions (id, user_id) on delete restrict
);

create index routine_version_days_owner_idx
  on public.routine_version_days (user_id, routine_version_id, position);

create table public.routine_version_prescriptions (
  id uuid primary key default gen_random_uuid(),
  routine_version_id uuid not null,
  routine_version_day_id uuid not null,
  user_id uuid not null,
  position integer not null,
  exercise_definition_id uuid not null,
  guidance_revision_id uuid not null,
  priority boolean not null,
  working_sets integer not null,
  rep_min integer not null,
  rep_max integer not null,
  rir_target integer not null,
  rest_seconds integer not null,
  load_unit text not null,
  notes text not null default '',
  unique (routine_version_day_id, position),
  foreign key (routine_version_day_id, routine_version_id, user_id)
    references public.routine_version_days (id, routine_version_id, user_id) on delete restrict,
  foreign key (exercise_definition_id, user_id)
    references public.exercise_definitions (id, user_id) on delete restrict,
  foreign key (guidance_revision_id, exercise_definition_id, user_id)
    references public.guidance_revisions (id, exercise_id, user_id) on delete restrict
);

create index routine_version_prescriptions_owner_idx
  on public.routine_version_prescriptions (user_id, routine_version_id, routine_version_day_id, position);
create index routine_version_prescriptions_exercise_idx
  on public.routine_version_prescriptions (exercise_definition_id);
create index routine_version_prescriptions_guidance_idx
  on public.routine_version_prescriptions (guidance_revision_id);

create table private.routine_mutation_operations (
  user_id uuid not null references public.profiles (id) on delete cascade,
  operation_name text not null,
  idempotency_key uuid not null,
  request_fingerprint text not null check (request_fingerprint ~ '^[0-9a-f]{64}$'),
  correlation_id uuid not null default gen_random_uuid(),
  result jsonb not null check (jsonb_typeof(result) = 'object'),
  created_at timestamptz not null default clock_timestamp(),
  primary key (user_id, operation_name, idempotency_key)
);

create index routine_mutation_operations_created_idx
  on private.routine_mutation_operations (created_at);

revoke all on table public.routine_drafts from public, anon, authenticated, service_role;
revoke all on table public.routine_draft_days from public, anon, authenticated, service_role;
revoke all on table public.routine_draft_prescriptions from public, anon, authenticated, service_role;
revoke all on table public.routine_submissions from public, anon, authenticated, service_role;
revoke all on table public.routine_reviews from public, anon, authenticated, service_role;
revoke all on table public.routine_versions from public, anon, authenticated, service_role;
revoke all on table public.routine_version_days from public, anon, authenticated, service_role;
revoke all on table public.routine_version_prescriptions from public, anon, authenticated, service_role;
revoke all on table private.routine_mutation_operations from public, anon, authenticated, service_role;

create or replace function private.require_routine_actor()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select private.require_product_actor();
$$;

create or replace function private.require_routine_reviewer()
returns uuid
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
begin
  if not exists (
    select 1 from public.account_capabilities
    where user_id = v_user_id
      and capability_code = 'routine_reviewer'
      and is_enabled
  ) then
    raise exception using errcode = '42501', message = 'routine_reviewer_not_authorized';
  end if;
  return v_user_id;
end;
$$;

create or replace function private.load_routine_mutation_result(
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
  v_record private.routine_mutation_operations%rowtype;
begin
  if p_idempotency_key is null then
    raise exception using errcode = '22023', message = 'idempotency_key_required';
  end if;
  perform pg_advisory_xact_lock(hashtextextended(p_user_id::text || ':' || p_operation_name || ':' || p_idempotency_key::text, 0));
  select * into v_record
  from private.routine_mutation_operations
  where user_id = p_user_id and operation_name = p_operation_name and idempotency_key = p_idempotency_key;
  if found then
    if v_record.request_fingerprint <> p_request_fingerprint then
      raise exception using errcode = '22023', message = 'idempotency_key_reused';
    end if;
    return v_record.result || jsonb_build_object('replayed', true);
  end if;
  return null;
end;
$$;

create or replace function private.store_routine_mutation_result(
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
  v_result jsonb := p_result || jsonb_build_object('correlationId', v_correlation_id, 'replayed', false);
begin
  insert into private.routine_mutation_operations (
    user_id, operation_name, idempotency_key, request_fingerprint, correlation_id, result
  ) values (
    p_user_id, p_operation_name, p_idempotency_key, p_request_fingerprint, v_correlation_id, v_result
  );
  return v_result;
end;
$$;

create or replace function private.routine_draft_json(p_routine_draft_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id', draft.id,
    'ownerId', draft.user_id,
    'name', draft.name,
    'description', draft.description,
    'status', draft.status,
    'revision', draft.revision,
    'baseVersionId', draft.base_routine_version_id,
    'latestSubmissionId', (
      select submission.id
      from public.routine_submissions submission
      where submission.routine_draft_id = draft.id
      order by submission.submitted_at desc, submission.id desc
      limit 1
    ),
    'createdAt', draft.created_at,
    'updatedAt', draft.updated_at,
    'days', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', day.id,
        'dayIndex', day.day_index,
        'kind', day.day_type,
        'title', day.title,
        'purpose', day.purpose,
        'position', day.position,
        'prescriptions', coalesce((
          select jsonb_agg(jsonb_build_object(
            'id', prescription.id,
            'position', prescription.position,
            'exerciseId', prescription.exercise_definition_id,
            'guidanceRevisionId', prescription.guidance_revision_id,
            'priority', prescription.priority,
            'sets', prescription.working_sets,
            'minReps', prescription.rep_min,
            'maxReps', prescription.rep_max,
            'rir', prescription.rir_target,
            'restSeconds', prescription.rest_seconds,
            'loadUnit', prescription.load_unit,
            'notes', prescription.notes
          ) order by prescription.position)
          from public.routine_draft_prescriptions as prescription
          where prescription.routine_draft_day_id = day.id
        ), '[]'::jsonb)
      ) order by day.position)
      from public.routine_draft_days as day
      where day.routine_draft_id = draft.id
    ), '[]'::jsonb)
  )
  from public.routine_drafts as draft
  where draft.id = p_routine_draft_id;
$$;

create or replace function private.routine_version_json(p_routine_version_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id', version.id,
    'ownerId', version.user_id,
    'routineDraftId', version.source_routine_draft_id,
    'approvedSubmissionId', version.approved_submission_id,
    'approvedReviewId', version.approved_review_id,
    'versionNumber', version.version_number,
    'name', version.name,
    'description', version.description,
    'contentHash', version.content_hash,
    'effectiveDate', version.effective_date,
    'publishedAt', version.published_at,
    'days', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', day.id,
        'dayIndex', day.day_index,
        'kind', day.day_type,
        'title', day.title,
        'purpose', day.purpose,
        'position', day.position,
        'prescriptions', coalesce((
          select jsonb_agg(jsonb_build_object(
            'id', prescription.id,
            'position', prescription.position,
            'exerciseId', prescription.exercise_definition_id,
            'guidanceRevisionId', prescription.guidance_revision_id,
            'priority', prescription.priority,
            'sets', prescription.working_sets,
            'minReps', prescription.rep_min,
            'maxReps', prescription.rep_max,
            'rir', prescription.rir_target,
            'restSeconds', prescription.rest_seconds,
            'loadUnit', prescription.load_unit,
            'notes', prescription.notes
          ) order by prescription.position)
          from public.routine_version_prescriptions as prescription
          where prescription.routine_version_day_id = day.id
        ), '[]'::jsonb)
      ) order by day.position)
      from public.routine_version_days as day
      where day.routine_version_id = version.id
    ), '[]'::jsonb)
  )
  from public.routine_versions as version
  where version.id = p_routine_version_id;
$$;

create or replace function private.validate_routine_draft(p_routine_draft_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_errors jsonb;
  v_day_count integer;
  v_workout_count integer;
  v_rest_count integer;
begin
  select count(*),
         count(*) filter (where day_type = 'workout'),
         count(*) filter (where day_type = 'rest')
  into v_day_count, v_workout_count, v_rest_count
  from public.routine_draft_days
  where routine_draft_id = p_routine_draft_id;

  with errors as (
    select 10 as sort_key, null::integer as day_index, null::integer as prescription_position,
      'day_count'::text as code, 'Routine must contain exactly seven days.'::text as message,
      p_routine_draft_id::text as entity_id, 'days'::text as field
    where v_day_count <> 7
    union all
    select 20, null, null, 'workout_day_count', 'Routine must contain four to six workout days.',
      p_routine_draft_id::text, 'days'
    where v_workout_count not between 4 and 6
    union all
    select 30, null, null, 'rest_day_count', 'Routine must contain one to three rest days.',
      p_routine_draft_id::text, 'days'
    where v_rest_count not between 1 and 3
    union all
    select 100 + day.day_index, day.day_index, null, 'rest_day_has_prescriptions',
      'Rest days cannot contain exercise prescriptions.', day.id::text, 'prescriptions'
    from public.routine_draft_days day
    where day.routine_draft_id = p_routine_draft_id
      and day.day_type = 'rest'
      and exists (select 1 from public.routine_draft_prescriptions p where p.routine_draft_day_id = day.id)
    union all
    select 200 + day.day_index, day.day_index, null, 'prescription_count',
      'Workout days must contain three to ten prescriptions.', day.id::text, 'prescriptions'
    from public.routine_draft_days day
    where day.routine_draft_id = p_routine_draft_id and day.day_type = 'workout'
      and (select count(*) from public.routine_draft_prescriptions p where p.routine_draft_day_id = day.id) not between 3 and 10
    union all
    select 300 + day.day_index, day.day_index, null, 'working_set_count',
      'Workout days must contain eight to twenty working sets.', day.id::text, 'workingSets'
    from public.routine_draft_days day
    where day.routine_draft_id = p_routine_draft_id and day.day_type = 'workout'
      and coalesce((select sum(p.working_sets) from public.routine_draft_prescriptions p where p.routine_draft_day_id = day.id), 0) not between 8 and 20
    union all
    select 400 + day.day_index, day.day_index, null, 'priority_required',
      'Workout days require at least one priority prescription.', day.id::text, 'priority'
    from public.routine_draft_days day
    where day.routine_draft_id = p_routine_draft_id and day.day_type = 'workout'
      and not exists (select 1 from public.routine_draft_prescriptions p where p.routine_draft_day_id = day.id and p.priority)
    union all
    select 500 + day.day_index * 20 + p.position, day.day_index, p.position, 'working_sets_range',
      'Working sets must be between one and six.', p.id::text, 'workingSets'
    from public.routine_draft_prescriptions p
    join public.routine_draft_days day on day.id = p.routine_draft_day_id
    where p.routine_draft_id = p_routine_draft_id and p.working_sets not between 1 and 6
    union all
    select 600 + day.day_index * 20 + p.position, day.day_index, p.position, 'rep_range',
      'Rep range must be between five and thirty with max at least min.', p.id::text, 'repRange'
    from public.routine_draft_prescriptions p
    join public.routine_draft_days day on day.id = p.routine_draft_day_id
    where p.routine_draft_id = p_routine_draft_id
      and (p.rep_min not between 5 and 30 or p.rep_max not between 5 and 30 or p.rep_max < p.rep_min)
    union all
    select 700 + day.day_index * 20 + p.position, day.day_index, p.position, 'rir_range',
      'RIR target must be between zero and five.', p.id::text, 'rirTarget'
    from public.routine_draft_prescriptions p
    join public.routine_draft_days day on day.id = p.routine_draft_day_id
    where p.routine_draft_id = p_routine_draft_id and p.rir_target not between 0 and 5
    union all
    select 800 + day.day_index * 20 + p.position, day.day_index, p.position, 'rest_range',
      'Rest must be between thirty and three hundred seconds.', p.id::text, 'restSeconds'
    from public.routine_draft_prescriptions p
    join public.routine_draft_days day on day.id = p.routine_draft_day_id
    where p.routine_draft_id = p_routine_draft_id and p.rest_seconds not between 30 and 300
  )
  select coalesce(jsonb_agg(jsonb_strip_nulls(jsonb_build_object(
    'code', code, 'message', message, 'entityId', entity_id,
    'dayIndex', day_index, 'prescriptionPosition', prescription_position, 'field', field
  )) order by sort_key), '[]'::jsonb)
  into v_errors
  from errors;

  return jsonb_build_object(
    'validatorVersion', 'routine-validator-v1',
    'valid', jsonb_array_length(v_errors) = 0,
    'errors', v_errors,
    'issues', (
      select coalesce(jsonb_agg(jsonb_build_object(
        'code', item ->> 'code',
        'path', concat_ws('.',
          case when item ? 'dayIndex' then 'days[' || (item ->> 'dayIndex') || ']' end,
          case when item ? 'prescriptionPosition' then 'prescriptions[' || (item ->> 'prescriptionPosition') || ']' end,
          item ->> 'field'
        )
      )), '[]'::jsonb)
      from jsonb_array_elements(v_errors) item
    ),
    'summary', jsonb_build_object(
      'dayCount', v_day_count,
      'workoutDayCount', v_workout_count,
      'restDayCount', v_rest_count,
      'weeklyWorkingSets', coalesce((select sum(working_sets) from public.routine_draft_prescriptions where routine_draft_id = p_routine_draft_id), 0)
    )
  );
end;
$$;

create or replace function private.reject_immutable_routine_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception using errcode = '42501', message = 'immutable_routine_version';
end;
$$;

create trigger routine_versions_immutable
before update or delete on public.routine_versions
for each row execute function private.reject_immutable_routine_change();
create trigger routine_version_days_immutable
before update or delete on public.routine_version_days
for each row execute function private.reject_immutable_routine_change();
create trigger routine_version_prescriptions_immutable
before update or delete on public.routine_version_prescriptions
for each row execute function private.reject_immutable_routine_change();
create trigger routine_submissions_immutable_content
before update of snapshot, content_hash, validation_result, validation_status, routine_draft_id,
  routine_draft_revision, author_user_id, submitted_at on public.routine_submissions
for each row execute function private.reject_immutable_routine_change();
create trigger routine_reviews_immutable
before update or delete on public.routine_reviews
for each row execute function private.reject_immutable_routine_change();

create or replace function private.create_routine_draft_v1(
  p_name text,
  p_description text,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_routine_actor();
  v_name text := btrim(regexp_replace(coalesce(p_name, ''), '[[:space:]]+', ' ', 'g'));
  v_description text := coalesce(p_description, '');
  v_fingerprint text;
  v_replay jsonb;
  v_draft_id uuid;
begin
  if char_length(v_name) not between 1 and 120
     or char_length(v_description) > 2000
     or v_name ~ '[[:cntrl:]]' then
    raise exception using errcode = '22023', message = 'invalid_routine_draft';
  end if;
  v_fingerprint := private.sha256_jsonb(jsonb_build_array('create_routine_draft_v1', v_name, v_description));
  v_replay := private.load_routine_mutation_result(v_user_id, 'create_routine_draft_v1', p_idempotency_key, v_fingerprint);
  if v_replay is not null then return v_replay; end if;

  insert into public.routine_drafts (user_id, name, description)
  values (v_user_id, v_name, v_description)
  returning id into v_draft_id;

  insert into public.routine_draft_days (
    routine_draft_id, user_id, day_index, day_type, title, purpose, position
  )
  select v_draft_id, v_user_id, day_index, 'rest', '', '', day_index
  from generate_series(1, 7) as day_index;

  return private.store_routine_mutation_result(
    v_user_id, 'create_routine_draft_v1', p_idempotency_key, v_fingerprint,
    jsonb_build_object('operation', 'create', 'routineDraftId', v_draft_id, 'routineDraftRevision', 1)
  );
end;
$$;

create or replace function private.save_routine_draft_v1(
  p_routine_draft_id uuid,
  p_name text,
  p_description text,
  p_days jsonb,
  p_expected_revision bigint,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_routine_actor();
  v_name text := btrim(regexp_replace(coalesce(p_name, ''), '[[:space:]]+', ' ', 'g'));
  v_description text := coalesce(p_description, '');
  v_fingerprint text;
  v_replay jsonb;
  v_current_revision bigint;
  v_new_revision bigint;
  v_day jsonb;
  v_prescription jsonb;
  v_day_id uuid;
  v_exercise_id uuid;
  v_guidance_id uuid;
begin
  if p_routine_draft_id is null or p_expected_revision is null or p_days is null
     or jsonb_typeof(p_days) <> 'array'
     or jsonb_array_length(p_days) > 7
     or char_length(v_name) not between 1 and 120
     or char_length(v_description) > 2000 then
    raise exception using errcode = '22023', message = 'invalid_routine_draft_save';
  end if;
  v_fingerprint := private.sha256_jsonb(jsonb_build_array(
    'save_routine_draft_v1', p_routine_draft_id, v_name, v_description, p_days, p_expected_revision
  ));
  v_replay := private.load_routine_mutation_result(v_user_id, 'save_routine_draft_v1', p_idempotency_key, v_fingerprint);
  if v_replay is not null then return v_replay; end if;

  select revision into v_current_revision
  from public.routine_drafts
  where id = p_routine_draft_id and user_id = v_user_id and status = 'draft'
  for update;
  if not found then
    raise exception using errcode = 'P0002', message = 'routine_draft_not_found';
  end if;
  if v_current_revision <> p_expected_revision then
    raise exception using errcode = '40001', message = 'routine_draft_revision_conflict',
      detail = jsonb_build_object('currentRevision', v_current_revision, 'correlationId', gen_random_uuid())::text;
  end if;

  if exists (
    select 1
    from jsonb_array_elements(p_days) as item
    where jsonb_typeof(item) <> 'object'
      or not (item ?& array['dayIndex', 'kind', 'prescriptions'])
      or jsonb_typeof(item -> 'prescriptions') <> 'array'
      or jsonb_array_length(item -> 'prescriptions') > 20
  ) or (
    select count(distinct (item ->> 'dayIndex')::integer)
    from jsonb_array_elements(p_days) item
  ) <> jsonb_array_length(p_days) then
    raise exception using errcode = '22023', message = 'invalid_routine_days';
  end if;

  delete from public.routine_draft_days where routine_draft_id = p_routine_draft_id;

  for v_day in select value from jsonb_array_elements(p_days)
  loop
    begin
      v_day_id := coalesce((v_day ->> 'id')::uuid, gen_random_uuid());
      insert into public.routine_draft_days (
        id, routine_draft_id, user_id, day_index, day_type, title, purpose, position
      ) values (
        v_day_id, p_routine_draft_id, v_user_id,
        (v_day ->> 'dayIndex')::integer, v_day ->> 'kind',
        btrim(coalesce(v_day ->> 'title', '')), coalesce(v_day ->> 'purpose', ''),
        (v_day ->> 'dayIndex')::integer
      );
    exception when others then
      raise exception using errcode = '22023', message = 'invalid_routine_day';
    end;

    for v_prescription in select value from jsonb_array_elements(v_day -> 'prescriptions')
    loop
      begin
        v_exercise_id := (v_prescription ->> 'exerciseId')::uuid;
        v_guidance_id := (v_prescription ->> 'guidanceRevisionId')::uuid;
      exception when others then
        raise exception using errcode = '22023', message = 'invalid_routine_prescription';
      end;
      if not exists (
        select 1
        from public.exercise_definitions exercise
        join public.guidance_revisions guidance
          on guidance.exercise_id = exercise.id and guidance.user_id = exercise.user_id
        where exercise.id = v_exercise_id
          and exercise.user_id = v_user_id
          and exercise.archived_at is null
          and guidance.id = v_guidance_id
      ) then
        raise exception using errcode = '22023', message = 'routine_prescription_source_unavailable';
      end if;
      begin
        insert into public.routine_draft_prescriptions (
          id, routine_draft_id, routine_draft_day_id, user_id, position,
          exercise_definition_id, guidance_revision_id, priority, working_sets,
          rep_min, rep_max, rir_target, rest_seconds, load_unit, notes
        ) values (
          coalesce((v_prescription ->> 'id')::uuid, gen_random_uuid()),
          p_routine_draft_id, v_day_id, v_user_id,
          (v_prescription ->> 'position')::integer, v_exercise_id, v_guidance_id,
          coalesce((v_prescription ->> 'priority')::boolean, false),
          (v_prescription ->> 'sets')::integer,
          (v_prescription ->> 'minReps')::integer,
          (v_prescription ->> 'maxReps')::integer,
          (v_prescription ->> 'rir')::integer,
          (v_prescription ->> 'restSeconds')::integer,
          coalesce(v_prescription ->> 'loadUnit', 'kg'),
          coalesce(v_prescription ->> 'notes', '')
        );
      exception when others then
        raise exception using errcode = '22023', message = 'invalid_routine_prescription';
      end;
    end loop;
  end loop;

  update public.routine_drafts
  set name = v_name, description = v_description, revision = revision + 1,
      updated_at = clock_timestamp()
  where id = p_routine_draft_id
  returning revision into v_new_revision;

  return private.store_routine_mutation_result(
    v_user_id, 'save_routine_draft_v1', p_idempotency_key, v_fingerprint,
    jsonb_build_object('operation', 'save', 'routineDraftId', p_routine_draft_id, 'routineDraftRevision', v_new_revision)
  );
end;
$$;

create or replace function private.archive_routine_draft_v1(
  p_routine_draft_id uuid,
  p_expected_revision bigint,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_routine_actor();
  v_fingerprint text := private.sha256_jsonb(jsonb_build_array('archive_routine_draft_v1', p_routine_draft_id, p_expected_revision));
  v_replay jsonb;
  v_revision bigint;
begin
  v_replay := private.load_routine_mutation_result(v_user_id, 'archive_routine_draft_v1', p_idempotency_key, v_fingerprint);
  if v_replay is not null then return v_replay; end if;
  update public.routine_drafts
  set status = 'archived', revision = revision + 1, updated_at = clock_timestamp()
  where id = p_routine_draft_id and user_id = v_user_id and status = 'draft' and revision = p_expected_revision
  returning revision into v_revision;
  if not found then raise exception using errcode = '40001', message = 'routine_draft_revision_conflict'; end if;
  return private.store_routine_mutation_result(
    v_user_id, 'archive_routine_draft_v1', p_idempotency_key, v_fingerprint,
    jsonb_build_object('operation', 'archive', 'routineDraftId', p_routine_draft_id, 'routineDraftRevision', v_revision)
  );
end;
$$;

create or replace function private.validate_routine_draft_v1(
  p_routine_draft_id uuid,
  p_expected_revision bigint
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_routine_actor();
  v_revision bigint;
  v_result jsonb;
begin
  select revision into v_revision from public.routine_drafts
  where id = p_routine_draft_id and user_id = v_user_id and status <> 'archived';
  if not found then raise exception using errcode = 'P0002', message = 'routine_draft_not_found'; end if;
  if p_expected_revision is null or v_revision <> p_expected_revision then
    raise exception using errcode = '40001', message = 'routine_draft_revision_conflict',
      detail = jsonb_build_object('currentRevision', v_revision, 'correlationId', gen_random_uuid())::text;
  end if;
  v_result := private.validate_routine_draft(p_routine_draft_id);
  return v_result || jsonb_build_object('routineDraftId', p_routine_draft_id, 'routineDraftRevision', v_revision);
end;
$$;

create or replace function private.submit_routine_v1(
  p_routine_draft_id uuid,
  p_expected_revision bigint,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_routine_actor();
  v_fingerprint text := private.sha256_jsonb(jsonb_build_array('submit_routine_v1', p_routine_draft_id, p_expected_revision));
  v_replay jsonb;
  v_snapshot jsonb;
  v_validation jsonb;
  v_submission_id uuid;
  v_hash text;
begin
  v_replay := private.load_routine_mutation_result(v_user_id, 'submit_routine_v1', p_idempotency_key, v_fingerprint);
  if v_replay is not null then return v_replay; end if;
  perform 1 from public.routine_drafts
  where id = p_routine_draft_id and user_id = v_user_id and status = 'draft' and revision = p_expected_revision
  for update;
  if not found then raise exception using errcode = '40001', message = 'routine_draft_revision_conflict'; end if;
  v_validation := private.validate_routine_draft(p_routine_draft_id);
  if not (v_validation ->> 'valid')::boolean then
    raise exception using errcode = '22023', message = 'routine_validation_failed', detail = v_validation::text;
  end if;
  v_snapshot := private.routine_draft_json(p_routine_draft_id) - array['status', 'createdAt', 'updatedAt'];
  v_hash := private.sha256_jsonb(v_snapshot);
  insert into public.routine_submissions (
    author_user_id, routine_draft_id, routine_draft_revision, snapshot, content_hash,
    validation_result, validation_status
  ) values (
    v_user_id, p_routine_draft_id, p_expected_revision, v_snapshot, v_hash, v_validation, 'valid'
  ) returning id into v_submission_id;
  update public.routine_drafts set status = 'submitted', updated_at = clock_timestamp()
  where id = p_routine_draft_id;
  return private.store_routine_mutation_result(
    v_user_id, 'submit_routine_v1', p_idempotency_key, v_fingerprint,
    jsonb_build_object(
      'operation', 'submit', 'routineDraftId', p_routine_draft_id,
      'routineDraftRevision', p_expected_revision, 'submissionId', v_submission_id,
      'contentHash', v_hash, 'status', 'submitted'
    )
  );
end;
$$;

create or replace function private.decide_routine_submission_v1(
  p_submission_id uuid,
  p_decision text,
  p_reason text,
  p_reviewer_note text,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_reviewer_id uuid := private.require_routine_reviewer();
  v_submission public.routine_submissions%rowtype;
  v_fingerprint text := private.sha256_jsonb(jsonb_build_array(
    'decide_routine_submission_v1', p_submission_id, p_decision, p_reason, p_reviewer_note
  ));
  v_replay jsonb;
  v_review_id uuid;
begin
  if p_decision not in ('approved', 'rejected')
     or (p_decision = 'rejected' and char_length(btrim(coalesce(p_reason, ''))) not between 1 and 1000)
     or char_length(coalesce(p_reviewer_note, '')) > 2000 then
    raise exception using errcode = '22023', message = 'invalid_routine_review';
  end if;
  v_replay := private.load_routine_mutation_result(
    v_reviewer_id, p_decision || '_routine_submission_v1', p_idempotency_key, v_fingerprint
  );
  if v_replay is not null then return v_replay; end if;

  select * into v_submission from public.routine_submissions
  where id = p_submission_id
  for update;
  if not found or v_submission.status <> 'submitted' then
    raise exception using errcode = 'P0002', message = 'routine_submission_not_reviewable';
  end if;
  if v_submission.author_user_id = v_reviewer_id then
    raise exception using errcode = '42501', message = 'routine_self_review_denied';
  end if;
  if v_submission.validation_status <> 'valid'
     or not (v_submission.validation_result ->> 'valid')::boolean
     or private.sha256_jsonb(v_submission.snapshot) <> v_submission.content_hash then
    raise exception using errcode = '22023', message = 'routine_submission_evidence_invalid';
  end if;

  insert into public.routine_reviews (
    submission_id, author_user_id, reviewer_user_id, decision, reason, reviewer_note, content_hash
  ) values (
    p_submission_id, v_submission.author_user_id, v_reviewer_id, p_decision,
    nullif(btrim(coalesce(p_reason, '')), ''), nullif(btrim(coalesce(p_reviewer_note, '')), ''),
    v_submission.content_hash
  ) returning id into v_review_id;

  update public.routine_submissions
  set status = p_decision, decided_at = clock_timestamp()
  where id = p_submission_id;
  update public.routine_drafts
  set status = case when p_decision = 'approved' then 'approved' else 'draft' end,
      updated_at = clock_timestamp()
  where id = v_submission.routine_draft_id;

  return private.store_routine_mutation_result(
    v_reviewer_id, p_decision || '_routine_submission_v1', p_idempotency_key, v_fingerprint,
    jsonb_build_object(
      'operation', p_decision, 'submissionId', p_submission_id, 'reviewId', v_review_id,
      'status', p_decision
    )
  );
end;
$$;

create or replace function private.publish_approved_routine_submission_v1(
  p_submission_id uuid,
  p_effective_date date,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_routine_actor();
  v_submission public.routine_submissions%rowtype;
  v_review public.routine_reviews%rowtype;
  v_fingerprint text := private.sha256_jsonb(jsonb_build_array(
    'publish_approved_routine_submission_v1', p_submission_id, p_effective_date
  ));
  v_replay jsonb;
  v_version_id uuid;
  v_version_number bigint;
  v_day jsonb;
  v_prescription jsonb;
  v_version_day_id uuid;
begin
  if p_effective_date is null or extract(isodow from p_effective_date) <> 1
     or p_effective_date <= current_date then
    raise exception using errcode = '22023', message = 'routine_effective_date_must_be_future_monday';
  end if;
  v_replay := private.load_routine_mutation_result(
    v_user_id, 'publish_approved_routine_submission_v1', p_idempotency_key, v_fingerprint
  );
  if v_replay is not null then return v_replay; end if;

  select * into v_submission from public.routine_submissions
  where id = p_submission_id and author_user_id = v_user_id
  for update;
  if not found or v_submission.status <> 'approved' then
    raise exception using errcode = 'P0002', message = 'approved_routine_submission_not_found';
  end if;
  select * into v_review from public.routine_reviews
  where submission_id = p_submission_id and decision = 'approved';
  if not found or v_review.content_hash <> v_submission.content_hash then
    raise exception using errcode = '22023', message = 'routine_approval_content_mismatch';
  end if;
  if v_submission.validation_status <> 'valid'
     or not (v_submission.validation_result ->> 'valid')::boolean
     or private.sha256_jsonb(v_submission.snapshot) <> v_submission.content_hash then
    raise exception using errcode = '22023', message = 'routine_submission_evidence_invalid';
  end if;

  perform pg_advisory_xact_lock(hashtextextended('routine-version:' || v_user_id::text, 0));
  select coalesce(max(version_number), 0) + 1 into v_version_number
  from public.routine_versions
  where source_routine_draft_id = v_submission.routine_draft_id;
  insert into public.routine_versions (
    user_id, source_routine_draft_id, approved_submission_id, approved_review_id,
    version_number, name, description, content_hash, effective_date
  ) values (
    v_user_id, v_submission.routine_draft_id, p_submission_id, v_review.id,
    v_version_number, v_submission.snapshot ->> 'name',
    coalesce(v_submission.snapshot ->> 'description', ''), v_submission.content_hash, p_effective_date
  ) returning id into v_version_id;

  for v_day in select value from jsonb_array_elements(v_submission.snapshot -> 'days')
  loop
    insert into public.routine_version_days (
      routine_version_id, user_id, day_index, day_type, title, purpose, position
    ) values (
      v_version_id, v_user_id, (v_day ->> 'dayIndex')::integer, v_day ->> 'kind',
      coalesce(v_day ->> 'title', ''), coalesce(v_day ->> 'purpose', ''),
      (v_day ->> 'position')::integer
    ) returning id into v_version_day_id;
    for v_prescription in select value from jsonb_array_elements(v_day -> 'prescriptions')
    loop
      insert into public.routine_version_prescriptions (
        routine_version_id, routine_version_day_id, user_id, position,
        exercise_definition_id, guidance_revision_id, priority, working_sets,
        rep_min, rep_max, rir_target, rest_seconds, load_unit, notes
      ) values (
        v_version_id, v_version_day_id, v_user_id,
        (v_prescription ->> 'position')::integer,
        (v_prescription ->> 'exerciseId')::uuid,
        (v_prescription ->> 'guidanceRevisionId')::uuid,
        (v_prescription ->> 'priority')::boolean,
        (v_prescription ->> 'sets')::integer,
        (v_prescription ->> 'minReps')::integer,
        (v_prescription ->> 'maxReps')::integer,
        (v_prescription ->> 'rir')::integer,
        (v_prescription ->> 'restSeconds')::integer,
        v_prescription ->> 'loadUnit', coalesce(v_prescription ->> 'notes', '')
      );
    end loop;
  end loop;

  update public.routine_submissions set status = 'published' where id = p_submission_id;
  update public.routine_drafts set status = 'published', updated_at = clock_timestamp()
  where id = v_submission.routine_draft_id;

  return private.store_routine_mutation_result(
    v_user_id, 'publish_approved_routine_submission_v1', p_idempotency_key, v_fingerprint,
    jsonb_build_object(
      'operation', 'publish', 'submissionId', p_submission_id,
      'routineDraftId', v_submission.routine_draft_id,
      'routineVersionId', v_version_id, 'versionNumber', v_version_number,
      'effectiveDate', p_effective_date, 'status', 'published'
    )
  );
end;
$$;

create or replace function private.duplicate_routine_version_as_draft_v1(
  p_routine_version_id uuid,
  p_name text,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_routine_actor();
  v_source jsonb;
  v_name text;
  v_fingerprint text;
  v_replay jsonb;
  v_draft_id uuid;
  v_day jsonb;
  v_prescription jsonb;
  v_draft_day_id uuid;
begin
  v_source := private.routine_version_json(p_routine_version_id);
  if v_source is null or v_source ->> 'ownerId' <> v_user_id::text then
    raise exception using errcode = 'P0002', message = 'routine_version_not_found';
  end if;
  v_name := btrim(coalesce(nullif(p_name, ''), (v_source ->> 'name') || ' Copy'));
  if char_length(v_name) not between 1 and 120 then
    raise exception using errcode = '22023', message = 'invalid_routine_draft_name';
  end if;
  v_fingerprint := private.sha256_jsonb(jsonb_build_array(
    'duplicate_routine_version_as_draft_v1', p_routine_version_id, v_name
  ));
  v_replay := private.load_routine_mutation_result(
    v_user_id, 'duplicate_routine_version_as_draft_v1', p_idempotency_key, v_fingerprint
  );
  if v_replay is not null then return v_replay; end if;

  insert into public.routine_drafts (user_id, name, description, base_routine_version_id)
  values (v_user_id, v_name, coalesce(v_source ->> 'description', ''), p_routine_version_id)
  returning id into v_draft_id;
  for v_day in select value from jsonb_array_elements(v_source -> 'days')
  loop
    insert into public.routine_draft_days (
      routine_draft_id, user_id, day_index, day_type, title, purpose, position
    ) values (
      v_draft_id, v_user_id, (v_day ->> 'dayIndex')::integer, v_day ->> 'kind',
      coalesce(v_day ->> 'title', ''), coalesce(v_day ->> 'purpose', ''),
      (v_day ->> 'position')::integer
    ) returning id into v_draft_day_id;
    for v_prescription in select value from jsonb_array_elements(v_day -> 'prescriptions')
    loop
      insert into public.routine_draft_prescriptions (
        routine_draft_id, routine_draft_day_id, user_id, position,
        exercise_definition_id, guidance_revision_id, priority, working_sets,
        rep_min, rep_max, rir_target, rest_seconds, load_unit, notes
      ) values (
        v_draft_id, v_draft_day_id, v_user_id, (v_prescription ->> 'position')::integer,
        (v_prescription ->> 'exerciseId')::uuid,
        (v_prescription ->> 'guidanceRevisionId')::uuid,
        (v_prescription ->> 'priority')::boolean,
        (v_prescription ->> 'sets')::integer,
        (v_prescription ->> 'minReps')::integer,
        (v_prescription ->> 'maxReps')::integer,
        (v_prescription ->> 'rir')::integer,
        (v_prescription ->> 'restSeconds')::integer,
        v_prescription ->> 'loadUnit', coalesce(v_prescription ->> 'notes', '')
      );
    end loop;
  end loop;
  return private.store_routine_mutation_result(
    v_user_id, 'duplicate_routine_version_as_draft_v1', p_idempotency_key, v_fingerprint,
    jsonb_build_object(
      'operation', 'duplicateVersion', 'routineVersionId', p_routine_version_id,
      'routineDraftId', v_draft_id, 'routineDraftRevision', 1
    )
  );
end;
$$;

create or replace function public.list_my_routines_v1(p_search text default null)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_routine_actor();
  v_search text := lower(btrim(coalesce(p_search, '')));
begin
  if char_length(v_search) > 120 then
    raise exception using errcode = '22023', message = 'invalid_routine_search';
  end if;
  return jsonb_build_object('items', coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', draft.id, 'name', draft.name, 'status', draft.status,
      'revision', draft.revision, 'updatedAt', draft.updated_at,
      'latestVersionId', latest.id, 'latestVersionNumber', latest.version_number
    ) order by draft.updated_at desc, draft.id)
    from (
      select * from public.routine_drafts
      where user_id = v_user_id
        and status <> 'archived'
        and (v_search = '' or position(v_search in lower(name)) > 0)
      order by updated_at desc, id
      limit 100
    ) draft
    left join lateral (
      select version.id, version.version_number
      from public.routine_versions version
      where version.source_routine_draft_id = draft.id
      order by version.version_number desc limit 1
    ) latest on true
  ), '[]'::jsonb));
end;
$$;

create or replace function public.get_routine_draft_v1(p_routine_draft_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_routine_actor();
  v_result jsonb;
begin
  select private.routine_draft_json(p_routine_draft_id) into v_result
  from public.routine_drafts
  where id = p_routine_draft_id and user_id = v_user_id;
  if v_result is null then raise exception using errcode = 'P0002', message = 'routine_draft_not_found'; end if;
  return v_result;
end;
$$;

create or replace function private.routine_submission_json(p_submission_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id', submission.id,
    'routineDraftId', submission.routine_draft_id,
    'ownerId', submission.author_user_id,
    'routineName', submission.snapshot ->> 'name',
    'description', submission.snapshot ->> 'description',
    'draftRevision', submission.routine_draft_revision,
    'status', submission.status,
    'submittedAt', submission.submitted_at,
    'days', coalesce(submission.snapshot -> 'days', '[]'::jsonb),
    'validationIssues', coalesce(submission.validation_result -> 'issues', '[]'::jsonb),
    'contentHash', submission.content_hash,
    'reviewedAt', review.reviewed_at,
    'reviewNote', coalesce(review.reason, review.reviewer_note),
    'reviewerId', review.reviewer_user_id,
    'reviewDecision', review.decision
  )
  from public.routine_submissions submission
  left join public.routine_reviews review on review.submission_id = submission.id
  where submission.id = p_submission_id;
$$;

create or replace function public.list_routine_review_queue_v1()
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_routine_reviewer();
begin
  return jsonb_build_object('items', coalesce((
    select jsonb_agg(private.routine_submission_json(submission.id) order by submission.submitted_at, submission.id)
    from (
      select id, submitted_at
      from public.routine_submissions
      where author_user_id <> v_user_id and status = 'submitted'
      order by submitted_at, id
      limit 100
    ) submission
  ), '[]'::jsonb));
end;
$$;

create or replace function public.get_routine_submission_v1(p_submission_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_routine_actor();
  v_submission public.routine_submissions%rowtype;
  v_result jsonb;
begin
  select * into v_submission from public.routine_submissions where id = p_submission_id;
  if not found then raise exception using errcode = 'P0002', message = 'routine_submission_not_found'; end if;
  if v_submission.author_user_id <> v_user_id then
    perform private.require_routine_reviewer();
  end if;
  v_result := private.routine_submission_json(p_submission_id);
  return v_result;
end;
$$;

create or replace function public.list_routine_versions_v1(p_routine_draft_id uuid default null)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_routine_actor();
begin
  return jsonb_build_object('items', coalesce((
    select jsonb_agg(private.routine_version_json(version.id) order by version.version_number desc)
    from (
      select id, version_number
      from public.routine_versions
      where user_id = v_user_id
        and (p_routine_draft_id is null or source_routine_draft_id = p_routine_draft_id)
      order by version_number desc
      limit 100
    ) version
  ), '[]'::jsonb));
end;
$$;

create or replace function public.get_routine_version_v1(p_version_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_routine_actor();
  v_result jsonb;
begin
  select private.routine_version_json(p_version_id) into v_result
  from public.routine_versions where id = p_version_id and user_id = v_user_id;
  if v_result is null then raise exception using errcode = 'P0002', message = 'routine_version_not_found'; end if;
  return v_result;
end;
$$;

create or replace function public.create_routine_draft_v1(
  p_name text, p_description text, p_idempotency_key uuid
) returns jsonb language sql security invoker set search_path = '' as $$
  select private.create_routine_draft_v1(p_name, p_description, p_idempotency_key);
$$;
create or replace function public.save_routine_draft_v1(
  p_routine_draft_id uuid, p_name text, p_description text, p_days jsonb,
  p_expected_revision bigint, p_idempotency_key uuid
) returns jsonb language sql security invoker set search_path = '' as $$
  select private.save_routine_draft_v1(
    p_routine_draft_id, p_name, p_description, p_days, p_expected_revision, p_idempotency_key
  );
$$;
create or replace function public.archive_routine_draft_v1(
  p_routine_draft_id uuid, p_expected_revision bigint, p_idempotency_key uuid
) returns jsonb language sql security invoker set search_path = '' as $$
  select private.archive_routine_draft_v1(p_routine_draft_id, p_expected_revision, p_idempotency_key);
$$;
create or replace function public.validate_routine_draft_v1(
  p_routine_draft_id uuid, p_expected_revision bigint
) returns jsonb language sql security invoker set search_path = '' as $$
  select private.validate_routine_draft_v1(p_routine_draft_id, p_expected_revision);
$$;
create or replace function public.submit_routine_v1(
  p_routine_draft_id uuid, p_expected_revision bigint, p_idempotency_key uuid
) returns jsonb language sql security invoker set search_path = '' as $$
  select private.submit_routine_v1(p_routine_draft_id, p_expected_revision, p_idempotency_key);
$$;
create or replace function public.approve_routine_submission_v1(
  p_submission_id uuid, p_note text, p_idempotency_key uuid
) returns jsonb language sql security invoker set search_path = '' as $$
  select private.decide_routine_submission_v1(p_submission_id, 'approved', null, p_note, p_idempotency_key);
$$;
create or replace function public.reject_routine_submission_v1(
  p_submission_id uuid, p_reason text, p_idempotency_key uuid
) returns jsonb language sql security invoker set search_path = '' as $$
  select private.decide_routine_submission_v1(p_submission_id, 'rejected', p_reason, null, p_idempotency_key);
$$;
create or replace function public.publish_approved_routine_submission_v1(
  p_submission_id uuid, p_effective_date date, p_idempotency_key uuid
) returns jsonb language sql security invoker set search_path = '' as $$
  select private.publish_approved_routine_submission_v1(p_submission_id, p_effective_date, p_idempotency_key);
$$;
create or replace function public.duplicate_routine_version_as_draft_v1(
  p_version_id uuid, p_name text, p_idempotency_key uuid
) returns jsonb language sql security invoker set search_path = '' as $$
  select private.duplicate_routine_version_as_draft_v1(p_version_id, p_name, p_idempotency_key);
$$;

alter table public.routine_drafts enable row level security;
alter table public.routine_draft_days enable row level security;
alter table public.routine_draft_prescriptions enable row level security;
alter table public.routine_submissions enable row level security;
alter table public.routine_reviews enable row level security;
alter table public.routine_versions enable row level security;
alter table public.routine_version_days enable row level security;
alter table public.routine_version_prescriptions enable row level security;
alter table private.routine_mutation_operations enable row level security;

create policy routine_drafts_select_own on public.routine_drafts
for select to authenticated
using ((select auth.uid()) = user_id and (select private.current_session_is_authorized(true, false)));
create policy routine_draft_days_select_own on public.routine_draft_days
for select to authenticated
using ((select auth.uid()) = user_id and (select private.current_session_is_authorized(true, false)));
create policy routine_draft_prescriptions_select_own on public.routine_draft_prescriptions
for select to authenticated
using ((select auth.uid()) = user_id and (select private.current_session_is_authorized(true, false)));
create policy routine_submissions_select_author_or_reviewer on public.routine_submissions
for select to authenticated
using (
  (select private.current_session_is_authorized(true, false))
  and (
    (select auth.uid()) = author_user_id
    or (
      (select auth.uid()) <> author_user_id
      and exists (
        select 1 from public.account_capabilities capability
        where capability.user_id = (select auth.uid())
          and capability.capability_code = 'routine_reviewer'
          and capability.is_enabled
      )
    )
  )
);
create policy routine_reviews_select_participant on public.routine_reviews
for select to authenticated
using (
  (select private.current_session_is_authorized(true, false))
  and ((select auth.uid()) = author_user_id or (select auth.uid()) = reviewer_user_id)
);
create policy routine_versions_select_own on public.routine_versions
for select to authenticated
using ((select auth.uid()) = user_id and (select private.current_session_is_authorized(true, false)));
create policy routine_version_days_select_own on public.routine_version_days
for select to authenticated
using ((select auth.uid()) = user_id and (select private.current_session_is_authorized(true, false)));
create policy routine_version_prescriptions_select_own on public.routine_version_prescriptions
for select to authenticated
using ((select auth.uid()) = user_id and (select private.current_session_is_authorized(true, false)));

grant select on table public.routine_drafts to authenticated;
grant select on table public.routine_draft_days to authenticated;
grant select on table public.routine_draft_prescriptions to authenticated;
grant select on table public.routine_submissions to authenticated;
grant select on table public.routine_reviews to authenticated;
grant select on table public.routine_versions to authenticated;
grant select on table public.routine_version_days to authenticated;
grant select on table public.routine_version_prescriptions to authenticated;

revoke all on function private.require_routine_actor() from public, anon, authenticated, service_role;
revoke all on function private.require_routine_reviewer() from public, anon, authenticated, service_role;
revoke all on function private.load_routine_mutation_result(uuid,text,uuid,text) from public, anon, authenticated, service_role;
revoke all on function private.store_routine_mutation_result(uuid,text,uuid,text,jsonb) from public, anon, authenticated, service_role;
revoke all on function private.routine_draft_json(uuid) from public, anon, authenticated, service_role;
revoke all on function private.routine_version_json(uuid) from public, anon, authenticated, service_role;
revoke all on function private.routine_submission_json(uuid) from public, anon, authenticated, service_role;
revoke all on function private.validate_routine_draft(uuid) from public, anon, authenticated, service_role;
revoke all on function private.reject_immutable_routine_change() from public, anon, authenticated, service_role;
revoke all on function private.create_routine_draft_v1(text,text,uuid) from public, anon, authenticated, service_role;
revoke all on function private.save_routine_draft_v1(uuid,text,text,jsonb,bigint,uuid) from public, anon, authenticated, service_role;
revoke all on function private.archive_routine_draft_v1(uuid,bigint,uuid) from public, anon, authenticated, service_role;
revoke all on function private.validate_routine_draft_v1(uuid,bigint) from public, anon, authenticated, service_role;
revoke all on function private.submit_routine_v1(uuid,bigint,uuid) from public, anon, authenticated, service_role;
revoke all on function private.decide_routine_submission_v1(uuid,text,text,text,uuid) from public, anon, authenticated, service_role;
revoke all on function private.publish_approved_routine_submission_v1(uuid,date,uuid) from public, anon, authenticated, service_role;
revoke all on function private.duplicate_routine_version_as_draft_v1(uuid,text,uuid) from public, anon, authenticated, service_role;

revoke all on function public.list_my_routines_v1(text) from public, anon, authenticated, service_role;
revoke all on function public.get_routine_draft_v1(uuid) from public, anon, authenticated, service_role;
revoke all on function public.create_routine_draft_v1(text,text,uuid) from public, anon, authenticated, service_role;
revoke all on function public.save_routine_draft_v1(uuid,text,text,jsonb,bigint,uuid) from public, anon, authenticated, service_role;
revoke all on function public.archive_routine_draft_v1(uuid,bigint,uuid) from public, anon, authenticated, service_role;
revoke all on function public.validate_routine_draft_v1(uuid,bigint) from public, anon, authenticated, service_role;
revoke all on function public.submit_routine_v1(uuid,bigint,uuid) from public, anon, authenticated, service_role;
revoke all on function public.list_routine_review_queue_v1() from public, anon, authenticated, service_role;
revoke all on function public.get_routine_submission_v1(uuid) from public, anon, authenticated, service_role;
revoke all on function public.approve_routine_submission_v1(uuid,text,uuid) from public, anon, authenticated, service_role;
revoke all on function public.reject_routine_submission_v1(uuid,text,uuid) from public, anon, authenticated, service_role;
revoke all on function public.publish_approved_routine_submission_v1(uuid,date,uuid) from public, anon, authenticated, service_role;
revoke all on function public.list_routine_versions_v1(uuid) from public, anon, authenticated, service_role;
revoke all on function public.get_routine_version_v1(uuid) from public, anon, authenticated, service_role;
revoke all on function public.duplicate_routine_version_as_draft_v1(uuid,text,uuid) from public, anon, authenticated, service_role;

grant execute on function private.create_routine_draft_v1(text,text,uuid) to authenticated;
grant execute on function private.save_routine_draft_v1(uuid,text,text,jsonb,bigint,uuid) to authenticated;
grant execute on function private.archive_routine_draft_v1(uuid,bigint,uuid) to authenticated;
grant execute on function private.validate_routine_draft_v1(uuid,bigint) to authenticated;
grant execute on function private.submit_routine_v1(uuid,bigint,uuid) to authenticated;
grant execute on function private.decide_routine_submission_v1(uuid,text,text,text,uuid) to authenticated;
grant execute on function private.publish_approved_routine_submission_v1(uuid,date,uuid) to authenticated;
grant execute on function private.duplicate_routine_version_as_draft_v1(uuid,text,uuid) to authenticated;

grant execute on function public.list_my_routines_v1(text) to authenticated;
grant execute on function public.get_routine_draft_v1(uuid) to authenticated;
grant execute on function public.create_routine_draft_v1(text,text,uuid) to authenticated;
grant execute on function public.save_routine_draft_v1(uuid,text,text,jsonb,bigint,uuid) to authenticated;
grant execute on function public.archive_routine_draft_v1(uuid,bigint,uuid) to authenticated;
grant execute on function public.validate_routine_draft_v1(uuid,bigint) to authenticated;
grant execute on function public.submit_routine_v1(uuid,bigint,uuid) to authenticated;
grant execute on function public.list_routine_review_queue_v1() to authenticated;
grant execute on function public.get_routine_submission_v1(uuid) to authenticated;
grant execute on function public.approve_routine_submission_v1(uuid,text,uuid) to authenticated;
grant execute on function public.reject_routine_submission_v1(uuid,text,uuid) to authenticated;
grant execute on function public.publish_approved_routine_submission_v1(uuid,date,uuid) to authenticated;
grant execute on function public.list_routine_versions_v1(uuid) to authenticated;
grant execute on function public.get_routine_version_v1(uuid) to authenticated;
grant execute on function public.duplicate_routine_version_as_draft_v1(uuid,text,uuid) to authenticated;

comment on table public.routine_submissions is
  'Immutable validated routine snapshots used for independent review.';
comment on table public.routine_versions is
  'Immutable published routine history; Phase 4 owns future-week materialization.';
comment on table private.routine_mutation_operations is
  'Durable bounded idempotency replay evidence for routine mutations.';

commit;
