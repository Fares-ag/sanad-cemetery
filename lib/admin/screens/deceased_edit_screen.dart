import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/deceased.dart';
import '../state/admin_data_provider.dart';

class DeceasedEditScreen extends StatefulWidget {
  final String? graveId;

  const DeceasedEditScreen({super.key, this.graveId});

  @override
  State<DeceasedEditScreen> createState() => _DeceasedEditScreenState();
}

class _DeceasedEditScreenState extends State<DeceasedEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstName;
  late TextEditingController _middleName;
  late TextEditingController _lastName;
  late TextEditingController _maidenName;
  late TextEditingController _birthDate;
  late TextEditingController _deathDate;
  late TextEditingController _branchOfService;
  late TextEditingController _lat;
  late TextEditingController _lon;
  late TextEditingController _plotNumber;
  late TextEditingController _bioHtml;
  late TextEditingController _imageUrls;
  bool _isVeteran = false;
  String? _sectionId;
  bool _loaded = false;

  bool get isNew => widget.graveId == null;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController();
    _middleName = TextEditingController();
    _lastName = TextEditingController();
    _maidenName = TextEditingController();
    _birthDate = TextEditingController();
    _deathDate = TextEditingController();
    _branchOfService = TextEditingController();
    _lat = TextEditingController();
    _lon = TextEditingController();
    _plotNumber = TextEditingController();
    _bioHtml = TextEditingController();
    _imageUrls = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final data = context.read<AdminDataProvider>();
      if (widget.graveId != null) {
        final d = data.getDeceasedById(widget.graveId!);
        if (d != null) {
          _firstName.text = d.firstName;
          _middleName.text = d.middleName;
          _lastName.text = d.lastName;
          _maidenName.text = d.maidenName ?? '';
          _birthDate.text = d.birthDate != null ? _formatDate(d.birthDate!) : '';
          _deathDate.text = d.deathDate != null ? _formatDate(d.deathDate!) : '';
          _isVeteran = d.isVeteran;
          _branchOfService.text = d.branchOfService ?? '';
          _lat.text = d.lat.toString();
          _lon.text = d.lon.toString();
          _sectionId = d.sectionId;
          _plotNumber.text = d.plotNumber ?? '';
          _bioHtml.text = d.bioHtml ?? '';
          _imageUrls.text = d.imageUrls.join('\n');
        }
      } else {
        _lat.text = '25.196';
        _lon.text = '51.487';
      }
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime? _parseDate(String s) {
    if (s.trim().isEmpty) return null;
    return DateTime.tryParse(s.trim());
  }

  @override
  void dispose() {
    _firstName.dispose();
    _middleName.dispose();
    _lastName.dispose();
    _maidenName.dispose();
    _birthDate.dispose();
    _deathDate.dispose();
    _branchOfService.dispose();
    _lat.dispose();
    _lon.dispose();
    _plotNumber.dispose();
    _bioHtml.dispose();
    _imageUrls.dispose();
    super.dispose();
  }

  List<String> _parseImageUrls() {
    return _imageUrls.text
        .split(RegExp(r'[\n\r]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final data = context.read<AdminDataProvider>();
    final id = isNew ? data.newDeceasedId() : widget.graveId!;
    final d = Deceased(
      id: id,
      firstName: _firstName.text.trim(),
      middleName: _middleName.text.trim(),
      lastName: _lastName.text.trim(),
      maidenName: _maidenName.text.trim().isEmpty ? null : _maidenName.text.trim(),
      birthDate: _parseDate(_birthDate.text),
      deathDate: _parseDate(_deathDate.text),
      isVeteran: _isVeteran,
      branchOfService: _branchOfService.text.trim().isEmpty ? null : _branchOfService.text.trim(),
      lat: double.tryParse(_lat.text.trim()) ?? 25.196,
      lon: double.tryParse(_lon.text.trim()) ?? 51.487,
      sectionId: _sectionId,
      plotNumber: _plotNumber.text.trim().isEmpty ? null : _plotNumber.text.trim(),
      bioHtml: _bioHtml.text.trim().isEmpty ? null : _bioHtml.text.trim(),
      imageUrls: _parseImageUrls(),
    );
    await data.addOrUpdateDeceased(d);
    if (mounted) context.go('/deceased');
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AdminDataProvider>();
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.go('/deceased'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isNew ? 'Add deceased' : 'Edit deceased',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!isNew) ...[
                  TextButton.icon(
                    icon: const Icon(Icons.link_rounded, size: 20),
                    label: const Text('Copy link'),
                    onPressed: () {
                      final id = widget.graveId!;
                      final link = 'myapp://grave/$id';
                      Clipboard.setData(ClipboardData(text: link));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied to clipboard')),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.qr_code_rounded, size: 20),
                    label: const Text('View QR'),
                    onPressed: () {
                      final id = widget.graveId!;
                      final link = 'myapp://grave/$id';
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('QR code'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              QrImageView(
                                data: link,
                                version: QrVersions.auto,
                                size: 200,
                              ),
                              const SizedBox(height: 12),
                              SelectableText(link, style: theme.textTheme.bodySmall),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _firstName,
                            decoration: const InputDecoration(labelText: 'First name'),
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _middleName,
                            decoration: const InputDecoration(labelText: 'Middle'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _lastName,
                            decoration: const InputDecoration(labelText: 'Last name'),
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _maidenName,
                      decoration: const InputDecoration(
                        labelText: 'Maiden name (optional)',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dates',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _birthDate,
                            decoration: const InputDecoration(
                              labelText: 'Birth date (YYYY-MM-DD)',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _deathDate,
                            decoration: const InputDecoration(
                              labelText: 'Death date (YYYY-MM-DD)',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: _isVeteran,
                      onChanged: (v) => setState(() => _isVeteran = v ?? false),
                      title: const Text('Veteran'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_isVeteran)
                      TextFormField(
                        controller: _branchOfService,
                        decoration: const InputDecoration(
                          labelText: 'Branch of service',
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location & section',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _lat,
                            decoration: const InputDecoration(labelText: 'Latitude'),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Required';
                              if (double.tryParse(v.trim()) == null) return 'Invalid number';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _lon,
                            decoration: const InputDecoration(labelText: 'Longitude'),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Required';
                              if (double.tryParse(v.trim()) == null) return 'Invalid number';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _sectionId,
                      decoration: const InputDecoration(labelText: 'Section / site'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('— None —'),
                        ),
                        ...data.sections
                            .map((s) => DropdownMenuItem<String>(
                                  value: s.id,
                                  child: Text(s.name),
                                )),
                      ],
                      onChanged: (v) => setState(() => _sectionId = v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _plotNumber,
                      decoration: const InputDecoration(
                        labelText: 'Plot number (optional)',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Image URLs (optional)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'One URL per line. Shown on the deceased profile in the app.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _imageUrls,
                      decoration: const InputDecoration(
                        hintText: 'https://example.com/photo1.jpg\nhttps://...',
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Life story (optional)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _bioHtml,
                      decoration: const InputDecoration(
                        hintText: 'HTML or plain text',
                      ),
                      maxLines: 6,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => context.go('/deceased'),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(isNew ? 'Add record' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
