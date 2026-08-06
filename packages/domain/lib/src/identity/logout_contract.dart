enum LogoutDecision {
  resolutionRequired,
  synchronizeNow,
  remainSignedIn,
  discardAndLogout,
  logoutNow,
}

abstract interface class UnsynchronizedPrivateWork {
  Future<bool> hasUnsynchronizedPrivateWork(String userId);

  Future<bool> synchronizeNow(String userId);

  Future<void> discard(String userId);
}

abstract interface class PrivateWorkQuarantine {
  Future<void> quarantineForSessionLoss(String userId);
}

final class NoUnsynchronizedPrivateWork implements UnsynchronizedPrivateWork {
  const NoUnsynchronizedPrivateWork();

  @override
  Future<bool> hasUnsynchronizedPrivateWork(String userId) async => false;

  @override
  Future<bool> synchronizeNow(String userId) async => true;

  @override
  Future<void> discard(String userId) async {}
}

final class NoOpPrivateWorkQuarantine implements PrivateWorkQuarantine {
  const NoOpPrivateWorkQuarantine();

  @override
  Future<void> quarantineForSessionLoss(String userId) async {}
}
