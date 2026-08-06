import assert from 'node:assert/strict';
import test from 'node:test';

import {
  deriveAlias,
  executeCommand,
  generateTemporaryPassword,
  normalizeUsername,
  parseArguments,
  resolveAliasConfiguration,
  validateAliasDomain,
  validateExecutionBoundary,
  validatePassword,
} from './operator-lib.mjs';

test('username normalization shares the frozen grammar and length', () => {
  assert.equal(normalizeUsername('  Alpha_01  '), 'alpha_01');
  assert.throws(() => normalizeUsername('ab'), /invalid_username/);
  assert.throws(() => normalizeUsername('1alpha'), /invalid_username/);
  assert.throws(() => normalizeUsername('alpha-name'), /invalid_username/);
  assert.throws(() => normalizeUsername(`a${'b'.repeat(32)}`), /invalid_username/);
});

test('temporary password meets the frozen password policy', () => {
  for (let index = 0; index < 25; index += 1) {
    const password = generateTemporaryPassword();
    assert.equal(password.length, 24);
    assert.equal(validatePassword(password), password);
  }
  assert.throws(() => validatePassword('shortA1!'), /password_policy_not_met/);
  assert.throws(() => validatePassword('alllowercase123!'), /password_policy_not_met/);
});

test('secret command-line arguments are rejected', () => {
  assert.throws(
    () => parseArguments(['status', '--environment', 'local', '--password', 'secret']),
    /secret_arguments_are_forbidden/,
  );
  assert.throws(
    () => parseArguments(['status', '--service-role-key', 'secret']),
    /secret_arguments_are_forbidden/,
  );
  assert.throws(
    () => parseArguments(['status', '--apikey', 'secret']),
    /secret_arguments_are_forbidden/,
  );
});

test('execution requires credentials and explicit production confirmation', () => {
  assert.deepEqual(
    validateExecutionBoundary({ environment: 'local' }, {}),
    { environment: 'local', execute: false },
  );
  assert.throws(
    () => validateExecutionBoundary({ environment: 'local', execute: true }, {}),
    /operator_credentials_required/,
  );
  assert.throws(
    () => validateExecutionBoundary(
      { environment: 'production', execute: true },
      { STONE_SET_SUPABASE_URL: 'https://example.test', STONE_SET_SERVICE_ROLE_KEY: 'redacted' },
    ),
    /production_confirmation_required/,
  );
});

test('non-local provisioning requires an accepted alias strategy', () => {
  assert.deepEqual(resolveAliasConfiguration('local', {}), {
    strategy: 'synthetic_local',
    domain: 'local.stone-set.invalid',
  });
  assert.throws(() => resolveAliasConfiguration('staging', {}), /accepted_alias_strategy_required/);
  assert.deepEqual(
    resolveAliasConfiguration('production', {
      STONE_SET_ALIAS_STRATEGY: 'controlled_domain',
      STONE_SET_ALIAS_DOMAIN: 'accounts.stone-set.com',
    }),
    { strategy: 'controlled_domain', domain: 'accounts.stone-set.com' },
  );
  assert.equal(deriveAlias('Alpha_01', 'Accounts.Stone-Set.com'), 'alpha_01@accounts.stone-set.com');
  assert.throws(
    () => resolveAliasConfiguration('staging', {
      STONE_SET_ALIAS_STRATEGY: 'controlled_domain',
      STONE_SET_ALIAS_DOMAIN: 'accounts.example.test',
    }),
    /non_routable_alias_domain_forbidden/,
  );
  assert.throws(
    () => resolveAliasConfiguration('production', {
      STONE_SET_ALIAS_STRATEGY: 'noop_email_hook',
      STONE_SET_ALIAS_DOMAIN: 'stone-set.invalid',
    }),
    /non_routable_alias_domain_forbidden/,
  );
  assert.throws(() => validateAliasDomain('bad..domain.com'), /invalid_alias_domain/);
  assert.throws(() => validateAliasDomain('-bad.domain.com'), /invalid_alias_domain/);
});

test('dry-run validates and performs no network call', async () => {
  let fetchCalled = false;
  const result = await executeCommand({
    argv: [
      'provision',
      '--environment',
      'local',
      '--username',
      'Alpha_01',
      '--display-name',
      'Alpha One',
    ],
    environmentValues: {},
    fetchImpl: async () => {
      fetchCalled = true;
      throw new Error('network_must_not_be_called');
    },
  });
  assert.equal(fetchCalled, false);
  assert.equal(result.dryRun, true);
  assert.equal(result.username, 'alpha_01');
  assert.equal(result.aliasDomain, 'local.stone-set.invalid');
  assert.equal(JSON.stringify(result).includes('password'), false);
});

test('provision dry-run rejects invalid display names and IANA timezones', async () => {
  await assert.rejects(
    executeCommand({
      argv: [
        'provision',
        '--environment',
        'local',
        '--username',
        'alpha_01',
        '--display-name',
        '   ',
      ],
      environmentValues: {},
    }),
    /invalid_display_name/,
  );
  await assert.rejects(
    executeCommand({
      argv: [
        'provision',
        '--environment',
        'local',
        '--username',
        'alpha_01',
        '--display-name',
        'Alpha One',
        '--timezone',
        'Not/A_Timezone',
      ],
      environmentValues: {},
    }),
    /invalid_reward_timezone/,
  );
});

