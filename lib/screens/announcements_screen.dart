import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/app_content.dart';
import '../providers/app_content_provider.dart';
import '../services/app_content_api.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';
import '../utils/locale_digits.dart';

/// Recent announcements from the municipality content API + public submission (pending approval).
class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _burialController = TextEditingController();
  final _burialArController = TextEditingController();

  DateTime? _passedAwayDate;
  DateTime? _serviceAt;
  String _serviceType = 'funeral_prayers';
  String _iconKey = 'prayer';
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _burialController.dispose();
    _burialArController.dispose();
    super.dispose();
  }

  String _displayName(AppAnnouncement a, BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    if (ar && (a.nameAr?.isNotEmpty ?? false)) return a.nameAr!;
    return a.name;
  }

  String _displayLocation(AppAnnouncement a, BuildContext context) {
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    if (ar && (a.burialLocationAr?.isNotEmpty ?? false)) return a.burialLocationAr!;
    return a.burialLocation;
  }

  DateTime? _parsePassedAway(String raw) {
    final d = DateTime.tryParse(raw);
    if (d != null) return d;
    return DateTime.tryParse('${raw}T00:00:00');
  }

  bool _isBurialType(String serviceType) {
    return serviceType == 'burial' || serviceType == 'memorial';
  }

  Future<void> _pickPassedDate(BuildContext context) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _passedAwayDate ?? now,
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );
    if (d != null) setState(() => _passedAwayDate = d);
  }

  Future<void> _pickServiceDateTime(BuildContext context) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: (_serviceAt ?? now).toLocal(),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (d == null || !context.mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_serviceAt ?? now),
    );
    if (t == null) return;
    setState(() {
      _serviceAt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    });
  }

  Future<void> _submit(BuildContext context) async {
    final name = _nameController.text.trim();
    final burial = _burialController.text.trim();
    if (name.isEmpty || burial.isEmpty || _passedAwayDate == null || _serviceAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.tr(context, 'announcementFormIncomplete'))),
      );
      return;
    }
    setState(() => _submitting = true);
    final passedStr =
        '${_passedAwayDate!.year.toString().padLeft(4, '0')}-${_passedAwayDate!.month.toString().padLeft(2, '0')}-${_passedAwayDate!.day.toString().padLeft(2, '0')}';
    final iso = _serviceAt!.toUtc().toIso8601String();
    final result = await submitAnnouncementForReview(
      name: name,
      nameAr: _nameArController.text.trim().isEmpty ? null : _nameArController.text.trim(),
      passedAwayDate: passedStr,
      serviceType: _serviceType,
      serviceDateTimeIso: iso,
      burialLocation: burial,
      burialLocationAr: _burialArController.text.trim().isEmpty ? null : _burialArController.text.trim(),
      iconKey: _iconKey,
    );
    if (!context.mounted) return;
    setState(() => _submitting = false);
    if (result.ok) {
      _nameController.clear();
      _nameArController.clear();
      _burialController.clear();
      _burialArController.clear();
      setState(() {
        _passedAwayDate = null;
        _serviceAt = null;
      });
      await context.read<AppContentProvider>().refresh();
      if (!context.mounted) return;
      context.push('/success?msg=announcementQueuedForReview');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.tr(context, 'announcementSubmitFailed'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: AppTheme.appScaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.hubCardBorderColor),
        ),
        leading: IconButton(
          icon: Icon(isRtl ? AppIcons.forward : AppIcons.back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/location');
            }
          },
        ),
        title: Text(
          AppStrings.tr(context, 'announcements'),
          style: AppTheme.appBarTitle,
        ),
      ),
      body: RefreshIndicator(
        color: AppTheme.maroon,
        onRefresh: () => context.read<AppContentProvider>().refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          child: Consumer<AppContentProvider>(
            builder: (context, ac, _) {
              final rows = ac.data?.announcements ?? const <AppAnnouncement>[];
              final showFatalError = !ac.loading && ac.data == null;
              final showBundledHint = ac.lastRefreshUsedAssetFallback && ac.data != null;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showFatalError) _StatusBanner.error(message: AppStrings.tr(context, 'appContentOffline')),
                  if (showBundledHint) _StatusBanner.info(message: AppStrings.tr(context, 'appContentBundled')),
                  Text(
                    AppStrings.tr(context, 'recentAnnouncements'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      height: 1.25,
                      color: Color(0xFF3A0B17),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.tr(context, 'burialAnnouncementsHint'),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: Colors.black.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (ac.loading && rows.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.maroon),
                        ),
                      ),
                    ),
                  if (!ac.loading && rows.isEmpty)
                    _EmptyAnnouncements(message: AppStrings.tr(context, 'noResults')),
                  ...rows.map((a) {
                    final passed = _parsePassedAway(a.passedAwayDate);
                    final svc = DateTime.tryParse(a.serviceDateTime);
                    final isBurial = _isBurialType(a.serviceType);
                    final serviceKey = isBurial ? 'burialScheduledOn' : 'funeralPrayersOn';
                    final iconKey = a.iconKey ?? 'burial';
                    final isPrayerIcon = iconKey == 'prayer' || iconKey == 'celebration';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AnnouncementCard(
                        name: _displayName(a, context),
                        date: passed != null
                            ? AppStrings.tr(context, 'passedAwayOn', formatDeathDate(context, passed))
                            : a.passedAwayDate,
                        service: svc != null
                            ? AppStrings.tr(context, serviceKey, formatServiceDateTime(context, svc))
                            : a.serviceDateTime,
                        burialLocation: _displayLocation(a, context),
                        icon: isPrayerIcon ? AppIcons.prayer : AppIcons.burialService,
                        isBurial: isBurial,
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  _SubmitAnnouncementCard(
                    nameController: _nameController,
                    nameArController: _nameArController,
                    burialController: _burialController,
                    burialArController: _burialArController,
                    passedAwayDate: _passedAwayDate,
                    serviceAt: _serviceAt,
                    serviceType: _serviceType,
                    iconKey: _iconKey,
                    submitting: _submitting,
                    onPickPassed: () => _pickPassedDate(context),
                    onPickService: () => _pickServiceDateTime(context),
                    onServiceType: (v) => setState(() {
                      _serviceType = v;
                      _iconKey = v == 'burial' ? 'burial' : 'prayer';
                    }),
                    onIconKey: (v) => setState(() => _iconKey = v),
                    onSubmit: () => _submit(context),
                    onCancel: () {
                      _nameController.clear();
                      _nameArController.clear();
                      _burialController.clear();
                      _burialArController.clear();
                      setState(() {
                        _passedAwayDate = null;
                        _serviceAt = null;
                      });
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner.error({required this.message}) : _isError = true;
  const _StatusBanner.info({required this.message}) : _isError = false;

  final String message;
  final bool _isError;

  @override
  Widget build(BuildContext context) {
    final bg = _isError ? const Color(0xFFFFF4E6) : const Color(0xFFF5F0F1);
    final border = _isError ? const Color(0xFFFFC966) : AppTheme.maroon.withValues(alpha: 0.18);
    final icon = _isError ? Icons.wifi_off_rounded : Icons.info_outline_rounded;
    final iconColor = _isError ? const Color(0xFFB45309) : AppTheme.maroon;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: _isError ? const Color(0xFF92400E) : Colors.black.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAnnouncements extends StatelessWidget {
  const _EmptyAnnouncements({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.hubCardBorderColor),
        boxShadow: AppTheme.cardElevationShadow,
      ),
      child: Column(
        children: [
          Icon(Icons.campaign_outlined, size: 44, color: Colors.black.withValues(alpha: 0.22)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Colors.black.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.name,
    required this.date,
    required this.service,
    required this.burialLocation,
    required this.icon,
    required this.isBurial,
  });

  final String name;
  final String date;
  final String service;
  final String burialLocation;
  final IconData icon;
  final bool isBurial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.hubCardBorderColor),
        boxShadow: AppTheme.cardElevationShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.maroon.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.maroon.withValues(alpha: 0.12)),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 26, color: AppTheme.maroon),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        color: Color(0xFF1C1C1C),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Colors.black.withValues(alpha: 0.52),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.maroon.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.maroon.withValues(alpha: 0.14)),
            ),
            child: Row(
              children: [
                Icon(
                  isBurial ? Icons.place_rounded : Icons.mosque_rounded,
                  size: 18,
                  color: AppTheme.maroon.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    service,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.maroon.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (burialLocation.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    AppIcons.place,
                    size: 18,
                    color: Colors.black.withValues(alpha: 0.42),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${AppStrings.tr(context, 'burialLocation')}: $burialLocation',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: Colors.black.withValues(alpha: 0.62),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SubmitAnnouncementCard extends StatelessWidget {
  const _SubmitAnnouncementCard({
    required this.nameController,
    required this.nameArController,
    required this.burialController,
    required this.burialArController,
    required this.passedAwayDate,
    required this.serviceAt,
    required this.serviceType,
    required this.iconKey,
    required this.submitting,
    required this.onPickPassed,
    required this.onPickService,
    required this.onServiceType,
    required this.onIconKey,
    required this.onSubmit,
    required this.onCancel,
  });

  final TextEditingController nameController;
  final TextEditingController nameArController;
  final TextEditingController burialController;
  final TextEditingController burialArController;
  final DateTime? passedAwayDate;
  final DateTime? serviceAt;
  final String serviceType;
  final String iconKey;
  final bool submitting;
  final VoidCallback onPickPassed;
  final VoidCallback onPickService;
  final void Function(String) onServiceType;
  final void Function(String) onIconKey;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    String fmt(DateTime? d) {
      if (d == null) return AppStrings.tr(context, 'tapToSelectDate');
      return localizeWesternDigitsForDisplay(
        context,
        MaterialLocalizations.of(context).formatMediumDate(d),
      );
    }

    String fmtSvc(DateTime? d) {
      if (d == null) return AppStrings.tr(context, 'tapToSelectDateTime');
      return formatServiceDateTime(context, d);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.hubCardBorderColor),
        boxShadow: AppTheme.cardElevationShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.maroon.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.edit_note_rounded, color: AppTheme.maroon.withValues(alpha: 0.95), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.tr(context, 'addNewAnnouncement'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: Color(0xFF3A0B17),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.tr(context, 'announcementPendingReviewHint'),
            style: TextStyle(fontSize: 12, height: 1.4, color: Colors.black.withValues(alpha: 0.55)),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: nameController,
            style: AppTheme.bodyMedium,
            decoration: AppTheme.inputDecoration(
              hintText: AppStrings.tr(context, 'enterNameDeceased'),
            ).copyWith(
              filled: true,
              fillColor: const Color(0xFFFCFAFA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.border(0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.maroon, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: nameArController,
            style: AppTheme.bodyMedium,
            textDirection: TextDirection.rtl,
            decoration: AppTheme.inputDecoration(
              hintText: AppStrings.tr(context, 'nameArOptional'),
            ).copyWith(
              filled: true,
              fillColor: const Color(0xFFFCFAFA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.border(0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.maroon, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(AppStrings.tr(context, 'passedAwayDateLabel'), style: AppTheme.bodyMedium),
          ),
          const SizedBox(height: 6),
          OutlinedButton(
            onPressed: onPickPassed,
            child: Text(fmt(passedAwayDate)),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(AppStrings.tr(context, 'serviceDateTimeLabel'), style: AppTheme.bodyMedium),
          ),
          const SizedBox(height: 6),
          OutlinedButton(
            onPressed: onPickService,
            child: Text(fmtSvc(serviceAt)),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: serviceType,
            decoration: AppTheme.inputDecoration(
              hintText: AppStrings.tr(context, 'serviceTypeBurialLabel'),
            ),
            items: [
              DropdownMenuItem(value: 'funeral_prayers', child: Text(AppStrings.tr(context, 'serviceTypeFuneralPrayers'))),
              DropdownMenuItem(value: 'burial', child: Text(AppStrings.tr(context, 'serviceTypeBurial'))),
            ],
            onChanged: (v) {
              if (v != null) onServiceType(v);
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: iconKey,
            decoration: AppTheme.inputDecoration(
              hintText: AppStrings.tr(context, 'listIconLabel'),
            ),
            items: [
              DropdownMenuItem(value: 'prayer', child: Text(AppStrings.tr(context, 'listIconPrayer'))),
              DropdownMenuItem(value: 'burial', child: Text(AppStrings.tr(context, 'listIconBurial'))),
            ],
            onChanged: (v) {
              if (v != null) onIconKey(v);
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: burialController,
            style: AppTheme.bodyMedium,
            maxLines: 2,
            decoration: AppTheme.inputDecoration(
              hintText: AppStrings.tr(context, 'burialLocationHint'),
            ).copyWith(
              filled: true,
              fillColor: const Color(0xFFFCFAFA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.border(0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.maroon, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: burialArController,
            style: AppTheme.bodyMedium,
            textDirection: TextDirection.rtl,
            maxLines: 2,
            decoration: AppTheme.inputDecoration(
              hintText: AppStrings.tr(context, 'burialLocationArOptional'),
            ).copyWith(
              filled: true,
              fillColor: const Color(0xFFFCFAFA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.border(0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.maroon, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: submitting ? null : onCancel,
                  style: AppTheme.outlinedButtonStyle(foregroundColor: Colors.black87),
                  child: Text(
                    AppStrings.tr(context, 'cancel'),
                    style: AppTheme.button.copyWith(color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: submitting ? null : onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.maroon,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                        )
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            AppStrings.tr(context, 'submitPublishAnnouncement'),
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
    );
  }
}
