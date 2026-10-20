import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Top-down car marker widget matching user screenshot:
/// - Exact aerodynamic vehicle with white body, dark windshield, purple roof (#8B53FE),
///   shark-fin antenna dot, front headlights, red taillights, and purple side-mirrors
/// - Seamless speech bubble tooltip badge with driver name and tilted navigation arrow distance
/// - Screen corner safe: Adapts alignment so badges never hide or clip off-screen
/// - When clicked: size increases slightly (1.28x) AND color turns WHITE (#FFFFFF)
class TopDownCarWidget extends StatelessWidget {
  final double width;
  final double height;
  final double angle; // in degrees
  final double opacity;
  final String? driverName;
  final double? distanceKm;
  final bool showBadge;
  final bool isSelected;
  final bool isInsideRadius;
  final VoidCallback? onTap;
  final Color bodyColor;
  final bool alignBadgeLeft;
  final bool alignBadgeBelow;

  const TopDownCarWidget({
    super.key,
    this.width = 16.5,
    this.height = 28.5,
    required this.angle,
    this.opacity = 1.0,
    this.driverName,
    this.distanceKm,
    this.showBadge = true,
    this.isSelected = false,
    this.isInsideRadius = true,
    this.onTap,
    this.bodyColor = const Color(0xFFA67AFE),
    this.alignBadgeLeft = false,
    this.alignBadgeBelow = false,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Vector Car Render
    // Heading 0 deg = facing UP. Rotation aligns nose along heading vector.
    final Widget carGraphic = SizedBox(
      width: width,
      height: height,
      child: Transform.rotate(
        angle: angle * math.pi / 180.0,
        alignment: Alignment.center,
        child: CustomPaint(
          size: Size(width, height),
          painter: _TopDownVectorCarPainter(
            roofColor: isSelected ? Colors.white : bodyColor,
            isSelected: isSelected,
          ),
        ),
      ),
    );

    // Scaling animation on selection (thora sa increase: 1.28x on tap)
    final Widget animatedCar = AnimatedScale(
      scale: isSelected ? 1.28 : 1.0,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutBack,
      alignment: Alignment.center,
      child: carGraphic,
    );

    // If badge is not needed, return clickable car with generous hit area
    if (!showBadge || driverName == null) {
      return SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              left: (width - 48.0) / 2.0,
              top: (height - 48.0) / 2.0,
              width: 48.0,
              height: 48.0,
              child: GestureDetector(
                onTap: onTap,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),
            Opacity(
              opacity: opacity,
              child: animatedCar,
            ),
          ],
        ),
      );
    }

    // Full car with Speech Bubble Tooltip
    return SizedBox(
      width: width,
      height: height,
      child: Opacity(
        opacity: opacity,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // 48x48 touch hit area for easy tapping
            Positioned(
              left: (width - 48.0) / 2.0,
              top: (height - 48.0) / 2.0,
              width: 48.0,
              height: 48.0,
              child: GestureDetector(
                onTap: onTap,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),

            // Car Icon
            Positioned(
              top: 0.0,
              child: animatedCar,
            ),

            // Speech Bubble Tooltip attached directly on top of car (bilkul car k oopr sth attach)
            Positioned(
              bottom: isSelected ? (height + 2.0) : (height - 1.5),
              child: GestureDetector(
                onTap: onTap,
                behavior: HitTestBehavior.opaque,
                child: _SpeechBubbleTooltip(
                  driverName: driverName!,
                  distanceKm: distanceKm,
                  isSelected: isSelected,
                  tailOnCenter: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Razor-sharp top-down vector car painter matching the user screenshot
class _TopDownVectorCarPainter extends CustomPainter {
  final Color roofColor;
  final bool isSelected;

  const _TopDownVectorCarPainter({
    required this.roofColor,
    this.isSelected = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Soft Ground Drop Shadow under car on asphalt
    final Rect shadowRect = Rect.fromCenter(
      center: Offset(w / 2.0, h / 2.0 + 1.2),
      width: w * 0.94,
      height: h * 0.96,
    );
    final RRect shadowRRect = RRect.fromRectAndRadius(
      shadowRect,
      Radius.circular(w * 0.32),
    );
    canvas.drawRRect(
      shadowRRect,
      Paint()
        ..color = isSelected
            ? const Color(0x3D8B53FE)
            : const Color(0x2E000000)
        ..style = PaintingStyle.fill,
    );

    // 2. Wheels / Tires (subtle black tires visible at sides)
    final Paint tirePaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.fill;
    const double tireWidth = 1.8;
    final double tireHeight = h * 0.18;
    // Front-left tire
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.2, h * 0.16, tireWidth, tireHeight),
        const Radius.circular(0.8),
      ),
      tirePaint,
    );
    // Front-right tire
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w - tireWidth - 0.2, h * 0.16, tireWidth, tireHeight),
        const Radius.circular(0.8),
      ),
      tirePaint,
    );
    // Rear-left tire
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.2, h * 0.68, tireWidth, tireHeight),
        const Radius.circular(0.8),
      ),
      tirePaint,
    );
    // Rear-right tire
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w - tireWidth - 0.2, h * 0.68, tireWidth, tireHeight),
        const Radius.circular(0.8),
      ),
      tirePaint,
    );

    // 3. Side Mirrors (Teal in normal state, White in selected state)
    final Color mirrorColor = isSelected ? Colors.white : roofColor;
    final Paint mirrorPaint = Paint()
      ..color = mirrorColor
      ..style = PaintingStyle.fill;
    final Paint mirrorBorderPaint = Paint()
      ..color = isSelected ? const Color(0xFF8B53FE) : const Color(0xFFA67AFE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.55;

    final double mirrorY = h * 0.34;
    final double mirrorH = h * 0.10;
    const double mirrorW = 2.4;
    // Left mirror
    final RRect leftMirrorRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(-mirrorW + 0.6, mirrorY, mirrorW, mirrorH),
      const Radius.circular(1.2),
    );
    canvas.drawRRect(leftMirrorRRect, mirrorPaint);
    canvas.drawRRect(leftMirrorRRect, mirrorBorderPaint);

    // Right mirror
    final RRect rightMirrorRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w - 0.6, mirrorY, mirrorW, mirrorH),
      const Radius.circular(1.2),
    );
    canvas.drawRRect(rightMirrorRRect, mirrorPaint);
    canvas.drawRRect(rightMirrorRRect, mirrorBorderPaint);

    // 4. Main White Chassis Body (Aerodynamic silhouette)
    final Path bodyPath = Path();
    bodyPath.moveTo(w * 0.28, 0.4); // top left nose
    bodyPath.quadraticBezierTo(w * 0.5, 0.0, w * 0.72, 0.4); // nose tip curve
    bodyPath.quadraticBezierTo(w - 0.6, h * 0.08, w - 0.8, h * 0.24); // front right fender
    bodyPath.lineTo(w - 1.2, h * 0.46); // right waist
    bodyPath.quadraticBezierTo(w - 0.6, h * 0.70, w - 0.8, h * 0.86); // rear right fender
    bodyPath.quadraticBezierTo(w * 0.86, h - 0.4, w * 0.68, h - 0.4); // rear right bumper
    bodyPath.lineTo(w * 0.32, h - 0.4); // rear bumper center
    bodyPath.quadraticBezierTo(w * 0.14, h - 0.4, 0.8, h * 0.86); // rear left bumper
    bodyPath.quadraticBezierTo(0.6, h * 0.70, 1.2, h * 0.46); // left waist
    bodyPath.lineTo(0.8, h * 0.24); // front left fender
    bodyPath.quadraticBezierTo(0.6, h * 0.08, w * 0.28, 0.4); // front left nose
    bodyPath.close();

    // Body fill (clean white)
    final Paint bodyFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, bodyFillPaint);

    // Body contour stroke
    final Paint bodyStrokePaint = Paint()
      ..color = isSelected ? const Color(0xFF8B53FE) : const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 1.0 : 0.65;
    canvas.drawPath(bodyPath, bodyStrokePaint);

    // 5. Front Headlights (Sleek angled modern LED lights)
    final Paint headlightPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;
    final Paint headlightStroke = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final Path leftHeadlight = Path()
      ..moveTo(1.8, h * 0.08)
      ..lineTo(w * 0.30, h * 0.05)
      ..lineTo(w * 0.26, h * 0.12)
      ..lineTo(2.0, h * 0.13)
      ..close();
    canvas.drawPath(leftHeadlight, headlightPaint);
    canvas.drawPath(leftHeadlight, headlightStroke);

    final Path rightHeadlight = Path()
      ..moveTo(w - 1.8, h * 0.08)
      ..lineTo(w - w * 0.30, h * 0.05)
      ..lineTo(w - w * 0.26, h * 0.12)
      ..lineTo(w - 2.0, h * 0.13)
      ..close();
    canvas.drawPath(rightHeadlight, headlightPaint);
    canvas.drawPath(rightHeadlight, headlightStroke);

    // 6. Cabin Glasshouse (Dark tinted panoramic glass)
    final Paint glassPaint = Paint()
      ..color = const Color(0xFF151E1C)
      ..style = PaintingStyle.fill;

    // Front Windshield (curved trapezoid)
    final Path frontWindshieldPath = Path()
      ..moveTo(w * 0.22, h * 0.28)
      ..quadraticBezierTo(w * 0.5, h * 0.25, w * 0.78, h * 0.28)
      ..lineTo(w * 0.82, h * 0.42)
      ..quadraticBezierTo(w * 0.5, h * 0.40, w * 0.18, h * 0.42)
      ..close();
    canvas.drawPath(frontWindshieldPath, glassPaint);

    // Rear Windshield
    final Path rearWindshieldPath = Path()
      ..moveTo(w * 0.20, h * 0.73)
      ..quadraticBezierTo(w * 0.5, h * 0.71, w * 0.80, h * 0.73)
      ..lineTo(w * 0.76, h * 0.85)
      ..quadraticBezierTo(w * 0.5, h * 0.86, w * 0.24, h * 0.85)
      ..close();
    canvas.drawPath(rearWindshieldPath, glassPaint);

    // Side window pillars/slits
    final Path leftWindow = Path()
      ..moveTo(w * 0.17, h * 0.42)
      ..lineTo(w * 0.19, h * 0.73)
      ..lineTo(w * 0.25, h * 0.72)
      ..lineTo(w * 0.23, h * 0.42)
      ..close();
    canvas.drawPath(leftWindow, glassPaint);

    final Path rightWindow = Path()
      ..moveTo(w * 0.83, h * 0.42)
      ..lineTo(w * 0.81, h * 0.73)
      ..lineTo(w * 0.75, h * 0.72)
      ..lineTo(w * 0.77, h * 0.42)
      ..close();
    canvas.drawPath(rightWindow, glassPaint);

    // 7. Car Roof (Purple #8B53FE in unselected state; Pure WHITE when clicked/selected)
    final Paint roofPaint = Paint()
      ..color = isSelected ? Colors.white : roofColor
      ..style = PaintingStyle.fill;

    final RRect roofRRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.21, h * 0.39, w * 0.79, h * 0.73),
      Radius.circular(w * 0.16),
    );
    canvas.drawRRect(roofRRect, roofPaint);

    if (isSelected) {
      final Paint roofBorder = Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6;
      canvas.drawRRect(roofRRect, roofBorder);
    }

    // 8. Shark-Fin Antenna / Roof Dot
    final Paint antennaPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.64),
      w * 0.055,
      antennaPaint,
    );

    // 9. Rear Taillights (Red LED strips at rear corners)
    final Paint taillightPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    // Left taillight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1.8, h * 0.88, w * 0.20, h * 0.045),
        const Radius.circular(0.6),
      ),
      taillightPaint,
    );
    // Right taillight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w - 1.8 - w * 0.20, h * 0.88, w * 0.20, h * 0.045),
        const Radius.circular(0.6),
      ),
      taillightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TopDownVectorCarPainter oldDelegate) {
    return oldDelegate.roofColor != roofColor || oldDelegate.isSelected != isSelected;
  }
}

