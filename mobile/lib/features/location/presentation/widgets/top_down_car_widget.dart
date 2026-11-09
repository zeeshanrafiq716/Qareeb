import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_locale.dart';

/// Ultra-Premium Top-Down Car Marker Widget:
/// - Realistic luxury executive sedan with aerodynamic curves, pearl-white metallic finish,
///   sculpted hood lines, alloy wheel rims, and authentic panoramic glasshouse with optical sheen
/// - Front dual LED matrix jewel headlights with ice-blue DRL ribbons & continuous rear red neon lightbar
/// - Multi-layer diffuse ground shadow on asphalt with radiant brand-purple underglow when selected
/// - Sleek, ultra-compact luxury pill badge (capsule) with glowing emerald status dot,
///   clean driver name, and purple navigation arrow with distance
/// - Collision-resistant layout preventing overlapping clutter on the map
class TopDownCarWidget extends StatelessWidget {
  final double width;
  final double height;
  final double angle; // in degrees
  final double opacity;
  final String? driverName;
  final double? distanceKm;
  final bool showBadge;
  final bool isSelected;
  final bool isWhite;
  final bool isInsideRadius;
  final VoidCallback? onTap;
  final Color bodyColor;
  final bool alignBadgeLeft;
  final bool alignBadgeBelow;

