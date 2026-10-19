import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Provider Admin Approval Status Card Widget
/// Implements exact Figma branding specifications:
///
/// next card widget branding:
///   width: 350;
///   height: 180;
///   gap: 20px;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 12px;
///   padding: 16px;
///   background: #FFFFFF;
///   box-shadow: 0px 1px 12px 0px #0000001A;
///
/// 3 rows with equal gap (20px):
///   Row 1: Account Details (Completed)
///   Row 2: Document Verification (In Progress / Reviewing)
///   Row 3: Admin Approval (Pending / Waiting)
class ProviderAdminApprovalStatusCard extends StatelessWidget {
  const ProviderAdminApprovalStatusCard({super.key});

  static const double designWidth = 350.0;
  static const double designHeight = 180.0;
  static const double rowGap = 20.0;
  static const double cardPadding = 16.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: Container(
          width: designWidth,
          height: designHeight,
          padding: const EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF), // background: #FFFFFF
            borderRadius: BorderRadius.circular(12.0), // border-radius: 12px
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000), // box-shadow: 0px 1px 12px 0px #0000001A
                offset: Offset(0, 1),
                blurRadius: 12.0,
                spreadRadius: 0.0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1st row branding: Account Details (Completed)
              _buildRow(
                leftIcon: const _FolderLeftIcon(),
                title: 'Account Details',
                subtitle: 'Your basic information has been submitted.',
                statusBadge: const _CompletedStatusBadge(),
              ),

              const SizedBox(height: rowGap), // gap: 20px

              // 2nd row branding: Document Verification (In Progress)
              _buildRow(
                leftIcon: const _IdCardLeftIcon(),
                title: 'Document Verification',
                subtitle: 'We are reviewing your documents.',
                statusBadge: const _InProgressStatusBadge(),
              ),

              const SizedBox(height: rowGap), // gap: 20px

              // 3rd row branding: Admin Approval (Pending)
              _buildRow(
                leftIcon: const _ApprovalCheckLeftIcon(),
                title: 'Admin Approval',
                subtitle: 'Final Approval from our team.',
                statusBadge: const _PendingStatusBadge(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow({
    required Widget leftIcon,
    required String title,
    required String subtitle,
    required Widget statusBadge,
  }) {
    return SizedBox(
      width: 318.0, // width: 318; height: 36; justify-content: space-between;
      height: 36.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Content Layout: width: 253; height: 36; gap: 12px;
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left-side icon branding: width: 36; height: 36; border-radius: 8px;
                leftIcon,

                // Gap: 12px
                const SizedBox(width: 12.0),

                // Content layout: width: 205; height: 28;
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Content: Title (Inter 500 Medium 12px #1C2926)
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500, // Medium 500
                          color: const Color(0xFF1C2926),
                          height: 1.25,
                          letterSpacing: 0.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2.0),
                      // Content: Subtitle (Inter 400 Regular 10px #566663)
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w400, // Regular 400
                          color: const Color(0xFF566663),
                          height: 1.2,
                          letterSpacing: 0.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8.0),

          // Right side icon branding: width: 20; height: 20; border-radius: 37.81px;
          statusBadge,
        ],
      ),
    );
  }
}

/// Row 1 Left Icon: Folder icon inside 36x36 container
class _FolderLeftIcon extends StatelessWidget {
  const _FolderLeftIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.0,
      height: 36.0,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5F2), // soft neutral mint container
        borderRadius: BorderRadius.circular(8.0), // border-radius: 8px
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(20.0, 20.0),
          painter: _FolderIconPainter(),
        ),
      ),
    );
  }
}

/// CustomPainter for the Folder + Document icon (#1D8070)
class _FolderIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1D8070)
      ..style = PaintingStyle.fill;

    // Back document / folder tab
    final backPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.15, size.width * 0.10, size.width * 0.70, size.height * 0.55),
          const Radius.circular(2.5),
        ),
      );
    canvas.drawPath(backPath, paint);

    // Front folder body with tab
    final frontPath = Path()
      ..moveTo(size.width * 0.10, size.height * 0.38)
      ..lineTo(size.width * 0.40, size.height * 0.38)
      ..lineTo(size.width * 0.48, size.height * 0.48)
      ..lineTo(size.width * 0.90, size.height * 0.48)
      ..quadraticBezierTo(size.width * 0.94, size.height * 0.48, size.width * 0.94, size.height * 0.54)
      ..lineTo(size.width * 0.94, size.height * 0.86)
      ..quadraticBezierTo(size.width * 0.94, size.height * 0.92, size.width * 0.88, size.height * 0.92)
      ..lineTo(size.width * 0.16, size.height * 0.92)
      ..quadraticBezierTo(size.width * 0.10, size.height * 0.92, size.width * 0.10, size.height * 0.86)
      ..close();

    canvas.drawPath(frontPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Row 2 Left Icon: ID Card / Document with silhouette inside 36x36 container
class _IdCardLeftIcon extends StatelessWidget {
  const _IdCardLeftIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.0,
      height: 36.0,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5F2),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(20.0, 16.0),
          painter: _IdCardIconPainter(),
        ),
      ),
    );
  }
}

