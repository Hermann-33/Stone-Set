// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dashboardIdentityRepository)
final dashboardIdentityRepositoryProvider =
    DashboardIdentityRepositoryProvider._();

final class DashboardIdentityRepositoryProvider
    extends
        $FunctionalProvider<
          IdentityRepository,
          IdentityRepository,
          IdentityRepository
        >
    with $Provider<IdentityRepository> {
  DashboardIdentityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardIdentityRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardIdentityRepositoryHash();

  @$internal
  @override
  $ProviderElement<IdentityRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IdentityRepository create(Ref ref) {
    return dashboardIdentityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IdentityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IdentityRepository>(value),
    );
  }
}

String _$dashboardIdentityRepositoryHash() =>
    r'8e4c8368352345adf25d8dd94a6e24133f5ef4bc';

@ProviderFor(DashboardSessionController)
final dashboardSessionControllerProvider =
    DashboardSessionControllerProvider._();

final class DashboardSessionControllerProvider
    extends
        $NotifierProvider<DashboardSessionController, IdentitySessionState> {
  DashboardSessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardSessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardSessionControllerHash();

  @$internal
  @override
  DashboardSessionController create() => DashboardSessionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IdentitySessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IdentitySessionState>(value),
    );
  }
}

String _$dashboardSessionControllerHash() =>
    r'13cdf7c86e09af13a193e6b68790da5662e25ad7';

abstract class _$DashboardSessionController
    extends $Notifier<IdentitySessionState> {
  IdentitySessionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<IdentitySessionState, IdentitySessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<IdentitySessionState, IdentitySessionState>,
              IdentitySessionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
