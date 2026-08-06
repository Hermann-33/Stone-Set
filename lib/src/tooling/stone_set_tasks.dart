import 'dart:io';

import 'process_service.dart';
import 'repository_checker.dart';
import 'tool_version_checker.dart';
import 'workspace.dart';

final class StoneSetTasks {
  const StoneSetTasks({
    required this.workspace,
    required this.processes,
    required this.repositoryChecker,
    required this.toolVersionChecker,
  });

  final StoneSetWorkspace workspace;
  final ProcessService processes;
  final RepositoryChecker repositoryChecker;
  final ToolVersionChecker toolVersionChecker;

  Future<void> restore({required bool enforceLockfile}) async {
    await processes.run(ToolExecutables.dart, <String>[
      'pub',
      'get',
      if (enforceLockfile) '--enforce-lockfile',
    ], workingDirectory: workspace.rootPath);
    await processes.run(ToolExecutables.npm, const <String>[
      'ci',
    ], workingDirectory: workspace.rootPath);
  }

  Future<void> formatCheck() => processes.run(
    ToolExecutables.dart,
    const <String>['format', '--output=none', '--set-exit-if-changed', '.'],
    workingDirectory: workspace.rootPath,
  );

  Future<void> analyze() => processes.run(ToolExecutables.dart, const <String>[
    'analyze',
    '--fatal-infos',
  ], workingDirectory: workspace.rootPath);

  Future<void> generate() async {
    for (final application in const <String>['apps/mobile', 'apps/dashboard']) {
      await processes.run(ToolExecutables.dart, const <String>[
        'run',
        'build_runner',
        'build',
        '--delete-conflicting-outputs',
      ], workingDirectory: workspace.path(application));
    }
  }

  Future<void> test() async {
    await processes.run(ToolExecutables.node, const <String>[
      '--test',
      'tool/operator/operator.test.mjs',
    ], workingDirectory: workspace.rootPath);
    await processes.run(ToolExecutables.dart, const <String>[
      'test',
      'test/tooling',
    ], workingDirectory: workspace.rootPath);
    for (final package in const <String>['packages/domain']) {
      await processes.run(ToolExecutables.dart, const <String>[
        'test',
      ], workingDirectory: workspace.path(package));
    }
    for (final package in const <String>[
      'packages/data',
      'packages/ui',
      'apps/mobile',
      'apps/dashboard',
    ]) {
      await processes.run(ToolExecutables.flutter, const <String>[
        'test',
      ], workingDirectory: workspace.path(package));
    }
  }

  Future<void> buildAndroid() => processes.run(
    ToolExecutables.flutter,
    const <String>['build', 'apk', '--release'],
    workingDirectory: workspace.path('apps/mobile'),
  );

  Future<void> buildDashboard() => processes.run(
    ToolExecutables.flutter,
    const <String>['build', 'web', '--release'],
    workingDirectory: workspace.path('apps/dashboard'),
  );

  Future<void> supabaseStart() => _supabase(const <String>['start']);

  Future<void> supabaseReset() => _supabase(const <String>['db', 'reset', '--local']);

  Future<void> supabaseTest() => _supabase(const <String>['test', 'db', '--local']);

  Future<void> supabaseLint() => _supabase(const <String>[
    'db',
    'lint',
    '--local',
    '--fail-on',
    'warning',
  ]);

  Future<void> supabaseStop({required bool noBackup}) => _supabase(<String>[
    'stop',
    '--project-id',
    'stone-set',
    if (noBackup) '--no-backup',
  ]);

  Future<void> checkRepository() => repositoryChecker.check();

  Future<void> checkToolVersions() => toolVersionChecker.check();

  Future<void> verify() async {
    await checkRepository();
    await restore(enforceLockfile: true);
    await checkToolVersions();
    await generate();
    await formatCheck();
    await analyze();
    await test();
    await buildAndroid();
    await buildDashboard();

    try {
      await supabaseStart();
      await supabaseReset();
      await supabaseTest();
      await supabaseLint();
    } finally {
      await supabaseStop(noBackup: true);
    }
    stdout.writeln('Complete Stone Set repository verification passed.');
  }

  Future<void> _supabase(List<String> arguments) => processes.run(
    ToolExecutables.npm,
    <String>['exec', '--', 'supabase', ...arguments],
    workingDirectory: workspace.rootPath,
  );
}
