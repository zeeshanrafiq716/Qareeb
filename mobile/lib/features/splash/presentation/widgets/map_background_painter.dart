import 'package:flutter/material.dart';

/// Custom painter that creates an exact replica of the geometric mosaic
/// splash screen background: rich vertical emerald-to-dark-slate gradient
/// with elegant organic rounded-corner blocks, polygonal street mesh,
/// and smooth curved junctions.
class MapBackgroundPainter extends CustomPainter {
  final double animationProgress;

  MapBackgroundPainter({this.animationProgress = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Draw base dark slate (#1F2927 / rgba(31, 41, 39, 1))
    final baseBgPaint = Paint()..color = const Color(0xFF1F2927);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), baseBgPaint);

    // 2. Top Mint Glow Gradient (exact user specifications):
    // linear-gradient(180deg, rgba(102, 255, 172, 0.8) -28.97%, rgba(102, 255, 172, 0.0511174) 50.78%, rgba(102, 255, 172, 0) 62.86%)
    // Normalized to total height span (1.0 + 0.2897 = 1.2897)
    final topGlowShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.6184, 0.7120, 1.0],
      colors: [
        Color(0xCC66FFAC), // rgba(102, 255, 172, 0.8)
        Color(0x0D66FFAC), // rgba(102, 255, 172, 0.0511174)
        Color(0x0066FFAC), // rgba(102, 255, 172, 0)
        Color(0x0066FFAC),
      ],
    ).createShader(Rect.fromLTWH(0, -0.2897 * h, w, 1.2897 * h));

    final topGlowPaint = Paint()..shader = topGlowShader;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), topGlowPaint);

    // 3. Primary road & mosaic line paint from picture replica
    // Dark translucent pine-charcoal with rounded caps and joins
    final linePaint = Paint()
      ..color = const Color(0xFF14241F).withValues(alpha: 0.50)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Helper to map normalized coordinates (0.0 to 1.0) to canvas size
    Offset p(double x, double y) => Offset(x * w, y * h);

    final path = Path();

    // -------------------------------------------------------------
    // BLOCK 1: Top Center Inverted Rounded Tab / Block
    // (Noticeable rounded bottom corners at the top edge)
    // -------------------------------------------------------------
    final double r1 = 16.0 / 390.0 * w; // Corner radius scaled
    path.moveTo(p(0.36, 0.0).dx, p(0.36, 0.0).dy);
    path.lineTo(p(0.36, 0.075).dx, p(0.36, 0.075).dy - r1);
    path.quadraticBezierTo(
      p(0.36, 0.075).dx,
      p(0.36, 0.075).dy,
      p(0.36, 0.075).dx + r1,
      p(0.36, 0.075).dy,
    );
    path.lineTo(p(0.63, 0.075).dx - r1, p(0.63, 0.075).dy);
    path.quadraticBezierTo(
      p(0.63, 0.075).dx,
      p(0.63, 0.075).dy,
      p(0.63, 0.075).dx,
      p(0.63, 0.075).dy - r1,
    );
    path.lineTo(p(0.63, 0.0).dx, p(0.63, 0.0).dy);

    // -------------------------------------------------------------
    // BLOCK 2: Top Right Curved Conduit & Upper Quadrant
    // -------------------------------------------------------------
    final double r2 = 18.0 / 390.0 * w;
    // Route continuing from top center block right corner:
    path.moveTo(p(0.63, 0.075).dx, p(0.63, 0.075).dy);
    path.lineTo(p(0.72, 0.078).dx - r2, p(0.72, 0.078).dy);
    // Smooth turn downwards
    path.quadraticBezierTo(
      p(0.74, 0.078).dx,
      p(0.74, 0.078).dy,
      p(0.74, 0.10).dx,
      p(0.74, 0.10).dy,
    );
    path.lineTo(p(0.74, 0.19).dx, p(0.74, 0.19).dy - r2);
    // Smooth turn rightwards
    path.quadraticBezierTo(
      p(0.74, 0.215).dx,
      p(0.74, 0.215).dy,
      p(0.74, 0.215).dx + r2,
      p(0.74, 0.215).dy,
    );
    path.lineTo(p(1.0, 0.215).dx, p(1.0, 0.215).dy);

    // Diagonal lines in top-right
    path.moveTo(p(0.75, 0.0).dx, p(0.75, 0.0).dy);
    path.lineTo(p(0.63, 0.075).dx, p(0.63, 0.075).dy);

    path.moveTo(p(0.96, 0.0).dx, p(0.96, 0.0).dy);
    path.lineTo(p(1.0, 0.035).dx, p(1.0, 0.035).dy);

    path.moveTo(p(0.74, 0.14).dx, p(0.74, 0.14).dy);
    path.lineTo(p(1.0, 0.025).dx, p(1.0, 0.025).dy);

    path.moveTo(p(0.74, 0.19).dx, p(0.74, 0.19).dy);
    path.lineTo(p(1.0, 0.34).dx, p(1.0, 0.34).dy);

    // -------------------------------------------------------------
    // BLOCK 3: Top Left Section
    // -------------------------------------------------------------
    path.moveTo(p(0.0, 0.02).dx, p(0.0, 0.02).dy);
    path.lineTo(p(0.16, 0.0).dx, p(0.16, 0.0).dy);

    path.moveTo(p(0.0, 0.075).dx, p(0.0, 0.075).dy);
    path.lineTo(p(0.28, 0.165).dx, p(0.28, 0.165).dy);

    path.moveTo(p(0.28, 0.165).dx, p(0.28, 0.165).dy);
    path.lineTo(p(0.36, 0.072).dx, p(0.36, 0.072).dy);

    path.moveTo(p(0.28, 0.165).dx, p(0.28, 0.165).dy);
    path.lineTo(p(0.33, 0.11).dx, p(0.33, 0.11).dy);
    path.lineTo(p(0.36, 0.0).dx, p(0.36, 0.0).dy);

    // -------------------------------------------------------------
    // BLOCK 4: Upper-Center Slanted Rounded Polygon Block
    // -------------------------------------------------------------
    final double r4 = 16.0 / 390.0 * w;
    path.moveTo(p(0.28, 0.165).dx, p(0.28, 0.165).dy);
    path.lineTo(p(0.53, 0.168).dx - r4, p(0.53, 0.168).dy);
    path.quadraticBezierTo(
      p(0.535, 0.168).dx,
      p(0.535, 0.168).dy,
      p(0.535, 0.168).dx + (r4 * 0.5),
      p(0.535, 0.168).dy + r4,
    );
    path.lineTo(p(0.535, 0.27).dx, p(0.535, 0.27).dy);
    path.lineTo(p(0.615, 0.30).dx, p(0.615, 0.30).dy);

    // -------------------------------------------------------------
    // BLOCK 5: Mid-Left Slanted Blocks & Parallel Dividers
    // -------------------------------------------------------------
    path.moveTo(p(0.0, 0.23).dx, p(0.0, 0.23).dy);
    path.lineTo(p(0.28, 0.165).dx, p(0.28, 0.165).dy);

    path.moveTo(p(0.0, 0.23).dx, p(0.0, 0.23).dy);
    path.lineTo(p(0.52, 0.35).dx, p(0.52, 0.35).dy);

    path.moveTo(p(0.0, 0.33).dx, p(0.0, 0.33).dy);
    path.lineTo(p(0.33, 0.42).dx, p(0.33, 0.42).dy);

    // Vertical divider between diagonals
    path.moveTo(p(0.16, 0.27).dx, p(0.16, 0.27).dy);
    path.lineTo(p(0.16, 0.37).dx, p(0.16, 0.37).dy);

    // Left rounded loop at (0.33, 0.42)
    path.moveTo(p(0.33, 0.42).dx, p(0.33, 0.42).dy);
    path.lineTo(p(0.0, 0.47).dx, p(0.0, 0.47).dy);

    path.moveTo(p(0.33, 0.42).dx, p(0.33, 0.42).dy);
    path.lineTo(p(0.17, 0.475).dx + r4, p(0.17, 0.475).dy);
    path.quadraticBezierTo(
      p(0.15, 0.48).dx,
      p(0.15, 0.48).dy,
      p(0.17, 0.485).dx + r4,
      p(0.17, 0.485).dy,
    );
    path.lineTo(p(0.45, 0.415).dx, p(0.45, 0.415).dy);

    // -------------------------------------------------------------
    // BLOCK 6: Mid-Right Region with Distinctive Rounded Notch
    // -------------------------------------------------------------
    // Junction at (0.615, 0.30)
    path.moveTo(p(0.615, 0.30).dx, p(0.615, 0.30).dy);
    path.lineTo(p(0.74, 0.24).dx, p(0.74, 0.24).dy);

    path.moveTo(p(0.615, 0.30).dx, p(0.615, 0.30).dy);
    path.lineTo(p(0.76, 0.36).dx - r4, p(0.76, 0.36).dy);
    path.quadraticBezierTo(
      p(0.76, 0.36).dx,
      p(0.76, 0.36).dy,
      p(0.76, 0.36).dx,
      p(0.76, 0.36).dy + r4,
    );
    path.lineTo(p(0.77, 0.47).dx, p(0.77, 0.47).dy);

    path.moveTo(p(0.76, 0.36).dx, p(0.76, 0.36).dy);
    path.lineTo(p(1.0, 0.33).dx, p(1.0, 0.33).dy);

    // Inward rounded hook/notch contour
    final double rNotch = 22.0 / 390.0 * w;
    path.moveTo(p(0.59, 0.46).dx, p(0.59, 0.46).dy);
    path.lineTo(p(0.77, 0.48).dx - rNotch, p(0.77, 0.48).dy);
    path.quadraticBezierTo(
      p(0.78, 0.48).dx,
      p(0.78, 0.48).dy,
      p(0.78, 0.48).dx,
      p(0.78, 0.48).dy + rNotch,
    );
    path.lineTo(p(0.78, 0.70).dx, p(0.78, 0.70).dy);

    path.moveTo(p(0.78, 0.48).dx, p(0.78, 0.48).dy);
    path.lineTo(p(1.0, 0.49).dx, p(1.0, 0.49).dy);

    // -------------------------------------------------------------
    // BLOCK 7: Central Junction & Connections
    // -------------------------------------------------------------
    path.moveTo(p(0.615, 0.30).dx, p(0.615, 0.30).dy);
    path.lineTo(p(0.45, 0.415).dx, p(0.45, 0.415).dy);

    path.moveTo(p(0.52, 0.35).dx, p(0.52, 0.35).dy);
    path.lineTo(p(0.45, 0.415).dx, p(0.45, 0.415).dy);

    path.moveTo(p(0.45, 0.415).dx, p(0.45, 0.415).dy);
    path.lineTo(p(0.59, 0.46).dx, p(0.59, 0.46).dy);

    path.moveTo(p(0.45, 0.415).dx, p(0.45, 0.415).dy);
    path.lineTo(p(0.42, 0.58).dx, p(0.42, 0.58).dy);

    path.moveTo(p(0.45, 0.415).dx, p(0.45, 0.415).dy);
    path.lineTo(p(0.11, 0.50).dx, p(0.11, 0.50).dy);

    // -------------------------------------------------------------
    // BLOCK 8: Lower-Left Facets
    // -------------------------------------------------------------
    path.moveTo(p(0.11, 0.50).dx, p(0.11, 0.50).dy);
    path.lineTo(p(0.0, 0.56).dx, p(0.0, 0.56).dy);

    path.moveTo(p(0.11, 0.50).dx, p(0.11, 0.50).dy);
    path.lineTo(p(0.20, 0.63).dx, p(0.20, 0.63).dy);

    path.moveTo(p(0.20, 0.63).dx, p(0.20, 0.63).dy);
    path.lineTo(p(0.0, 0.65).dx, p(0.0, 0.65).dy);

    path.moveTo(p(0.20, 0.63).dx, p(0.20, 0.63).dy);
    path.lineTo(p(0.28, 0.74).dx, p(0.28, 0.74).dy);

    path.moveTo(p(0.42, 0.58).dx, p(0.42, 0.58).dy);
    path.lineTo(p(0.28, 0.74).dx, p(0.28, 0.74).dy);

    path.moveTo(p(0.28, 0.74).dx, p(0.28, 0.74).dy);
    path.lineTo(p(0.0, 0.79).dx, p(0.0, 0.79).dy);

    // -------------------------------------------------------------
    // BLOCK 9: Lower-Right Facets
    // -------------------------------------------------------------
    path.moveTo(p(0.42, 0.58).dx, p(0.42, 0.58).dy);
    path.lineTo(p(0.60, 0.60).dx, p(0.60, 0.60).dy);

    path.moveTo(p(0.60, 0.60).dx, p(0.60, 0.60).dy);
    path.lineTo(p(0.78, 0.70).dx, p(0.78, 0.70).dy);

    path.moveTo(p(0.60, 0.60).dx, p(0.60, 0.60).dy);
    path.lineTo(p(0.62, 0.72).dx, p(0.62, 0.72).dy);

    path.moveTo(p(0.62, 0.72).dx, p(0.62, 0.72).dy);
    path.lineTo(p(0.78, 0.70).dx, p(0.78, 0.70).dy);

    path.moveTo(p(0.78, 0.70).dx, p(0.78, 0.70).dy);
    path.lineTo(p(0.87, 0.78).dx, p(0.87, 0.78).dy);
    path.lineTo(p(1.0, 0.79).dx, p(1.0, 0.79).dy);

    path.moveTo(p(0.87, 0.78).dx, p(0.87, 0.78).dy);
    path.lineTo(p(1.0, 0.85).dx, p(1.0, 0.85).dy);

    path.moveTo(p(0.87, 0.78).dx, p(0.87, 0.78).dy);
    path.lineTo(p(0.73, 0.88).dx, p(0.73, 0.88).dy);
    path.lineTo(p(0.75, 1.0).dx, p(0.75, 1.0).dy);

    // -------------------------------------------------------------
    // BLOCK 10: Bottom-Center & Bottom-Left Geometry
    // -------------------------------------------------------------
    path.moveTo(p(0.28, 0.74).dx, p(0.28, 0.74).dy);
    path.lineTo(p(0.38, 0.74).dx, p(0.38, 0.74).dy);

    path.moveTo(p(0.38, 0.74).dx, p(0.38, 0.74).dy);
    path.lineTo(p(0.50, 0.85).dx, p(0.50, 0.85).dy);
    path.lineTo(p(0.54, 1.0).dx, p(0.54, 1.0).dy);

    path.moveTo(p(0.38, 0.74).dx, p(0.38, 0.74).dy);
    path.lineTo(p(0.23, 0.81).dx, p(0.23, 0.81).dy);

    path.moveTo(p(0.23, 0.81).dx, p(0.23, 0.81).dy);
    path.lineTo(p(0.08, 0.92).dx, p(0.08, 0.92).dy);
    path.lineTo(p(0.0, 0.93).dx, p(0.0, 0.93).dy);

    path.moveTo(p(0.23, 0.81).dx, p(0.23, 0.81).dy);
    path.lineTo(p(0.38, 0.94).dx, p(0.38, 0.94).dy);
    path.lineTo(p(0.39, 1.0).dx, p(0.39, 1.0).dy);

    // Draw the comprehensive geometric mosaic network
    canvas.drawPath(path, linePaint);

    // 4. Bottom dark shading gradient (exact user specifications):
    // linear-gradient(180deg, rgba(31, 41, 39, 0) 0%, rgba(31, 41, 39, 0.817605) 43.97%, rgba(31, 41, 39, 0.92) 76.78%, #1F2927 100%)
    final bottomDarkShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.4397, 0.7678, 1.0],
      colors: [
        Color(0x001F2927), // rgba(31, 41, 39, 0)
        Color(0xD11F2927), // rgba(31, 41, 39, 0.817605)
        Color(0xEB1F2927), // rgba(31, 41, 39, 0.92)
        Color(0xFF1F2927), // #1F2927
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final bottomDarkPaint = Paint()..shader = bottomDarkShader;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bottomDarkPaint);
  }

  @override
  bool shouldRepaint(covariant MapBackgroundPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress;
  }
}
