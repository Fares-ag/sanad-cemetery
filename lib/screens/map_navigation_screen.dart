import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../models/deceased.dart';
import '../services/search_service.dart';
import '../services/navigation_service.dart';

class MapNavigationScreen extends StatefulWidget {
  final String graveId;

  const MapNavigationScreen({super.key, required this.graveId});

  @override
  State<MapNavigationScreen> createState() => _MapNavigationScreenState();
}

class _MapNavigationScreenState extends State<MapNavigationScreen> {
  final MapController _mapController = MapController();
  StreamSubscription<CompassEvent>? _compassSub;
  StreamSubscription<Position>? _positionSub;
  double? _compassHeading;
  Position? _userPosition;
  Deceased? _deceased;
  double? _bearingToTarget;
  bool _arrivalVibrated = false;
  bool _locationDenied = false;
  bool _locationLoading = true;
  static const double _arrivalRadiusM = 2.0;

  @override
  void initState() {
    super.initState();
    _deceased = context.read<SearchService>().getById(widget.graveId);
    _requestLocationAndStart();
    _startCompass();
  }

  Future<void> _requestLocationAndStart() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() { _locationDenied = true; _locationLoading = false; });
      return;
    }
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
      if (mounted) setState(() { _locationDenied = true; _locationLoading = false; });
      return;
    }
    // Try one-time position for quick center, then start stream
    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) setState(() { _userPosition = pos; _locationLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _locationLoading = false; });
    }
    _startLocationStream();
  }

  void _startCompass() {
    _compassSub = FlutterCompass.events?.listen((event) {
      if (event.heading != null && mounted) {
        setState(() => _compassHeading = event.heading);
      }
    });
  }

  void _startLocationStream() {
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((p) {
      if (!mounted) return;
      setState(() {
        _userPosition = p;
        final nav = context.read<NavigationService>();
        if (_deceased != null) {
          nav.ensurePath(LatLng(p.latitude, p.longitude), LatLng(_deceased!.lat, _deceased!.lon));
          _bearingToTarget = nav.directionToPlot(
            LatLng(p.latitude, p.longitude),
            LatLng(_deceased!.lat, _deceased!.lon),
          );
          final dist = nav.distanceMeters(
            LatLng(p.latitude, p.longitude),
            LatLng(_deceased!.lat, _deceased!.lon),
          );
          if (dist <= _arrivalRadiusM && !_arrivalVibrated) {
            _arrivalVibrated = true;
            HapticFeedback.heavyImpact();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _positionSub?.cancel();
    super.dispose();
  }

  void _centerOnMe() {
    if (_userPosition != null) {
      _mapController.move(
        LatLng(_userPosition!.latitude, _userPosition!.longitude),
        18,
      );
    }
  }

  void _centerOnGrave() {
    if (_deceased != null) {
      _mapController.move(LatLng(_deceased!.lat, _deceased!.lon), 18);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_deceased == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          title: Text(AppStrings.tr(context, 'navigate'), style: AppTheme.appBarTitle),
        ),
        body: Center(
          child: Text(
            AppStrings.tr(context, 'graveNotFound'),
            style: AppTheme.bodyMedium,
          ),
        ),
      );
    }

    final plot = LatLng(_deceased!.lat, _deceased!.lon);
    final center = _userPosition != null
        ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
        : plot;
    final nav = context.watch<NavigationService>();
    if (_userPosition != null) {
      nav.ensurePath(center, plot);
    }

    if (_locationLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          title: Text(
            '${AppStrings.tr(context, 'walkTo')} ${_deceased!.fullName}',
            style: AppTheme.appBarTitle.copyWith(fontSize: 18),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppTheme.maroon),
              const SizedBox(height: AppTheme.spaceLg),
              Text(
                AppStrings.tr(context, 'gettingLocation'),
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary(0.7)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          '${AppStrings.tr(context, 'walkTo')} ${_deceased!.fullName}',
          style: AppTheme.appBarTitle.copyWith(fontSize: 18),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 18,
              minZoom: 5,
              maxZoom: 22,
              onMapReady: () {
                if (_userPosition != null) {
                  _mapController.move(
                    LatLng(_userPosition!.latitude, _userPosition!.longitude),
                    18,
                  );
                } else {
                  _mapController.move(plot, 18);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sanad.cemetery.sanad_cemetery',
              ),
              if (nav.pathPoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: nav.pathPoints,
                      color: AppTheme.maroon,
                      strokeWidth: 5,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: plot,
                    width: 48,
                    height: 48,
                    child: const Icon(
                      AppIcons.place,
                      color: AppTheme.maroon,
                      size: 48,
                    ),
                  ),
                  if (_userPosition != null)
                    Marker(
                      point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
                      width: 36,
                      height: 36,
                      child: const Icon(
                        Icons.person_pin_circle_rounded,
                        color: AppTheme.maroon,
                        size: 36,
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (_locationDenied)
            Positioned(
              top: MediaQuery.paddingOf(context).top + kToolbarHeight + 12,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.border()),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(AppIcons.locationOff, color: Colors.red.shade700, size: AppIcons.sizeLg),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.tr(context, 'locationUnavailable'),
                        style: AppTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            right: 16,
            bottom: 180,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'center_grave',
                  onPressed: _centerOnGrave,
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.maroon,
                  child: const Icon(AppIcons.place),
                  tooltip: AppStrings.tr(context, 'centerOnGrave'),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'center_me',
                  onPressed: _userPosition != null ? _centerOnMe : null,
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.maroon,
                  child: const Icon(AppIcons.myLocation),
                  tooltip: AppStrings.tr(context, 'centerOnMe'),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 28,
            child: _DirectionCard(
              compassHeading: _compassHeading ?? 0,
              bearingToTarget: _bearingToTarget ?? 0,
              distanceMeters: _userPosition != null
                  ? nav.distanceMeters(
                      LatLng(_userPosition!.latitude, _userPosition!.longitude),
                      plot,
                    )
                  : null,
              arrived: _arrivalVibrated,
              sectionPlot: _deceased!.sectionId != null || _deceased!.plotNumber != null
                  ? '${AppStrings.tr(context, 'section')} ${_deceased!.sectionId ?? '?'}, ${AppStrings.tr(context, 'plot')} ${_deceased!.plotNumber ?? '?'}'
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionCard extends StatelessWidget {
  final double compassHeading;
  final double bearingToTarget;
  final double? distanceMeters;
  final bool arrived;
  final String? sectionPlot;

  const _DirectionCard({
    required this.compassHeading,
    required this.bearingToTarget,
    this.distanceMeters,
    required this.arrived,
    this.sectionPlot,
  });

  double get _arrowRotation =>
      (bearingToTarget - compassHeading) * (3.14159265359 / 180);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.border()),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sectionPlot != null) ...[
            Text(
              sectionPlot!,
              style: AppTheme.labelMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceMd),
          ],
          if (arrived)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(AppIcons.checkCircle, color: AppTheme.maroon, size: AppIcons.sizeXl),
                const SizedBox(width: AppTheme.spaceMd),
                Text(
                  AppStrings.tr(context, 'youHaveArrived'),
                  style: AppTheme.cardTitle.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            )
          else
            Transform.rotate(
              angle: _arrowRotation,
              child: const Icon(
                Icons.navigation_rounded,
                size: 56,
                color: AppTheme.maroon,
              ),
            ),
          if (distanceMeters != null && !arrived) ...[
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              '${distanceMeters!.toStringAsFixed(0)} ${AppStrings.tr(context, 'mAway')}',
              style: AppTheme.bodySecondary(0.7),
            ),
          ],
        ],
      ),
    );
  }
}
