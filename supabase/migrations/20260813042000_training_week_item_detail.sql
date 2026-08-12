begin;

create or replace function public.get_training_week_item_detail_v1(
  p_week_item_id uuid
)
returns jsonb
language sql
stable
security invoker
set search_path = ''
as $$
  select jsonb_build_object(
    'id', item.id,
    'assigned_date', item.assigned_date,
    'item_type', item.item_type,
    'title', day.title,
    'purpose', day.purpose,
    'exercises', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'id', prescription.id,
            'position', prescription.position,
            'exercise_definition_id', prescription.exercise_definition_id,
            'guidance_revision_id', coalesce(
              (
                select revision.id
                from public.guidance_revisions as revision
                join public.guidance_media_manifests as manifest
                  on manifest.guidance_revision_id = revision.id
                 and manifest.exercise_id = revision.exercise_id
                 and manifest.user_id = revision.user_id
                where revision.exercise_id = prescription.exercise_definition_id
                  and revision.user_id = item.user_id
                order by revision.version_number desc, revision.id desc
                limit 1
              ),
              prescription.guidance_revision_id
            ),
            'title', exercise.canonical_name,
            'priority', prescription.priority,
            'working_sets', prescription.working_sets,
            'rep_min', prescription.rep_min,
            'rep_max', prescription.rep_max,
            'rir_target', prescription.rir_target,
            'rest_seconds', prescription.rest_seconds,
            'load_unit', prescription.load_unit,
            'notes', prescription.notes
          )
          order by prescription.position
        )
        from public.routine_version_prescriptions as prescription
        join public.exercise_definitions as exercise
          on exercise.id = prescription.exercise_definition_id
         and exercise.user_id = prescription.user_id
        where prescription.routine_version_day_id = item.routine_version_day_id
          and prescription.user_id = item.user_id
      ),
      '[]'::jsonb
    )
  )
  from public.training_week_items as item
  join public.routine_version_days as day
    on day.id = item.routine_version_day_id
   and day.user_id = item.user_id
  where item.id = p_week_item_id
    and item.user_id = auth.uid();
$$;

revoke all on function public.get_training_week_item_detail_v1(uuid)
  from public, anon;
grant execute on function public.get_training_week_item_detail_v1(uuid)
  to authenticated;

comment on function public.get_training_week_item_detail_v1(uuid) is
  'Returns one owner-scoped materialized week item with immutable prescription details and the latest finalized published guidance revision for read-only mobile browsing.';

commit;