  const TopDownCarWidget({
    super.key,
    this.width = 18.0,
    this.height = 34.0,
    required this.angle,
    this.opacity = 1.0,
    this.driverName,
    this.distanceKm,
    this.showBadge = true,
    this.isSelected = false,
    this.isWhite = false,
    this.isInsideRadius = true,
    this.onTap,
    this.bodyColor = const Color(0xFF8B53FE),
    this.alignBadgeLeft = false,
    this.alignBadgeBelow = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSel = isSelected == true;
    final bool isWh = isWhite == true;
    final bool effectiveWhite = isSel || isWh;

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
            roofColor: effectiveWhite ? Colors.white : bodyColor,
            isSelected: isSel,
            isWhite: effectiveWhite,
          ),
        ),
      ),
    );

    // Scaling animation on selection (smooth 1.20x elevation on tap)
    final Widget animatedCar = AnimatedScale(
      scale: isSel ? 1.20 : 1.0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      alignment: Alignment.center,
      child: carGraphic,
    );

    // If badge is disabled (e.g. in small provider toggle or compact icon), return the car graphic directly
    if (showBadge != true || driverName == null) {
      return SizedBox(
        width: width,
        height: height,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Opacity(
            opacity: opacity,
            child: animatedCar,
          ),
        ),
      );
    }

    // Interactive Marker layout: Compact luxury 2-line speech bubble badge + Car
    const double containerW = 66.0;
    const double containerH = 68.0;

    return SizedBox(
      width: containerW,
      height: containerH,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Opacity(
            opacity: opacity,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // 1. Luxury Floating Speech Bubble directly above car
                Positioned(
                  top: 0.0,
                  child: _PremiumSpeechBubbleBadge(
                    driverName: driverName!,
                    distanceKm: distanceKm,
                    isSelected: isSel,
                    isWhite: effectiveWhite,
                    isInsideRadius: isInsideRadius,
                  ),
                ),

                // 2. Car Icon centered directly beneath the speech bubble caret
                Positioned(
                  top: (distanceKm != null) ? 36.0 : 22.0,
                  child: animatedCar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ultra-Premium Top-Down Vector Car Painter
/// Renders an authentic luxury executive sedan with metallic reflections,
/// optical glass sheen, LED headlights, neon rear lightbar, and multi-tier ground shadows
class _TopDownVectorCarPainter extends CustomPainter {
  final Color roofColor;
  final bool isSelected;
  final bool isWhite;

  const _TopDownVectorCarPainter({
    required this.roofColor,
    this.isSelected = false,
    this.isWhite = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Multi-tier Ground Shadow (Ambient diffuse shadow + Contact shadow + Purple glow if selected)
    // Ambient diffuse shadow
    final RRect ambientShadow = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w / 2.0, h / 2.0 + 1.8),
        width: w * 0.94,
        height: h * 0.96,
      ),
      Radius.circular(w * 0.35),
    );
    canvas.drawRRect(
      ambientShadow,
      Paint()
        ..color = isSelected ? const Color(0x558B53FE) : const Color(0x30000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    // Inner contact shadow (dark core directly beneath tires/floorpan)
    final RRect contactShadow = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w / 2.0, h / 2.0 + 0.8),
        width: w * 0.86,
        height: h * 0.90,
      ),
      Radius.circular(w * 0.28),
    );
    canvas.drawRRect(
      contactShadow,
      Paint()..color = const Color(0x35000000),
    );

    // If selected, an outer luxury neon aura
    if (isSelected) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(w / 2.0, h / 2.0),
            width: w * 1.35,
            height: h * 1.25,
          ),
          Radius.circular(w * 0.5),
        ),
        Paint()
          ..color = const Color(0x388B53FE)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
      );
    }

    // 2. Tires with Alloy Wheel Rims
    final Paint tireRubber = Paint()..color = const Color(0xFF1E293B);
    final Paint alloyRim = Paint()..color = const Color(0xFF94A3B8);
    const double tireW = 2.4;
    final double tireH = h * 0.17;

    void drawWheel(double x, double y) {
      final RRect tire = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, tireW, tireH),
        const Radius.circular(1.0),
      );
      canvas.drawRRect(tire, tireRubber);
      canvas.drawLine(
        Offset(x + tireW / 2.0, y + 2.0),
        Offset(x + tireW / 2.0, y + tireH - 2.0),
        alloyRim
          ..strokeWidth = 0.8
          ..strokeCap = StrokeCap.round,
      );
    }

    drawWheel(-0.6, h * 0.16); // Front-Left
    drawWheel(w - tireW + 0.6, h * 0.16); // Front-Right
    drawWheel(-0.6, h * 0.69); // Rear-Left
    drawWheel(w - tireW + 0.6, h * 0.69); // Rear-Right

    // 3. Side Mirrors with Amber LED Indicator Slivers
    final double mirrorY = h * 0.33;
    final double mirrorH = h * 0.085;
    const double mirrorW = 2.8;

    // Left mirror
    final Path leftMirrorPath = Path()
      ..moveTo(0.8, mirrorY)
      ..lineTo(-mirrorW + 0.4, mirrorY + 1.2)
      ..quadraticBezierTo(-mirrorW, mirrorY + mirrorH * 0.6, -mirrorW + 0.8, mirrorY + mirrorH)
      ..lineTo(0.8, mirrorY + mirrorH * 0.8)
      ..close();
    canvas.drawPath(leftMirrorPath, Paint()..color = (isSelected || isWhite) ? Colors.white : const Color(0xFFF8FAFC));
    canvas.drawPath(
      leftMirrorPath,
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
    canvas.drawCircle(Offset(-mirrorW + 0.8, mirrorY + mirrorH * 0.5), 0.65, Paint()..color = const Color(0xFFF59E0B));

    // Right mirror
    final Path rightMirrorPath = Path()
      ..moveTo(w - 0.8, mirrorY)
      ..lineTo(w + mirrorW - 0.4, mirrorY + 1.2)
      ..quadraticBezierTo(w + mirrorW, mirrorY + mirrorH * 0.6, w + mirrorW - 0.8, mirrorY + mirrorH)
      ..lineTo(w - 0.8, mirrorY + mirrorH * 0.8)
      ..close();
    canvas.drawPath(rightMirrorPath, Paint()..color = (isSelected || isWhite) ? Colors.white : const Color(0xFFF8FAFC));
    canvas.drawPath(
      rightMirrorPath,
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
    canvas.drawCircle(Offset(w + mirrorW - 0.8, mirrorY + mirrorH * 0.5), 0.65, Paint()..color = const Color(0xFFF59E0B));

    // 4. Sleek Aerodynamic Body Chassis (Luxury Executive Sedan Contour)
    final Path body = Path();
    body.moveTo(w * 0.30, 0.6); // Front nose center-left
    body.quadraticBezierTo(w * 0.5, 0.0, w * 0.70, 0.6); // Rounded sleek front bumper nose
    body.quadraticBezierTo(w - 0.4, h * 0.06, w - 0.6, h * 0.22); // Front right headlight/fender flare
    body.lineTo(w - 1.2, h * 0.44); // Right waist aerodynamic tuck
    body.quadraticBezierTo(w - 0.4, h * 0.68, w - 0.6, h * 0.87); // Rear right muscular shoulder
    body.quadraticBezierTo(w * 0.88, h - 0.4, w * 0.68, h - 0.4); // Rear right bumper wrap
    body.lineTo(w * 0.32, h - 0.4); // Rear decklid center
    body.quadraticBezierTo(w * 0.12, h - 0.4, 0.6, h * 0.87); // Rear left bumper wrap
    body.quadraticBezierTo(0.4, h * 0.68, 1.2, h * 0.44); // Left waist tuck
    body.lineTo(0.6, h * 0.22); // Front left fender flare
    body.quadraticBezierTo(0.4, h * 0.06, w * 0.30, 0.6); // Front nose closure
    body.close();

    // Body Paint: Pearl Metallic White
    final Paint bodyFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(body, bodyFill);

    // Subtle perimeter contour stroke (brand purple accent outline if selected)
    canvas.drawPath(
      body,
      Paint()
        ..color = isSelected ? const Color(0xFF8B53FE) : const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 1.2 : 0.75,
    );

    // Sculpted Hood Creases (Dual aerodynamic character lines)
    final Paint hoodCrease = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    final Path leftCrease = Path()
      ..moveTo(w * 0.30, h * 0.05)
      ..quadraticBezierTo(w * 0.26, h * 0.14, w * 0.24, h * 0.25);
    canvas.drawPath(leftCrease, hoodCrease);
    final Path rightCrease = Path()
      ..moveTo(w * 0.70, h * 0.05)
      ..quadraticBezierTo(w * 0.74, h * 0.14, w * 0.76, h * 0.25);
    canvas.drawPath(rightCrease, hoodCrease);

    // 5. Jewel LED Matrix Headlights & Ice-Blue DRL Ribbons
    final Path leftHeadlight = Path()
      ..moveTo(1.5, h * 0.07)
      ..lineTo(w * 0.28, h * 0.04)
      ..lineTo(w * 0.25, h * 0.11)
      ..lineTo(1.8, h * 0.13)
      ..close();
    canvas.drawPath(leftHeadlight, Paint()..color = const Color(0xFF0F172A)); // Dark headlight housing
    canvas.drawCircle(Offset(w * 0.14, h * 0.09), 1.0, Paint()..color = const Color(0xFF38BDF8));
    canvas.drawCircle(Offset(w * 0.14, h * 0.09), 0.5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w * 0.22, h * 0.075), 0.9, Paint()..color = Colors.white);

    final Path rightHeadlight = Path()
      ..moveTo(w - 1.5, h * 0.07)
      ..lineTo(w - w * 0.28, h * 0.04)
      ..lineTo(w - w * 0.25, h * 0.11)
      ..lineTo(w - 1.8, h * 0.13)
      ..close();
    canvas.drawPath(rightHeadlight, Paint()..color = const Color(0xFF0F172A));
    canvas.drawCircle(Offset(w - w * 0.14, h * 0.09), 1.0, Paint()..color = const Color(0xFF38BDF8));
    canvas.drawCircle(Offset(w - w * 0.14, h * 0.09), 0.5, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(w - w * 0.22, h * 0.075), 0.9, Paint()..color = Colors.white);

    // 6. Luxury Glasshouse (Windshield, Glass Pillars, and Panoramic Sunroof)
    final Paint glassPaint = Paint()..color = const Color(0xFF0B132B);

    // Front Windshield (curved panoramic glass)
    final Path frontWindshield = Path()
      ..moveTo(w * 0.21, h * 0.27)
      ..quadraticBezierTo(w * 0.5, h * 0.23, w * 0.79, h * 0.27)
      ..lineTo(w * 0.83, h * 0.41)
      ..quadraticBezierTo(w * 0.5, h * 0.39, w * 0.17, h * 0.41)
      ..close();
    canvas.drawPath(frontWindshield, glassPaint);

    // Diagonal Glass Sheen Reflection across windshield
    final Path glassSheen = Path()
      ..moveTo(w * 0.30, h * 0.26)
      ..lineTo(w * 0.42, h * 0.25)
      ..lineTo(w * 0.32, h * 0.40)
      ..lineTo(w * 0.20, h * 0.40)
      ..close();
    canvas.drawPath(
      glassSheen,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0.35), Colors.white.withValues(alpha: 0.05)],
        ).createShader(Rect.fromLTWH(0, h * 0.25, w, h * 0.16)),
    );

    // Rear Windshield (with defroster curves)
    final Path rearWindshield = Path()
      ..moveTo(w * 0.19, h * 0.72)
      ..quadraticBezierTo(w * 0.5, h * 0.70, w * 0.81, h * 0.72)
      ..lineTo(w * 0.77, h * 0.84)
      ..quadraticBezierTo(w * 0.5, h * 0.85, w * 0.23, h * 0.84)
      ..close();
    canvas.drawPath(rearWindshield, glassPaint);

    // Side Windows
    final Path sideWindows = Path();
    // Left side glass
    sideWindows.moveTo(w * 0.16, h * 0.41);
    sideWindows.lineTo(w * 0.18, h * 0.72);
    sideWindows.lineTo(w * 0.24, h * 0.71);
    sideWindows.lineTo(w * 0.22, h * 0.41);
    sideWindows.close();
    // Right side glass
    sideWindows.moveTo(w * 0.84, h * 0.41);
    sideWindows.lineTo(w * 0.82, h * 0.72);
    sideWindows.lineTo(w * 0.76, h * 0.71);
    sideWindows.lineTo(w * 0.78, h * 0.41);
    sideWindows.close();
    canvas.drawPath(sideWindows, glassPaint);

    // 7. Panoramic Executive Roof Panel (Pure Solid White when selected/white, Brand Purple when normal)
    final Rect roofRect = Rect.fromLTRB(w * 0.20, h * 0.39, w * 0.80, h * 0.72);
    final RRect roofRRect = RRect.fromRectAndRadius(roofRect, Radius.circular(w * 0.14));

    final Paint roofPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: (isSelected || isWhite)
            ? [const Color(0xFFFFFFFF), const Color(0xFFFFFFFF)]
            : [roofColor, roofColor.withValues(alpha: 0.82)],
      ).createShader(roofRect);
    canvas.drawRRect(roofRRect, roofPaint);

    // Roof glass highlight reflection / border
    canvas.drawRRect(
      roofRRect,
      Paint()
        ..color = (isSelected || isWhite) ? const Color(0xFFCBD5E1) : Colors.white.withValues(alpha: 0.20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (isSelected || isWhite) ? 0.75 : 0.5,
    );

    // Aerodynamic Shark-Fin Antenna (subtle teardrop)
    final Path sharkFin = Path()
      ..moveTo(w * 0.5, h * 0.62)
      ..quadraticBezierTo(w * 0.48, h * 0.65, w * 0.49, h * 0.68)
      ..lineTo(w * 0.51, h * 0.68)
      ..quadraticBezierTo(w * 0.52, h * 0.65, w * 0.5, h * 0.62)
      ..close();
    canvas.drawPath(sharkFin, Paint()..color = (isSelected || isWhite) ? const Color(0xFFCBD5E1) : const Color(0xFF0F172A));

    // 8. Continuous Rear Lightbar (Full-width neon red LED strip)
    final Path rearLightbar = Path()
      ..moveTo(1.8, h * 0.88)
      ..lineTo(w * 0.26, h * 0.89)
      ..lineTo(w * 0.74, h * 0.89)
      ..lineTo(w - 1.8, h * 0.88)
      ..lineTo(w - 1.8, h * 0.91)
      ..lineTo(w * 0.72, h * 0.92)
      ..lineTo(w * 0.28, h * 0.92)
      ..lineTo(1.8, h * 0.91)
      ..close();
    canvas.drawPath(rearLightbar, Paint()..color = const Color(0xFFFF2E54));
    canvas.drawLine(
      Offset(w * 0.15, h * 0.90),
      Offset(w * 0.85, h * 0.90),
      Paint()
        ..color = const Color(0xFFFF859B)
        ..strokeWidth = 0.8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _TopDownVectorCarPainter oldDelegate) {
    return oldDelegate.roofColor != roofColor ||
        (oldDelegate.isSelected == true) != (isSelected == true) ||
        (oldDelegate.isWhite == true) != (isWhite == true);
  }
}

