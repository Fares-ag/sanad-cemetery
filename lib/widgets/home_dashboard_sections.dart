import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_strings.dart';
import '../models/app_content.dart';
import '../providers/app_content_provider.dart';
import '../providers/emergency_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';
import '../utils/home_content_helpers.dart';
import '../utils/maintenance_metrics.dart';
import '../services/maintenance_service.dart';

// Light palette for home shortcuts (avoid dark Material chip defaults).
const _kShortcutCardBg = Color(0xFFFFFFFF);
const _kShortcutCardBorder = Color(0xFFECE8E8);
const _kPillBg = Color(0xFFFCFAFA);
const _kPillBorder = Color(0xFFE5E0E0);
const _kPillIcon = Color(0xFFB0455C);
const _kPillLabel = Color(0xFF3D3D3D);

/// Welcome line: profile name from emergency settings, or default demo name.
class HomeWelcomeName extends StatelessWidget {
  const HomeWelcomeName({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmergencyProvider>(
      builder: (context, em, _) {
        final raw = em.info.userName?.trim();
        final name = raw != null && raw.isNotEmpty ? raw : AppStrings.tr(context, 'welcomeDefaultName');
        return Text(
          AppStrings.tr(context, 'welcomeUser', name),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 24 / 16,
                color: Colors.black,
              ),
        );
      },
    );
  }
}

