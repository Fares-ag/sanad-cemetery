import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Report An Issue form per Figma 166:21885.
/// Map, Cemetery Name, Location, Description, Upload images, Cancel/Submit Request.
class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _cemeteryController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _locationLoading = false;
  String? _locationError;
  Position? _currentPosition;
  final MapController _mapController = MapController();
  String? _scannedGraveId;

  /// Default center (Doha) when no position yet.
  static const LatLng _defaultCenter = LatLng(25.2854, 51.5310);

  @override
  void dispose() {
    _cemeteryController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  static const _maroon = Color(0xFF8E1737);

  Future<void> _getCurrentLocation() async {
    if (_locationLoading) return;
    setState(() {
      _locationLoading = true;
      _locationError = null;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() {
          _locationLoading = false;
          _locationError = AppStrings.tr(context, 'locationUnavailable');
        });
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) setState(() {
          _locationLoading = false;
          _locationError = AppStrings.tr(context, 'locationUnavailable');
        });
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _locationLoading = false;
          _locationError = null;
        });
        _locationController.text = '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _currentPosition != null) {
            _mapController.move(
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              16,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() {
        _locationLoading = false;
        _locationError = AppStrings.tr(context, 'locationUnavailable');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Figma 166:21885 is light theme only — force light surface so design matches in any system theme.
    return Theme(
      data: ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: _maroon, brightness: Brightness.light),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_forward_rounded
                  : Icons.arrow_back_rounded,
              color: Colors.black,
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/requests');
              }
            },
          ),
          title: Text(
            AppStrings.tr(context, 'reportAnIssue'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 24 / 20,
              color: Colors.black,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(AppIcons.phone, size: AppIcons.sizeLg, color: Colors.black87),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(AppIcons.location, size: AppIcons.sizeLg, color: Colors.black87),
              onPressed: _getCurrentLocation,
              tooltip: AppStrings.tr(context, 'location'),
            ),
          ],
        ),
        body: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            _LocationMap(
              mapController: _mapController,
              isLoading: _locationLoading,
              errorMessage: _locationError,
              currentPosition: _currentPosition,
              onGetLocation: _getCurrentLocation,
              maroon: _maroon,
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.tr(context, 'scanGraveQR'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final id = await context.push<String>('/scan?forReport=1');
                if (id != null && mounted) {
                  setState(() {
                    _scannedGraveId = id;
                    if (_cemeteryController.text.isEmpty) {
                      _cemeteryController.text = AppStrings.tr(context, 'graveWithId', id);
                    }
                  });
                }
              },
              icon: const Icon(AppIcons.qrCodeScanner, size: 22),
              label: Text(AppStrings.tr(context, 'scanGraveQR')),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF8E1737)),
                foregroundColor: const Color(0xFF8E1737),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            if (_scannedGraveId != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(AppIcons.checkCircle, size: AppIcons.sizeMd, color: _maroon),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${AppStrings.tr(context, 'reportLinkedToGrave')}: $_scannedGraveId',
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final id = _scannedGraveId;
                      setState(() {
                        _scannedGraveId = null;
                        if (id != null && _cemeteryController.text == AppStrings.tr(context, 'graveWithId', id)) {
                          _cemeteryController.clear();
                        }
                      });
                    },
                    child: Text(
                      AppStrings.tr(context, 'clear'),
                      style: TextStyle(fontSize: 13, color: _maroon),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            _LabeledInput(
              label: AppStrings.tr(context, 'cemeteryName'),
              hint: AppStrings.tr(context, 'enterCemeteryName'),
              helper: AppStrings.tr(context, 'pleaseProvideCemetery'),
              controller: _cemeteryController,
            ),
            const SizedBox(height: 10),
            _LabeledInput(
              label: AppStrings.tr(context, 'location'),
              hint: AppStrings.tr(context, 'enterLocationAddress'),
              helper: AppStrings.tr(context, 'provideExactLocation'),
              controller: _locationController,
            ),
            const SizedBox(height: 10),
            _LabeledInput(
              label: AppStrings.tr(context, 'descriptionOfIssue'),
              hint: AppStrings.tr(context, 'describeIssue'),
              helper: AppStrings.tr(context, 'beSpecificFixing'),
              controller: _descriptionController,
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            _UploadImagesPlaceholder(),
            const SizedBox(height: 25),
            OutlinedButton(
              onPressed: () => context.go('/'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                AppStrings.tr(context, 'cancel'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                context.push('/success?msg=thankYouRequest');
              },
              style: FilledButton.styleFrom(
                backgroundColor: _maroon,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                AppStrings.tr(context, 'submitMaintenanceReport'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationMap extends StatelessWidget {
  const _LocationMap({
    required this.mapController,
    this.isLoading,
    this.errorMessage,
    this.currentPosition,
    required this.onGetLocation,
    required this.maroon,
  });

  final MapController mapController;
  final bool? isLoading;
  final String? errorMessage;
  final Position? currentPosition;
  final VoidCallback onGetLocation;
  final Color maroon;

  @override
  Widget build(BuildContext context) {
    final loading = isLoading ?? false;
    final center = currentPosition != null
        ? LatLng(currentPosition!.latitude, currentPosition!.longitude)
        : _ReportIssueScreenState._defaultCenter;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 336,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: currentPosition != null ? 16 : 12,
                minZoom: 5,
                maxZoom: 19,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.pinchMove,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sanad.cemetery.sanad_cemetery',
                ),
                if (currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(currentPosition!.latitude, currentPosition!.longitude),
                        width: 40,
                        height: 40,
                        child: Icon(
                          AppIcons.location,
                          color: maroon,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (loading || errorMessage != null)
              Positioned.fill(
                child: Material(
                  color: Colors.white.withOpacity(0.85),
                  child: InkWell(
                    onTap: loading ? null : onGetLocation,
                    child: Center(
                      child: loading
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  AppStrings.tr(context, 'gettingLocation'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                    ),
                  ),
                ),
              )
            else if (currentPosition == null)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onGetLocation,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(AppIcons.location, size: 48, color: maroon),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              AppStrings.tr(context, 'realtimeTrackingLocation'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.tr(context, 'tapToGetLocation'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: onGetLocation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        AppStrings.tr(context, 'tapToRefreshLocation'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.label,
    required this.hint,
    required this.helper,
    required this.controller,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final String helper;
  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 20 / 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          helper,
          style: TextStyle(
            fontSize: 12,
            height: 16 / 12,
            color: Colors.black.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

class _UploadImagesPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            AppStrings.tr(context, 'uploadImagesIssue'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                const SizedBox(width: 4),
                ...List.generate(3, (_) => Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
