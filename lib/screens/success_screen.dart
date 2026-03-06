import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_strings.dart';

/// Success overlay screens per Figma 166:22182, 166:22353, 166:25100.
/// Maroon background, white text, 32px gap, Back button white/black.
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.messageKey, this.popTo});

  final String messageKey;
  final String? popTo;

  static const _maroon = Color(0xFF8E1737);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _maroon,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.tr(context, messageKey),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 22 / 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      if (popTo != null) {
                        context.go(popTo!);
                      } else {
                        context.pop();
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      AppStrings.tr(context, 'back'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 22 / 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
