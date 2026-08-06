import 'package:flutter/material.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

typedef AuthPageFrame = StoneSetAuthFrame;

class AuthStatusMessage extends StatelessWidget {
  const AuthStatusMessage({super.key, required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final value = message;
    if (value == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: StoneSetStatusMessage(message: value, tone: StoneSetStatusTone.error),
    );
  }
}
