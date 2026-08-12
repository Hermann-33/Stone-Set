import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../../identity/controllers/mobile_session_controller.dart';
import '../../identity/views/logout_flow.dart';
import '../../sync/controllers/mobile_sync_controller.dart';

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
    final sync = ref.watch(mobileSyncControllerProvider);
    return StoneSetBackdrop(
      child: SafeArea(
        child: SingleChildScrollView(
          key: PageStorageKey<String>('mobile-${title.toLowerCase()}-scroll'),
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  StoneSetPageHeader(
                    eyebrow: showProfileDetails ? 'Private account' : 'Stone Set',
                    title: title,
                    description: description,
                  ),
                  if (showProfileDetails) ...<Widget>[
                    const SizedBox(height: StoneSetSpacing.xl),
                    StoneSetCard(
                      style: StoneSetCardStyle.hero,
                      child: Row(
                        children: <Widget>[
                          StoneSetIconBadge(
                            icon: Icons.verified_user_outlined,
                            color: StoneSetSemanticColors.of(context).authoritative,
                            size: 52,
                          ),
                          const SizedBox(width: StoneSetSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  profile?.displayName ?? 'Stone Set member',
                                  key: const Key('profile-display-name'),
                                  style: StoneSetTextStyles.of(context).sectionTitle,
                                ),
                                const SizedBox(height: StoneSetSpacing.xxs),
                                Text(
                                  profile == null
                                      ? 'Verified account'
                                      : '@${profile.normalizedUsername}',
                                  style: StoneSetTextStyles.of(context).compactBody.copyWith(
                                    color: StoneSetSemanticColors.of(context).textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const StoneSetStatusChip(
                            kind: StoneSetStatusKind.success,
                            label: 'Active',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: StoneSetSpacing.section),
                    const StoneSetSectionHeader(
                      title: 'Synchronization',
                      description: 'Cached private data remains available between successful syncs.',
                    ),
                    const SizedBox(height: StoneSetSpacing.sm),
                    StoneSetCard(
                      key: const Key('profile-sync-status'),
                      style: StoneSetCardStyle.base,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            sync.lastFailureCode != null
                                ? Icons.cloud_off_outlined
                                : sync.isRunning
                                ? Icons.sync_rounded
                                : Icons.cloud_done_outlined,
                          ),
                          const SizedBox(width: StoneSetSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _syncTitle(sync),
                                  style: StoneSetTextStyles.of(context).cardTitle,
                                ),
                                const SizedBox(height: StoneSetSpacing.xxs),
                                Text(
                                  _syncDetail(sync),
                                  style: StoneSetTextStyles.of(context).caption.copyWith(
                                    color: StoneSetSemanticColors.of(context).textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: StoneSetSpacing.section),
                    const StoneSetSectionHeader(
                      title: 'Session',
                      description:
                          'Theme and account preferences remain managed by the verified profile.',
                    ),
                    const SizedBox(height: StoneSetSpacing.sm),
                    OutlinedButton.icon(
                      key: const Key('profile-sign-out-button'),
                      onPressed: () => requestMobileLogout(context, ref),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sign out'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _syncTitle(MobileSyncState state) {
  if (state.isRunning) return 'Synchronizing';
  if (state.pendingMutationCount > 0) return 'Pending synchronization';
  if (state.lastFailureCode != null) return 'Offline or unavailable';
  return state.lastSuccessfulSyncAt == null ? 'Cached state' : 'Synchronized';
}

String _syncDetail(MobileSyncState state) {
  if (state.pendingMutationCount > 0) {
    return state.pendingMutationCount == 1
        ? '1 workout has local changes waiting to sync.'
        : '${state.pendingMutationCount} workouts have local changes waiting to sync.';
  }
  final last = state.lastSuccessfulSyncAt;
  if (last == null) return 'No successful data synchronization is recorded yet.';
  final local = last.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return state.lastFailureCode == null
      ? 'Last synchronized at $hour:$minute.'
      : 'Cached data from $hour:$minute is still being shown.';
}
