import 'identity_models.dart';
import 'username_alias.dart';

abstract interface class IdentityRepository {
  Stream<IdentityAuthEvent> get authEvents;

  Future<IdentitySession?> recoverSession();

  Future<IdentitySession> refreshSession();

  Future<void> signIn({required NormalizedUsername username, required String password});

  Future<IdentityBootstrap> bootstrap();

  Future<IdentityBootstrap> completeRequiredPasswordChange(String newPassword);

  Future<void> signOut({IdentitySignOutScope scope = IdentitySignOutScope.local});
}
