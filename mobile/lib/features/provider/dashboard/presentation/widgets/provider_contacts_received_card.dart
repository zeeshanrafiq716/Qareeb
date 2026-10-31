import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/dashboard/presentation/widgets/provider_contact_channel_cards.dart';
import 'package:mobile/models/provider_dashboard_model.dart';

/// Provider Contacts Received Card Widget
/// Implements exact Figma specifications:
///
/// card widget branding:
///   width: 350;
///   height: 461;
///   border-radius: 16px;
///   padding-top: 16px;
///   padding-bottom: 16px;
///   gap: 20px;
///   angle: 0 deg;
///   opacity: 1;
///   background: #FFFFFF;
///   box-shadow: 0px 1px 12px 0px #0000001A;
///
/// Following 1st card branding with real phone icon:
///   - 36x36 soft lavender circular container (#F3F2F5)
///   - Real purple phone receiver icon (#8B53FE)
///   - Title: "Contacts Received" (Inter 500, 14px, #252527)
///   - Subtitle: "Customers contacted you through QAREEB." (Inter 400, 12px, #616166)
///   - 3rd row: 19 (Inter 600, 30-32px), [ (↑) +33% ] badge, "vs yesterday"
///   - Tabs row: 318x27, 5 tabs (Today, Yesterday, 10days, 15 days, 20 days)
///   - Breakdown & activity graph area (height: 238px)
class ProviderContactsReceivedCard extends StatefulWidget {
  final int initialTabIndex;
  final ValueChanged<int>? onTabChanged;
  final ProviderContactsCardData? data;

