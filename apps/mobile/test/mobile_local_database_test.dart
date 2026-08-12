import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_mobile/features/local/data/mobile_local_database.dart';

void main() {
  test('v1 to v2 migration adds cache schema without touching workout tables', () {
    final statements = stoneSetMobileMigrationStatements(
      oldVersion: 1,
      newVersion: 2,
    );
    final sql = statements.join('\n').toLowerCase();

    expect(stoneSetMobileDatabaseVersion, 2);
    expect(sql, contains('create table if not exists mobile_snapshots'));
    expect(sql, contains('create table if not exists mobile_sync_state'));
    expect(sql, isNot(contains('drop table')));
    expect(sql, isNot(contains('delete from')));
    expect(sql, isNot(contains('active_workouts')));
    expect(sql, isNot(contains('workout_set_drafts')));
  });

  test('fresh database schema still includes workout and cache tables', () {
    final workoutSql = stoneSetWorkoutSchemaStatements.join('\n').toLowerCase();
    final snapshotSql = stoneSetSnapshotSchemaStatements.join('\n').toLowerCase();

    expect(workoutSql, contains('active_workouts'));
    expect(workoutSql, contains('workout_set_drafts'));
    expect(snapshotSql, contains('mobile_snapshots'));
    expect(snapshotSql, contains('mobile_sync_state'));
  });

  test('migration plan is empty when no version upgrade is required', () {
    expect(
      stoneSetMobileMigrationStatements(oldVersion: 2, newVersion: 2),
      isEmpty,
    );
  });
}
