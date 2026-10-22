import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';

/// Provider Profile Views Card Widget
/// Implements exact Figma specifications:
///
/// widget inner branding:
///   width: 350;
///   height: 377;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 16px;
///   background: #FFFFFF;
///   box-shadow: 0px 1px 12px 0px #0000001A;
///
/// content layout:
///   width: 173;
///   height: 122;
///   gap: 16px;
///   angle: 0 deg;
///   opacity: 1;
///
/// eye icon branding:
///   width: 36;
///   height: 36;
///   angle: 0 deg;
///   opacity: 1;
///
/// eye vector inner branding:
///   width: 20;
///   height: 16;
///   top: 10px;
///   left: 8px;
///   angle: 0 deg;
///   opacity: 1;
///   background: #8B53FE;
///
/// heading branding:
///   Profile Views 
///   width: 88;
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
/// sub heading:
///   Customers viewed your profile
///   width: 173;
///   height: 9;
///   angle: 0 deg;
///   opacity: 1;
///   font-family: Inter;
///   font-weight: 400;
///   font-style: Regular;
///   font-size: 12px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 100%;
///   letter-spacing: 0px;
///   background: #616166;
///
/// 3rd row layout:
///   width: 173;
///   height: 23;
///   gap: 10px;
///   angle: 0 deg;
///   opacity: 1;
///
/// 24
///   width: 41;
///   height: 23;
///   angle: 0 deg;
///   opacity: 1;
///   font-family: Inter;
///   font-weight: 600;
///   font-style: Semi Bold;
///   font-size: 32px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 22px;
///   letter-spacing: 0px;
///   text-align: center;
///   background: #252527;
///
/// percentage layout:
///   width: 50;
///   height: 18;
///   gap: 6px;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 60px;
///   padding: 4px;
///   background: #F3F2F5;
///
/// arrow-up branding:
///   width: 10;
///   height: 10;
///   angle: 0 deg;
///   opacity: 1;
///   background: #8B53FE;
///
/// +12%
///   width: 26;
///   height: 7;
///   angle: 0 deg;
///   opacity: 1;
///   font-family: Inter;
///   font-weight: 500;
///   font-style: Medium;
///   font-size: 10px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 22px;
///   letter-spacing: 0px;
///   background: #8B53FE;
///
/// vs yesterday
///   width: 61;
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
///
/// next row layout:
///   width: 318;
///   height: 27;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 6px;
///
/// 1st tab layout:
///   width: 58.79999923706055;
///   height: 27;
///   border-radius: 20px;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 10px;
///   padding: 10px;
///   background: #8B53FE;
///
/// inner content: Today
///   width: 30; height: 7; font-family: Inter; font-weight: 500; font-size: 10px; color: #FFFFFF;
///
/// 2nd tab layout:
///   width: 58.79999923706055; height: 27; border-radius: 20px; padding: 10px; background: #F3F2F5;
///
/// inner branding: Yesterday
///   width: 48; height: 7; font-family: Inter; font-weight: 400; font-size: 10px; color: #616166;
///
/// graph layout:
///   width: 318;
///   height: 152;
///   angle: 0 deg;
///   opacity: 1;
///   top: 205px;
///   left: 16px;
class ProviderProfileViewsCard extends StatefulWidget {
  final int initialTabIndex;
  final ValueChanged<int>? onTabChanged;

