import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _localeKey = "selected_locale_v2";

  Future<void> saveLocale({required String locale}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale);
  }

  Future<String?> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey);
  }
}
