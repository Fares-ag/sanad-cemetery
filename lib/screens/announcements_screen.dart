import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';

/// Announcements screen per Figma (166:22209).
/// Recent Announcements list + Add New Announcement form.
class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final List<Map<String, dynamic>> _recent = [
    {'name': 'Ahmed Khan', 'date': DateTime(2026, 9, 25), 'serviceKey': 'funeralOn', 'serviceDateTime': DateTime(2026, 9, 28, 14, 0)},
    {'name': 'Mirza Khan', 'date': DateTime(2026, 9, 20), 'serviceKey': 'memorialServiceOn', 'serviceDateTime': DateTime(2026, 9, 22, 16, 0)},
  ];
  final _newNameController = TextEditingController();

  @override
  void dispose() {
    _newNameController.dispose();
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
          icon: Icon(isRtl ? AppIcons.forward : AppIcons.back),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          AppStrings.tr(context, 'announcements'),
          style: AppTheme.appBarTitle,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.tr(context, 'recentAnnouncements'),
              style: AppTheme.sectionTitle,
            ),
            const SizedBox(height: 16),
            ..._recent.map((a) => _AnnouncementTile(
              name: a['name'] as String,
              date: AppStrings.tr(context, 'passedAwayOn', formatDeathDate(context, a['date'] as DateTime)),
              service: AppStrings.tr(context, a['serviceKey'] as String, formatServiceDateTime(context, a['serviceDateTime'] as DateTime)),
              icon: (a['name'] as String).startsWith('Ahmed') ? AppIcons.celebration : AppIcons.flower,
            )),
            const SizedBox(height: 24),
            Text(
              AppStrings.tr(context, 'addNewAnnouncement'),
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _newNameController,
              style: AppTheme.bodyMedium,
              decoration: AppTheme.inputDecoration(
                hintText: AppStrings.tr(context, 'enterNameDeceased'),
                helperText: AppStrings.tr(context, 'includeDateService'),
              ).copyWith(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  borderSide: BorderSide(color: AppTheme.border()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _newNameController.clear(),
                    style: AppTheme.outlinedButtonStyle(),
                    child: Text(
                      AppStrings.tr(context, 'cancel'),
                      style: AppTheme.button.copyWith(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (_newNameController.text.trim().isEmpty) return;
                      context.push('/success?msg=thankYouSubmission').then((_) => setState(() {}));
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.maroon,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        AppStrings.tr(context, 'submitAnnouncement'),
                        style: AppTheme.button,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  const _AnnouncementTile({
    required this.name,
    required this.date,
    required this.service,
    required this.icon,
  });

  final String name;
  final String date;
  final String service;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: AppIcons.sizeMd, color: Colors.black87),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        height: 16 / 12,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Text(
                  service,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 20 / 14,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.black.withOpacity(0.12)),
      ],
    );
  }
}
