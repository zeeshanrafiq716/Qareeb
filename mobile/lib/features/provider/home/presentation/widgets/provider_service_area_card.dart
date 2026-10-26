import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';

/// Provider Service Area Card Widget
/// Implements exact Figma branding specifications:
///
/// next card layout:
///   width: 350;
///   height: 68;
///   gap: 10px;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 12px;
///   padding: 16px;
///   background: #FFFFFF;
///   box-shadow: 0px 1px 12px 0px #0000001A;
///
/// card inner layout:
///   width: 318;
///   height: 36;
///   justify-content: space-between;
///   angle: 0 deg;
///   opacity: 1;
///
/// icon branding:
///   width: 36;
///   height: 36;
///   angle: 0 deg;
///   opacity: 1;
///
/// content branding:
///   width: 266;
///   height: 26;
///   gap: 10px;
///   angle: 0 deg;
///   opacity: 1;
///
/// Service Area
///   width: 266;
///   height: 9;
///   angle: 0 deg;
///   opacity: 1;
///   font-family: Inter;
///   font-weight: 500;
///   font-style: Medium;
///   font-size: 12px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 22px;
///   letter-spacing: 0px;
///   background: #252527;
///
/// Nearby requests based on your location 
///   width: 266;
///   height: 7;
///   angle: 0 deg;
///   opacity: 1;
///   font-family: Inter;
///   font-weight: 400;
///   font-style: Regular;
///   font-size: 10px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 100%;
///   letter-spacing: 0px;
///   background: #616166;
class ProviderServiceAreaCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;

  const ProviderServiceAreaCard({
    super.key,
    this.title,
    this.subtitle,
    this.onTap,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 68.0;
  static const double innerWidth = 318.0;
  static const double innerHeight = 36.0;
  static const double iconSize = 36.0;
  static const double contentWidth = 266.0;
  static const double contentGap = 10.0;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;
    final String effectiveTitle = title ?? (isArabic ? 'منطقة الخدمة' : 'Service Area');
    final String effectiveSubtitle = subtitle ??
        (isArabic
            ? 'الطلبات القريبة بناءً على موقعك'
            : 'Nearby requests based on your location');

    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: Container(
          width: double.infinity, // stretch full available width
          constraints: const BoxConstraints(minHeight: designHeight), // height: 68
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0), // padding: 16px
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: innerHeight, // minHeight: 36
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // justify-content: space-between
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left group: Icon + Content Branding
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // icon branding: width: 36; height: 36;
                            Opacity(
                              opacity: 1.0,
                              child: Transform.rotate(
                                angle: 0.0,
                                child: Container(
                                  width: iconSize,
                                  height: iconSize,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF4F2F8), // Soft lavender tint
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.visibility_rounded,
                                      size: 20.0,
                                      color: Color(0xFF8B53FE), // #8B53FE Brand purple
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // gap: 10px
                            const SizedBox(width: contentGap),

                            // content branding: width: 266; height: 26; gap: 10px;
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: AlignmentDirectional.centerStart,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Service Area
                                    // width: 266; height: 9; font-size: 12px; font-weight: 500;
                                    // line-height: 22px; color: #252527;
                                    Opacity(
                                      opacity: 1.0,
                                      child: Transform.rotate(
                                        angle: 0.0,
                                        child: Text(
                                          effectiveTitle,
                                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                            fontSize: isArabic ? 12.0 : 12.0,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF252527),
                                            letterSpacing: 0.0,
                                            height: 1.15,
                                          ),
                                          textHeightBehavior: const TextHeightBehavior(
                                            applyHeightToFirstAscent: false,
                                            applyHeightToLastDescent: false,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 2.0),

                                    // Nearby requests based on your location
                                    // width: 266; height: 7; font-size: 10px; font-weight: 400;
                                    // line-height: 100%; color: #616166;
                                    Opacity(
                                      opacity: 1.0,
                                      child: Transform.rotate(
                                        angle: 0.0,
                                        child: Text(
                                          effectiveSubtitle,
                                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                            fontSize: isArabic ? 10.0 : 10.0,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF616166),
                                            letterSpacing: 0.0,
                                            height: 1.1,
                                          ),
                                          textHeightBehavior: const TextHeightBehavior(
                                            applyHeightToFirstAscent: false,
                                            applyHeightToLastDescent: false,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Chevron arrow > matching Figma vector
                      const SizedBox(width: 8.0),
                      Opacity(
                        opacity: 1.0,
                        child: CustomPaint(
                          size: const Size(6.0, 13.0),
                          painter: _ServiceAreaChevronPainter(
                            color: const Color(0xFF616166),
                            isRtl: isArabic || Directionality.of(context) == TextDirection.rtl,
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
      ),
    );
  }
}

/// Precise Chevron Arrow matching Figma vector redlines (width: 6, height: 13, border: 1px solid #616166)
class _ServiceAreaChevronPainter extends CustomPainter {
  final Color color;
  final bool isRtl;

  const _ServiceAreaChevronPainter({
    required this.color,
    this.isRtl = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    if (isRtl) {
      // In RTL points left: <
      path.moveTo(size.width - 0.5, 0.5);
      path.lineTo(0.5, size.height / 2);
      path.lineTo(size.width - 0.5, size.height - 0.5);
    } else {
      // In LTR points right: >
      path.moveTo(0.5, 0.5);
      path.lineTo(size.width - 0.5, size.height / 2);
      path.lineTo(0.5, size.height - 0.5);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ServiceAreaChevronPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isRtl != isRtl;
  }
}
