import 'package:flutter/foundation.dart';
import '../services/emergency_storage.dart';

/// Provides emergency info for the QR card and syncs with Settings.
class EmergencyProvider extends ChangeNotifier {
  EmergencyInfo _info = const EmergencyInfo();

  EmergencyInfo get info => _info;

  Future<void> load() async {
    _info = await EmergencyStorage.load();
    notifyListeners();
  }

  Future<void> save(EmergencyInfo info) async {
    await EmergencyStorage.save(info);
    _info = info;
    notifyListeners();
  }
}
