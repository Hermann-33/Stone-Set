import 'package:flutter/material.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

class SessionCheckScreen extends StatelessWidget {
  const SessionCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StoneSetAuthFrame(
      title: 'Checking your session…',
      description: 'Private content will appear after your account is verified.',
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
