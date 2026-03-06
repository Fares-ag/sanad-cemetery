import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/maintenance_ticket.dart';

/// Maintenance ticketing: submit, list, status updates. Notifications on status change.
class MaintenanceService extends ChangeNotifier {
  static const _storageKey = 'sanad_maintenance_tickets';
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  List<MaintenanceTicket> _tickets = [];
  List<void Function(MaintenanceTicket)> _listeners = [];

  List<MaintenanceTicket> get tickets => List.unmodifiable(_tickets);

  Future<void> init() async {
    await _loadFromStorage();
    await _initNotifications();
  }

  Future<void> _initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Could navigate to ticket detail if payload contains id
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_storageKey);
    if (json != null) {
      try {
        final list = jsonDecode(json) as List<dynamic>;
        _tickets = list.map((e) => MaintenanceTicket.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _tickets.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(list));
  }

  void addStatusListener(void Function(MaintenanceTicket) listener) {
    _listeners.add(listener);
  }

  void removeStatusListener(void Function(MaintenanceTicket) listener) {
    _listeners.remove(listener);
  }

  Future<MaintenanceTicket> submit({
    required String category,
    String? description,
    required String photoPath,
    required double lat,
    required double lon,
    String? graveId,
  }) async {
    final ticket = MaintenanceTicket(
      id: 'ticket_${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      description: description,
      photoPath: photoPath,
      lat: lat,
      lon: lon,
      graveId: graveId,
      status: TicketStatus.reported,
      createdAt: DateTime.now(),
    );
    _tickets.insert(0, ticket);
    await _saveToStorage();
    notifyListeners();
    return ticket;
  }

  Future<void> updateStatus(String ticketId, TicketStatus status) async {
    final i = _tickets.indexWhere((t) => t.id == ticketId);
    if (i < 0) return;
    final old = _tickets[i];
    final updated = MaintenanceTicket(
      id: old.id,
      category: old.category,
      description: old.description,
      photoPath: old.photoPath,
      lat: old.lat,
      lon: old.lon,
      graveId: old.graveId,
      status: status,
      createdAt: old.createdAt,
      updatedAt: DateTime.now(),
      reportedByUserId: old.reportedByUserId,
    );
    _tickets[i] = updated;
    await _saveToStorage();
    notifyListeners();
    for (final l in _listeners) l(updated);
    await _notifyStatusChange(updated);
  }

  Future<void> _notifyStatusChange(MaintenanceTicket ticket) async {
    const android = AndroidNotificationDetails(
      'maintenance',
      'Maintenance Requests',
      channelDescription: 'Status updates for maintenance reports',
      importance: Importance.defaultImportance,
    );
    const ios = DarwinNotificationDetails();
    await _notifications.show(
      ticket.hashCode % 100000,
      'Maintenance Update',
      'Ticket "${ticket.category}" is now ${ticket.status.displayName}',
      const NotificationDetails(android: android, iOS: ios),
      payload: ticket.id,
    );
  }

  Future<String> savePhotoToAppDir(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final name = 'maintenance_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = dir.path + '/$name';
    // In real app, copy from image_picker temp to file
    return sourcePath; // For now return as-is if already in app dir
  }

  MaintenanceTicket? getById(String id) {
    try {
      return _tickets.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
