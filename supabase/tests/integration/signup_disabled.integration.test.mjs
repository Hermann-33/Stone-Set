import { randomBytes, randomUUID } from 'node:crypto';
import assert from 'node:assert/strict';
import test from 'node:test';

const enabled = process.env.STONE_SET_RUN_SUPABASE_INTEGRATION === '1';
const integrationTest = enabled ? test : test.skip;

function runtimeConfiguration() {
  const url = process.env.STONE_SET_SUPABASE_URL?.replace(/\/$/, '');
  const anonKey = process.env.STONE_SET_SUPABASE_ANON_KEY;
  if (!url || !anonKey) {
    throw new Error('local_supabase_public_configuration_required');
  }
  if (!/^https?:\/\/(127\.0\.0\.1|localhost)(:\d+)?$/i.test(url)) {
    throw new Error('signup_verification_is_local_only');
  }
  return { url, anonKey };
}

async function authRequest(path, body) {
  const { url, anonKey } = runtimeConfiguration();
  const response = await fetch(`${url}${path}`, {
    method: body === undefined ? 'GET' : 'POST',
    headers: {
      apikey: anonKey,
      'content-type': 'application/json',
    },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const payload = await response.json().catch(() => null);
  return {
    ok: response.ok,
    status: response.status,
    disableSignup: payload?.disable_signup,
    safeCode: payload?.code || payload?.error_code || null,
  };
}

integrationTest('running local Auth reports public signup disabled', async () => {
  const settings = await authRequest('/auth/v1/settings');
  assert.equal(settings.ok, true);
  assert.equal(settings.disableSignup, true);
});

integrationTest('running local Auth denies synthetic public email signup', async () => {
  const password = `${randomBytes(12).toString('hex')}aA1!`;
  const result = await authRequest('/auth/v1/signup', {
    email: `blocked-${randomUUID()}@local.stone-set.invalid`,
    password,
  });
  assert.equal(result.ok, false);
  assert.ok([400, 401, 403, 422].includes(result.status));
});

integrationTest('running local Auth denies anonymous signup', async () => {
  const result = await authRequest('/auth/v1/signup', { data: {} });
  assert.equal(result.ok, false);
  assert.ok([400, 401, 403, 422].includes(result.status));
});
