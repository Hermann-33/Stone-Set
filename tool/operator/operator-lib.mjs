import { randomInt, randomUUID } from 'node:crypto';

export const usernamePattern = /^[a-z][a-z0-9_]{2,31}$/;
export const passwordPattern = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{12,}$/;
export const environments = new Set(['local', 'staging', 'production']);

export function normalizeUsername(value) {
  if (typeof value !== 'string') {
    throw new Error('username_required');
  }
  const normalized = value.trim().toLowerCase();
  if (!usernamePattern.test(normalized)) {
    throw new Error('invalid_username');
  }
  return normalized;
}

export function validatePassword(value) {
  if (typeof value !== 'string' || !passwordPattern.test(value)) {
    throw new Error('password_policy_not_met');
  }
  return value;
}

export function generateTemporaryPassword(length = 24) {
  if (!Number.isInteger(length) || length < 12) {
    throw new Error('password_length_too_short');
  }
  const required = ['abcdefghijkmnopqrstuvwxyz', 'ABCDEFGHJKLMNPQRSTUVWXYZ', '23456789', '!@#$%^&*_-+='];
  const all = required.join('');
  const characters = required.map((alphabet) => alphabet[randomInt(alphabet.length)]);
  while (characters.length < length) {
    characters.push(all[randomInt(all.length)]);
  }
  for (let index = characters.length - 1; index > 0; index -= 1) {
    const swapWith = randomInt(index + 1);
    [characters[index], characters[swapWith]] = [characters[swapWith], characters[index]];
  }
  return validatePassword(characters.join(''));
}

export function parseArguments(argv) {
  const [command, ...tokens] = argv;
  if (!command || command.startsWith('--')) {
    throw new Error('command_required');
  }
  const options = {};
  for (let index = 0; index < tokens.length; index += 1) {
    const token = tokens[index];
    if (!token.startsWith('--')) {
      throw new Error(`unexpected_argument:${token}`);
    }
    const key = token.slice(2);
    if (/(password|token|secret|key|database-url)/i.test(key)) {
      throw new Error('secret_arguments_are_forbidden');
    }
    const next = tokens[index + 1];
    if (!next || next.startsWith('--')) {
      options[key] = true;
    } else {
      options[key] = next;
      index += 1;
    }
  }
  return { command, options };
}

export function validateExecutionBoundary(options, environmentValues) {
  const environment = options.environment;
  if (!environments.has(environment)) {
    throw new Error('explicit_environment_required');
  }
  const execute = options.execute === true;
  if (environment === 'production' && execute && options['confirm-production'] !== true) {
    throw new Error('production_confirmation_required');
  }
  if (execute && (!environmentValues.STONE_SET_SUPABASE_URL || !environmentValues.STONE_SET_SERVICE_ROLE_KEY)) {
    throw new Error('operator_credentials_required');
  }
  return { environment, execute };
}

export function resolveAliasConfiguration(environment, environmentValues) {
  const strategy = environmentValues.STONE_SET_ALIAS_STRATEGY;
  const configuredDomain = environmentValues.STONE_SET_ALIAS_DOMAIN;
  if (environment === 'local') {
    return {
      strategy: strategy || 'synthetic_local',
      domain: configuredDomain || 'local.stone-set.invalid',
    };
  }
  if (!['controlled_domain', 'noop_email_hook'].includes(strategy)) {
    throw new Error('accepted_alias_strategy_required');
  }
  if (!configuredDomain) {
    throw new Error('alias_domain_required');
  }
  return { strategy, domain: configuredDomain };
}

export function deriveAlias(username, domain) {
  const normalized = normalizeUsername(username);
  if (typeof domain !== 'string' || !/^[a-z0-9](?:[a-z0-9.-]{0,251}[a-z0-9])?$/i.test(domain)) {
    throw new Error('invalid_alias_domain');
  }
  return `${normalized}@${domain.toLowerCase()}`;
}

export class SupabaseOperatorClient {
  constructor({ url, serviceRoleKey, fetchImpl = globalThis.fetch }) {
    this.url = url.replace(/\/$/, '');
    this.serviceRoleKey = serviceRoleKey;
    this.fetchImpl = fetchImpl;
  }

