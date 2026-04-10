import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/hub_link_card.dart';

/// All request types are visible at once (no dropdown) so users can scan options quickly.
class RequestsHubScreen extends StatelessWidget {
  const RequestsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: AppTheme.hubScaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(isRtl ? AppIcons.forward : AppIcons.back),
          onPressed: () => context.go('/'),
        ),
        title: Text(AppStrings.tr(context, 'navRequests'), style: AppTheme.appBarTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 100),
        children: [
          Text(AppStrings.tr(context, 'requestsHubTitle'), style: AppTheme.sectionTitle),
          const SizedBox(height: 8),
          Text(
            AppStrings.tr(context, 'requestsHubSubtitle'),
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary(0.55)),
          ),
          const SizedBox(height: 20),
          HubLinkCard(
            icon: AppIcons.construction,
            title: AppStrings.tr(context, 'reportIssue'),
            subtitle: AppStrings.tr(context, 'maintenanceRequestSub'),
            onTap: () => context.push('/maintenance'),
          ),
          const SizedBox(height: 12),
          HubLinkCard(
            icon: Icons.feedback_outlined,
            title: AppStrings.tr(context, 'complaintsTitle'),
            subtitle: AppStrings.tr(context, 'complaintsHint'),
            onTap: () => context.push('/complaints'),
          ),
          const SizedBox(height: 12),
          HubLinkCard(
            icon: Icons.balance_rounded,
            title: AppStrings.tr(context, 'religiousFinesTitle'),
            subtitle: AppStrings.tr(context, 'religiousFinesHint'),
            onTap: () => context.push('/religious-fines'),
          ),
          const SizedBox(height: 12),
          HubLinkCard(
            icon: Icons.info_outline_rounded,
            title: AppStrings.tr(context, 'requestInfoTitle'),
            subtitle: AppStrings.tr(context, 'requestInfoHint'),
            onTap: () => context.push('/request-information'),
          ),
        ],
      ),
    );
  }
}
