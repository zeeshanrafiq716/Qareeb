import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Provider Phone Verified Success Badge Widget
/// Implements exact Figma branding specifications:
///
/// Overall Bounds:
///   width: 174;
///   height: 80;
///   angle: 0 deg;
///   opacity: 1;
///
/// left stickers layout:
///   width: 41.00042724609375;
///   height: 74.57072448730469;
///   angle: 0 deg;
///   opacity: 1;
///   top: 3px;
///   left: 88px; (in 350px container; 0px relative to 174px badge)
///
/// circle layout:
///   width: 80;
///   height: 80;
///   angle: 0 deg;
///   opacity: 1;
///   left: 135px; (in 350px container; 47px relative to 174px badge)
///   border: 0.5px solid #E0FFEE;
///
/// circle shadow layout:
///   width: 62.60871124267578;
///   height: 62.60871124267578;
///   angle: 0 deg;
///   opacity: 1;
///   top: 9px;
///   left: 144px; (in 350px container; 56px relative to 174px badge)
///
/// circle layut:
///   width: 48;
///   height: 48;
///   angle: 0 deg;
///   opacity: 1;
///   top: 16px;
///   left: 151px; (in 350px container; 63px relative to 174px badge)
///   background: #1D8070;
///
/// right layout:
///   width: 41.00042724609375;
///   height: 74.57072448730469;
///   angle: -180 deg;
///   opacity: 1;
///   top: 3px;
///   left: 221px; (in 350px container; 133px relative to 174px badge)
class ProviderPhoneVerifiedSuccessBadge extends StatelessWidget {
  const ProviderPhoneVerifiedSuccessBadge({super.key});

  static const double designWidth = 174.0;
  static const double designHeight = 80.0;

  // Stickers specifications
  static const double stickersWidth = 41.00042724609375;
  static const double stickersHeight = 74.57072448730469;
  static const double stickersTop = 3.0;
  static const double leftStickersLeft = 88.0; // In 350px container
  static const double rightStickersLeft = 221.0; // In 350px container

  // Circles specifications
  static const double outerCircleSize = 80.0;
  static const double outerCircleLeft = 135.0; // In 350px container
  static const double shadowCircleSize = 62.60871124267578;
  static const double shadowCircleTop = 9.0;
  static const double shadowCircleLeft = 144.0; // In 350px container
  static const double innerCircleSize = 48.0;
  static const double innerCircleTop = 16.0;
  static const double innerCircleLeft = 151.0; // In 350px container

  @override
  Widget build(BuildContext context) {
    return const Opacity(
      opacity: 1.0, // opacity: 1
      child: SizedBox(
        width: designWidth,
        height: designHeight,
        child: CustomPaint(
          size: Size(designWidth, designHeight),
          painter: _PhoneVerifiedSuccessBadgePainter(),
        ),
      ),
    );
  }
}

/// Fallback CustomPainter implementing exact circle layers and radiating rays
class _PhoneVerifiedSuccessBadgePainter extends CustomPainter {
  const _PhoneVerifiedSuccessBadgePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2.0;
    final double cy = size.height / 2.0;

    // 1. circle layout: width: 80; height: 80; border: 0.5px solid #E9E0FE;
    final outerCircleFill = Paint()
      ..color = const Color(0xFFF0EAFE).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 40.0, outerCircleFill);

    final outerCircleBorder = Paint()
      ..color = const Color(0xFFE9E0FE) // border: 0.5px solid #E9E0FE
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawCircle(Offset(cx, cy), 40.0, outerCircleBorder);

    // 2. circle shadow layout: width: 62.61; height: 62.61;
    final shadowCirclePaint = Paint()
      ..color = const Color(0xFFEAE0FE).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 31.30435, shadowCirclePaint);

    // 3. inner branding: width: 48; height: 48; background: #8B53FE;
    final innerCirclePaint = Paint()
      ..color = const Color(0xFF8B53FE) // background: #8B53FE
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), 24.0, innerCirclePaint);

    // 4. Centered White Checkmark
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final checkPath = Path();
    checkPath.moveTo(cx - 7.5, cy - 0.5);
    checkPath.lineTo(cx - 2.5, cy + 5.5);
    checkPath.lineTo(cx + 8.5, cy - 5.5);
    canvas.drawPath(checkPath, checkPaint);

    // 5. Radiating celebration sparks (left stickers at top: 3, right stickers at top: 3 angle: -180 deg)
    void drawRay(double angleDeg, double innerR, double outerR, Color color) {
      final rad = angleDeg * math.pi / 180.0;
      final rayPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx + innerR * math.cos(rad), cy + innerR * math.sin(rad)),
        Offset(cx + outerR * math.cos(rad), cy + outerR * math.sin(rad)),
        rayPaint,
      );
    }

    // Yellow sparks at top (left stickers and right stickers)
    drawRay(240, 42.0, 50.0, const Color(0xFFF9BD15));
    drawRay(300, 42.0, 50.0, const Color(0xFFF9BD15));

    // Mint sparks
    drawRay(205, 42.0, 50.0, const Color(0xFFA67AFE));
    drawRay(335, 42.0, 50.0, const Color(0xFFA67AFE));
    drawRay(150, 43.0, 52.0, const Color(0xFFA67AFE));
    drawRay(30, 43.0, 52.0, const Color(0xFFA67AFE));

    // Teal sparks (mid-left and mid-right)
    drawRay(175, 44.0, 53.0, const Color(0xFF8B53FE));
    drawRay(5, 44.0, 53.0, const Color(0xFF8B53FE));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
