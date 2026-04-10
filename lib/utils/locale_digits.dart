import 'package:flutter/material.dart';

/// Western (ASCII) digits → Eastern Arabic numerals (٠–٩), for Arabic UI.
const _western = '0123456789';
const _easternArabic = '٠١٢٣٤٥٦٧٨٩';

/// Converts only U+0030–U+0039; leaves existing Arabic-Indic / other chars unchanged.
String westernDigitsToEasternArabic(String input) {
  final sb = StringBuffer();
  for (final ch in input.split('')) {
    final i = _western.indexOf(ch);
    sb.write(i >= 0 ? _easternArabic[i] : ch);
  }
  return sb.toString();
}

/// Whether the active app language should use Eastern Arabic numerals in the UI.
bool useEasternArabicNumeralsForLanguage(String languageCode) => languageCode == 'ar';

/// Same using the current [MaterialLocalizations] / app locale.
bool useEasternArabicNumerals(BuildContext context) =>
    useEasternArabicNumeralsForLanguage(Localizations.localeOf(context).languageCode);

/// Applies [westernDigitsToEasternArabic] when the locale is Arabic.
String localizeWesternDigitsForDisplay(BuildContext context, String text) {
  if (!useEasternArabicNumerals(context)) return text;
  return westernDigitsToEasternArabic(text);
}
