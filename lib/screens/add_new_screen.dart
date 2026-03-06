import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';

/// Add New (deceased request) — aligned with app design system.
class AddNewScreen extends StatefulWidget {
  const AddNewScreen({super.key});

  @override
  State<AddNewScreen> createState() => _AddNewScreenState();
}

class _AddNewScreenState extends State<AddNewScreen> {
  final _nameController = TextEditingController();
  final _qidController = TextEditingController();
  final _ageController = TextEditingController();
  final _yearController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _qidController.dispose();
    _ageController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(isRtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppStrings.tr(context, 'addNew'),
          style: AppTheme.appBarTitle,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LabeledField(
              label: AppStrings.tr(context, 'name'),
              hint: AppStrings.tr(context, 'enterFullName'),
              controller: _nameController,
            ),
            _LabeledField(
              label: 'QID',
              hint: AppStrings.tr(context, 'enterQidShort'),
              controller: _qidController,
              keyboardType: TextInputType.number,
            ),
            _LabeledField(
              label: AppStrings.tr(context, 'age'),
              hint: AppStrings.tr(context, 'enterAge'),
              controller: _ageController,
              keyboardType: TextInputType.number,
            ),
            _LabeledField(
              label: AppStrings.tr(context, 'yearOfDeath'),
              hint: AppStrings.tr(context, 'selectYear'),
              controller: _yearController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.tr(context, 'uploadDeathCertificate'),
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: AppTheme.spaceXs),
            TextField(
              readOnly: true,
              style: AppTheme.bodyMedium,
              decoration: AppTheme.inputDecoration(hintText: AppStrings.tr(context, 'uploadDocument')),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.cardMuted(),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    AppStrings.tr(context, 'uploadImages'),
                    style: AppTheme.cardTitle,
                  ),
                  Positioned(
                    bottom: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        const SizedBox(width: 4),
                        ...List.generate(3, (_) => Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.tr(context, 'qrCodeMapping'),
              style: AppTheme.sectionTitle,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Container(
              height: 336,
              decoration: AppTheme.cardDecoration(),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      AppStrings.tr(context, 'qrCodeMappingData'),
                      style: AppTheme.cardTitle.copyWith(color: AppTheme.textSecondary(0.6)),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spaceXs),
                      decoration: BoxDecoration(
                        color: AppTheme.cardMuted(),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(AppTheme.radiusSm),
                          topLeft: Radius.circular(AppTheme.radiusSm),
                        ),
                      ),
                      child: Text(
                        AppStrings.tr(context, 'useQrEmergencyInfo'),
                        style: AppTheme.labelMedium.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.pop(),
                style: AppTheme.outlinedButtonStyle(),
                child: Text(AppStrings.tr(context, 'cancel'), style: AppTheme.button),
              ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.push('/success?msg=thankYouSubmission'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.maroon,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                ),
                child: Text(AppStrings.tr(context, 'submitRequest'), style: AppTheme.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: AppTheme.spaceXs),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppTheme.bodyMedium,
            decoration: AppTheme.inputDecoration(hintText: hint).copyWith(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                borderSide: BorderSide(color: AppTheme.border()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
