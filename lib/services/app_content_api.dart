import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../models/app_content.dart';

/// Override with `--dart-define=CONTENT_API_BASE=http://YOUR_LAN_IP:3333` on physical devices.
String contentApiBase() {
  const env = String.fromEnvironment('CONTENT_API_BASE');
  if (env.isNotEmpty) return env;
  if (Platform.isAndroid) return 'http://10.0.2.2:3333';
  return 'http://127.0.0.1:3333';
}

class AppContentFetchOutcome {
  const AppContentFetchOutcome({
    required this.payload,
    required this.fromNetwork,
    required this.usedAssetFallback,
  });

  final AppContentPayload? payload;
  final bool fromNetwork;
  final bool usedAssetFallback;
}

Future<AppContentPayload?> _loadBundledFallback() async {
  try {
    final raw = await rootBundle.loadString('assets/fallback_app_content.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return AppContentPayload.fromJson(map);
  } catch (_) {
    return null;
  }
}

/// Tries HTTP first; if the server is unreachable (typical on device without LAN), loads [assets/fallback_app_content.json].
Future<AppContentFetchOutcome> fetchPublicAppContentWithFallback() async {
  final uri = Uri.parse('${contentApiBase()}/api/public/app-content');
  try {
    final response = await http.get(uri).timeout(const Duration(seconds: 12));
    if (response.statusCode == 200) {
      final map = jsonDecode(response.body) as Map<String, dynamic>;
      return AppContentFetchOutcome(
        payload: AppContentPayload.fromJson(map),
        fromNetwork: true,
        usedAssetFallback: false,
      );
    }
  } catch (_) {
    /* fall through to bundled JSON */
  }
  final fb = await _loadBundledFallback();
  if (fb != null) {
    return AppContentFetchOutcome(
      payload: fb,
      fromNetwork: false,
      usedAssetFallback: true,
    );
  }
  return const AppContentFetchOutcome(payload: null, fromNetwork: false, usedAssetFallback: false);
}

/// Submits a burial/funeral announcement for **municipality review** (not shown publicly until approved).
Future<({bool ok, String? error})> submitAnnouncementForReview({
  required String name,
  String? nameAr,
  required String passedAwayDate,
  required String serviceType,
  required String serviceDateTimeIso,
  required String burialLocation,
  String? burialLocationAr,
  required String iconKey,
}) async {
  final uri = Uri.parse('${contentApiBase()}/api/public/announcement-submissions');
  final body = <String, dynamic>{
    'name': name,
    if (nameAr != null && nameAr.trim().isNotEmpty) 'nameAr': nameAr.trim(),
    'passedAwayDate': passedAwayDate,
    'serviceType': serviceType,
    'serviceDateTime': serviceDateTimeIso,
    'burialLocation': burialLocation,
    if (burialLocationAr != null && burialLocationAr.trim().isNotEmpty) 'burialLocationAr': burialLocationAr.trim(),
    'iconKey': iconKey,
  };
  try {
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 201) {
      return (ok: true, error: null);
    }
    return (ok: false, error: 'http_${response.statusCode}');
  } catch (e) {
    return (ok: false, error: e.toString());
  }
}
