import 'package:flutter/material.dart';
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
    const double trackWidth = 160.0;
    const double trackHeight = 6.0;
    const double pillWidth = 76.0;
    const double maxSlide = trackWidth - pillWidth; // 84.0 px slide range

    return SizedBox(
      width: 350.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Indicator bar layout: 160 x 6, border-radius: 100px
          Container(
            width: trackWidth,
            height: trackHeight,
            decoration: BoxDecoration(
              color: const Color(0xFF2C3C37),
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
                                color: ProviderColors.mintAccent, // #9FFFCB
                                borderRadius: BorderRadius.circular(100.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: ProviderColors.mintGlow.withValues(alpha: 0.40),
                                    blurRadius: 4.0,
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
                        color: ProviderColors.mintAccent, // #9FFFCB
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 12.0), // gap: 12px
          // Status text: Getting things ready... (12px, #E0E0E0)
          SizedBox(
            width: 350.0,
            child: Text(
              'Getting things ready...',
              textAlign: TextAlign.center,
              style: ProviderTextStyles.indicatorStatus,
            ),
          ),
        ],
      ),
    );
  }
}
