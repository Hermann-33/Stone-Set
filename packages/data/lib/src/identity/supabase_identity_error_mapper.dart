import 'package:stone_set_domain/identity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

IdentityFailure mapSupabaseIdentityFailure(
  Object error, {
  IdentityErrorCode fallback = IdentityErrorCode.unknown,
}) {
  if (error is IdentityFailure) {
    return error;
  }
  final message = error.toString().toLowerCase();
  if (message.contains('429') || message.contains('rate limit')) {
    return const IdentityFailure(IdentityErrorCode.rateLimited);
  }
  if (message.contains('socket') || message.contains('network') || message.contains('connection')) {
    return const IdentityFailure(IdentityErrorCode.networkUnavailable);
  }
  if (error is AuthException &&
      (message.contains('invalid login') || message.contains('invalid credentials'))) {
    return const IdentityFailure(IdentityErrorCode.invalidCredentials);
  }
  return IdentityFailure(fallback);
}
