import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/presentation/vehicle_service_details_screen.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_animated_button.dart';
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
    const Color backgroundColor = Color(0xFF2D2A3D);

    final Color foregroundColor = Colors.white;

    final TextStyle textStyle = isPrimary
        ? ProviderTextStyles.continueButtonText
        : ProviderTextStyles.backToHomeDarkButtonText;

    return ProviderAnimatedButton(
      width: width,
      height: height,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      isLoading: isLoading,
      isPrimary: isPrimary,
      text: title ?? context.l10n.continueButtonText,
      textStyle: textStyle,
      icon: icon ?? _ContinueArrowWidget(color: foregroundColor),
      onTap: onTap ?? () => _defaultOnTap(context),
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
