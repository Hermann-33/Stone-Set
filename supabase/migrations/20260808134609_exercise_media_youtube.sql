begin;

alter table public.guidance_drafts
  add constraint guidance_drafts_id_exercise_user_unique unique (id, exercise_id, user_id);

create table public.guidance_media_draft_states (
  guidance_draft_id uuid primary key,
  exercise_id uuid not null,
  user_id uuid not null,
  media_revision bigint not null default 1 check (media_revision > 0),
  created_at timestamptz not null default clock_timestamp(),
  updated_at timestamptz not null default clock_timestamp(),
  unique (guidance_draft_id, exercise_id, user_id),
  foreign key (guidance_draft_id, user_id)
    references public.guidance_drafts (id, user_id) on delete cascade,
  foreign key (exercise_id, user_id)
    references public.exercise_definitions (id, user_id) on delete cascade
);

create index guidance_media_draft_states_owner_idx
  on public.guidance_media_draft_states (user_id, guidance_draft_id);

create table public.guidance_media_assets (
  id uuid primary key,
  user_id uuid not null,
  exercise_id uuid not null,
  guidance_draft_id uuid,
  guidance_revision_id uuid,
  source_asset_id uuid,
  bucket_id text not null default 'exercise-media',
  object_path text not null,
  mime_type text not null,
  byte_size bigint,
  width integer,
  height integer,
  sha256_hex text,
  alt_text text not null default '',
  position integer not null default 0,
  is_cover boolean not null default false,
  state text not null default 'pending',
  revision bigint not null default 1 check (revision > 0),
  created_at timestamptz not null default clock_timestamp(),
  updated_at timestamptz not null default clock_timestamp(),
  published_at timestamptz,
  quarantined_at timestamptz,
  deleted_at timestamptz,
  unique (id, user_id),
  unique (id, guidance_draft_id, user_id),
  unique (id, guidance_revision_id, user_id),
  foreign key (exercise_id, user_id)
    references public.exercise_definitions (id, user_id) on delete restrict,
  foreign key (guidance_draft_id, exercise_id, user_id)
    references public.guidance_drafts (id, exercise_id, user_id) on delete cascade,
  foreign key (guidance_revision_id, exercise_id, user_id)
    references public.guidance_revisions (id, exercise_id, user_id) on delete restrict,
  foreign key (source_asset_id, user_id)
    references public.guidance_media_assets (id, user_id) on delete restrict,
  constraint guidance_media_assets_scope_xor check (
    (guidance_draft_id is not null) <> (guidance_revision_id is not null)
  ),
  constraint guidance_media_assets_bucket check (bucket_id = 'exercise-media'),
  constraint guidance_media_assets_mime check (
    mime_type in ('image/jpeg', 'image/png', 'image/webp')
  ),
  constraint guidance_media_assets_object_path check (
    length(object_path) between 1 and 700 and object_path !~ '(^|/)\.\.(/|$)'
  ),
  constraint guidance_media_assets_byte_size check (
    byte_size is null or byte_size between 1 and 5242880
  ),
  constraint guidance_media_assets_dimensions check (
    (width is null and height is null)
    or (
      width between 1 and 2400 and height between 1 and 2400
      and least(width, height) >= 320
    )
  ),
  constraint guidance_media_assets_sha256 check (
    sha256_hex is null or sha256_hex ~ '^[0-9a-f]{64}$'
  ),
  constraint guidance_media_assets_alt_text check (length(alt_text) <= 500),
  constraint guidance_media_assets_position check (position between 0 and 5),
  constraint guidance_media_assets_state check (
    state in ('pending', 'ready', 'published', 'quarantined', 'deleted')
  ),
  constraint guidance_media_assets_state_evidence check (
    (state = 'pending' and byte_size is null and width is null and height is null and sha256_hex is null)
    or state = 'quarantined'
    or (state in ('ready', 'published', 'deleted')
      and byte_size is not null and width is not null and height is not null and sha256_hex is not null)
  ),
  constraint guidance_media_assets_published_scope check (
    (state = 'published') = (guidance_revision_id is not null)
  ),
  constraint guidance_media_assets_published_time check (
    (state = 'published') = (published_at is not null)
  )
);

create index guidance_media_assets_draft_idx
  on public.guidance_media_assets (user_id, guidance_draft_id, position, id)
  where guidance_draft_id is not null and state in ('pending', 'ready');
create index guidance_media_assets_revision_idx
  on public.guidance_media_assets (user_id, guidance_revision_id, position, id)
  where guidance_revision_id is not null and state = 'published';
create index guidance_media_assets_source_idx
  on public.guidance_media_assets (source_asset_id)
  where source_asset_id is not null;
create unique index guidance_media_assets_original_path_unique
  on public.guidance_media_assets (object_path)
  where source_asset_id is null;
create unique index guidance_media_assets_revision_position_unique
  on public.guidance_media_assets (guidance_revision_id, position)
  where guidance_revision_id is not null and state = 'published';
create unique index guidance_media_assets_revision_cover_unique
  on public.guidance_media_assets (guidance_revision_id)
  where guidance_revision_id is not null and state = 'published' and is_cover;

create table public.guidance_youtube_references (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  exercise_id uuid not null,
  guidance_draft_id uuid,
  guidance_revision_id uuid,
  source_reference_id uuid,
  provider text not null default 'youtube',
  video_id text not null,
  canonical_watch_url text not null,
  start_seconds integer,
  title_snapshot text,
  thumbnail_url_snapshot text,
  validation_status text not null,
  validated_at timestamptz,
  revision bigint not null default 1 check (revision > 0),
  created_at timestamptz not null default clock_timestamp(),
  updated_at timestamptz not null default clock_timestamp(),
  published_at timestamptz,
  unique (id, user_id),
  unique (id, guidance_draft_id, user_id),
  foreign key (exercise_id, user_id)
    references public.exercise_definitions (id, user_id) on delete restrict,
  foreign key (guidance_draft_id, exercise_id, user_id)
    references public.guidance_drafts (id, exercise_id, user_id) on delete cascade,
  foreign key (guidance_revision_id, exercise_id, user_id)
    references public.guidance_revisions (id, exercise_id, user_id) on delete restrict,
  foreign key (source_reference_id, user_id)
    references public.guidance_youtube_references (id, user_id) on delete restrict,
  constraint guidance_youtube_references_scope_xor check (
    (guidance_draft_id is not null) <> (guidance_revision_id is not null)
  ),
  constraint guidance_youtube_references_provider check (provider = 'youtube'),
  constraint guidance_youtube_references_video_id check (video_id ~ '^[A-Za-z0-9_-]{11}$'),
  constraint guidance_youtube_references_url check (
    canonical_watch_url = 'https://www.youtube.com/watch?v=' || video_id
  ),
  constraint guidance_youtube_references_start check (
    start_seconds is null or start_seconds between 0 and 86400
  ),
  constraint guidance_youtube_references_title check (
    title_snapshot is null or length(title_snapshot) between 1 and 300
  ),
  constraint guidance_youtube_references_thumbnail check (
    thumbnail_url_snapshot is null
    or thumbnail_url_snapshot = 'https://i.ytimg.com/vi/' || video_id || '/hqdefault.jpg'
  ),
  constraint guidance_youtube_references_status check (
    validation_status in (
      'preview_required', 'preview_succeeded', 'unavailable', 'embed_disabled', 'player_error'
    )
  ),
  constraint guidance_youtube_references_validation_evidence check (
    (validation_status = 'preview_required' and validated_at is null)
    or (validation_status <> 'preview_required' and validated_at is not null)
  ),
  constraint guidance_youtube_references_published_time check (
    (guidance_revision_id is not null) = (published_at is not null)
  )
);

create unique index guidance_youtube_references_draft_unique
  on public.guidance_youtube_references (guidance_draft_id)
  where guidance_draft_id is not null;
create unique index guidance_youtube_references_revision_unique
  on public.guidance_youtube_references (guidance_revision_id)
  where guidance_revision_id is not null;
create index guidance_youtube_references_owner_idx
  on public.guidance_youtube_references (user_id, exercise_id);

create table public.guidance_media_manifests (
  guidance_revision_id uuid primary key,
  exercise_id uuid not null,
  user_id uuid not null,
  schema_version integer not null default 1,
  canonical_manifest jsonb not null,
  manifest_hash text not null,
  bundle_hash text not null unique,
  publication_fingerprint text not null,
  created_at timestamptz not null default clock_timestamp(),
  unique (guidance_revision_id, user_id),
  foreign key (guidance_revision_id, exercise_id, user_id)
    references public.guidance_revisions (id, exercise_id, user_id) on delete restrict,
  constraint guidance_media_manifests_schema check (schema_version = 1),
  constraint guidance_media_manifests_canonical_array check (
    jsonb_typeof(canonical_manifest) = 'array'
    and canonical_manifest ->> 0 = 'stone-set-guidance-media-manifest-v1'
  ),
  constraint guidance_media_manifests_hashes check (
    manifest_hash ~ '^[0-9a-f]{64}$'
    and bundle_hash ~ '^[0-9a-f]{64}$'
    and publication_fingerprint ~ '^[0-9a-f]{64}$'
  )
);

create index guidance_media_manifests_owner_idx
  on public.guidance_media_manifests (user_id, guidance_revision_id);
create index guidance_media_manifests_fingerprint_idx
  on public.guidance_media_manifests (exercise_id, publication_fingerprint);

create table private.media_upload_intents (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null unique,
  user_id uuid not null references public.profiles (id) on delete cascade,
  exercise_id uuid not null,
  guidance_draft_id uuid not null,
  bucket_id text not null default 'exercise-media' check (bucket_id = 'exercise-media'),
  object_path text not null unique,
  mime_type text not null check (mime_type in ('image/jpeg', 'image/png', 'image/webp')),
  file_extension text not null check (file_extension in ('jpg', 'jpeg', 'png', 'webp')),
  max_byte_size bigint not null default 5242880 check (max_byte_size = 5242880),
  expires_at timestamptz not null,
  consumed_at timestamptz,
  created_at timestamptz not null default clock_timestamp(),
  unique (id, user_id),
  foreign key (guidance_draft_id, exercise_id, user_id)
    references public.guidance_drafts (id, exercise_id, user_id) on delete cascade,
  constraint media_upload_intents_expiry check (expires_at > created_at),
  constraint media_upload_intents_extension_mime check (
    (mime_type = 'image/jpeg' and file_extension in ('jpg', 'jpeg'))
    or (mime_type = 'image/png' and file_extension = 'png')
    or (mime_type = 'image/webp' and file_extension = 'webp')
  )
);

create index media_upload_intents_active_idx
  on private.media_upload_intents (user_id, object_path, expires_at)
  where consumed_at is null;

create table private.media_publication_reservations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  exercise_id uuid not null,
  guidance_draft_id uuid not null,
  guidance_revision_id uuid not null,
  expected_exercise_revision bigint not null,
  expected_draft_revision bigint not null,
  expected_media_revision bigint not null,
  version_number bigint not null check (version_number > 0),
  supersedes_revision_id uuid,
  normalized_content jsonb not null,
  content_hash text not null,
  revision_hash text not null,
  canonical_manifest jsonb not null,
  manifest_hash text not null,
  bundle_hash text not null,
  publication_fingerprint text not null,
  state text not null default 'pending',
  existing_guidance_revision_id uuid,
  expires_at timestamptz not null,
  completed_at timestamptz,
  created_at timestamptz not null default clock_timestamp(),
  unique (id, user_id),
  foreign key (guidance_draft_id, exercise_id, user_id)
    references public.guidance_drafts (id, exercise_id, user_id) on delete cascade,
  foreign key (supersedes_revision_id, exercise_id, user_id)
    references public.guidance_revisions (id, exercise_id, user_id) on delete restrict,
  foreign key (existing_guidance_revision_id, exercise_id, user_id)
    references public.guidance_revisions (id, exercise_id, user_id) on delete restrict,
  constraint media_publication_reservations_state check (
    state in ('pending', 'no_change', 'completed', 'expired')
  ),
  constraint media_publication_reservations_hashes check (
    content_hash ~ '^[0-9a-f]{64}$'
    and revision_hash ~ '^[0-9a-f]{64}$'
    and manifest_hash ~ '^[0-9a-f]{64}$'
    and bundle_hash ~ '^[0-9a-f]{64}$'
    and publication_fingerprint ~ '^[0-9a-f]{64}$'
  ),
  constraint media_publication_reservations_expiry check (expires_at > created_at)
);

