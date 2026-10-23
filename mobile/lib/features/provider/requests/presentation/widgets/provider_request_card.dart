import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';

/// Provider Request Card Widget
/// Implements exact Figma branding specifications:
///
/// Selected card branding:
///   background: #F4EFFE;
///   border: 1px solid #8B53FE;
///   height: 98;
///
/// Remaining (unselected) cards:
///   background: #FFFFFF;
///   box-shadow: 0px 1px 12px 0px #0000001A;
///   border: null (no purple border)
///   height: 96;
///
/// Inner content branding:
///   left side img: width: 64; height: 64; border-radius: 12px;
///   content layout: width: 236; height: 64; gap: 12px;
///   1st row: badge: "New Request" (#EAE0FE bg, #8B53FE text) + time: "Just now" (#616166 10px)
///   2nd & 3rd row: Title: "Battery Jump Start" (Inter 500 14px #252527) + "Location • Distance" + chevron >
class ProviderRequestCard extends StatelessWidget {
  final String title;
  final String location;
  final String distance;
  final String timeText;
  final String badgeText;
  final String imageAsset;
  final bool isSelected;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final double? height;
  final Color badgeBackgroundColor;
  final Color badgeTextColor;
  final VoidCallback? onTap;

  const ProviderRequestCard({
    super.key,
    required this.title,
    required this.location,
    required this.distance,
    this.timeText = 'Just now',
    this.badgeText = 'New Request',
    this.imageAsset = 'assets/images/img.png',
    this.isSelected = false,
    this.backgroundColor,
    this.borderColor,
    this.boxShadow,
    this.height,
    this.badgeBackgroundColor = const Color(0xFFEAE0FE),
    this.badgeTextColor = const Color(0xFF8B53FE),
    this.onTap,
  });

  /// Highlighted constructor (explicitly forced selected style)
  const ProviderRequestCard.highlighted({
    super.key,
    required this.title,
    required this.location,
    required this.distance,
    this.timeText = 'Just now',
    this.badgeText = 'New Request',
    this.imageAsset = 'assets/images/img.png',
    this.isSelected = true,
    this.backgroundColor = const Color(0xFFF4EFFE),
    this.borderColor = const Color(0xFF8B53FE),
    this.boxShadow,
    this.height = 98.0,
    this.badgeBackgroundColor = const Color(0xFFEAE0FE),
    this.badgeTextColor = const Color(0xFF8B53FE),
    this.onTap,
  });

  static const double designWidth = 350.0;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;

    // Selected card: background: #F4EFFE; border: 1px solid #8B53FE;
    // Remaining cards: background: #FFFFFF; box-shadow: 0px 1px 12px 0px #0000001A; border will not purple
    final Color effectiveBackgroundColor = backgroundColor ??
        (isSelected ? const Color(0xFFF4EFFE) : Colors.white);

    final Color? effectiveBorderColor = borderColor ??
        (isSelected ? const Color(0xFF8B53FE) : null);

    final List<BoxShadow>? effectiveBoxShadow = boxShadow ??
        (isSelected
            ? null
            : const [
                BoxShadow(
                  color: Color(0x1A000000), // 0px 1px 12px 0px #0000001A
                  offset: Offset(0, 1),
                  blurRadius: 12.0,
                  spreadRadius: 0.0,
                ),
              ]);

    final double effectiveHeight = height ?? (isSelected ? 98.0 : 96.0);

