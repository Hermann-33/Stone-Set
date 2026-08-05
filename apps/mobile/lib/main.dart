import 'package:flutter/material.dart';

void main() {
  runApp(const StoneSetMobileApp());
}

class StoneSetMobileApp extends StatelessWidget {
  const StoneSetMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stone Set',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const MobileFoundationScreen(),
    );
  }
}

class MobileFoundationScreen extends StatelessWidget {
  const MobileFoundationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Semantics(
                container: true,
                explicitChildNodes: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text('Stone Set', style: textTheme.headlineMedium),
                    ),
                    const SizedBox(height: 16),
                    Text('Android foundation', style: textTheme.titleLarge),
                    const SizedBox(height: 8),
                    const Text(
                      'The mobile foundation is ready. Product features are not implemented yet.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
