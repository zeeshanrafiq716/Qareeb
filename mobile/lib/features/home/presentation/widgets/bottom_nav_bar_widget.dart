import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/app_locale.dart';

/// Floating Bottom Navigation Bar strictly following Figma branding:
/// - Outer Container:
///   - width: 292; height: 65; border-radius: 60px;
///   - padding-top: 4px; padding-bottom: 4px; padding-left: 4px;
///   - background: #1C2926;
/// - Home tab layout (Active):
///   - width: 96; height: 57; border-radius: 60px;
///   - padding-top: 8px; padding-right: 20px; padding-bottom: 8px; padding-left: 20px;
///   - gap: 8px; border-width: 0.6px; border: 0.6px solid #2B4742;
///   - background: #2A3D39;
///   - vector: width: 24; height: 24; color: #9FFFCB;
///   - content: Home; font-size: 12px; font-weight: 400; line-height: 100%; color: #9FFFCB;
/// - Inactive tabs (Request, Profile):
///   - width: 96; height: 57; transparent background;
///   - vector: 24x24; color: #FFFFFF;
///   - content: font-size: 12px; font-weight: 400; line-height: 100%; color: #FFFFFF;
class BottomNavBarWidget extends ConsumerStatefulWidget {
  final int initialIndex;
  final int? currentIndex;
  final ValueChanged<int>? onTabSelected;

  const BottomNavBarWidget({
    super.key,
    this.initialIndex = 0,
    this.currentIndex,
    this.onTabSelected,
  });

  @override
  ConsumerState<BottomNavBarWidget> createState() => _BottomNavBarWidgetState();
}

class _BottomNavBarWidgetState extends ConsumerState<BottomNavBarWidget> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex ?? widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant BottomNavBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != null) {
      _currentIndex = widget.currentIndex!;
    } else if (oldWidget.initialIndex != widget.initialIndex) {
      _currentIndex = widget.initialIndex;
    }
  }

  void _handleTabTap(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentIndex = index;
    });
    widget.onTabSelected?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);

    return Container(
      width: 292.0,
      height: 65.0,
      padding: const EdgeInsets.only(
        top: 4.0,
        bottom: 4.0,
        left: 4.0,
        right: 0.0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(60.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000), // 0px 1px 16px 0px #0000001F
            blurRadius: 16.0,
            spreadRadius: 0.0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Home Tab (width: 96, height: 57) - Vector1.png
          _buildTabItem(
            index: 0,
            label: tr.navHome,
            iconAsset: 'assets/images/Vector1.png',
            fallbackBuilder: (color, isActive) => StylizedHomeIcon(color: color, isFilled: isActive),
            tr: tr,
          ),

          // 2. Request Tab (width: 96, height: 57) - Vector2.png
          _buildTabItem(
            index: 1,
            label: tr.navRequests,
            iconAsset: 'assets/images/Vector2.png',
            fallbackBuilder: (color, isActive) => StylizedRequestIcon(color: color),
            tr: tr,
          ),

          // 3. Profile Tab (width: 96, height: 57) - vector3.png
          _buildTabItem(
            index: 2,
            label: tr.navProfile,
            iconAsset: 'assets/images/vector3.png',
            fallbackBuilder: (color, isActive) => StylizedProfileIcon(color: color),
            tr: tr,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String label,
    required String iconAsset,
    required Widget Function(Color color, bool isActive) fallbackBuilder,
    required AppTranslations tr,
  }) {
    final int effectiveCurrent = widget.currentIndex ?? _currentIndex;
    final bool isSelected = effectiveCurrent == index;
    final Color textColor = isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF566663);
    final Color iconColor = isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF566663);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        width: 96.0,
        height: 57.0,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B53FE) : Colors.transparent,
          borderRadius: BorderRadius.circular(60.0),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x0F000000), // 0px 0px 12px 0px #0000000F
                    blurRadius: 12.0,
                    spreadRadius: 0.0,
                    offset: Offset(0, 0),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(60.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(60.0),
            splashColor: const Color(0xFF8B53FE).withValues(alpha: 0.15),
            highlightColor: const Color(0xFF8B53FE).withValues(alpha: 0.08),
            onTap: () => _handleTabTap(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24.0,
                    height: 24.0,
                    child: Image.asset(
                      iconAsset,
                      width: 24.0,
                      height: 24.0,
                      fit: BoxFit.contain,
                      color: iconColor,
                      errorBuilder: (context, error, stackTrace) =>
                          fallbackBuilder(iconColor, isSelected),
                    ),
                  ),
                  SizedBox(
                    height: (tr.isArabic || Directionality.of(context) == TextDirection.rtl)
                        ? 1.0
                        : 4.0,
                  ),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                    style: tr.font(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: textColor,
                      height: 1.0, // line-height: 100%
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 1. Stylized Home Icon:
/// Pointed pentagon roof shape with rounded vertices and a lower horizontal slit cutout
class StylizedHomeIcon extends StatelessWidget {
  final Color color;
  final bool isFilled;

  const StylizedHomeIcon({
    super.key,
    required this.color,
    this.isFilled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(24.0, 24.0),
      painter: _StylizedHomePainter(color: color, isFilled: isFilled),
    );
  }
}

class _StylizedHomePainter extends CustomPainter {
  final Color color;
  final bool isFilled;

  _StylizedHomePainter({required this.color, required this.isFilled});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final outerPath = Path();
    // Rounded pentagon / cottage outline
    outerPath.moveTo(w * 0.5, h * 0.08);
    // Top right slope towards shoulder
    outerPath.quadraticBezierTo(w * 0.53, h * 0.08, w * 0.84, h * 0.32);
    outerPath.quadraticBezierTo(w * 0.89, h * 0.36, w * 0.86, h * 0.44);
    // Right side downwards
    outerPath.lineTo(w * 0.83, h * 0.86);
    outerPath.quadraticBezierTo(w * 0.81, h * 0.94, w * 0.72, h * 0.94);
    // Bottom edge
    outerPath.lineTo(w * 0.28, h * 0.94);
    outerPath.quadraticBezierTo(w * 0.19, h * 0.94, w * 0.17, h * 0.86);
    // Left side upwards
    outerPath.lineTo(w * 0.14, h * 0.44);
    outerPath.quadraticBezierTo(w * 0.11, h * 0.36, w * 0.16, h * 0.32);
    // Left slope back to peak
    outerPath.quadraticBezierTo(w * 0.47, h * 0.08, w * 0.5, h * 0.08);
    outerPath.close();

    if (isFilled) {
      // Solid filled with horizontal slit cutout
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // Inner horizontal slit cutout
      final slitWidth = w * 0.40;
      final slitHeight = h * 0.13;
      final slitRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.73),
          width: slitWidth,
          height: slitHeight,
        ),
        Radius.circular(slitHeight * 0.5),
      );

      final slitPath = Path()..addRRect(slitRect);
      final finalPath = Path.combine(PathOperation.difference, outerPath, slitPath);
      canvas.drawPath(finalPath, paint);
    } else {
      // Outline stroke
      final strokePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(outerPath, strokePaint);

      // Inner slit stroke
      final slitWidth = w * 0.40;
      final slitHeight = h * 0.13;
      final slitRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.73),
          width: slitWidth,
          height: slitHeight,
        ),
        Radius.circular(slitHeight * 0.5),
      );
      canvas.drawRRect(slitRect, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _StylizedHomePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isFilled != isFilled;
}

