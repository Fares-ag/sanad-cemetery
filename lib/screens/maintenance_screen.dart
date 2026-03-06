import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../providers/locale_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io';
import '../models/maintenance_ticket.dart';
import '../services/maintenance_service.dart';
import '../services/search_service.dart';
import '../services/qr_service.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  @override
  Widget build(BuildContext context) {
    final service = context.watch<MaintenanceService>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          AppStrings.tr(context, 'reportAnIssue'),
          style: AppTheme.appBarTitle,
        ),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.phone, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(AppIcons.location, size: AppIcons.sizeLg, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: service.tickets.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppTheme.cardMuted(),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        AppIcons.construction,
                        size: 56,
                        color: AppTheme.textSecondary(0.6),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      AppStrings.tr(context, 'noReports'),
                      style: AppTheme.sectionTitle.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppStrings.tr(context, 'noReportsSub'),
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary(0.7),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              itemCount: service.tickets.length,
              itemBuilder: (_, i) {
                final t = service.tickets[i];
                final isDone = TicketStatus.values.indexOf(t.status) == 2;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: AppTheme.cardDecoration(),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.maroon.withOpacity(0.12),
                      child: t.photoPath.isNotEmpty && File(t.photoPath).existsSync()
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.file(File(t.photoPath), width: 48, height: 48, fit: BoxFit.cover),
                            )
                          : const Icon(AppIcons.construction, color: AppTheme.maroon, size: AppIcons.sizeLg),
                    ),
                    title: Text(
                      AppStrings.categoryDisplay(context, t.category),
                      style: AppTheme.cardTitle.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${AppStrings.status(context, t.status)} · ${t.createdAt.toString().substring(0, 16)}',
                      style: AppTheme.labelMedium,
                    ),
                    trailing: Icon(
                      isDone ? AppIcons.checkCircle : AppIcons.hourglass,
                      color: isDone ? AppTheme.maroon : AppTheme.textSecondary(0.5),
                      size: AppIcons.sizeLg,
                    ),
                    onTap: () => _showTicketDetail(context, t),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSubmitForm(context),
        backgroundColor: AppTheme.maroon,
        foregroundColor: Colors.white,
        icon: const Icon(AppIcons.add, size: 22),
        label: Text(AppStrings.tr(context, 'reportIssue'), style: AppTheme.button),
        elevation: 2,
      ),
    );
  }

  Future<String?> _showTombstoneQrScanner(BuildContext context) async {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (ctx) => _TombstoneQrScanner(
          onScanned: (graveId) => Navigator.pop(ctx, graveId),
        ),
      ),
    );
  }

  void _showTicketDetail(BuildContext context, MaintenanceTicket t) {
    final deceased = t.graveId != null
        ? context.read<SearchService>().getById(t.graveId!)
        : null;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.categoryDisplay(ctx, t.category)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${AppStrings.status(ctx, t.status)}'),
              Text('Created: ${t.createdAt}'),
              if (t.updatedAt != null) Text('Updated: ${t.updatedAt}'),
              if (deceased != null) Text('Tombstone: ${deceased.fullName} (Section ${deceased.sectionId ?? '?'}, Plot ${deceased.plotNumber ?? '?'})'),
              if (t.description != null) Text('Notes: ${t.description}'),
              Text('Location: ${t.lat.toStringAsFixed(5)}, ${t.lon.toStringAsFixed(5)}'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.tr(ctx, 'close')))],
      ),
    );
  }

  void _showSubmitForm(BuildContext context) async {
    String? category = 'sunkenGrave';
    String? description;
    String? photoPath;
    double? lat;
    double? lon;
    String? graveId;

    final formKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) {
          final isRtl = ctx.read<LocaleProvider>().isArabic;
          final textDir = isRtl ? TextDirection.rtl : TextDirection.ltr;
          return AlertDialog(
            title: Text(AppStrings.tr(ctx, 'reportIssue')),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            content: Directionality(
              textDirection: textDir,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: InputDecoration(labelText: AppStrings.tr(ctx, 'category')),
                        items: ['sunkenGrave', 'damagedStone', 'overgrownGrass', 'other']
                            .map((k) => DropdownMenuItem(value: k, child: Text(AppStrings.tr(ctx, k))))
                            .toList(),
                        onChanged: (v) => setDialog(() => category = v),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(labelText: AppStrings.tr(ctx, 'description')),
                        maxLines: 2,
                        onChanged: (v) => description = v.isEmpty ? null : v,
                      ),
                      const SizedBox(height: 20),
                      Text(AppStrings.tr(ctx, 'photo'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (photoPath != null)
                        Image.file(File(photoPath!), height: 120, fit: BoxFit.cover)
                      else
                        OutlinedButton(
                          onPressed: () async {
                            final picker = ImagePicker();
                            final x = await picker.pickImage(source: ImageSource.camera);
                            if (x != null) setDialog(() => photoPath = x.path);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(AppIcons.camera, size: AppIcons.sizeMd),
                              const SizedBox(width: 10),
                              Text(AppStrings.tr(ctx, 'takePhoto')),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text(AppStrings.tr(ctx, 'location'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(AppIcons.qrCodeScanner, size: AppIcons.sizeMd),
                              label: Text(AppStrings.tr(ctx, 'scanTombstoneQR')),
                              onPressed: () async {
                                final scannedId = await _showTombstoneQrScanner(ctx);
                                if (scannedId == null || !ctx.mounted) return;
                                final d = ctx.read<SearchService>().getById(scannedId);
                                if (d != null) {
                                  setDialog(() {
                                    graveId = scannedId;
                                    lat = d.lat;
                                    lon = d.lon;
                                    if (description == null || description!.isEmpty) {
                                      description = 'Maintenance for ${d.fullName}'
                                          '${d.sectionId != null || d.plotNumber != null ? ' – Section ${d.sectionId ?? '?'}, Plot ${d.plotNumber ?? '?'}' : ''}';
                                    }
                                  });
                                } else {
                                  if (ctx.mounted) {
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      SnackBar(content: Text(AppStrings.tr(ctx, 'tombstoneNotFound'))),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(AppIcons.myLocation, size: AppIcons.sizeMd),
                              label: Text(AppStrings.tr(ctx, 'useGPS')),
                              onPressed: () async {
                                final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                                setDialog(() { lat = pos.latitude; lon = pos.longitude; });
                              },
                            ),
                          ),
                        ],
                      ),
                      if (lat != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${AppStrings.tr(ctx, 'location')}: ${lat!.toStringAsFixed(5)}, ${lon!.toStringAsFixed(5)}',
                            style: Theme.of(ctx).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.tr(ctx, 'cancel'))),
              FilledButton(
                onPressed: () async {
                  if (photoPath == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.tr(context, 'pleaseTakePhoto'))));
                    return;
                  }
                  double submitLat;
                  double submitLon;
                  if (lat != null && lon != null) {
                    submitLat = lat!;
                    submitLon = lon!;
                  } else {
                    final currentPos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                    submitLat = currentPos.latitude;
                    submitLon = currentPos.longitude;
                  }
                  final ticket = await context.read<MaintenanceService>().submit(
                    category: category!,
                    description: description,
                    photoPath: photoPath!,
                    lat: submitLat,
                    lon: submitLon,
                    graveId: graveId,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppStrings.tr(context, 'reportSubmitted')} ID: ${ticket.id}')));
                },
                child: Text(AppStrings.tr(ctx, 'submit')),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Full-screen QR scanner for selecting a tombstone for maintenance.
class _TombstoneQrScanner extends StatefulWidget {
  final void Function(String graveId) onScanned;

  const _TombstoneQrScanner({required this.onScanned});

  @override
  State<_TombstoneQrScanner> createState() => _TombstoneQrScannerState();
}

class _TombstoneQrScannerState extends State<_TombstoneQrScanner> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _scanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final codes = capture.barcodes;
    if (codes.isEmpty) return;
    final raw = codes.first.rawValue;
    final graveId = QrService.parseGraveIdFromScanned(raw);
    if (graveId != null && graveId.isNotEmpty) {
      _scanned = true;
      widget.onScanned(graveId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.tr(context, 'scanTombstoneQRTitle'))),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                AppStrings.tr(context, 'pointCameraAtTombstone'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
