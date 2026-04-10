import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../providers/app_content_provider.dart';
import '../theme/app_theme.dart';

class MinistryNewsScreen extends StatelessWidget {
  const MinistryNewsScreen({super.key});

  String _feedLine(BuildContext context, AppContentProvider ac) {
    final m = ac.data?.ministryStats;
    if (m == null) return AppStrings.tr(context, 'liveFeedDemo');
    final ar = Localizations.localeOf(context).languageCode == 'ar';
    if (ar && (m.feedNoteAr?.isNotEmpty ?? false)) return m.feedNoteAr!;
    if (m.feedNote?.isNotEmpty ?? false) return m.feedNote!;
    return AppStrings.tr(context, 'liveFeedDemo');
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
        leading: IconButton(
          icon: Icon(isRtl ? AppIcons.forward : AppIcons.back),
          onPressed: () => context.pop(),
        ),
        title: Text(AppStrings.tr(context, 'ministryNewsTitle'), style: AppTheme.appBarTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AppContentProvider>().refresh(),
        child: Consumer<AppContentProvider>(
          builder: (context, ac, _) {
            final m = ac.data?.ministryStats;
            final today = m != null ? '${m.deceasedToday}' : (ac.loading ? '…' : '3');
            final month = m != null ? '${m.deceasedThisMonth}' : (ac.loading ? '…' : '42');
            final showFatalError = !ac.loading && ac.data == null;
            final showBundledHint = ac.lastRefreshUsedAssetFallback && ac.data != null;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              children: [
                if (showFatalError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      AppStrings.tr(context, 'appContentOffline'),
                      style: AppTheme.bodyMedium.copyWith(color: Colors.orange.shade900),
                    ),
                  ),
                if (showBundledHint)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      AppStrings.tr(context, 'appContentBundled'),
                      style: AppTheme.bodyMedium.copyWith(color: Colors.black87),
                    ),
                  ),
                Semantics(
                  button: true,
                  label: AppStrings.tr(context, 'governanceOpenGuide'),
                  child: Material(
                    color: AppTheme.maroon.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    child: InkWell(
                      onTap: () => context.push('/ministry-governance'),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(Icons.account_balance_rounded, color: AppTheme.maroon, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.tr(context, 'governanceOpenGuide'),
                                    style: AppTheme.cardTitle.copyWith(color: AppTheme.maroon),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppStrings.tr(context, 'governanceGuideSubtitle'),
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.textSecondary(0.65),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                              color: AppTheme.maroon,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(AppStrings.tr(context, 'ministryNewsSubtitle'), style: AppTheme.bodyMedium),
                const SizedBox(height: 16),
                if (ac.loading && m == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  _StatRow(label: AppStrings.tr(context, 'deceasedToday'), value: today),
                  _StatRow(label: AppStrings.tr(context, 'deceasedThisMonth'), value: month),
                ],
                const Divider(),
                Text(_feedLine(context, ac), style: AppTheme.labelMuted(0.65)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: AppTheme.cardTitle)),
          Text(value, style: AppTheme.sectionTitle),
        ],
      ),
    );
  }
}
