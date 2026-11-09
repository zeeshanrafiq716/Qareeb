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
  final bool isRejected;
  final bool isResubmission;
  final String? title;
  final String? subtitle;

  const ProviderUnderReviewCard({
    super.key,
    this.isRejected = false,
    this.isResubmission = false,
    this.title,
    this.subtitle,
  });

  const ProviderUnderReviewCard.rejected({
    super.key,
    this.isRejected = true,
    this.isResubmission = false,
    this.title,
    this.subtitle,
  });

  const ProviderUnderReviewCard.resubmission({
    super.key,
    this.isRejected = false,
    this.isResubmission = true,
    this.title,
    this.subtitle,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 72.0;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;

    // Card background:
    // When review: #F7F3EB (soft cream)
    // When resubmission: #FFFBEB (amber-50) with subtle amber border #FDE68A
    // When rejected/suspended: #FEF2F2 (soft light red) with subtle border #FEE2E2
    final Color bgColor = isResubmission
        ? const Color(0xFFFFFBEB)
        : (isRejected ? const Color(0xFFFEF2F2) : const Color(0xFFF7F3EB));
    final Border? cardBorder = isResubmission
        ? Border.all(color: const Color(0xFFFDE68A), width: 1.0)
        : (isRejected
            ? Border.all(color: const Color(0xFFFEE2E2), width: 1.0)
            : null);

    // Icon circle branding:
    // When review: outer #FAEAC8, inner #FFAE00 with clock hands
    // When resubmission: outer #FEF3C7, inner #D97706 with refresh icon
    // When rejected: outer #FEE2E2, inner #EF4444 with white close icon
    final Color outerCircleColor = isResubmission
        ? const Color(0xFFFEF3C7)
        : (isRejected ? const Color(0xFFFEE2E2) : const Color(0xFFFAEAC8));
    final Color innerCircleColor = isResubmission
        ? const Color(0xFFD97706)
        : (isRejected ? const Color(0xFFEF4444) : const Color(0xFFFFAE00));

    // Title:
    final String effectiveTitle = title ??
        (isResubmission
            ? (isArabic ? 'مطلوب إعادة تقديم المستندات' : 'Resubmission Requested')
            : (isRejected
                ? (isArabic ? 'تم رفض طلب اعتمادك' : 'Your approval is rejected')
                : (isArabic ? 'طلبك قيد المراجعة' : 'Your Application Is Under Review')));
    final Color titleColor = isResubmission
        ? const Color(0xFFD97706)
        : (isRejected ? const Color(0xFFDC2626) : const Color(0xFFFFAE00));

    // Subtitle:
    final String effectiveSubtitle = subtitle ??
        (isResubmission
            ? (isArabic
                ? 'طلب المشرف إعادة تقديم بعض المستندات. يرجى التحديث والمتابعة.'
                : 'Admin requested document resubmission. Please update and re-submit.')
            : (isRejected
                ? (isArabic
                    ? 'لم يتم اعتماد مستندات حسابك من قبل الإدارة. يرجى مراجعة المستندات أو التواصل مع الدعم.'
                    : "Your account documents were not approved by admin. Please review your submitted documents or contact support.")
                : (isArabic
                    ? 'حسابك لا يزال قيد انتظار الموافقة. سنقوم بإشعارك فور اعتماده.'
                    : "Your account is still pending approval. We'll notify you when it's approved.")));

    return Opacity(
      opacity: 1.0,
      child: Transform.rotate(
        angle: 0.0,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: designHeight),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12.0),
            border: cardBorder,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon branding
              Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: outerCircleColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 24.89,
                    height: 24.89,
                    decoration: BoxDecoration(
                      color: innerCircleColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isResubmission
                          ? const Icon(
                              Icons.refresh_rounded,
                              size: 15.0,
                              color: Colors.white,
                            )
                          : (isRejected
                              ? const Icon(
                                  Icons.close_rounded,
                                  size: 15.0,
                                  color: Colors.white,
                                )
                              : const CustomPaint(
                                  size: Size(15.0, 15.0),
                                  painter: _ReviewClockHandsPainter(),
                                )),
                    ),
                  ),
                ),
              ),

              // Gap: 12px
              const SizedBox(width: 12.0),

              // Right content layout: Title (in red if rejected) + paragraph text
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      effectiveTitle,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 3.0),

                    Text(
                      effectiveSubtitle,
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
