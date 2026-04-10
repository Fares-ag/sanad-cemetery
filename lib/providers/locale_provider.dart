import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeKey = 'app_locale';

/// Supported BCP-47 language codes. Arabic & Urdu use RTL.
const kSupportedLanguageCodes = ['en', 'ar', 'hi', 'ur', 'ml'];

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  static bool isRtlCode(String code) => code == 'ar' || code == 'ur';

  bool get isRtl => isRtlCode(_locale.languageCode);

  LocaleProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code != null && kSupportedLanguageCodes.contains(code)) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!kSupportedLanguageCodes.contains(locale.languageCode)) return;
    if (_locale == locale) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  /// Cycles en ↔ ar for quick toggle (toolbar). Full list in settings.
  Future<void> toggleLocale() async {
    await setLocale(isArabic ? const Locale('en') : const Locale('ar'));
  }
}
