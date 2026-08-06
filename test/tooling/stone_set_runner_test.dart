import 'package:stone_set_workspace/src/tooling/process_service.dart';
import 'package:stone_set_workspace/src/tooling/repository_checker.dart';
import 'package:stone_set_workspace/src/tooling/stone_set_runner.dart';
import 'package:stone_set_workspace/src/tooling/stone_set_tasks.dart';
import 'package:stone_set_workspace/src/tooling/tool_version_checker.dart';
import 'package:stone_set_workspace/src/tooling/workspace.dart';
import 'package:test/test.dart';

void main() {
  test('exposes every required root command', () {
    final workspace = StoneSetWorkspace.current();
    const processes = _NoopProcessService();
    final tasks = StoneSetTasks(
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
    final runner = buildStoneSetRunner(tasks: tasks);

    expect(
      runner.commands.keys,
      containsAll(<String>{
        'restore',
        'stage-rank-assets',
        'generate',
        'format-check',
        'analyze',
        'test',
        'build-android',
        'build-dashboard',
        'supabase-start',
        'supabase-reset',
        'supabase-test',
        'supabase-lint',
        'supabase-stop',
        'repository-check',
        'tool-version-check',
        'verify',
      }),
    );
  });
}

final class _NoopProcessService implements ProcessService {
  const _NoopProcessService();

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
  }) async {}
}
