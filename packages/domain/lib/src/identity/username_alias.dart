final class UsernameValidationException implements FormatException {
  const UsernameValidationException(this.message, this.source);

  @override
  final String message;

  @override
  final Object? source;

  @override
  int? get offset => null;

  @override
  String toString() => message;
}

final class NormalizedUsername {
  const NormalizedUsername._(this.value);

  static final RegExp _grammar = RegExp(r'^[a-z][a-z0-9_]{2,31}$');

  final String value;

  static NormalizedUsername parse(String input) {
    final normalized = input.trim().toLowerCase();
    if (!_grammar.hasMatch(normalized)) {
      throw UsernameValidationException(
        'Use 3-32 lowercase letters, numbers, or underscores, starting with a letter.',
        input,
      );
    }
    return NormalizedUsername._(normalized);
  }

  @override
  bool operator ==(Object other) => other is NormalizedUsername && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

final class UsernameAliasMapper {
  UsernameAliasMapper(String domain) : domain = _validateDomain(domain);

  final String domain;

  String map(NormalizedUsername username) => '${username.value}@$domain';

  static String _validateDomain(String input) {
    final normalized = input.trim().toLowerCase();
    if (normalized.isEmpty ||
        normalized.contains('@') ||
        normalized.startsWith('.') ||
        normalized.endsWith('.') ||
        !normalized.contains('.')) {
      throw FormatException('The authentication alias domain is invalid.');
    }
    return normalized;
  }
}
