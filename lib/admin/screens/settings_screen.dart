import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/deceased.dart';
import '../models/cemetery_info.dart';
import '../models/section.dart';
import '../state/admin_data_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _name;
  late TextEditingController _address;
  late TextEditingController _phone;
  late TextEditingController _email;
  late TextEditingController _hours;
  late TextEditingController _description;
  late TextEditingController _pathsGeojson;
  bool _infoLoaded = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _address = TextEditingController();
    _phone = TextEditingController();
    _email = TextEditingController();
    _hours = TextEditingController();
    _description = TextEditingController();
    _pathsGeojson = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_infoLoaded) {
      _infoLoaded = true;
      final info = context.read<AdminDataProvider>().cemeteryInfo;
      final paths = context.read<AdminDataProvider>().pathsGeojson;
      _name.text = info.name;
      _address.text = info.address ?? '';
      _phone.text = info.contactPhone ?? '';
      _email.text = info.contactEmail ?? '';
      _hours.text = info.openingHours ?? '';
      _description.text = info.description ?? '';
      _pathsGeojson.text = paths;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    _email.dispose();
    _hours.dispose();
    _description.dispose();
    _pathsGeojson.dispose();
    super.dispose();
  }

  void _saveCemeteryInfo() {
    context.read<AdminDataProvider>().setCemeteryInfo(CemeteryInfo(
      name: _name.text.trim().isEmpty ? 'Sanad Cemetery' : _name.text.trim(),
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      contactPhone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      contactEmail: _email.text.trim().isEmpty ? null : _email.text.trim(),
      openingHours: _hours.text.trim().isEmpty ? null : _hours.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
    ));
  }

  void _savePaths() {
    context.read<AdminDataProvider>().setPathsGeojson(_pathsGeojson.text.trim());
  }

  void _exportData(BuildContext context) {
    final data = context.read<AdminDataProvider>();
    final payload = {
      'deceased': data.deceased.map((e) => e.toJson()).toList(),
      'sections': data.sections.map((e) => e.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
    final str = const JsonEncoder.withIndent('  ').convert(payload);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export data'),
        content: SizedBox(
          width: 500,
          height: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Copy the JSON below or use the Copy button.'),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(str, style: const TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          FilledButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: str));
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  void _importData(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import data'),
        content: SizedBox(
          width: 500,
          height: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Paste JSON with "deceased" and/or "sections" arrays. Existing IDs will be updated.'),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: '{"deceased": [...], "sections": [...]}',
                    alignLabelWithHint: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              try {
                final json = jsonDecode(controller.text) as Map<String, dynamic>;
                final provider = ctx.read<AdminDataProvider>();
                final deceasedList = json['deceased'] as List<dynamic>?;
                final sectionsList = json['sections'] as List<dynamic>?;
                if (deceasedList != null) {
                  provider.importDeceased(
                    deceasedList.map((e) => Deceased.fromJson(e as Map<String, dynamic>)).toList(),
                  );
                }
                if (sectionsList != null) {
                  provider.importSections(
                    sectionsList.map((e) => Section.fromJson(e as Map<String, dynamic>)).toList(),
                  );
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Imported ${deceasedList?.length ?? 0} deceased, ${sectionsList?.length ?? 0} sections')),
                );
              } catch (e) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Invalid JSON: $e')));
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Settings',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cemetery info, paths, and data export/import.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cemetery info',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _address,
                    decoration: const InputDecoration(labelText: 'Address'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phone,
                          decoration: const InputDecoration(labelText: 'Phone'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _hours,
                    decoration: const InputDecoration(labelText: 'Opening hours'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _saveCemeteryInfo,
                    child: const Text('Save cemetery info'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paths (GeoJSON)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Paste or edit the path network GeoJSON. Used for walking directions in the app when connected to a backend.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pathsGeojson,
                    decoration: const InputDecoration(
                      hintText: '{"type":"FeatureCollection", ...}',
                    ),
                    maxLines: 12,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _savePaths,
                    child: const Text('Save paths'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export / Import',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: () => _exportData(context),
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Export JSON'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => _importData(context),
                        icon: const Icon(Icons.upload_rounded),
                        label: const Text('Import'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