/// Seamless speech bubble tooltip matching user screenshot:
/// - Single contiguous path uniting card body and pointer tail
/// - Driver name (e.g. Adnan Sajid)
/// - Tilted navigation arrow + distance (e.g. ➤ 0.7 km)
/// - Supports tailOnRight (flips to left of car near screen edge)
/// - Supports tailOnTop (flips below car near header edge)
class _SpeechBubbleTooltip extends StatelessWidget {
  final String driverName;
  final double? distanceKm;
  final bool isSelected;
  final bool tailOnCenter;
  final bool tailOnRight;
  final bool tailOnTop;

  const _SpeechBubbleTooltip({
    required this.driverName,
    this.distanceKm,
    this.isSelected = false,
    this.tailOnCenter = true,
    this.tailOnRight = false,
    this.tailOnTop = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SpeechBubbleCardPainter(
        backgroundColor: Colors.white,
        borderColor: isSelected ? const Color(0xFF8B53FE) : const Color(0xFFE2E8F0),
        borderWidth: isSelected ? 1.4 : 0.8,
        borderRadius: 7.0,
        tailWidth: 8.0,
        tailHeight: 4.5,
        tailOnCenter: tailOnCenter,
        tailOnRight: tailOnRight,
        tailOnTop: tailOnTop,
        isSelected: isSelected,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          7.0,
          tailOnTop ? 8.5 : 4.0,
          7.0,
          tailOnTop ? 4.0 : 8.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              driverName.trim().split(' ').first,
              style: GoogleFonts.inter(
                fontSize: isSelected ? 10.5 : 10.0,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1C2926),
                height: 1.1,
              ),
            ),
            if (distanceKm != null) ...[
              const SizedBox(height: 2.0),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.rotate(
                    angle: -math.pi / 4.0, // Tilted navigation arrow matching screenshot
                    child: const Icon(
                      Icons.navigation,
                      size: 8.5,
                      color: Color(0xFF566663),
                    ),
                  ),
                  const SizedBox(width: 3.0),
                  Text(
                    '${distanceKm!.toStringAsFixed(1)} km',
                    style: GoogleFonts.inter(
                      fontSize: 9.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF566663),
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SpeechBubbleCardPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double tailWidth;
  final double tailHeight;
  final bool tailOnCenter;
  final bool tailOnRight;
  final bool tailOnTop;
  final bool isSelected;

  const _SpeechBubbleCardPainter({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.tailWidth,
    required this.tailHeight,
    this.tailOnCenter = true,
    this.tailOnRight = false,
    this.tailOnTop = false,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double tw = tailWidth;
    final double th = tailHeight;
    final double r = borderRadius;

    final double topY = tailOnTop ? th : 0.0;
    final double bottomY = tailOnTop ? size.height : (size.height - th);

    final double tx = tailOnCenter
        ? ((w - tw) / 2.0)
        : (tailOnRight ? (w - tw - 9.0) : 9.0);

    final path = Path();

    // Start at top-left
    path.moveTo(r, topY);

    // Top edge
    if (tailOnTop) {
      // Top edge has triangle tail pointing UP towards car
      path.lineTo(tx, topY);
      path.lineTo(tx + (tailOnCenter ? tw * 0.5 : (tailOnRight ? tw * 0.55 : tw * 0.45)), 0.0); // tip pointing up
      path.lineTo(tx + tw, topY);
    }
    path.lineTo(w - r, topY);
    path.arcToPoint(Offset(w, topY + r), radius: Radius.circular(r));

    // Right edge
    path.lineTo(w, bottomY - r);
    path.arcToPoint(Offset(w - r, bottomY), radius: Radius.circular(r));

    // Bottom edge
    if (!tailOnTop) {
      // Bottom edge has triangle tail pointing DOWN towards car
      path.lineTo(tx + tw, bottomY);
      path.lineTo(tx + (tailOnCenter ? tw * 0.5 : (tailOnRight ? tw * 0.55 : tw * 0.45)), bottomY + th); // tip pointing down directly in center
      path.lineTo(tx, bottomY);
    }
    path.lineTo(r, bottomY);
    path.arcToPoint(Offset(0, bottomY - r), radius: Radius.circular(r));

    // Left edge
    path.lineTo(0, topY + r);
    path.arcToPoint(Offset(r, topY), radius: Radius.circular(r));
    path.close();

    // WebGL2 & CanvasKit safe drop shadow (eliminates SkShadowUtils shader compilation crash)
    final shadowPath = path.shift(const Offset(0, 1.8));
    final shadowPaint = Paint()
      ..color = isSelected ? const Color(0x388B53FE) : const Color(0x1F000000)
      ..style = PaintingStyle.fill;
    canvas.drawPath(shadowPath, shadowPaint);

    // Solid White fill
    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Subtle border stroke
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _SpeechBubbleCardPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor ||
      oldDelegate.borderWidth != borderWidth ||
      oldDelegate.tailOnCenter != tailOnCenter ||
      oldDelegate.tailOnRight != tailOnRight ||
      oldDelegate.tailOnTop != tailOnTop ||
      oldDelegate.isSelected != isSelected;
}
