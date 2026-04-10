import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

class MetricsDetailScreen extends StatelessWidget {
  const MetricsDetailScreen({super.key, required this.type});

  final String type;

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
        title: Text(AppStrings.tr(context, 'metricsOverview'), style: AppTheme.appBarTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: $type', style: AppTheme.sectionTitle),
            const SizedBox(height: 12),
            Text(AppStrings.tr(context, 'metricsDetailHint'), style: AppTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
