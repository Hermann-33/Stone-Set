import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

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
