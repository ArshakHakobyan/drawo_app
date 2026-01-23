import 'package:drawo_app/presentation/auth/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drawo_app/core/style/palette.dart';
import 'package:drawo_app/core/style/text_styles.dart';
import 'package:drawo_app/core/common/app_enums.dart';
import 'package:drawo_app/core/input/sign_in_form.dart';
import 'package:drawo_app/core/languages/app_localizations.dart';
import 'package:drawo_app/presentation/auth/bloc/auth_bloc.dart';
import 'package:drawo_app/presentation/common/components/auth_scaffold.dart';
import 'package:drawo_app/presentation/common/components/accent_button.dart';
import 'package:drawo_app/presentation/common/components/glass_text_input.dart';
import 'package:reactive_forms/reactive_forms.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final SignInForm _loginForm;

  @override
  void initState() {
    super.initState();
    _loginForm = SignInForm();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final localeStrings = AppLocalizations.of(context)!;

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Login failed')),
            );
          }
          // Navigation to Gallery is handled in drawing_app.dart via BlocBuilder
          // but we can also handle it here if we want explicit navigation,
          // however the root navigator checks auth status.
        },
        builder: (context, state) {
          final isLoading = state.status == AuthStatus.loading;
          return Stack(
            alignment: Alignment.center,
            children: [
              const AuthScaffold(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  child: ReactiveForm(
                    formGroup: _loginForm.formGroup,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: screenSize.height / 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localeStrings.loginTitle,
                              style: AppTypography.h6.copyWith(
                                color: Palette.whiter,
                                fontFamily: "PressStart2P",
                                shadows: [
                                  const Shadow(
                                    color: Palette.primary,
                                    blurRadius: 28,
                                    offset: Offset(0, 0),
                                  ),
                                  const Shadow(
                                    color: Palette.primary,
                                    blurRadius: 28 * 0.66,
                                    offset: Offset(0, 0),
                                  ),
                                  const Shadow(
                                    color: Palette.primary,
                                    blurRadius: 28 * 0.33,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            GlassTextInput(
                              formControl: _loginForm.emailControl,
                              hint: localeStrings.email,
                              requiredMessage: localeStrings.emailrequired,
                              fillColor: Palette.black,
                              obscureText: false,
                              context: context,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            GlassTextInput(
                              context: context,
                              formControl: _loginForm.passwordControl,
                              hint: localeStrings.password,
                              requiredMessage: localeStrings.passwordrequired,
                              fillColor: Palette.black,
                              obscureText: true,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
                            ),
                          ],
                        ),
                        SizedBox(height: screenSize.height / 9),
                        Column(
                          children: [
                            AccentButton(
                              label: localeStrings.login,
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (_loginForm.validate()) {
                                        context.read<AuthBloc>().add(
                                          AuthSignInRequested(
                                            _loginForm.emailControl.value!,
                                            _loginForm.passwordControl.value!,
                                          ),
                                        );
                                      } else {
                                        _loginForm.formGroup.markAllAsTouched();
                                      }
                                    },
                              variant: AppButtonVariant.primaryGradient,
                              showLoading: isLoading,
                              loadingColor: Palette.whiter,
                            ),
                            const SizedBox(height: 19),
                            AccentButton(
                              label: localeStrings.registration,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegistrationScreen(),
                                  ),
                                );
                              },
                              variant: AppButtonVariant.primaryLight,
                              showLoading: false,
                              loadingColor: Palette.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
