import 'package:stone_set_workspace/src/tooling/repository_checker.dart';
import 'package:test/test.dart';

void main() {
  group('generated path classification', () {
    test('rejects generated and local state', () {
      expect(
        isForbiddenGeneratedPath('apps/mobile/.dart_tool/package_config.json'),
        isTrue,
      );
      expect(
        isForbiddenGeneratedPath('apps/dashboard/build/web/index.html'),
        isTrue,
      );
      expect(isForbiddenGeneratedPath('supabase/.temp/project-ref'), isTrue);
      expect(isForbiddenGeneratedPath('.vercel/project.json'), isTrue);
    });

    test('allows committed product assets', () {
      expect(isForbiddenGeneratedPath('assets/ranks/01_bronze_i.png'), isFalse);
      expect(isForbiddenGeneratedPath('supabase/config.toml'), isFalse);
    });
  });

  group('secret path classification', () {
    test('rejects credentials and signing state', () {
      expect(isForbiddenSecretPath('.env.local'), isTrue);
      expect(
        isForbiddenSecretPath('apps/mobile/android/key.properties'),
        isTrue,
      );
      expect(isForbiddenSecretPath('release/upload.jks'), isTrue);
      expect(
        isForbiddenSecretPath('config/dart_defines.production.json'),
        isTrue,
      );
    });

    test('allows explicit examples', () {
      expect(isForbiddenSecretPath('.env.example'), isFalse);
      expect(
        isForbiddenSecretPath('config/dart_defines.example.json'),
        isFalse,
      );
    });
  });
}