    return Container(
      width: designWidth,
      height: effectiveHeight,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(16.0), // border-radius: 16px
        border: effectiveBorderColor != null
            ? Border.all(
                color: effectiveBorderColor,
                width: 1.0,
              )
            : null,
        boxShadow: effectiveBoxShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // padding: 16px
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Left Side Image: width: 64; height: 64; border-radius: 12px;
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    imageAsset,
                    width: 64.0,
                    height: 64.0,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 64.0,
                        height: 64.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAE0FE),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: const Icon(
                          Icons.car_repair_rounded,
                          color: Color(0xFF8B53FE),
                          size: 28.0,
                        ),
                      );
                    },
                  ),
                ),

                // gap: 16px
                const SizedBox(width: 16.0),

                // 2. Content Layout: width: 236; height: 64; gap: 12px;
                Expanded(
                  child: SizedBox(
                    height: 64.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 1st Row: Badge on left + Time on right (height: 23)
                        SizedBox(
                          height: 23.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Badge Layout: height: 23; border-radius: 20px; background: #EAE0FE;
                              Container(
                                height: 23.0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeBackgroundColor,
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Center(
                                  child: Text(
                                    badgeText,
                                    style: isArabic
                                        ? GoogleFonts.cairo(
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w500,
                                            color: badgeTextColor,
                                            height: 1.0,
                                          )
                                        : GoogleFonts.inter(
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w400,
                                            color: badgeTextColor,
                                            height: 1.0,
                                            letterSpacing: 0.0,
                                          ),
                                  ),
                                ),
                              ),

                              // Right Side Badge Branding: Time
                              Text(
                                timeText,
                                style: isArabic
                                    ? GoogleFonts.cairo(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF616166),
                                        height: 1.0,
                                      )
                                    : GoogleFonts.inter(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF616166),
                                        height: 1.0,
                                        letterSpacing: 0.0,
                                      ),
                              ),
                            ],
                          ),
                        ),

                        // 2nd & 3rd Row Layout: height: 29; justify-content: space-between
                        SizedBox(
                          height: 29.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Text Content (Title + Location/Distance)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // 2nd Row: Title (Inter 500 14px line-height 24px #252527)
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: isArabic
                                          ? GoogleFonts.cairo(
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF252527),
                                              height: 1.15,
                                            )
                                          : GoogleFonts.inter(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF252527),
                                              height: 1.15,
                                              letterSpacing: 0.0,
                                            ),
                                    ),

                                    const SizedBox(height: 2.0),

                                    // 3rd Row Content: Location • Distance
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Location Text
                                        Flexible(
                                          child: Text(
                                            location,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: isArabic
                                                ? GoogleFonts.cairo(
                                                    fontSize: 10.0,
                                                    fontWeight: FontWeight.w400,
                                                    color: const Color(0xFF616166),
                                                    height: 1.0,
                                                  )
                                                : GoogleFonts.inter(
                                                    fontSize: 10.0,
                                                    fontWeight: FontWeight.w400,
                                                    color: const Color(0xFF616166),
                                                    height: 1.0,
                                                    letterSpacing: 0.0,
                                                  ),
                                          ),
                                        ),

                                        const SizedBox(width: 8.0), // gap: 8px

                                        // Ellipse Dot: width: 4; height: 4; background: #616166;
                                        Container(
                                          width: 4.0,
                                          height: 4.0,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF616166),
                                            shape: BoxShape.circle,
                                          ),
                                        ),

                                        const SizedBox(width: 8.0), // gap: 8px

                                        // Distance Text
                                        Text(
                                          distance,
                                          style: isArabic
                                              ? GoogleFonts.cairo(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color(0xFF616166),
                                                  height: 1.0,
                                                )
                                              : GoogleFonts.inter(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.w400,
                                                  color: const Color(0xFF616166),
                                                  height: 1.0,
                                                  letterSpacing: 0.0,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8.0),

                              // > Chevron Branding: width: 6.06; height: 12.87;
                              Transform.flip(
                                flipX: isArabic,
                                child: const SizedBox(
                                  width: 6.06,
                                  height: 12.87,
                                  child: CustomPaint(
                                    painter: _CardChevronPainter(
                                      color: Color(0xFF616166),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Precise CustomPainter for `>` branding (width: 6.06, height: 12.87, stroke: 1.2px)
class _CardChevronPainter extends CustomPainter {
  final Color color;

  const _CardChevronPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0.5, 0.5)
      ..lineTo(size.width - 0.5, size.height / 2.0)
      ..lineTo(0.5, size.height - 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CardChevronPainter oldDelegate) =>
      color != oldDelegate.color;
}
