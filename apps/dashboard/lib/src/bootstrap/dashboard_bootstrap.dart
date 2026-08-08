import 'package:stone_set_data/stone_set_data.dart';
import 'package:stone_set_domain/exercise_guidance.dart';
import 'package:stone_set_domain/identity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabasePublishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
const _aliasDomain = String.fromEnvironment('STONE_SET_ALIAS_DOMAIN');
const _environment = String.fromEnvironment('APP_ENV');
const _dashboardBuild = 1;

final class DashboardRepositories {
  const DashboardRepositories({required this.identity, required this.exerciseGuidance});

  final IdentityRepository identity;
  final ExerciseGuidanceRepository exerciseGuidance;
}

Future<DashboardRepositories> createDashboardRepositories() async {
  if (_supabaseUrl.isEmpty ||
      _supabasePublishableKey.isEmpty ||
      _aliasDomain.isEmpty ||
      _environment.isEmpty) {
    throw StateError(
      'Stone Set public client configuration is incomplete. Use the documented Dart defines.',
    );
  }
  await Supabase.initialize(url: _supabaseUrl, publishableKey: _supabasePublishableKey);
  final client = Supabase.instance.client;
  return DashboardRepositories(
    identity: SupabaseIdentityRepository(
      client: client,
      aliasMapper: UsernameAliasMapper(_aliasDomain),
      environment: _environment,
      clientKind: 'dashboard',
      clientBuild: _dashboardBuild,
    ),
    exerciseGuidance: SupabaseExerciseGuidanceRepository(
      remote: SupabaseExerciseGuidanceRemoteService(client),
    ),
  );
}
