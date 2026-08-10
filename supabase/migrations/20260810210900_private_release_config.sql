begin;

insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'exercise-media',
  'exercise-media',
  false,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']::text[]
)
on conflict (id) do update set
  name = excluded.name,
  public = false,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

update public.client_compatibility_config
set is_current = false
where environment = 'production'
  and is_current;

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
)
values (
  'production',
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
)
on conflict (environment, config_version) do update set
  minimum_mobile_build = excluded.minimum_mobile_build,
  minimum_dashboard_build = excluded.minimum_dashboard_build,
  minimum_schema_contract = excluded.minimum_schema_contract,
  recommended_mobile_build = excluded.recommended_mobile_build,
  maintenance_mode = excluded.maintenance_mode,
  read_only_mode = excluded.read_only_mode,
  message_code = excluded.message_code,
  message_text = excluded.message_text,
  features = excluded.features,
  is_current = excluded.is_current,
  active_from = clock_timestamp();

commit;
