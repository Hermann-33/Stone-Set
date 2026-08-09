import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

import { classifyChanges } from '../../tool/ci/change-classifier.mjs';

test('documentation-only changes run no runtime lane', () => {
  const result = classifyChanges(['README.md', 'docs/tasks/TASK-IMP-003B.md']);

  assert.equal(result.docs_only, true);
  assert.equal(result.flutter, false);
  assert.equal(result.mobile_performance, false);
  assert.equal(result.dashboard, false);
  assert.equal(result.supabase, false);
});

test('dashboard-only changes skip Android and Supabase lanes', () => {
  const result = classifyChanges(['apps/dashboard/lib/main.dart']);

  assert.equal(result.dashboard, true);
  assert.equal(result.dashboard_app, true);
  assert.equal(result.dashboard_visual, true);
  assert.equal(result.mobile_build, false);
  assert.equal(result.mobile_performance, false);
  assert.equal(result.supabase, false);
});

test('pure shared contracts compile Android without triggering API 24 profiling', () => {
  const result = classifyChanges(['packages/domain/lib/exercise_guidance.dart']);

  assert.equal(result.domain, true);
  assert.equal(result.mobile_build, true);
  assert.equal(result.dashboard, true);
  assert.equal(result.dashboard_visual, false);
  assert.equal(result.mobile_visual, false);
  assert.equal(result.mobile_performance, false);
});

test('mobile and shared UI changes retain the physical performance gate', () => {
  for (const path of ['apps/mobile/lib/main.dart', 'packages/ui/lib/stone_set_ui.dart']) {
    const result = classifyChanges([path]);
    assert.equal(result.mobile_build, true, path);
    assert.equal(result.mobile_visual, true, path);
    assert.equal(result.mobile_performance, true, path);
  }
});

test('database changes run only the Supabase runtime lane', () => {
  const result = classifyChanges(['supabase/migrations/20260808000100_example.sql']);

  assert.equal(result.supabase, true);
  assert.equal(result.flutter, false);
  assert.equal(result.mobile_performance, false);
});

test('root dependency changes compile both clients but do not claim a performance change', () => {
  const result = classifyChanges(['pubspec.lock']);

  assert.equal(result.flutter, true);
  assert.equal(result.mobile_build, true);
  assert.equal(result.dashboard, true);
  assert.equal(result.mobile_performance, false);
});

test('unknown paths fail closed instead of bypassing runtime gates', () => {
  const result = classifyChanges(['new-runtime/service/example.rs']);

  assert.equal(result.unknown, true);
  assert.equal(result.flutter, true);
  assert.equal(result.dashboard, true);
  assert.equal(result.mobile_performance, true);
  assert.equal(result.supabase, true);
});

test('workflow jobs consume the fail-closed classifier outputs', async () => {
  const workflow = await readFile('.github/workflows/foundation-ci.yml', 'utf8');

  assert.match(workflow, /flutter_dart:[\s\S]*?needs: changes[\s\S]*?outputs\.flutter/);
  assert.match(
    workflow,
    /mobile_api24_profile:[\s\S]*?needs: changes[\s\S]*?outputs\.mobile_performance/,
  );
  assert.match(workflow, /supabase:[\s\S]*?needs: changes[\s\S]*?outputs\.supabase/);
  assert.match(workflow, /Verify path-sensitive CI classification[\s\S]*?test:ci-classifier/);
  assert.match(
    workflow,
    /Verify running Auth and private Storage lifecycles[\s\S]*?exercise_media_storage\.integration\.test\.mjs/,
  );
});
