import 'dart:convert';
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

  Future<void> formatCheck() {
    final sourcePaths =
        workspace.root
            .listSync(recursive: true, followLinks: false)
            .whereType<File>()
            .map((entry) => entry.path)
            .where(
              (path) =>
                  path.endsWith('.dart') &&
                  !path.endsWith('.g.dart') &&
                  !path.contains('${Platform.pathSeparator}.dart_tool${Platform.pathSeparator}') &&
                  !path.contains('${Platform.pathSeparator}build${Platform.pathSeparator}'),
            )
            .toList()
          ..sort();
    return processes.run(
      ToolExecutables.dart,
      <String>['format', '--output=none', '--set-exit-if-changed', ...sourcePaths],
      workingDirectory: workspace.rootPath,
    );
  }

  Future<void> stageMobileRankAssets() async {
    final sourceDirectory = Directory(workspace.path('assets/ranks'));
    final manifestFile = File('${sourceDirectory.path}${Platform.pathSeparator}manifest.json');
    final manifest = jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>;
    final assets = (manifest['assets'] as List<dynamic>).cast<Map<String, dynamic>>();
    if (assets.length != 20) {
      throw StateError('Expected 20 canonical rank assets, found ${assets.length}.');
    }

    final fileNames = assets.map((asset) => asset['filename'] as String).toSet();
    final validFileName = RegExp(r'^\d{2}_[a-z0-9_]+\.png$');
    if (fileNames.length != 20 || fileNames.any((fileName) => !validFileName.hasMatch(fileName))) {
      throw StateError(
        'Canonical rank asset filenames must be 20 unique safe PNG basenames.',
      );
    }

    final destinationDirectory = Directory(
      workspace.path('apps/mobile/.dart_tool/stone_set_assets/ranks'),
    );
    if (destinationDirectory.existsSync()) {
      destinationDirectory.deleteSync(recursive: true);
    }
    destinationDirectory.createSync(recursive: true);

    for (final fileName in fileNames) {
      final source = File('${sourceDirectory.path}${Platform.pathSeparator}$fileName');
      if (!source.existsSync()) {
        throw StateError('Missing canonical rank asset: $fileName');
      }
      await source.copy('${destinationDirectory.path}${Platform.pathSeparator}$fileName');
    }
  }

  Future<void> analyze() async {
    await stageMobileRankAssets();
    await processes.run(ToolExecutables.flutter, const <String>[
      'analyze',
      '--fatal-infos',
    ], workingDirectory: workspace.rootPath);
  }

  Future<void> generate() async {
    for (final application in const <String>['apps/mobile', 'apps/dashboard']) {
      await processes.run(ToolExecutables.dart, const <String>[
        'run',
        'build_runner',
        'build',
      ], workingDirectory: workspace.path(application));
    }
  }

  Future<void> test() async {
    await stageMobileRankAssets();
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

  Future<void> buildAndroid() async {
    await stageMobileRankAssets();
    await processes.run(
      ToolExecutables.flutter,
      const <String>['build', 'apk', '--release'],
      workingDirectory: workspace.path('apps/mobile'),
    );
  }

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