  const ProviderProfileViewsCard({
    super.key,
    this.initialTabIndex = 0,
    this.onTabChanged,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 377.0;

  @override
  State<ProviderProfileViewsCard> createState() => _ProviderProfileViewsCardState();
}

class _ProviderProfileViewsCardState extends State<ProviderProfileViewsCard> {
  late int _selectedTabIndex;
  int _selectedBarIndex = 4; // Bar 5 (Friday) selected by default matching Figma

  final List<String> _tabKeysEn = ['Today', 'Yesterday', '10days', '15 days', '20 days'];
  final List<String> _tabKeysAr = ['اليوم', 'الأمس', '١٠ أيام', '١٥ يوماً', '٢٠ يوماً'];

  // Metrics dynamic to selected tab
  final List<int> _viewsCounts = [24, 21, 184, 268, 345];
  final List<String> _trends = ['+12%', '+5%', '+18%', '+22%', '+15%'];

  // Bar specifications from Figma:
  // Bar 1: Mon, width: 40.29, height: 20, top: 96, left: 0.00, value: 1
  // Bar 2: Tue, width: 40.29, height: 70, top: 46, left: 46.29, value: 3
  // Bar 3: Wed, width: 40.29, height: 90, top: 26, left: 92.57, value: 4
  // Bar 4: Thu, width: 40.29, height: 116, top: 0, left: 138.86, value: 7
  // Bar 5: Fri, width: 40.29, height: 90, top: 26, left: 185.14, value: 4 (highlighted #8B53FE)
  // Bar 6: Sat, width: 41.00, height: 48, top: 68, left: 231.00, value: 2
  // Bar 7: Sun, width: 40.29, height: 69, top: 47, left: 277.71, value: 3
  static const List<double> _barWidths = [40.29, 40.29, 40.29, 40.29, 40.29, 41.00, 40.29];
  static const List<double> _barHeights = [20.0, 70.0, 90.0, 116.0, 90.0, 48.0, 69.0];
  static const List<double> _barLefts = [0.0, 46.29, 92.57, 138.86, 185.14, 231.0, 277.71];
  static const List<int> _barValues = [1, 3, 4, 7, 4, 2, 3];
  static const List<String> _daysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<String> _daysAr = ['إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت', 'أحد'];

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;
    final String headingText = isArabic ? 'مشاهدات الملف الشخصي' : 'Profile Views';
    final String subHeadingText =
        isArabic ? 'العملاء الذين شاهدوا ملفك الشخصي' : 'Customers viewed your profile';
    final String comparisonText = isArabic ? 'مقارنة بالأمس' : 'vs yesterday';

    final int currentViews = _viewsCounts[_selectedTabIndex];
    final String currentTrend = _trends[_selectedTabIndex];
    final List<String> tabs = isArabic ? _tabKeysAr : _tabKeysEn;
    final List<String> days = isArabic ? _daysAr : _daysEn;

    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: Container(
          width: ProviderProfileViewsCard.designWidth, // width: 350
          height: ProviderProfileViewsCard.designHeight, // height: 377
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF), // background: #FFFFFF
            borderRadius: BorderRadius.circular(16.0), // border-radius: 16px
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000), // box-shadow: 0px 1px 12px 0px #0000001A
                offset: Offset(0, 1),
                blurRadius: 12.0,
                spreadRadius: 0.0,
              ),
            ],
          ),
          child: Stack(
            children: [
              // 1. Content Layout: top: 16px; left: 16px; right: 16px; height: 124px;
              Positioned(
                top: 16.0,
                left: 16.0,
                right: 16.0,
                height: 124.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1.1 Eye icon branding: width: 36; height: 36;
                    Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F2F5),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        // Eye vector inner branding: width: 20; height: 16;
                        child: CustomPaint(
                          size: const Size(20.0, 16.0),
                          painter: const _EyeVectorPainter(
                            color: Color(0xFF8B53FE),
                          ),
                        ),
                      ),
                    ),

                    // 1.2 Headings:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Heading branding: "Profile Views"
                        Text(
                          headingText,
                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF252527),
                            height: 1.15,
                            letterSpacing: 0.0,
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 3.0),
                        // Sub heading: "Customers viewed your profile"
                        Text(
                          subHeadingText,
                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF616166),
                            height: 1.0,
                            letterSpacing: 0.0,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),

                    // 1.3 3rd row layout: full width, clean vertical alignment, no glyph clipping
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Views count (e.g. 24 or 345)
                        Text(
                          '$currentViews',
                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF252527),
                            height: 1.0,
                            letterSpacing: 0.0,
                          ),
                        ),

                        const SizedBox(width: 10.0), // gap: 10px

                        // Percentage layout: width: 50; height: 18; gap: 6px;
                        // border-radius: 60px; padding: 4px; background: #F3F2F5;
                        Container(
                          height: 18.0,
                          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F2F5),
                            borderRadius: BorderRadius.circular(60.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Arrow-up branding: width: 10; height: 10; background: #8B53FE;
                              Container(
                                width: 10.0,
                                height: 10.0,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF8B53FE),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.arrow_upward_rounded,
                                    size: 7.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 4.0), // gap: 6px approx

                              // +12% / +15%
                              Text(
                                currentTrend,
                                style: GoogleFonts.inter(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF8B53FE),
                                  height: 1.0,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8.0), // gap: 10px approx

                        // vs yesterday - NO clipping, NO ellipsis (...)
                        Text(
                          comparisonText,
                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF616166),
                            height: 1.0,
                            letterSpacing: 0.0,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. Next Row Layout: Tabs (Today, Yesterday, 10days, 15 days, 20 days)
              // width: 318; height: 27; top: 154px; left: 16px; gap: 6px;
              Positioned(
                top: 154.0,
                left: isArabic ? null : 16.0,
                right: isArabic ? 16.0 : null,
                width: 318.0,
                height: 27.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(tabs.length, (index) {
                    final bool isSelected = _selectedTabIndex == index;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: (index < tabs.length - 1 && !isArabic) ? 6.0 : 0.0,
                          left: (index < tabs.length - 1 && isArabic) ? 6.0 : 0.0,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTabIndex = index;
                            });
                            widget.onTabChanged?.call(index);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeInOut,
                            height: 27.0,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF8B53FE)
                                  : const Color(0xFFF3F2F5),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              tabs[index],
                              style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                fontSize: 10.0,
                                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                color: isSelected
                                    ? const Color(0xFFFFFFFF)
                                    : const Color(0xFF616166),
                                height: 1.0,
                                letterSpacing: 0.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // 3. Graph Layout: width: 318; height: 152; top: 205px; left: 16px;
              Positioned(
                top: 205.0,
                left: isArabic ? null : 16.0,
                right: isArabic ? 16.0 : null,
                width: 318.0,
                height: 152.0,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: List.generate(7, (index) {
                    final double barWidth = _barWidths[index];
                    final double barHeight = _barHeights[index];
                    final double barLeft = _barLefts[index];
                    final int value = _barValues[index];
                    final bool isBarSelected = _selectedBarIndex == index;

                    // Bar color: Fri (#8B53FE), others (#F3F2F5)
                    final Color barColor = isBarSelected
                        ? const Color(0xFF8B53FE)
                        : const Color(0xFFF3F2F5);

                    // Day label color: Fri (#8B53FE), others (#616166)
                    final Color labelColor = isBarSelected
                        ? const Color(0xFF8B53FE)
                        : const Color(0xFF616166);

                    return Positioned(
                      left: isArabic ? null : barLeft,
                      right: isArabic ? barLeft : null,
                      width: barWidth,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedBarIndex = index;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Value number placed above the bar
                            Text(
                              '$value',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.0,
                                fontWeight: isBarSelected ? FontWeight.w500 : FontWeight.w400,
                                color: const Color(0xFF252527),
                                height: 1.0,
                              ),
                            ),

                            const SizedBox(height: 5.0),

                            // The bar container
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              width: barWidth,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                            ),

                            const SizedBox(height: 7.0),

                            // Day label at the bottom (Mon, Tue, Wed, Thu, Fri, Sat, Sun)
                            Text(
                              days[index],
                              style: TextStyle(
                                fontFamily: isArabic ? GoogleFonts.cairo().fontFamily : 'Inter',
                                fontSize: 10.0,
                                fontWeight: isBarSelected ? FontWeight.w500 : FontWeight.w400,
                                color: labelColor,
                                height: 1.0,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the exact 20x16 eye vector
/// top: 10px, left: 8px, background: #8B53FE with white pupil
class _EyeVectorPainter extends CustomPainter {
  final Color color;

  const _EyeVectorPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Outer eye path
    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.5,
      0,
      size.width,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height,
      0,
      size.height * 0.5,
    );
    path.close();

    canvas.drawPath(path, paint);

    // Inner pupil (white circle)
    final pupilPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.height * 0.22,
      pupilPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _EyeVectorPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
