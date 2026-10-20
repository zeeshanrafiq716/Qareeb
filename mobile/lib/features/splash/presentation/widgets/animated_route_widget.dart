import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedRouteWidget extends StatefulWidget {
  final double progress;

  const AnimatedRouteWidget({
    super.key,
    this.progress = 1.0,
  });

  @override
  State<AnimatedRouteWidget> createState() => _AnimatedRouteWidgetState();
}

class _AnimatedRouteWidgetState extends State<AnimatedRouteWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void deactivate() {
    _pulseController.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    _pulseController.stop();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        return CustomPaint(
          painter: _RouteAndCarPainter(
            pulseValue: _pulseController.value,
            drawProgress: widget.progress,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _RouteAndCarPainter extends CustomPainter {
  final double pulseValue;
  final double drawProgress;

  _RouteAndCarPainter({
    required this.pulseValue,
    required this.drawProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Helper to map reference coordinates (390 x 844) to actual canvas size
    Offset p(double x, double y) => Offset(x / 390.0 * w, y / 844.0 * h);

    // Route waypoint coordinates from reference mockup
    final startPin = p(138, 330);
    final turn1 = p(176, 362);
    final turn2 = p(242, 260);
    final carPos = p(218, 185);

    // Compute route segments
    final totalWaypoints = [startPin, turn1, turn2, carPos];
    final routePath = Path()..moveTo(startPin.dx, startPin.dy);
    for (int i = 1; i < totalWaypoints.length; i++) {
      routePath.lineTo(totalWaypoints[i].dx, totalWaypoints[i].dy);
    }

    // Measure path length for partial progress animation
    final pathMetrics = routePath.computeMetrics().toList();
    if (pathMetrics.isNotEmpty) {
      final metric = pathMetrics.first;
      final currentLength = metric.length * drawProgress.clamp(0.0, 1.0);
      final extractedPath = metric.extractPath(0.0, currentLength);

      // Distance line: border: 4px solid #8B53FE
      final routePaint = Paint()
        ..color = const Color(0xFF8B53FE)
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(extractedPath, routePaint);
    }

    // Draw "You" Location Pin
    _drawUserPin(canvas, startPin);

    // Draw Vehicle at destination
    if (drawProgress > 0.4) {
      final carOpacity = ((drawProgress - 0.4) / 0.6).clamp(0.0, 1.0);
      canvas.save();
      _drawCar(canvas, carPos, carOpacity);
      canvas.restore();
    }
  }

  void _drawUserPin(Canvas canvas, Offset center) {
    // Ellipse color: background: #8B53FE;
    // 1. Radar Pulse Ring
    final pulseRadius = 12.0 + (pulseValue * 14.0);
    final pulseAlpha = (1.0 - pulseValue).clamp(0.0, 1.0) * 0.45;
    final pulsePaint = Paint()
      ..color = const Color(0xFF8B53FE).withValues(alpha: pulseAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, pulseRadius, pulsePaint);

    // 2. Outer Beacon Ellipse Circle: background: #8B53FE (with soft ambient alpha)
    final outerCirclePaint = Paint()
      ..color = const Color(0xFF8B53FE).withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 12, outerCirclePaint);

    // 3. Solid Beacon Ring: background: #8B53FE
    final ringPaint = Paint()
      ..color = const Color(0xFF8B53FE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, 9, ringPaint);

    // 4. Center Dot: background: #8B53FE
    final dotPaint = Paint()
      ..color = const Color(0xFF8B53FE)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, dotPaint);

    // 5. "You" Tooltip Tag above the pin:
    // background: #8B53FE;
    // box-shadow: 0px 1px 8px 0px #0000000F;
    final tagCenter = Offset(center.dx, center.dy - 26);
    const tagWidth = 36.0;
    const tagHeight = 20.0;
    const radius = 5.0;

    final tagRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: tagCenter, width: tagWidth, height: tagHeight),
      const Radius.circular(radius),
    );

    // Tiny pointer triangle towards pin
    final pointerPath = Path()
      ..moveTo(tagCenter.dx - 4, tagCenter.dy + (tagHeight / 2))
      ..lineTo(tagCenter.dx + 4, tagCenter.dy + (tagHeight / 2))
      ..lineTo(tagCenter.dx, tagCenter.dy + (tagHeight / 2) + 4)
      ..close();

    // Box-shadow: 0px 1px 8px 0px #0000000F
    canvas.save();
    canvas.translate(0, 1.0);
    final shadowPaint = Paint()
      ..color = const Color(0x0F000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    canvas.drawRRect(tagRect, shadowPaint);
    canvas.drawPath(pointerPath, shadowPaint);
    canvas.restore();

    // Tag body: background: #8B53FE
    final badgePaint = Paint()..color = const Color(0xFF8B53FE);
    canvas.drawRRect(tagRect, badgePaint);
    canvas.drawPath(pointerPath, badgePaint);

    // Text "You"
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'You',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        tagCenter.dx - (textPainter.width / 2),
        tagCenter.dy - (textPainter.height / 2),
      ),
    );
  }

  void _drawCar(Canvas canvas, Offset pos, double opacity) {
    canvas.translate(pos.dx, pos.dy);
    // Align car along the incoming road heading (~ -22 degrees)
    canvas.rotate(-22 * math.pi / 180);

    final carScale = 1.0;
    canvas.scale(carScale, carScale);

    // Car shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-12, -24, 24, 48),
        const Radius.circular(8),
      ),
      shadowPaint,
    );

    // 1. Car Purple Shade Chassis Body
    final bodyPaint = Paint()
      ..color = const Color(0xFF8B53FE).withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    final bodyRect = RRect.fromRectAndCorners(
      const Rect.fromLTWH(-11, -23, 22, 46),
      topLeft: const Radius.circular(7),
      topRight: const Radius.circular(7),
      bottomLeft: const Radius.circular(6),
      bottomRight: const Radius.circular(6),
    );
    canvas.drawRRect(bodyRect, bodyPaint);
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = const Color(0xFF6B35DC).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // 2. Side Mirrors (Purple shade)
    final mirrorPaint = Paint()..color = const Color(0xFFA57CFF).withValues(alpha: opacity);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-14, -13, 3, 7),
        const Radius.circular(1.5),
      ),
      mirrorPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(11, -13, 3, 7),
        const Radius.circular(1.5),
      ),
      mirrorPaint,
    );

    // 3. Panoramic Glass Roof / Windshields (Deep violet tinted glass)
    final glassPaint = Paint()
      ..color = const Color(0xFF2E1756).withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    // Windshield (front)
    final frontGlass = RRect.fromRectAndCorners(
      const Rect.fromLTWH(-8, -14, 16, 8),
      topLeft: const Radius.circular(3),
      topRight: const Radius.circular(3),
      bottomLeft: const Radius.circular(2),
      bottomRight: const Radius.circular(2),
    );
    canvas.drawRRect(frontGlass, glassPaint);

    // Roof Center
    final roofCenter = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-7, -4, 14, 13),
      const Radius.circular(2),
    );
    canvas.drawRRect(roofCenter, glassPaint);

    // Rear Windshield
    final rearGlass = RRect.fromRectAndCorners(
      const Rect.fromLTWH(-8, 11, 16, 6),
      topLeft: const Radius.circular(2),
      topRight: const Radius.circular(2),
      bottomLeft: const Radius.circular(3),
      bottomRight: const Radius.circular(3),
    );
    canvas.drawRRect(rearGlass, glassPaint);

    // 4. Electric Accent Stripe on Hood (Lavender highlight)
    final accentPaint = Paint()
      ..color = const Color(0xFFE4D5FF).withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-6, -21, 12, 3),
        const Radius.circular(1.5),
      ),
      accentPaint,
    );

    // 5. Headlight glow dots (Crisp bright headlights)
    final lightPaint = Paint()
      ..color = const Color(0xFFF3EDFF).withValues(alpha: opacity * 0.95)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(-8, -21), 1.6, lightPaint);
    canvas.drawCircle(const Offset(8, -21), 1.6, lightPaint);
  }

  @override
  bool shouldRepaint(covariant _RouteAndCarPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.drawProgress != drawProgress;
  }
}
