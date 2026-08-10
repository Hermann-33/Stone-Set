import 'dart:io';

import 'package:yaml/yaml.dart';

import 'process_service.dart';
import 'workspace.dart';

const List<String> requiredWorkspaceMembers = <String>[
  'apps/mobile',
  'apps/dashboard',
  'packages/domain',
  'packages/data',
  'packages/ui',
];

const List<String> _requiredRepositoryPaths = <String>[
  'AGENTS.md',
  'README.md',
  'analysis_options.yaml',
  'pubspec.yaml',
  'pubspec.lock',
  'package.json',
  'package-lock.json',
  'tool/tool_versions.json',
  'config/README.md',
  'config/dart_defines.example.json',
  'supabase/config.toml',
  'supabase/seed.sql',
  'apps/dashboard/vercel.json',
  'docs/context/ACTIVE_CONTEXT.md',
  'docs/context/PROJECT_BRIEF.md',
  'docs/context/ARCHITECTURE.md',
  'docs/context/CODEBASE_MAP.md',
  'docs/context/ROADMAP.md',
  'docs/context/WORKFLOW.md',
  'docs/context/HANDOFF.md',
  'docs/context/IMPLEMENTATION_PLAN.md',
  'docs/product/AUTHENTICATION_AND_SESSION_UX.md',
  'docs/product/ROUTINE_ELIGIBILITY.md',
  'docs/product/EXERCISE_GUIDANCE_AND_MEDIA.md',
  'docs/product/RANK_SYSTEM.md',
  'docs/product/WEEKLY_SCHEDULING.md',
  'docs/product/APPLICATION_WORKFLOW.md',
  'docs/tasks/TASK-IMP-001.md',
  'docs/decisions/ADR-0001-flutter-client-platforms.md',
  'docs/decisions/ADR-0002-supabase-backend-auth-and-persistence.md',
  'docs/decisions/ADR-0003-local-workout-drafts-and-online-finalization.md',
  'docs/decisions/ADR-0004-android-first-and-vercel-dashboard-hosting.md',
  'docs/decisions/ADR-0005-supabase-production-operations-and-recovery.md',
  'docs/decisions/ADR-0006-exercise-media-storage-and-youtube-embedding.md',
];

final class RepositoryChecker {
  const RepositoryChecker({required this.workspace, required this.processes});

  final StoneSetWorkspace workspace;
  final ProcessService processes;

  Future<void> check() async {
    final problems = <String>[];
    _checkRequiredPaths(problems);
    _checkWorkspace(problems);
    _checkAnalysisOptions(problems);
    _checkSupabaseTests(problems);
    _checkLockfiles(problems);
    _checkPlatformDirectories(problems);
    await _checkTrackedFiles(problems);

    if (problems.isNotEmpty) {
      throw StateError('Repository checks failed:\n- ${problems.join('\n- ')}');
    }
    stdout.writeln('Repository structure and hygiene checks passed.');
  }

  void _checkRequiredPaths(List<String> problems) {
    for (final path in _requiredRepositoryPaths) {
      if (!File(workspace.path(path)).existsSync()) {
        problems.add('Missing required repository file: $path');
      }
    }
  }

  void _checkWorkspace(List<String> problems) {
    final rootPubspec = _readYamlMap(workspace.path('pubspec.yaml'));
    final workspaceValue = rootPubspec['workspace'];
    final actualMembers = workspaceValue is YamlList
        ? workspaceValue.nodes.map((node) => node.value).whereType<String>().toList(growable: false)
        : const <String>[];
    if (!_sameOrderedValues(actualMembers, requiredWorkspaceMembers)) {
      problems.add(
        'Root workspace members must exactly match $requiredWorkspaceMembers.',
      );
    }

    final packageNames = <String, String>{};
    final memberPubspecs = <String, YamlMap>{};
    for (final member in requiredWorkspaceMembers) {
      final pubspecPath = workspace.path(member, 'pubspec.yaml');
      if (!File(pubspecPath).existsSync()) {
        problems.add('Missing workspace pubspec: $member/pubspec.yaml');
        continue;
      }
      final pubspec = _readYamlMap(pubspecPath);
      memberPubspecs[member] = pubspec;
      if (pubspec['resolution'] != 'workspace') {
        problems.add('$member must declare resolution: workspace.');
      }
      if (pubspec['publish_to'] != 'none') {
        problems.add('$member must declare publish_to: none.');
      }
      final name = pubspec['name'];
      if (name is! String || !name.startsWith('stone_set_')) {
        problems.add(
          '$member must have a unique Stone Set-specific package name.',
        );
      } else if (packageNames.containsKey(name)) {
        problems.add('Duplicate workspace package name $name.');
      } else {
        packageNames[name] = member;
      }
    }
    _checkDependencyDirection(memberPubspecs, packageNames, problems);
  }

