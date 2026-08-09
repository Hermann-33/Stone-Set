// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mobile_session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MobileSessionController)
final mobileSessionControllerProvider = MobileSessionControllerProvider._();

final class MobileSessionControllerProvider
    extends $AsyncNotifierProvider<MobileSessionController, IdentitySessionState> {
  MobileSessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mobileSessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mobileSessionControllerHash();

  @$internal
  @override
  MobileSessionController create() => MobileSessionController();
}

String _$mobileSessionControllerHash() => r'ab80838d70f55826bcaca453f49c62ee76ea6ae5';

abstract class _$MobileSessionController extends $AsyncNotifier<IdentitySessionState> {
  FutureOr<IdentitySessionState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<IdentitySessionState>, IdentitySessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<IdentitySessionState>, IdentitySessionState>,
              AsyncValue<IdentitySessionState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
