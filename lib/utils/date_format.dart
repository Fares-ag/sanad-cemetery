import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Formats a date for "passed away" / death date display.
/// Respects the current locale (e.g. Arabic numerals and month names for ar).
String _dateLocale(BuildContext context) {
  final c = Localizations.localeOf(context).languageCode;
  if (c == 'ar') return 'ar';
  return 'en';
}

String formatDeathDate(BuildContext context, DateTime date) {
  final locale = _dateLocale(context);
  return DateFormat.yMMMMd(locale).format(date);
}

/// Formats date and time for funeral prayer / burial display.
/// Respects the current locale (e.g. Arabic numerals and month names for ar).
String formatServiceDateTime(BuildContext context, DateTime dateTime) {
  final locale = _dateLocale(context);
  final datePart = DateFormat.yMMMd(locale).format(dateTime);
  final timePart = DateFormat.jm(locale).format(dateTime);
  return '$datePart ${locale == 'ar' ? 'الساعة' : 'at'} $timePart';
}

/// Formats an integer for display (e.g. age, grave number, years).
/// Uses Arabic-Indic numerals in Arabic locale.
String formatNumber(BuildContext context, num value) {
  final c = Localizations.localeOf(context).languageCode;
  final locale = c == 'ar' ? 'ar' : 'en';
  return NumberFormat.decimalPattern(locale).format(value);
}
