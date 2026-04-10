import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/user_role.dart';
import '../providers/user_role_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/language_picker_sheet.dart';

/// Settings list — aligned with app design system.
class SettingsScreenVisitor extends StatelessWidget {
  const SettingsScreenVisitor({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    String roleLabel(UserRole r) {
      switch (r) {
        case UserRole.visitor:
          return AppStrings.tr(context, 'roleVisitor');
        case UserRole.municipalityCrew:
          return AppStrings.tr(context, 'roleMunicipalityCrew');
        case UserRole.ministryMunicipality:
          return AppStrings.tr(context, 'roleMinistryMunicipality');
        case UserRole.admin:
          return AppStrings.tr(context, 'roleAdmin');
        case UserRole.superAdmin:
          return AppStrings.tr(context, 'roleSuperAdmin');
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
        title: Text(AppStrings.tr(context, 'settings'), style: AppTheme.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.settings, size: AppIcons.sizeLg, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          Divider(height: 1, color: AppTheme.divider()),
          _SettingsTile(
            title: AppStrings.tr(context, 'mySettings'),
            onTap: () => context.push('/settings/profile'),
          ),
          Divider(height: 1, color: AppTheme.divider()),
          _SettingsTile(
            title: AppStrings.tr(context, 'chooseLanguage'),
            onTap: () => showLanguagePickerSheet(context),
          ),
          Divider(height: 1, color: AppTheme.divider()),
          _SettingsTile(
            title: AppStrings.tr(context, 'accessibilityPortal'),
            subtitle: AppStrings.tr(context, 'accessibilityHelp'),
            onTap: () => context.push('/accessibility-settings'),
          ),
          Divider(height: 1, color: AppTheme.divider()),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppTheme.spaceMd, 12, AppTheme.spaceMd, 4),
            child: Text(AppStrings.tr(context, 'userRole'), style: AppTheme.labelMuted(0.65)),
          ),
          Consumer<UserRoleProvider>(
            builder: (context, ur, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
                child: DropdownButtonFormField<UserRole>(
                  value: ur.role,
                  decoration: AppTheme.inputDecoration(hintText: ''),
                  items: UserRole.values
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(roleLabel(r)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) ur.setRole(v);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: AppTheme.divider()),
          _SettingsTile(
            title: AppStrings.tr(context, 'termsAndConditions'),
            onTap: () {},
          ),
          Divider(height: 1, color: AppTheme.divider()),
          _SettingsTile(
            title: AppStrings.tr(context, 'privacyPolicy'),
            onTap: () {},
          ),
          Divider(height: 1, color: AppTheme.divider()),
          _SettingsTile(
            title: AppStrings.tr(context, 'logout'),
            onTap: () => _showLogoutScreen(context),
          ),
          Divider(height: 1, color: AppTheme.divider()),
        ],
      ),
    );
  }

  void _showLogoutScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => _LogoutConfirmScreen(
          onCancel: () => Navigator.pop(ctx),
          onConfirm: () {
            Navigator.pop(ctx);
            context.go('/login');
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.title, required this.onTap, this.subtitle});

  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd, vertical: AppTheme.spaceLg),
      title: Text(title, style: AppTheme.cardTitle),
      subtitle: subtitle != null
          ? Text(subtitle!, style: AppTheme.labelMuted(0.65))
          : null,
      trailing: Icon(
        isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
        color: AppTheme.textSecondary(0.6),
        size: 24,
      ),
      onTap: onTap,
    );
  }
}

/// Full-screen logout confirmation per Figma 166:25269.
class _LogoutConfirmScreen extends StatelessWidget {
  const _LogoutConfirmScreen({required this.onCancel, required this.onConfirm});

  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.maroon,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.tr(context, 'sureLogout'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 22 / 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          AppStrings.tr(context, 'cancel'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: onConfirm,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.maroon,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          AppStrings.tr(context, 'confirmLogout'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
