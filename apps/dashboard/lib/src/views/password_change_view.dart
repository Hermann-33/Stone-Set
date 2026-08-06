import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stone_set_domain/identity.dart';
import 'package:stone_set_ui/stone_set_ui.dart';

import '../session/dashboard_session_controller.dart';
import 'auth_page_frame.dart';

class PasswordChangeView extends ConsumerStatefulWidget {
  const PasswordChangeView({super.key});

  @override
  ConsumerState<PasswordChangeView> createState() => _PasswordChangeViewState();
}

class _PasswordChangeViewState extends ConsumerState<PasswordChangeView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _confirmationFocus = FocusNode();
  bool _submitting = false;
  String? _failureMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    _confirmationFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageFrame(
      title: 'Change your temporary password',
      description: 'Choose a private password before opening protected Stone Set content.',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthStatusMessage(message: _failureMessage),
              StoneSetPasswordField(
                key: const Key('dashboard-new-password'),
                controller: _passwordController,
                autofillHints: const [AutofillHints.newPassword],
                enabled: !_submitting,
                textInputAction: TextInputAction.next,
                label: 'New password',
                helperText:
                    'Use 12 or more characters with uppercase, lowercase, a number, and a symbol.',
                helperMaxLines: 2,
                visibilityControlKey: const Key('dashboard-new-password-visibility'),
                validator: _validatePassword,
                onFieldSubmitted: (_) => _confirmationFocus.requestFocus(),
              ),
              const SizedBox(height: 16),
              StoneSetPasswordField(
                key: const Key('dashboard-confirm-password'),
                controller: _confirmationController,
                focusNode: _confirmationFocus,
                autofillHints: const [AutofillHints.newPassword],
                enabled: !_submitting,
                textInputAction: TextInputAction.done,
                label: 'Confirm new password',
                visibilityControlKey: const Key('dashboard-confirm-password-visibility'),
                validator: (value) =>
                    value != _passwordController.text ? 'Enter the same password again.' : null,
                onFieldSubmitted: (_) => unawaited(_submit()),
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('dashboard-password-change-submit'),
                onPressed: _submitting ? null : () => unawaited(_submit()),
                child: _submitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          semanticsLabel: 'Changing password…',
                        ),
                      )
                    : const Text('Change password'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _submitting
                    ? null
                    : () => unawaited(
                        ref.read(dashboardSessionControllerProvider.notifier).signOut(),
                      ),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a new password.';
    }
    if (!PasswordPolicy.validate(value).isValid) {
      return 'Meet every password requirement before continuing.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _submitting = true;
      _failureMessage = null;
    });
    try {
      await ref
          .read(dashboardSessionControllerProvider.notifier)
          .completeRequiredPasswordChange(_passwordController.text);
    } on IdentityFailure {
      if (mounted) {
        setState(() {
          _failureMessage = 'Unable to change the password. Check the requirements and try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}
