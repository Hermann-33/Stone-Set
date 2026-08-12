import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stone_set_data/stone_set_data.dart';
import 'package:stone_set_domain/identity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/mobile_client_configuration.dart';
import '../../workout/controllers/workout_controller.dart';
import '../../workout/data/sqflite_workout_local_store.dart';
import '../../workout/data/workout_private_work.dart';

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
UnsynchronizedPrivateWork unsynchronizedPrivateWork(Ref ref) {
  final local = SqfliteWorkoutLocalStore();
  final remote = SupabaseWorkoutRepository(
    remote: SupabaseWorkoutRemoteService(ref.watch(supabaseClientProvider)),
  );
  return WorkoutPrivateWork(
    local: local,
    controller: WorkoutController(remote: remote, local: local),
  );
}

@Riverpod(keepAlive: true)
PrivateWorkQuarantine privateWorkQuarantine(Ref ref) => const OwnerScopedWorkoutQuarantine();
