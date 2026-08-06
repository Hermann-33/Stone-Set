import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_domain/identity.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../session/dashboard_session_controller.dart';
import 'auth_page_frame.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _submitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(dashboardSessionControllerProvider);
    return AuthPageFrame(
      title: 'Sign in',
      description: 'Use your provisioned Stone Set username and password.',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthStatusMessage(message: _loginMessage(session.failure)),
              if (session.phase == IdentitySessionPhase.recoverableFailure) ...[
                OutlinedButton(
                  key: const Key('dashboard-session-retry'),
                  onPressed: _submitting
                      ? null
                      : () => unawaited(
                          ref.read(dashboardSessionControllerProvider.notifier).revalidate(),
                        ),
                  child: const Text('Try session again'),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                key: const Key('dashboard-login-username'),
                controller: _usernameController,
                enabled: !_submitting,
                autofillHints: const [AutofillHints.username],
                autocorrect: false,
                enableSuggestions: false,
                spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter your username.' : null,
                onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
              ),
              const SizedBox(height: 16),
              StoneSetPasswordField(
                key: const Key('dashboard-login-password'),
                controller: _passwordController,
                focusNode: _passwordFocus,
                autofillHints: const [AutofillHints.password],
                enabled: !_submitting,
                textInputAction: TextInputAction.done,
                label: 'Password',
                visibilityControlKey: const Key('dashboard-login-password-visibility'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter your password.' : null,
                onFieldSubmitted: (_) => unawaited(_submit()),
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('dashboard-login-submit'),
                onPressed: _submitting ? null : () => unawaited(_submit()),
                child: _submitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          semanticsLabel: 'Signing in…',
                        ),
                      )
                    : const Text('Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    await ref
        .read(dashboardSessionControllerProvider.notifier)
        .signIn(
          username: _usernameController.text,
          password: _passwordController.text,
        );
    if (mounted) {
      setState(() => _submitting = false);
    }
  }
}

String? _loginMessage(IdentityFailure? failure) => switch (failure?.code) {
  null => null,
  IdentityErrorCode.rateLimited => 'Unable to sign in right now. Wait a moment and try again.',
  IdentityErrorCode.networkUnavailable || IdentityErrorCode.serverUnavailable =>
    'Unable to reach Stone Set. Check your connection and try again.',
  IdentityErrorCode.sessionExpired => 'Your session ended. Sign in again.',
  _ => 'Unable to sign in. Check your details and try again.',
};
