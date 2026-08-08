import 'package:stone_set_domain/exercise_guidance.dart';
import 'package:test/test.dart';

void main() {
  const alreadyNormalized = ExerciseGuidanceCanonicalizer(
    unicodeNormalizer: AlreadyNormalizedUnicodeNormalizer(),
  );

  test('SHA-256 implementation matches the published empty and abc vectors', () {
    expect(
      sha256Hex(const <int>[]),
      'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    );
    expect(
      sha256Hex(const <int>[0x61, 0x62, 0x63]),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
  });

  test('serializes PostgreSQL jsonb text and hashes an already-normalized golden fixture', () {
    final input = _goldenInput('Élite\u00a0 Press');

    expect(
      alreadyNormalized.contentJsonbText(input),
      '["stone-set-guidance-content-v1", "élite press", null, '
      '["dumbbell", "bench"], ["chest"], [], "Line 1\\nLine 2", '
      '["Brace"], ["Press \\"up\\""], [], [], []]',
    );
    expect(
      alreadyNormalized.contentHash(input),
      '932f2beb29b193d000915b6be781f527c8b1d1eabc9fa5f2c14ee8089ff704f4',
    );
    expect(
      alreadyNormalized.revisionHash(
        exerciseId: '11111111-1111-4111-8111-111111111111',
        ownerId: '22222222-2222-4222-8222-222222222222',
        versionNumber: 3,
        contentHash: alreadyNormalized.contentHash(input),
        supersedesRevisionId: null,
      ),
      '91e6a2615d09fe1cea9060d03fbb74a547558edc2122bab7f9850a1d824750d1',
    );
  });

  test('injected NFC normalizer proves decomposed input can match the golden', () {
    const canonicalizer = ExerciseGuidanceCanonicalizer(unicodeNormalizer: _FixtureNfcNormalizer());

    expect(
      canonicalizer.contentHash(_goldenInput('E\u0301lite\u00a0 Press')),
      alreadyNormalized.contentHash(_goldenInput('Élite\u00a0 Press')),
    );
  });

  test('rejects NUL and disallowed controls without claiming server authority', () {
    expect(
      () => alreadyNormalized.normalizeGuidanceString('Unsafe\u0000value'),
      throwsFormatException,
    );
    expect(alreadyNormalized.normalizeGuidanceString('Tabs\tstay'), 'Tabs\tstay');
  });
}

GuidanceCanonicalInput _goldenInput(String name) => GuidanceCanonicalInput(
  canonicalName: '  $name ',
  variantKey: null,
  equipmentKeys: const <String>['dumbbell', 'bench'],
  primaryMuscleKeys: const <String>['chest'],
  secondaryMuscleKeys: const <String>[],
  content: GuidanceContentV1(
    shortExplanation: 'Line 1\r\nLine 2',
    setupSteps: const <String>['  Brace  '],
    executionSteps: const <String>['Press "up"'],
  ),
);

final class _FixtureNfcNormalizer implements UnicodeNormalizer {
  const _FixtureNfcNormalizer();

  @override
  String normalizeNfc(String value) => value.replaceAll('E\u0301', 'É');
}
