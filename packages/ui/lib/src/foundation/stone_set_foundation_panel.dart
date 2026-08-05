import 'package:flutter/material.dart';

import 'stone_set_foundation_tokens.dart';

/// A neutral, theme-driven panel for foundation-only placeholder screens.
class StoneSetFoundationPanel extends StatelessWidget {
  const StoneSetFoundationPanel({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: StoneSetFoundationTokens.contentMaxWidth,
        ),
        child: Padding(
          padding: StoneSetFoundationTokens.contentPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(title, style: textTheme.titleLarge),
              ),
              const SizedBox(height: StoneSetFoundationTokens.textGap),
              Text(message, style: textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}
