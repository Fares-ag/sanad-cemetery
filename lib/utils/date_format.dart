import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'locale_digits.dart';

/// Formats a date for "passed away" / death date display.
/// Respects the current locale (e.g. Arabic numerals and month names for ar).
String _dateLocale(BuildContext context) {
  final c = Localizations.localeOf(context).languageCode;
  if (c == 'ar') return 'ar';
  return 'en';
}

String formatDeathDate(BuildContext context, DateTime date) {
  final locale = _dateLocale(context);
  final s = DateFormat.yMMMMd(locale).format(date);
  return locale == 'ar' ? westernDigitsToEasternArabic(s) : s;
}

/// Formats date and time for funeral prayer / burial display.
/// Respects the current locale (e.g. Arabic numerals and month names for ar).
String formatServiceDateTime(BuildContext context, DateTime dateTime) {
  final locale = _dateLocale(context);
  final datePart = DateFormat.yMMMd(locale).format(dateTime);
  final timePart = DateFormat.jm(locale).format(dateTime);
  var s = '$datePart ${locale == 'ar' ? 'الساعة' : 'at'} $timePart';
  if (locale == 'ar') s = westernDigitsToEasternArabic(s);
  return s;
}

/// Compact date-time for lists / tickets (Gregorian calendar; Arabic-Indic digits when locale is ar).
String formatDateTimeCompact(BuildContext context, DateTime dateTime) {
  final locale = _dateLocale(context);
  final s = DateFormat('yyyy-MM-dd HH:mm', locale).format(dateTime);
  return locale == 'ar' ? westernDigitsToEasternArabic(s) : s;
}

/// Formats an integer for display (e.g. age, grave number, years).
/// Uses Arabic-Indic numerals in Arabic locale.
String formatNumber(BuildContext context, num value) {
  final c = Localizations.localeOf(context).languageCode;
  final locale = c == 'ar' ? 'ar' : 'en';
  final s = NumberFormat.decimalPattern(locale).format(value);
  return c == 'ar' ? westernDigitsToEasternArabic(s) : s;
}
