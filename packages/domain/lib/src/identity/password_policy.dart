enum PasswordRequirement {
  minimumLength,
  lowercaseLetter,
  uppercaseLetter,
  digit,
  symbol,
}

final class PasswordValidation {
  const PasswordValidation(this.missingRequirements);

  final Set<PasswordRequirement> missingRequirements;

  bool get isValid => missingRequirements.isEmpty;
}

abstract final class PasswordPolicy {
  static const minimumLength = 12;

  static PasswordValidation validate(String password) {
    final missing = <PasswordRequirement>{};
    if (password.length < minimumLength) {
      missing.add(PasswordRequirement.minimumLength);
    }
    if (!RegExp('[a-z]').hasMatch(password)) {
      missing.add(PasswordRequirement.lowercaseLetter);
    }
    if (!RegExp('[A-Z]').hasMatch(password)) {
      missing.add(PasswordRequirement.uppercaseLetter);
    }
    if (!RegExp('[0-9]').hasMatch(password)) {
      missing.add(PasswordRequirement.digit);
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      missing.add(PasswordRequirement.symbol);
    }
    return PasswordValidation(Set<PasswordRequirement>.unmodifiable(missing));
  }
}
