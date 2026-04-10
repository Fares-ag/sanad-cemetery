import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _a11yScaleKey = 'sanad_a11y_text_scale';
const _a11yBoldKey = 'sanad_a11y_bold';
const _a11ySimplifiedKey = 'sanad_a11y_simplified';
/// Legacy key from former "elderly portal" toggle — migrated on load.
const _legacyElderlyModeKey = 'sanad_elderly_mode';

/// Accessibility: text size, emphasis, and layout density (aligned with app accessibility portal).
class AccessibilityProvider extends ChangeNotifier {
  double _textScale = 1.0;
  bool _boldLabels = false;
  bool _simplifiedLayout = false;

  double get textScale => _textScale;
  bool get boldLabels => _boldLabels;
  bool get simplifiedLayout => _simplifiedLayout;

  AccessibilityProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getDouble(_a11yScaleKey);
    if (s != null && s >= 1.0 && s <= 1.6) {
      _textScale = s;
    }
    _boldLabels = prefs.getBool(_a11yBoldKey) ?? false;
    _simplifiedLayout = prefs.getBool(_a11ySimplifiedKey) ?? prefs.getBool(_legacyElderlyModeKey) ?? false;
    if (prefs.containsKey(_legacyElderlyModeKey) && !prefs.containsKey(_a11ySimplifiedKey)) {
      await prefs.setBool(_a11ySimplifiedKey, _simplifiedLayout);
    }
    notifyListeners();
  }

  Future<void> setTextScale(double value) async {
    final v = value.clamp(1.0, 1.6);
    if (_textScale == v) return;
    _textScale = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_a11yScaleKey, v);
    notifyListeners();
  }

  Future<void> setBoldLabels(bool value) async {
    if (_boldLabels == value) return;
    _boldLabels = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_a11yBoldKey, value);
    notifyListeners();
  }

  Future<void> setSimplifiedLayout(bool value) async {
    if (_simplifiedLayout == value) return;
    _simplifiedLayout = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_a11ySimplifiedKey, value);
    notifyListeners();
  }
}
