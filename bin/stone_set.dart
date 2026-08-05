import 'dart:io';

import 'package:args/command_runner.dart';

import 'package:stone_set_workspace/src/tooling/stone_set_runner.dart';

Future<void> main(List<String> arguments) async {
  final runner = buildStoneSetRunner();

  try {
    exitCode = await runner.run(arguments) ?? 0;
  } on UsageException catch (error) {
    stderr
      ..writeln(error.message)
      ..writeln()
      ..writeln(error.usage);
    exitCode = 64;
  } on Object catch (error, stackTrace) {
    stderr
      ..writeln('Stone Set tooling failed: $error')
      ..writeln(stackTrace);
    exitCode = 1;
  }
}
