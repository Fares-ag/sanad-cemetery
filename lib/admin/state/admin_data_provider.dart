import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../models/deceased.dart';
import '../../models/maintenance_ticket.dart';
import '../models/cemetery_info.dart';
import '../models/section.dart';

const _keyDeceased = 'admin_deceased_json';
const _keySections = 'admin_sections_json';
const _keyTickets = 'admin_maintenance_tickets_json';
const _keyTicketNotes = 'admin_ticket_notes_json';
const _keyCemeteryInfo = 'admin_cemetery_info_json';
const _keyPathsGeojson = 'admin_paths_geojson';

/// In-memory admin data with optional persistence to localStorage (web) / SharedPreferences.
/// Pure frontend: no API. Later replace with API client.
class AdminDataProvider extends ChangeNotifier {
  final List<Deceased> _deceased = [];
  final List<Section> _sections = [];
  final List<MaintenanceTicket> _tickets = [];
  final Map<String, String> _ticketNotes = {};
  CemeteryInfo _cemeteryInfo = const CemeteryInfo();
  String _pathsGeojson = '';
  bool _loaded = false;

  List<Deceased> get deceased => List.unmodifiable(_deceased);
  List<Section> get sections => List.unmodifiable(_sections);
  List<MaintenanceTicket> get tickets => List.unmodifiable(_tickets);
  CemeteryInfo get cemeteryInfo => _cemeteryInfo;
  String get pathsGeojson => _pathsGeojson;
  bool get loaded => _loaded;

  int get openTicketsCount =>
      _tickets.where((t) => t.status != TicketStatus.resolved).length;

  String? getTicketNote(String ticketId) => _ticketNotes[ticketId];

  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final deceasedJson = prefs.getString(_keyDeceased);
      final sectionsJson = prefs.getString(_keySections);
      final ticketsJson = prefs.getString(_keyTickets);
      final notesJson = prefs.getString(_keyTicketNotes);
      final infoJson = prefs.getString(_keyCemeteryInfo);
      final paths = prefs.getString(_keyPathsGeojson);

      if (deceasedJson != null) {
        final list = jsonDecode(deceasedJson) as List<dynamic>;
        _deceased.clear();
        for (final e in list) {
          try {
            _deceased.add(Deceased.fromJson(e as Map<String, dynamic>));
          } catch (_) {}
        }
      }
      if (sectionsJson != null) {
        final list = jsonDecode(sectionsJson) as List<dynamic>;
        _sections.clear();
        for (final e in list) {
          try {
            _sections.add(Section.fromJson(e as Map<String, dynamic>));
          } catch (_) {}
        }
      }
      if (ticketsJson != null) {
        final list = jsonDecode(ticketsJson) as List<dynamic>;
        _tickets.clear();
        for (final e in list) {
          try {
            _tickets.add(MaintenanceTicket.fromJson(e as Map<String, dynamic>));
          } catch (_) {}
        }
      }
      if (notesJson != null) {
        final map = jsonDecode(notesJson) as Map<String, dynamic>;
        _ticketNotes.clear();
        for (final e in map.entries) {
          _ticketNotes[e.key as String] = e.value as String? ?? '';
        }
      }
      if (infoJson != null) {
        try {
          _cemeteryInfo = CemeteryInfo.fromJson(jsonDecode(infoJson) as Map<String, dynamic>?);
        } catch (_) {}
      }
      if (paths != null) _pathsGeojson = paths;

