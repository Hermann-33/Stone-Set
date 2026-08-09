// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_private_cache.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dashboardPrivateCache)
final dashboardPrivateCacheProvider = DashboardPrivateCacheProvider._();

final class DashboardPrivateCacheProvider
    extends $FunctionalProvider<DashboardPrivateCache, DashboardPrivateCache, DashboardPrivateCache>
    with $Provider<DashboardPrivateCache> {
  DashboardPrivateCacheProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardPrivateCacheProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardPrivateCacheHash();

  @$internal
  @override
  $ProviderElement<DashboardPrivateCache> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DashboardPrivateCache create(Ref ref) {
    return dashboardPrivateCache(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardPrivateCache value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardPrivateCache>(value),
    );
  }
}

String _$dashboardPrivateCacheHash() => r'80dfb31aaf293cfa2093dc1d72805d0cadca2422';