  async request(path, { method = 'POST', body } = {}) {
    const response = await this.fetchImpl(`${this.url}${path}`, {
      method,
      headers: {
        apikey: this.serviceRoleKey,
        authorization: `Bearer ${this.serviceRoleKey}`,
        'content-type': 'application/json',
      },
      body: body === undefined ? undefined : JSON.stringify(body),
    });
    const payload = response.status === 204 ? null : await response.json().catch(() => null);
    if (!response.ok) {
      const error = new Error(`operator_request_failed:${response.status}`);
      error.safePayload = payload && typeof payload === 'object'
        ? { code: payload.code || null }
        : null;
      throw error;
    }
    return payload;
  }

  createConfirmedUser(email, password) {
    return this.request('/auth/v1/admin/users', {
      body: { email, password, email_confirm: true },
    });
  }

  updatePassword(userId, password) {
    return this.request(`/auth/v1/admin/users/${encodeURIComponent(userId)}`, {
      method: 'PUT',
      body: { password },
    });
  }

  deleteUser(userId) {
    return this.request(`/auth/v1/admin/users/${encodeURIComponent(userId)}`, {
      method: 'DELETE',
    });
  }

  rpc(name, parameters) {
    return this.request(`/rest/v1/rpc/${name}`, { body: parameters });
  }
}

function requiredOption(options, key) {
  const value = options[key];
  if (typeof value !== 'string' || value.length === 0) {
    throw new Error(`option_required:${key}`);
  }
  return value;
}

function validateDisplayName(value) {
  const displayName = value.trim();
  if (displayName.length < 1 || displayName.length > 80 || /[\u0000-\u001f\u007f]/.test(displayName)) {
    throw new Error('invalid_display_name');
  }
  return displayName;
}

function validateTimeZone(value) {
  try {
    new Intl.DateTimeFormat('en-US', { timeZone: value }).format();
  } catch {
    throw new Error('invalid_reward_timezone');
  }
  return value;
}

function dryRunResult(command, environment, details) {
  return {
    dryRun: true,
    command,
    environment,
    ...details,
  };
}

function parseActive(options) {
  const activeText = requiredOption(options, 'active');
  if (!['true', 'false'].includes(activeText)) {
    throw new Error('active_must_be_true_or_false');
  }
  return activeText === 'true';
}

function parseRevocation(options) {
  const scope = requiredOption(options, 'scope');
  if (!['selected', 'global'].includes(scope)) {
    throw new Error('scope_must_be_selected_or_global');
  }
  const sessionId = options['session-id'] || null;
  if ((scope === 'selected') !== Boolean(sessionId)) {
    throw new Error('selected_scope_requires_session_id_only');
  }
  return { scope, sessionId };
}

async function statusForUsername(client, username) {
  return client.rpc('operator_account_status', {
    p_normalized_username: username,
  });
}

async function waitForPasswordAudit(client, username, previousEventId, waitImpl) {
  for (let attempt = 0; attempt < 20; attempt += 1) {
    const status = await statusForUsername(client, username);
    const eventId = status?.latestPasswordAudit?.eventId;
    if (eventId && eventId !== previousEventId) {
      return { status, eventId };
    }
    await waitImpl(250);
  }
  throw new Error('password_audit_not_observed_account_must_remain_disabled');
}

