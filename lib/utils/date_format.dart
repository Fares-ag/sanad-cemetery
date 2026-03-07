import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Formats a date for "passed away" / death date display.
/// Respects the current locale (e.g. Arabic numerals and month names for ar).
String formatDeathDate(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).languageCode;
  return DateFormat.yMMMMd(locale).format(date);
}

/// Formats date and time for memorial/funeral service display.
/// Respects the current locale (e.g. Arabic numerals and month names for ar).
String formatServiceDateTime(BuildContext context, DateTime dateTime) {
  final locale = Localizations.localeOf(context).languageCode;
  final datePart = DateFormat.yMMMd(locale).format(dateTime);
  final timePart = DateFormat.jm(locale).format(dateTime);
  return '$datePart ${locale == 'ar' ? 'الساعة' : 'at'} $timePart';
}

/// Formats an integer for display (e.g. age, grave number, years).
/// Uses Arabic-Indic numerals in Arabic locale.
String formatNumber(BuildContext context, num value) {
  final locale = Localizations.localeOf(context).languageCode;
  return NumberFormat.decimalPattern(locale).format(value);
}
