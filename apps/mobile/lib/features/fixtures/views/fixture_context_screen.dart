import 'package:flutter/material.dart';

class FixtureContextScreen extends StatelessWidget {
  const FixtureContextScreen({
    required this.title,
    required this.description,
    super.key,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
                    child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  const SizedBox(height: 12),
                  Text(description),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Return to Home'),
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
