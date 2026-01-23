import 'package:flutter/material.dart';

enum AppButtonVariant { primaryGradient, primaryLight, neutral, destructive }

enum AuthError {
  none,
  userNotFound,
  wrongPassword,
  invalidEmail,
  emailAlreadyInUse,
  weakPassword,
  unknown,
  invalidCredentials,
}

extension AuthErrorExtension on AuthError {
  String toMessage(BuildContext context) {
    switch (this) {
      case AuthError.userNotFound:
        return 'Пользователь не найден';
      case AuthError.wrongPassword:
        return 'Неверный пароль';
      case AuthError.invalidEmail:
        return 'Некорректный email';
      case AuthError.emailAlreadyInUse:
        return 'Этот email уже используется';
      case AuthError.weakPassword:
        return 'Пароль слишком слабый (минимум 6 символов)';

      case AuthError.invalidCredentials:
        return 'Неверный логин или пароль';
      case AuthError.none:
      case AuthError.unknown:
        return 'Произошла ошибка. Попробуйте позже.';
    }
  }
}
