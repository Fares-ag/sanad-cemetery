import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Tappable hub row: white surface, soft border, explicit text colors for contrast.
class HubLinkCard extends StatelessWidget {
  const HubLinkCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  static const Color _titleColor = Color(0xFF1A1A1A);
  static const Color _subtitleColor = Color(0xFF5C5C5C);

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final radius = BorderRadius.circular(AppTheme.radiusMd);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppTheme.cardElevationShadow,
      ),
      child: Material(
        color: AppTheme.hubCardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: AppTheme.hubCardBorderColor, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: AppTheme.maroon.withValues(alpha: 0.10),
          highlightColor: AppTheme.maroon.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.iconHubBackground(),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(icon, color: AppTheme.maroon, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.cardTitle.copyWith(color: _titleColor),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: AppTheme.bodyMedium.copyWith(
                        color: _subtitleColor,
                        height: 20 / 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                color: const Color(0xFF9E9E9E),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
