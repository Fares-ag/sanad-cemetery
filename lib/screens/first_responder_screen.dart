import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../utils/date_format.dart';

class FirstResponderScreen extends StatelessWidget {
  const FirstResponderScreen({super.key});

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
        title: Text(AppStrings.tr(context, 'firstResponderTitle'), style: AppTheme.appBarTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(AppStrings.tr(context, 'firstResponderSubtitle'), style: AppTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            AppStrings.tr(context, 'liveFeedDemo'),
            style: AppTheme.labelMuted(0.65),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < 5; i++)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text('Field update ${formatNumber(context, i + 1)}'),
                subtitle: Text(AppStrings.tr(context, 'submittedAt')),
              ),
            ),
        ],
      ),
    );
  }
}
