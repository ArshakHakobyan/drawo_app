import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  late final Locale locale;

  AppLocalizations(this.locale);

  static List<Locale> get supportedLanguages =>
      const _AppLocalizationsDelegate().supportedLanguages;

  bool isSupported(Locale type) =>
      const _AppLocalizationsDelegate().isSupported(type);

  // Helper method to keep the code in the widgets concise Localizations are
  // accessed using an InheritedWidget "of" syntax
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Map<String, dynamic> _localizedStrings = {};
  Map<String, dynamic> _localizedStringsDefault = {};

  Future<bool> load() async {
    try {
      // Load the language JSON file from the "lang" folder
      String jsonString = await rootBundle.loadString(
        'assets/I18n/${locale.languageCode}.json',
      );
      _localizedStrings = json.decode(jsonString);

      String jsonStringEn = await rootBundle.loadString('assets/I18n/en.json');
      _localizedStringsDefault = json.decode(jsonStringEn);
    } catch (e) {
      debugPrint('Error loading localizations: $e');
      _localizedStrings = {};
      _localizedStringsDefault = {};
    }

    return true;
  }

  // This method will be called from every widget which needs a localized text
  String translate(String key) {
    List<String> keys = key.split('.');
    dynamic value = _localizedStrings;

    for (String k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        value = null;
        break;
      }
    }

    if (value == null) {
      value = _localizedStringsDefault;
      for (String k in keys) {
        if (value is Map<String, dynamic> && value.containsKey(k)) {
          value = value[k];
        } else {
          return key; // Return the key itself if not found in defaults
        }
      }
    }

    return value.toString();
  }

  String get appTitle => translate('appTitle');
  String get loginTitle => translate('loginTitle');
  String get registration => translate('registration');
  String get login => translate('login');
  String get name => translate('name');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirmPassword');
  String get signup => translate('signup');
  String get gallery => translate('gallery');
  String get edit => translate('edit');
  String get newImage => translate('newImage');
  String get enterName => translate('enterName');
  String get enterEmail => translate('enterEmail');
  String get enterPassword => translate('enterPassword');
  String get yourEmail => translate('yourEmail');
  String get passwordValidationMessage =>
      translate('passwordValidationMessage');
  String get create => translate('create');
  String get areyousureexit => translate('areyousureexit');
  String get yes => translate('yes');
  String get cancel => translate('cancel');
  String get accountexist => translate('accountexist');
  String get wrongcredentials => translate('wrongcredentials');
  String get emailrequired => translate('emailrequired');
  String get passwordrequired => translate('passwordrequired');
  String get namerequired => translate('namerequired');
  String get entervalidemail => translate('entervalidemail');
  String get passwordshouldmatch => translate('passwordshouldmatch');
  String get mustbeatchars => translate('mustbeatchars');
  String get imageSaved => translate('imageSaved');
  String get imageSavedDesc => translate('imageSavedDesc');
  String get imageUpdated => translate('imageUpdated');
  String get imageUpdatedDesc => translate('imageUpdatedDesc');
  String get imageDeleted => translate('imageDeleted');
  String get imageDeletedDesc => translate('imageDeletedDesc');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const _AppLocalizationsDelegate();

  List<Locale> get supportedLanguages => [
    const Locale('en'),
    const Locale('ru'),
  ];

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return supportedLanguages.contains(locale);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
