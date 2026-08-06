// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mobileClientConfiguration)
final mobileClientConfigurationProvider = MobileClientConfigurationProvider._();

final class MobileClientConfigurationProvider
    extends
        $FunctionalProvider<
          MobileClientConfiguration,
          MobileClientConfiguration,
          MobileClientConfiguration
        >
    with $Provider<MobileClientConfiguration> {
  MobileClientConfigurationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mobileClientConfigurationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mobileClientConfigurationHash();

  @$internal
  @override
  $ProviderElement<MobileClientConfiguration> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MobileClientConfiguration create(Ref ref) {
    return mobileClientConfiguration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MobileClientConfiguration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MobileClientConfiguration>(value),
    );
  }
}

String _$mobileClientConfigurationHash() =>
    r'25ad52ab1a4b555162f7aa911ac8dbdf6cc214f0';

@ProviderFor(supabaseClient)
final supabaseClientProvider = SupabaseClientProvider._();

final class SupabaseClientProvider
    extends $FunctionalProvider<SupabaseClient, SupabaseClient, SupabaseClient>
    with $Provider<SupabaseClient> {
  SupabaseClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseClientHash();

  @$internal
  @override
  $ProviderElement<SupabaseClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupabaseClient create(Ref ref) {
    return supabaseClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseClient>(value),
    );
  }
}

String _$supabaseClientHash() => r'3db2a4c212c7f24cea9810e376225aa1a6cab012';

@ProviderFor(identityRepository)
final identityRepositoryProvider = IdentityRepositoryProvider._();

final class IdentityRepositoryProvider
    extends
        $FunctionalProvider<
          IdentityRepository,
          IdentityRepository,
          IdentityRepository
        >
    with $Provider<IdentityRepository> {
  IdentityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'identityRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$identityRepositoryHash();

  @$internal
  @override
  $ProviderElement<IdentityRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IdentityRepository create(Ref ref) {
    return identityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IdentityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IdentityRepository>(value),
    );
  }
}

String _$identityRepositoryHash() =>
    r'205deba9ccbc28421e42cec042568307625b9868';

@ProviderFor(unsynchronizedPrivateWork)
final unsynchronizedPrivateWorkProvider = UnsynchronizedPrivateWorkProvider._();

final class UnsynchronizedPrivateWorkProvider
    extends
        $FunctionalProvider<
          UnsynchronizedPrivateWork,
          UnsynchronizedPrivateWork,
          UnsynchronizedPrivateWork
        >
    with $Provider<UnsynchronizedPrivateWork> {
  UnsynchronizedPrivateWorkProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unsynchronizedPrivateWorkProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unsynchronizedPrivateWorkHash();

  @$internal
  @override
  $ProviderElement<UnsynchronizedPrivateWork> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UnsynchronizedPrivateWork create(Ref ref) {
    return unsynchronizedPrivateWork(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnsynchronizedPrivateWork value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnsynchronizedPrivateWork>(value),
    );
  }
}

String _$unsynchronizedPrivateWorkHash() =>
    r'248582e4f395c6275c56591a40f4b4094eed0831';

@ProviderFor(privateWorkQuarantine)
final privateWorkQuarantineProvider = PrivateWorkQuarantineProvider._();

final class PrivateWorkQuarantineProvider
    extends
        $FunctionalProvider<
          PrivateWorkQuarantine,
          PrivateWorkQuarantine,
          PrivateWorkQuarantine
        >
    with $Provider<PrivateWorkQuarantine> {
  PrivateWorkQuarantineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'privateWorkQuarantineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$privateWorkQuarantineHash();

  @$internal
  @override
  $ProviderElement<PrivateWorkQuarantine> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PrivateWorkQuarantine create(Ref ref) {
    return privateWorkQuarantine(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PrivateWorkQuarantine value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PrivateWorkQuarantine>(value),
    );
  }
}

String _$privateWorkQuarantineHash() =>
    r'e8496fdd8cf17e2809fa03994184eb75707450e4';
