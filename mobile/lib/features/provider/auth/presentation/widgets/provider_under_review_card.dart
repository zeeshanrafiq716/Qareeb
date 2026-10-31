import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';

/// Provider Under Review Card Widget
/// Appears when user taps "Got it" on AdminApprovalScreen while documents/account are pending.
///
/// Designing layout:
///   width: 350;
///   height: 72;
///   gap: 12px;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 12px;
///   padding: 16px;
///   background: #F7F3EB;
///
/// Icon branding:
///   width: 32;
///   height: 32;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 60.5px;
///   background: #FAEAC8;
///
/// Inner branding:
///   width: 24.88888931274414;
///   height: 24.88888931274414;
///   angle: 0 deg;
///   opacity: 1;
///   background: #FFAE00;
///
/// Right content layout:
///   width: 274;
///   height: 40;
///   gap: 12px;
///
/// Title: Your Application Is Under Review
///   font-family: Inter;
///   font-weight: 500 (Medium);
///   font-size: 12px;
///   line-height: 22px;
///   color: #FFAE00;
///
/// Subtitle: Your account is still pending approval. We'll notify you when it's approved.
///   font-family: Inter;
///   font-weight: 400 (Regular);
///   font-size: 10px;
///   line-height: 100%;
///   color: #616166;
class ProviderUnderReviewCard extends StatelessWidget {
  const ProviderUnderReviewCard({super.key});

  static const double designWidth = 350.0;
  static const double designHeight = 72.0;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;

    return Opacity(
      opacity: 1.0,
      child: Transform.rotate(
        angle: 0.0,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: designHeight),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F3EB), // background: #F7F3EB
            borderRadius: BorderRadius.circular(12.0), // border-radius: 12px
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon branding: width: 32; height: 32; border-radius: 60.5px; background: #FAEAC8;
              Container(
                width: 32.0,
                height: 32.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFFAEAC8),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  // Inner branding: width: 24.89; height: 24.89; background: #FFAE00;
                  child: Container(
                    width: 24.89,
                    height: 24.89,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFAE00),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CustomPaint(
                        size: Size(15.0, 15.0),
                        painter: _ReviewClockHandsPainter(),
                      ),
                    ),
                  ),
                ),
              ),

              // Gap: 12px
              const SizedBox(width: 12.0),

              // Right content layout: width: 274; height: 40;
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title: Your Application Is Under Review (Inter 500 12px #FFAE00)
                    Text(
                      isArabic
                          ? 'طلبك قيد المراجعة'
                          : 'Your Application Is Under Review',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFFAE00),
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 3.0),

                    // Subtitle: Your account is still pending approval. We'll notify you when it's approved. (Inter 400 10px #616166)
                    Text(
                      isArabic
                          ? 'حسابك لا يزال قيد انتظار الموافقة. سنقوم بإشعارك فور اعتماده.'
                          : "Your account is still pending approval. We'll notify you when it's approved.",
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.0,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF616166),
                        height: 1.25,
                      ),
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
    );
  }
}

/// CustomPainter for white clock hands matching user screenshot exactly
/// Hour hand pointing up (12 o'clock), minute hand pointing to ~8:20
class _ReviewClockHandsPainter extends CustomPainter {
  const _ReviewClockHandsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    // Small center pivot
    canvas.drawCircle(center, 1.1, Paint()..color = Colors.white);

    // Hour hand pointing straight up to 12
    canvas.drawLine(center, Offset(center.dx, center.dy - 5.5), paint);

    // Minute hand pointing to ~8:20 (down-left, angle 215 degrees)
    const angle = 215.0 * (math.pi / 180.0);
    final minuteEnd = Offset(
      center.dx + 5.0 * math.cos(angle),
      center.dy + 5.0 * math.sin(angle),
    );
    canvas.drawLine(center, minuteEnd, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
