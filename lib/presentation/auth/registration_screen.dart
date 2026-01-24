import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:drawo_app/core/style/palette.dart';
import 'package:drawo_app/core/style/text_styles.dart';
import 'package:drawo_app/core/common/app_enums.dart';
import 'package:drawo_app/core/input/sign_up_form.dart';
import 'package:drawo_app/core/languages/app_localizations.dart';
import 'package:drawo_app/presentation/auth/bloc/auth_bloc.dart';
import 'package:drawo_app/presentation/common/components/auth_scaffold.dart';
import 'package:drawo_app/presentation/common/components/accent_button.dart';
import 'package:drawo_app/presentation/common/components/glass_text_input.dart';
import 'package:reactive_forms/reactive_forms.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late final SignUpForm _registrationForm;

  @override
  void initState() {
    super.initState();
    _registrationForm = SignUpForm();
  }

  @override
  Widget build(BuildContext context) {
    final localeStrings = AppLocalizations.of(context)!;

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.error) {
            Fluttertoast.showToast(
              msg: state.error.toMessage(context),
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Palette.red.withValues(alpha: 0.8),
              textColor: Palette.white,
              fontSize: 14.0,
            );
          }
          if (state.status == AuthStatus.authenticated) {
            // Navigator.pop(context); // Pop back to login which might redirect?
            // Actually drawing_app.dart handles authenticated state and shows Gallery.
            // But if we are pushed on top of Login, we might need to be removed.
            // Since drawing_app.dart uses a Switch-like logic (if auth -> Gallery),
            // the whole MaterialApp content changes if we are at root.
            // But here we pushed RegistrationScreen.
            // The root BlocBuilder will rebuild MaterialApp's home.
            // If we are deep in navigation, we might need to clear stack.
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: ReactiveForm(
                            formGroup: _registrationForm.formGroup,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Spacer(flex: 2),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localeStrings.registration,
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
                                      width:
                                          MediaQuery.of(context).size.width -
                                          40,
                                      formControl:
                                          _registrationForm.nameControl,
                                      label: localeStrings.name,
                                      hint: localeStrings.enterName,
                                      requiredMessage:
                                          localeStrings.namerequired,
                                      fillColor: Palette.black,
                                      obscureText: false,
                                      context: context,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 20),
                                    GlassTextInput(
                                      width:
                                          MediaQuery.of(context).size.width -
                                          40,
                                      formControl:
                                          _registrationForm.emailControl,
                                      label: localeStrings.email,
                                      hint: localeStrings.yourEmail,
                                      requiredMessage:
                                          localeStrings.emailrequired,
                                      fillColor: Palette.black,
                                      obscureText: false,
                                      context: context,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 20),
                                    GlassTextInput(
                                      width:
                                          MediaQuery.of(context).size.width -
                                          40,
                                      context: context,
                                      formControl:
                                          _registrationForm.passwordControl,
                                      label: localeStrings.password,
                                      hint: localeStrings
                                          .passwordValidationMessage,
                                      requiredMessage:
                                          localeStrings.passwordrequired,
                                      passwordCustomKeyMessage:
                                          localeStrings.mustbeatchars,
                                      fillColor: Palette.black,
                                      obscureText: true,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 20),
                                    GlassTextInput(
                                      width:
                                          MediaQuery.of(context).size.width -
                                          40,
                                      context: context,
                                      formControl: _registrationForm
                                          .confirmPasswordControl,
                                      label: localeStrings.confirmPassword,
                                      hint: localeStrings
                                          .passwordValidationMessage,
                                      passwordCustomKeyMessage:
                                          localeStrings.mustbeatchars,
                                      requiredMessage:
                                          localeStrings.passwordrequired,
                                      fillColor: Palette.black,
                                      obscureText: true,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      textInputAction: TextInputAction.done,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                const Spacer(),
                                Column(
                                  children: [
                                    ReactiveFormConsumer(
                                      builder: (context, form, child) {
                                        return AccentButton(
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width -
                                              40,
                                          label: localeStrings.signup,
                                          onPressed: (form.valid && !isLoading)
                                              ? () {
                                                  context.read<AuthBloc>().add(
                                                    AuthSignUpRequested(
                                                      _registrationForm
                                                          .emailControl
                                                          .value!,
                                                      _registrationForm
                                                          .passwordControl
                                                          .value!,
                                                    ),
                                                  );
                                                }
                                              : null,
                                          variant:
                                              AppButtonVariant.primaryGradient,
                                          showLoading: isLoading,
                                          loadingColor: Palette.whiter,
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 19),
                                    AccentButton(
                                      width:
                                          MediaQuery.of(context).size.width -
                                          40,
                                      label: localeStrings.login,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      variant: AppButtonVariant.primaryLight,
                                      showLoading: false,
                                      loadingColor: Palette.primary,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
