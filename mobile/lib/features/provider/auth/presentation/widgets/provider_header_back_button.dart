import 'package:flutter/material.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';

/// Provider Header Back Button Widget
/// Implements exact Figma branding specifications:
///
/// icon ellipse:
///   width: 36;
///   height: 36;
///   angle: 0 deg;
///   opacity: 1;
///   background: #FFFFFF;
///
/// < branding:
///   width: 6;
///   height: 13;
///   top: 12px;
///   left: 15px;
///   angle: 0 deg;
///   opacity: 1;
///   border-width: 1px;
///   background: #FFFFFF;
///   border: 1px solid #1C2926;
class ProviderHeaderBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const ProviderHeaderBackButton({
    super.key,
    this.onTap,
  });

  static const double designWidth = 36.0;
  static const double designHeight = 36.0;
  static const double chevronWidth = 6.0;
  static const double chevronHeight = 13.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: Container(
          width: designWidth,
          height: designHeight,
          decoration: const BoxDecoration(
            color: ProviderColors.cardBackground, // background: #FFFFFF
            shape: BoxShape.circle, // icon ellipse: width: 36; height: 36;
            boxShadow: [
              BoxShadow(
                color: ProviderColors.cardShadow, // #00000014
                offset: Offset(0, 1),
                blurRadius: 8.0,
                spreadRadius: 0.0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap ?? () => Navigator.of(context).maybePop(),
              customBorder: const CircleBorder(),
              child: Center(
                child: Transform.flip(
                  flipX: false,
                  child: const SizedBox(
                    width: chevronWidth,
                    height: chevronHeight,
                    child: CustomPaint(
                      painter: _HeaderChevronPainter(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Precise CustomPainter for `<` branding
/// width: 6; height: 13; border: 1px solid #1C2926
class _HeaderChevronPainter extends CustomPainter {
  const _HeaderChevronPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ProviderColors.cardTitle // #1C2926
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width - 0.5, 0.5)
      ..lineTo(0.5, size.height / 2)
      ..lineTo(size.width - 0.5, size.height - 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