create index media_publication_reservations_active_idx
  on private.media_publication_reservations (user_id, guidance_draft_id, expires_at)
  where state = 'pending';

create table private.media_publication_reservation_assets (
  reservation_id uuid not null,
  user_id uuid not null,
  source_asset_id uuid not null,
  published_asset_id uuid not null unique,
  source_object_path text not null,
  destination_object_path text not null unique,
  position integer not null check (position between 0 and 5),
  primary key (reservation_id, source_asset_id),
  unique (reservation_id, position),
  foreign key (reservation_id, user_id)
    references private.media_publication_reservations (id, user_id) on delete cascade,
  foreign key (source_asset_id, user_id)
    references public.guidance_media_assets (id, user_id) on delete restrict
);

create index media_publication_reservation_assets_owner_destination_idx
  on private.media_publication_reservation_assets (user_id, destination_object_path);

revoke all on table public.guidance_media_draft_states from public, anon, authenticated, service_role;
revoke all on table public.guidance_media_assets from public, anon, authenticated, service_role;
revoke all on table public.guidance_youtube_references from public, anon, authenticated, service_role;
revoke all on table public.guidance_media_manifests from public, anon, authenticated, service_role;
revoke all on table private.media_upload_intents from public, anon, authenticated, service_role;
revoke all on table private.media_publication_reservations from public, anon, authenticated, service_role;
revoke all on table private.media_publication_reservation_assets from public, anon, authenticated, service_role;

alter table public.guidance_revisions
  drop constraint guidance_revisions_exercise_id_content_hash_key;
create index guidance_revisions_exercise_content_hash_idx
  on public.guidance_revisions (exercise_id, content_hash);

create or replace function private.reject_published_media_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception using errcode = '55000', message = 'published_media_is_immutable';
end;
$$;

create trigger guidance_media_assets_published_immutable
before update or delete on public.guidance_media_assets
for each row
when (old.guidance_revision_id is not null)
execute function private.reject_published_media_change();

create trigger guidance_youtube_references_published_immutable
before update or delete on public.guidance_youtube_references
for each row
when (old.guidance_revision_id is not null)
execute function private.reject_published_media_change();

create trigger guidance_media_manifests_immutable
before update or delete on public.guidance_media_manifests
for each row
execute function private.reject_published_media_change();

create or replace function private.assert_draft_media_layout()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_draft_id uuid := coalesce(new.guidance_draft_id, old.guidance_draft_id);
begin
  if v_draft_id is null then return null; end if;
  if (select count(*) from public.guidance_media_assets
      where guidance_draft_id = v_draft_id and state in ('pending', 'ready')) > 6 then
    raise exception using errcode = '23514', message = 'guidance_media_image_limit_exceeded';
  end if;
  if exists (
    select 1 from public.guidance_media_assets
    where guidance_draft_id = v_draft_id and state = 'ready'
    group by position having count(*) > 1
  ) then
    raise exception using errcode = '23505', message = 'guidance_media_position_conflict';
  end if;
  if (select count(*) from public.guidance_media_assets
      where guidance_draft_id = v_draft_id and state = 'ready' and is_cover) > 1 then
    raise exception using errcode = '23505', message = 'guidance_media_cover_conflict';
  end if;
  return null;
end;
$$;

create constraint trigger guidance_media_assets_draft_layout_valid
after insert or update or delete on public.guidance_media_assets
deferrable initially deferred
for each row
execute function private.assert_draft_media_layout();

create or replace function private.ensure_media_draft_state(
  p_user_id uuid,
  p_exercise_id uuid,
  p_draft_id uuid
)
returns public.guidance_media_draft_states
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_state public.guidance_media_draft_states%rowtype;
begin
  if not exists (
    select 1 from public.guidance_drafts
    where id = p_draft_id and exercise_id = p_exercise_id and user_id = p_user_id
  ) then
    raise exception using errcode = 'P0002', message = 'guidance_draft_not_found';
  end if;
  insert into public.guidance_media_draft_states (guidance_draft_id, exercise_id, user_id)
  values (p_draft_id, p_exercise_id, p_user_id)
  on conflict (guidance_draft_id) do nothing;
  select * into v_state
  from public.guidance_media_draft_states
  where guidance_draft_id = p_draft_id and exercise_id = p_exercise_id and user_id = p_user_id
  for update;
  return v_state;
end;
$$;

create or replace function private.media_stale_detail(
  p_exercise_revision bigint,
  p_draft_revision bigint,
  p_media_revision bigint
)
returns text
language sql
volatile
set search_path = ''
as $$
  select jsonb_build_object(
    'correlationId', gen_random_uuid(),
    'exerciseRevision', p_exercise_revision,
    'draftRevision', p_draft_revision,
    'mediaRevision', p_media_revision
  )::text;
$$;

create or replace function private.media_manifest_canonical(
  p_images jsonb,
  p_youtube jsonb
)
returns jsonb
language sql
immutable
set search_path = ''
as $$
  select jsonb_build_array(
    'stone-set-guidance-media-manifest-v1',
    coalesce(p_images, '[]'::jsonb),
    p_youtube
  );
$$;

