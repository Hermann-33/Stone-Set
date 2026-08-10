alter table public.routine_versions
  alter column approved_submission_id drop not null,
  alter column approved_review_id drop not null;

create or replace function private.publish_routine_draft_v1(
  p_routine_draft_id uuid,
  p_expected_revision bigint,
  p_idempotency_key uuid
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_routine_actor();
  v_draft public.routine_drafts%rowtype;
  v_validation jsonb;
  v_snapshot jsonb;
  v_publish_content jsonb;
  v_content_hash text;
  v_fingerprint text;
  v_replay jsonb;
  v_version_id uuid;
  v_version_number bigint;
  v_effective_date date := date_trunc('week', current_date)::date;
  v_day jsonb;
  v_prescription jsonb;
  v_version_day_id uuid;
begin
  if p_routine_draft_id is null or p_expected_revision is null or p_idempotency_key is null then
    raise exception using errcode = '22023', message = 'invalid_routine_publish_request';
  end if;

  v_fingerprint := private.sha256_jsonb(jsonb_build_array(
    'publish_routine_draft_v1', p_routine_draft_id, p_expected_revision
  ));
  v_replay := private.load_routine_mutation_result(
    v_user_id, 'publish_routine_draft_v1', p_idempotency_key, v_fingerprint
  );
  if v_replay is not null then return v_replay; end if;

  select * into v_draft
  from public.routine_drafts
  where id = p_routine_draft_id
    and user_id = v_user_id
    and status in ('draft', 'submitted', 'approved', 'rejected')
  for update;

  if not found then
    raise exception using errcode = 'P0002', message = 'publishable_routine_draft_not_found';
  end if;
  if v_draft.revision <> p_expected_revision then
    raise exception using
      errcode = '40001',
      message = 'routine_draft_revision_conflict',
      detail = jsonb_build_object(
        'currentRevision', v_draft.revision,
        'correlationId', gen_random_uuid()
      )::text;
  end if;

  v_validation := private.validate_routine_draft(p_routine_draft_id);
  if not coalesce((v_validation ->> 'valid')::boolean, false) then
    raise exception using
      errcode = '22023',
      message = 'routine_draft_invalid',
      detail = jsonb_build_object(
        'correlationId', gen_random_uuid(),
        'validation', v_validation
      )::text;
  end if;

  v_snapshot := private.routine_draft_json(p_routine_draft_id);
  v_publish_content := jsonb_build_object(
    'name', v_snapshot ->> 'name',
    'description', coalesce(v_snapshot ->> 'description', ''),
    'days', v_snapshot -> 'days'
  );
  v_content_hash := private.sha256_jsonb(v_publish_content);

  perform pg_advisory_xact_lock(hashtextextended('routine-version:' || v_user_id::text, 0));
  select coalesce(max(version_number), 0) + 1
  into v_version_number
  from public.routine_versions
  where source_routine_draft_id = p_routine_draft_id;

  insert into public.routine_versions (
    user_id,
    source_routine_draft_id,
    approved_submission_id,
    approved_review_id,
    version_number,
    name,
    description,
    content_hash,
    effective_date
  ) values (
    v_user_id,
    p_routine_draft_id,
    null,
    null,
    v_version_number,
    v_snapshot ->> 'name',
    coalesce(v_snapshot ->> 'description', ''),
    v_content_hash,
    v_effective_date
  ) returning id into v_version_id;

  for v_day in select value from jsonb_array_elements(v_snapshot -> 'days')
  loop
    insert into public.routine_version_days (
      routine_version_id, user_id, day_index, day_type, title, purpose, position
    ) values (
      v_version_id,
      v_user_id,
      (v_day ->> 'dayIndex')::integer,
      v_day ->> 'kind',
      coalesce(v_day ->> 'title', ''),
      coalesce(v_day ->> 'purpose', ''),
      (v_day ->> 'position')::integer
    ) returning id into v_version_day_id;

    for v_prescription in select value from jsonb_array_elements(v_day -> 'prescriptions')
    loop
      insert into public.routine_version_prescriptions (
        routine_version_id,
        routine_version_day_id,
        user_id,
        position,
        exercise_definition_id,
        guidance_revision_id,
        priority,
        working_sets,
        rep_min,
        rep_max,
        rir_target,
        rest_seconds,
        load_unit,
        notes
      ) values (
        v_version_id,
        v_version_day_id,
        v_user_id,
        (v_prescription ->> 'position')::integer,
        (v_prescription ->> 'exerciseId')::uuid,
        (v_prescription ->> 'guidanceRevisionId')::uuid,
        (v_prescription ->> 'priority')::boolean,
        (v_prescription ->> 'sets')::integer,
        (v_prescription ->> 'minReps')::integer,
        (v_prescription ->> 'maxReps')::integer,
        (v_prescription ->> 'rir')::integer,
        (v_prescription ->> 'restSeconds')::integer,
        v_prescription ->> 'loadUnit',
        coalesce(v_prescription ->> 'notes', '')
      );
    end loop;
  end loop;

  update public.routine_submissions
  set status = 'published', decided_at = coalesce(decided_at, clock_timestamp())
  where routine_draft_id = p_routine_draft_id
    and status in ('submitted', 'approved');

  update public.routine_drafts
  set status = 'published', updated_at = clock_timestamp()
  where id = p_routine_draft_id;

  return private.store_routine_mutation_result(
    v_user_id,
    'publish_routine_draft_v1',
    p_idempotency_key,
    v_fingerprint,
    jsonb_build_object(
      'operation', 'publish',
      'routineDraftId', p_routine_draft_id,
      'routineVersionId', v_version_id,
      'versionNumber', v_version_number,
      'effectiveDate', v_effective_date,
      'status', 'published'
    )
  );
end;
$$;

create or replace function public.publish_routine_draft_v1(
  p_routine_draft_id uuid,
  p_expected_revision bigint,
  p_idempotency_key uuid
) returns jsonb
language sql
set search_path = ''
as $$
  select private.publish_routine_draft_v1(
    p_routine_draft_id,
    p_expected_revision,
    p_idempotency_key
  );
$$;

revoke execute on function public.publish_routine_draft_v1(uuid,bigint,uuid) from public, anon;
grant execute on function public.publish_routine_draft_v1(uuid,bigint,uuid) to authenticated;

revoke execute on function public.submit_routine_v1(uuid,bigint,uuid) from public, anon, authenticated;
revoke execute on function public.approve_routine_submission_v1(uuid,text,uuid) from public, anon, authenticated;
revoke execute on function public.reject_routine_submission_v1(uuid,text,uuid) from public, anon, authenticated;
revoke execute on function public.publish_approved_routine_submission_v1(uuid,date,uuid) from public, anon, authenticated;
revoke execute on function public.list_routine_review_queue_v1() from public, anon, authenticated;
revoke execute on function public.get_routine_submission_v1(uuid) from public, anon, authenticated;
