import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../providers/locale_provider.dart';

void showLanguagePickerSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    builder: (ctx) {
      void pick(Locale locale) {
        ctx.read<LocaleProvider>().setLocale(locale);
        Navigator.pop(ctx);
      }

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppStrings.tr(ctx, 'chooseLanguage'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              title: Text(AppStrings.tr(ctx, 'languageEnglish')),
              onTap: () => pick(const Locale('en')),
            ),
            ListTile(
              title: Text(AppStrings.tr(ctx, 'languageArabic')),
              onTap: () => pick(const Locale('ar')),
            ),
            ListTile(
              title: Text(AppStrings.tr(ctx, 'languageHindi')),
              onTap: () => pick(const Locale('hi')),
            ),
            ListTile(
              title: Text(AppStrings.tr(ctx, 'languageUrdu')),
              onTap: () => pick(const Locale('ur')),
            ),
            ListTile(
              title: Text(AppStrings.tr(ctx, 'languageMalayalam')),
              onTap: () => pick(const Locale('ml')),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