/// CustomPainter for the ID Card icon (#1D8070)
class _IdCardIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = const Color(0xFF1D8070)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFF1D8070)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    // Card outline
    final cardRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.8, 0.8, size.width - 1.6, size.height - 1.6),
      const Radius.circular(3.0),
    );
    canvas.drawRRect(cardRRect, strokePaint);

    // Person head
    canvas.drawCircle(Offset(size.width * 0.32, size.height * 0.40), 2.4, fillPaint);

    // Person shoulders
    final shoulderPath = Path()
      ..moveTo(size.width * 0.18, size.height * 0.76)
      ..quadraticBezierTo(size.width * 0.32, size.height * 0.56, size.width * 0.46, size.height * 0.76)
      ..close();
    canvas.drawPath(shoulderPath, fillPaint);

    // 3 lines on right side
    final linePaint = Paint()
      ..color = const Color(0xFF1D8070)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(size.width * 0.58, size.height * 0.36), Offset(size.width * 0.84, size.height * 0.36), linePaint);
    canvas.drawLine(Offset(size.width * 0.58, size.height * 0.54), Offset(size.width * 0.84, size.height * 0.54), linePaint);
    canvas.drawLine(Offset(size.width * 0.58, size.height * 0.72), Offset(size.width * 0.76, size.height * 0.72), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Row 3 Left Icon: Circular Badge with checkmark inside 36x36 container
class _ApprovalCheckLeftIcon extends StatelessWidget {
  const _ApprovalCheckLeftIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.0,
      height: 36.0,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5F2),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Container(
          width: 20.0,
          height: 20.0,
          decoration: const BoxDecoration(
            color: Color(0xFF1D8070),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              size: 13.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Row 1 Right Status Badge: Completed green checkmark
class _CompletedStatusBadge extends StatelessWidget {
  const _CompletedStatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.0,
      height: 20.0,
      decoration: const BoxDecoration(
        color: Color(0xFFDDF0E3), // background: #DDF0E3
        shape: BoxShape.circle, // border-radius: 37.81px
      ),
      child: Center(
        child: Container(
          width: 15.12, // width: 15.124969482421875
          height: 15.12, // height: 15.124969482421875
          decoration: const BoxDecoration(
            color: Color(0xFF1D8070), // background: #1D8070
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              size: 10.5,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Row 2 Right Status Badge: In Progress orange/amber clock
class _InProgressStatusBadge extends StatelessWidget {
  const _InProgressStatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.0,
      height: 20.0,
      decoration: const BoxDecoration(
        color: Color(0xFFFEF3E2), // soft amber ring
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 15.12,
          height: 15.12,
          decoration: const BoxDecoration(
            color: Color(0xFFFFAE00), // #FFAE00 amber
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: CustomPaint(
              size: Size(10.0, 10.0),
              painter: _ClockHandsPainter(
                hourAngle: 0.0, // pointing up to 12
                minuteAngle: 0.5 * math.pi, // pointing right to 3
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Row 3 Right Status Badge: Pending gray clock
class _PendingStatusBadge extends StatelessWidget {
  const _PendingStatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.0,
      height: 20.0,
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6), // soft gray ring
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 15.12,
          height: 15.12,
          decoration: const BoxDecoration(
            color: Color(0xFF7F8584), // slate gray
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: CustomPaint(
              size: Size(10.0, 10.0),
              painter: _ClockHandsPainter(
                hourAngle: 0.0, // pointing up to 12
                minuteAngle: 0.25 * math.pi, // pointing to 1:30
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// CustomPainter for crisp clock hands inside 15x15 circle
class _ClockHandsPainter extends CustomPainter {
  final double hourAngle;
  final double minuteAngle;

  const _ClockHandsPainter({
    required this.hourAngle,
    required this.minuteAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round;

    // Hour hand (shorter)
    final hourLength = size.width * 0.28;
    final hourEnd = Offset(
      center.dx + hourLength * math.sin(hourAngle),
      center.dy - hourLength * math.cos(hourAngle),
    );
    canvas.drawLine(center, hourEnd, paint);

    // Minute hand (longer)
    final minuteLength = size.width * 0.38;
    final minuteEnd = Offset(
      center.dx + minuteLength * math.sin(minuteAngle),
      center.dy - minuteLength * math.cos(minuteAngle),
    );
    canvas.drawLine(center, minuteEnd, paint);
  }

  @override
  bool shouldRepaint(covariant _ClockHandsPainter oldDelegate) =>
      oldDelegate.hourAngle != hourAngle || oldDelegate.minuteAngle != minuteAngle;
}
