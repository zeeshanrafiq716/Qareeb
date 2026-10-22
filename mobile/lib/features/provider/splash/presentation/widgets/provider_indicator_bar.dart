import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Splash Screen Indicator Bar Widget
/// Implements exact Figma branding specifications:
///
/// indicator bar:
///   width: 350; height: 27; top: 753px; left: 20px; angle: 0 deg; opacity: 1; gap: 12px;
///
/// indicator bar layout:
///   width: 160; height: 6; angle: 0 deg; opacity: 1; border-radius: 100px;
///
/// inner branding:
///   width: 76; height: 6; left: 95px; angle: 0 deg; opacity: 1;
///   border-radius: 100px; background: #9FFFCB;
///
/// content: Getting things ready...
///   width: 350; height: 9; angle: 0 deg; opacity: 1;
///   font-family: Inter; font-weight: 400 (Regular); font-size: 12px;
///   leading-trim: CAP_HEIGHT; line-height: 100%; letter-spacing: 0%;
///   text-align: center; color: #E0E0E0;
class ProviderIndicatorBar extends StatefulWidget {
  final bool animate;

  const ProviderIndicatorBar({
    super.key,
    this.animate = true,
  });

  @override
  State<ProviderIndicatorBar> createState() => _ProviderIndicatorBarState();
}

class _ProviderIndicatorBarState extends State<ProviderIndicatorBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Subtle smooth oscillation between 0.0 and 1.0
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double trackWidth = 140.0;
    const double trackHeight = 5.0;
    const double pillWidth = 60.0;
    const double maxSlide = trackWidth - pillWidth; // 80.0 px slide range

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Indicator bar track: 140 x 5, border-radius: 100px
        Container(
          width: trackWidth,
          height: trackHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB), // clean light grey track
            borderRadius: BorderRadius.circular(100.0),
          ),
          child: widget.animate
              ? AnimatedBuilder(
                  animation: _animation,
                  builder: (context, _) {
                    return Stack(
                      children: [
                        Positioned(
                          left: _animation.value * maxSlide,
                          top: 0.0,
                          child: Container(
                            width: pillWidth,
                            height: trackHeight,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B53FE), // background: #8B53FE
                              borderRadius: BorderRadius.circular(100.0),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8B53FE).withValues(alpha: 0.35),
                                  blurRadius: 6.0,
                                  spreadRadius: 0.5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                )
              : Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: pillWidth,
                    height: trackHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B53FE), // background: #8B53FE
                      borderRadius: BorderRadius.circular(100.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B53FE).withValues(alpha: 0.35),
                          blurRadius: 6.0,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 10.0), // gap: 10px
        // Status text: Getting things ready... (Arabic: جارٍ تجهيز كل شيء...)
        Text(
          context.l10n.providerGettingThingsReady,
          textAlign: TextAlign.center,
          style: ProviderTextStyles.indicatorStatus,
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
        ),
      ],
    );
  }
}
