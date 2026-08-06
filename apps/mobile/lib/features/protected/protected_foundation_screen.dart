import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../identity/controllers/mobile_session_controller.dart';
import '../identity/views/logout_flow.dart';

class ProtectedFoundationScreen extends ConsumerWidget {
  const ProtectedFoundationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(mobileSessionControllerProvider).value;
    final readOnly = session?.bootstrap?.compatibility.readOnlyMode ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Stone Set')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Semantics(
                    header: true,
                    child: Text(
                      'Authenticated foundation',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your identity and session are verified. Product features are not implemented yet.',
                  ),
                  if (readOnly) ...<Widget>[
                    const SizedBox(height: 16),
                    const StoneSetStatusMessage(
                      message: 'Stone Set is currently read-only.',
                      tone: StoneSetStatusTone.warning,
                    ),
                  ],
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => requestMobileLogout(context, ref),
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
