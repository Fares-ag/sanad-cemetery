import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Emergency contact entry for QR and display.
class EmergencyContact {
  const EmergencyContact({
    required this.name,
    required this.relation,
    required this.phone,
  });

  final String name;
  final String relation;
  final String phone;

  Map<String, dynamic> toJson() => {
        'name': name,
        'relation': relation,
        'phone': phone,
      };

  static EmergencyContact fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] as String? ?? '',
      relation: json['relation'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  String get displayLine => '$name ($relation): $phone';
}

/// Saved emergency info for QR code encoding and display.
class EmergencyInfo {
  const EmergencyInfo({
    this.userName,
    this.contacts = const [],
    this.shareLocation = true,
  });

  final String? userName;
  final List<EmergencyContact> contacts;
  final bool shareLocation;

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'contacts': contacts.map((c) => c.toJson()).toList(),
        'shareLocation': shareLocation,
      };

  static EmergencyInfo fromJson(Map<String, dynamic> json) {
    final list = json['contacts'];
    return EmergencyInfo(
      userName: json['userName'] as String?,
      contacts: list is List
          ? list.map<EmergencyContact>((e) => EmergencyContact.fromJson(Map<String, dynamic>.from(e as Map))).toList()
          : [],
      shareLocation: json['shareLocation'] as bool? ?? true,
    );
  }

  /// Plain-text payload for QR code (readable by scanners and first responders).
  String toQrPayload() {
    final buf = StringBuffer();
    buf.writeln('SANAD CEMETERY – EMERGENCY INFO');
    buf.writeln('Do not use for non-emergency.');
    if (userName != null && userName!.isNotEmpty) buf.writeln('Name: $userName');
    buf.writeln('Share location with responders: ${shareLocation ? 'Yes' : 'No'}');
    if (contacts.isNotEmpty) {
      buf.writeln('Contacts:');
      for (final c in contacts) {
        buf.writeln('  ${c.displayLine}');
      }
    }
    return buf.toString().trim();
  }

  bool get hasData => (userName != null && userName!.isNotEmpty) || contacts.isNotEmpty;
}

/// Persists and loads emergency info for the QR card and settings.
class EmergencyStorage {
  static const _key = 'sanad_emergency_info';

  static Future<EmergencyInfo> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const EmergencyInfo();
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return EmergencyInfo.fromJson(map);
    } catch (_) {
      return const EmergencyInfo();
    }
  }

  static Future<void> save(EmergencyInfo info) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(info.toJson()));
  }
}
