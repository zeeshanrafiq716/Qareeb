import 'package:flutter/material.dart';

/// Notification Popup Card
/// Implements exact Figma branding and layout specifications:
///
/// notification card layout after click on icon:
///   width: 350;
///   height: 96;
///   gap: 16px;
///   angle: 0 deg;
///   opacity: 1;
///   top: 106px;
///   left: 21px;
///   border-radius: 12px;
///   padding: 16px;
///   background: #FFFFFF;
///   box-shadow: 0px 1px 16px 0px #0000001F;
///
/// card inner layout img branding:
///   width: 63.999996185302734;
///   height: 64;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 12px;
///
/// content layout:
///   width: 238;
///   height: 64;
///   gap: 12px;
///   angle: 0 deg;
///   opacity: 1;
///
/// content layout row 1:
///   width: 238;
///   height: 23;
///   justify-content: space-between;
///   - badge branding: width: 80; height: 23; gap: 10px; border-radius: 20px; padding: 8px; bg: #F3F2F5;
///     - New Request: 10px, 400, #8B53FE
///   - Just now: 10px, 400, #616166
///
/// row 2,3 layout:
///   width: 238;
///   height: 29;
///   justify-content: space-between;
///   - row 2,3 content branding: width: 199; height: 29; gap: 12px;
///     - Battery Jump Start: 14px, 500, #1C2926
///     - row 3 content layout: width: 199; height: 7; gap: 8px;
///       - King Abdullah Rd, Riyadh: 10px, 400, #616166
///       - ellipse branding: 4x4 circle #616166
///       - 4.1 km  away: 10px, 400, #616166
///   - > branding: width: 6.06; height: 12.87; border: 1px solid #616166;
class NotificationPopupCard extends StatelessWidget {
  final String badgeText;
  final String title;
  final String location;
  final String distance;
  final String time;
  final String? imageAsset;
  final double? width;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationPopupCard({
    super.key,
    this.badgeText = 'New Request',
    this.title = 'Battery Jump Start',
    this.location = 'King Abdullah Rd, Riyadh',
    this.distance = '4.1 km  away',
    this.time = 'Just now',
    this.imageAsset,
    this.width,
    this.onTap,
    this.onDismiss,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 96.0;
  static const double designTop = 106.0;
  static const double designLeft = 21.0;
  static const double designPadding = 16.0;
  static const double designGap = 16.0;
  static const double imgWidth = 63.999996185302734;
  static const double imgHeight = 64.0;
  static const double contentHeight = 64.0;
  static const double contentGap = 12.0;

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl ||
        Localizations.maybeLocaleOf(context)?.languageCode == 'ar';
    final String trimmedImage = imageAsset?.trim() ?? '';
    final bool hasImage = trimmedImage.isNotEmpty;
    final bool isNetworkImage = trimmedImage.startsWith('http://') ||
        trimmedImage.startsWith('https://');
    final String trimmedLocation = location.trim();
    final String trimmedDistance = distance.trim();

    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 82.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 13.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 16.0,
            offset: Offset(0, 2),
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? onDismiss,
          borderRadius: BorderRadius.circular(14.0),
          splashColor: const Color(0xFF8B53FE).withValues(alpha: 0.08),
          highlightColor: const Color(0xFF8B53FE).withValues(alpha: 0.04),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Only render profile image + gap if a real profile image is available (no blank gap!)
              if (hasImage) ...[
                Container(
                  width: 52.0,
                  height: 52.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F2F5),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: isNetworkImage
                      ? Image.network(
                          trimmedImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person_rounded, color: Color(0xFF8B53FE), size: 26.0),
                        )
                      : Image.asset(
                          trimmedImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person_rounded, color: Color(0xFF8B53FE), size: 26.0),
                        ),
                ),
                const SizedBox(width: 12.0),
              ],

              // Content Layout — uses full available width cleanly without truncated dots
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Badge + Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F2F5),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 10.5,
                              color: Color(0xFF8B53FE),
                              height: 1.1,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          time,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 10.5,
                            color: Color(0xFF616166),
                            height: 1.1,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8.0),

                    // Row 2 & 3: Title + Full Message / Distance + Chevron
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.0,
                                  color: Color(0xFF1C2926),
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                softWrap: true,
                              ),
                              if (trimmedLocation.isNotEmpty || trimmedDistance.isNotEmpty) ...[
                                const SizedBox(height: 4.0),
                                Text(
                                  trimmedLocation.isNotEmpty && trimmedDistance.isNotEmpty
                                      ? '$trimmedLocation • $trimmedDistance'
                                      : (trimmedLocation.isNotEmpty
                                          ? trimmedLocation
                                          : trimmedDistance),
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11.5,
                                    color: Color(0xFF616166),
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  softWrap: true,
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(width: 10.0),

                        Transform.scale(
                          scaleX: isRtl ? -1.0 : 1.0,
                          child: SizedBox(
                            width: 6.06,
                            height: 12.87,
                            child: CustomPaint(
                              painter: const _ChevronPainter(
                                color: Color(0xFF616166),
                              ),
                            ),
                          ),
                        ),
                      ],
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

/// Precise Chevron Icon Painter (width: 6.06; height: 12.87; 1px solid #616166)
class _ChevronPainter extends CustomPainter {
  final Color color;

  const _ChevronPainter({
    this.color = const Color(0xFF616166),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0.5, 0.5)
      ..lineTo(size.width - 0.5, size.height / 2)
      ..lineTo(0.5, size.height - 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) =>
      color != oldDelegate.color;
}
