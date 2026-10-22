import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Step Card Layout Widget
/// Implements exact Figma branding specifications:
///
/// 1st card layout:
///   width: 350;
///   height: 68;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 12px;
///   border-radius: 12px;
///   padding: 16px;
///   background: #F2F5F4;
///
/// icon layout:
///   width: 36;
///   height: 36;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 8px;
///   background: #E2F0E6;
///
/// icon layout:
///   width: 15.999999046325684;
///   height: 19.471717834472656;
///   angle: 0 deg;
///   opacity: 1;
///   top: 8px;
///   left: 10px;
///   background: #1C2926;
///
/// content branding:
///   width: 270;
///   height: 29;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 12px;
///
/// content: Complete  Your Profile
///   font-family: Inter; font-weight: 500 (Medium); font-size: 14px;
///   line-height: 22px; color: #1C2926;
///
/// content: Add your business details, services, and location.
///   font-family: Inter; font-weight: 400 (Regular); font-size: 10px;
///   line-height: 22px; color: #566663;
class ProviderStepCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? iconWidget;
  final VoidCallback? onTap;

  const ProviderStepCard({
    super.key,
    this.title = 'Complete  Your Profile',
    this.subtitle = 'Add your business details, services, and location.',
    this.iconWidget,
    this.onTap,
  });

  /// Factory for 1st Card: "Complete  Your Profile"
  const ProviderStepCard.profile({
    super.key,
    this.title = 'Complete  Your Profile',
    this.subtitle = 'Add your business details, services, and location.',
    this.onTap,
  }) : iconWidget = const SizedBox(
          width: 16.0,
          height: 19.47,
          child: CustomPaint(
            painter: _ProfileVectorIconPainter(),
          ),
        );

  /// Factory for 2nd Card: "Get Verified"
  const ProviderStepCard.getVerified({
    super.key,
    this.title = 'Get Verified',
    this.subtitle = 'Build customer trust with a complete and verified profile.',
    this.onTap,
  }) : iconWidget = const SizedBox(
          width: 16.0,
          height: 19.47,
          child: CustomPaint(
            painter: _ShieldCheckIconPainter(),
          ),
        );

  /// Factory for 3rd Card: "Start Receiving Requests"
  const ProviderStepCard.startReceivingRequests({
    super.key,
    this.title = 'Start Receiving Requests',
    this.subtitle = 'Go online and start receiving service requests.',
    this.onTap,
  }) : iconWidget = const SizedBox(
          width: 16.0,
          height: 19.47,
          child: CustomPaint(
            painter: _BellVectorIconPainter(),
          ),
        );

  static const double designWidth = 350.0;
  static const double designHeight = 68.0;
  static const double designGap = 12.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: designHeight),
          decoration: BoxDecoration(
            color: ProviderColors.inputBackground, // background: #F2F5F4
            borderRadius: BorderRadius.circular(12.0), // border-radius: 12px
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0), // padding: 16px
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  // 1. Icon Box: width: 36; height: 36; border-radius: 8px; background: #E2F0E6;
                  Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      color: ProviderColors.profileIconBackground, // #E2F0E6
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Center(
                      child: iconWidget ??
                          const SizedBox(
                            width: 16.0,
                            height: 19.47,
                            child: CustomPaint(
                              painter: _ProfileVectorIconPainter(),
                            ),
                          ),
                    ),
                  ),

                  // gap: 12px;
                  const SizedBox(width: designGap),

                  // 2. Content Branding: width: 270; height: 29;
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // content: Complete Your Profile (Inter 500 14px line-height 22px #1C2926)
                        Text(
                          context.isArabic ? context.auto(title) : title,
                          style: ProviderTextStyles.stepCardTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 2.0),

                        // content: Add your business details, services, and location. (Inter 400 10px #566663)
                        Text(
                          context.isArabic ? context.auto(subtitle) : subtitle,
                          style: ProviderTextStyles.stepCardSubtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}

/// Vector Painter for Profile icon (width: 16, height: 19.47, color: #1C2926)
class _ProfileVectorIconPainter extends CustomPainter {
  const _ProfileVectorIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ProviderColors.cardTitle // #1C2926
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final double cx = size.width / 2.0;

    // 1. Head circle: diameter ~6.8
    canvas.drawCircle(Offset(cx, 4.2), 3.4, paint);

    // 2. Torso / Shoulders solid curve
    final bodyPath = Path()
      ..moveTo(0.5, size.height)
      ..cubicTo(0.5, 11.5, cx - 3.5, 9.8, cx, 9.8)
      ..cubicTo(cx + 3.5, 9.8, size.width - 0.5, 11.5, size.width - 0.5, size.height)
      ..close();

    canvas.drawPath(bodyPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vector Painter for Shield Check icon (width: 16, height: 19.47, color: #1C2926)
class _ShieldCheckIconPainter extends CustomPainter {
  const _ShieldCheckIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = ProviderColors.cardTitle // #1C2926
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final double cx = size.width / 2.0;

    // Solid shield path
    final path = Path()
      ..moveTo(cx, 0.5)
      ..quadraticBezierTo(size.width * 0.85, 0.5, size.width - 0.5, 3.5)
      ..lineTo(size.width - 0.5, size.height * 0.55)
      ..cubicTo(size.width - 0.5, size.height * 0.85, cx, size.height, cx, size.height)
      ..cubicTo(cx, size.height, 0.5, size.height * 0.85, 0.5, size.height * 0.55)
      ..lineTo(0.5, 3.5)
      ..quadraticBezierTo(size.width * 0.15, 0.5, cx, 0.5)
      ..close();

    canvas.drawPath(path, fillPaint);

    // White checkmark inside shield
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final checkPath = Path()
      ..moveTo(cx - 3.5, size.height * 0.50)
      ..lineTo(cx - 1.0, size.height * 0.62)
      ..lineTo(cx + 3.8, size.height * 0.40);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vector Painter for Bell Notification icon (width: 16, height: 19.47, color: #1C2926)
class _BellVectorIconPainter extends CustomPainter {
  const _BellVectorIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ProviderColors.cardTitle // #1C2926
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final double cx = size.width / 2.0;

    // Top loop / handle
    canvas.drawCircle(Offset(cx, 1.8), 1.4, paint);

    // Bell body with flare
    final bellPath = Path()
      ..moveTo(cx - 3.0, 3.2)
      ..cubicTo(cx - 5.5, 3.5, cx - 6.5, 7.0, cx - 6.5, 12.0)
      ..lineTo(cx - 7.5, 14.5)
      ..quadraticBezierTo(cx - 7.5, 15.5, cx - 6.0, 15.5)
      ..lineTo(cx + 6.0, 15.5)
      ..quadraticBezierTo(cx + 7.5, 15.5, cx + 7.5, 14.5)
      ..lineTo(cx + 6.5, 12.0)
      ..cubicTo(cx + 6.5, 7.0, cx + 5.5, 3.5, cx + 3.0, 3.2)
      ..close();

    canvas.drawPath(bellPath, paint);

    // Clapper dot at bottom
    canvas.drawCircle(Offset(cx, 18.0), 1.8, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
