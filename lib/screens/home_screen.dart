import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_strings.dart';
import '../providers/locale_provider.dart';
import '../providers/emergency_provider.dart';
import '../services/emergency_storage.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';

/// Home per Figma 165:21551 — exact layout, spacing, and typography.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: EdgeInsetsDirectional.only(
                top: MediaQuery.paddingOf(context).top + 16,
                start: 12,
                end: 12,
                bottom: 16,
              ),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.black.withOpacity(0.1),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppStrings.tr(context, 'welcomeUser', 'Sultan'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            height: 24 / 16,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          AppStrings.tr(context, 'welcomeManage'),
                          style: TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(AppIcons.search, size: AppIcons.sizeLg),
                    onPressed: () => context.go('/search'),
                    tooltip: AppStrings.tr(context, 'search'),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.translate_rounded,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                    tooltip: context.watch<LocaleProvider>().isArabic ? 'English' : 'العربية',
                    onPressed: () => context.read<LocaleProvider>().toggleLocale(),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                _ReportHeroCard(onReport: () => context.go('/maintenance')),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.tr(context, 'cemeteryIssuesReported'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          height: 24 / 18,
                        ),
                      ),
                      Text(
                        AppStrings.tr(context, 'overview'),
                        style: TextStyle(
                          fontSize: 12,
                          height: 16 / 12,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        label: AppStrings.tr(context, 'reportedIssues'),
                        value: '25',
                        delta: '+5',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetricCard(
                        label: AppStrings.tr(context, 'resolvedIssues'),
                        value: '15',
                        delta: '-2',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    AppStrings.tr(context, 'recentReports'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 24 / 18,
                    ),
                  ),
                ),
                _RecentReportTile(
                  title: AppStrings.tr(context, 'oldCemetery'),
                  subtitle: AppStrings.tr(context, 'brokenFence'),
                  time: AppStrings.tr(context, 'reported1HourAgo'),
                  icon: AppIcons.location,
                ),
                Divider(height: 1, color: Colors.black.withOpacity(0.12)),
                _RecentReportTile(
                  title: AppStrings.tr(context, 'dharmaCemetery'),
                  subtitle: AppStrings.tr(context, 'overgrownBushes'),
                  time: AppStrings.tr(context, 'reported3HoursAgo'),
                  icon: AppIcons.park,
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.tr(context, 'announcements'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          height: 24 / 18,
                        ),
                      ),
                      Text(
                        AppStrings.tr(context, 'sharingCondolences'),
                        style: TextStyle(
                          fontSize: 12,
                          height: 16 / 12,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _AnnouncementPreviewTile(
                  name: 'Ahmed Khan',
                  date: AppStrings.tr(context, 'passedAwayOn', formatDeathDate(context, DateTime(2026, 9, 20))),
                  service: AppStrings.tr(context, 'memorialServiceOn', formatServiceDateTime(context, DateTime(2026, 9, 22, 16, 0))),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    AppStrings.tr(context, 'qrCodeMapping'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 24 / 18,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _QrAndEmergencyCard(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportHeroCard extends StatelessWidget {
  const _ReportHeroCard({required this.onReport});

  final VoidCallback onReport;

  static const _heroImageAsset = 'images/home-img.png';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 120,
            width: double.infinity,
            child: Image.asset(
              _heroImageAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _ReportHeroCard._maroon.withOpacity(0.25),
                      _ReportHeroCard._maroon.withOpacity(0.08),
                    ],
                  ),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    AppStrings.tr(context, 'reportVisibleIssues'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 22 / 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: onReport,
            style: TextButton.styleFrom(
              backgroundColor: _maroon,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              AppStrings.tr(context, 'reportAnIssue'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 22 / 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static const _maroon = AppTheme.maroon;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.delta,
  });

  final String label;
  final String value;
  final String delta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 28 / 20,
              color: Colors.black,
            ),
          ),
          Text(
            delta,
            style: const TextStyle(
              fontSize: 14,
              height: 20 / 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentReportTile extends StatelessWidget {
  const _RecentReportTile({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String time;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
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
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    color: Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 20 / 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementPreviewTile extends StatelessWidget {
  const _AnnouncementPreviewTile({
    required this.name,
    required this.date,
    required this.service,
  });

  final String name;
  final String date;
  final String service;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/announcements'),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
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
              child: Icon(AppIcons.flower, size: AppIcons.sizeMd, color: Colors.black87),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Qatar emergency number (use 911 in other regions if needed).
const _kEmergencyNumber = '999';

String _buildLocalizedQrPayload(BuildContext context, EmergencyInfo info) {
  final buf = StringBuffer();
  buf.writeln(AppStrings.tr(context, 'sanadEmergency'));
  buf.writeln(AppStrings.tr(context, 'doNotUseNonEmergency'));
  if (info.userName != null && info.userName!.isNotEmpty) {
    buf.writeln('${AppStrings.tr(context, 'name')}: ${info.userName}');
  }
  buf.writeln('${AppStrings.tr(context, 'shareLocationWithResponders')}: ${info.shareLocation ? AppStrings.tr(context, 'yes') : AppStrings.tr(context, 'no')}');
  if (info.contacts.isNotEmpty) {
    buf.writeln('${AppStrings.tr(context, 'contacts')}:');
    for (final c in info.contacts) {
      buf.writeln('  ${c.displayLine}');
    }
  }
  return buf.toString().trim();
}

class _QrAndEmergencyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<EmergencyProvider>(
      builder: (context, emergencyProvider, _) {
        final info = emergencyProvider.info;
        final qrPayload = info.hasData
            ? _buildLocalizedQrPayload(context, info)
            : AppStrings.tr(context, 'setEmergencyInfoInSettings');

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(6),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(6),
                    topLeft: Radius.circular(6),
                  ),
                ),
                child: Text(
                  AppStrings.tr(context, 'useQrEmergencyInfo'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 16 / 12,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
              ),
              SizedBox(
                height: 200,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: QrImageView(
                      data: qrPayload,
                      version: QrVersions.auto,
                      size: 168,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black87,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.tr(context, 'emergencyActions'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        height: 24 / 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _launchEmergencyCall(context),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Icon(AppIcons.emergency, size: AppIcons.sizeMd, color: Colors.black87),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.tr(context, 'alertPolice'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 16 / 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchEmergencyCall(BuildContext context) async {
    final uri = Uri.parse('tel:$_kEmergencyNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.tr(context, 'cannotPlaceCall', _kEmergencyNumber))),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.tr(context, 'couldNotOpenDialer', _kEmergencyNumber))),
        );
      }
    }
  }
}
