import 'package:flutter/material.dart';
import 'package:drawo_app/core/style/palette.dart';
import 'package:drawo_app/core/languages/app_localizations.dart';
import 'package:drawo_app/presentation/common/components/frosted_container.dart';
import 'package:reactive_forms/reactive_forms.dart';

class GlassTextInput extends StatelessWidget {
  final FormControl<String> formControl;
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
    return SizedBox(
      height: 78,
      width: 350,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            const FrostedContainer(),
            Container(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      child: ReactiveTextField<String>(
                        obscureText: obscureText,
                        onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        formControl: formControl,
                        cursorColor: Colors.white70,
                        style: const TextStyle(
                          color: Palette.white,
                          fontSize: 16,
                          height: 1.3,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: false,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          labelText: hint,
                          labelStyle: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          hintText: hint,
                          hintStyle: TextStyle(
                            color: Palette.whiter.withOpacity(0.6),
                            fontSize: 16,
                          ),
                          contentPadding: const EdgeInsets.only(
                            top: 8,
                            bottom: 6,
                          ),
                        ),
                        validationMessages: {
                          ValidationMessage.required: (_) =>
                              requiredMessage ?? 'required',
                          'passwordComplexity': (_) =>
                              passwordCustomKeyMessage ?? '',

                          ValidationMessage.email: (_) =>
                              localeStrings.entervalidemail,

                          ValidationMessage.mustMatch: (_) => localeStrings
                              .passwordshouldmatch, // Uses specific key in drawo_app app_localizations
                          // painterapp used localeStrings.password which seemed wrong for match error?
                          // Painterapp code: ValidationMessage.mustMatch: (_) => localeStrings.password,
                          // Wait, "password" usually means the label "Password".
                          // painterapp localizations might have different keys.
                          // drawo_app has "passwordshouldmatch". I'll use that as it makes more sense.
                        },
                        keyboardType: keyboardType,
                        textInputAction: textInputAction,
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    margin: const EdgeInsets.only(top: 6, left: 16, right: 16),
                    color: Palette.whiter.withOpacity(0.3),
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
