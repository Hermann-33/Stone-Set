begin;

create or replace function private.create_guidance_media_draft_from_revision_v1(
  p_exercise_id uuid,
  p_guidance_revision_id uuid,
  p_expected_exercise_revision bigint,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_fingerprint text;
  v_replayed jsonb;
  v_exercise public.exercise_definitions%rowtype;
  v_source public.guidance_revisions%rowtype;
  v_existing_draft public.guidance_drafts%rowtype;
  v_draft public.guidance_drafts%rowtype;
  v_state public.guidance_media_draft_states%rowtype;
  v_image_count integer := 0;
  v_youtube_copied boolean := false;
  v_result jsonb;
begin
  if p_exercise_id is null
     or p_guidance_revision_id is null
     or p_expected_exercise_revision is null
     or p_expected_exercise_revision <= 0
     or p_idempotency_key is null then
    raise exception using
      errcode = '22023',
      message = 'invalid_guidance_media_draft_materialization_request';
  end if;

  v_fingerprint := private.sha256_jsonb(jsonb_build_array(
    p_exercise_id,
    p_guidance_revision_id,
    p_expected_exercise_revision
  ));
  v_replayed := private.load_mutation_result(
    v_user_id,
    'create_guidance_media_draft_from_revision_v1',
    p_idempotency_key,
    v_fingerprint
  );
  if v_replayed is not null then
    return v_replayed;
  end if;

  select exercise.*
  into v_exercise
  from public.exercise_definitions as exercise
  where exercise.id = p_exercise_id
    and exercise.user_id = v_user_id
  for update;

  if not found then
    raise exception using errcode = 'P0002', message = 'exercise_not_found';
  end if;
  if v_exercise.archived_at is not null then
    raise exception using errcode = '55000', message = 'archived_exercise_cannot_create_guidance_draft';
  end if;
  if v_exercise.revision <> p_expected_exercise_revision then
    raise exception using
      errcode = '40001',
      message = 'stale_exercise_revision',
      detail = jsonb_build_object(
        'correlationId', gen_random_uuid(),
        'exerciseRevision', v_exercise.revision
      )::text;
  end if;

  select revision.*
  into v_source
  from public.guidance_revisions as revision
  where revision.id = p_guidance_revision_id
    and revision.exercise_id = p_exercise_id
    and revision.user_id = v_user_id;

  if not found then
    raise exception using errcode = 'P0002', message = 'guidance_revision_not_found';
  end if;

  select draft.*
  into v_existing_draft
  from public.guidance_drafts as draft
  where draft.exercise_id = p_exercise_id
    and draft.user_id = v_user_id;

  if found then
    select state.*
    into v_state
    from public.guidance_media_draft_states as state
    where state.guidance_draft_id = v_existing_draft.id
      and state.exercise_id = p_exercise_id
      and state.user_id = v_user_id;

    raise exception using
      errcode = '40001',
      message = 'guidance_media_draft_already_exists',
      detail = jsonb_build_object(
        'correlationId', gen_random_uuid(),
        'draftId', v_existing_draft.id,
        'draftRevision', v_existing_draft.revision,
        'mediaRevision', coalesce(v_state.media_revision, 1)
      )::text;
  end if;

  insert into public.guidance_drafts (
    exercise_id,
    user_id,
    base_guidance_revision_id,
    structured_content_schema_version,
    structured_content
  ) values (
    p_exercise_id,
    v_user_id,
    p_guidance_revision_id,
    v_source.structured_content_schema_version,
    v_source.structured_content
  )
  returning * into v_draft;

  insert into public.guidance_media_draft_states (
    guidance_draft_id,
    exercise_id,
    user_id
  ) values (
    v_draft.id,
    p_exercise_id,
    v_user_id
  )
  returning * into v_state;

  insert into public.guidance_media_assets (
    id,
    user_id,
    exercise_id,
    guidance_draft_id,
    source_asset_id,
    bucket_id,
    object_path,
    mime_type,
    byte_size,
    width,
    height,
    sha256_hex,
    alt_text,
    position,
    is_cover,
    state,
    revision
  )
  select
    gen_random_uuid(),
    v_user_id,
    p_exercise_id,
    v_draft.id,
    source.id,
    source.bucket_id,
    source.object_path,
    source.mime_type,
    source.byte_size,
    source.width,
    source.height,
    source.sha256_hex,
    source.alt_text,
    source.position,
    source.is_cover,
    'ready',
    1
  from public.guidance_media_assets as source
  where source.guidance_revision_id = p_guidance_revision_id
    and source.exercise_id = p_exercise_id
    and source.user_id = v_user_id
    and source.state = 'published'
  order by source.position, source.id;
  get diagnostics v_image_count = row_count;

  insert into public.guidance_youtube_references (
    user_id,
    exercise_id,
    guidance_draft_id,
    source_reference_id,
    provider,
    video_id,
    canonical_watch_url,
    start_seconds,
    title_snapshot,
    thumbnail_url_snapshot,
    validation_status,
    validated_at
  )
  select
    v_user_id,
    p_exercise_id,
    v_draft.id,
    source.id,
    source.provider,
    source.video_id,
    source.canonical_watch_url,
    source.start_seconds,
    source.title_snapshot,
    source.thumbnail_url_snapshot,
    source.validation_status,
    source.validated_at
  from public.guidance_youtube_references as source
  where source.guidance_revision_id = p_guidance_revision_id
    and source.exercise_id = p_exercise_id
    and source.user_id = v_user_id;
  v_youtube_copied := found;

  v_result := jsonb_build_object(
    'operation', 'create_guidance_media_draft_from_revision_v1',
    'exerciseId', p_exercise_id,
    'sourceGuidanceRevisionId', p_guidance_revision_id,
    'exerciseRevision', v_exercise.revision,
    'draftId', v_draft.id,
    'draftRevision', v_draft.revision,
    'mediaRevision', v_state.media_revision,
    'imageCount', v_image_count,
    'youtubeCopied', v_youtube_copied,
    'reusedPublishedObjects', true
  );

  return private.store_mutation_result(
    v_user_id,
    'create_guidance_media_draft_from_revision_v1',
    p_idempotency_key,
    v_fingerprint,
    v_result
  );
end;
$$;

create or replace function public.create_guidance_media_draft_from_revision_v1(
  p_exercise_id uuid,
  p_guidance_revision_id uuid,
  p_expected_exercise_revision bigint,
  p_idempotency_key uuid
)
returns jsonb
language sql
volatile
security definer
set search_path = ''
as $$
  select private.create_guidance_media_draft_from_revision_v1(
    p_exercise_id,
    p_guidance_revision_id,
    p_expected_exercise_revision,
    p_idempotency_key
  );
$$;

revoke all on function private.create_guidance_media_draft_from_revision_v1(uuid, uuid, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function public.create_guidance_media_draft_from_revision_v1(uuid, uuid, bigint, uuid)
  from public, anon, authenticated, service_role;

grant execute on function public.create_guidance_media_draft_from_revision_v1(uuid, uuid, bigint, uuid)
  to authenticated;

comment on function public.create_guidance_media_draft_from_revision_v1(uuid, uuid, bigint, uuid) is
  'Owner-scoped, atomic and idempotent materialization of an editable guidance/media draft from one immutable revision.';

commit;
