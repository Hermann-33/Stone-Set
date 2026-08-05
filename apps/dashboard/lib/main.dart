import 'package:flutter/material.dart';

void main() => runApp(const StoneSetDashboardApp());

class StoneSetDashboardApp extends StatelessWidget {
  const StoneSetDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stone Set Dashboard',
      theme: ThemeData(useMaterial3: true),
      home: const DashboardFoundationView(),
    );
  }
}

class DashboardFoundationView extends StatelessWidget {
  const DashboardFoundationView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    key: const Key('dashboard-foundation-heading'),
                    container: true,
                    excludeSemantics: true,
                    header: true,
                    label: 'Stone Set dashboard foundation',
                    child: Text(
                      'Stone Set dashboard foundation',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'The Flutter Web foundation is ready. Product workflows, '
                    'authentication, and connected data are not implemented '
                    'in this task.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge,
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
