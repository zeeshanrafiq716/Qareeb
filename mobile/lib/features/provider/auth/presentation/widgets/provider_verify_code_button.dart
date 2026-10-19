import 'package:flutter/material.dart';
import 'package:mobile/features/provider/auth/presentation/phone_verified_screen.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Verify Code Button Widget
/// Aligned identically to the button in the previous screen:
///
/// button layout:
///   width: 350;
///   height: 52;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 12px;
///   background: #1D8070;
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
                : (onVerify ??
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
                    }),
            style: ElevatedButton.styleFrom(
              backgroundColor: ProviderColors.primaryButton, // #1D8070
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0), // border-radius: 12px
              ),
              padding: EdgeInsets.zero,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.0,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // content: Verify Code (Inter 500 Medium 14px line-height 22px #FFFFFF)
                      Text(
                        'Verify Code',
                        style: ProviderTextStyles.continueButtonText,
                      ),

                      // gap: 12px;
                      const SizedBox(width: designGap),

                      // arrow icon: width: 14; height: 12; border: 1.5px solid #FFFFFF
                      const _VerifyArrowWidget(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _VerifyArrowWidget extends StatelessWidget {
  const _VerifyArrowWidget();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(14.0, 12.0),
      painter: _VerifyArrowPainter(),
    );
  }
}

class _VerifyArrowPainter extends CustomPainter {
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
