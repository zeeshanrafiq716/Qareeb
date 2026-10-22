import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Security Notice Row Widget
/// Implements exact Figma branding specifications:
///
/// next row text branding :
///   width: 186.8000030517578;
///   height: 16;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 12px;
///
/// lock icon branding on left side:
///   width: 12.800000190734863;
///   height: 16;
///   angle: 0 deg;
///   opacity: 1;
///   background: #566663;
///
/// content: Your Number is safe with us.
///   width: 162;
///   height: 9;
///   angle: 0 deg;
///   opacity: 1;
///   font-family: Inter;
///   font-weight: 400;
///   font-style: Regular;
///   font-size: 12px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 100%;
///   letter-spacing: 0px;
///   color: #566663;
class ProviderSecurityNoticeRow extends StatelessWidget {
  const ProviderSecurityNoticeRow({super.key});

  static const double designWidth = 186.8000030517578;
  static const double designHeight = 16.0;
  static const double lockWidth = 12.800000190734863;
  static const double designGap = 12.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        // Removed fixed-width SizedBox so Arabic text can expand without clipping
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // lock icon branding on left side: width: 12.8; height: 16; color: #566663;
            SizedBox(
              width: lockWidth,
              height: designHeight,
              child: const CustomPaint(
                painter: _LockIconPainter(),
              ),
            ),

            const SizedBox(width: designGap), // gap: 12px

            // content: Your Number is safe with us. (Inter 400 Regular 12px #566663)
            Flexible(
              child: Text(
                context.l10n.numberSafeWithUs,
                style: ProviderTextStyles.securityNotice,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Official Vector Lock Icon Painter matching exact Figma specifications:
/// width: 12.8; height: 16; color: #566663;
class _LockIconPainter extends CustomPainter {
  const _LockIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = ProviderColors.dropdownBorder // #566663
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final shacklePaint = Paint()
      ..color = ProviderColors.dropdownBorder // #566663
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // 1. Shackle (arched loop)
    final double shackleW = 7.6;
    final double shackleLeft = (size.width - shackleW) / 2;
    final double shackleRight = shackleLeft + shackleW;
    final shacklePath = Path()
      ..moveTo(shackleLeft, 7.0)
      ..lineTo(shackleLeft, 4.0)
      ..arcToPoint(
        Offset(shackleRight, 4.0),
        radius: Radius.circular(shackleW / 2),
      )
      ..lineTo(shackleRight, 7.0);
    canvas.drawPath(shacklePath, shacklePaint);

    // 2. Lock Body (rounded rectangle)
    final bodyRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.4, 6.5, size.width - 0.8, size.height - 6.5),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(bodyRRect, bodyPaint);

    // 3. Keyhole cutout (white dot and slot)
    final keyholePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, 10.2), 0.9, keyholePaint);
    canvas.drawRect(
      Rect.fromLTWH(size.width / 2 - 0.5, 10.2, 1.0, 2.2),
      keyholePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
