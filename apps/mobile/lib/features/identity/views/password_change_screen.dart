import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_domain/identity.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../controllers/mobile_session_controller.dart';
import 'identity_messages.dart';
import 'logout_flow.dart';

class PasswordChangeScreen extends ConsumerStatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  ConsumerState<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends ConsumerState<PasswordChangeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    await ref
        .read(mobileSessionControllerProvider.notifier)
        .changeRequiredPassword(_passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(mobileSessionControllerProvider).value;
    final busy = session?.phase == IdentitySessionPhase.bootstrapping;
    return StoneSetAuthFrame(
      mobilePresentation: true,
      title: 'Choose a new password',
      description: 'Replace your temporary password before continuing.',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Use at least 12 characters with lowercase and uppercase letters, '
                'a number, and a symbol.',
              ),
              const SizedBox(height: 16),
              StoneSetPasswordField(
                key: const Key('new-password-field'),
                controller: _passwordController,
                label: 'New password',
                enabled: !busy,
                autofillHints: const <String>[AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
                validator: (value) => PasswordPolicy.validate(value ?? '').isValid
                    ? null
                    : 'Enter a password that meets every requirement.',
              ),
              const SizedBox(height: 16),
              StoneSetPasswordField(
                key: const Key('confirm-password-field'),
                controller: _confirmationController,
                label: 'Confirm password',
                enabled: !busy,
                autofillHints: const <String>[AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (value) =>
                    value == _passwordController.text ? null : 'Enter the same password again.',
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
                key: const Key('change-password-button'),
                onPressed: busy ? null : _submit,
                child: busy
                    ? const SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Change password'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: busy ? null : () => requestMobileLogout(context, ref),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
