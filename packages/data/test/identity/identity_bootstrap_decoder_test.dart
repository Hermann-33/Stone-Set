import 'package:flutter_test/flutter_test.dart';
import 'package:stone_set_data/stone_set_data.dart';
import 'package:stone_set_domain/identity.dart';

void main() {
  test('decodes the current get_authenticated_bootstrap contract', () {
    final bootstrap = decodeIdentityBootstrapResponse(<String, Object?>{
      'state': 'password_change_required',
      'correlationId': '00000000-0000-4000-8000-000000000099',
      'serverTime': '2026-08-06T00:00:00Z',
      'schemaContract': 1,
      'readOnly': false,
      'compatibility': <String, Object?>{
        'configVersion': 1,
        'minimumBuild': 1,
        'recommendedMobileBuild': 1,
        'messageCode': null,
        'messageText': null,
        'features': <String, Object?>{},
      },
      'profile': <String, Object?>{
        'id': '00000000-0000-4000-8000-000000000001',
        'username': 'member_one',
        'displayName': 'Member One',
        'active': true,
        'mustChangePassword': true,
        'rewardTimezone': 'Etc/UTC',
        'revision': 1,
      },
      'preferences': <String, Object?>{
        'loadUnit': 'kg',
        'appearanceMode': 'system',
        'reducedMotion': false,
        'hapticsEnabled': true,
        'restTimerSoundEnabled': true,
        'workoutRemindersEnabled': false,
        'reminderLocalTime': null,
        'locale': 'en',
        'revision': 1,
      },
      'capabilities': <Object?>['routine_reviewer'],
    });

    expect(bootstrap.profile.normalizedUsername, 'member_one');
    expect(bootstrap.profile.mustChangePassword, isTrue);
    expect(bootstrap.preferences.loadUnit, 'kg');
    expect(bootstrap.capabilities, <String>{'routine_reviewer'});
  });

  test('maps a session-expired bootstrap without requiring profile data', () {
    expect(
      () => decodeIdentityBootstrapResponse(<String, Object?>{
        'state': 'session_expired',
        'correlationId': '00000000-0000-4000-8000-000000000099',
        'serverTime': '2026-08-06T00:00:00Z',
        'schemaContract': 1,
      }),
      throwsA(
        isA<IdentityFailure>().having(
          (failure) => failure.code,
          'code',
          IdentityErrorCode.sessionExpired,
        ),
      ),
    );
  });
}
