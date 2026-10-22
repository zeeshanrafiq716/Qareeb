import 'package:flutter/material.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';

/// Provider Splash Screen Background Painter
/// Strictly renders the branding gradient specifications:
/// - Base canvas: #1F2927
/// - Top Linear Gradient (180deg):
///     rgba(102, 255, 172, 0.8) at -33.53%
///     rgba(102, 255, 172, 0.460552) at 4.23%
///     rgba(102, 255, 172, 0.25553) at 27.03%
///     rgba(102, 255, 172, 0) at 62.38%
/// - Bottom Linear Gradient (180deg):
///     rgba(31, 41, 39, 0) at 50%
///     rgba(31, 41, 39, 0.398199) at 57.27%
///     rgba(31, 41, 39, 0.817605) at 71.17%
///     rgba(31, 41, 39, 0.92) at 82.55%
///     #1F2927 at 100%
class ProviderSplashBackgroundPainter extends CustomPainter {
  final bool drawBase;

  const ProviderSplashBackgroundPainter({this.drawBase = false});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Optional Base Dark Slate canvas (#1F2927)
    if (drawBase) {
      final basePaint = Paint()..color = ProviderColors.background;
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), basePaint);
    }

    // 2. Top Mint Glow Linear Gradient (180deg vertical)
    // Span: -33.53% to 62.38% (total height span = 0.6238 - (-0.3353) = 0.9591 * h)
    final topGlowShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.3937024, 0.6314253, 1.0],
      colors: [
        Color(0xCC66FFAC), // rgba(102, 255, 172, 0.8) at -33.53%
        Color(0x7566FFAC), // rgba(102, 255, 172, 0.460552) at 4.23%
        Color(0x4166FFAC), // rgba(102, 255, 172, 0.25553) at 27.03%
        Color(0x0066FFAC), // rgba(102, 255, 172, 0) at 62.38%
      ],
    ).createShader(Rect.fromLTWH(0, -0.3353 * h, w, 0.9591 * h));

    final topPaint = Paint()..shader = topGlowShader;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), topPaint);

    // 3. Bottom Dark Slate Shading Linear Gradient (180deg vertical)
    // Span: 50% to 100%
    final bottomDarkShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.50, 0.5727, 0.7117, 0.8255, 1.0],
      colors: [
        Color(0x001F2927), // rgba(31, 41, 39, 0) from 0%
        Color(0x001F2927), // rgba(31, 41, 39, 0) at 50%
        Color(0x661F2927), // rgba(31, 41, 39, 0.398199) at 57.27%
        Color(0xD11F2927), // rgba(31, 41, 39, 0.817605) at 71.17%
        Color(0xEB1F2927), // rgba(31, 41, 39, 0.92) at 82.55%
        Color(0xFF1F2927), // #1F2927 at 100%
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final bottomPaint = Paint()..shader = bottomDarkShader;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bottomPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Provider Splash Screen Branding Background Painter
/// Implements exact Figma CSS specification:
/// ```css
/// background: linear-gradient(180.52deg, #8B53FE -66.75%, rgba(139, 83, 254, 0.37284) -0.59%, rgba(139, 83, 254, 0) 29.8%),
/// linear-gradient(180deg, rgba(255, 255, 255, 0) 47.99%, rgba(255, 255, 255, 0.666786) 55.54%, #FFFFFF 65.82%);
/// ```
class ProviderSplashBrandingPainter extends CustomPainter {
  final bool drawBase;
  final bool drawTopPurple;
  final bool drawBottomWhite;

  const ProviderSplashBrandingPainter({
    this.drawBase = true,
    this.drawTopPurple = true,
    this.drawBottomWhite = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Base White Canvas (#FFFFFF)
    if (drawBase) {
      final basePaint = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), basePaint);
    }

    // 2. Top Purple Brand Gradient (180.52deg):
    //    #8B53FE -66.75%, rgba(139, 83, 254, 0.37284) -0.59%, rgba(139, 83, 254, 0) 29.8%
    if (drawTopPurple) {
      final double topSpan = (0.298 - (-0.6675)) * h;
      final topShader = const LinearGradient(
        begin: Alignment(-0.009, -1.0),
        end: Alignment(0.009, 1.0),
        stops: [0.0, 0.68524, 1.0],
        colors: [
          Color(0xFF8B53FE),
          Color.fromRGBO(139, 83, 254, 0.37284),
          Color.fromRGBO(139, 83, 254, 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, -0.6675 * h, w, topSpan));

      final topPaint = Paint()..shader = topShader;
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), topPaint);
    }

    // 3. Bottom White Fade Linear Gradient (180deg):
    //    rgba(255, 255, 255, 0) 47.99%, rgba(255, 255, 255, 0.666786) 55.54%, #FFFFFF 65.82%
    if (drawBottomWhite) {
      final bottomShader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.4799, 0.5554, 0.6582, 1.0],
        colors: [
          Color.fromRGBO(255, 255, 255, 0.0),
          Color.fromRGBO(255, 255, 255, 0.0),
          Color.fromRGBO(255, 255, 255, 0.666786),
          Color(0xFFFFFFFF),
          Color(0xFFFFFFFF),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

      final bottomPaint = Paint()..shader = bottomShader;
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bottomPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
