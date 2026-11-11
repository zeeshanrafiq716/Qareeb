import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_animated_button.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Change Phone Number Button Widget
/// Implements exact Figma branding specifications:
///
/// chnge button layout:
///   width: 350;
///   height: 52;
///   border-radius: 12px;
///   background: #F2F5F4;
///
/// content: Change Phone Number
///   font-family: Inter; font-weight: 500 (Medium); font-size: 14px;
///   line-height: 22px;
///   color: #1C2926;
class ProviderChangePhoneButton extends StatelessWidget {
  final VoidCallback? onTap;

  const ProviderChangePhoneButton({
    super.key,
    this.onTap,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 52.0;
  static const double designGap = 12.0;

  @override
  Widget build(BuildContext context) {
    return ProviderAnimatedButton(
      height: designHeight,
      backgroundColor: const Color(0xFF2D2A3D),
      foregroundColor: Colors.white,
      isPrimary: false,
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _BackArrowWidget(),
          const SizedBox(width: designGap),
          Text(
            context.l10n.changePhoneNumber,
            style: ProviderTextStyles.changePhoneButtonText,
          ),
        ],
      ),
    );
  }
}

class _BackArrowWidget extends StatelessWidget {
  const _BackArrowWidget();

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: Directionality.of(context) == TextDirection.rtl,
      child: const CustomPaint(
        size: Size(14.0, 12.0),
        painter: _BackArrowPainter(),
      ),
    );
  }
}

/// Left back arrow painter matching Figma specifications:
/// width: 14; height: 12; angle: 0 deg; border: 1.5px solid #1C2926;
class _BackArrowPainter extends CustomPainter {
  const _BackArrowPainter();

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

    // Arrowhead pointing back (left)
    final headPath = Path()
      ..moveTo(5.5, 1.5)
      ..lineTo(0.5, midY)
      ..lineTo(5.5, size.height - 1.5);
    canvas.drawPath(headPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
