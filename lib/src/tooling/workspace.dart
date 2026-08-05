import 'dart:io';

final class StoneSetWorkspace {
  StoneSetWorkspace._(this.root);

  factory StoneSetWorkspace.current() {
    final root = Directory.current.absolute;
    if (!File(_join(root.path, 'pubspec.yaml')).existsSync()) {
      throw StateError('Run Stone Set commands from the repository root.');
    }
    return StoneSetWorkspace._(root);
  }

  final Directory root;

  String get rootPath => root.path;

  String path(String first, [String? second, String? third]) {
    var result = _join(root.path, first);
    if (second != null) {
      result = _join(result, second);
    }
    if (third != null) {
      result = _join(result, third);
    }
    return result;
  }
}

final class ToolExecutables {
  ToolExecutables._();

  static String get dart => Platform.resolvedExecutable;

  static String get flutter {
    final configuredRoot = Platform.environment['FLUTTER_ROOT'];
    if (configuredRoot != null && configuredRoot.isNotEmpty) {
      final configured = _join(
        _join(configuredRoot, 'bin'),
        Platform.isWindows ? 'flutter.bat' : 'flutter',
      );
      if (File(configured).existsSync()) {
        return configured;
      }
    }

    var directory = File(Platform.resolvedExecutable).parent;
    for (var index = 0; index < 3; index += 1) {
      directory = directory.parent;
    }
    final bundled = _join(
      directory.path,
      Platform.isWindows ? 'flutter.bat' : 'flutter',
    );
    if (File(bundled).existsSync()) {
      return bundled;
    }
    return Platform.isWindows ? 'flutter.bat' : 'flutter';
  }

  static String get npm => Platform.isWindows ? 'npm.cmd' : 'npm';

  static String get node => Platform.isWindows ? 'node.exe' : 'node';
}

String _join(String parent, String child) => '$parent${Platform.pathSeparator}$child';
