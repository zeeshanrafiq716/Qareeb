import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Premium Animated Language Toggle Widget
/// Features a smooth sliding pill indicator with springy physics,
/// vibrant purple gradient branding, and haptic feedback.
class ProviderAnimatedLanguageToggle extends ConsumerStatefulWidget {
  final double width;
  final double height;

  const ProviderAnimatedLanguageToggle({
    super.key,
    this.width = 138.0,
    this.height = 36.0,
  });

  const ProviderAnimatedLanguageToggle.compact({
    super.key,
    this.width = 96.0,
    this.height = 30.0,
  });

  @override
  ConsumerState<ProviderAnimatedLanguageToggle> createState() =>
      _ProviderAnimatedLanguageToggleState();
}

class _ProviderAnimatedLanguageToggleState
    extends ConsumerState<ProviderAnimatedLanguageToggle> {
  bool _isPressed = false;

  void _switchLanguage(bool toArabic) {
    HapticFeedback.selectionClick();
    ProviderTextStyles.isArabic = toArabic;
    ref.read(appLocaleProvider.notifier).setLocale(toArabic ? 'ar' : 'en');
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(appLocaleProvider);
    final bool isArabic = currentLocale.languageCode == 'ar';

    final double pad = widget.height <= 32.0 ? 2.5 : 3.0;
    final double pillWidth = (widget.width - (pad * 2)) / 2.0;
    final double pillHeight = widget.height - (pad * 2);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeInOut,
          child: Container(
            width: widget.width,
            height: widget.height,
            padding: EdgeInsets.all(pad),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(widget.height / 2.0),
              border: Border.all(
                color: const Color(0xFF8B53FE).withValues(alpha: 0.28),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B53FE).withValues(alpha: 0.16),
                  blurRadius: 12.0,
                  offset: const Offset(0, 3),
                ),
                const BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 4.0,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 1. Sliding Animated Pill Background (Locked to LTR for precise left/right geometry)
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    alignment: isArabic
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      width: pillWidth,
                      height: pillHeight,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF8B53FE), // Brand Primary Purple
                            Color(0xFFA67AFE), // Brand Soft Glow Purple
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                            BorderRadius.circular(pillHeight / 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B53FE)
                                .withValues(alpha: 0.40),
                            blurRadius: 8.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Interactive Options (Arabic on Left, English on Right)
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: [
                      // Arabic Option
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (!isArabic) _switchLanguage(true);
                          },
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              style: GoogleFonts.cairo(
                                fontSize: widget.height <= 32.0 ? 10.5 : 12.0,
                                fontWeight: isArabic
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isArabic
                                    ? Colors.white
                                    : const Color(0xFF566663),
                                height: 1.15,
                              ),
                              child: const Text('عربي'),
                            ),
                          ),
                        ),
                      ),

                      // English Option
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (isArabic) _switchLanguage(false);
                          },
                          child: Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              style: GoogleFonts.inter(
                                fontSize: widget.height <= 32.0 ? 10.5 : 12.0,
                                fontWeight: !isArabic
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: !isArabic
                                    ? Colors.white
                                    : const Color(0xFF566663),
                                height: 1.15,
                                letterSpacing: 0.3,
                              ),
                              child: const Text('EN'),
                            ),
                          ),
                        ),
                      ),
                    ],
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