test('executed provisioning fails closed before account creation when public signup is enabled', async () => {
  const requests = [];
  await assert.rejects(
    executeCommand({
      argv: [
        'provision',
        '--environment',
        'local',
        '--username',
        'alpha_01',
        '--display-name',
        'Alpha One',
        '--execute',
      ],
      environmentValues: {
        STONE_SET_SUPABASE_URL: 'http://127.0.0.1:54321',
        STONE_SET_SERVICE_ROLE_KEY: 'unit-test-placeholder',
      },
      fetchImpl: async (url) => {
        requests.push(new URL(url).pathname);
        return new Response(JSON.stringify({
          disable_signup: false,
          external: { anonymous_users: false },
        }), {
          status: 200,
          headers: { 'content-type': 'application/json' },
        });
      },
    }),
    /public_signup_must_be_disabled/,
  );
  assert.deepEqual(requests, ['/auth/v1/settings']);

  requests.length = 0;
  await assert.rejects(
    executeCommand({
      argv: [
        'provision',
        '--environment',
        'staging',
        '--username',
        'alpha_01',
        '--display-name',
        'Alpha One',
        '--execute',
      ],
      environmentValues: {
        STONE_SET_SUPABASE_URL: 'https://staging.stone-set.com',
        STONE_SET_SERVICE_ROLE_KEY: 'unit-test-placeholder',
        STONE_SET_ALIAS_STRATEGY: 'controlled_domain',
        STONE_SET_ALIAS_DOMAIN: 'accounts.stone-set.com',
      },
      fetchImpl: async (url) => {
        requests.push(new URL(url).pathname);
        return new Response(JSON.stringify({
          disable_signup: true,
          external: { anonymous_users: true },
        }), {
          status: 200,
          headers: { 'content-type': 'application/json' },
        });
      },
    }),
    /anonymous_signup_must_be_disabled/,
  );
  assert.deepEqual(requests, ['/auth/v1/settings']);
});

test('selected revocation dry-run records scope without credentials', async () => {
  const result = await executeCommand({
    argv: [
      'revoke',
      '--environment',
      'local',
      '--username',
      'alpha_01',
      '--scope',
      'selected',
      '--session-id',
      '00000000-0000-4000-8000-000000000001',
    ],
    environmentValues: {},
  });
  assert.equal(result.dryRun, true);
  assert.equal(result.scope, 'selected');
});

test('revocation dry-run validates selected/global scope contracts', async () => {
  await assert.rejects(
    executeCommand({
      argv: ['revoke', '--environment', 'local', '--username', 'alpha_01', '--scope', 'selected'],
      environmentValues: {},
    }),
    /selected_scope_requires_session_id_only/,
  );
  await assert.rejects(
    executeCommand({
      argv: [
        'revoke',
        '--environment',
        'local',
        '--username',
        'alpha_01',
        '--scope',
        'global',
        '--session-id',
        '00000000-0000-4000-8000-000000000001',
      ],
      environmentValues: {},
    }),
    /selected_scope_requires_session_id_only/,
  );
  await assert.rejects(
    executeCommand({
      argv: [
        'revoke',
        '--environment',
        'local',
        '--username',
        'alpha_01',
        '--scope',
        'selected',
        '--session-id',
        'not-a-uuid',
      ],
      environmentValues: {},
    }),
    /invalid_session_id/,
  );
});

test('password reset deactivates before Auth update and restores only after proof', async () => {
  const requests = [];
  const responses = [
    {
      userId: '10000000-0000-4000-8000-000000000001',
      active: true,
      latestPasswordAudit: { eventId: '20000000-0000-4000-8000-000000000001' },
    },
    { active: false },
    { id: '10000000-0000-4000-8000-000000000001' },
    {
      userId: '10000000-0000-4000-8000-000000000001',
      active: false,
      latestPasswordAudit: { eventId: '20000000-0000-4000-8000-000000000002' },
    },
    { mustChangePassword: true, sessionsRevoked: 'global' },
    { active: true },
  ];
  const result = await executeCommand({
    argv: ['reset-password', '--environment', 'local', '--username', 'alpha_01', '--execute'],
    environmentValues: {
      STONE_SET_SUPABASE_URL: 'http://127.0.0.1:54321',
      STONE_SET_SERVICE_ROLE_KEY: 'unit-test-placeholder',
    },
    fetchImpl: async (url, options) => {
      requests.push({ url, options });
      return new Response(JSON.stringify(responses.shift()), {
        status: 200,
        headers: { 'content-type': 'application/json' },
      });
    },
    waitImpl: async () => undefined,
  });

  assert.deepEqual(
    requests.map(({ url }) => new URL(url).pathname),
    [
      '/rest/v1/rpc/operator_account_status',
      '/rest/v1/rpc/operator_set_active',
      '/auth/v1/admin/users/10000000-0000-4000-8000-000000000001',
      '/rest/v1/rpc/operator_account_status',
      '/rest/v1/rpc/operator_require_password_change',
      '/rest/v1/rpc/operator_set_active',
    ],
  );
  assert.equal(JSON.parse(requests[1].options.body).p_active, false);
  assert.equal(JSON.parse(requests[5].options.body).p_active, true);
  assert.equal(validatePassword(result.oneTimeTemporaryPassword), result.oneTimeTemporaryPassword);
});