/// Light card: quick-action pills + accessibility link (replaces dark default [ActionChip]s).
class HomeShortcutsCard extends StatelessWidget {
  const HomeShortcutsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_QuickItem>[
      _QuickItem(AppStrings.tr(context, 'search'), AppIcons.search, () => context.go('/search')),
      _QuickItem(AppStrings.tr(context, 'scan'), AppIcons.qrCodeScanner, () => context.push('/scan')),
      _QuickItem(AppStrings.tr(context, 'reportAnIssue'), AppIcons.report, () => context.push('/maintenance')),
      _QuickItem(AppStrings.tr(context, 'mapBrowseTitle'), AppIcons.place, () => context.push('/location-map')),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: _kShortcutCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kShortcutCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.tr(context, 'homeQuickActions'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: Colors.black.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  _QuickActionPill(
                    label: items[i].label,
                    icon: items[i].icon,
                    onTap: items[i].onTap,
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Divider(height: 1, thickness: 1, color: Colors.black.withValues(alpha: 0.06)),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/accessibility-settings'),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.accessibility_new_rounded,
                      size: 20,
                      color: AppTheme.maroon.withValues(alpha: 0.75),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppStrings.tr(context, 'homeAccessibilityShort'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withValues(alpha: 0.62),
                        ),
                      ),
                    ),
                    Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.chevron_left_rounded
                          : Icons.chevron_right_rounded,
                      size: 20,
                      color: Colors.black.withValues(alpha: 0.28),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickItem {
  _QuickItem(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _QuickActionPill extends StatelessWidget {
  const _QuickActionPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _kPillBg,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppTheme.maroon.withValues(alpha: 0.07),
        highlightColor: AppTheme.maroon.withValues(alpha: 0.04),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kPillBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: _kPillIcon),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  color: _kPillLabel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Today / this month + optional feed line from [AppContentProvider].
class HomeMinistrySnapshot extends StatelessWidget {
  const HomeMinistrySnapshot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppContentProvider>(
      builder: (context, ac, _) {
        final m = ac.data?.ministryStats;
        if (ac.loading && m == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(minHeight: 2),
          );
        }
        if (m == null) return const SizedBox.shrink();
        final ar = Localizations.localeOf(context).languageCode == 'ar';
        final feed = ar && (m.feedNoteAr?.isNotEmpty ?? false)
            ? m.feedNoteAr!
            : (m.feedNote?.isNotEmpty ?? false)
                ? m.feedNote!
                : null;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.maroon.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.maroon.withValues(alpha: 0.14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.tr(context, 'homeMinistrySnapshot'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: AppTheme.maroon,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _SnapCell(
                      label: AppStrings.tr(context, 'deceasedToday'),
                      value: '${m.deceasedToday}',
                    ),
                  ),
                  Expanded(
                    child: _SnapCell(
                      label: AppStrings.tr(context, 'deceasedThisMonth'),
                      value: '${m.deceasedThisMonth}',
                    ),
                  ),
                ],
              ),
              if (feed != null) ...[
                const SizedBox(height: 8),
                Text(
                  feed,
                  style: TextStyle(
                    fontSize: 13,
                    height: 18 / 13,
                    color: Colors.black.withValues(alpha: 0.82),
                  ),
                ),
              ],
              TextButton(
                onPressed: () => context.push('/ministry-news'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.maroon,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppStrings.tr(context, 'ministryNewsTitle'),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SnapCell extends StatelessWidget {
  const _SnapCell({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            height: 1.2,
            fontWeight: FontWeight.w500,
            color: Colors.black.withValues(alpha: 0.74),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.15,
            color: Color(0xFF1C1C1C),
          ),
        ),
      ],
    );
  }
}

/// Next upcoming funeral prayer or burial from content API.
class HomeNextAnnouncementTeaser extends StatelessWidget {
  const HomeNextAnnouncementTeaser({super.key});

  String _name(AppAnnouncement a, BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    if (ar && (a.nameAr?.isNotEmpty ?? false)) return a.nameAr!;
    return a.name;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppContentProvider>(
      builder: (context, ac, _) {
        final list = ac.data?.announcements ?? const <AppAnnouncement>[];
        final next = nextUpcomingAnnouncement(list, DateTime.now());
        if (next == null) {
          if (ac.loading && ac.data == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              AppStrings.tr(context, 'homeNoUpcomingServices'),
              style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.5)),
            ),
          );
        }
        final svc = DateTime.tryParse(next.serviceDateTime);
        final serviceLine = svc != null
            ? formatServiceDateTime(context, svc)
            : next.serviceDateTime;
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => context.push('/announcements'),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kShortcutCardBorder),
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
                    AppStrings.tr(context, 'homeNextService'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withValues(alpha: 0.48),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _name(next, context),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.25),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    serviceLine,
                    style: TextStyle(fontSize: 13, color: Colors.black.withValues(alpha: 0.65)),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      AppStrings.tr(context, 'homeSeeAllAnnouncements'),
                      style: TextStyle(
                        color: AppTheme.maroon.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Count of open maintenance tickets on this device → Requests hub.
class HomeOpenReportsBanner extends StatelessWidget {
  const HomeOpenReportsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MaintenanceService>(
      builder: (context, svc, _) {
        final n = countOpenMaintenanceTickets(svc.tickets);
        if (n == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              AppStrings.tr(context, 'homeOpenReportsZero'),
              style: TextStyle(fontSize: 12, color: Colors.black.withValues(alpha: 0.5)),
            ),
          );
        }
        return Material(
          color: AppTheme.maroon.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => context.push('/requests'),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.maroon.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  Icon(Icons.assignment_outlined, size: 22, color: AppTheme.maroon.withValues(alpha: 0.75)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppStrings.tr(context, 'homeOpenReports', '$n'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black.withValues(alpha: 0.78),
                      ),
                    ),
                  ),
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Expandable hours, phone, website — from API or bundled fallback.
class HomeHoursContactCard extends StatelessWidget {
  const HomeHoursContactCard({super.key});

  String? _hours(SiteInfo? s, BuildContext context) {
    if (s == null) return null;
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    if (ar && (s.openingHoursAr?.isNotEmpty ?? false)) return s.openingHoursAr;
    return s.openingHours;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppContentProvider>(
      builder: (context, ac, _) {
        final s = ac.data?.siteInfo;
        final hours = _hours(s, context);
        final phone = s?.phone;
        final web = s?.website;
        if (hours == null && (phone == null || phone.isEmpty) && (web == null || web.isEmpty)) {
          return const SizedBox.shrink();
        }
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.hubCardBorderColor),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            boxShadow: AppTheme.cardElevationShadow,
          ),
          child: ExpansionTile(
            title: Text(
              AppStrings.tr(context, 'homeHoursContact'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            children: [
              if (hours != null && hours.isNotEmpty)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(hours, style: const TextStyle(fontSize: 14, height: 1.4)),
                ),
              if (phone != null && phone.isNotEmpty)
                TextButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  icon: const Icon(Icons.phone_rounded, size: 20),
                  label: Text(phone),
                ),
              if (web != null && web.isNotEmpty)
                TextButton.icon(
                  onPressed: () async {
                    var url = web.trim();
                    if (!url.startsWith('http')) url = 'https://$url';
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.language_rounded, size: 20),
                  label: Text(AppStrings.tr(context, 'website')),
                ),
            ],
          ),
        );
      },
    );
  }
}
