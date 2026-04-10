import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../providers/accessibility_provider.dart';
import '../theme/app_theme.dart';

class AccessibilitySettingsScreen extends StatelessWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final a11y = context.watch<AccessibilityProvider>();
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
        title: Text(AppStrings.tr(context, 'accessibilityPortal'), style: AppTheme.appBarTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(AppStrings.tr(context, 'accessibilityPortalIntro'), style: AppTheme.bodyMedium),
          const SizedBox(height: 20),
          Text(AppStrings.tr(context, 'textSize'), style: AppTheme.cardTitle),
          Slider(
            value: a11y.textScale,
            min: 1.0,
            max: 1.6,
            divisions: 6,
            label: a11y.textScale.toStringAsFixed(1),
            onChanged: (v) => context.read<AccessibilityProvider>().setTextScale(v),
          ),
          SwitchListTile(
            title: Text(AppStrings.tr(context, 'boldLabels')),
            subtitle: Text(AppStrings.tr(context, 'boldLabelsHelp'), style: AppTheme.labelMuted(0.65)),
            value: a11y.boldLabels,
            onChanged: context.read<AccessibilityProvider>().setBoldLabels,
          ),
          SwitchListTile(
            title: Text(AppStrings.tr(context, 'simplifiedLayout')),
            subtitle: Text(AppStrings.tr(context, 'simplifiedLayoutHelp'), style: AppTheme.labelMuted(0.65)),
            value: a11y.simplifiedLayout,
            onChanged: context.read<AccessibilityProvider>().setSimplifiedLayout,
          ),
        ],
      ),
    );
  }
}
