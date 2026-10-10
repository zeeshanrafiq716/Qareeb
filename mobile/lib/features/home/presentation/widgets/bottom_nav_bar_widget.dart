import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Floating Bottom Navigation Bar strictly following Figma screenshot:
/// - Outer Container:
///   - width: 292; height: 65; border-radius: 60px;
///   - padding: 4px; background: #1C2926;
/// - Tabs:
///   1. Home:
///      - Active: 96x57 pill, background #2A3D39, border #2B4742, icon & label #9FFFCB
///      - Custom stylized solid pentagon home icon with lower slit cutout
///   2. Request:
///      - Inactive: white outline diamond with right-curved arrow inside, label "Request" #FFFFFF
///   3. Profile:
///      - Inactive: white outline user silhouette icon, label "Profile" #FFFFFF
class BottomNavBarWidget extends StatefulWidget {
  final int initialIndex;
  final ValueChanged<int>? onTabSelected;

  const BottomNavBarWidget({
    super.key,
    this.initialIndex = 0,
    this.onTabSelected,
  });

  @override
  State<BottomNavBarWidget> createState() => _BottomNavBarWidgetState();
}

class _BottomNavBarWidgetState extends State<BottomNavBarWidget> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _handleTabTap(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    widget.onTabSelected?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 292.0,
      height: 65.0,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2926),
        borderRadius: BorderRadius.circular(60.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C2926).withValues(alpha: 0.4),
            blurRadius: 24.0,
            spreadRadius: 0.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Home Tab
          Expanded(
            child: _buildTabItem(
              index: 0,
              label: 'Home',
              iconBuilder: (color, isActive) => StylizedHomeIcon(color: color, isFilled: isActive),
            ),
          ),

          // 2. Request Tab
          Expanded(
            child: _buildTabItem(
              index: 1,
              label: 'Request',
              iconBuilder: (color, isActive) => StylizedRequestIcon(color: color),
            ),
          ),

          // 3. Profile Tab
          Expanded(
            child: _buildTabItem(
              index: 2,
              label: 'Profile',
              iconBuilder: (color, isActive) => StylizedProfileIcon(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String label,
    required Widget Function(Color color, bool isActive) iconBuilder,
  }) {
    final bool isSelected = _currentIndex == index;
    final Color textColor = isSelected ? const Color(0xFF9FFFCB) : Colors.white;
    final Color iconColor = isSelected ? const Color(0xFF9FFFCB) : Colors.white;

    if (isSelected) {
      // Active Pill Tab: fills slot, height 57, border-radius 60px, background #2A3D39, border #2B4742
      return GestureDetector(
        onTap: () => _handleTabTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: 57.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: const Color(0xFF2A3D39),
            borderRadius: BorderRadius.circular(60.0),
            border: Border.all(
              color: const Color(0xFF2B4742),
              width: 0.6,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24.0,
                height: 24.0,
                child: iconBuilder(iconColor, true),
              ),
              const SizedBox(height: 4.0),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                  height: 1.0,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Inactive Tab (fills slot, height: 57)
    return GestureDetector(
      onTap: () => _handleTabTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: double.infinity,
        height: 57.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24.0,
              height: 24.0,
              child: iconBuilder(iconColor, false),
            ),
            const SizedBox(height: 4.0),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 10.0,
                fontWeight: FontWeight.w400,
                color: textColor,
                height: 1.0,
                letterSpacing: 0.0,
              ),
            ),
          ],
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
      final slitWidth = w * 0.38;
      final slitHeight = h * 0.14;
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
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(outerPath, strokePaint);

      // Inner slit stroke
      final slitWidth = w * 0.38;
      final slitHeight = h * 0.14;
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
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // 1. Rounded diamond outline
    final cornerRadius = 3.8;
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
      ..strokeWidth = 0.8
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
    final cornerR = 5.0;

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
