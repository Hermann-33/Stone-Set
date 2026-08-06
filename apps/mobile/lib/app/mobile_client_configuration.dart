final class MobileClientConfiguration {
  const MobileClientConfiguration({
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    required this.authAliasDomain,
    required this.environment,
    required this.clientBuild,
    required this.schemaContract,
  });

  final String supabaseUrl;
  final String supabasePublishableKey;
  final String authAliasDomain;
  final String environment;
  final int clientBuild;
  final int schemaContract;

  factory MobileClientConfiguration.fromEnvironment() {
    const configuration = MobileClientConfiguration(
      supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
      supabasePublishableKey: String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
      authAliasDomain: String.fromEnvironment('STONE_SET_ALIAS_DOMAIN'),
      environment: String.fromEnvironment('APP_ENV'),
      clientBuild: int.fromEnvironment('APP_BUILD', defaultValue: 1),
      schemaContract: int.fromEnvironment('SCHEMA_CONTRACT', defaultValue: 1),
    );
    if (configuration.supabaseUrl.isEmpty ||
        configuration.supabasePublishableKey.isEmpty ||
        configuration.authAliasDomain.isEmpty ||
        !const <String>{'local', 'staging', 'production'}.contains(configuration.environment) ||
        configuration.clientBuild < 1 ||
        configuration.schemaContract < 1) {
      throw StateError('Stone Set public client configuration is incomplete.');
    }
    return configuration;
  }
}
