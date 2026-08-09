import assert from 'node:assert/strict';
import test from 'node:test';

const enabled = process.env.STONE_SET_RUN_SUPABASE_INTEGRATION === '1';
const integrationTest = enabled ? test : test.skip;

function runtimeConfiguration() {
  const url = process.env.STONE_SET_SUPABASE_URL?.replace(/\/$/, '');
  const anonKey = process.env.STONE_SET_SUPABASE_ANON_KEY;
  const serviceRoleKey = process.env.STONE_SET_SERVICE_ROLE_KEY;
  if (!url || !anonKey || !serviceRoleKey) {
    throw new Error('local_supabase_storage_configuration_required');
  }
  if (!/^https?:\/\/(127\.0\.0\.1|localhost)(:\d+)?$/i.test(url)) {
    throw new Error('exercise_media_storage_verification_is_local_only');
  }
  return { url, anonKey, serviceRoleKey };
}

async function storageRequest(path, { apiKey, method = 'GET', body, contentType } = {}) {
  const { url } = runtimeConfiguration();
  const response = await fetch(`${url}/storage/v1${path}`, {
    method,
    headers: {
      apikey: apiKey,
      authorization: `Bearer ${apiKey}`,
      ...(contentType ? { 'content-type': contentType } : {}),
    },
    body,
  });
  const payload = await response.json().catch(() => null);
  return { ok: response.ok, status: response.status, payload };
}

integrationTest('running local Storage exposes the exact private exercise-media bucket limits', async () => {
  const { serviceRoleKey } = runtimeConfiguration();
  const result = await storageRequest('/bucket/exercise-media', { apiKey: serviceRoleKey });
  assert.equal(result.ok, true);
  assert.equal(result.payload?.id, 'exercise-media');
  assert.equal(result.payload?.public, false);
  assert.equal(Number(result.payload?.file_size_limit), 5 * 1024 * 1024);
  assert.deepEqual(
    [...(result.payload?.allowed_mime_types ?? [])].sort(),
    ['image/jpeg', 'image/png', 'image/webp'],
  );
});

integrationTest('anonymous caller cannot upload without an owned server-created intent', async () => {
  const { anonKey } = runtimeConfiguration();
  const result = await storageRequest(
    '/object/exercise-media/00000000-0000-4000-8000-000000000000/denied.png',
    {
      apiKey: anonKey,
      method: 'POST',
      body: new Uint8Array([0x89, 0x50, 0x4e, 0x47]),
      contentType: 'image/png',
    },
  );
  assert.equal(result.ok, false);
  assert.ok([400, 401, 403].includes(result.status));
});
