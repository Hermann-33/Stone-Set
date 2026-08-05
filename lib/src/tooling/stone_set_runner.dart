import 'package:args/command_runner.dart';

import 'process_service.dart';
import 'repository_checker.dart';
import 'stone_set_tasks.dart';
import 'tool_version_checker.dart';
import 'workspace.dart';

CommandRunner<int> buildStoneSetRunner({StoneSetTasks? tasks}) {
  final selectedTasks = tasks ?? _buildLocalTasks();
  return CommandRunner<int>(
      'stone_set',
      'Stone Set repository development commands.',
    )
    ..addCommand(_RestoreCommand(selectedTasks))
    ..addCommand(
      _TaskCommand(
        'format-check',
        'Check Dart formatting.',
        selectedTasks.formatCheck,
      ),
    )
    ..addCommand(
      _TaskCommand(
        'analyze',
        'Run strict Dart analysis.',
        selectedTasks.analyze,
      ),
    )
    ..addCommand(
      _TaskCommand(
        'test',
        'Run all unit and widget tests.',
        selectedTasks.test,
      ),
    )
    ..addCommand(
      _TaskCommand(
        'build-android',
        'Build the Android release APK.',
        selectedTasks.buildAndroid,
      ),
    )
    ..addCommand(
      _TaskCommand(
        'build-dashboard',
        'Build the dashboard release web bundle.',
        selectedTasks.buildDashboard,
      ),
    )
    ..addCommand(
      _TaskCommand(
        'supabase-start',
        'Start the local Supabase stack.',
        selectedTasks.supabaseStart,
      ),
    )
    ..addCommand(
      _TaskCommand(
        'supabase-reset',
        'Reset the local Supabase database.',
        selectedTasks.supabaseReset,
      ),
    )
    ..addCommand(
      _TaskCommand(
        'supabase-test',
        'Run local pgTAP database tests.',
        selectedTasks.supabaseTest,
      ),
    )
    ..addCommand(
      _TaskCommand(
        'supabase-lint',
        'Lint the local database.',
        selectedTasks.supabaseLint,
      ),
    )
    ..addCommand(_SupabaseStopCommand(selectedTasks))
    ..addCommand(
      _TaskCommand(
        'repository-check',
        'Check workspace, dependency, platform, generated, and secret boundaries.',
        selectedTasks.checkRepository,
      ),
    )
    ..addCommand(
      _TaskCommand(
        'tool-version-check',
        'Verify pinned Flutter, Dart, Node, and Supabase versions.',
        selectedTasks.checkToolVersions,
      ),
    )
    ..addCommand(
      _TaskCommand(
        'verify',
        'Run complete foundation verification.',
        selectedTasks.verify,
      ),
    );
}

StoneSetTasks _buildLocalTasks() {
  final workspace = StoneSetWorkspace.current();
  const processes = LocalProcessService();
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

final class _TaskCommand extends Command<int> {
  _TaskCommand(this.name, this.description, this._action);

  @override
  final String name;

  @override
  final String description;

  final Future<void> Function() _action;

  @override
  Future<int> run() async {
    await _action();
    return 0;
  }
}

final class _RestoreCommand extends Command<int> {
  _RestoreCommand(this._tasks) {
    argParser.addFlag(
      'enforce-lockfile',
      help: 'Fail unless pubspec.lock exactly satisfies every workspace pubspec.',
    );
  }

  final StoneSetTasks _tasks;

  @override
  String get name => 'restore';

  @override
  String get description => 'Restore Dart/Flutter and npm dependencies.';

  @override
  Future<int> run() async {
    await _tasks.restore(
      enforceLockfile: argResults?['enforce-lockfile'] as bool? ?? false,
    );
    return 0;
  }
}

final class _SupabaseStopCommand extends Command<int> {
  _SupabaseStopCommand(this._tasks) {
    argParser.addFlag(
      'no-backup',
      help: 'Delete local Supabase data volumes after stopping.',
    );
  }

  final StoneSetTasks _tasks;

  @override
  String get name => 'supabase-stop';

  @override
  String get description => 'Stop the local Supabase stack.';

  @override
  Future<int> run() async {
    await _tasks.supabaseStop(
      noBackup: argResults?['no-backup'] as bool? ?? false,
    );
    return 0;
  }
}
