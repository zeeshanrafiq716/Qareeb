import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/presentation/phone_verified_screen.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_animated_button.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Verify Code Button Widget
/// Aligned identically to the button in the previous screen:
///
/// button layout:
///   width: 350;
///   height: 52;
///   border-radius: 12px;
///   background: #1D8070 / #8B53FE;
///
/// content: Verify Code
///   font-family: Inter; font-weight: 500 (Medium); font-size: 14px;
///   line-height: 22px; color: #FFFFFF;
///
/// arrow icon:
///   width: 14; height: 12; border: 1.5px solid #FFFFFF;
class ProviderVerifyCodeButton extends StatelessWidget {
  final VoidCallback? onVerify;
  final bool isLoading;

  const ProviderVerifyCodeButton({
    super.key,
    this.onVerify,
    this.isLoading = false,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 52.0;
  static const double designGap = 12.0;

  @override
  Widget build(BuildContext context) {
    return ProviderAnimatedButton(
      height: designHeight,
      isLoading: isLoading,
      backgroundColor: ProviderColors.primaryButton,
      onTap: onVerify ??
          () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, _, _) => const PhoneVerifiedScreen(),
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
          },
      text: context.l10n.verifyCode,
      textStyle: ProviderTextStyles.continueButtonText,
      icon: const _VerifyArrowWidget(),
    );
  }
}

class _VerifyArrowWidget extends StatelessWidget {
  const _VerifyArrowWidget();

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: Directionality.of(context) == TextDirection.rtl,
      child: const CustomPaint(
        size: Size(14.0, 12.0),
        painter: _VerifyArrowPainter(),
      ),
    );
  }
}

class _VerifyArrowPainter extends CustomPainter {
  const _VerifyArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
