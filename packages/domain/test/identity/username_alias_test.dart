import 'package:stone_set_domain/identity.dart';
import 'package:test/test.dart';

void main() {
  group('NormalizedUsername', () {
    test('trims and lowercases an accepted username', () {
      expect(NormalizedUsername.parse('  User_01  ').value, 'user_01');
    });

    for (final invalid in <String>['ab', '1user', '_user', 'user-name', 'a' * 33]) {
      test('rejects $invalid', () {
        expect(() => NormalizedUsername.parse(invalid), throwsFormatException);
      });
    }
  });

  test('derives an alias from normalized public configuration', () {
    final mapper = UsernameAliasMapper(' Auth.StoneSet.Test ');

    expect(mapper.map(NormalizedUsername.parse('Member_1')), 'member_1@auth.stoneset.test');
  });

  test('rejects malformed alias domains', () {
    expect(() => UsernameAliasMapper('invalid'), throwsFormatException);
    expect(() => UsernameAliasMapper('bad@example.test'), throwsFormatException);
  });
}
