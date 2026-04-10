import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

class LocationMapScreen extends StatelessWidget {
  const LocationMapScreen({super.key});

  /// Cemetery site (Sanad / browse map default).
  static const LatLng _center = LatLng(25.196370486760518, 51.48726955208789);

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(isRtl ? AppIcons.forward : AppIcons.back),
          onPressed: () => context.pop(),
        ),
        title: Text(AppStrings.tr(context, 'mapBrowseTitle'), style: AppTheme.appBarTitle),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(AppStrings.tr(context, 'mapBrowseHint'), style: AppTheme.bodyMedium),
          ),
          Expanded(
            child: FlutterMap(
              options: const MapOptions(initialCenter: _center, initialZoom: 16),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sanad.cemetery.sanad_cemetery',
                ),
                const MarkerLayer(
                  markers: [
                    Marker(
                      point: _center,
                      width: 48,
                      height: 48,
                      child: Icon(
                        AppIcons.place,
                        color: AppTheme.maroon,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
