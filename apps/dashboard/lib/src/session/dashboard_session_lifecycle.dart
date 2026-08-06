import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard_session_controller.dart';

class DashboardSessionLifecycle extends ConsumerStatefulWidget {
  const DashboardSessionLifecycle({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DashboardSessionLifecycle> createState() => _DashboardSessionLifecycleState();
}

class _DashboardSessionLifecycleState extends ConsumerState<DashboardSessionLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(dashboardSessionControllerProvider.notifier).revalidate());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
