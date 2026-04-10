import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Explains how the Ministry of Municipality and Awqaf divide responsibilities (Qatar model).
class MinistryGovernanceScreen extends StatelessWidget {
  const MinistryGovernanceScreen({super.key});

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
        title: Text(AppStrings.tr(context, 'governanceGuideTitle'), style: AppTheme.appBarTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
        children: [
          Text(
            AppStrings.tr(context, 'governanceGuideSubtitle'),
            style: AppTheme.sectionTitle,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.tr(context, 'governanceIntro'),
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary(0.75)),
          ),
          const SizedBox(height: 20),
          _Section(
            title: AppStrings.tr(context, 'governanceMunicipalityTitle'),
            lead: AppStrings.tr(context, 'governanceMunicipalityLead'),
            children: [
              _SubBlock(
                title: AppStrings.tr(context, 'governanceMuniPlanningTitle'),
                body: AppStrings.tr(context, 'governanceMuniPlanningBody'),
              ),
              _SubBlock(
                title: AppStrings.tr(context, 'governanceMuniOpsTitle'),
                body: AppStrings.tr(context, 'governanceMuniOpsBody'),
              ),
              _SubBlock(
                title: AppStrings.tr(context, 'governanceMuniInfraTitle'),
                body: AppStrings.tr(context, 'governanceMuniInfraBody'),
              ),
              _SubBlock(
                title: AppStrings.tr(context, 'governanceMuniPublicTitle'),
                body: AppStrings.tr(context, 'governanceMuniPublicBody'),
              ),
              const SizedBox(height: 8),
              _ThinkBox(text: AppStrings.tr(context, 'governanceMuniThink')),
            ],
          ),
          const SizedBox(height: 20),
          _Section(
            title: AppStrings.tr(context, 'governanceAwqafTitle'),
            lead: AppStrings.tr(context, 'governanceAwqafLead'),
            children: [
              _SubBlock(
                title: AppStrings.tr(context, 'governanceAwqafIslamicTitle'),
                body: AppStrings.tr(context, 'governanceAwqafIslamicBody'),
              ),
              _SubBlock(
                title: AppStrings.tr(context, 'governanceAwqafSupervisionTitle'),
                body: AppStrings.tr(context, 'governanceAwqafSupervisionBody'),
              ),
              _SubBlock(
                title: AppStrings.tr(context, 'governanceAwqafMosqueTitle'),
                body: AppStrings.tr(context, 'governanceAwqafMosqueBody'),
              ),
              _SubBlock(
                title: AppStrings.tr(context, 'governanceAwqafCommunityTitle'),
                body: AppStrings.tr(context, 'governanceAwqafCommunityBody'),
              ),
              const SizedBox(height: 8),
              _ThinkBox(text: AppStrings.tr(context, 'governanceAwqafThink')),
            ],
          ),
          const SizedBox(height: 20),
          Text(AppStrings.tr(context, 'governanceWorkflowTitle'), style: AppTheme.sectionTitle),
          const SizedBox(height: 8),
          Text(
            AppStrings.tr(context, 'governanceWorkflowBody'),
            style: AppTheme.bodyMedium.copyWith(height: 22 / 14),
          ),
          const SizedBox(height: 20),
          Text(AppStrings.tr(context, 'governanceCompareTitle'), style: AppTheme.sectionTitle),
          const SizedBox(height: 12),
          const _CompareTable(),
          const SizedBox(height: 20),
          Text(AppStrings.tr(context, 'governanceNuanceTitle'), style: AppTheme.sectionTitle),
          const SizedBox(height: 8),
          Text(
            AppStrings.tr(context, 'governanceNuanceBody'),
            style: AppTheme.bodyMedium.copyWith(height: 22 / 14),
          ),
          const SizedBox(height: 20),
          Text(AppStrings.tr(context, 'governanceWhyTitle'), style: AppTheme.sectionTitle),
          const SizedBox(height: 8),
          Text(
            AppStrings.tr(context, 'governanceWhyBody'),
            style: AppTheme.bodyMedium.copyWith(height: 22 / 14),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.lead,
    required this.children,
  });

  final String title;
  final String lead;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppTheme.sectionTitle.copyWith(color: AppTheme.maroon)),
        const SizedBox(height: 6),
        Text(lead, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _SubBlock extends StatelessWidget {
  const _SubBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.cardTitle.copyWith(fontSize: 15)),
          const SizedBox(height: 4),
          Text(
            body,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary(0.82),
              height: 20 / 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThinkBox extends StatelessWidget {
  const _ThinkBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.maroon.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.maroon.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: AppTheme.bodyMedium.copyWith(
          color: AppTheme.maroon,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
        ),
      ),
    );
  }
}

class _CompareTable extends StatelessWidget {
  const _CompareTable();

  @override
  Widget build(BuildContext context) {
    final rows = [
      (
        AppStrings.tr(context, 'governanceTblRow1Label'),
        AppStrings.tr(context, 'governanceTblRow1Muni'),
        AppStrings.tr(context, 'governanceTblRow1Awqaf'),
      ),
      (
        AppStrings.tr(context, 'governanceTblRow2Label'),
        AppStrings.tr(context, 'governanceTblRow2Muni'),
        AppStrings.tr(context, 'governanceTblRow2Awqaf'),
      ),
      (
        AppStrings.tr(context, 'governanceTblRow3Label'),
        AppStrings.tr(context, 'governanceTblRow3Muni'),
        AppStrings.tr(context, 'governanceTblRow3Awqaf'),
      ),
      (
        AppStrings.tr(context, 'governanceTblRow4Label'),
        AppStrings.tr(context, 'governanceTblRow4Muni'),
        AppStrings.tr(context, 'governanceTblRow4Awqaf'),
      ),
      (
        AppStrings.tr(context, 'governanceTblRow5Label'),
        AppStrings.tr(context, 'governanceTblRow5Muni'),
        AppStrings.tr(context, 'governanceTblRow5Awqaf'),
      ),
    ];

    TextStyle cell(bool header) => TextStyle(
          fontSize: header ? 13 : 13,
          fontWeight: header ? FontWeight.w600 : FontWeight.w400,
          height: 18 / 13,
          color: header ? Colors.black : AppTheme.textSecondary(0.88),
        );

    return Table(
      border: TableBorder.all(color: AppTheme.hubCardBorderColor),
      columnWidths: const {
        0: FlexColumnWidth(1.15),
        1: FlexColumnWidth(1.2),
        2: FlexColumnWidth(1.2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: AppTheme.cardMuted(0.04)),
          children: [
            _CompareTable._cellPad(Text(AppStrings.tr(context, 'governanceTblArea'), style: cell(true))),
            _CompareTable._cellPad(Text(AppStrings.tr(context, 'governanceTblMunicipalityCol'), style: cell(true))),
            _CompareTable._cellPad(Text(AppStrings.tr(context, 'governanceTblAwqafCol'), style: cell(true))),
          ],
        ),
        for (final r in rows)
          TableRow(
            children: [
              _CompareTable._cellPad(Text(r.$1, style: cell(false).copyWith(color: Colors.black87))),
              _CompareTable._cellPad(Text(r.$2, style: cell(false))),
              _CompareTable._cellPad(Text(r.$3, style: cell(false))),
            ],
          ),
      ],
    );
  }

  static Widget _cellPad(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: child,
    );
  }
}