/// 2. Stylized Request Icon:
/// Rounded diamond outline with right-curved arrow inside
class StylizedRequestIcon extends StatelessWidget {
  final Color color;

  const StylizedRequestIcon({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(24.0, 24.0),
      painter: _StylizedRequestPainter(color: color),
    );
  }
}

class _StylizedRequestPainter extends CustomPainter {
  final Color color;

  _StylizedRequestPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // 1. Rounded diamond outline
    const cornerRadius = 3.6;
    final diamondPath = Path();
    // Top corner
    diamondPath.moveTo(w * 0.5, h * 0.08 + cornerRadius);
    diamondPath.lineTo(w * 0.92 - cornerRadius, h * 0.5 - cornerRadius);
    diamondPath.quadraticBezierTo(w * 0.92, h * 0.5, w * 0.92 - cornerRadius, h * 0.5 + cornerRadius);
    // Bottom corner
    diamondPath.lineTo(w * 0.5 + cornerRadius, h * 0.92 - cornerRadius);
    diamondPath.quadraticBezierTo(w * 0.5, h * 0.92, w * 0.5 - cornerRadius, h * 0.92 - cornerRadius);
    // Left corner
    diamondPath.lineTo(w * 0.08 + cornerRadius, h * 0.5 + cornerRadius);
    diamondPath.quadraticBezierTo(w * 0.08, h * 0.5, w * 0.08 + cornerRadius, h * 0.5 - cornerRadius);
    // Back to top
    diamondPath.lineTo(w * 0.5 - cornerRadius, h * 0.08 + cornerRadius);
    diamondPath.quadraticBezierTo(w * 0.5, h * 0.08, w * 0.5, h * 0.08 + cornerRadius);
    diamondPath.close();

    canvas.drawPath(diamondPath, strokePaint);

    // 2. Right-curved arrow inside diamond
    final arrowCurve = Path();
    arrowCurve.moveTo(w * 0.38, h * 0.62);
    arrowCurve.quadraticBezierTo(w * 0.40, h * 0.44, w * 0.64, h * 0.44);
    canvas.drawPath(arrowCurve, strokePaint);

    final arrowHead = Path();
    arrowHead.moveTo(w * 0.54, h * 0.34);
    arrowHead.lineTo(w * 0.65, h * 0.44);
    arrowHead.lineTo(w * 0.54, h * 0.54);
    canvas.drawPath(arrowHead, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _StylizedRequestPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// 3. Stylized Profile Icon:
/// Outline head circle and rounded shoulders silhouette
class StylizedProfileIcon extends StatelessWidget {
  final Color color;

  const StylizedProfileIcon({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(24.0, 24.0),
      painter: _StylizedProfilePainter(color: color),
    );
  }
}

class _StylizedProfilePainter extends CustomPainter {
  final Color color;

  _StylizedProfilePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // 1. Head circle outline
    canvas.drawCircle(Offset(w * 0.5, h * 0.30), w * 0.17, strokePaint);

    // 2. Shoulders dome / arc outline
    final bodyPath = Path();
    final leftX = w * 0.22;
    final rightX = w * 0.78;
    final bottomY = h * 0.88;
    final shoulderY = h * 0.56;
    const cornerR = 5.0;

    bodyPath.moveTo(leftX + cornerR, bottomY);
    bodyPath.lineTo(rightX - cornerR, bottomY);
    bodyPath.quadraticBezierTo(rightX, bottomY, rightX, bottomY - cornerR);
    bodyPath.quadraticBezierTo(rightX, shoulderY, w * 0.5, shoulderY);
    bodyPath.quadraticBezierTo(leftX, shoulderY, leftX, bottomY - cornerR);
    bodyPath.quadraticBezierTo(leftX, bottomY, leftX + cornerR, bottomY);
    bodyPath.close();

    canvas.drawPath(bodyPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _StylizedProfilePainter oldDelegate) =>
      oldDelegate.color != color;
}
