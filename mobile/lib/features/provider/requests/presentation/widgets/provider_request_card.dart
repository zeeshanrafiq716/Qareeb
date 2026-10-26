import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';

/// Provider Request Card Widget
/// Implements exact Figma branding specifications:
///
/// completed, pending, in progress, cancelled cards design layout branding:
///   width: 350;
///   height: 124;
///   gap: 16px;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 12px;
///   padding: 16px;
///   background: #FFFFFF;
///   box-shadow: 0px 1px 12px 0px #0000001A;
///
/// img layout:
///   width: 92;
///   height: 92;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 12px;
///
/// content layout:
///   width: 210;
///   height: 92;
///   justify-content: space-between;
///   angle: 0 deg;
///   opacity: 1;
///
/// 1st row content layout:
///   width: 203;
///   height: 19;
///   gap: 76px;
///   angle: 0 deg;
///   opacity: 1;
///
/// 2nd row content layout:
///   Battery Jump Start
///   width: 109;
///   height: 9;
///   font-family: Inter; font-weight: 500 (Medium); font-size: 12px;
///   line-height: 24px; color: #252527;
///
/// 3rd row layout:
///   width: 203;
///   height: 20;
///   gap: 8px;
///   angle: 0 deg;
///   opacity: 1;
///   3rd row img layout: width: 20; height: 20;
///   Ahmed Khan: font-family: Inter; font-weight: 400; font-size: 12px; color: #252527;
///
/// 4th row layout:
///   width: 203;
///   height: 10;
///   gap: 8px;
///   angle: 0 deg;
///   opacity: 1;
///   location vector layout: width: 9; height: 10; background: #616166;
///   King Abdullah Rd, Riyadh: font-family: Inter; font-weight: 400; font-size: 10px; color: #616166;
///   ellipse branding: width: 4; height: 4; background: #616166;
///   4.1km: font-family: Inter; font-weight: 400; font-size: 10px; color: #616166;
class ProviderRequestCard extends StatelessWidget {
  final String? title;
  final String? location;
  final String? distance;
  final String? timeText;
  final String? badgeText;
  final String? imageAsset;
  final String? customerName;
  final String? customerAvatarAsset;
  final bool isSelected;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final double? height;
  final double? width;
  final Color? badgeBackgroundColor;
  final Color? badgeTextColor;
  final bool showChevron;
  final VoidCallback? onTap;

  const ProviderRequestCard({
    super.key,
    this.title,
    this.location,
    this.distance,
    this.timeText = '10:24 PM',
    this.badgeText = 'Completed',
    this.imageAsset = 'assets/images/img.png',
    this.customerName = 'Ahmed Khan',
    this.customerAvatarAsset,
    this.isSelected = false,
    this.backgroundColor,
    this.borderColor,
    this.boxShadow,
    this.height,
    this.width,
    this.badgeBackgroundColor,
    this.badgeTextColor,
    this.showChevron = true,
    this.onTap,
  });

