import 'package:fuzzy/fuzzy.dart';
import 'package:flutter/foundation.dart';
import '../models/deceased.dart';
import '../models/search_params.dart';

/// Global search with fuzzy matching and metadata filters.
/// Can be backed by in-memory Fuzzy (for demo) or swapped for Elasticsearch/Algolia for 100k+ records.
class SearchService extends ChangeNotifier {
  List<Deceased> _allRecords = [];
  Fuzzy<String>? _fuzzy;
  final List<String> _searchableStrings = [];

  static String _searchable(Deceased d) {
    return '${d.firstName} ${d.middleName} ${d.lastName} ${d.maidenName ?? ''}'.toLowerCase();
  }

  void _rebuildFuzzy() {
    _searchableStrings.clear();
    for (final d in _allRecords) {
      _searchableStrings.add(_searchable(d));
    }
    _fuzzy = Fuzzy(
      _searchableStrings,
      options: FuzzyOptions(threshold: 0.4, findAllMatches: true, tokenize: true),
    );
  }

  /// Initialize with full dataset (e.g. from API or local DB).
  /// For production 100k+ records, replace this with Elasticsearch/Algolia client.
  Future<void> setRecords(List<Deceased> records) async {
    _allRecords = List.from(records);
    _rebuildFuzzy();
  }

  void addOrUpdateRecord(Deceased record) {
    final i = _allRecords.indexWhere((e) => e.id == record.id);
    if (i >= 0) {
      _allRecords[i] = record;
    } else {
      _allRecords.add(record);
    }
    _rebuildFuzzy();
    notifyListeners();
  }

  /// Search with optional query string and filters. Returns instantly using index.
  List<Deceased> search(String? query, SearchParams params) {
    List<Deceased> base = _allRecords;

    // Apply filters first (date range, veteran, branch)
    if (params.birthYearFrom != null) {
      base = base.where((d) => d.birthYear != null && d.birthYear! >= params.birthYearFrom!).toList();
    }
    if (params.birthYearTo != null) {
      base = base.where((d) => d.birthYear != null && d.birthYear! <= params.birthYearTo!).toList();
    }
    if (params.deathYearFrom != null) {
      base = base.where((d) => d.deathYear != null && d.deathYear! >= params.deathYearFrom!).toList();
    }
    if (params.deathYearTo != null) {
      base = base.where((d) => d.deathYear != null && d.deathYear! <= params.deathYearTo!).toList();
    }
    if (params.isVeteran == true) {
      base = base.where((d) => d.isVeteran).toList();
    }
    if (params.branchOfService != null && params.branchOfService!.isNotEmpty) {
      base = base
          .where((d) =>
              d.branchOfService != null &&
              d.branchOfService!.toLowerCase().contains(params.branchOfService!.toLowerCase()))
          .toList();
    }

    // Name filters (exact or contains)
    if (params.firstName != null && params.firstName!.isNotEmpty) {
      base = base
          .where((d) => d.firstName.toLowerCase().contains(params.firstName!.toLowerCase()))
          .toList();
    }
    if (params.middleName != null && params.middleName!.isNotEmpty) {
      base = base
          .where((d) => d.middleName.toLowerCase().contains(params.middleName!.toLowerCase()))
          .toList();
    }
    if (params.lastName != null && params.lastName!.isNotEmpty) {
      base = base
          .where((d) => d.lastName.toLowerCase().contains(params.lastName!.toLowerCase()))
          .toList();
    }
    if (params.maidenName != null && params.maidenName!.isNotEmpty) {
      base = base
          .where((d) =>
              d.maidenName != null &&
              d.maidenName!.toLowerCase().contains(params.maidenName!.toLowerCase()))
          .toList();
    }

    // Fuzzy text search on names if query provided
    if (query != null && query.trim().isNotEmpty && base.isNotEmpty && _fuzzy != null) {
      final filteredIds = base.map((e) => e.id).toSet();
      final filteredRecords = _allRecords.where((e) => filteredIds.contains(e.id)).toList();
      final filteredStrings = filteredRecords.map(_searchable).toList();
      final fuzzyFiltered = Fuzzy(
        filteredStrings,
        options: FuzzyOptions(threshold: 0.4, findAllMatches: true, tokenize: true),
      );
      final result = fuzzyFiltered.search(query.trim());
      final indices = result.map((r) => filteredStrings.indexOf(r.item)).toList();
      return indices.map((i) => filteredRecords[i]).toList();
    }

    return base;
  }

  Deceased? getById(String id) {
    try {
      return _allRecords.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
