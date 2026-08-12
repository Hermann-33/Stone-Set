begin;

create or replace function private.resolve_latest_workout_guidance_revision_v1()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
declare
  v_latest_guidance_revision_id uuid;
begin
  select revision.id
  into v_latest_guidance_revision_id
  from public.guidance_revisions as revision
  join public.guidance_media_manifests as manifest
    on manifest.guidance_revision_id = revision.id
   and manifest.exercise_id = revision.exercise_id
   and manifest.user_id = revision.user_id
  where revision.exercise_id = new.exercise_definition_id
    and revision.user_id = new.user_id
  order by revision.version_number desc, revision.id desc
  limit 1;

  if v_latest_guidance_revision_id is not null then
    new.guidance_revision_id := v_latest_guidance_revision_id;
  end if;

  return new;
end;
$$;

revoke all on function private.resolve_latest_workout_guidance_revision_v1()
  from public, anon, authenticated, service_role;

create trigger workout_session_exercises_latest_guidance_before_insert
before insert on public.workout_session_exercises
for each row
execute function private.resolve_latest_workout_guidance_revision_v1();

comment on function private.resolve_latest_workout_guidance_revision_v1() is
  'Resolves the newest owner-matching finalized guidance/media bundle when a new workout-session exercise snapshot is created, while preserving the supplied routine revision as fallback.';

comment on trigger workout_session_exercises_latest_guidance_before_insert on public.workout_session_exercises is
  'New workout sessions use the latest finalized published guidance bundle; existing workout-session snapshots are never rewritten.';

commit;
