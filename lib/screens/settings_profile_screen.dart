import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../providers/emergency_provider.dart';
import '../services/emergency_storage.dart';
import '../theme/app_theme.dart';

/// My Settings — aligned with app design system: profile, emergency contacts, share location, Cancel/Save.
/// Saves to EmergencyProvider so the home QR code reflects this data.
class SettingsProfileScreen extends StatefulWidget {
  const SettingsProfileScreen({super.key});

  @override
  State<SettingsProfileScreen> createState() => _SettingsProfileScreenState();
}

class _SettingsProfileScreenState extends State<SettingsProfileScreen> {
  final _userNameController = TextEditingController();
  final _emergencyController = TextEditingController();
  final _newContactController = TextEditingController();
  bool _shareLocation = true;
  List<Map<String, String>> _contacts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFromProvider());
  }

  void _loadFromProvider() {
    final info = context.read<EmergencyProvider>().info;
    _userNameController.text = info.userName ?? '';
    _shareLocation = info.shareLocation;
    setState(() {
      _contacts = info.contacts
          .map((c) => {'name': c.name, 'relation': c.relation, 'phone': c.phone})
          .toList();
    });
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emergencyController.dispose();
    _newContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(AppStrings.tr(context, 'mySettings'), style: AppTheme.appBarTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.cardMuted(),
                  child: Text(
                    _userNameController.text.isNotEmpty
                        ? _userNameController.text[0].toUpperCase()
                        : '?',
                    style: AppTheme.cardTitle.copyWith(color: AppTheme.textSecondary(0.7)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _userNameController,
                        style: AppTheme.cardTitle.copyWith(fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: AppStrings.tr(context, 'yourName'),
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.tr(context, 'editYourProfile'),
                        style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary(0.7)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              AppStrings.tr(context, 'emergencyContacts'),
              style: AppTheme.sectionTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _emergencyController,
              style: AppTheme.bodyMedium,
              decoration: AppTheme.inputDecoration(
                hintText: AppStrings.tr(context, 'enterEmergencyContact'),
                helperText: AppStrings.tr(context, 'tapToAddContacts'),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.tr(context, 'currentEmergencyContacts'),
              style: AppTheme.sectionTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            ..._contacts.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.cardMuted(),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Icon(AppIcons.phone, size: AppIcons.sizeSm, color: AppTheme.textSecondary(0.6)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c['name']!, style: AppTheme.cardTitle),
                        Text(c['relation']!, style: AppTheme.labelMedium),
                      ],
                    ),
                  ),
                  Text(c['phone']!, style: AppTheme.cardTitle.copyWith(fontSize: 15)),
                ],
              ),
            )),
            const SizedBox(height: 20),
            Text(
              AppStrings.tr(context, 'shareLocationResponders'),
              style: AppTheme.sectionTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _shareLocation = true),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _shareLocation ? AppTheme.maroon : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(
                            color: _shareLocation ? AppTheme.maroon : AppTheme.border(0.2),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          AppStrings.tr(context, 'yes'),
                          style: AppTheme.button.copyWith(
                            color: _shareLocation ? Colors.white : AppTheme.textSecondary(0.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _shareLocation = false),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_shareLocation ? AppTheme.maroon : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(
                            color: !_shareLocation ? AppTheme.maroon : AppTheme.border(0.2),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          AppStrings.tr(context, 'no'),
                          style: AppTheme.button.copyWith(
                            color: !_shareLocation ? Colors.white : AppTheme.textSecondary(0.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.tr(context, 'chooseShareLocation'),
              style: AppTheme.labelMedium,
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.tr(context, 'addNewContact'),
              style: AppTheme.sectionTitle.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _newContactController,
              style: AppTheme.bodyMedium,
              decoration: AppTheme.inputDecoration(
                hintText: AppStrings.tr(context, 'contactNamePhone'),
                helperText: AppStrings.tr(context, 'formatNamePhone'),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: AppTheme.outlinedMaroonButtonStyle(),
                    child: Text(AppStrings.tr(context, 'cancel'), style: AppTheme.button),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _saveAndExit(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.maroon,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                    ),
                    child: Text(AppStrings.tr(context, 'saveChanges'), style: AppTheme.button),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveAndExit(BuildContext context) {
    final contacts = _contacts
        .map((c) => EmergencyContact(
              name: c['name'] ?? '',
              relation: c['relation'] ?? '',
              phone: c['phone'] ?? '',
            ))
        .toList();
    final info = EmergencyInfo(
      userName: _userNameController.text.trim().isEmpty ? null : _userNameController.text.trim(),
      contacts: contacts,
      shareLocation: _shareLocation,
    );
    context.read<EmergencyProvider>().save(info);
    context.push('/success?msg=changesSaved');
  }
}
