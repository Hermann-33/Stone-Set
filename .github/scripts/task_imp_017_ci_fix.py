from pathlib import Path


def replace_once(path: str, old: str, new: str, label: str) -> None:
    file = Path(path)
    text = file.read_text()
    if old not in text:
        raise RuntimeError(f'{label}: anchor not found')
    file.write_text(text.replace(old, new, 1))


replace_once(
    'apps/dashboard/lib/src/features/exercises/views/dashboard_guidance_editor_view.dart',
    '        error: (_, __) => const _PublicationStatusCard(',
    '        error: (_, _) => const _PublicationStatusCard(',
    'Dart wildcard lint',
)

replace_once(
    'supabase/tests/database/guidance_publication_activation_e2e.test.sql',
    """insert into auth.users (
  instance_id, id, aud, role, email, email_confirmed_at, created_at, updated_at
) values (
  '00000000-0000-0000-0000-000000000000',
  'fa100000-0000-4000-8000-000000000001',
  'authenticated', 'authenticated', 'guidance-activation@local.stone-set.invalid',
  clock_timestamp(), clock_timestamp(), clock_timestamp()
);

insert into public.profiles (
  id, normalized_username, public_display_name, active, must_change_password, reward_timezone
) values (
  'fa100000-0000-4000-8000-000000000001',
  'guidance_activation', 'Guidance Activation', true, false, 'Asia/Kuala_Lumpur'
);
""",
    """insert into auth.users (
  instance_id, id, aud, role, email, email_confirmed_at, created_at, updated_at
) values
  (
    '00000000-0000-0000-0000-000000000000',
    'fa100000-0000-4000-8000-000000000001',
    'authenticated', 'authenticated', 'guidance-activation@local.stone-set.invalid',
    clock_timestamp(), clock_timestamp(), clock_timestamp()
  ),
  (
    '00000000-0000-0000-0000-000000000000',
    'fa100000-0000-4000-8000-000000000002',
    'authenticated', 'authenticated', 'guidance-reviewer@local.stone-set.invalid',
    clock_timestamp(), clock_timestamp(), clock_timestamp()
  );

insert into public.profiles (
  id, normalized_username, public_display_name, active, must_change_password, reward_timezone
) values
  (
    'fa100000-0000-4000-8000-000000000001',
    'guidance_activation', 'Guidance Activation', true, false, 'Asia/Kuala_Lumpur'
  ),
  (
    'fa100000-0000-4000-8000-000000000002',
    'guidance_reviewer', 'Guidance Reviewer', true, false, 'Asia/Kuala_Lumpur'
  );
""",
    'distinct reviewer fixture identities',
)

replace_once(
    'supabase/tests/database/guidance_publication_activation_e2e.test.sql',
    """  'fa500000-0000-4000-8000-000000000001',
  'fa100000-0000-4000-8000-000000000001',
  'fa100000-0000-4000-8000-000000000001',
  'approved', 'Guidance activation fixture', repeat('d', 64)
""",
    """  'fa500000-0000-4000-8000-000000000001',
  'fa100000-0000-4000-8000-000000000001',
  'fa100000-0000-4000-8000-000000000002',
  'approved', 'Guidance activation fixture', repeat('d', 64)
""",
    'non-self routine review fixture',
)