  const ProviderContactsReceivedCard({
    super.key,
    this.initialTabIndex = 0,
    this.onTabChanged,
    this.data,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 461.0;

  @override
  State<ProviderContactsReceivedCard> createState() =>
      _ProviderContactsReceivedCardState();
}

class _ProviderContactsReceivedCardState
    extends State<ProviderContactsReceivedCard> {
  late int _selectedTabIndex;
  int _selectedBarIndex = 4; // Friday highlighted by default

  final List<String> _tabKeysEn = [
    'Today',
    'Yesterday',
    '10days',
    '15 days',
    '20 days'
  ];
  final List<String> _tabKeysAr = [
    'اليوم',
    'الأمس',
    '١٠ أيام',
    '١٥ يوماً',
    '٢٠ يوماً'
  ];

  static const List<double> _barWidths = [40.29, 40.29, 40.29, 40.29, 40.29, 41.00, 40.29];
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
    final contactsData = widget.data ?? ProviderContactsCardData.defaults;
    final List<int> contactsCounts = contactsData.counts;
    final List<int> callsCounts = contactsData.callsCounts;
    final List<int> whatsAppCounts = contactsData.whatsAppCounts;
    final List<String> trends = contactsData.trends;
    final List<int> barValues = contactsData.barValues;

    final String headingText = isArabic ? 'جهات الاتصال المستلمة' : 'Contacts Received';
    final String subHeadingText = isArabic
        ? 'العملاء الذين تواصلوا معك عبر قريب.'
        : 'Customers contacted you through QAREEB.';
    final String comparisonText = isArabic ? 'مقارنة بالأمس' : 'vs yesterday';

    final int currentContacts = _selectedTabIndex < contactsCounts.length
        ? contactsCounts[_selectedTabIndex]
        : (contactsCounts.isNotEmpty ? contactsCounts[0] : 19);
    final int currentCalls = _selectedTabIndex < callsCounts.length
        ? callsCounts[_selectedTabIndex]
        : (callsCounts.isNotEmpty ? callsCounts[0] : 11);
    final int currentWhatsApp = _selectedTabIndex < whatsAppCounts.length
        ? whatsAppCounts[_selectedTabIndex]
        : (whatsAppCounts.isNotEmpty ? whatsAppCounts[0] : 8);
    final String currentTrend = _selectedTabIndex < trends.length
        ? trends[_selectedTabIndex]
        : (trends.isNotEmpty ? trends[0] : '+33%');

    final List<String> tabs = isArabic ? _tabKeysAr : _tabKeysEn;
    final List<String> days = isArabic ? _daysAr : _daysEn;

    final int maxVal = barValues.fold<int>(1, (prev, elem) => elem > prev ? elem : prev);

    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: Container(
          width: ProviderContactsReceivedCard.designWidth, // width: 350
          height: ProviderContactsReceivedCard.designHeight, // height: 461
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Content Layout (height: 124px)
              SizedBox(
                height: 124.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1.1 Real Phone Icon: 36x36 circular container
                    Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F2F5),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        // Real phone receiver icon matching Figma
                        child: Transform.rotate(
                          angle: isArabic ? 1.57 : 0.0,
                          child: const Icon(
                            Icons.phone_rounded,
                            size: 18.0,
                            color: Color(0xFF8B53FE), // #8B53FE
                          ),
                        ),
                      ),
                    ),

                    // 1.2 Headings: Title & Subtitle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title: "Contacts Received"
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
                        // Subtitle: "Customers contacted you through QAREEB."
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

                    // 1.3 3rd Row: Value (19), Percentage badge (+33%), vs yesterday
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Metric value (e.g. 19)
                        Text(
                          '$currentContacts',
                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF252527),
                            height: 1.0,
                            letterSpacing: 0.0,
                          ),
                        ),

                        const SizedBox(width: 10.0), // gap: 10px

                        // Percentage badge: [ (↑) +33% ]
                        Container(
                          height: 18.0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F2F5),
                            borderRadius: BorderRadius.circular(60.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 10x10 purple circle with white upward arrow
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

                              const SizedBox(width: 4.0),

                              // +33%
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

                        const SizedBox(width: 8.0),

                        // vs yesterday
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

              // gap: 20px
              const SizedBox(height: 20.0),

              // 2. Next Row: Tabs Row (Today, Yesterday, 10days, 15 days, 20 days)
              // width: 318; height: 27; gap: 6px;
              SizedBox(
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

              // gap: 16px
              const SizedBox(height: 16.0),

              // 3. Call and WhatsApp Mini Cards (Placed directly after Dayz Tab)
              ProviderContactChannelCards(
                callsCount: currentCalls,
                whatsAppCount: currentWhatsApp,
                padding: EdgeInsets.zero,
                width: 318.0,
              ),

              // gap: 16px
              const SizedBox(height: 16.0),

              // 4. Call Activity Chart (Mon - Sun)
              Expanded(
                child: SizedBox(
                  width: 318.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (index) {
                      final double barWidth = _barWidths[index];
                      final int value = index < barValues.length ? barValues[index] : 0;
                      final double barHeight = maxVal > 0
                          ? math.max((value / maxVal) * 78.0, 16.0)
                          : 20.0;
                      final bool isBarSelected = _selectedBarIndex == index;

                      final Color barColor = isBarSelected
                          ? const Color(0xFF8B53FE)
                          : const Color(0xFFF3F2F5);

                      final Color labelColor = isBarSelected
                          ? const Color(0xFF8B53FE)
                          : const Color(0xFF616166);

                      return SizedBox(
                        width: barWidth,
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
                              // Value above bar
                              Text(
                                '$value',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11.0,
                                  fontWeight: isBarSelected
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  color: const Color(0xFF252527),
                                  height: 1.0,
                                ),
                              ),

                              const SizedBox(height: 5.0),

                              // Bar Container
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

                              // Day label
                              Text(
                                days[index],
                                style: TextStyle(
                                  fontFamily: isArabic
                                      ? GoogleFonts.cairo().fontFamily
                                      : 'Inter',
                                  fontSize: 10.0,
                                  fontWeight: isBarSelected
                                      ? FontWeight.w500
                                      : FontWeight.w400,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
