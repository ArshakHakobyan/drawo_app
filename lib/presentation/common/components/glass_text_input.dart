import 'package:flutter/material.dart';
import 'package:drawo_app/core/style/palette.dart';
import 'package:drawo_app/core/languages/app_localizations.dart';
import 'package:drawo_app/presentation/common/components/frosted_container.dart';
import 'package:reactive_forms/reactive_forms.dart';

class GlassTextInput extends StatelessWidget {
  final FormControl<String> formControl;
  final String label;
  final String hint;
  final Color fillColor;
  final bool obscureText;
  final BuildContext context;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  final String? requiredMessage;
  final String? passwordCustomKeyMessage;

  const GlassTextInput({
    super.key,
    required this.context,
    required this.formControl,
    this.label = '',
    this.hint = '',
    this.fillColor = Colors.transparent,
    this.obscureText = false,
    this.requiredMessage = '',
    this.passwordCustomKeyMessage = '',
    required this.keyboardType,
    required this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final localeStrings = AppLocalizations.of(context)!;
    return Container(
      width: 335,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            const Positioned.fill(child: FrostedContainer(borderRadius: 8)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label.isNotEmpty) ...[
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  ReactiveTextField<String>(
                    obscureText: obscureText,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    formControl: formControl,
                    cursorColor: Colors.white70,
                    style: const TextStyle(
                      color: Palette.white,
                      fontSize: 18,
                      height: 1.3,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: false,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      hintText: hint,
                      hintStyle: TextStyle(
                        color: Palette.whiter.withValues(alpha: 0.4),
                        fontSize: 18,
                      ),
                      contentPadding: EdgeInsets.zero,
                      errorStyle: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        height: 1,
                      ),
                    ),
                    obscuringCharacter: '*',
                    validationMessages: {
                      ValidationMessage.required: (_) =>
                          requiredMessage ?? 'required',
                      'passwordComplexity': (_) =>
                          passwordCustomKeyMessage ?? '',
                      ValidationMessage.email: (_) =>
                          localeStrings.entervalidemail,
                      ValidationMessage.mustMatch: (_) =>
                          localeStrings.passwordshouldmatch,
                    },
                    keyboardType: keyboardType,
                    textInputAction: textInputAction,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 1,
                    color: Palette.whiter.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
