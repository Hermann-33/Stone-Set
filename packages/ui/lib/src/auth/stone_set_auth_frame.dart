import 'package:flutter/material.dart';

class StoneSetAuthFrame extends StatelessWidget {
  const StoneSetAuthFrame({
    required this.title,
    required this.description,
    required this.child,
    super.key,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
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
                  const SizedBox(height: 32),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
