import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../session/dashboard_session_controller.dart';
import 'session_status_view.dart';

class ProtectedDashboardView extends ConsumerWidget {
  const ProtectedDashboardView({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(dashboardSessionControllerProvider);
    final bootstrap = session.bootstrap;
    if (bootstrap == null) {
      return const SessionCheckingView();
    }

    return ProviderScope(
      key: ValueKey(bootstrap.profile.userId),
      child: child,
    );
  }
}
