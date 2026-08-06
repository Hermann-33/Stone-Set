import 'package:stone_set_domain/identity.dart';
import 'package:test/test.dart';

void main() {
  test('accepts a password meeting every requirement', () {
    expect(PasswordPolicy.validate('Correct-Horse7').isValid, isTrue);
  });

  test('reports every missing requirement', () {
    final validation = PasswordPolicy.validate('short');

    expect(
      validation.missingRequirements,
      containsAll(<PasswordRequirement>{
        PasswordRequirement.minimumLength,
        PasswordRequirement.uppercaseLetter,
        PasswordRequirement.digit,
        PasswordRequirement.symbol,
      }),
    );
  });
}
