import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stone_set_data/stone_set_data.dart';
import 'package:stone_set_domain/identity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/mobile_client_configuration.dart';

part 'identity_providers.g.dart';

@Riverpod(keepAlive: true)
MobileClientConfiguration mobileClientConfiguration(Ref ref) =>
    MobileClientConfiguration.fromEnvironment();

@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;

@Riverpod(keepAlive: true)
IdentityRepository identityRepository(Ref ref) {
  final configuration = ref.watch(mobileClientConfigurationProvider);
  return SupabaseIdentityRepository(
    client: ref.watch(supabaseClientProvider),
    aliasMapper: UsernameAliasMapper(configuration.authAliasDomain),
    environment: configuration.environment,
    clientKind: 'android',
    clientBuild: configuration.clientBuild,
    schemaContract: configuration.schemaContract,
  );
}

@Riverpod(keepAlive: true)
UnsynchronizedPrivateWork unsynchronizedPrivateWork(Ref ref) => const NoUnsynchronizedPrivateWork();

@Riverpod(keepAlive: true)
PrivateWorkQuarantine privateWorkQuarantine(Ref ref) => const NoOpPrivateWorkQuarantine();
