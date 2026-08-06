import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../identity/controllers/mobile_session_controller.dart';
import '../../identity/views/logout_flow.dart';

class MobileDestinationPlaceholder extends ConsumerWidget {
  const MobileDestinationPlaceholder({
    required this.title,
    required this.description,
    this.showProfileDetails = false,
    super.key,
  });

  final String title;
  final String description;
  final bool showProfileDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(mobileSessionControllerProvider).value?.bootstrap?.profile;
    return SafeArea(
      child: SingleChildScrollView(
        key: PageStorageKey<String>('mobile-${title.toLowerCase()}-scroll'),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
                ),
                const SizedBox(height: 12),
                Text(description),
                if (showProfileDetails) ...<Widget>[
                  const SizedBox(height: 24),
                  Text(
                    profile?.displayName ?? 'Stone Set member',
                    key: const Key('profile-display-name'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile == null ? 'Verified account' : '@${profile.normalizedUsername}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    key: const Key('profile-sign-out-button'),
                    onPressed: () => requestMobileLogout(context, ref),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign out'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
