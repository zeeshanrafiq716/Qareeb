import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/dashboard/presentation/provider_dashboard_screen.dart';

/// Provider Home Stats Cards Widget
/// Implements exact Figma branding specifications:
///
/// next widget layout:
///   width: 350;
///   height: 68;
///   gap: 12px;
///   angle: 0 deg;
///   opacity: 1;
///
/// 1st card branding:
///   width: 169;
///   height: 68;
///   gap: 10px;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 12px;
///   padding: 16px;
///   background: #FFFFFF;
///   box-shadow: 0px 1px 12px 0px #0000001A;
///
/// card inner branding:
///   width: 137;
///   height: 36;
///   justify-content: space-between;
///   angle: 0 deg;
///   opacity: 1;
///
/// content layout branding:
///   width: 119;
///   height: 36;
///   gap: 10px;
///   angle: 0 deg;
///   opacity: 1;
///
/// icon branding:
///   width: 36;
///   height: 36;
///   angle: 0 deg;
///   opacity: 1;
///
/// content: 32 (Views today) / 19 (Contacts today)
///   width: 18;
///   height: 10;
///   angle: 0 deg;
///   opacity: 1;
///   font-family: Inter;
///   font-weight: 500;
///   font-style: Medium;
///   font-size: 14px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 22px;
///   letter-spacing: 0px;
///   text-align: center;
///   background: #252527;
///
/// content: Views today / Contacts today
///   width: 73;
///   height: 7;
///   angle: 0 deg;
///   opacity: 1;
///   font-family: Inter;
///   font-weight: 400;
///   font-style: Regular;
///   font-size: 10px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 22px;
///   letter-spacing: 0px;
///   background: #616166;
///
/// > branding:
///   width: 6;
///   height: 13;
///   angle: -180 deg;
///   opacity: 1;
///   border-width: 1px;
///   border: 1px solid #616166;
class ProviderStatsCards extends StatelessWidget {
  final int viewsToday;
  final int contactsToday;
  final VoidCallback? onViewsTap;
  final VoidCallback? onContactsTap;

  const ProviderStatsCards({
    super.key,
    this.viewsToday = 32,
    this.contactsToday = 19,
    this.onViewsTap,
    this.onContactsTap,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 68.0;
  static const double cardWidth = 169.0;
  static const double cardHeight = 68.0;
  static const double gap = 12.0;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;
    final String viewsLabel = isArabic ? 'المشاهدات اليوم' : 'Views today';
    final String contactsLabel = isArabic ? 'جهات الاتصال اليوم' : 'Contacts today';

    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: double.infinity,
          height: designHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1st Card: Views today
              Expanded(
                child: _ProviderStatCard(
                  icon: Icons.remove_red_eye_rounded,
                  value: '$viewsToday',
                  label: viewsLabel,
                  onTap: onViewsTap ??
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProviderDashboardScreen(),
                          ),
                        );
                      },
                ),
              ),

              const SizedBox(width: gap),

              // 2nd Card: Contacts today
              Expanded(
                child: _ProviderStatCard(
                  icon: Icons.phone_rounded,
                  value: '$contactsToday',
                  label: contactsLabel,
                  onTap: onContactsTap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _ProviderStatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;

    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: Container(
          height: ProviderStatsCards.cardHeight, // height: 68
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
                child: SizedBox(
                  width: 137.0, // card inner branding width: 137
                  height: 36.0, // card inner branding height: 36
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // justify-content: space-between
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // content layout branding: width: 119; height: 36; gap: 10px;
                      SizedBox(
                        width: 119.0,
                        height: 36.0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // icon branding: width: 36; height: 36;
                            Opacity(
                              opacity: 1.0, // opacity: 1
                              child: Transform.rotate(
                                angle: 0.0, // angle: 0 deg
                                child: Container(
                                  width: 36.0,
                                  height: 36.0,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF4F2F8), // Soft lavender tint
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      icon,
                                      size: 18.0,
                                      color: const Color(0xFF8B53FE), // Brand purple
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // gap: 10px
                            const SizedBox(width: 10.0),

                            // Text column
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: AlignmentDirectional.centerStart,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // content: value (32 / 19)
                                    // width: 18; height: 10; font-family: Inter; font-weight: 500; font-size: 14px;
                                    // leading-trim: CAP_HEIGHT; line-height: 22px; color: #252527
                                    Opacity(
                                      opacity: 1.0, // opacity: 1
                                      child: Transform.rotate(
                                        angle: 0.0, // angle: 0 deg
                                        child: Text(
                                          value,
                                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF252527),
                                            height: 1.15,
                                            letterSpacing: 0.0,
                                          ),
                                          textHeightBehavior: const TextHeightBehavior(
                                            applyHeightToFirstAscent: false,
                                            applyHeightToLastDescent: false,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 1.0),

                                    // content: label (Views today / Contacts today)
                                    // width: 73; height: 7; font-family: Inter; font-weight: 400; font-size: 10px;
                                    // leading-trim: CAP_HEIGHT; line-height: 22px; color: #616166
                                    Opacity(
                                      opacity: 1.0, // opacity: 1
                                      child: Transform.rotate(
                                        angle: 0.0, // angle: 0 deg
                                        child: Text(
                                          label,
                                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF616166),
                                            height: 1.1,
                                            letterSpacing: 0.0,
                                          ),
                                          textHeightBehavior: const TextHeightBehavior(
                                            applyHeightToFirstAscent: false,
                                            applyHeightToLastDescent: false,
                                          ),
                                          maxLines: 1,
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

                      // > branding: width: 6; height: 13; angle: -180 deg; opacity: 1; border: 1px solid #616166
                      Opacity(
                        opacity: 1.0, // opacity: 1
                        child: CustomPaint(
                          size: const Size(6.0, 13.0),
                          painter: _ChevronArrowPainter(
                            color: const Color(0xFF616166),
                            isRtl: isArabic,
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
class _ChevronArrowPainter extends CustomPainter {
  final Color color;
  final bool isRtl;

  const _ChevronArrowPainter({
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
  bool shouldRepaint(covariant _ChevronArrowPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isRtl != isRtl;
  }
}
