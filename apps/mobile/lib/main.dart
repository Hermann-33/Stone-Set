import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/mobile_client_configuration.dart';
import 'app/stone_set_mobile_app.dart';

export 'app/stone_set_mobile_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final configuration = MobileClientConfiguration.fromEnvironment();
  await Supabase.initialize(
    url: configuration.supabaseUrl,
    publishableKey: configuration.supabasePublishableKey,
  );
  runApp(const ProviderScope(child: StoneSetMobileApp()));
}
