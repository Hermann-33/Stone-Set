import 'package:stone_set_workspace/src/tooling/tool_version_checker.dart';
import 'package:test/test.dart';

void main() {
  test('parses the committed tool version schema', () {
    final versions = ToolVersions.parse('''
{
  "schemaVersion": 1,
  "flutter": "3.44.7",
  "dart": "3.12.2",
  "node": "24.11.1",
  "supabase": "2.111.0"
}
''');

    expect(versions.flutter, '3.44.7');
    expect(versions.dart, '3.12.2');
    expect(versions.node, '24.11.1');
    expect(versions.supabase, '2.111.0');
  });

  test('rejects an unsupported schema', () {
    expect(
      () => ToolVersions.parse('{"schemaVersion": 2}'),
      throwsFormatException,
    );
  });
}