  /// Highlighted constructor (explicitly forced selected style)
  const ProviderRequestCard.highlighted({
    super.key,
    this.title,
    this.location,
    this.distance,
    this.timeText = '10:24 PM',
    this.badgeText = 'Completed',
    this.imageAsset = 'assets/images/img.png',
    this.customerName = 'Ahmed Khan',
    this.customerAvatarAsset,
    this.isSelected = true,
    this.backgroundColor = const Color(0xFFF4EFFE),
    this.borderColor = const Color(0xFF8B53FE),
    this.boxShadow,
    this.height = 124.0,
    this.width,
    this.badgeBackgroundColor,
    this.badgeTextColor,
    this.showChevron = true,
    this.onTap,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 124.0;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;

    // Safe fallbacks to prevent any null string runtime errors
    final String effectiveTitle = (title != null && title!.isNotEmpty)
        ? title!
        : (isArabic ? 'شحن وتبديل بطارية' : 'Battery Jump Start');
    final String effectiveLocation = (location != null && location!.isNotEmpty)
        ? location!
        : (isArabic ? 'طريق الملك عبدالله، الرياض' : 'King Abdullah Rd, Riyadh');
    final String effectiveDistance = (distance != null && distance!.isNotEmpty)
        ? distance!
        : (isArabic ? '٤.١ كم' : '4.1km');
    final String effectiveTime = (timeText != null && timeText!.isNotEmpty)
        ? timeText!
        : '10:24 PM';
    final String effectiveBadge = (badgeText != null && badgeText!.isNotEmpty)
        ? badgeText!
        : (isArabic ? 'مكتمل' : 'Completed');
    final String effectiveImage = (imageAsset != null && imageAsset!.isNotEmpty)
        ? imageAsset!
        : 'assets/images/img.png';
    final String effectiveCustomer =
        (customerName != null && customerName!.isNotEmpty)
            ? customerName!
            : (isArabic ? 'أحمد خان' : 'Ahmed Khan');
    final String effectiveAvatar =
        (customerAvatarAsset != null && customerAvatarAsset!.isNotEmpty)
            ? customerAvatarAsset!
            : 'assets/images/ahmed_khan.jpg';

    // Card branding:
    // width: 350; height: 124; gap: 16px; border-radius: 12px; padding: 16px;
    // background: #FFFFFF; box-shadow: 0px 1px 12px 0px #0000001A;
    final Color effectiveBackgroundColor = backgroundColor ??
        (isSelected ? const Color(0xFFF4EFFE) : const Color(0xFFFFFFFF));

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

    final double effectiveHeight = height ?? designHeight;

    // Badge colors according to status branding:
    final Color effectiveBadgeBgColor = badgeBackgroundColor ??
        _resolveBadgeBgColor(effectiveBadge);
    final Color effectiveBadgeTextColor = badgeTextColor ??
        _resolveBadgeTextColor(effectiveBadge);

    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: Container(
          width: width ?? double.infinity,
          constraints: const BoxConstraints(maxWidth: designWidth),
          height: effectiveHeight,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(12.0), // border-radius: 12px
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
            borderRadius: BorderRadius.circular(12.0),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0), // padding: 16px
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. img layout: width: 92; height: 92; angle: 0 deg; opacity: 1; border-radius: 12px;
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.asset(
                        effectiveImage,
                        width: 92.0,
                        height: 92.0,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 92.0,
                            height: 92.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F2F5),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.build_rounded,
                                color: Color(0xFF8B53FE),
                                size: 36.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // gap: 16px;
                    const SizedBox(width: 16.0),

                    // 2. content layout: width: 210; height: 92; justify-content: space-between;
                    Expanded(
                      child: SizedBox(
                        height: 92.0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Text columns: 1st, 2nd, 3rd, 4th row layouts
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 1st row content layout: width: 203; height: 19; gap: 76px;
                                  SizedBox(
                                    height: 19.0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Badge Pill: height: 19; border-radius: 20px;
                                        Container(
                                          height: 19.0,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 2.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: effectiveBadgeBgColor,
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            effectiveBadge,
                                            style: (isArabic
                                                ? GoogleFonts.cairo
                                                : GoogleFonts.inter)(
                                              fontSize: isArabic ? 10.0 : 10.5,
                                              fontWeight: FontWeight.w500,
                                              color: effectiveBadgeTextColor,
                                              height: 1.0,
                                            ),
                                          ),
                                        ),

                                        // Time Text (e.g. 10:24 PM):
                                        Text(
                                          effectiveTime,
                                          style: (isArabic
                                              ? GoogleFonts.cairo
                                              : GoogleFonts.inter)(
                                            fontSize: 11.0,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF616166),
                                            height: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 2nd row content layout:
                                  // Battery Jump Start: font-family: Inter; font-weight: 500; font-size: 12px;
                                  // line-height: 24px; color: #252527;
                                  Text(
                                    effectiveTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: (isArabic
                                        ? GoogleFonts.cairo
                                        : GoogleFonts.inter)(
                                      fontSize: isArabic ? 12.5 : 12.0,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF252527),
                                      height: 1.2,
                                    ),
                                  ),

                                  // 3rd row layout: width: 203; height: 20; gap: 8px;
                                  SizedBox(
                                    height: 20.0,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // 3rd row img layout: width: 20; height: 20;
                                        ClipOval(
                                          child: Image.asset(
                                            effectiveAvatar,
                                            width: 20.0,
                                            height: 20.0,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                width: 20.0,
                                                height: 20.0,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFE5E7EB),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.person_rounded,
                                                  size: 13.0,
                                                  color: Color(0xFF616166),
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        // gap: 8px;
                                        const SizedBox(width: 8.0),

                                        // Ahmed Khan: width: 73; height: 9; font-family: Inter;
                                        // font-weight: 400; font-size: 12px; color: #252527;
                                        Expanded(
                                          child: Text(
                                            effectiveCustomer,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: (isArabic
                                                ? GoogleFonts.cairo
                                                : GoogleFonts.inter)(
                                              fontSize: isArabic ? 11.5 : 12.0,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF252527),
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 4th row layout: width: 203; height: 10; gap: 8px;
                                  SizedBox(
                                    height: 12.0,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // location vector layout: width: 9; height: 10; background: #616166;
                                        const SizedBox(
                                          width: 9.0,
                                          height: 10.0,
                                          child: CustomPaint(
                                            painter: _LocationPinPainter(
                                              color: Color(0xFF616166),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 4.0),

                                        // King Abdullah Rd, Riyadh: font-family: Inter; font-weight: 400; font-size: 10px; color: #616166;
                                        Flexible(
                                          child: Text(
                                            effectiveLocation,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: (isArabic
                                                ? GoogleFonts.cairo
                                                : GoogleFonts.inter)(
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF616166),
                                              height: 1.0,
                                            ),
                                          ),
                                        ),

                                        // gap: 8px;
                                        const SizedBox(width: 6.0),

                                        // ellipse branding: width: 4; height: 4; background: #616166;
                                        Container(
                                          width: 4.0,
                                          height: 4.0,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF616166),
                                            shape: BoxShape.circle,
                                          ),
                                        ),

                                        // gap: 8px;
                                        const SizedBox(width: 6.0),

                                        // 4.1km: font-family: Inter; font-weight: 400; font-size: 10px; color: #616166;
                                        Text(
                                          effectiveDistance,
                                          style: (isArabic
                                              ? GoogleFonts.cairo
                                              : GoogleFonts.inter)(
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF616166),
                                            height: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Right Side > Chevron (matching screenshot)
                            if (showChevron) ...[
                              const SizedBox(width: 6.0),
                              Transform.flip(
                                flipX: isArabic || Directionality.of(context) == TextDirection.rtl,
                                child: const SizedBox(
                                  width: 6.5,
                                  height: 13.0,
                                  child: CustomPaint(
                                    painter: _CardChevronPainter(
                                      color: Color(0xFF616166),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
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

  static Color _resolveBadgeBgColor(String? badge) {
    if (badge == null || badge.isEmpty) return const Color(0xFFF4EFFE);
    final lower = badge.toLowerCase();
    if (lower.contains('complet') || lower.contains('مكتمل')) {
      return const Color(0xFFF4EFFE);
    }
    if (lower.contains('pend') || lower.contains('معلق')) {
      return const Color(0xFFFFF7ED);
    }
    if (lower.contains('progress') ||
        lower.contains('تنفيذ') ||
        lower.contains('active') ||
        lower.contains('نشط')) {
      return const Color(0xFFECFDF5);
    }
    if (lower.contains('cancel') || lower.contains('ملغي')) {
      return const Color(0xFFFEF2F2);
    }
    return const Color(0xFFF4EFFE);
  }

  static Color _resolveBadgeTextColor(String? badge) {
    if (badge == null || badge.isEmpty) return const Color(0xFF8B53FE);
    final lower = badge.toLowerCase();
    if (lower.contains('complet') || lower.contains('مكتمل')) {
      return const Color(0xFF8B53FE);
    }
    if (lower.contains('pend') || lower.contains('معلق')) {
      return const Color(0xFFEA580C);
    }
    if (lower.contains('progress') ||
        lower.contains('تنفيذ') ||
        lower.contains('active') ||
        lower.contains('نشط')) {
      return const Color(0xFF059669);
    }
    if (lower.contains('cancel') || lower.contains('ملغي')) {
      return const Color(0xFFDC2626);
    }
    return const Color(0xFF8B53FE);
  }
}

/// Location Vector Pin Painter (width: 9, height: 10, stroke: 1.0px)
class _LocationPinPainter extends CustomPainter {
  final Color color;

  const _LocationPinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;

    final path = Path()
      ..moveTo(w / 2.0, h)
      ..cubicTo(w * 0.1, h * 0.58, 0.5, h * 0.42, 0.5, h * 0.32)
      ..arcToPoint(
        Offset(w - 0.5, h * 0.32),
        radius: Radius.circular((w - 1.0) / 2.0),
      )
      ..cubicTo(w - 0.5, h * 0.42, w * 0.9, h * 0.58, w / 2.0, h)
      ..close();

    canvas.drawPath(path, strokePaint);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w / 2.0, h * 0.32), 1.1, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _LocationPinPainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Precise CustomPainter for `>` branding (width: 6.5, height: 13.0, stroke: 1.2px)
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
