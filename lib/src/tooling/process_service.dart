import 'dart:async';
import 'dart:io';

final class ToolProcessException implements Exception {
  const ToolProcessException(this.executable, this.arguments, this.exitCode);

  final String executable;
  final List<String> arguments;
  final int exitCode;

  @override
  String toString() =>
      'Command failed with exit code $exitCode: ${_displayCommand(executable, arguments)}';
}

abstract interface class ProcessService {
  Future<void> run(
    String executable,
    List<String> arguments, {
    required String workingDirectory,
  });

  Future<String> capture(
    String executable,
    List<String> arguments, {
    required String workingDirectory,
  });
}

final class LocalProcessService implements ProcessService {
  const LocalProcessService();

  @override
  Future<void> run(
    String executable,
    List<String> arguments, {
    required String workingDirectory,
  }) async {
    stdout.writeln('> ${_displayCommand(executable, arguments)}');
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      runInShell: Platform.isWindows && _requiresShell(executable),
    );
    final drains = <Future<void>>[
      stdout.addStream(process.stdout),
      stderr.addStream(process.stderr),
    ];
    final result = await process.exitCode;
    await Future.wait(drains);
    if (result != 0) {
      throw ToolProcessException(executable, arguments, result);
    }
  }

  @override
  Future<String> capture(
    String executable,
    List<String> arguments, {
    required String workingDirectory,
  }) async {
    stdout.writeln('> ${_displayCommand(executable, arguments)}');
    final result = await Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      runInShell: Platform.isWindows && _requiresShell(executable),
      stdoutEncoding: systemEncoding,
      stderrEncoding: systemEncoding,
    );
    if (result.exitCode != 0) {
      final errorOutput = (result.stderr as String).trim();
      if (errorOutput.isNotEmpty) {
        stderr.writeln(errorOutput);
      }
      throw ToolProcessException(executable, arguments, result.exitCode);
    }
    return (result.stdout as String).trim();
  }
}

bool _requiresShell(String executable) {
  final lower = executable.toLowerCase();
  return lower.endsWith('.bat') || lower.endsWith('.cmd');
}

String _displayCommand(String executable, List<String> arguments) =>
    <String>[executable, ...arguments].map(_quoteArgument).join(' ');

String _quoteArgument(String argument) {
  if (!argument.contains(RegExp(r'\s'))) {
    return argument;
  }
  return '"${argument.replaceAll('"', r'\"')}"';
}
