enum IdentityErrorCode {
  invalidCredentials,
  rateLimited,
  networkUnavailable,
  profileUnavailable,
  profileDisabled,
  passwordChangeRequired,
  sessionExpired,
  clientIncompatible,
  maintenance,
  serverUnavailable,
  unknown,
}

final class IdentityFailure implements Exception {
  const IdentityFailure(this.code, {this.correlationId});

  final IdentityErrorCode code;
  final String? correlationId;

  @override
  String toString() => 'IdentityFailure(${code.name})';
}

final class IdentitySession {
  const IdentitySession({required this.userId, required this.expiresAt});

  final String userId;
  final DateTime? expiresAt;
}

final class IdentityProfile {
  const IdentityProfile({
    required this.userId,
    required this.normalizedUsername,
    required this.displayName,
    required this.active,
    required this.mustChangePassword,
    required this.rewardTimezone,
    this.revision = 1,
  });

  final String userId;
  final String normalizedUsername;
  final String displayName;
  final bool active;
  final bool mustChangePassword;
  final String rewardTimezone;
  final int revision;
}

final class IdentityPreferences {
  const IdentityPreferences({
    required this.loadUnit,
    required this.appearanceMode,
    required this.reducedMotion,
    required this.hapticsEnabled,
    required this.locale,
    this.restTimerSoundEnabled = true,
    this.workoutRemindersEnabled = false,
    this.reminderLocalTime,
    this.revision = 1,
  });

  final String loadUnit;
  final String appearanceMode;
  final bool reducedMotion;
  final bool hapticsEnabled;
  final String locale;
  final bool restTimerSoundEnabled;
  final bool workoutRemindersEnabled;
  final String? reminderLocalTime;
  final int revision;
}

final class IdentityCompatibility {
  const IdentityCompatibility({
    required this.maintenanceMode,
    required this.readOnlyMode,
    required this.clientCompatible,
    this.configVersion = 1,
    this.minimumBuild = 1,
    this.recommendedMobileBuild = 1,
    this.messageCode,
    this.messageText,
    this.features = const <String, Object?>{},
  });

  final bool maintenanceMode;
  final bool readOnlyMode;
  final bool clientCompatible;
  final int configVersion;
  final int minimumBuild;
  final int recommendedMobileBuild;
  final String? messageCode;
  final String? messageText;
  final Map<String, Object?> features;

  String? get message => messageText;
}

final class IdentityBootstrap {
  const IdentityBootstrap({
    required this.profile,
    required this.preferences,
    required this.compatibility,
    required this.serverTime,
    required this.correlationId,
    this.capabilities = const <String>{},
    this.schemaContract = 1,
  });

  final IdentityProfile profile;
  final IdentityPreferences preferences;
  final IdentityCompatibility compatibility;
  final DateTime serverTime;
  final String correlationId;
  final Set<String> capabilities;
  final int schemaContract;
}

enum IdentityAuthEventType {
  initialSession,
  signedIn,
  signedOut,
  passwordRecovery,
  tokenRefreshed,
  userUpdated,
  userDeleted,
  mfaChallengeVerified,
  streamError,
}

final class IdentityAuthEvent {
  const IdentityAuthEvent(this.type, {this.session, this.failure});

  final IdentityAuthEventType type;
  final IdentitySession? session;
  final IdentityFailure? failure;
}

enum IdentitySignOutScope { local, global, others }
