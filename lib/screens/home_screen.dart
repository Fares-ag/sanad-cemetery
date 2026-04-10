import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_strings.dart';
import '../providers/emergency_provider.dart';
import '../providers/user_role_provider.dart';
import '../models/user_role.dart';
import '../services/emergency_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/language_picker_sheet.dart';
import '../widgets/home_dashboard_sections.dart';
import '../widgets/home_hero_carousel.dart';
import '../config/app_external_urls.dart';
import '../services/maintenance_service.dart';
import '../utils/maintenance_metrics.dart';
import '../utils/date_format.dart';

/// Home per Figma 165:21551 — exact layout, spacing, and typography.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.appScaffoldBackground,
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
              color: AppTheme.appScaffoldBackground,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFEDE9E9),
                    child: Icon(Icons.person_rounded, size: 22, color: Colors.black.withValues(alpha: 0.35)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: HomeWelcomeName(),
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
                    tooltip: AppStrings.tr(context, 'chooseLanguage'),
                    onPressed: () => showLanguagePickerSheet(context),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.black87),
                    tooltip: AppStrings.tr(context, 'menuMore'),
                    onSelected: (value) {
                      switch (value) {
                        case 'tutorials':
                          context.push('/tutorials');
                          break;
                        case 'announcements':
                          context.push('/announcements');
                          break;
                        case 'ministry':
                          context.push('/ministry-news');
                          break;
                        case 'governance':
                          context.push('/ministry-governance');
                          break;
                        case 'accessibility':
                          context.push('/accessibility-settings');
                          break;
                      }
                    },
                    itemBuilder: (ctx) {
                      return [
                        PopupMenuItem(
                          value: 'tutorials',
                          child: Text(AppStrings.tr(ctx, 'tutorialsTitle')),
                        ),
                        PopupMenuItem(
                          value: 'announcements',
                          child: Text(AppStrings.tr(ctx, 'burialAnnouncements')),
                        ),
                        PopupMenuItem(
                          value: 'ministry',
                          child: Text(AppStrings.tr(ctx, 'ministryNewsTitle')),
                        ),
                        PopupMenuItem(
                          value: 'governance',
                          child: Text(AppStrings.tr(ctx, 'governanceOpenGuide')),
                        ),
                        PopupMenuItem(
                          value: 'accessibility',
                          child: Text(AppStrings.tr(ctx, 'accessibility')),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HomeHeroCarousel(onReport: () => context.push('/maintenance')),
                  const SizedBox(height: 20),
                  const HomeShortcutsCard(),
                  const SizedBox(height: 12),
                  const HomeMinistrySnapshot(),
                  const SizedBox(height: 12),
                  const HomeNextAnnouncementTeaser(),
                  const SizedBox(height: 12),
                  const HomeOpenReportsBanner(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
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
                Semantics(
                  header: true,
                  child: Text(
                    AppStrings.tr(context, 'tapCardForDetails'),
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<MaintenanceService>(
                  builder: (context, svc, _) {
                    final now = DateTime.now();
                    final tickets = svc.tickets;
                    final open = countOpenMaintenanceTickets(tickets);
                    final resolved = countResolvedMaintenanceTickets(tickets);
                    final n7 = countCreatedLast7Days(tickets, now);
                    final r7 = countResolvedLast7Days(tickets, now);
                    return Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: AppStrings.tr(context, 'reportedIssues'),
                            value: formatNumber(context, open),
                            delta: AppStrings.tr(context, 'homeMetricNew7d', formatNumber(context, n7)),
                            onTap: () => context.push('/metrics-detail/reported'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricCard(
                            label: AppStrings.tr(context, 'resolvedIssues'),
                            value: formatNumber(context, resolved),
                            delta: AppStrings.tr(context, 'homeMetricResolved7d', formatNumber(context, r7)),
                            onTap: () => context.push('/metrics-detail/resolved'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 12),
                const _AwqafDashboardNoticeCard(),
                Consumer<UserRoleProvider>(
                  builder: (context, roleProv, _) {
                    if (roleProv.role != UserRole.municipalityCrew) {
                      return const SizedBox.shrink();
                    }
                    return const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 12),
                        _MunicipalityCrewHomeCard(),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                const HomeHoursContactCard(),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.delta,
    required this.onTap,
  });

  final String label;
  final String value;
  final String delta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFECE8E8)),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  height: 20 / 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withValues(alpha: 0.48),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 28 / 22,
                  color: Color(0xFF2A2A2A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                delta,
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.maroon.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
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
            color: Colors.white,
            border: Border.all(color: AppTheme.hubCardBorderColor, width: 1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: AppTheme.cardElevationShadow,
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
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(AppTheme.radiusMd),
                    topLeft: Radius.circular(AppTheme.radiusMd),
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
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.hubCardBorderColor, width: 1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
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
                              AppStrings.tr(context, 'callEmergencyHotline'),
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

/// Ministry of Awqaf work is handled in the dedicated Awqaf web dashboard, not in this app.
class _AwqafDashboardNoticeCard extends StatelessWidget {
  const _AwqafDashboardNoticeCard();

  Future<void> _openAwqaf(BuildContext context) async {
    final uri = Uri.parse(AppExternalUrls.awqafDashboard);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.tr(context, 'couldNotOpenLink'))),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.tr(context, 'couldNotOpenLink'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.maroon.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.maroon.withValues(alpha: 0.22), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.tr(context, 'awqafUseDashboardTitle'),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.maroon,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.tr(context, 'awqafUseDashboardBody'),
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.black.withValues(alpha: 0.58),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton(
              onPressed: () => _openAwqaf(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.maroon,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(AppStrings.tr(context, 'openAwqafDashboard')),
            ),
          ),
        ],
      ),
    );
  }
}

class _MunicipalityCrewHomeCard extends StatelessWidget {
  const _MunicipalityCrewHomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.hubCardBorderColor, width: 1),
        color: Colors.black.withOpacity(0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.tr(context, 'roleMunicipalityCrew'),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.tr(context, 'municipalityCrewHomeNote'),
            style: TextStyle(fontSize: 12, height: 16 / 12, color: Colors.black.withOpacity(0.55)),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => context.push('/requests'),
              child: Text(AppStrings.tr(context, 'navRequests')),
            ),
          ),
        ],
      ),
    );
  }
}
