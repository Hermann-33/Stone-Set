import 'package:flutter/material.dart';

enum StoneSetStatusTone { information, warning, error }

class StoneSetStatusMessage extends StatelessWidget {
  const StoneSetStatusMessage({required this.message, required this.tone, super.key});

  final String message;
  final StoneSetStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, color) = switch (tone) {
      StoneSetStatusTone.information => (Icons.info_outline, colorScheme.primary),
      StoneSetStatusTone.warning => (Icons.warning_amber_outlined, colorScheme.tertiary),
      StoneSetStatusTone.error => (Icons.error_outline, colorScheme.error),
    };
    return Semantics(
      container: true,
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: color, semanticLabel: '${tone.name} status'),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
