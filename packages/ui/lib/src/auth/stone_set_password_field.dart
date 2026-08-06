import 'package:flutter/material.dart';

class StoneSetPasswordField extends StatefulWidget {
  const StoneSetPasswordField({
    required this.controller,
    required this.label,
    this.enabled = true,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofillHints = const <String>[AutofillHints.password],
    this.validator,
    this.focusNode,
    this.helperText,
    this.helperMaxLines,
    this.visibilityControlKey,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final String? helperText;
  final int? helperMaxLines;
  final Key? visibilityControlKey;

  @override
  State<StoneSetPasswordField> createState() => _StoneSetPasswordFieldState();
}

class _StoneSetPasswordFieldState extends State<StoneSetPasswordField> {
  var _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final fieldName = widget.label.toLowerCase();
    final actionLabel = '${_obscureText ? 'Show' : 'Hide'} $fieldName';
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enabled,
      obscureText: _obscureText,
      autocorrect: false,
      enableSuggestions: false,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helperText,
        helperMaxLines: widget.helperMaxLines,
        suffixIcon: IconButton(
          key: widget.visibilityControlKey,
          tooltip: actionLabel,
          onPressed: widget.enabled
              ? () => setState(() {
                  _obscureText = !_obscureText;
                })
              : null,
          icon: Icon(_obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined),
        ),
      ),
    );
  }
}
