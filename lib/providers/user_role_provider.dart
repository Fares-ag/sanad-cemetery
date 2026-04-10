import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_role.dart';

const _roleKey = 'sanad_demo_user_role';

class UserRoleProvider extends ChangeNotifier {
  UserRole _role = UserRole.visitor;

  UserRole get role => _role;

  UserRoleProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_roleKey);
    if (name == 'awqaf') {
      _role = UserRole.visitor;
      await prefs.setString(_roleKey, _role.name);
      notifyListeners();
      return;
    }
    if (name != null) {
      for (final r in UserRole.values) {
        if (r.name == name) {
          _role = r;
          notifyListeners();
          break;
        }
      }
    }
  }

  Future<void> setRole(UserRole role) async {
    if (_role == role) return;
    _role = role;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role.name);
    notifyListeners();
  }
}