export async function executeCommand({
  argv,
  environmentValues = process.env,
  fetchImpl = globalThis.fetch,
  waitImpl = (milliseconds) => new Promise((resolve) => setTimeout(resolve, milliseconds)),
}) {
  const { command, options } = parseArguments(argv);
  const { environment, execute } = validateExecutionBoundary(options, environmentValues);
  const correlationId = randomUUID();
  const username = command === 'help' ? null : normalizeUsername(requiredOption(options, 'username'));

  if (command === 'provision') {
    const displayName = validateDisplayName(requiredOption(options, 'display-name'));
    const rewardTimezone = validateTimeZone(options.timezone || 'UTC');
    const aliasConfiguration = resolveAliasConfiguration(environment, environmentValues);
    const alias = deriveAlias(username, aliasConfiguration.domain);
    if (!execute) {
      return dryRunResult(command, environment, {
        username,
        displayName,
        rewardTimezone,
        aliasStrategy: aliasConfiguration.strategy,
        aliasDomain: aliasConfiguration.domain,
        steps: ['create_confirmed_auth_user', 'link_inactive_profile', 'activate_profile'],
      });
    }
    const client = new SupabaseOperatorClient({
      url: environmentValues.STONE_SET_SUPABASE_URL,
      serviceRoleKey: environmentValues.STONE_SET_SERVICE_ROLE_KEY,
      fetchImpl,
    });
    const temporaryPassword = generateTemporaryPassword();
    let userId;
    try {
      const authUser = await client.createConfirmedUser(alias, temporaryPassword);
      userId = authUser.id;
      await client.rpc('operator_link_identity', {
        p_user_id: userId,
        p_normalized_username: username,
        p_public_display_name: displayName,
        p_reward_timezone: rewardTimezone,
        p_correlation_id: correlationId,
      });
      const result = await client.rpc('operator_set_active', {
        p_user_id: userId,
        p_active: true,
        p_correlation_id: correlationId,
      });
      return {
        command,
        environment,
        username,
        userId,
        correlationId,
        result,
        oneTimeTemporaryPassword: temporaryPassword,
      };
    } catch (error) {
      if (userId) {
        await client.deleteUser(userId).catch(() => undefined);
      }
      throw error;
    }
  }

  if (!execute) {
    const details = { username };
    if (command === 'set-active') {
      details.active = parseActive(options);
    } else if (command === 'revoke') {
      const revocation = parseRevocation(options);
      details.scope = revocation.scope;
      details.sessionId = revocation.sessionId;
    } else if (command === 'reset-password') {
      details.steps = [
        'capture_password_audit_baseline',
        'deactivate_profile',
        'update_auth_password',
        'observe_new_auth_audit',
        'set_requirement_and_global_cutoff',
        'restore_prior_active_state',
      ];
    } else if (!['status', 'reset-password'].includes(command)) {
      throw new Error('unsupported_command');
    }
    return dryRunResult(command, environment, details);
  }

  const client = new SupabaseOperatorClient({
    url: environmentValues.STONE_SET_SUPABASE_URL,
    serviceRoleKey: environmentValues.STONE_SET_SERVICE_ROLE_KEY,
    fetchImpl,
  });
  const status = await statusForUsername(client, username);

  if (command === 'status') {
    return { command, environment, status };
  }

  if (command === 'set-active') {
    const active = parseActive(options);
    const result = await client.rpc('operator_set_active', {
      p_user_id: status.userId,
      p_active: active,
      p_correlation_id: correlationId,
    });
    return { command, environment, username, correlationId, result };
  }

  if (command === 'revoke') {
    const { scope, sessionId } = parseRevocation(options);
    const result = await client.rpc('operator_revoke_sessions', {
      p_user_id: status.userId,
      p_scope: scope,
      p_session_id: sessionId,
      p_reason_code: options.reason || 'operator_revocation',
      p_correlation_id: correlationId,
    });
    return { command, environment, username, correlationId, result };
  }

  if (command === 'reset-password') {
    const priorAuditEventId = status.latestPasswordAudit?.eventId || null;
    const temporaryPassword = generateTemporaryPassword();
    await client.rpc('operator_set_active', {
      p_user_id: status.userId,
      p_active: false,
      p_correlation_id: correlationId,
    });
    let result;
    try {
      await client.updatePassword(status.userId, temporaryPassword);
      const observed = await waitForPasswordAudit(client, username, priorAuditEventId, waitImpl);
      result = await client.rpc('operator_require_password_change', {
        p_user_id: status.userId,
        p_observed_auth_audit_id: observed.eventId,
        p_correlation_id: correlationId,
      });
      if (status.active) {
        await client.rpc('operator_set_active', {
          p_user_id: status.userId,
          p_active: true,
          p_correlation_id: correlationId,
        });
      }
    } catch (error) {
      throw error;
    }
    return {
      command,
      environment,
      username,
      correlationId,
      result,
      oneTimeTemporaryPassword: temporaryPassword,
    };
  }

  throw new Error('unsupported_command');
}
