import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_domain/identity.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../controllers/mobile_session_controller.dart';
import 'identity_messages.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await ref
        .read(mobileSessionControllerProvider.notifier)
        .signIn(
          username: NormalizedUsername.parse(_usernameController.text),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(mobileSessionControllerProvider).value;
    final busy =
        session?.phase == IdentitySessionPhase.authenticating ||
        session?.phase == IdentitySessionPhase.bootstrapping;
    final canRetrySession =
        session?.phase == IdentitySessionPhase.recoverableFailure &&
        (session?.failure?.code == IdentityErrorCode.networkUnavailable ||
            session?.failure?.code == IdentityErrorCode.serverUnavailable);
    return StoneSetAuthFrame(
      title: 'Sign in',
      description: 'Use the username and password provided to you.',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                key: const Key('username-field'),
                controller: _usernameController,
                enabled: !busy,
                autofillHints: const <String>[AutofillHints.username],
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  try {
                    NormalizedUsername.parse(value ?? '');
                    return null;
                  } on FormatException catch (error) {
                    return error.message;
                  }
                },
              ),
              const SizedBox(height: 16),
              StoneSetPasswordField(
                key: const Key('password-field'),
                controller: _passwordController,
                label: 'Password',
                enabled: !busy,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (value) => (value ?? '').isEmpty ? 'Enter your password.' : null,
              ),
              if (session?.failure != null) ...<Widget>[
                const SizedBox(height: 16),
                StoneSetStatusMessage(
                  message: identityMessage(session?.failure),
                  tone: StoneSetStatusTone.error,
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('sign-in-button'),
                onPressed: busy ? null : _submit,
                child: busy
                    ? const SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign in'),
              ),
              if (canRetrySession) ...<Widget>[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      ref.read(mobileSessionControllerProvider.notifier).retrySessionCheck(),
                  child: const Text('Retry session check'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
