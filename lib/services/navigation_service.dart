import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart' show rootBundle;
import 'package:latlong2/latlong.dart';

/// Path network built from cemetery walkways (GeoJSON LineStrings).
/// Supports path-finding and walking distance along paths.
class _PathNetwork {
  final List<List<LatLng>> _segments = [];
  final Map<String, List<_Edge>> _graph = {};
  static const _distance = Distance();

  static String _key(LatLng p) =>
      '${p.latitude.toStringAsFixed(6)},${p.longitude.toStringAsFixed(6)}';

  void loadFromGeoJson(Map<String, dynamic> json) {
    _segments.clear();
    _graph.clear();
    final features = json['features'] as List<dynamic>? ?? [];
    for (final f in features) {
      final geom = (f as Map)['geometry'];
      if (geom == null || geom['type'] != 'LineString') continue;
      final coords = geom['coordinates'] as List<dynamic>? ?? [];
      if (coords.length < 2) continue;
      final points = <LatLng>[];
      for (final c in coords) {
        final arr = c as List;
        if (arr.length >= 2) {
          points.add(LatLng((arr[1] as num).toDouble(), (arr[0] as num).toDouble()));
        }
      }
      if (points.length >= 2) _segments.add(points);
    }
    _buildGraph();
  }

  void _buildGraph() {
    for (final seg in _segments) {
      for (var i = 0; i < seg.length - 1; i++) {
        final a = seg[i];
        final b = seg[i + 1];
        final d = _distance(a, b);
        _graph.putIfAbsent(_key(a), () => []).add(_Edge(_key(b), b, d));
        _graph.putIfAbsent(_key(b), () => []).add(_Edge(_key(a), a, d));
      }
    }
  }

  /// Snap point to nearest vertex on path network (segment endpoint). Returns (snapped LatLng, graph key).
  ({LatLng point, String key})? snapToNetwork(LatLng p) {
    if (_segments.isEmpty) return null;
    double bestDist = double.infinity;
    LatLng? bestPoint;
    String? bestKey;
    for (final seg in _segments) {
      for (final pt in seg) {
        final d = _distance(p, pt);
        if (d < bestDist) {
          bestDist = d;
          bestPoint = pt;
          bestKey = _key(pt);
        }
      }
    }
    if (bestPoint == null || bestKey == null) return null;
    return (point: bestPoint, key: bestKey);
  }

  /// Find shortest path from startKey to endKey. Returns path points and total walking distance.
  ({List<LatLng> path, double distanceMeters})? findPath(String startKey, LatLng startPoint, String endKey, LatLng endPoint) {
    if (startKey == endKey) {
      return (path: [startPoint], distanceMeters: 0.0);
    }
    if (!_graph.containsKey(startKey) || !_graph.containsKey(endKey)) {
      return null;
    }
    final dist = <String, double>{};
    final prev = <String, String>{};
    final nodePoint = <String, LatLng>{};
    nodePoint[startKey] = startPoint;
    nodePoint[endKey] = endPoint;
    dist[startKey] = 0;
    var pq = <_PQEntry>[_PQEntry(startKey, 0)];
    while (pq.isNotEmpty) {
      pq.sort((a, b) => a.dist.compareTo(b.dist));
      final u = pq.removeAt(0);
      if (u.key == endKey) break;
      if ((dist[u.key] ?? double.infinity) < u.dist) continue;
      for (final edge in _graph[u.key] ?? []) {
        nodePoint[edge.toKey] = edge.toPoint;
        final alt = (dist[u.key] ?? double.infinity) + edge.distance;
        if (alt < (dist[edge.toKey] ?? double.infinity)) {
          dist[edge.toKey] = alt;
          prev[edge.toKey] = u.key;
          pq.add(_PQEntry(edge.toKey, alt));
        }
      }
    }
    if (!prev.containsKey(endKey)) return null;
    final path = <LatLng>[];
    var k = endKey;
    while (true) {
      final pt = nodePoint[k] ?? (k == startKey ? startPoint : (k == endKey ? endPoint : null));
      if (pt != null) path.add(pt);
      if (k == startKey) break;
      k = prev[k] ?? startKey;
    }
    final reversed = path.reversed.toList();
    path.clear();
    path.addAll(reversed);
    final totalDist = dist[endKey] ?? 0.0;
    return (path: path, distanceMeters: totalDist);
  }

  bool get hasPaths => _segments.isNotEmpty;
}

class _Edge {
  final String toKey;
  final LatLng toPoint;
  final double distance;

  _Edge(this.toKey, this.toPoint, this.distance);
}

class _PQEntry {
  final String key;
  final double dist;

  _PQEntry(this.key, this.dist);
}

/// Shortest path from user to plot using cemetery paths (GeoJSON).
/// Uses path-based walking distance when path network is loaded.
class NavigationService {
  static const double arrivalRadiusMeters = 2.0;

  final List<LatLng> _pathPoints = [];
  final _PathNetwork _network = _PathNetwork();
  static const _distance = Distance();

  double? _lastWalkingDistanceMeters;

  /// Load cemetery path network from assets/geojson/paths.geojson.
  Future<void> loadPathNetwork() async {
    try {
      final json = await rootBundle.loadString('assets/geojson/paths.geojson');
      _network.loadFromGeoJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      // No path data - will fall back to straight line
    }
  }

  /// Distance in meters: walking distance along path when available, else straight-line.
  double distanceMeters(LatLng a, LatLng b) {
    if (_lastWalkingDistanceMeters != null) return _lastWalkingDistanceMeters!;
    return _distance(a, b);
  }

  /// Bearing from point A to B in degrees (0 = North, 90 = East).
  double bearingDegrees(LatLng from, LatLng to) {
    final dLon = (to.longitude - from.longitude) * math.pi / 180;
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    var bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  bool isWithinArrivalRadius(LatLng user, LatLng plot) {
    return _distance(user, plot) <= arrivalRadiusMeters;
  }

  double directionToPlot(LatLng userPosition, LatLng plotPosition) {
    return bearingDegrees(userPosition, plotPosition);
  }

  List<LatLng> get pathPoints => List.unmodifiable(_pathPoints);

  /// Ensure path from user to plot. Uses path network when available for walking distance.
  void ensurePath(LatLng user, LatLng plot) {
    if (user.latitude == plot.latitude && user.longitude == plot.longitude) {
      _pathPoints.clear();
      _lastWalkingDistanceMeters = 0.0;
      return;
    }

    _lastWalkingDistanceMeters = null;

    try {
      if (_network.hasPaths) {
        final snapUser = _network.snapToNetwork(user);
        final snapPlot = _network.snapToNetwork(plot);
        if (snapUser != null && snapPlot != null) {
          final result = _network.findPath(
            snapUser.key, snapUser.point,
            snapPlot.key, snapPlot.point,
          );
          if (result != null && result.path.isNotEmpty) {
            _pathPoints.clear();
            _pathPoints.add(user);
            _pathPoints.addAll(result.path);
            _pathPoints.add(plot);
            _lastWalkingDistanceMeters = result.distanceMeters +
                _distance(user, snapUser.point) +
                _distance(snapPlot.point, plot);
            return;
          }
        }
      }
    } catch (_) {
      // Path network not loaded (e.g. after hot reload) or other error - fall through
    }

    // Fallback: straight line
    _pathPoints.clear();
    _pathPoints.add(user);
    _pathPoints.add(plot);
    _lastWalkingDistanceMeters = _distance(user, plot);
  }
}