      _loaded = true;
      notifyListeners();
    } catch (_) {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _keyDeceased,
        jsonEncode(_deceased.map((e) => e.toJson()).toList()),
      );
      await prefs.setString(
        _keySections,
        jsonEncode(_sections.map((e) => e.toJson()).toList()),
      );
      await prefs.setString(
        _keyTickets,
        jsonEncode(_tickets.map((e) => e.toJson()).toList()),
      );
      await prefs.setString(
        _keyTicketNotes,
        jsonEncode(_ticketNotes),
      );
      await prefs.setString(
        _keyCemeteryInfo,
        jsonEncode(_cemeteryInfo.toJson()),
      );
      await prefs.setString(_keyPathsGeojson, _pathsGeojson);
    } catch (_) {}
  }

  // ——— Deceased ———
  Deceased? getDeceasedById(String id) {
    try {
      return _deceased.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addOrUpdateDeceased(Deceased d) async {
    final i = _deceased.indexWhere((e) => e.id == d.id);
    if (i >= 0) {
      _deceased[i] = d;
    } else {
      _deceased.add(d);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> deleteDeceased(String id) async {
    _deceased.removeWhere((e) => e.id == id);
    await _persist();
    notifyListeners();
  }

  /// Generate a new ID for a deceased record.
  String newDeceasedId() => 'grave-${const Uuid().v4().substring(0, 8)}';

  // ——— Sections ———
  Section? getSectionById(String id) {
    try {
      return _sections.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addOrUpdateSection(Section s) async {
    final i = _sections.indexWhere((e) => e.id == s.id);
    if (i >= 0) {
      _sections[i] = s;
    } else {
      _sections.add(s);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> deleteSection(String id) async {
    _sections.removeWhere((e) => e.id == id);
    await _persist();
    notifyListeners();
  }

  String newSectionId() => 'section-${const Uuid().v4().substring(0, 8)}';

  // ——— Maintenance tickets ———
  MaintenanceTicket? getTicketById(String id) {
    try {
      return _tickets.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateTicketStatus(String id, TicketStatus status) async {
    final i = _tickets.indexWhere((e) => e.id == id);
    if (i < 0) return;
    _tickets[i] = MaintenanceTicket(
      id: _tickets[i].id,
      category: _tickets[i].category,
      description: _tickets[i].description,
      photoPath: _tickets[i].photoPath,
      lat: _tickets[i].lat,
      lon: _tickets[i].lon,
      graveId: _tickets[i].graveId,
      status: status,
      createdAt: _tickets[i].createdAt,
      updatedAt: DateTime.now(),
      reportedByUserId: _tickets[i].reportedByUserId,
    );
    await _persist();
    notifyListeners();
  }

  Future<void> setTicketNote(String ticketId, String note) async {
    if (note.isEmpty) {
      _ticketNotes.remove(ticketId);
    } else {
      _ticketNotes[ticketId] = note;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> addTicket(MaintenanceTicket t) async {
    _tickets.insert(0, t);
    await _persist();
    notifyListeners();
  }

  Future<void> deleteTicket(String id) async {
    _tickets.removeWhere((e) => e.id == id);
    _ticketNotes.remove(id);
    await _persist();
    notifyListeners();
  }

  String newTicketId() => 'ticket_${DateTime.now().millisecondsSinceEpoch}';

  // ——— Cemetery info ———
  Future<void> setCemeteryInfo(CemeteryInfo info) async {
    _cemeteryInfo = info;
    await _persist();
    notifyListeners();
  }

  // ——— Paths GeoJSON ———
  Future<void> setPathsGeojson(String geojson) async {
    _pathsGeojson = geojson;
    await _persist();
    notifyListeners();
  }

  // ——— Import (merge) ———
  Future<void> importDeceased(List<Deceased> list) async {
    for (final d in list) {
      final i = _deceased.indexWhere((e) => e.id == d.id);
      if (i >= 0) {
        _deceased[i] = d;
      } else {
        _deceased.add(d);
      }
    }
    await _persist();
    notifyListeners();
  }

  Future<void> importSections(List<Section> list) async {
    for (final s in list) {
      final i = _sections.indexWhere((e) => e.id == s.id);
      if (i >= 0) {
        _sections[i] = s;
      } else {
        _sections.add(s);
      }
    }
    await _persist();
    notifyListeners();
  }
}
