import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../session/dashboard_session_controller.dart';
import 'session_status_view.dart';

class ProtectedDashboardView extends ConsumerWidget {
  const ProtectedDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(dashboardSessionControllerProvider);
    final bootstrap = session.bootstrap;
    if (bootstrap == null) {
      return const SessionCheckingView();
    }

    return ProviderScope(
      key: ValueKey(bootstrap.profile.userId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Stone Set Dashboard'),
          actions: [
            TextButton(
              onPressed: () => unawaited(
                ref.read(dashboardSessionControllerProvider.notifier).signOut(),
              ),
              child: const Text('Sign out'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (bootstrap.compatibility.readOnlyMode) ...[
                      MaterialBanner(
                        content: const Text(
                          'Stone Set is read-only. Changes are temporarily unavailable.',
                        ),
                        actions: const [],
                      ),
                      const SizedBox(height: 24),
                    ],
                    Semantics(
                      header: true,
                      child: Text(
                        'Identity foundation ready',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Signed in as ${bootstrap.profile.displayName}. '
                      'The full dashboard remains scheduled for a later implementation packet.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
