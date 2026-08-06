import 'package:stone_set_workspace/src/tooling/process_service.dart';
import 'package:stone_set_workspace/src/tooling/repository_checker.dart';
import 'package:stone_set_workspace/src/tooling/stone_set_tasks.dart';
import 'package:stone_set_workspace/src/tooling/tool_version_checker.dart';
import 'package:stone_set_workspace/src/tooling/workspace.dart';
import 'package:test/test.dart';

void main() {
  test('generates both Flutter clients with deterministic conflict handling', () async {
    final processes = _RecordingProcessService();
    final tasks = _buildTasks(processes);

    await tasks.generate();

    expect(processes.calls, hasLength(2));
    for (final call in processes.calls) {
      expect(call.arguments, <String>[
        'run',
        'build_runner',
        'build',
        '--delete-conflicting-outputs',
      ]);
    }
    expect(processes.calls[0].workingDirectory.replaceAll('\\', '/'), endsWith('apps/mobile'));
    expect(
      processes.calls[1].workingDirectory.replaceAll('\\', '/'),
      endsWith('apps/dashboard'),
    );
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
        arguments: List<String>.unmodifiable(arguments),
        workingDirectory: workingDirectory,
      ),
    );
  }
}

final class _ProcessCall {
  const _ProcessCall({required this.arguments, required this.workingDirectory});

  final List<String> arguments;
  final String workingDirectory;
}
