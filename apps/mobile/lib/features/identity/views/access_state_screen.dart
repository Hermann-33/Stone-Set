import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../controllers/mobile_session_controller.dart';
import 'logout_flow.dart';

class AccessStateScreen extends ConsumerWidget {
  const AccessStateScreen({
    required this.title,
    required this.description,
    required this.allowRetry,
    super.key,
  });

  final String title;
  final String description;
  final bool allowRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StoneSetAuthFrame(
      title: title,
      description: description,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (allowRetry)
            FilledButton(
              onPressed: () =>
                  ref.read(mobileSessionControllerProvider.notifier).foregroundRevalidate(),
              child: const Text('Try again'),
            ),
          TextButton(
            onPressed: () => requestMobileLogout(context, ref),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
