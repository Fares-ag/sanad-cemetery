import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

class TutorialsScreen extends StatelessWidget {
  const TutorialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final items = [
      AppStrings.tr(context, 'tutorialJanazah'),
      AppStrings.tr(context, 'tutorialGhusl'),
      AppStrings.tr(context, 'tutorialVisitingGrave'),
    ];
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
        title: Text(AppStrings.tr(context, 'tutorialsTitle'), style: AppTheme.appBarTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(AppStrings.tr(context, 'tutorialsSubtitle'), style: AppTheme.bodyMedium),
          const SizedBox(height: 16),
          for (final t in items)
            Card(
              child: ListTile(
                title: Text(t),
                trailing: const Icon(Icons.play_circle_outline_rounded),
                onTap: () {},
              ),
            ),
        ],
      ),
    );
  }
}
