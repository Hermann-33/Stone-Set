import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

const configUrl = new URL('../../config.toml', import.meta.url);

function section(config, name) {
  const escaped = name.replaceAll('.', '\\.');
  const match = config.match(new RegExp(`\\[${escaped}\\]([\\s\\S]*?)(?=\\n\\[|$)`));
  assert.ok(match, `missing [${name}] section`);
  return match[1];
}

function value(configSection, key) {
  const match = configSection.match(new RegExp(`^${key}\\s*=\\s*(.+)$`, 'm'));
  assert.ok(match, `missing ${key}`);
  return match[1].trim().replace(/^"|"$/g, '');
}

test('public and provider email signup are disabled', async () => {
  const config = await readFile(configUrl, 'utf8');
  assert.equal(value(section(config, 'auth'), 'enable_signup'), 'false');
  assert.equal(value(section(config, 'auth.email'), 'enable_signup'), 'false');
  assert.equal(value(section(config, 'auth.sms'), 'enable_signup'), 'false');
});

test('anonymous signup is disabled', async () => {
  const config = await readFile(configUrl, 'utf8');
  assert.equal(value(section(config, 'auth'), 'enable_anonymous_sign_ins'), 'false');
});

test('local Auth enforces the frozen password policy', async () => {
  const config = await readFile(configUrl, 'utf8');
  const auth = section(config, 'auth');
  assert.equal(value(auth, 'minimum_password_length'), '12');
  assert.equal(value(auth, 'password_requirements'), 'lower_upper_letters_digits_symbols');
  assert.equal(value(section(config, 'auth.email'), 'secure_password_change'), 'true');
});

test('private schema is not Data API exposed and auto exposure is not enabled', async () => {
  const config = await readFile(configUrl, 'utf8');
  const api = section(config, 'api');
  assert.equal(value(api, 'schemas'), '["public", "graphql_public"]');
  assert.equal(/^auto_expose_new_tables\s*=/m.test(api), false);
});
