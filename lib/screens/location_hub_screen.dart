import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/hub_link_card.dart';

/// Location hub: map, grave request, burial announcements.
class LocationHubScreen extends StatelessWidget {
  const LocationHubScreen({super.key});

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
        title: Text(AppStrings.tr(context, 'navLocation'), style: AppTheme.appBarTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 100),
        children: [
          Text(AppStrings.tr(context, 'locationHubTitle'), style: AppTheme.sectionTitle),
          const SizedBox(height: 8),
          Text(
            AppStrings.tr(context, 'locationHubSubtitle'),
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary(0.55)),
          ),
          const SizedBox(height: 20),
          HubLinkCard(
            icon: AppIcons.place,
            title: AppStrings.tr(context, 'browseMap'),
            subtitle: AppStrings.tr(context, 'mapBrowseHint'),
            onTap: () => context.push('/location-map'),
          ),
          const SizedBox(height: 12),
          HubLinkCard(
            icon: AppIcons.location,
            title: AppStrings.tr(context, 'requestGraveLocationTitle'),
            subtitle: AppStrings.tr(context, 'requestGraveLocationDesc'),
            onTap: () => context.push('/request-grave-location'),
          ),
          const SizedBox(height: 12),
          HubLinkCard(
            icon: AppIcons.campaign,
            title: AppStrings.tr(context, 'burialAnnouncements'),
            subtitle: AppStrings.tr(context, 'burialAnnouncementsHint'),
            onTap: () => context.push('/announcements'),
          ),
        ],
      ),
    );
  }
}
