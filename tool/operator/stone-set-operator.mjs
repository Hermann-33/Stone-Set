#!/usr/bin/env node

import { executeCommand } from './operator-lib.mjs';

const usage = `Stone Set trusted identity operator

Every command requires --environment local|staging|production.
Commands are dry-run unless --execute is present. Production execution also requires
--confirm-production.

  provision --environment local --username USER --display-name NAME [--timezone AREA/LOCATION]
  status --environment local --username USER
  set-active --environment local --username USER --active true|false
  revoke --environment local --username USER --scope selected --session-id UUID
  revoke --environment local --username USER --scope global
  reset-password --environment local --username USER

Execution reads STONE_SET_SUPABASE_URL and STONE_SET_SERVICE_ROLE_KEY from the environment.
Alias settings are non-secret STONE_SET_ALIAS_DOMAIN and STONE_SET_ALIAS_STRATEGY.
Never pass credentials or passwords as arguments.`;

function safeError(error) {
  return {
    error: error instanceof Error ? error.message : 'unknown_operator_error',
    details: error?.safePayload || null,
  };
}

try {
  if (process.argv.includes('--help') || process.argv.length < 3) {
    process.stdout.write(`${usage}\n`);
    process.exitCode = process.argv.length < 3 ? 2 : 0;
  } else {
    const result = await executeCommand({ argv: process.argv.slice(2) });
    const { oneTimeTemporaryPassword, ...safeResult } = result;
    process.stdout.write(`${JSON.stringify(safeResult, null, 2)}\n`);
    if (oneTimeTemporaryPassword) {
      process.stdout.write(`ONE-TIME TEMPORARY PASSWORD: ${oneTimeTemporaryPassword}\n`);
      process.stdout.write('Transfer it through the approved controlled handoff, then clear this terminal.\n');
    }
  }
} catch (error) {
  process.stderr.write(`${JSON.stringify(safeError(error))}\n`);
  process.exitCode = 1;
}