/// Ultra-Sleek Floating Pill Badge (Capsule Tag)
/// Clean single-line layout matching Apple Maps & Uber standards:
/// [ 🟢 DriverName • ➤ 0.9 km ]
/// Ultra-Premium Speech Bubble Badge matching User Screenshot:
/// - Compact 2-line layout (Line 1: • Driver Name, Line 2: ↖ Real Distance)
/// - Pure white card with 10px rounded corners, sleek border, and soft shadow
/// - Crisp downward-pointing pointer tail pointing directly to the car nose
/// - Highlighted with vivid purple border & glowing halo when clicked or selected
class _PremiumSpeechBubbleBadge extends ConsumerWidget {
  final String driverName;
  final double? distanceKm;
  final bool isSelected;
  final bool isWhite;
  final bool isInsideRadius;

  const _PremiumSpeechBubbleBadge({
    required this.driverName,
    this.distanceKm,
    this.isSelected = false,
    this.isWhite = false,
    this.isInsideRadius = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final localizedDriverName =
        tr.formatProviderName(driverName).trim().split(' ').first;
    final bool isHighlighted = isSelected || isWhite;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 3.5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: isHighlighted
                  ? const Color(0xFF8B53FE)
                  : const Color(0xFFE2E8F0),
              width: isHighlighted ? 1.4 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isHighlighted
                    ? const Color(0x358B53FE)
                    : const Color(0x18000000),
                blurRadius: isHighlighted ? 8.0 : 4.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Row 1: Emerald Live Status Dot + Driver Name
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 5.5,
                    height: 5.5,
                    margin: const EdgeInsets.only(right: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.6),
                          blurRadius: 3.0,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    localizedDriverName,
                    style: tr.font(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      height: 1.15,
                    ),
                  ),
                ],
              ),
              if (distanceKm != null) ...[
                const SizedBox(height: 1.5),
                // Row 2: Purple Navigation Arrow + Real Distance
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.rotate(
                      angle: -math.pi / 4.0,
                      child: const Icon(
                        Icons.navigation,
                        size: 9.0,
                        color: Color(0xFF8B53FE),
                      ),
                    ),
                    const SizedBox(width: 2.5),
                    Text(
                      tr.isArabic
                          ? '${distanceKm!.toStringAsFixed(1)} كم'
                          : '${distanceKm!.toStringAsFixed(1)} km',
                      style: tr.font(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF8B53FE),
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        // Downward pointer tail pointing directly at car
        CustomPaint(
          size: const Size(8.0, 4.0),
          painter: _MicroCaretPainter(
            color: Colors.white,
            borderColor: isHighlighted
                ? const Color(0xFF8B53FE)
                : const Color(0xFFE2E8F0),
          ),
        ),
      ],
    );
  }
}

/// Vector Micro-Caret Pointer
class _MicroCaretPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  const _MicroCaretPainter({
    required this.color,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2.0, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);

    if (borderColor != Colors.transparent) {
      final Path border = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width / 2.0, size.height)
        ..lineTo(size.width, 0);
      canvas.drawPath(
        border,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MicroCaretPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.borderColor != borderColor;
}
