import { randomBytes, randomUUID } from 'node:crypto';
import assert from 'node:assert/strict';
import test from 'node:test';

const enabled = process.env.STONE_SET_RUN_SUPABASE_INTEGRATION === '1';
const integrationTest = enabled ? test : test.skip;

function runtimeConfiguration() {
  const url = process.env.STONE_SET_SUPABASE_URL?.replace(/\/$/, '');
  const anonKey = process.env.STONE_SET_SUPABASE_ANON_KEY;
  const serviceRoleKey = process.env.STONE_SET_SERVICE_ROLE_KEY;
  if (!url || !anonKey || !serviceRoleKey) {
    throw new Error('local_supabase_identity_configuration_required');
  }
  if (!/^https?:\/\/(127\.0\.0\.1|localhost)(:\d+)?$/i.test(url)) {
    throw new Error('identity_lifecycle_verification_is_local_only');
  }
  return { url, anonKey, serviceRoleKey };
}

async function request(path, { apiKey, bearer = apiKey, method = 'POST', body } = {}) {
  const { url } = runtimeConfiguration();
  const response = await fetch(`${url}${path}`, {
    method,
    headers: {
      apikey: apiKey,
      authorization: `Bearer ${bearer}`,
      'content-type': 'application/json',
    },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const payload = response.status === 204 ? null : await response.json().catch(() => null);
  return { ok: response.ok, status: response.status, payload };
}

async function operatorRpc(name, parameters) {
  const { serviceRoleKey } = runtimeConfiguration();
  return request(`/rest/v1/rpc/${name}`, {
    apiKey: serviceRoleKey,
    body: parameters,
  });
}

async function authenticatedRpc(name, accessToken, parameters) {
  const { anonKey } = runtimeConfiguration();
  return request(`/rest/v1/rpc/${name}`, {
    apiKey: anonKey,
    bearer: accessToken,
    body: parameters,
  });
}

async function waitForPasswordProof(accessToken, correlationId) {
  for (let attempt = 0; attempt < 40; attempt += 1) {
    const result = await authenticatedRpc('complete_required_password_change', accessToken, {
      p_correlation_id: correlationId,
    });
    if (result.ok) {
      return result;
    }
    if (result.payload?.message !== 'password_change_evidence_missing') {
      assert.fail(`unexpected_password_proof_failure:${result.status}:${result.payload?.message}`);
    }
    await new Promise((resolve) => setTimeout(resolve, 250));
  }
  assert.fail('password_change_audit_evidence_not_observed');
}

integrationTest('real Auth password update is required before the server flag clears', { timeout: 30000 }, async () => {
  const { anonKey, serviceRoleKey } = runtimeConfiguration();
  const suffix = randomUUID().replaceAll('-', '').slice(0, 12);
  const username = `test_${suffix}`;
  const email = `${username}@local.stone-set.invalid`;
  const temporaryPassword = `${randomBytes(12).toString('hex')}aA1!`;
  const permanentPassword = `${randomBytes(12).toString('hex')}zZ2!`;
  const correlationId = randomUUID();
  let userId;

  try {
    const created = await request('/auth/v1/admin/users', {
      apiKey: serviceRoleKey,
      body: { email, password: temporaryPassword, email_confirm: true },
    });
    assert.equal(created.ok, true, 'trusted operator can create a synthetic confirmed user');
    userId = created.payload?.id;
    assert.match(userId, /^[0-9a-f-]{36}$/i);

    const linked = await operatorRpc('operator_link_identity', {
      p_user_id: userId,
      p_normalized_username: username,
      p_public_display_name: 'Identity Proof User',
      p_reward_timezone: 'UTC',
      p_correlation_id: correlationId,
    });
    assert.equal(linked.ok, true, 'trusted operator links the protected profile');
    const activated = await operatorRpc('operator_set_active', {
      p_user_id: userId,
      p_active: true,
      p_correlation_id: correlationId,
    });
    assert.equal(activated.ok, true, 'trusted operator activates the protected profile');

    const signedIn = await request('/auth/v1/token?grant_type=password', {
      apiKey: anonKey,
      body: { email, password: temporaryPassword },
    });
    assert.equal(signedIn.ok, true, 'provisioned account signs in through Supabase Auth');
    const accessToken = signedIn.payload?.access_token;
    assert.equal(typeof accessToken, 'string');

    const unsupportedCompletion = await authenticatedRpc(
      'complete_required_password_change',
      accessToken,
      { p_correlation_id: randomUUID() },
    );
    assert.equal(unsupportedCompletion.ok, false);
    assert.equal(unsupportedCompletion.payload?.message, 'password_change_evidence_missing');

    const directClear = await request(`/rest/v1/profiles?id=eq.${encodeURIComponent(userId)}`, {
      apiKey: anonKey,
      bearer: accessToken,
      method: 'PATCH',
      body: { must_change_password: false },
    });
    assert.equal(directClear.ok, false, 'direct client flag clear is denied at object level');
    assert.equal(directClear.payload?.code, '42501');

    const passwordUpdated = await request('/auth/v1/user', {
      apiKey: anonKey,
      bearer: accessToken,
      method: 'PUT',
      body: { password: permanentPassword },
    });
    assert.equal(passwordUpdated.ok, true, 'password update succeeds through Supabase Auth');

    const completed = await waitForPasswordProof(accessToken, correlationId);
    assert.equal(completed.payload?.completed, true);

    const bootstrap = await authenticatedRpc('get_authenticated_bootstrap', accessToken, {
      p_environment: 'local',
      p_client_kind: 'dashboard',
      p_client_build: 1,
      p_schema_contract: 1,
      p_correlation_id: randomUUID(),
    });
    assert.equal(bootstrap.ok, true);
    assert.equal(bootstrap.payload?.state, 'authenticated');
    assert.equal(bootstrap.payload?.profile?.mustChangePassword, false);
  } finally {
    if (userId) {
      await request(`/auth/v1/admin/users/${encodeURIComponent(userId)}`, {
        apiKey: serviceRoleKey,
        method: 'DELETE',
      });
    }
  }
});
