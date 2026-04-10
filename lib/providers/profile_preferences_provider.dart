import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _birthYearKey = 'sanad_birth_year';

/// Optional profile fields stored separately from emergency QR payload.
class ProfilePreferencesProvider extends ChangeNotifier {
  int? _birthYear;

  int? get birthYear => _birthYear;

  ProfilePreferencesProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _birthYear = prefs.getInt(_birthYearKey);
    notifyListeners();
  }

  Future<void> setBirthYear(int? year) async {
    _birthYear = year;
    final prefs = await SharedPreferences.getInstance();
    if (year == null) {
      await prefs.remove(_birthYearKey);
    } else {
      await prefs.setInt(_birthYearKey, year);
    }
    notifyListeners();
  }
}
