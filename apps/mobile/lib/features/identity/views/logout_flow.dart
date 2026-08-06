import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_domain/identity.dart';

import '../controllers/mobile_session_controller.dart';

Future<void> requestMobileLogout(BuildContext context, WidgetRef ref) async {
  final controller = ref.read(mobileSessionControllerProvider.notifier);
  final decision = await controller.requestLogout();
  if (!context.mounted || decision != LogoutDecision.resolutionRequired) {
    return;
  }
  final selected = await showDialog<LogoutDecision>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Unsynchronized workout'),
      content: const Text('Choose what to do with your private workout draft before signing out.'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, LogoutDecision.remainSignedIn),
          child: const Text('Remain signed in'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, LogoutDecision.synchronizeNow),
          child: const Text('Synchronize now'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, LogoutDecision.discardAndLogout),
          child: const Text('Discard draft'),
        ),
      ],
    ),
  );
  if (selected == null || selected == LogoutDecision.remainSignedIn) {
    return;
  }
  if (selected == LogoutDecision.discardAndLogout &&
      context.mounted &&
      !await _confirmDiscard(context)) {
    return;
  }
  await controller.resolveLogout(selected);
}

Future<bool> _confirmDiscard(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard this draft?'),
          content: const Text('This removes unsynchronized workout data from this device.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep draft'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Discard and sign out'),
            ),
          ],
        ),
      ) ??
      false;
}