  void _checkDependencyDirection(
    Map<String, YamlMap> pubspecs,
    Map<String, String> packageNames,
    List<String> problems,
  ) {
    const allowed = <String, Set<String>>{
      'apps/mobile': {'packages/domain', 'packages/data', 'packages/ui'},
      'apps/dashboard': {'packages/domain', 'packages/data', 'packages/ui'},
      'packages/domain': {},
      'packages/data': {'packages/domain'},
      'packages/ui': {},
    };

    for (final entry in pubspecs.entries) {
      for (final sectionName in const <String>[
        'dependencies',
        'dev_dependencies',
      ]) {
        final section = entry.value[sectionName];
        if (section is! YamlMap) {
          continue;
        }
        for (final dependency in section.keys.whereType<String>()) {
          final target = packageNames[dependency];
          if (target != null && !allowed[entry.key]!.contains(target)) {
            problems.add(
              '${entry.key} may not depend on $target via $sectionName.',
            );
          }
        }
      }
    }
  }

  void _checkLockfiles(List<String> problems) {
    final lockfiles = workspace.root
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((file) => _basename(file.path) == 'pubspec.lock')
        .where((file) => !_relativePath(file.path).startsWith('.git/'))
        .map((file) => _relativePath(file.path))
        .toList(growable: false);
    if (!_sameOrderedValues(lockfiles, const <String>['pubspec.lock'])) {
      problems.add(
        'Exactly one root pubspec.lock is required; found $lockfiles.',
      );
    }
  }

  void _checkAnalysisOptions(List<String> problems) {
    for (final member in requiredWorkspaceMembers) {
      final path = workspace.path(member, 'analysis_options.yaml');
      final file = File(path);
      if (!file.existsSync()) {
        continue;
      }
      final options = _readYamlMap(path);
      if (options['include'] != '../../analysis_options.yaml') {
        problems.add(
          '$member/analysis_options.yaml must include ../../analysis_options.yaml so the shared '
          'strict policy cannot be bypassed.',
        );
      }
    }
  }

  void _checkPlatformDirectories(List<String> problems) {
    const required = <String, String>{
      'apps/mobile': 'android',
      'apps/dashboard': 'web',
    };
    for (final entry in required.entries) {
      if (!Directory(workspace.path(entry.key, entry.value)).existsSync()) {
        problems.add(
          '${entry.key} is missing required platform directory: ${entry.value}',
        );
      }
    }

    const forbidden = <String, List<String>>{
      'apps/mobile': ['ios', 'web', 'linux', 'macos', 'windows'],
      'apps/dashboard': ['android', 'ios', 'linux', 'macos', 'windows'],
    };
    for (final entry in forbidden.entries) {
      for (final platform in entry.value) {
        if (Directory(workspace.path(entry.key, platform)).existsSync()) {
          problems.add(
            '${entry.key} contains forbidden platform directory: $platform',
          );
        }
      }
    }
  }

  void _checkSupabaseTests(List<String> problems) {
    final testDirectory = Directory(workspace.path('supabase/tests/database'));
    if (!testDirectory.existsSync() ||
        !testDirectory
            .listSync(followLinks: false)
            .whereType<File>()
            .any((file) => file.path.toLowerCase().endsWith('.sql'))) {
      problems.add(
        'supabase/tests/database must contain at least one pgTAP SQL test.',
      );
    }
  }

  Future<void> _checkTrackedFiles(List<String> problems) async {
    final output = await processes.capture('git', const <String>[
      'ls-files',
      '-z',
    ], workingDirectory: workspace.rootPath);
    for (final rawPath in output.split('\u0000')) {
      if (rawPath.isEmpty) {
        continue;
      }
      final path = rawPath.replaceAll('\\', '/');
      if (isForbiddenGeneratedPath(path)) {
        problems.add('Generated or local-only path is tracked: $path');
      }
      if (isForbiddenSecretPath(path)) {
        problems.add('Potential secret or signing file is tracked: $path');
      }
    }
  }

  String _relativePath(String path) => path
      .substring(workspace.rootPath.length)
      .replaceAll('\\', '/')
      .replaceFirst(RegExp('^/'), '');
}

bool isForbiddenGeneratedPath(String path) {
  final normalized = '/${path.replaceAll('\\', '/').toLowerCase()}/';
  return normalized.contains('/.dart_tool/') ||
      normalized.contains('/build/') ||
      normalized.contains('/coverage/') ||
      normalized.contains('/node_modules/') ||
      normalized.contains('/.vercel/') ||
      normalized.contains('/supabase/.temp/') ||
      normalized.contains('/supabase/.branches/');
}

bool isForbiddenSecretPath(String path) {
  final normalized = path.replaceAll('\\', '/').toLowerCase();
  final name = normalized.split('/').last;
  if (name == '.env.example' ||
      name == 'dart_defines.example.json' ||
      normalized == 'config/dart_defines.release.json') {
    return false;
  }
  if (name == '.env' || name.startsWith('.env.')) {
    return true;
  }
  if (normalized.startsWith('config/dart_defines.') && name != 'dart_defines.example.json') {
    return true;
  }
  if (<String>{
    'key.properties',
    'local.properties',
    'google-services.json',
  }.contains(name)) {
    return true;
  }
  return <String>{
    '.jks',
    '.keystore',
    '.p12',
    '.pfx',
    '.pem',
    '.key',
  }.any(name.endsWith);
}

YamlMap _readYamlMap(String path) {
  final value = loadYaml(File(path).readAsStringSync());
  if (value is! YamlMap) {
    throw FormatException('$path must contain a YAML map.');
  }
  return value;
}

bool _sameOrderedValues(List<String> left, List<String> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}

String _basename(String path) => path.replaceAll('\\', '/').split('/').last;
