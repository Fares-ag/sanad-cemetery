import 'package:flutter/material.dart';

/// Standard icon set for consistent use across the app.
class AppIcons {
  AppIcons._();

  static const double sizeSm = 18;
  static const double sizeMd = 20;
  static const double sizeLg = 24;
  static const double sizeXl = 32;

  // Navigation & actions
  static const IconData add = Icons.add_rounded;
  static const IconData back = Icons.arrow_back_rounded;
  static const IconData forward = Icons.arrow_forward_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData settings = Icons.settings_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData home = Icons.home_rounded;
  static const IconData campaign = Icons.campaign_rounded;

  // Location & map
  static const IconData location = Icons.location_on_rounded;
  static const IconData place = Icons.place_rounded;
  static const IconData myLocation = Icons.my_location_rounded;
  static const IconData locationOff = Icons.location_off_rounded;

  // Communication & emergency
  static const IconData phone = Icons.phone_rounded;
  static const IconData emergency = Icons.emergency_rounded;
  static const IconData alert = Icons.warning_amber_rounded;

  // Cemetery & reports
  static const IconData report = Icons.report_rounded;
  static const IconData construction = Icons.construction_rounded;
  static const IconData park = Icons.park_rounded;
  static const IconData grass = Icons.grass_rounded;

  // Funeral prayers & burial (public announcements)
  static const IconData prayer = Icons.mosque_rounded;
  static const IconData burialService = Icons.place_rounded;

  // Media & content
  static const IconData image = Icons.image_rounded;
  static const IconData person = Icons.person_rounded;
  static const IconData personOff = Icons.person_off_rounded;
  static const IconData qrCode = Icons.qr_code_rounded;
  static const IconData qrCodeScanner = Icons.qr_code_scanner_rounded;

  // Status
  static const IconData checkCircle = Icons.check_circle_rounded;
  static const IconData camera = Icons.camera_alt_rounded;
  static const IconData hourglass = Icons.hourglass_empty_rounded;
  static const IconData imageNotSupported = Icons.image_not_supported_outlined;
}

/// Central design system for Sanad Cemetery app.
/// Use these constants and text styles for a consistent, professional look.
class AppTheme {
  AppTheme._();

  // --- Colors ---
  static const Color maroon = Color(0xFF8E1737);
  static const Color maroonSecondary = Color(0xFFA91F42);

  static Color get surface => Colors.white;
  static Color get textPrimary => Colors.black;
  static Color textSecondary([double opacity = 0.5]) => Colors.black.withOpacity(opacity);
  static Color border([double opacity = 0.1]) => Colors.black.withOpacity(opacity);
  static Color divider([double opacity = 0.12]) => Colors.black.withOpacity(opacity);
  static Color cardMuted([double opacity = 0.05]) => Colors.black.withOpacity(opacity);

  /// Warm neutral page background — aligned with web dashboards (`--bg`).
  static const Color appScaffoldBackground = Color(0xFFFAF8F8);

  /// Hub screens use the same canvas as the rest of the app.
  static const Color hubScaffoldBackground = appScaffoldBackground;

  /// Hub row: always light surface for text contrast (avoid dark M3 card surfaces).
  static const Color hubCardBackground = Color(0xFFFFFFFF);

  /// Soft outline for cards and rows (matches web `--border` feel).
  static const Color hubCardBorderColor = Color(0xFFE3DEDE);

  /// Subtle elevation for content cards on the scaffold (web `.panel` shadow).
  static final List<BoxShadow> cardElevationShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  /// Icon backplate on hub rows (light maroon wash).
  static Color iconHubBackground([double opacity = 0.10]) => maroon.withValues(alpha: opacity);

  // --- Spacing ---
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 24;
  static const double spaceXxl = 32;

  // --- Radius ---
  static const double radiusSm = 6;
  static const double radiusMd = 8;
  static const double radiusLg = 12;

  // --- Typography ---
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 24 / 20,
    color: Colors.black,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 24 / 18,
    color: Colors.black,
  );

  static const TextStyle sectionSubtitle = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    color: Colors.black54,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    color: Colors.black,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    color: Colors.black,
  );

  static TextStyle bodySecondary([double opacity = 0.5]) => TextStyle(
    fontSize: 14,
    height: 20 / 14,
    color: Colors.black.withOpacity(opacity),
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    color: Colors.black54,
  );

  static TextStyle labelMuted([double opacity = 0.5]) => TextStyle(
    fontSize: 12,
    height: 16 / 12,
    color: Colors.black.withOpacity(opacity),
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 22 / 16,
  );

  // --- Decoration helpers ---
  static BoxDecoration cardDecoration({Color? borderColor}) => BoxDecoration(
    color: Colors.white,
    border: Border.all(color: borderColor ?? hubCardBorderColor, width: 1),
    borderRadius: BorderRadius.circular(radiusSm),
    boxShadow: cardElevationShadow,
  );

  static InputDecoration inputDecoration({
    required String hintText,
    String? helperText,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        hintText: hintText,
        hintStyle: labelMuted(0.5),
        helperText: helperText,
        helperStyle: labelMuted(0.5),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusSm)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: border()),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: maroon, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );

  static ButtonStyle primaryButtonStyle() => TextButton.styleFrom(
        backgroundColor: maroon,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      );

  static ButtonStyle outlinedButtonStyle({Color? foregroundColor}) =>
      OutlinedButton.styleFrom(
        side: BorderSide(color: foregroundColor ?? textPrimary, width: 1),
        foregroundColor: foregroundColor ?? textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      );

  static ButtonStyle outlinedMaroonButtonStyle() => OutlinedButton.styleFrom(
        side: const BorderSide(color: maroon),
        foregroundColor: maroon,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      );
}
