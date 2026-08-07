import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'src/app/stone_set_dashboard_app.dart';
import 'src/bootstrap/dashboard_bootstrap.dart';
import 'src/session/dashboard_session_controller.dart';

export 'src/app/stone_set_dashboard_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
    SemanticsBinding.instance.ensureSemantics();
  }
  final identityRepository = await createDashboardIdentityRepository();
  runApp(
    ProviderScope(
      overrides: [dashboardIdentityRepositoryProvider.overrideWithValue(identityRepository)],
      child: const StoneSetDashboardApp(),
    ),
  );
}
