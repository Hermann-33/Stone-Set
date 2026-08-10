import 'package:flutter/material.dart';

import '../primitives/stone_set_primitives.dart';
import '../theme/stone_set_theme.dart';

class StoneSetAuthFrame extends StatelessWidget {
  const StoneSetAuthFrame({
    required this.title,
    required this.description,
    required this.child,
    this.mobilePresentation = false,
    super.key,
  });

  final String title;
  final String description;
  final Widget child;
  final bool mobilePresentation;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final content = SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (mobilePresentation)
                  StoneSetPageHeader(
                    eyebrow: 'Private training',
                    title: title,
                    description: description,
                  )
                else ...<Widget>[
                  Semantics(
                    header: true,
                    child: Text('Stone Set', style: textTheme.titleMedium),
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    header: true,
                    child: Text(title, style: textTheme.headlineMedium),
                  ),
                  const SizedBox(height: 8),
                  Text(description, style: textTheme.bodyLarge),
                ],
                const SizedBox(height: StoneSetSpacing.xxl),
                if (mobilePresentation)
                  StoneSetCard(
                    style: StoneSetCardStyle.raised,
                    child: child,
                  )
                else
                  child,
              ],
            ),
          ),
        ),
      ),
    );
    return Scaffold(
      body: mobilePresentation ? StoneSetBackdrop(child: content) : content,
    );
  }
}
