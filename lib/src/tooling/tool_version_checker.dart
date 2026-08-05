import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import 'process_service.dart';
import 'workspace.dart';

final class ToolVersions {
  const ToolVersions({
    required this.flutter,
    required this.dart,
    required this.node,
    required this.supabase,
  });

  final String flutter;
  final String dart;
  final String node;
  final String supabase;

  factory ToolVersions.parse(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, Object?> || decoded['schemaVersion'] != 1) {
      throw const FormatException('Unsupported tool version file schema.');
    }
    return ToolVersions(
      flutter: _requiredString(decoded, 'flutter'),
      dart: _requiredString(decoded, 'dart'),
      node: _requiredString(decoded, 'node'),
      supabase: _requiredString(decoded, 'supabase'),
    );
  }
}

final class ToolVersionChecker {
  const ToolVersionChecker({required this.workspace, required this.processes});

  final StoneSetWorkspace workspace;
  final ProcessService processes;

  Future<void> check() async {
    final expected = ToolVersions.parse(
      File(workspace.path('tool', 'tool_versions.json')).readAsStringSync(),
    );
    final flutterOutput = await processes.capture(
      ToolExecutables.flutter,
      const <String>['--version', '--machine'],
      workingDirectory: workspace.rootPath,
    );
    final flutterData = jsonDecode(flutterOutput);
    if (flutterData is! Map<String, Object?>) {
      throw const FormatException(
        'Flutter returned invalid machine-readable version data.',
      );
    }
    _expectVersion('Flutter', expected.flutter, flutterData['flutterVersion']);
    _expectVersion('Dart', expected.dart, flutterData['dartSdkVersion']);

    final nodeOutput = await processes.capture(
      ToolExecutables.node,
      const <String>['--version'],
      workingDirectory: workspace.rootPath,
    );
    _expectVersion(
      'Node',
      expected.node,
      nodeOutput.replaceFirst(RegExp('^v'), ''),
    );

    final packageJson = jsonDecode(
      File(workspace.path('package.json')).readAsStringSync(),
    );
    if (packageJson is! Map<String, Object?>) {
      throw const FormatException('package.json must contain a JSON object.');
    }
    final devDependencies = packageJson['devDependencies'];
    if (devDependencies is! Map<String, Object?>) {
      throw const FormatException('package.json must define devDependencies.');
    }
    _expectVersion(
      'Supabase CLI package',
      expected.supabase,
      devDependencies['supabase'],
    );
    final engines = packageJson['engines'];
    if (engines is! Map<String, Object?>) {
      throw const FormatException('package.json must define engines.');
    }
    _expectVersion('Node package engine', expected.node, engines['node']);

    final packageLock = jsonDecode(
      File(workspace.path('package-lock.json')).readAsStringSync(),
    );
    if (packageLock is! Map<String, Object?>) {
      throw const FormatException(
        'package-lock.json must contain a JSON object.',
      );
    }
    final lockedPackages = packageLock['packages'];
    if (lockedPackages is! Map<String, Object?>) {
      throw const FormatException('package-lock.json must define packages.');
    }
    final lockedSupabase = lockedPackages['node_modules/supabase'];
    if (lockedSupabase is! Map<String, Object?>) {
      throw const FormatException(
        'package-lock.json must lock the Supabase CLI package.',
      );
    }
    _expectVersion(
      'Locked Supabase CLI package',
      expected.supabase,
      lockedSupabase['version'],
    );

    final pubspec = loadYaml(
      File(workspace.path('pubspec.yaml')).readAsStringSync(),
    );
    if (pubspec is! YamlMap) {
      throw const FormatException('Root pubspec.yaml must contain a YAML map.');
    }
    final environment = pubspec['environment'];
    if (environment is! YamlMap || !(environment['sdk'] as String).contains(expected.dart)) {
      throw StateError(
        'Root SDK constraint must include Dart ${expected.dart}.',
      );
    }

    stdout.writeln(
      'Tool versions match: Flutter ${expected.flutter}, Dart ${expected.dart}, '
      'Node ${expected.node}, Supabase ${expected.supabase}.',
    );
  }
}

String _requiredString(Map<String, Object?> values, String key) {
  final value = values[key];
  if (value is! String || value.isEmpty) {
    throw FormatException('Missing tool version: $key.');
  }
  return value;
}

void _expectVersion(String tool, String expected, Object? actual) {
  if (actual != expected) {
    throw StateError(
      '$tool version mismatch: expected $expected, found $actual.',
    );
  }
}
