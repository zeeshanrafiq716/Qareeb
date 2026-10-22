import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/presentation/vehicle_service_details_screen.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Continue Button Widget
/// Implements exact Figma branding specifications following previous screen buttons:
///
/// button layout:
///   width: 350 (or 100% / double.infinity);
///   height: 52;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 12px;
///   background: #1D8070;
///
/// content layout:
///   gap: 12px;
///   content: Continue (Inter 500 Medium 14px line-height 22px #FFFFFF)
///
/// arrow icon branding:
///   width: 14;
///   height: 12;
///   border-width: 1.5px;
///   border: 1.5px solid #FFFFFF;
class ProviderContinueButton extends StatelessWidget {
  final String? title;
  final VoidCallback? onTap;
  final Widget? icon;
  final double? width;
  final double height;
  final bool isLoading;
  final bool isPrimary;

  const ProviderContinueButton({
    super.key,
    this.title,
    this.onTap,
    this.icon,
    this.width = double.infinity,
    this.height = 52.0,
    this.isLoading = false,
    this.isPrimary = true,
  });

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
        ? ProviderTextStyles.continueButtonText
        : ProviderTextStyles.backToHomeDarkButtonText;

    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: width,
          height: height,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : (onTap ?? () => _defaultOnTap(context)),
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
                      // content: Continue
                      Text(
                        title ?? context.l10n.continueButtonText,
                        style: textStyle,
                      ),

                      // gap: 12px;
                      const SizedBox(width: designGap),

                      // arrow icon branding: width: 14; height: 12; border: 1.5px solid #FFFFFF
                      icon ?? _ContinueArrowWidget(color: foregroundColor),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _defaultOnTap(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const VehicleServiceDetailsScreen(),
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

/// Forward Arrow Widget matching user screenshot and previous screen buttons:
/// width: 14; height: 12; border: 1.5px solid #FFFFFF
class _ContinueArrowWidget extends StatelessWidget {
  final Color color;

  const _ContinueArrowWidget({
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(14.0, 12.0),
      painter: _ContinueArrowPainter(color: color),
    );
  }
}

/// Vector Painter for Forward Arrow (horizontal line with angled head pointing right)
class _ContinueArrowPainter extends CustomPainter {
  final Color color;

  const _ContinueArrowPainter({
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
      ..moveTo(size.width - 5.5, 1.5)
      ..lineTo(size.width - 0.5, midY)
      ..lineTo(size.width - 5.5, size.height - 1.5);
    canvas.drawPath(headPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ContinueArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}
