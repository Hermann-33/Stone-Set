import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:idb_shim/idb_browser.dart';

import 'src/app/stone_set_dashboard_app.dart';
import 'src/bootstrap/dashboard_bootstrap.dart';
import 'src/features/exercises/controllers/dashboard_exercise_controllers.dart';
import 'src/features/exercises/controllers/dashboard_guidance_media_controller.dart';
import 'src/features/exercises/data/dashboard_guidance_draft_cache.dart';
import 'src/features/routines/controllers/dashboard_routine_controllers.dart';
import 'src/session/dashboard_private_cache.dart';
import 'src/session/dashboard_session_controller.dart';

export 'src/app/stone_set_dashboard_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
    SemanticsBinding.instance.ensureSemantics();
  }
  final repositories = await createDashboardRepositories();
  final guidanceCache = IdbDashboardGuidanceDraftCache(factory: idbFactoryBrowser);
  runApp(
    ProviderScope(
      overrides: [
        dashboardIdentityRepositoryProvider.overrideWithValue(repositories.identity),
        exerciseGuidanceRepositoryProvider.overrideWithValue(repositories.exerciseGuidance),
        exerciseMediaRepositoryProvider.overrideWithValue(repositories.exerciseMedia),
        routineRepositoryProvider.overrideWithValue(repositories.routines),
        dashboardGuidanceDraftCacheProvider.overrideWithValue(guidanceCache),
        dashboardPrivateCacheProvider.overrideWithValue(guidanceCache),
      ],
      child: const StoneSetDashboardApp(),
    ),
  );
}