create or replace function private.can_insert_exercise_media_object(
  p_bucket_id text,
  p_object_path text,
  p_owner_id text
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select p_bucket_id = 'exercise-media'
    and p_owner_id = (select auth.uid())::text
    and (select private.current_session_is_authorized(true, false))
    and (
      exists (
        select 1
        from private.media_upload_intents as intent
        join public.guidance_media_assets as asset
          on asset.id = intent.asset_id and asset.user_id = intent.user_id
        where intent.user_id = (select auth.uid())
          and intent.bucket_id = p_bucket_id
          and intent.object_path = p_object_path
          and intent.consumed_at is null
          and intent.expires_at > clock_timestamp()
          and asset.state = 'pending'
      )
      or exists (
        select 1
        from private.media_publication_reservations as reservation
        join private.media_publication_reservation_assets as item
          on item.reservation_id = reservation.id and item.user_id = reservation.user_id
        where reservation.user_id = (select auth.uid())
          and reservation.state = 'pending'
          and reservation.expires_at > clock_timestamp()
          and item.destination_object_path = p_object_path
      )
    );
$$;

create or replace function private.can_select_exercise_media_object(
  p_bucket_id text,
  p_object_path text,
  p_owner_id text
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select p_bucket_id = 'exercise-media'
    and p_owner_id = (select auth.uid())::text
    and (select private.current_session_is_authorized(true, false))
    and (
      exists (
        select 1 from public.guidance_media_assets as asset
        where asset.user_id = (select auth.uid())
          and asset.bucket_id = p_bucket_id
          and asset.object_path = p_object_path
          and asset.state in ('ready', 'published')
      )
      or exists (
        select 1
        from private.media_publication_reservations as reservation
        join private.media_publication_reservation_assets as item
          on item.reservation_id = reservation.id and item.user_id = reservation.user_id
        where reservation.user_id = (select auth.uid())
          and reservation.state = 'pending'
          and reservation.expires_at > clock_timestamp()
          and item.destination_object_path = p_object_path
      )
    );
$$;

create or replace function private.can_delete_exercise_media_object(
  p_bucket_id text,
  p_object_path text,
  p_owner_id text
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select p_bucket_id = 'exercise-media'
    and p_owner_id = (select auth.uid())::text
    and (select private.current_session_is_authorized(true, false))
    and exists (
      select 1 from public.guidance_media_assets as asset
      where asset.user_id = (select auth.uid())
        and asset.bucket_id = p_bucket_id
        and asset.object_path = p_object_path
        and asset.guidance_draft_id is not null
        and asset.state = 'quarantined'
        and not exists (
          select 1 from public.guidance_media_assets as published
          where published.object_path = asset.object_path
            and published.guidance_revision_id is not null
            and published.state = 'published'
        )
    );
$$;

create or replace function private.get_guidance_draft_media_manifest_v1(
  p_exercise_id uuid,
  p_draft_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_draft public.guidance_drafts%rowtype;
  v_state public.guidance_media_draft_states%rowtype;
  v_images jsonb;
  v_youtube jsonb;
begin
  select * into v_draft from public.guidance_drafts
  where id = p_draft_id and exercise_id = p_exercise_id and user_id = v_user_id;
  if not found then raise exception using errcode = 'P0002', message = 'guidance_draft_not_found'; end if;
  select * into v_state from public.guidance_media_draft_states
  where guidance_draft_id = p_draft_id and user_id = v_user_id;
  select coalesce(jsonb_agg(jsonb_build_object(
    'assetId', asset.id,
    'ownerId', asset.user_id,
    'exerciseId', asset.exercise_id,
    'draftId', asset.guidance_draft_id,
    'guidanceRevisionId', null,
    'bucketId', asset.bucket_id,
    'objectPath', asset.object_path,
    'mimeType', asset.mime_type,
    'byteSize', asset.byte_size,
    'width', asset.width,
    'height', asset.height,
    'sha256Hex', asset.sha256_hex,
    'altText', asset.alt_text,
    'position', asset.position,
    'isCover', asset.is_cover,
    'state', asset.state,
    'createdAt', asset.created_at,
    'updatedAt', asset.updated_at
  ) order by asset.position, asset.id), '[]'::jsonb)
  into v_images
  from public.guidance_media_assets as asset
  where asset.guidance_draft_id = p_draft_id
    and asset.user_id = v_user_id
    and asset.state = 'ready';
  select jsonb_build_object(
    'referenceId', reference.id,
    'provider', reference.provider,
    'videoId', reference.video_id,
    'canonicalWatchUrl', reference.canonical_watch_url,
    'startSeconds', reference.start_seconds,
    'titleSnapshot', reference.title_snapshot,
    'thumbnailUrlSnapshot', reference.thumbnail_url_snapshot,
    'validationStatus', reference.validation_status,
    'validatedAt', reference.validated_at
  ) into v_youtube
  from public.guidance_youtube_references as reference
  where reference.guidance_draft_id = p_draft_id and reference.user_id = v_user_id;
  return jsonb_build_object(
    'schemaVersion', 1,
    'ownerId', v_user_id,
    'exerciseId', p_exercise_id,
    'draftId', p_draft_id,
    'guidanceRevisionId', null,
    'draftRevision', v_draft.revision,
    'mediaRevision', coalesce(v_state.media_revision, 1),
    'images', v_images,
    'youtube', v_youtube
  );
end;
$$;

create or replace function public.get_guidance_draft_media_manifest_v1(
  p_exercise_id uuid,
  p_draft_id uuid
)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.get_guidance_draft_media_manifest_v1(p_exercise_id, p_draft_id);
$$;

create or replace function private.get_guidance_revision_media_manifest_v1(
  p_exercise_id uuid,
  p_guidance_revision_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_revision public.guidance_revisions%rowtype;
  v_manifest public.guidance_media_manifests%rowtype;
  v_images jsonb;
  v_youtube jsonb;
begin
  select * into v_revision from public.guidance_revisions
  where id = p_guidance_revision_id and exercise_id = p_exercise_id and user_id = v_user_id;
  if not found then raise exception using errcode = 'P0002', message = 'guidance_revision_not_found'; end if;
  select * into v_manifest from public.guidance_media_manifests
  where guidance_revision_id = p_guidance_revision_id and user_id = v_user_id;
  select coalesce(jsonb_agg(jsonb_build_object(
    'assetId', asset.id,
    'ownerId', asset.user_id,
    'exerciseId', asset.exercise_id,
    'draftId', null,
    'guidanceRevisionId', asset.guidance_revision_id,
    'bucketId', asset.bucket_id,
    'objectPath', asset.object_path,
    'mimeType', asset.mime_type,
    'byteSize', asset.byte_size,
    'width', asset.width,
    'height', asset.height,
    'sha256Hex', asset.sha256_hex,
    'altText', asset.alt_text,
    'position', asset.position,
    'isCover', asset.is_cover,
    'state', asset.state,
    'createdAt', asset.created_at,
    'updatedAt', asset.updated_at
  ) order by asset.position, asset.id), '[]'::jsonb)
  into v_images from public.guidance_media_assets as asset
  where asset.guidance_revision_id = p_guidance_revision_id
    and asset.user_id = v_user_id and asset.state = 'published';
  select jsonb_build_object(
    'referenceId', reference.id,
    'provider', reference.provider,
    'videoId', reference.video_id,
    'canonicalWatchUrl', reference.canonical_watch_url,
    'startSeconds', reference.start_seconds,
    'titleSnapshot', reference.title_snapshot,
    'thumbnailUrlSnapshot', reference.thumbnail_url_snapshot,
    'validationStatus', reference.validation_status,
    'validatedAt', reference.validated_at
  ) into v_youtube from public.guidance_youtube_references as reference
  where reference.guidance_revision_id = p_guidance_revision_id and reference.user_id = v_user_id;
  return jsonb_build_object(
    'schemaVersion', 1,
    'ownerId', v_user_id,
    'exerciseId', p_exercise_id,
    'draftId', null,
    'guidanceRevisionId', p_guidance_revision_id,
    'mediaRevision', 1,
    'images', v_images,
    'youtube', v_youtube,
    'manifestHash', v_manifest.manifest_hash,
    'bundleHash', v_manifest.bundle_hash,
    'guidanceRevisionHash', v_revision.revision_hash
  );
end;
$$;

create or replace function public.get_guidance_revision_media_manifest_v1(
  p_exercise_id uuid,
  p_guidance_revision_id uuid
)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select private.get_guidance_revision_media_manifest_v1(p_exercise_id, p_guidance_revision_id);
$$;

create or replace function private.create_guidance_media_upload_intent_v1(
  p_exercise_id uuid,
  p_draft_id uuid,
  p_mime_type text,
  p_file_extension text,
  p_expected_draft_revision bigint,
  p_expected_media_revision bigint,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_mime text := lower(trim(p_mime_type));
  v_extension text := lower(trim(leading '.' from p_file_extension));
  v_fingerprint text := private.sha256_jsonb(jsonb_build_array(
    p_exercise_id, p_draft_id, v_mime, v_extension,
    p_expected_draft_revision, p_expected_media_revision
  ));
  v_replayed jsonb;
  v_draft public.guidance_drafts%rowtype;
  v_state public.guidance_media_draft_states%rowtype;
  v_asset_id uuid := gen_random_uuid();
  v_intent_id uuid := gen_random_uuid();
  v_path text;
  v_position integer;
  v_expires_at timestamptz := clock_timestamp() + interval '15 minutes';
  v_result jsonb;
begin
  if p_exercise_id is null or p_draft_id is null or p_expected_draft_revision is null
     or p_expected_media_revision is null or p_idempotency_key is null
     or not (
       (v_mime = 'image/jpeg' and v_extension in ('jpg', 'jpeg'))
       or (v_mime = 'image/png' and v_extension = 'png')
       or (v_mime = 'image/webp' and v_extension = 'webp')
     ) then
    raise exception using errcode = '22023', message = 'invalid_media_upload_intent';
  end if;
  v_replayed := private.load_mutation_result(
    v_user_id, 'create_guidance_media_upload_intent_v1', p_idempotency_key, v_fingerprint
  );
  if v_replayed is not null then return v_replayed; end if;
  select * into v_draft from public.guidance_drafts
  where id = p_draft_id and exercise_id = p_exercise_id and user_id = v_user_id for update;
  if not found then raise exception using errcode = 'P0002', message = 'guidance_draft_not_found'; end if;
  v_state := private.ensure_media_draft_state(v_user_id, p_exercise_id, p_draft_id);
  if v_draft.revision <> p_expected_draft_revision or v_state.media_revision <> p_expected_media_revision then
    raise exception using errcode = '40001', message = 'stale_guidance_media_revision',
      detail = private.media_stale_detail(null, v_draft.revision, v_state.media_revision);
  end if;
  select count(*)::integer into v_position from public.guidance_media_assets
  where guidance_draft_id = p_draft_id and state in ('pending', 'ready');
  if v_position >= 6 then raise exception using errcode = '23514', message = 'guidance_media_image_limit_exceeded'; end if;
  v_path := v_user_id::text || '/' || p_exercise_id::text || '/drafts/' ||
    p_draft_id::text || '/' || v_asset_id::text || '.' || v_extension;
  insert into public.guidance_media_assets (
    id, user_id, exercise_id, guidance_draft_id, object_path, mime_type, position
  ) values (
    v_asset_id, v_user_id, p_exercise_id, p_draft_id, v_path, v_mime, v_position
  );
  insert into private.media_upload_intents (
    id, asset_id, user_id, exercise_id, guidance_draft_id,
    object_path, mime_type, file_extension, expires_at
  ) values (
    v_intent_id, v_asset_id, v_user_id, p_exercise_id, p_draft_id,
    v_path, v_mime, v_extension, v_expires_at
  );
  update public.guidance_media_draft_states
  set media_revision = media_revision + 1, updated_at = clock_timestamp()
  where guidance_draft_id = p_draft_id returning * into v_state;
  v_result := jsonb_build_object(
    'operation', 'create_guidance_media_upload_intent_v1',
    'intentId', v_intent_id,
    'assetId', v_asset_id,
    'ownerId', v_user_id,
    'exerciseId', p_exercise_id,
    'draftId', p_draft_id,
    'bucketId', 'exercise-media',
    'objectPath', v_path,
    'mimeType', v_mime,
    'maximumByteSize', 5242880,
    'expiresAt', v_expires_at,
    'draftRevision', v_draft.revision,
    'mediaRevision', v_state.media_revision
  );
  return private.store_mutation_result(
    v_user_id, 'create_guidance_media_upload_intent_v1', p_idempotency_key, v_fingerprint, v_result
  );
end;
$$;

create or replace function public.create_guidance_media_upload_intent_v1(
  p_exercise_id uuid,
  p_draft_id uuid,
  p_mime_type text,
  p_file_extension text,
  p_expected_draft_revision bigint,
  p_expected_media_revision bigint,
  p_idempotency_key uuid
)
returns jsonb language sql volatile security invoker set search_path = ''
as $$ select private.create_guidance_media_upload_intent_v1(
  p_exercise_id, p_draft_id, p_mime_type, p_file_extension,
  p_expected_draft_revision, p_expected_media_revision, p_idempotency_key
); $$;

create or replace function private.finalize_guidance_media_upload_v1(
  p_intent_id uuid,
  p_byte_size bigint,
  p_width integer,
  p_height integer,
  p_sha256_hex text,
  p_expected_media_revision bigint,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_sha text := lower(trim(p_sha256_hex));
  v_fingerprint text := private.sha256_jsonb(jsonb_build_array(
    p_intent_id, p_byte_size, p_width, p_height, v_sha, p_expected_media_revision
  ));
  v_replayed jsonb;
  v_intent private.media_upload_intents%rowtype;
  v_state public.guidance_media_draft_states%rowtype;
  v_object storage.objects%rowtype;
  v_result jsonb;
begin
  if p_intent_id is null or p_byte_size not between 1 and 5242880
     or p_width not between 1 and 2400 or p_height not between 1 and 2400
     or least(p_width, p_height) < 320 or v_sha !~ '^[0-9a-f]{64}$'
     or p_expected_media_revision is null or p_idempotency_key is null then
    raise exception using errcode = '22023', message = 'invalid_media_upload_evidence';
  end if;
  v_replayed := private.load_mutation_result(
    v_user_id, 'finalize_guidance_media_upload_v1', p_idempotency_key, v_fingerprint
  );
  if v_replayed is not null then return v_replayed; end if;
  select * into v_intent from private.media_upload_intents
  where id = p_intent_id and user_id = v_user_id for update;
  if not found then raise exception using errcode = 'P0002', message = 'media_upload_intent_not_found'; end if;
  if v_intent.consumed_at is not null then raise exception using errcode = '55000', message = 'media_upload_intent_consumed'; end if;
  if v_intent.expires_at <= clock_timestamp() then raise exception using errcode = '55000', message = 'media_upload_intent_expired'; end if;
  v_state := private.ensure_media_draft_state(v_user_id, v_intent.exercise_id, v_intent.guidance_draft_id);
  if v_state.media_revision <> p_expected_media_revision then
    raise exception using errcode = '40001', message = 'stale_guidance_media_revision',
      detail = private.media_stale_detail(null, null, v_state.media_revision);
  end if;
  select * into v_object from storage.objects
  where bucket_id = v_intent.bucket_id and name = v_intent.object_path and owner_id = v_user_id::text;
  if not found then raise exception using errcode = 'P0002', message = 'media_storage_object_not_found'; end if;
  if coalesce((v_object.metadata ->> 'size')::bigint, -1) <> p_byte_size
     or coalesce(v_object.metadata ->> 'mimetype', '') <> v_intent.mime_type then
    raise exception using errcode = '22023', message = 'media_storage_metadata_mismatch';
  end if;
  update public.guidance_media_assets set
    byte_size = p_byte_size, width = p_width, height = p_height, sha256_hex = v_sha,
    state = 'ready', revision = revision + 1, updated_at = clock_timestamp()
  where id = v_intent.asset_id and user_id = v_user_id and state = 'pending';
  if not found then raise exception using errcode = '55000', message = 'media_asset_not_pending'; end if;
  update private.media_upload_intents set consumed_at = clock_timestamp() where id = p_intent_id;
  update public.guidance_media_draft_states
  set media_revision = media_revision + 1, updated_at = clock_timestamp()
  where guidance_draft_id = v_intent.guidance_draft_id returning * into v_state;
  v_result := jsonb_build_object(
    'operation', 'finalize_guidance_media_upload_v1',
    'intentId', p_intent_id,
    'assetId', v_intent.asset_id,
    'exerciseId', v_intent.exercise_id,
    'draftId', v_intent.guidance_draft_id,
    'mediaRevision', v_state.media_revision,
    'state', 'ready'
  );
  return private.store_mutation_result(
    v_user_id, 'finalize_guidance_media_upload_v1', p_idempotency_key, v_fingerprint, v_result
  );
end;
$$;

create or replace function public.finalize_guidance_media_upload_v1(
  p_intent_id uuid, p_byte_size bigint, p_width integer, p_height integer,
  p_sha256_hex text, p_expected_media_revision bigint, p_idempotency_key uuid
)
returns jsonb language sql volatile security invoker set search_path = ''
as $$ select private.finalize_guidance_media_upload_v1(
  p_intent_id, p_byte_size, p_width, p_height, p_sha256_hex,
  p_expected_media_revision, p_idempotency_key
); $$;

create or replace function private.save_guidance_media_layout_v1(
  p_draft_id uuid,
  p_images jsonb,
  p_expected_media_revision bigint,
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
    p_draft_id, p_images, p_expected_media_revision
  ));
  v_replayed jsonb;
  v_draft public.guidance_drafts%rowtype;
  v_state public.guidance_media_draft_states%rowtype;
  v_count integer;
  v_result jsonb;
begin
  if p_draft_id is null or jsonb_typeof(p_images) <> 'array'
     or jsonb_array_length(p_images) > 6
     or p_expected_media_revision is null or p_idempotency_key is null then
    raise exception using errcode = '22023', message = 'invalid_guidance_media_layout';
  end if;
  v_replayed := private.load_mutation_result(
    v_user_id, 'save_guidance_media_layout_v1', p_idempotency_key, v_fingerprint
  );
  if v_replayed is not null then return v_replayed; end if;
  select * into v_draft from public.guidance_drafts
  where id = p_draft_id and user_id = v_user_id for update;
  if not found then raise exception using errcode = 'P0002', message = 'guidance_draft_not_found'; end if;
  v_state := private.ensure_media_draft_state(v_user_id, v_draft.exercise_id, p_draft_id);
  if v_state.media_revision <> p_expected_media_revision then
    raise exception using errcode = '40001', message = 'stale_guidance_media_revision',
      detail = private.media_stale_detail(null, v_draft.revision, v_state.media_revision);
  end if;
  with requested as (
    select * from jsonb_to_recordset(p_images)
      as item("assetId" uuid, "altText" text, position integer, "isCover" boolean)
  )
  select count(*) into v_count from requested;
  if v_count <> (select count(*) from public.guidance_media_assets
                 where guidance_draft_id = p_draft_id and user_id = v_user_id and state = 'ready')
     or v_count <> (select count(distinct "assetId") from jsonb_to_recordset(p_images)
                    as item("assetId" uuid, "altText" text, position integer, "isCover" boolean))
     or v_count <> (select count(distinct position) from jsonb_to_recordset(p_images)
                    as item("assetId" uuid, "altText" text, position integer, "isCover" boolean))
     or exists (
       select 1 from jsonb_to_recordset(p_images)
         as item("assetId" uuid, "altText" text, position integer, "isCover" boolean)
       where "assetId" is null or position not between 0 and greatest(v_count - 1, 0)
         or "isCover" is null or length(trim(coalesce("altText", ''))) not between 1 and 500
     )
     or (v_count > 0 and (select count(*) from jsonb_to_recordset(p_images)
         as item("assetId" uuid, "altText" text, position integer, "isCover" boolean)
         where "isCover") <> 1)
     or exists (
       select 1 from jsonb_to_recordset(p_images)
         as item("assetId" uuid, "altText" text, position integer, "isCover" boolean)
       where not exists (
         select 1 from public.guidance_media_assets as asset
         where asset.id = "assetId" and asset.guidance_draft_id = p_draft_id
           and asset.user_id = v_user_id and asset.state = 'ready'
       )
     ) then
    raise exception using errcode = '22023', message = 'invalid_guidance_media_layout';
  end if;
  update public.guidance_media_assets as asset set
    alt_text = trim(item."altText"),
    position = item.position,
    is_cover = item."isCover",
    revision = asset.revision + 1,
    updated_at = clock_timestamp()
  from jsonb_to_recordset(p_images)
    as item("assetId" uuid, "altText" text, position integer, "isCover" boolean)
  where asset.id = item."assetId" and asset.guidance_draft_id = p_draft_id
    and asset.user_id = v_user_id and asset.state = 'ready';
  update public.guidance_media_draft_states
  set media_revision = media_revision + 1, updated_at = clock_timestamp()
  where guidance_draft_id = p_draft_id returning * into v_state;
  v_result := jsonb_build_object(
    'operation', 'save_guidance_media_layout_v1',
    'exerciseId', v_draft.exercise_id,
    'draftId', p_draft_id,
    'draftRevision', v_draft.revision,
    'mediaRevision', v_state.media_revision
  );
  return private.store_mutation_result(
    v_user_id, 'save_guidance_media_layout_v1', p_idempotency_key, v_fingerprint, v_result
  );
end;
$$;

create or replace function public.save_guidance_media_layout_v1(
  p_draft_id uuid, p_images jsonb, p_expected_media_revision bigint, p_idempotency_key uuid
)
returns jsonb language sql volatile security invoker set search_path = ''
as $$ select private.save_guidance_media_layout_v1(
  p_draft_id, p_images, p_expected_media_revision, p_idempotency_key
); $$;

create or replace function private.remove_guidance_media_asset_v1(
  p_draft_id uuid,
  p_asset_id uuid,
  p_expected_media_revision bigint,
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
    p_draft_id, p_asset_id, p_expected_media_revision
  ));
  v_replayed jsonb;
  v_asset public.guidance_media_assets%rowtype;
  v_draft public.guidance_drafts%rowtype;
  v_state public.guidance_media_draft_states%rowtype;
  v_result jsonb;
  v_requires_storage_delete boolean;
begin
  if p_draft_id is null or p_asset_id is null or p_expected_media_revision is null
     or p_idempotency_key is null then
    raise exception using errcode = '22023', message = 'invalid_remove_media_asset';
  end if;
  v_replayed := private.load_mutation_result(
    v_user_id, 'remove_guidance_media_asset_v1', p_idempotency_key, v_fingerprint
  );
  if v_replayed is not null then return v_replayed; end if;
  select * into v_draft from public.guidance_drafts
  where id = p_draft_id and user_id = v_user_id for update;
  if not found then raise exception using errcode = 'P0002', message = 'guidance_draft_not_found'; end if;
  v_state := private.ensure_media_draft_state(v_user_id, v_draft.exercise_id, p_draft_id);
  if v_state.media_revision <> p_expected_media_revision then
    raise exception using errcode = '40001', message = 'stale_guidance_media_revision',
      detail = private.media_stale_detail(null, v_draft.revision, v_state.media_revision);
  end if;
  select * into v_asset from public.guidance_media_assets
  where id = p_asset_id and guidance_draft_id = p_draft_id and user_id = v_user_id
    and state in ('pending', 'ready') for update;
  if not found then raise exception using errcode = 'P0002', message = 'guidance_media_asset_not_found'; end if;
  update public.guidance_media_assets set
    state = 'quarantined', is_cover = false, quarantined_at = clock_timestamp(),
    revision = revision + 1, updated_at = clock_timestamp()
  where id = p_asset_id;
  update private.media_upload_intents set consumed_at = coalesce(consumed_at, clock_timestamp())
  where asset_id = p_asset_id;
  v_requires_storage_delete := v_asset.source_asset_id is null and not exists (
    select 1 from public.guidance_media_assets as published
    where published.object_path = v_asset.object_path
      and published.guidance_revision_id is not null
      and published.state = 'published'
  );
  update public.guidance_media_draft_states
  set media_revision = media_revision + 1, updated_at = clock_timestamp()
  where guidance_draft_id = p_draft_id returning * into v_state;
  v_result := jsonb_build_object(
    'operation', 'remove_guidance_media_asset_v1',
    'exerciseId', v_draft.exercise_id,
    'draftId', p_draft_id,
    'assetId', p_asset_id,
    'bucketId', v_asset.bucket_id,
    'objectPath', v_asset.object_path,
    'requiresStorageDelete', v_requires_storage_delete,
    'draftRevision', v_draft.revision,
    'mediaRevision', v_state.media_revision,
    'state', 'quarantined'
  );
  return private.store_mutation_result(
    v_user_id, 'remove_guidance_media_asset_v1', p_idempotency_key, v_fingerprint, v_result
  );
end;
$$;

create or replace function public.remove_guidance_media_asset_v1(
  p_draft_id uuid, p_asset_id uuid, p_expected_media_revision bigint, p_idempotency_key uuid
)
returns jsonb language sql volatile security invoker set search_path = ''
as $$ select private.remove_guidance_media_asset_v1(
  p_draft_id, p_asset_id, p_expected_media_revision, p_idempotency_key
); $$;

create or replace function private.save_guidance_youtube_reference_v1(
  p_draft_id uuid,
  p_video_id text,
  p_canonical_watch_url text,
  p_start_seconds integer,
  p_title_snapshot text,
  p_thumbnail_url_snapshot text,
  p_preview_succeeded_at timestamptz,
  p_expected_media_revision bigint,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_video_id text := trim(p_video_id);
  v_url text := trim(p_canonical_watch_url);
  v_title text := nullif(trim(p_title_snapshot), '');
  v_thumbnail text := nullif(trim(p_thumbnail_url_snapshot), '');
  v_fingerprint text := private.sha256_jsonb(jsonb_build_array(
    p_draft_id, v_video_id, v_url, p_start_seconds, v_title, v_thumbnail,
    p_preview_succeeded_at, p_expected_media_revision
  ));
  v_replayed jsonb;
  v_draft public.guidance_drafts%rowtype;
  v_state public.guidance_media_draft_states%rowtype;
  v_reference public.guidance_youtube_references%rowtype;
  v_result jsonb;
begin
  if p_draft_id is null or v_video_id !~ '^[A-Za-z0-9_-]{11}$'
     or v_url <> 'https://www.youtube.com/watch?v=' || v_video_id
     or (p_start_seconds is not null and p_start_seconds not between 0 and 86400)
     or (v_title is not null and length(v_title) > 300)
     or (v_thumbnail is not null and v_thumbnail <> 'https://i.ytimg.com/vi/' || v_video_id || '/hqdefault.jpg')
     or (p_preview_succeeded_at is not null and (
       p_preview_succeeded_at < clock_timestamp() - interval '1 hour'
       or p_preview_succeeded_at > clock_timestamp() + interval '5 minutes'
     ))
     or p_expected_media_revision is null or p_idempotency_key is null then
    raise exception using errcode = '22023', message = 'invalid_youtube_reference';
  end if;
  v_replayed := private.load_mutation_result(
    v_user_id, 'save_guidance_youtube_reference_v1', p_idempotency_key, v_fingerprint
  );
  if v_replayed is not null then return v_replayed; end if;
  select * into v_draft from public.guidance_drafts
  where id = p_draft_id and user_id = v_user_id for update;
  if not found then raise exception using errcode = 'P0002', message = 'guidance_draft_not_found'; end if;
  v_state := private.ensure_media_draft_state(v_user_id, v_draft.exercise_id, p_draft_id);
  if v_state.media_revision <> p_expected_media_revision then
    raise exception using errcode = '40001', message = 'stale_guidance_media_revision',
      detail = private.media_stale_detail(null, v_draft.revision, v_state.media_revision);
  end if;
  insert into public.guidance_youtube_references (
    user_id, exercise_id, guidance_draft_id, video_id, canonical_watch_url,
    start_seconds, title_snapshot, thumbnail_url_snapshot, validation_status, validated_at
  ) values (
    v_user_id, v_draft.exercise_id, p_draft_id, v_video_id, v_url,
    p_start_seconds, v_title, v_thumbnail,
    case when p_preview_succeeded_at is null then 'preview_required' else 'preview_succeeded' end,
    p_preview_succeeded_at
  )
  on conflict (guidance_draft_id) where guidance_draft_id is not null do update set
    video_id = excluded.video_id,
    canonical_watch_url = excluded.canonical_watch_url,
    start_seconds = excluded.start_seconds,
    title_snapshot = excluded.title_snapshot,
    thumbnail_url_snapshot = excluded.thumbnail_url_snapshot,
    validation_status = excluded.validation_status,
    validated_at = excluded.validated_at,
    revision = public.guidance_youtube_references.revision + 1,
    updated_at = clock_timestamp()
  returning * into v_reference;
  update public.guidance_media_draft_states
  set media_revision = media_revision + 1, updated_at = clock_timestamp()
  where guidance_draft_id = p_draft_id returning * into v_state;
  v_result := jsonb_build_object(
    'operation', 'save_guidance_youtube_reference_v1',
    'exerciseId', v_draft.exercise_id,
    'draftId', p_draft_id,
    'referenceId', v_reference.id,
    'videoId', v_reference.video_id,
    'canonicalWatchUrl', v_reference.canonical_watch_url,
    'validationStatus', v_reference.validation_status,
    'draftRevision', v_draft.revision,
    'mediaRevision', v_state.media_revision
  );
  return private.store_mutation_result(
    v_user_id, 'save_guidance_youtube_reference_v1', p_idempotency_key, v_fingerprint, v_result
  );
end;
$$;

create or replace function public.save_guidance_youtube_reference_v1(
  p_draft_id uuid, p_video_id text, p_canonical_watch_url text, p_start_seconds integer,
  p_title_snapshot text, p_thumbnail_url_snapshot text, p_preview_succeeded_at timestamptz,
  p_expected_media_revision bigint, p_idempotency_key uuid
)
returns jsonb language sql volatile security invoker set search_path = ''
as $$ select private.save_guidance_youtube_reference_v1(
  p_draft_id, p_video_id, p_canonical_watch_url, p_start_seconds, p_title_snapshot,
  p_thumbnail_url_snapshot, p_preview_succeeded_at, p_expected_media_revision, p_idempotency_key
); $$;

create or replace function private.remove_guidance_youtube_reference_v1(
  p_draft_id uuid,
  p_expected_media_revision bigint,
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
    p_draft_id, p_expected_media_revision
  ));
  v_replayed jsonb;
  v_draft public.guidance_drafts%rowtype;
  v_state public.guidance_media_draft_states%rowtype;
  v_reference_id uuid;
  v_result jsonb;
begin
  if p_draft_id is null or p_expected_media_revision is null or p_idempotency_key is null then
    raise exception using errcode = '22023', message = 'invalid_remove_youtube_reference';
  end if;
  v_replayed := private.load_mutation_result(
    v_user_id, 'remove_guidance_youtube_reference_v1', p_idempotency_key, v_fingerprint
  );
  if v_replayed is not null then return v_replayed; end if;
  select * into v_draft from public.guidance_drafts
  where id = p_draft_id and user_id = v_user_id for update;
  if not found then raise exception using errcode = 'P0002', message = 'guidance_draft_not_found'; end if;
  v_state := private.ensure_media_draft_state(v_user_id, v_draft.exercise_id, p_draft_id);
  if v_state.media_revision <> p_expected_media_revision then
    raise exception using errcode = '40001', message = 'stale_guidance_media_revision',
      detail = private.media_stale_detail(null, v_draft.revision, v_state.media_revision);
  end if;
  delete from public.guidance_youtube_references
  where guidance_draft_id = p_draft_id and user_id = v_user_id
  returning id into v_reference_id;
  if v_reference_id is null then raise exception using errcode = 'P0002', message = 'youtube_reference_not_found'; end if;
  update public.guidance_media_draft_states
  set media_revision = media_revision + 1, updated_at = clock_timestamp()
  where guidance_draft_id = p_draft_id returning * into v_state;
  v_result := jsonb_build_object(
    'operation', 'remove_guidance_youtube_reference_v1',
    'exerciseId', v_draft.exercise_id,
    'draftId', p_draft_id,
    'referenceId', v_reference_id,
    'draftRevision', v_draft.revision,
    'mediaRevision', v_state.media_revision
  );
  return private.store_mutation_result(
    v_user_id, 'remove_guidance_youtube_reference_v1', p_idempotency_key, v_fingerprint, v_result
  );
end;
$$;

create or replace function public.remove_guidance_youtube_reference_v1(
  p_draft_id uuid, p_expected_media_revision bigint, p_idempotency_key uuid
)
returns jsonb language sql volatile security invoker set search_path = ''
as $$ select private.remove_guidance_youtube_reference_v1(
  p_draft_id, p_expected_media_revision, p_idempotency_key
); $$;

create or replace function private.duplicate_guidance_revision_with_media_as_draft_v1(
  p_exercise_id uuid,
  p_guidance_revision_id uuid,
  p_expected_draft_revision bigint,
  p_expected_media_revision bigint,
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
    p_exercise_id, p_guidance_revision_id,
    p_expected_draft_revision, p_expected_media_revision
  ));
  v_replayed jsonb;
  v_source public.guidance_revisions%rowtype;
  v_draft public.guidance_drafts%rowtype;
  v_state public.guidance_media_draft_states%rowtype;
  v_text_result jsonb;
  v_image_count integer;
  v_youtube_copied boolean;
  v_result jsonb;
begin
  if p_exercise_id is null or p_guidance_revision_id is null
     or p_expected_draft_revision is null or p_expected_media_revision is null
     or p_idempotency_key is null then
    raise exception using errcode = '22023', message = 'invalid_media_duplicate_request';
  end if;
  v_replayed := private.load_mutation_result(
    v_user_id, 'duplicate_guidance_revision_with_media_as_draft_v1',
    p_idempotency_key, v_fingerprint
  );
  if v_replayed is not null then return v_replayed; end if;
  select * into v_source from public.guidance_revisions
  where id = p_guidance_revision_id and exercise_id = p_exercise_id and user_id = v_user_id;
  if not found then raise exception using errcode = 'P0002', message = 'guidance_revision_not_found'; end if;
  select * into v_draft from public.guidance_drafts
  where exercise_id = p_exercise_id and user_id = v_user_id for update;
  if not found then raise exception using errcode = 'P0002', message = 'guidance_draft_not_found'; end if;
  v_state := private.ensure_media_draft_state(v_user_id, p_exercise_id, v_draft.id);
  if v_draft.revision <> p_expected_draft_revision
     or v_state.media_revision <> p_expected_media_revision then
    raise exception using errcode = '40001', message = 'stale_guidance_media_revision',
      detail = private.media_stale_detail(null, v_draft.revision, v_state.media_revision);
  end if;
  v_text_result := private.duplicate_guidance_revision_as_draft_v1(
    p_exercise_id, p_guidance_revision_id, p_expected_draft_revision, p_idempotency_key
  );
  update public.guidance_media_assets set
    state = 'quarantined', is_cover = false, quarantined_at = clock_timestamp(),
    revision = revision + 1, updated_at = clock_timestamp()
  where guidance_draft_id = v_draft.id and user_id = v_user_id and state in ('pending', 'ready');
  update private.media_upload_intents set consumed_at = coalesce(consumed_at, clock_timestamp())
  where guidance_draft_id = v_draft.id and user_id = v_user_id and consumed_at is null;
  delete from public.guidance_youtube_references
  where guidance_draft_id = v_draft.id and user_id = v_user_id;
  insert into public.guidance_media_assets (
    id, user_id, exercise_id, guidance_draft_id, source_asset_id,
    bucket_id, object_path, mime_type, byte_size, width, height, sha256_hex,
    alt_text, position, is_cover, state, revision
  )
  select
    gen_random_uuid(), v_user_id, p_exercise_id, v_draft.id, source.id,
    source.bucket_id, source.object_path, source.mime_type, source.byte_size,
    source.width, source.height, source.sha256_hex, source.alt_text,
    source.position, source.is_cover, 'ready', 1
  from public.guidance_media_assets as source
  where source.guidance_revision_id = p_guidance_revision_id
    and source.user_id = v_user_id and source.state = 'published'
  order by source.position, source.id;
  get diagnostics v_image_count = row_count;
  insert into public.guidance_youtube_references (
    user_id, exercise_id, guidance_draft_id, source_reference_id, provider,
    video_id, canonical_watch_url, start_seconds, title_snapshot,
    thumbnail_url_snapshot, validation_status, validated_at
  )
  select
    v_user_id, p_exercise_id, v_draft.id, source.id, source.provider,
    source.video_id, source.canonical_watch_url, source.start_seconds,
    source.title_snapshot, source.thumbnail_url_snapshot,
    source.validation_status, source.validated_at
  from public.guidance_youtube_references as source
  where source.guidance_revision_id = p_guidance_revision_id and source.user_id = v_user_id;
  v_youtube_copied := found;
  update public.guidance_media_draft_states
  set media_revision = media_revision + 1, updated_at = clock_timestamp()
  where guidance_draft_id = v_draft.id returning * into v_state;
  v_result := jsonb_build_object(
    'operation', 'duplicate_guidance_revision_with_media_as_draft_v1',
    'exerciseId', p_exercise_id,
    'draftId', v_draft.id,
    'sourceGuidanceRevisionId', p_guidance_revision_id,
    'draftRevision', (v_text_result ->> 'draftRevision')::bigint,
    'mediaRevision', v_state.media_revision,
    'imageCount', v_image_count,
    'youtubeCopied', v_youtube_copied,
    'reusedPublishedObjects', true
  );
  return private.store_mutation_result(
    v_user_id, 'duplicate_guidance_revision_with_media_as_draft_v1',
    p_idempotency_key, v_fingerprint, v_result
  );
end;
$$;

create or replace function public.duplicate_guidance_revision_with_media_as_draft_v1(
  p_exercise_id uuid,
  p_guidance_revision_id uuid,
  p_expected_draft_revision bigint,
  p_expected_media_revision bigint,
  p_idempotency_key uuid
)
returns jsonb language sql volatile security invoker set search_path = ''
as $$ select private.duplicate_guidance_revision_with_media_as_draft_v1(
  p_exercise_id, p_guidance_revision_id,
  p_expected_draft_revision, p_expected_media_revision, p_idempotency_key
); $$;

insert into public.guidance_media_manifests (
  guidance_revision_id, exercise_id, user_id, canonical_manifest,
  manifest_hash, bundle_hash, publication_fingerprint
)
select
  revision.id,
  revision.exercise_id,
  revision.user_id,
  canonical.value,
  private.sha256_jsonb(canonical.value),
  private.sha256_jsonb(jsonb_build_array(
    'stone-set-guidance-bundle-v1',
    revision.revision_hash,
    private.sha256_jsonb(canonical.value)
  )),
  private.sha256_jsonb(jsonb_build_array(
    'stone-set-guidance-publication-source-v1', revision.content_hash, '[]'::jsonb, null
  ))
from public.guidance_revisions as revision
cross join lateral (
  select private.media_manifest_canonical('[]'::jsonb, null) as value
) as canonical
on conflict (guidance_revision_id) do nothing;

create or replace function private.create_empty_guidance_media_manifest()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_canonical jsonb := private.media_manifest_canonical('[]'::jsonb, null);
  v_manifest_hash text;
begin
  if current_setting('stone_set.media_publication', true) = 'v1' then
    return new;
  end if;
  v_manifest_hash := private.sha256_jsonb(v_canonical);
  insert into public.guidance_media_manifests (
    guidance_revision_id, exercise_id, user_id, canonical_manifest,
    manifest_hash, bundle_hash, publication_fingerprint
  ) values (
    new.id,
    new.exercise_id,
    new.user_id,
    v_canonical,
    v_manifest_hash,
    private.sha256_jsonb(jsonb_build_array(
      'stone-set-guidance-bundle-v1', new.revision_hash, v_manifest_hash
    )),
    private.sha256_jsonb(jsonb_build_array(
      'stone-set-guidance-publication-source-v1', new.content_hash, '[]'::jsonb, null
    ))
  );
  return new;
end;
$$;

create trigger guidance_revisions_empty_media_manifest
after insert on public.guidance_revisions
for each row execute function private.create_empty_guidance_media_manifest();

create or replace function private.begin_guidance_media_publication_v1(
  p_exercise_id uuid,
  p_draft_id uuid,
  p_expected_exercise_revision bigint,
  p_expected_draft_revision bigint,
  p_expected_media_revision bigint,
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
    p_exercise_id, p_draft_id, p_expected_exercise_revision,
    p_expected_draft_revision, p_expected_media_revision
  ));
  v_replayed jsonb;
  v_exercise public.exercise_definitions%rowtype;
  v_draft public.guidance_drafts%rowtype;
  v_state public.guidance_media_draft_states%rowtype;
  v_previous public.guidance_revisions%rowtype;
  v_existing public.guidance_revisions%rowtype;
  v_existing_manifest public.guidance_media_manifests%rowtype;
  v_youtube public.guidance_youtube_references%rowtype;
  v_content jsonb;
  v_equipment jsonb;
  v_primary_muscles jsonb;
  v_secondary_muscles jsonb;
  v_content_hash text;
  v_semantic_images jsonb;
  v_semantic_youtube jsonb;
  v_publication_fingerprint text;
  v_revision_id uuid := gen_random_uuid();
  v_version_number bigint;
  v_revision_hash text;
  v_manifest_images jsonb;
  v_manifest_youtube jsonb;
  v_canonical_manifest jsonb;
  v_manifest_hash text;
  v_bundle_hash text;
  v_reservation_id uuid := gen_random_uuid();
  v_expires_at timestamptz := clock_timestamp() + interval '15 minutes';
  v_copies jsonb;
  v_result jsonb;
begin
  if p_exercise_id is null or p_draft_id is null
     or p_expected_exercise_revision is null or p_expected_draft_revision is null
     or p_expected_media_revision is null or p_idempotency_key is null then
    raise exception using errcode = '22023', message = 'invalid_media_publication_request';
  end if;
  v_replayed := private.load_mutation_result(
    v_user_id, 'begin_guidance_media_publication_v1', p_idempotency_key, v_fingerprint
  );
  if v_replayed is not null then return v_replayed; end if;
  select * into v_exercise from public.exercise_definitions
  where id = p_exercise_id and user_id = v_user_id for update;
  if not found then raise exception using errcode = 'P0002', message = 'exercise_not_found'; end if;
  select * into v_draft from public.guidance_drafts
  where id = p_draft_id and exercise_id = p_exercise_id and user_id = v_user_id for update;
  if not found then raise exception using errcode = 'P0002', message = 'guidance_draft_not_found'; end if;
  v_state := private.ensure_media_draft_state(v_user_id, p_exercise_id, p_draft_id);
  if v_exercise.revision <> p_expected_exercise_revision
     or v_draft.revision <> p_expected_draft_revision
     or v_state.media_revision <> p_expected_media_revision then
    raise exception using errcode = '40001', message = 'stale_guidance_media_revision',
      detail = private.media_stale_detail(v_exercise.revision, v_draft.revision, v_state.media_revision);
  end if;
  if v_exercise.archived_at is not null then
    raise exception using errcode = '55000', message = 'archived_exercise_cannot_publish';
  end if;
  if exists (select 1 from public.guidance_media_assets
             where guidance_draft_id = p_draft_id and state = 'pending') then
    raise exception using errcode = '55000', message = 'guidance_media_upload_pending';
  end if;
  if (select count(*) from public.guidance_media_assets
      where guidance_draft_id = p_draft_id and state = 'ready') > 6
     or ((select count(*) from public.guidance_media_assets
          where guidance_draft_id = p_draft_id and state = 'ready') > 0
         and (select count(*) from public.guidance_media_assets
              where guidance_draft_id = p_draft_id and state = 'ready' and is_cover) <> 1)
     or exists (select 1 from public.guidance_media_assets
                where guidance_draft_id = p_draft_id and state = 'ready'
                  and length(trim(alt_text)) not between 1 and 500) then
    raise exception using errcode = '23514', message = 'guidance_media_not_publishable';
  end if;
  select * into v_youtube from public.guidance_youtube_references
  where guidance_draft_id = p_draft_id and user_id = v_user_id;
  if found and (v_youtube.validation_status <> 'preview_succeeded'
                or v_youtube.validated_at < clock_timestamp() - interval '1 hour') then
    raise exception using errcode = '55000', message = 'youtube_preview_required';
  end if;

  v_content := private.normalize_guidance_content(v_draft.structured_content, true);
  select coalesce(jsonb_agg(equipment_key order by position), '[]'::jsonb)
  into v_equipment from public.exercise_definition_equipment where exercise_id = p_exercise_id;
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
  v_content_hash := private.sha256_jsonb(jsonb_build_array(
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
  ));
  select coalesce(jsonb_agg(jsonb_build_array(
    asset.mime_type, asset.byte_size, asset.width, asset.height,
    asset.sha256_hex, trim(asset.alt_text), asset.position, asset.is_cover
  ) order by asset.position, asset.id), '[]'::jsonb)
  into v_semantic_images from public.guidance_media_assets as asset
  where asset.guidance_draft_id = p_draft_id and asset.user_id = v_user_id and asset.state = 'ready';
  v_semantic_youtube := case when v_youtube.id is null then null else jsonb_build_array(
    'youtube', v_youtube.video_id, v_youtube.canonical_watch_url, v_youtube.start_seconds,
    v_youtube.title_snapshot, v_youtube.thumbnail_url_snapshot
  ) end;
  v_publication_fingerprint := private.sha256_jsonb(jsonb_build_array(
    'stone-set-guidance-publication-source-v1', v_content_hash, v_semantic_images, v_semantic_youtube
  ));
  select revision.* into v_existing
  from public.guidance_revisions as revision
  join public.guidance_media_manifests as manifest on manifest.guidance_revision_id = revision.id
  where revision.exercise_id = p_exercise_id and revision.user_id = v_user_id
    and manifest.publication_fingerprint = v_publication_fingerprint
  order by revision.version_number desc limit 1;
  if v_existing.id is not null then
    select * into v_existing_manifest from public.guidance_media_manifests
    where guidance_revision_id = v_existing.id and user_id = v_user_id;
    insert into private.media_publication_reservations (
      id, user_id, exercise_id, guidance_draft_id, guidance_revision_id,
      expected_exercise_revision, expected_draft_revision, expected_media_revision,
      version_number, supersedes_revision_id, normalized_content, content_hash, revision_hash,
      canonical_manifest, manifest_hash, bundle_hash, publication_fingerprint,
      state, existing_guidance_revision_id, expires_at
    ) values (
      v_reservation_id, v_user_id, p_exercise_id, p_draft_id, v_existing.id,
      p_expected_exercise_revision, p_expected_draft_revision, p_expected_media_revision,
      v_existing.version_number, v_existing.supersedes_revision_id, v_existing.structured_content,
      v_existing.content_hash, v_existing.revision_hash, v_existing_manifest.canonical_manifest,
      v_existing_manifest.manifest_hash, v_existing_manifest.bundle_hash,
      v_publication_fingerprint, 'no_change', v_existing.id, v_expires_at
    );
    v_result := jsonb_build_object(
      'operation', 'begin_guidance_media_publication_v1',
      'reservationId', v_reservation_id,
      'exerciseId', p_exercise_id,
      'draftId', p_draft_id,
      'guidanceRevisionId', v_existing.id,
      'expiresAt', v_expires_at,
      'copies', '[]'::jsonb,
      'contentHash', v_existing.content_hash,
      'revisionHash', v_existing.revision_hash,
      'manifestHash', v_existing_manifest.manifest_hash,
      'bundleHash', v_existing_manifest.bundle_hash,
      'exerciseRevision', v_exercise.revision,
      'draftRevision', v_draft.revision,
      'mediaRevision', v_state.media_revision,
      'noChange', true
    );
    return private.store_mutation_result(
      v_user_id, 'begin_guidance_media_publication_v1', p_idempotency_key, v_fingerprint, v_result
    );
  end if;

  update private.media_publication_reservations set state = 'expired'
  where user_id = v_user_id and guidance_draft_id = p_draft_id
    and state = 'pending' and expires_at <= clock_timestamp();
  if exists (select 1 from private.media_publication_reservations
             where user_id = v_user_id and guidance_draft_id = p_draft_id
               and state = 'pending' and expires_at > clock_timestamp()) then
    raise exception using errcode = '55000', message = 'media_publication_already_reserved';
  end if;
  select * into v_previous from public.guidance_revisions
  where exercise_id = p_exercise_id order by version_number desc limit 1 for update;
  v_version_number := coalesce(v_previous.version_number, 0) + 1;
  v_revision_hash := private.sha256_jsonb(jsonb_build_array(
    'stone-set-guidance-revision-v1', p_exercise_id::text, v_user_id::text,
    v_version_number, v_content_hash,
    case when v_previous.id is null then null else to_jsonb(v_previous.id::text) end
  ));
  insert into private.media_publication_reservations (
    id, user_id, exercise_id, guidance_draft_id, guidance_revision_id,
    expected_exercise_revision, expected_draft_revision, expected_media_revision,
    version_number, supersedes_revision_id, normalized_content, content_hash, revision_hash,
    canonical_manifest, manifest_hash, bundle_hash, publication_fingerprint, expires_at
  ) values (
    v_reservation_id, v_user_id, p_exercise_id, p_draft_id, v_revision_id,
    p_expected_exercise_revision, p_expected_draft_revision, p_expected_media_revision,
    v_version_number, v_previous.id, v_content, v_content_hash, v_revision_hash,
    '[]'::jsonb, repeat('0', 64), repeat('0', 64), v_publication_fingerprint, v_expires_at
  );
  insert into private.media_publication_reservation_assets (
    reservation_id, user_id, source_asset_id, published_asset_id,
    source_object_path, destination_object_path, position
  )
  select
    v_reservation_id, v_user_id, asset.id, generated.published_asset_id, asset.object_path,
    v_user_id::text || '/' || p_exercise_id::text || '/revisions/' || v_revision_id::text || '/' ||
      generated.published_asset_id::text || '.' || case asset.mime_type
        when 'image/jpeg' then 'jpg' when 'image/png' then 'png' else 'webp' end,
    asset.position
  from public.guidance_media_assets as asset
  cross join lateral (
    select gen_random_uuid() as published_asset_id where asset.id is not null
  ) as generated
  where asset.guidance_draft_id = p_draft_id and asset.user_id = v_user_id and asset.state = 'ready'
  order by asset.position, asset.id;
  select coalesce(jsonb_agg(jsonb_build_array(
    item.published_asset_id::text, 'exercise-media', item.destination_object_path,
    asset.mime_type, asset.byte_size, asset.width, asset.height, asset.sha256_hex,
    trim(asset.alt_text), asset.position, asset.is_cover
  ) order by asset.position, asset.id), '[]'::jsonb)
  into v_manifest_images
  from private.media_publication_reservation_assets as item
  join public.guidance_media_assets as asset
    on asset.id = item.source_asset_id and asset.user_id = item.user_id
  where item.reservation_id = v_reservation_id;
  v_manifest_youtube := case when v_youtube.id is null then null else jsonb_build_array(
    'youtube', v_youtube.video_id, v_youtube.canonical_watch_url, v_youtube.start_seconds,
    v_youtube.title_snapshot, v_youtube.thumbnail_url_snapshot,
    to_char(
      v_youtube.validated_at at time zone 'UTC',
      'YYYY-MM-DD"T"HH24:MI:SS.US"Z"'
    )
  ) end;
  v_canonical_manifest := private.media_manifest_canonical(v_manifest_images, v_manifest_youtube);
  v_manifest_hash := private.sha256_jsonb(v_canonical_manifest);
  v_bundle_hash := private.sha256_jsonb(jsonb_build_array(
    'stone-set-guidance-bundle-v1', v_revision_hash, v_manifest_hash
  ));
  update private.media_publication_reservations set
    canonical_manifest = v_canonical_manifest,
    manifest_hash = v_manifest_hash,
    bundle_hash = v_bundle_hash
  where id = v_reservation_id;
  select coalesce(jsonb_agg(jsonb_build_object(
    'assetId', item.source_asset_id,
    'sourcePath', item.source_object_path,
    'destinationPath', item.destination_object_path
  ) order by item.position), '[]'::jsonb)
  into v_copies from private.media_publication_reservation_assets as item
  where item.reservation_id = v_reservation_id;
  v_result := jsonb_build_object(
    'operation', 'begin_guidance_media_publication_v1',
    'reservationId', v_reservation_id,
    'exerciseId', p_exercise_id,
    'draftId', p_draft_id,
    'guidanceRevisionId', v_revision_id,
    'expiresAt', v_expires_at,
    'copies', v_copies,
    'contentHash', v_content_hash,
    'revisionHash', v_revision_hash,
    'manifestHash', v_manifest_hash,
    'bundleHash', v_bundle_hash,
    'exerciseRevision', v_exercise.revision,
    'draftRevision', v_draft.revision,
    'mediaRevision', v_state.media_revision,
    'noChange', false
  );
  return private.store_mutation_result(
    v_user_id, 'begin_guidance_media_publication_v1', p_idempotency_key, v_fingerprint, v_result
  );
end;
$$;

create or replace function public.begin_guidance_media_publication_v1(
  p_exercise_id uuid, p_draft_id uuid, p_expected_exercise_revision bigint,
  p_expected_draft_revision bigint, p_expected_media_revision bigint, p_idempotency_key uuid
)
returns jsonb language sql volatile security invoker set search_path = ''
as $$ select private.begin_guidance_media_publication_v1(
  p_exercise_id, p_draft_id, p_expected_exercise_revision,
  p_expected_draft_revision, p_expected_media_revision, p_idempotency_key
); $$;

create or replace function private.finalize_guidance_media_publication_v1(
  p_reservation_id uuid,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := private.require_product_actor();
  v_fingerprint text := private.sha256_jsonb(jsonb_build_array(p_reservation_id));
  v_replayed jsonb;
  v_reservation private.media_publication_reservations%rowtype;
  v_exercise public.exercise_definitions%rowtype;
  v_draft public.guidance_drafts%rowtype;
  v_state public.guidance_media_draft_states%rowtype;
  v_revision public.guidance_revisions%rowtype;
  v_equipment jsonb;
  v_expected_objects integer;
  v_verified_objects integer;
  v_result jsonb;
begin
  if p_reservation_id is null or p_idempotency_key is null then
    raise exception using errcode = '22023', message = 'invalid_media_publication_finalize';
  end if;
  v_replayed := private.load_mutation_result(
    v_user_id, 'finalize_guidance_media_publication_v1', p_idempotency_key, v_fingerprint
  );
  if v_replayed is not null then return v_replayed; end if;
  select * into v_reservation from private.media_publication_reservations
  where id = p_reservation_id and user_id = v_user_id for update;
  if not found then raise exception using errcode = 'P0002', message = 'media_publication_reservation_not_found'; end if;
  if v_reservation.state = 'completed' then
    raise exception using errcode = '55000', message = 'media_publication_already_completed';
  end if;
  if v_reservation.expires_at <= clock_timestamp() or v_reservation.state = 'expired' then
    update private.media_publication_reservations set state = 'expired'
    where id = p_reservation_id and state = 'pending';
    raise exception using errcode = '55000', message = 'media_publication_reservation_expired';
  end if;
  if v_reservation.state = 'no_change' then
    select * into v_revision from public.guidance_revisions
    where id = v_reservation.existing_guidance_revision_id and user_id = v_user_id;
    if not found then raise exception using errcode = '55000', message = 'media_publication_history_missing'; end if;
    update private.media_publication_reservations
    set state = 'completed', completed_at = clock_timestamp() where id = p_reservation_id;
    v_result := jsonb_build_object(
      'operation', 'finalize_guidance_media_publication_v1',
      'reservationId', p_reservation_id,
      'exerciseId', v_revision.exercise_id,
      'guidanceRevisionId', v_revision.id,
      'versionNumber', v_revision.version_number,
      'contentHash', v_revision.content_hash,
      'revisionHash', v_revision.revision_hash,
      'manifestHash', v_reservation.manifest_hash,
      'bundleHash', v_reservation.bundle_hash,
      'draftRevision', v_reservation.expected_draft_revision,
      'mediaRevision', v_reservation.expected_media_revision,
      'noChange', true
    );
    return private.store_mutation_result(
      v_user_id, 'finalize_guidance_media_publication_v1', p_idempotency_key, v_fingerprint, v_result
    );
  end if;
  if v_reservation.state <> 'pending' then
    raise exception using errcode = '55000', message = 'media_publication_reservation_invalid_state';
  end if;
  select * into v_exercise from public.exercise_definitions
  where id = v_reservation.exercise_id and user_id = v_user_id for update;
  if not found then raise exception using errcode = 'P0002', message = 'exercise_not_found'; end if;
  select * into v_draft from public.guidance_drafts
  where id = v_reservation.guidance_draft_id and exercise_id = v_reservation.exercise_id
    and user_id = v_user_id for update;
  if not found then raise exception using errcode = 'P0002', message = 'guidance_draft_not_found'; end if;
  v_state := private.ensure_media_draft_state(
    v_user_id, v_reservation.exercise_id, v_reservation.guidance_draft_id
  );
  if v_exercise.revision <> v_reservation.expected_exercise_revision
     or v_draft.revision <> v_reservation.expected_draft_revision
     or v_state.media_revision <> v_reservation.expected_media_revision then
    raise exception using errcode = '40001', message = 'stale_guidance_media_revision',
      detail = private.media_stale_detail(v_exercise.revision, v_draft.revision, v_state.media_revision);
  end if;
  if exists (
    select 1 from public.guidance_revisions
    where exercise_id = v_reservation.exercise_id
      and version_number >= v_reservation.version_number
  ) then
    raise exception using errcode = '40001', message = 'stale_guidance_publication_history',
      detail = private.media_stale_detail(v_exercise.revision, v_draft.revision, v_state.media_revision);
  end if;
  select count(*) into v_expected_objects
  from private.media_publication_reservation_assets
  where reservation_id = p_reservation_id;
  select count(*) into v_verified_objects
  from private.media_publication_reservation_assets as item
  join public.guidance_media_assets as source
    on source.id = item.source_asset_id and source.user_id = item.user_id
  join storage.objects as object
    on object.bucket_id = 'exercise-media'
   and object.name = item.destination_object_path
   and object.owner_id = v_user_id::text
  where item.reservation_id = p_reservation_id
    and source.guidance_draft_id = v_reservation.guidance_draft_id
    and source.state = 'ready'
    and coalesce((object.metadata ->> 'size')::bigint, -1) = source.byte_size
    and coalesce(object.metadata ->> 'mimetype', '') = source.mime_type;
  if v_verified_objects <> v_expected_objects then
    raise exception using errcode = '55000', message = 'media_publication_objects_incomplete';
  end if;
  select coalesce(jsonb_agg(equipment_key order by position), '[]'::jsonb)
  into v_equipment from public.exercise_definition_equipment
  where exercise_id = v_reservation.exercise_id;
  perform set_config('stone_set.media_publication', 'v1', true);
  insert into public.guidance_revisions (
    id, exercise_id, user_id, version_number, structured_content_schema_version,
    structured_content, canonical_name_snapshot, normalized_name_snapshot,
    variant_key_snapshot, equipment_keys_snapshot, content_hash, revision_hash,
    supersedes_revision_id
  ) values (
    v_reservation.guidance_revision_id, v_reservation.exercise_id, v_user_id,
    v_reservation.version_number, 1, v_reservation.normalized_content,
    v_exercise.canonical_name, v_exercise.normalized_name, v_exercise.variant_key,
    v_equipment, v_reservation.content_hash, v_reservation.revision_hash,
    v_reservation.supersedes_revision_id
  ) returning * into v_revision;
  insert into public.guidance_revision_muscles (
    guidance_revision_id, user_id, muscle_id, muscle_key_snapshot, role, position
  )
  select v_revision.id, v_user_id, assignment.muscle_id, muscle.stable_key,
    assignment.role, assignment.position
  from public.exercise_definition_muscles as assignment
  join public.muscles as muscle on muscle.id = assignment.muscle_id
  where assignment.exercise_id = v_reservation.exercise_id
  order by assignment.role, assignment.position;
  insert into public.guidance_media_assets (
    id, user_id, exercise_id, guidance_revision_id, source_asset_id,
    bucket_id, object_path, mime_type, byte_size, width, height, sha256_hex,
    alt_text, position, is_cover, state, revision, published_at
  )
  select
    item.published_asset_id, v_user_id, v_reservation.exercise_id,
    v_revision.id, source.id, source.bucket_id, item.destination_object_path,
    source.mime_type, source.byte_size, source.width, source.height, source.sha256_hex,
    source.alt_text, source.position, source.is_cover, 'published', 1, clock_timestamp()
  from private.media_publication_reservation_assets as item
  join public.guidance_media_assets as source
    on source.id = item.source_asset_id and source.user_id = item.user_id
  where item.reservation_id = p_reservation_id
  order by source.position, source.id;
  insert into public.guidance_youtube_references (
    user_id, exercise_id, guidance_revision_id, source_reference_id, provider,
    video_id, canonical_watch_url, start_seconds, title_snapshot,
    thumbnail_url_snapshot, validation_status, validated_at, published_at
  )
  select
    v_user_id, v_reservation.exercise_id, v_revision.id, source.id, source.provider,
    source.video_id, source.canonical_watch_url, source.start_seconds, source.title_snapshot,
    source.thumbnail_url_snapshot, source.validation_status, source.validated_at, clock_timestamp()
  from public.guidance_youtube_references as source
  where source.guidance_draft_id = v_reservation.guidance_draft_id
    and source.user_id = v_user_id;
  insert into public.guidance_media_manifests (
    guidance_revision_id, exercise_id, user_id, canonical_manifest,
    manifest_hash, bundle_hash, publication_fingerprint
  ) values (
    v_revision.id, v_revision.exercise_id, v_user_id, v_reservation.canonical_manifest,
    v_reservation.manifest_hash, v_reservation.bundle_hash,
    v_reservation.publication_fingerprint
  );
  update public.guidance_drafts set
    base_guidance_revision_id = v_revision.id,
    structured_content = v_reservation.normalized_content
  where id = v_reservation.guidance_draft_id returning * into v_draft;
  update private.media_publication_reservations
  set state = 'completed', completed_at = clock_timestamp() where id = p_reservation_id;
  v_result := jsonb_build_object(
    'operation', 'finalize_guidance_media_publication_v1',
    'reservationId', p_reservation_id,
    'exerciseId', v_revision.exercise_id,
    'guidanceRevisionId', v_revision.id,
    'versionNumber', v_revision.version_number,
    'contentHash', v_revision.content_hash,
    'revisionHash', v_revision.revision_hash,
    'manifestHash', v_reservation.manifest_hash,
    'bundleHash', v_reservation.bundle_hash,
    'draftRevision', v_draft.revision,
    'mediaRevision', v_state.media_revision,
    'noChange', false
  );
  return private.store_mutation_result(
    v_user_id, 'finalize_guidance_media_publication_v1', p_idempotency_key, v_fingerprint, v_result
  );
end;
$$;

create or replace function public.finalize_guidance_media_publication_v1(
  p_reservation_id uuid, p_idempotency_key uuid
)
returns jsonb language sql volatile security invoker set search_path = ''
as $$ select private.finalize_guidance_media_publication_v1(
  p_reservation_id, p_idempotency_key
); $$;

create or replace function private.claim_expired_guidance_media_cleanup_v1(p_limit integer)
returns table (bucket_id text, object_path text, asset_id uuid, user_id uuid)
language plpgsql
security definer
set search_path = ''
as $$
begin
  if p_limit is null or p_limit not between 1 and 100 then
    raise exception using errcode = '22023', message = 'invalid_media_cleanup_limit';
  end if;
  return query
  with candidates as (
    select asset.id
    from public.guidance_media_assets as asset
    left join private.media_upload_intents as intent on intent.asset_id = asset.id
    where asset.guidance_draft_id is not null
      and asset.state = 'pending'
      and coalesce(intent.expires_at, asset.created_at + interval '24 hours') <= clock_timestamp()
      and not exists (
        select 1 from public.guidance_media_assets as published
        where published.object_path = asset.object_path
          and published.guidance_revision_id is not null
          and published.state = 'published'
      )
    order by asset.created_at, asset.id
    limit p_limit
    for update of asset skip locked
  ), quarantined as (
    update public.guidance_media_assets as asset set
      state = 'quarantined', is_cover = false, quarantined_at = clock_timestamp(),
      revision = revision + 1, updated_at = clock_timestamp()
    from candidates
    where asset.id = candidates.id
    returning asset.bucket_id, asset.object_path, asset.id, asset.user_id
  )
  select quarantined.bucket_id, quarantined.object_path, quarantined.id, quarantined.user_id
  from quarantined;
end;
$$;

create or replace function private.claim_expired_media_publication_copies_v1(p_limit integer)
returns table (bucket_id text, object_path text, asset_id uuid, user_id uuid)
language plpgsql
security definer
set search_path = ''
as $$
begin
  if p_limit is null or p_limit not between 1 and 100 then
    raise exception using errcode = '22023', message = 'invalid_media_cleanup_limit';
  end if;
  return query
  with candidates as (
    select reservation.id
    from private.media_publication_reservations as reservation
    where reservation.state = 'pending'
      and reservation.expires_at <= clock_timestamp()
    order by reservation.expires_at, reservation.id
    limit p_limit
    for update skip locked
  ), expired as (
    update private.media_publication_reservations as reservation
    set state = 'expired'
    from candidates
    where reservation.id = candidates.id
    returning reservation.id
  )
  select
    'exercise-media'::text,
    item.destination_object_path,
    item.published_asset_id,
    item.user_id
  from expired
  join private.media_publication_reservation_assets as item
    on item.reservation_id = expired.id
  where not exists (
    select 1 from public.guidance_media_assets as published
    where published.object_path = item.destination_object_path
      and published.guidance_revision_id is not null
      and published.state = 'published'
  )
  order by item.destination_object_path;
end;
$$;

alter table public.guidance_media_draft_states enable row level security;
alter table public.guidance_media_assets enable row level security;
alter table public.guidance_youtube_references enable row level security;
alter table public.guidance_media_manifests enable row level security;
alter table private.media_upload_intents enable row level security;
alter table private.media_publication_reservations enable row level security;
alter table private.media_publication_reservation_assets enable row level security;

create policy guidance_media_draft_states_select_own
on public.guidance_media_draft_states
for select to authenticated
using (
  (select auth.uid()) = user_id
  and (select private.current_session_is_authorized(true, false))
);

create policy guidance_media_assets_select_own
on public.guidance_media_assets
for select to authenticated
using (
  (select auth.uid()) = user_id
  and (select private.current_session_is_authorized(true, false))
);

create policy guidance_youtube_references_select_own
on public.guidance_youtube_references
for select to authenticated
using (
  (select auth.uid()) = user_id
  and (select private.current_session_is_authorized(true, false))
);

create policy guidance_media_manifests_select_own
on public.guidance_media_manifests
for select to authenticated
using (
  (select auth.uid()) = user_id
  and (select private.current_session_is_authorized(true, false))
);

create policy exercise_media_objects_insert_own_intent
on storage.objects
for insert to authenticated
with check (
  (select private.can_insert_exercise_media_object(bucket_id, name, owner_id))
);

create policy exercise_media_objects_select_own_manifest
on storage.objects
for select to authenticated
using (
  storage.allow_any_operation(array[
    'storage.object.get_authenticated',
    'object.get_authenticated_info',
    'object.head_authenticated_info',
    'storage.object.sign',
    'storage.object.sign_many',
    'storage.object.copy'
  ])
  and (select private.can_select_exercise_media_object(bucket_id, name, owner_id))
);

create policy exercise_media_objects_delete_quarantined
on storage.objects
for delete to authenticated
using (
  (select private.can_delete_exercise_media_object(bucket_id, name, owner_id))
);

grant select on table public.guidance_media_draft_states to authenticated;
grant select on table public.guidance_media_assets to authenticated;
grant select on table public.guidance_youtube_references to authenticated;
grant select on table public.guidance_media_manifests to authenticated;

revoke all on function public.get_guidance_draft_media_manifest_v1(uuid, uuid)
  from public, anon, authenticated, service_role;
revoke all on function public.get_guidance_revision_media_manifest_v1(uuid, uuid)
  from public, anon, authenticated, service_role;
revoke all on function public.create_guidance_media_upload_intent_v1(uuid, uuid, text, text, bigint, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function public.finalize_guidance_media_upload_v1(uuid, bigint, integer, integer, text, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function public.save_guidance_media_layout_v1(uuid, jsonb, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function public.remove_guidance_media_asset_v1(uuid, uuid, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function public.save_guidance_youtube_reference_v1(uuid, text, text, integer, text, text, timestamptz, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function public.remove_guidance_youtube_reference_v1(uuid, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function public.duplicate_guidance_revision_with_media_as_draft_v1(uuid, uuid, bigint, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function public.begin_guidance_media_publication_v1(uuid, uuid, bigint, bigint, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function public.finalize_guidance_media_publication_v1(uuid, uuid)
  from public, anon, authenticated, service_role;

revoke all on function private.reject_published_media_change()
  from public, anon, authenticated, service_role;
revoke all on function private.assert_draft_media_layout()
  from public, anon, authenticated, service_role;
revoke all on function private.ensure_media_draft_state(uuid, uuid, uuid)
  from public, anon, authenticated, service_role;
revoke all on function private.media_stale_detail(bigint, bigint, bigint)
  from public, anon, authenticated, service_role;
revoke all on function private.media_manifest_canonical(jsonb, jsonb)
  from public, anon, authenticated, service_role;
revoke all on function private.can_insert_exercise_media_object(text, text, text)
  from public, anon, authenticated, service_role;
revoke all on function private.can_select_exercise_media_object(text, text, text)
  from public, anon, authenticated, service_role;
revoke all on function private.can_delete_exercise_media_object(text, text, text)
  from public, anon, authenticated, service_role;
revoke all on function private.get_guidance_draft_media_manifest_v1(uuid, uuid)
  from public, anon, authenticated, service_role;
revoke all on function private.get_guidance_revision_media_manifest_v1(uuid, uuid)
  from public, anon, authenticated, service_role;
revoke all on function private.create_guidance_media_upload_intent_v1(uuid, uuid, text, text, bigint, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function private.finalize_guidance_media_upload_v1(uuid, bigint, integer, integer, text, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function private.save_guidance_media_layout_v1(uuid, jsonb, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function private.remove_guidance_media_asset_v1(uuid, uuid, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function private.save_guidance_youtube_reference_v1(uuid, text, text, integer, text, text, timestamptz, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function private.remove_guidance_youtube_reference_v1(uuid, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function private.duplicate_guidance_revision_with_media_as_draft_v1(uuid, uuid, bigint, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function private.create_empty_guidance_media_manifest()
  from public, anon, authenticated, service_role;
revoke all on function private.begin_guidance_media_publication_v1(uuid, uuid, bigint, bigint, bigint, uuid)
  from public, anon, authenticated, service_role;
revoke all on function private.finalize_guidance_media_publication_v1(uuid, uuid)
  from public, anon, authenticated, service_role;
revoke all on function private.claim_expired_guidance_media_cleanup_v1(integer)
  from public, anon, authenticated, service_role;
revoke all on function private.claim_expired_media_publication_copies_v1(integer)
  from public, anon, authenticated, service_role;

grant execute on function private.can_insert_exercise_media_object(text, text, text)
  to authenticated;
grant execute on function private.can_select_exercise_media_object(text, text, text)
  to authenticated;
grant execute on function private.can_delete_exercise_media_object(text, text, text)
  to authenticated;
grant execute on function private.get_guidance_draft_media_manifest_v1(uuid, uuid)
  to authenticated;
grant execute on function private.get_guidance_revision_media_manifest_v1(uuid, uuid)
  to authenticated;
grant execute on function private.create_guidance_media_upload_intent_v1(uuid, uuid, text, text, bigint, bigint, uuid)
  to authenticated;
grant execute on function private.finalize_guidance_media_upload_v1(uuid, bigint, integer, integer, text, bigint, uuid)
  to authenticated;
grant execute on function private.save_guidance_media_layout_v1(uuid, jsonb, bigint, uuid)
  to authenticated;
grant execute on function private.remove_guidance_media_asset_v1(uuid, uuid, bigint, uuid)
  to authenticated;
grant execute on function private.save_guidance_youtube_reference_v1(uuid, text, text, integer, text, text, timestamptz, bigint, uuid)
  to authenticated;
grant execute on function private.remove_guidance_youtube_reference_v1(uuid, bigint, uuid)
  to authenticated;
grant execute on function private.duplicate_guidance_revision_with_media_as_draft_v1(uuid, uuid, bigint, bigint, uuid)
  to authenticated;
grant execute on function private.begin_guidance_media_publication_v1(uuid, uuid, bigint, bigint, bigint, uuid)
  to authenticated;
grant execute on function private.finalize_guidance_media_publication_v1(uuid, uuid)
  to authenticated;
grant execute on function private.claim_expired_guidance_media_cleanup_v1(integer)
  to service_role;
grant execute on function private.claim_expired_media_publication_copies_v1(integer)
  to service_role;

grant execute on function public.get_guidance_draft_media_manifest_v1(uuid, uuid)
  to authenticated;
grant execute on function public.get_guidance_revision_media_manifest_v1(uuid, uuid)
  to authenticated;
grant execute on function public.create_guidance_media_upload_intent_v1(uuid, uuid, text, text, bigint, bigint, uuid)
  to authenticated;
grant execute on function public.finalize_guidance_media_upload_v1(uuid, bigint, integer, integer, text, bigint, uuid)
  to authenticated;
grant execute on function public.save_guidance_media_layout_v1(uuid, jsonb, bigint, uuid)
  to authenticated;
grant execute on function public.remove_guidance_media_asset_v1(uuid, uuid, bigint, uuid)
  to authenticated;
grant execute on function public.save_guidance_youtube_reference_v1(uuid, text, text, integer, text, text, timestamptz, bigint, uuid)
  to authenticated;
grant execute on function public.remove_guidance_youtube_reference_v1(uuid, bigint, uuid)
  to authenticated;
grant execute on function public.duplicate_guidance_revision_with_media_as_draft_v1(uuid, uuid, bigint, bigint, uuid)
  to authenticated;
grant execute on function public.begin_guidance_media_publication_v1(uuid, uuid, bigint, bigint, bigint, uuid)
  to authenticated;
grant execute on function public.finalize_guidance_media_publication_v1(uuid, uuid)
  to authenticated;

comment on table public.guidance_media_assets is
  'Owner-scoped immutable Storage object metadata. Client hashes/dimensions are reconciliation evidence, not server byte inspection or authorization evidence.';
comment on table public.guidance_media_manifests is
  'Versioned guidance-media-manifest-v1 and guidance-bundle-v1 hashes; preserves the original 003A content and revision hashes.';
comment on table private.media_publication_reservations is
  'Short-lived two-phase reservation binding exact Storage copy destinations to a later transactional publication finalization.';
comment on column public.guidance_youtube_references.validated_at is
  'Recent client-reported successful official-player preview evidence; not server-attested video availability and not an authorization input.';

commit;
