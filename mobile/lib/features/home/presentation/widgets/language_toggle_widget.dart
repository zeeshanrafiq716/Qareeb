import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/app_locale.dart';

/// Premium Language Toggle Widget with vibrant Linear Gradient branding.
/// Allows instant switching between Arabic (عربي) and English (EN).
class LanguageToggleWidget extends ConsumerWidget {
  final double height;
  final bool showIcons;

  const LanguageToggleWidget({
    super.key,
    this.height = 32.0,
    this.showIcons = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(appLocaleProvider);
    final bool isArabic = currentLocale.languageCode == 'ar';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(height / 2.0),
          border: Border.all(
            color: const Color(0xFF8B53FE).withValues(alpha: 0.22),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B53FE).withValues(alpha: 0.08),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
            const BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4.0,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Arabic option
            _buildOption(
              context: context,
              label: 'عربي',
              isSelected: isArabic,
              isArabicFont: true,
              onTap: () {
                if (!isArabic) {
                  HapticFeedback.selectionClick();
                  ref.read(appLocaleProvider.notifier).setLocale('ar');
                }
              },
            ),

            const SizedBox(width: 2.0),

            // English option
            _buildOption(
              context: context,
              label: 'EN',
              isSelected: !isArabic,
              isArabicFont: false,
              onTap: () {
                if (isArabic) {
                  HapticFeedback.selectionClick();
                  ref.read(appLocaleProvider.notifier).setLocale('en');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required bool isArabicFont,
    required VoidCallback onTap,
  }) {
    final TextStyle textStyle = isArabicFont
        ? GoogleFonts.cairo(
            fontSize: 11.0,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF566663),
            height: 1.15,
          )
        : GoogleFonts.inter(
            fontSize: 11.0,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF566663),
            height: 1.15,
            letterSpacing: 0.2,
          );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        height: height - 5.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular((height - 5.0) / 2.0),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFF8B53FE), // Brand Primary Purple
                    Color(0xFFA67AFE), // Brand Soft Glow Purple
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF8B53FE).withValues(alpha: 0.35),
                    blurRadius: 6.0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: textStyle,
          maxLines: 1,
        ),
      ),
    );
  }
}
