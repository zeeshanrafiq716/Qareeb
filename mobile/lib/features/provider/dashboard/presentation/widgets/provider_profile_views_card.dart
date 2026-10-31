import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/models/provider_dashboard_model.dart';

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
  final ProviderViewsCardData? data;

  const ProviderProfileViewsCard({
    super.key,
    this.initialTabIndex = 0,
    this.onTabChanged,
    this.data,
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
    final viewsData = widget.data ?? ProviderViewsCardData.defaults;
    final List<int> viewsCounts = viewsData.counts;
    final List<String> trends = viewsData.trends;
    final List<int> barValues = viewsData.barValues;

    final String headingText = isArabic ? 'مشاهدات الملف الشخصي' : 'Profile Views';
    final String subHeadingText =
        isArabic ? 'العملاء الذين شاهدوا ملفك الشخصي' : 'Customers viewed your profile';
    final String comparisonText = isArabic ? 'مقارنة بالأمس' : 'vs yesterday';

    final int currentViews = _selectedTabIndex < viewsCounts.length
        ? viewsCounts[_selectedTabIndex]
        : (viewsCounts.isNotEmpty ? viewsCounts[0] : 24);
    final String currentTrend = _selectedTabIndex < trends.length
        ? trends[_selectedTabIndex]
        : (trends.isNotEmpty ? trends[0] : '+12%');

    final List<String> tabs = isArabic ? _tabKeysAr : _tabKeysEn;
    final List<String> days = isArabic ? _daysAr : _daysEn;

    final int maxVal = barValues.fold<int>(1, (prev, elem) => elem > prev ? elem : prev);

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
                      child: const Center(
                        child: Icon(
                          Icons.remove_red_eye_rounded,
                          size: 18.0,
                          color: Color(0xFF8B53FE),
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
              Positioned(
                top: 154.0,
                left: 16.0,
                right: 16.0,
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

              // 3. Graph Layout: responsive left: 16px, right: 16px, height: 152px, top: 205px
              Positioned(
                top: 205.0,
                left: 16.0,
                right: 16.0,
                height: 152.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    final int value = index < barValues.length ? barValues[index] : 0;
                    final double barHeight = maxVal > 0
                        ? math.max((value / maxVal) * 116.0, 16.0)
                        : 20.0;
                    final bool isBarSelected = _selectedBarIndex == index;

                    // Bar color: selected (#8B53FE), others (#F3F2F5)
                    final Color barColor = isBarSelected
                        ? const Color(0xFF8B53FE)
                        : const Color(0xFFF3F2F5);

                    // Day label color: selected (#8B53FE), others (#616166)
                    final Color labelColor = isBarSelected
                        ? const Color(0xFF8B53FE)
                        : const Color(0xFF616166);

                    return Expanded(
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

                            // The bar container (centered within its equal column slot, max width 36px)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              width: 36.0,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                            ),

                            const SizedBox(height: 7.0),

                            // Day label at the bottom (Mon, Tue, Wed, Thu, Fri, Sat, Sun)
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
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
