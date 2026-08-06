import 'package:stone_set_domain/identity.dart';

String identityMessage(IdentityFailure? failure) => switch (failure?.code) {
  IdentityErrorCode.rateLimited => 'Too many attempts. Wait a moment and try again.',
  IdentityErrorCode.networkUnavailable => 'You’re offline. Reconnect and try again.',
  IdentityErrorCode.sessionExpired => 'Your session ended. Sign in again to continue.',
  IdentityErrorCode.clientIncompatible => 'Update Stone Set before continuing.',
  IdentityErrorCode.maintenance => 'Stone Set is temporarily unavailable.',
  IdentityErrorCode.serverUnavailable => 'Stone Set could not complete that request. Try again.',
  _ => 'Unable to sign in. Check your details and try again.',
};
