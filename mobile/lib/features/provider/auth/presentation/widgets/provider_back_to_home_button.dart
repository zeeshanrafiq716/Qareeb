import 'package:flutter/material.dart';
import 'package:mobile/features/provider/auth/presentation/provider_profile_details_screen.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Back to Home Button Widget
/// Implements exact Figma branding specifications following previous buttons:
///
/// button layout:
///   width: 350;
///   height: 52;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 12px;
///   background: #1D8070;
///
/// button content layout:
///   width: 123;
///   height: 22;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 12px;
///
/// content: Back to Home
///   font-family: Inter;
///   font-weight: 500 (Medium);
///   font-size: 14px;
///   line-height: 22px;
///   color: #FFFFFF;
///
/// arrow vector branding:
///   width: 16;
///   height: 12;
///   angle: 0 deg;
///   opacity: 1;
///   border-width: 1.5px;
///   border: 1.5px solid #FFFFFF;
class ProviderBackToHomeButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Widget? icon;
  final bool isPrimary;
  final bool isLoading;

  const ProviderBackToHomeButton({
    super.key,
    this.title = 'Back to Home',
    this.onTap,
    this.icon,
    this.isPrimary = true,
    this.isLoading = false,
  });

  /// Secondary style constructor matching secondary button branding
  /// (background: #F2F5F4, text: #1C2926)
  const ProviderBackToHomeButton.secondary({
    super.key,
    this.title = 'Back to Home',
    this.onTap,
    this.icon,
    this.isLoading = false,
  }) : isPrimary = false;

  static const double designWidth = 350.0;
  static const double designHeight = 52.0;
  static const double designGap = 12.0;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isPrimary
        ? ProviderColors.primaryButton // #1D8070
        : ProviderColors.inputBackground; // #F2F5F4

    final Color foregroundColor = isPrimary
        ? Colors.white
        : ProviderColors.cardTitle; // #1C2926

    final TextStyle textStyle = isPrimary
        ? ProviderTextStyles.backToHomeButtonText
        : ProviderTextStyles.backToHomeDarkButtonText;

    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: designWidth,
          height: designHeight,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : (onTap ?? () => _defaultNavigation(context)),
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0), // border-radius: 12px
              ),
              padding: EdgeInsets.zero,
            ),
            child: isLoading
                ? SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      color: foregroundColor,
                      strokeWidth: 2.0,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // content: Back to Home (Inter 500 Medium 14px line-height 22px #FFFFFF)
                      Text(
                        title,
                        style: textStyle,
                      ),

                      // gap: 12px;
                      const SizedBox(width: designGap),

                      // arrow icon: width: 16; height: 12; border: 1.5px solid #FFFFFF
                      icon ?? _BackToHomeArrowWidget(color: foregroundColor),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _defaultNavigation(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const ProviderProfileDetailsScreen(),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}

/// Forward Arrow Widget matching user screenshot and Figma specifications:
/// width: 16; height: 12; border: 1.5px solid #FFFFFF
class _BackToHomeArrowWidget extends StatelessWidget {
  final Color color;

  const _BackToHomeArrowWidget({
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(16.0, 12.0),
      painter: _BackToHomeArrowPainter(color: color),
    );
  }
}

/// Vector Painter for Forward Arrow (horizontal line with angled head pointing right)
class _BackToHomeArrowPainter extends CustomPainter {
  final Color color;

  const _BackToHomeArrowPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double midY = size.height / 2;

    // Horizontal stem from left to right
    final shaftPath = Path()
      ..moveTo(0.5, midY)
      ..lineTo(size.width - 0.5, midY);
    canvas.drawPath(shaftPath, paint);

    // Arrowhead pointing forward (right)
    final headPath = Path()
      ..moveTo(size.width - 5.5, 1.2)
      ..lineTo(size.width - 0.5, midY)
      ..lineTo(size.width - 5.5, size.height - 1.2);
    canvas.drawPath(headPath, paint);
  }

  @override
  bool shouldRepaint(covariant _BackToHomeArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}
