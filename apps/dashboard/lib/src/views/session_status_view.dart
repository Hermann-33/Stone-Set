import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../session/dashboard_session_controller.dart';
import 'auth_page_frame.dart';

class SessionCheckingView extends ConsumerWidget {
  const SessionCheckingView({super.key, this.returnTo});

  final String? returnTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardSessionControllerProvider);
    final failed = state.failure != null;
    return AuthPageFrame(
      title: failed ? 'Unable to verify your session' : 'Checking your session…',
      description: failed
          ? 'Protected content remains locked until Stone Set can verify your session.'
          : 'Protected content will appear after your account is verified.',
      child: failed
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  onPressed: () => unawaited(
                    ref.read(dashboardSessionControllerProvider.notifier).revalidate(),
                  ),
                  child: const Text('Try again'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => unawaited(
                    ref.read(dashboardSessionControllerProvider.notifier).signOut(),
                  ),
                  child: const Text('Sign out'),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(semanticsLabel: 'Checking your session…'),
            ),
    );
  }
}

class MaintenanceView extends ConsumerWidget {
  const MaintenanceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(dashboardSessionControllerProvider).bootstrap?.compatibility.message;
    return _BlockingStatusView(
      title: 'Stone Set is under maintenance',
      description:
          message ?? 'Protected dashboard access will return when maintenance is complete.',
    );
  }
}

class UpdateRequiredView extends StatelessWidget {
  const UpdateRequiredView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _BlockingStatusView(
      title: 'Dashboard update required',
      description: 'Refresh after the current Stone Set dashboard version is available.',
    );
  }
}

class DashboardNotFoundView extends StatelessWidget {
  const DashboardNotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPageFrame(
      title: 'Page not found',
      description: 'The requested Stone Set dashboard page is unavailable.',
      child: FilledButton(
        onPressed: () => context.go('/'),
        child: const Text('Open dashboard'),
      ),
    );
  }
}

class _BlockingStatusView extends ConsumerWidget {
  const _BlockingStatusView({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthPageFrame(
      title: title,
      description: description,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: () => unawaited(
              ref.read(dashboardSessionControllerProvider.notifier).revalidate(),
            ),
            child: const Text('Check again'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => unawaited(
              ref.read(dashboardSessionControllerProvider.notifier).signOut(),
            ),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
