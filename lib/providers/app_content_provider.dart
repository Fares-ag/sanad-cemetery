import 'package:flutter/foundation.dart';

import '../models/app_content.dart';
import '../services/app_content_api.dart';

/// Municipality-published announcements and ministry headline for the mobile app.
class AppContentProvider extends ChangeNotifier {
  AppContentPayload? _data;
  bool loading = false;
  DateTime? lastUpdated;

  /// Last successful refresh used the live HTTP API.
  bool lastRefreshFromNetwork = false;

  /// Last successful refresh used bundled [assets/fallback_app_content.json] because the API was unreachable.
  bool lastRefreshUsedAssetFallback = false;

  AppContentPayload? get data => _data;

  bool get hasPayload => _data != null;

  Future<void> refresh() async {
    loading = true;
    notifyListeners();
    final outcome = await fetchPublicAppContentWithFallback();
    _data = outcome.payload;
    lastRefreshFromNetwork = outcome.fromNetwork;
    lastRefreshUsedAssetFallback = outcome.usedAssetFallback;
    lastUpdated = DateTime.now();
    loading = false;
    notifyListeners();
  }
}
