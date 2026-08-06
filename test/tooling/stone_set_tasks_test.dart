import 'dart:io';

import 'package:stone_set_workspace/src/tooling/process_service.dart';
import 'package:stone_set_workspace/src/tooling/repository_checker.dart';
import 'package:stone_set_workspace/src/tooling/stone_set_tasks.dart';
import 'package:stone_set_workspace/src/tooling/tool_version_checker.dart';
import 'package:stone_set_workspace/src/tooling/workspace.dart';
import 'package:test/test.dart';

void main() {
  test('stages exactly the manifest-listed mobile rank assets', () async {
    final workspace = StoneSetWorkspace.current();
    final destination = Directory(
      workspace.path('apps/mobile/.dart_tool/stone_set_assets/ranks'),
    );
    destination.createSync(recursive: true);
    final staleFile = File(
      '${destination.path}${Platform.pathSeparator}stale.png',
    )..writeAsBytesSync(<int>[0]);
    final tasks = _buildTasks(_RecordingProcessService());

    await tasks.stageMobileRankAssets();

    expect(staleFile.existsSync(), isFalse);
    final stagedFiles =
        destination.listSync().whereType<File>().map((file) => file.uri.pathSegments.last).toList()
          ..sort();
    expect(stagedFiles, hasLength(20));
    expect(stagedFiles.first, '01_bronze_i.png');
    expect(stagedFiles.last, '20_adonis.png');
    for (final fileName in stagedFiles) {
      expect(
        File(workspace.path('assets/ranks/$fileName')).readAsBytesSync(),
        File(
          '${destination.path}${Platform.pathSeparator}$fileName',
        ).readAsBytesSync(),
      );
    }
  });

  test('generates both Flutter clients without ignored cleanup flags', () async {
    final processes = _RecordingProcessService();
    final tasks = _buildTasks(processes);

    await tasks.generate();

    expect(processes.calls, hasLength(2));
    for (final call in processes.calls) {
      expect(call.arguments, <String>[
        'run',
        'build_runner',
        'build',
      ]);
    }
    expect(processes.calls[0].workingDirectory.replaceAll('\\', '/'), endsWith('apps/mobile'));
    expect(
      processes.calls[1].workingDirectory.replaceAll('\\', '/'),
      endsWith('apps/dashboard'),
    );
  });

  test('format check excludes generated and build output', () async {
    final processes = _RecordingProcessService();
    final tasks = _buildTasks(processes);

    await tasks.formatCheck();

    final arguments = processes.calls.single.arguments;
    expect(arguments, contains(endsWith('stone_set_tasks.dart')));
    expect(arguments.where((path) => path.endsWith('.g.dart')), isEmpty);
    expect(arguments.where((path) => path.contains('.dart_tool')), isEmpty);
    expect(arguments.where((path) => path.contains('${Platform.pathSeparator}build')), isEmpty);
  });

  test('strict analysis uses the Flutter workspace entry point', () async {
    final processes = _RecordingProcessService();
    final tasks = _buildTasks(processes);

    await tasks.analyze();

    final call = processes.calls.single;
    expect(call.executable, ToolExecutables.flutter);
    expect(call.arguments, <String>['analyze', '--fatal-infos']);
  });

  group('supabaseStop', () {
    test('targets only the Stone Set project', () async {
      final processes = _RecordingProcessService();
      final tasks = _buildTasks(processes);

      await tasks.supabaseStop(noBackup: false);

      expect(processes.lastArguments, <String>[
        'exec',
        '--',
        'supabase',
        'stop',
        '--project-id',
        'stone-set',
      ]);
    });

    test('can also remove the targeted project volumes', () async {
      final processes = _RecordingProcessService();
      final tasks = _buildTasks(processes);

      await tasks.supabaseStop(noBackup: true);

      expect(processes.lastArguments, <String>[
        'exec',
        '--',
        'supabase',
        'stop',
        '--project-id',
        'stone-set',
        '--no-backup',
      ]);
    });
  });
}

StoneSetTasks _buildTasks(ProcessService processes) {
  final workspace = StoneSetWorkspace.current();
  return StoneSetTasks(
    workspace: workspace,
    processes: processes,
    repositoryChecker: RepositoryChecker(
      workspace: workspace,
      processes: processes,
    ),
    toolVersionChecker: ToolVersionChecker(
      workspace: workspace,
      processes: processes,
    ),
  );
}

final class _RecordingProcessService implements ProcessService {
  List<String>? lastArguments;
  final List<_ProcessCall> calls = <_ProcessCall>[];

  @override
  Future<String> capture(
    String executable,
    List<String> arguments, {
    required String workingDirectory,
  }) async => '';

  @override
  Future<void> run(
    String executable,
    List<String> arguments, {
    required String workingDirectory,
  }) async {
    lastArguments = arguments;
    calls.add(
      _ProcessCall(
        executable: executable,
        arguments: List<String>.unmodifiable(arguments),
        workingDirectory: workingDirectory,
      ),
    );
  }
}

final class _ProcessCall {
  const _ProcessCall({
    required this.executable,
    required this.arguments,
    required this.workingDirectory,
  });

  final String executable;
  final List<String> arguments;
  final String workingDirectory;
}
