import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/location/presentation/widgets/top_down_car_widget.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_header_back_button.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';

/// Provider Active Request Screen
/// Displays active request details with:
/// - Top header with Back button, "Active Request" title, and "On the way" status card
/// - Map with destination pin, route line, car, landmark, and GPS button
/// - Bottom card with same branding as service details screen:
///   1. Service image + title + client info
///   2. Customer Location card
///   3. Distance & Estimated time twin cards
///   4. Customer card with WhatsApp, Call, vehicle & plate
///   5. 5-step status stepper (Accepted -> On the way -> Arrived -> In Progress -> Completed)
///   6. Customer Note card
///   7. "I've Arrived ->" primary action button
///   8. Bottom home indicator bar
class ProviderActiveRequestScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String serviceTypeEn;
  final String serviceTypeAr;
  final String locationEn;
  final String locationAr;
  final String distanceEn;
  final String distanceAr;
  final String timeEn;
  final String timeAr;
  final String customerNameEn;
  final String customerNameAr;
  final String vehicleModelEn;
  final String vehicleModelAr;
  final String plateNumber;
  final String customerNoteEn;
  final String customerNoteAr;

  const ProviderActiveRequestScreen({
    super.key,
    this.requestId = 'REQ-101',
    this.serviceTypeEn = 'Battery Jump Start',
    this.serviceTypeAr = 'شحن البطارية بالكيبل',
    this.locationEn = 'King Abdullah Rd, Riyadh',
    this.locationAr = 'طريق الملك عبدالله، الرياض',
    this.distanceEn = '2.4 km',
    this.distanceAr = '٢.٤ كم',
    this.timeEn = '8 min',
    this.timeAr = '٨ دقائق',
    this.customerNameEn = 'Ahmed Khan',
    this.customerNameAr = 'أحمد خان',
    this.vehicleModelEn = 'Toyota Corolla',
    this.vehicleModelAr = 'تويوتا كورولا',
    this.plateNumber = 'KSA 1234',
    this.customerNoteEn =
        'Battery is dead and the car won’t start. Need a jump start.',
    this.customerNoteAr =
        'البطارية فارغة والسيارة لا تعمل. أحتاج إلى شحن بطارية.',
  });

  @override
  ConsumerState<ProviderActiveRequestScreen> createState() =>
      _ProviderActiveRequestScreenState();
}

class _ProviderActiveRequestScreenState
    extends ConsumerState<ProviderActiveRequestScreen> {
  static const double designWidth = 390.0;
  static const double designHeight = 844.0;

  // Active step index: 0 = Accepted, 1 = On the way, 2 = Arrived, 3 = In Progress, 4 = Completed
  int _currentStep = 1;
  // Sheet expandable state for smooth user-friendly scrolling
  bool _isSheetExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    final cleanDistance = (isArabic ? widget.distanceAr : widget.distanceEn)
        .replaceAll(' away', '')
        .replaceAll('على بعد ', '')
        .trim();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktopWeb = constraints.maxWidth > 500;
            final double containerWidth = isDesktopWeb
                ? designWidth
                : (constraints.maxWidth > designWidth
                    ? designWidth
                    : constraints.maxWidth);
            final double containerHeight =
                isDesktopWeb ? designHeight : constraints.maxHeight;

            final double topSafeArea = MediaQuery.of(context).padding.top;
            final double headerTop =
                topSafeArea > 0 ? (topSafeArea + 8.0) : 52.0;

            final Widget screenContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Map Section Background (top 0 to 480px)
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    width: containerWidth,
                    height: 500.0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 1a. Background Map Layer
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/img.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              'assets/images/BG image.png',
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: const Color(0xFFF3F4F6),
                                child: const Center(
                                  child: Icon(
                                    Icons.map_outlined,
                                    size: 48,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 1b. Complete Screen Gradient Overlay Layer
                        Positioned.fill(
                          child: const IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: [0.0214, 0.1705, 0.2693, 1.0],
                                  colors: [
                                    Color(0xFFFFFFFF),
                                    Color(0xD6FFFFFF),
                                    Color(0x00FFFFFF),
                                    Color(0x00FFFFFF),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 1c. Purple Street Route Line
                        Positioned(
                          top: 154.0,
                          left: 110.0 + ((containerWidth - 390.0) / 2.0),
                          width: 75.0,
                          height: 72.0,
                          child: const CustomPaint(
                            size: Size(75.0, 72.0),
                            painter: _ActiveStreetRoutePainter(
                              color: Color(0xFF8B53FE),
                              strokeWidth: 4.8,
                            ),
                          ),
                        ),

                        // 1d. Destination Pin Halo
                        Positioned(
                          top: 132.0,
                          left: 104.0 + ((containerWidth - 390.0) / 2.0),
                          width: 48.0,
                          height: 48.0,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF8B53FE)
                                  .withValues(alpha: 0.16),
                              border: Border.all(
                                color: const Color(0xFF8B53FE)
                                    .withValues(alpha: 0.28),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),

                        // 1e. Destination Pin Circle
                        Positioned(
                          top: 138.0,
                          left: 110.0 + ((containerWidth - 390.0) / 2.0),
                          width: 36.0,
                          height: 36.0,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF8B53FE),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x4D8B53FE),
                                  blurRadius: 8.0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.location_on_rounded,
                                size: 20.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // 1f. Purple Distance Tooltip Badge: "2.4 km"
                        Positioned(
                          top: 104.0,
                          left: 99.0 + ((containerWidth - 390.0) / 2.0),
                          width: 58.0,
                          height: 28.0,
                          child: CustomPaint(
                            size: const Size(58.0, 28.0),
                            painter: const _ActiveTooltipSpeechBubblePainter(
                              color: Color(0xFF8B53FE),
                              cornerRadius: 6.0,
                              pointerWidth: 8.0,
                              pointerHeight: 6.0,
                              shadowColor: Color(0x338B53FE),
                            ),
                            child: Align(
                              alignment: const Alignment(0.0, -0.4),
                              child: Text(
                                cleanDistance,
                                style: isArabic
                                    ? GoogleFonts.cairo(
                                        fontSize: 11.0,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        height: 1.0,
                                      )
                                    : GoogleFonts.inter(
                                        fontSize: 11.0,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        height: 1.0,
                                      ),
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ),
                        ),

                        // 1g. Top-Down Vehicle Car
                        Positioned(
                          top: 215.0,
                          left: 172.0 + ((containerWidth - 390.0) / 2.0),
                          child: TopDownCarWidget(
                            width: 17.0,
                            height: 29.0,
                            angle: -48.0,
                            showBadge: false,
                            bodyColor: const Color(0xFF8B53FE),
                          ),
                        ),

                        // 1h. White "You" Speech Bubble
                        Positioned(
                          top: 179.0,
                          left: 162.0 + ((containerWidth - 390.0) / 2.0),
                          width: 44.0,
                          height: 30.0,
                          child: CustomPaint(
                            size: const Size(44.0, 30.0),
                            painter: const _ActiveTooltipSpeechBubblePainter(
                              color: Colors.white,
                              cornerRadius: 8.0,
                              pointerWidth: 8.0,
                              pointerHeight: 6.0,
                              shadowColor: Color(0x22000000),
                            ),
                            child: Align(
                              alignment: const Alignment(0.0, -0.45),
                              child: Text(
                                isArabic ? 'أنت' : 'You',
                                style: GoogleFonts.inter(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1C2926),
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 1i. Landmark Indicator: Al Nakheel Mall
                        Positioned(
                          top: 210.0,
                          left: 75.0 + ((containerWidth - 390.0) / 2.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 22.0,
                                height: 22.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF566663)
                                      .withValues(alpha: 0.15),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 13.0,
                                    color: Color(0xFF566663),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'النخيل مول',
                                    style: GoogleFonts.cairo(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF566663),
                                      height: 1.1,
                                    ),
                                  ),
                                  Text(
                                    'Al Nakheel Mall',
                                    style: GoogleFonts.inter(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF6B7280),
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 1j. Floating GPS / Re-center Target Button
                        Positioned(
                          top: 210.0,
                          right: 20.0,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isArabic
                                        ? 'تم إعادة توسيط الخريطة'
                                        : 'Map re-centered to your location',
                                    style: GoogleFonts.inter(color: Colors.white),
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              width: 42.0,
                              height: 42.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                  width: 1.0,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x1F000000),
                                    blurRadius: 12.0,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.my_location_rounded,
                                  size: 22.0,
                                  color: Color(0xFF1C2926),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Header Bar: Circular Back Button `<` + Title: "Active Request" + Top Right "On the way" Card
                  Positioned(
                    top: headerTop,
                    left: 20.0,
                    right: 20.0,
                    height: 46.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Circular Back Button `<`
                        ProviderHeaderBackButton(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).maybePop();
                          },
                        ),

                        const SizedBox(width: 10.0),

                        // Title: "Active Request"
                        Text(
                          isArabic ? 'طلب نشط' : 'Active Request',
                          style: isArabic
                              ? GoogleFonts.cairo(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1C2926),
                                  height: 1.2,
                                )
                              : GoogleFonts.inter(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1C2926),
                                  height: 1.2,
                                ),
                          maxLines: 1,
                        ),

                        const Spacer(),

                        // Top-Right Floating Status Pill: "On the way / Arriving in 8 min • 3.2 km away"
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 0.8,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 8.0,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Purple circle with navigation icon
                              Container(
                                width: 26.0,
                                height: 26.0,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF8B53FE),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.near_me_rounded,
                                    color: Colors.white,
                                    size: 14.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getStepStatusText(isArabic),
                                    style: isArabic
                                        ? GoogleFonts.cairo(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF8B53FE),
                                            height: 1.1,
                                          )
                                        : GoogleFonts.inter(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF8B53FE),
                                            height: 1.1,
                                          ),
                                  ),
                                  const SizedBox(height: 1.0),
                                  Text(
                                    isArabic
                                        ? 'الوصول خلال ٨ دقائق • ٣.٢ كم'
                                        : 'Arriving in 8 min • 3.2 km away',
                                    style: isArabic
                                        ? GoogleFonts.cairo(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF616166),
                                            height: 1.1,
                                          )
                                        : GoogleFonts.inter(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF616166),
                                            height: 1.1,
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

                  // 3. Bottom Sheet Card (Smooth user-friendly expandable & scrollable sheet)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    top: _isSheetExpanded
                        ? (topSafeArea > 0 ? (topSafeArea + 50.0) : 88.0)
                        : 258.0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: containerWidth,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28.0),
                          topRight: Radius.circular(28.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x14000000),
                            offset: Offset(0, -2),
                            blurRadius: 12.0,
                            spreadRadius: 0.0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Interactive Drag Handle Bar (Tap or drag up/down to expand/collapse)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _isSheetExpanded = !_isSheetExpanded;
                              });
                            },
                            onVerticalDragEnd: (details) {
                              if (details.primaryVelocity != null) {
                                if (details.primaryVelocity! < -80) {
                                  // Dragged / flicked up -> expand
                                  HapticFeedback.lightImpact();
                                  setState(() => _isSheetExpanded = true);
                                } else if (details.primaryVelocity! > 80) {
                                  // Dragged / flicked down -> collapse
                                  HapticFeedback.lightImpact();
                                  setState(() => _isSheetExpanded = false);
                                }
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(top: 10.0, bottom: 6.0),
                              color: Colors.transparent,
                              child: Center(
                                child: Container(
                                  width: 44.0,
                                  height: 4.0,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0DFE4),
                                    borderRadius: BorderRadius.circular(100.0),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Scrollable Bottom Card Content Area (Smooth bouncing physics, equal gaps)
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics(),
                              ),
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 6.0, 20.0, 0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 3a. Row 1: Service Image + Service Title + Client Name & Location
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        child: Image.asset(
                                          'assets/images/img.png',
                                          width: 52.0,
                                          height: 52.0,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Container(
                                            width: 52.0,
                                            height: 52.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3F2F5),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: const Icon(
                                              Icons.car_repair_rounded,
                                              color: Color(0xFF8B53FE),
                                              size: 26.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isArabic
                                                  ? widget.serviceTypeAr
                                                  : widget.serviceTypeEn,
                                              style: isArabic
                                                  ? GoogleFonts.cairo(
                                                      fontSize: 14.5,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                          0xFF252527),
                                                      height: 1.1,
                                                    )
                                                  : GoogleFonts.inter(
                                                      fontSize: 14.5,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: const Color(
                                                          0xFF252527),
                                                      height: 1.1,
                                                    ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 5.0),
                                            Row(
                                              children: [
                                                Text(
                                                  isArabic
                                                      ? 'من فيصل الحربي'
                                                      : 'From Faisal Al-Harbi',
                                                  style: isArabic
                                                      ? GoogleFonts.cairo(
                                                          fontSize: 10.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: const Color(
                                                              0xFF616166),
                                                          height: 1.0,
                                                        )
                                                      : GoogleFonts.inter(
                                                          fontSize: 10.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: const Color(
                                                              0xFF616166),
                                                          height: 1.0,
                                                        ),
                                                ),
                                                const SizedBox(width: 6.0),
                                                Container(
                                                  width: 3.5,
                                                  height: 3.5,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xFF616166),
                                                  ),
                                                ),
                                                const SizedBox(width: 6.0),
                                                Flexible(
                                                  child: Text(
                                                    isArabic
                                                        ? widget.locationAr
                                                        : widget.locationEn,
                                                    style: isArabic
                                                        ? GoogleFonts.cairo(
                                                            fontSize: 10.0,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: const Color(
                                                                0xFF616166),
                                                            height: 1.0,
                                                          )
                                                        : GoogleFonts.inter(
                                                            fontSize: 10.0,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: const Color(
                                                                0xFF616166),
                                                            height: 1.0,
                                                          ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12.0),

                                  // 3b. 1st Card: Customer Location Card
                                  Container(
                                    width: double.infinity,
                                    height: 68.0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 15.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F2F5),
                                      borderRadius:
                                          BorderRadius.circular(12.0),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 36.0,
                                          height: 36.0,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE7E6EB),
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.location_on_rounded,
                                              size: 18.0,
                                              color: Color(0xFF252527),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isArabic
                                                    ? 'موقع العميل'
                                                    : 'Customer Location',
                                                style: isArabic
                                                    ? GoogleFonts.cairo(
                                                        fontSize: 10.0,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: const Color(
                                                            0xFF616166),
                                                        height: 1.0,
                                                      )
                                                    : GoogleFonts.inter(
                                                        fontSize: 10.0,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: const Color(
                                                            0xFF616166),
                                                        height: 1.0,
                                                      ),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4.0),
                                              Text(
                                                isArabic
                                                    ? widget.locationAr
                                                    : widget.locationEn,
                                                style: isArabic
                                                    ? GoogleFonts.cairo(
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: const Color(
                                                            0xFF252527),
                                                        height: 1.1,
                                                      )
                                                    : GoogleFonts.inter(
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: const Color(
                                                            0xFF252527),
                                                        height: 1.1,
                                                      ),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 12.0),

                                  // 3c. Twin Row: Distance Away (169px) & Estimated Time (169px)
                                  SizedBox(
                                    height: 64.0,
                                    child: Row(
                                      children: [
                                        // 1st Card: Distance Away
                                        Expanded(
                                          child: Container(
                                            height: 64.0,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 14.0),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3F2F5),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 36.0,
                                                  height: 36.0,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xFFE7E6EB),
                                                  ),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.location_on_rounded,
                                                      size: 18.0,
                                                      color: Color(0xFF252527),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12.0),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        cleanDistance,
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 13.5,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: const Color(
                                                              0xFF252527),
                                                          height: 1.1,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const SizedBox(
                                                          height: 2.0),
                                                      Text(
                                                        isArabic
                                                            ? 'المسافة'
                                                            : 'Distance Away',
                                                        style: isArabic
                                                            ? GoogleFonts.cairo(
                                                                fontSize: 10.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: const Color(
                                                                    0xFF616166),
                                                                height: 1.1,
                                                              )
                                                            : GoogleFonts.inter(
                                                                fontSize: 10.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: const Color(
                                                                    0xFF616166),
                                                                height: 1.1,
                                                              ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 12.0),

                                        // 2nd Card: Estimated Time
                                        Expanded(
                                          child: Container(
                                            height: 64.0,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 14.0),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3F2F5),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 36.0,
                                                  height: 36.0,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xFFE7E6EB),
                                                  ),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.access_time_rounded,
                                                      size: 18.0,
                                                      color: Color(0xFF252527),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12.0),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        isArabic
                                                            ? widget.timeAr
                                                            : widget.timeEn,
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 13.5,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: const Color(
                                                              0xFF252527),
                                                          height: 1.1,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const SizedBox(
                                                          height: 2.0),
                                                      Text(
                                                        isArabic
                                                            ? 'الوقت المتوقع'
                                                            : 'Estimated time',
                                                        style: isArabic
                                                            ? GoogleFonts.cairo(
                                                                fontSize: 10.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: const Color(
                                                                    0xFF616166),
                                                                height: 1.1,
                                                              )
                                                            : GoogleFonts.inter(
                                                                fontSize: 10.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: const Color(
                                                                    0xFF616166),
                                                                height: 1.1,
                                                              ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
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

                                  const SizedBox(height: 12.0),

                                  // 3d. Customer Card: Avatar, Name, WhatsApp, Call, Vehicle
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F2F5),
                                      borderRadius:
                                          BorderRadius.circular(16.0),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Avatar + Customer info
                                            Row(
                                              children: [
                                                ClipOval(
                                                  child: Image.asset(
                                                    'assets/images/ahmed_khan.jpg',
                                                    width: 44.0,
                                                    height: 44.0,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Image.asset(
                                                      'assets/images/img.png',
                                                      width: 44.0,
                                                      height: 44.0,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12.0),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      isArabic
                                                          ? 'العميل'
                                                          : 'Customer',
                                                      style: isArabic
                                                          ? GoogleFonts.cairo(
                                                              fontSize: 11.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: const Color(
                                                                  0xFF75757A),
                                                            )
                                                          : GoogleFonts.inter(
                                                              fontSize: 11.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: const Color(
                                                                  0xFF75757A),
                                                            ),
                                                    ),
                                                    const SizedBox(height: 2.0),
                                                    Text(
                                                      isArabic
                                                          ? widget
                                                              .customerNameAr
                                                          : widget
                                                              .customerNameEn,
                                                      style: isArabic
                                                          ? GoogleFonts.cairo(
                                                              fontSize: 15.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: const Color(
                                                                  0xFF1C1C1E),
                                                            )
                                                          : GoogleFonts.inter(
                                                              fontSize: 15.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: const Color(
                                                                  0xFF1C1C1E),
                                                            ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),

                                            // WhatsApp & Call Buttons
                                            Row(
                                              children: [
                                                // WhatsApp Button
                                                GestureDetector(
                                                  onTap: () {
                                                    HapticFeedback
                                                        .lightImpact();
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          isArabic
                                                              ? 'جاري فتح واتساب...'
                                                              : 'Opening WhatsApp...',
                                                          style: GoogleFonts
                                                              .inter(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        duration:
                                                            const Duration(
                                                                seconds: 1),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 38.0,
                                                    height: 38.0,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color(0xFF25D366),
                                                    ),
                                                    child: const Center(
                                                      child: SizedBox(
                                                        width: 20.0,
                                                        height: 20.0,
                                                        child: CustomPaint(
                                                          painter:
                                                              _ActiveOfficialWhatsAppLogoPainter(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10.0),
                                                // Call Button
                                                GestureDetector(
                                                  onTap: () {
                                                    HapticFeedback
                                                        .lightImpact();
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          isArabic
                                                              ? 'جاري الاتصال بالعميل...'
                                                              : 'Calling client...',
                                                          style: GoogleFonts
                                                              .inter(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        duration:
                                                            const Duration(
                                                                seconds: 1),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    width: 38.0,
                                                    height: 38.0,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color(0xFF252527),
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.phone_rounded,
                                                        size: 18.0,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 12.0),

                                        // Vehicle Row
                                        Row(
                                          children: [
                                            const Icon(
                                                Icons.directions_car_rounded,
                                                size: 18.0,
                                                color: Color(0xFF252527)),
                                            const SizedBox(width: 8.0),
                                            Text(
                                              isArabic
                                                  ? widget.vehicleModelAr
                                                  : widget.vehicleModelEn,
                                              style: isArabic
                                                  ? GoogleFonts.cairo(
                                                      fontSize: 13.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: const Color(
                                                          0xFF252527),
                                                    )
                                                  : GoogleFonts.inter(
                                                      fontSize: 13.0,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: const Color(
                                                          0xFF252527),
                                                    ),
                                            ),
                                            const SizedBox(width: 12.0),
                                            Container(
                                                width: 1.0,
                                                height: 14.0,
                                                color:
                                                    const Color(0xFFE0DFE4)),
                                            const SizedBox(width: 12.0),
                                            // Plate Icon Badge
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.5,
                                                      vertical: 2.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: const Color(
                                                        0xFF9E9EA4),
                                                    width: 1.0),
                                                borderRadius:
                                                    BorderRadius.circular(3.5),
                                              ),
                                              child: Row(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  Container(
                                                      width: 1.0,
                                                      height: 7.5,
                                                      color: const Color(
                                                          0xFF75757A)),
                                                  const SizedBox(width: 2.0),
                                                  Container(
                                                      width: 1.0,
                                                      height: 7.5,
                                                      color: const Color(
                                                          0xFF75757A)),
                                                  const SizedBox(width: 2.0),
                                                  Container(
                                                      width: 1.0,
                                                      height: 7.5,
                                                      color: const Color(
                                                          0xFF75757A)),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 6.0),
                                            Text(
                                              widget.plateNumber,
                                              style: GoogleFonts.inter(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    const Color(0xFF5E5E63),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 12.0),

                                  // 3e. Service Status Stepper (5 Steps: Accepted -> On the way -> Arrived -> In Progress -> Completed)
                                  _buildStatusStepper(isArabic),

                                  const SizedBox(height: 12.0),

                                  // 3f. Customer Note Card
                                  // 3f. Customer Note Card (Exact previous screen branding)
                                  Container(
                                    width: 350.0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 15.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F2F5),
                                      borderRadius:
                                          BorderRadius.circular(12.0),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const _ActiveCustomerNoteIcon(),
                                        const SizedBox(width: 11.0),
                                        Expanded(
                                          child: SizedBox(
                                            width: 283.0,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  isArabic
                                                      ? 'ملاحظة العميل'
                                                      : 'Customer Note',
                                                  style: isArabic
                                                      ? GoogleFonts.cairo(
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: const Color(
                                                              0xFF252527),
                                                          height: 1.0,
                                                          letterSpacing: 0.0,
                                                        )
                                                      : GoogleFonts.inter(
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: const Color(
                                                              0xFF252527),
                                                          height: 1.0,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6.0),
                                                Text(
                                                  isArabic
                                                      ? widget.customerNoteAr
                                                      : widget.customerNoteEn,
                                                  style: isArabic
                                                      ? GoogleFonts.cairo(
                                                          fontSize: 10.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: const Color(
                                                              0xFF616166),
                                                          height: 1.1,
                                                          letterSpacing: 0.0,
                                                        )
                                                      : GoogleFonts.inter(
                                                          fontSize: 10.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: const Color(
                                                              0xFF616166),
                                                          height: 1.1,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
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

                          const SizedBox(height: 12.0),

                          // 3g. Primary Action Button: "I've Arrived ->" (Exact previous button branding)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                setState(() {
                                  if (_currentStep < 4) {
                                    _currentStep++;
                                  }
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFF8B53FE),
                                    content: Text(
                                      _getSuccessMessage(isArabic),
                                      style: GoogleFonts.inter(color: Colors.white),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                height: 52.0,
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B53FE),
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x338B53FE),
                                      blurRadius: 10.0,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _getActionButtonText(isArabic),
                                      style: isArabic
                                          ? GoogleFonts.cairo(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              height: 22.0 / 14.0,
                                              letterSpacing: 0.0,
                                            )
                                          : GoogleFonts.inter(
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              height: 22.0 / 14.0,
                                              letterSpacing: 0.0,
                                            ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: 8.0),
                                    Icon(
                                      isArabic
                                          ? Icons.arrow_back_rounded
                                          : Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 18.0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12.0),

                          // 3h. Bottom Home Indicator Bar (Always with bottom)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            width: 134.0,
                            height: 5.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1C1E),
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );

            if (isDesktopWeb) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFF0F1F5),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Container(
                    width: designWidth,
                    height: designHeight,
                    margin: const EdgeInsets.symmetric(vertical: 24.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(44),
                      border: Border.all(
                        color: const Color(0xFF8B53FE).withValues(alpha: 0.35),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 36,
                          spreadRadius: 6,
                        ),
                        BoxShadow(
                          color: const Color(0xFF8B53FE).withValues(alpha: 0.10),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(42),
                      child: screenContent,
                    ),
                  ),
                ),
              );
            }

            return Center(
              child: SizedBox(
                width: containerWidth,
                height: containerHeight,
                child: screenContent,
              ),
            );
          },
        ),
      ),
    );
  }

  String _getStepStatusText(bool isArabic) {
    switch (_currentStep) {
      case 0:
        return isArabic ? 'تم القبول' : 'Accepted';
      case 1:
        return isArabic ? 'في الطريق' : 'On the way';
      case 2:
        return isArabic ? 'تم الوصول' : 'Arrived';
      case 3:
        return isArabic ? 'جاري العمل' : 'In Progress';
      case 4:
        return isArabic ? 'مكتمل' : 'Completed';
      default:
        return isArabic ? 'في الطريق' : 'On the way';
    }
  }

  String _getActionButtonText(bool isArabic) {
    switch (_currentStep) {
      case 0:
      case 1:
        return isArabic ? 'لقد وصلت' : "I've Arrived";
      case 2:
        return isArabic ? 'بدء الخدمة' : 'Start Service';
      case 3:
        return isArabic ? 'إكمال الخدمة' : 'Complete Service';
      case 4:
      default:
        return isArabic ? 'تم الانتهاء بنجاح' : 'Service Completed';
    }
  }

  String _getSuccessMessage(bool isArabic) {
    switch (_currentStep) {
      case 2:
        return isArabic ? 'تم تأكيد الوصول للعميل!' : 'Arrival confirmed!';
      case 3:
        return isArabic ? 'تم بدء تنفيذ الخدمة!' : 'Service started!';
      case 4:
        return isArabic
            ? 'تم إكمال الخدمة بنجاح!'
            : 'Service successfully completed!';
      default:
        return isArabic
            ? 'تم تحديث حالة الطلب!'
            : 'Request status updated!';
    }
  }

  /// 5-Step Stepper Widget matching exact Figma design from user screenshot:
  /// Accepted (done) -> On the way (active) -> Arrived -> In Progress -> Completed
  Widget _buildStatusStepper(bool isArabic) {
    final steps = [
      {'key': 'accepted', 'en': 'Accepted', 'ar': 'تم القبول'},
      {'key': 'on_way', 'en': 'On the way', 'ar': 'في الطريق'},
      {'key': 'arrived', 'en': 'Arrived', 'ar': 'تم الوصول'},
      {'key': 'in_progress', 'en': 'In Progress', 'ar': 'جاري العمل'},
      {'key': 'completed', 'en': 'Completed', 'ar': 'مكتمل'},
    ];

    return Column(
      children: [
        // Stepper Nodes and Connecting Lines Row
        SizedBox(
          height: 30.0,
          child: Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isEven) {
                final stepIdx = index ~/ 2;
                final bool isDone = stepIdx < _currentStep;
                final bool isActive = stepIdx == _currentStep;

                if (isDone) {
                  // Step Completed: Purple circle with white checkmark
                  return Container(
                    width: 24.0,
                    height: 24.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF8B53FE),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 15.0,
                        color: Colors.white,
                      ),
                    ),
                  );
                } else if (isActive) {
                  // Step Active: Concentric purple ring
                  return Container(
                    width: 26.0,
                    height: 26.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFF8B53FE),
                        width: 2.2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x338B53FE),
                          blurRadius: 6.0,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 12.0,
                        height: 12.0,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF8B53FE),
                        ),
                      ),
                    ),
                  );
                } else {
                  // Step Pending: Light grey outlined circle
                  return Container(
                    width: 22.0,
                    height: 22.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                    ),
                  );
                }
              } else {
                // Connecting line between steps
                final lineIdx = index ~/ 2;
                final bool isLineDone = lineIdx < _currentStep;
                return Expanded(
                  child: Container(
                    height: 2.0,
                    margin: const EdgeInsets.symmetric(horizontal: 2.0),
                    color: isLineDone
                        ? const Color(0xFF8B53FE)
                        : const Color(0xFFE5E7EB),
                  ),
                );
              }
            }),
          ),
        ),

        const SizedBox(height: 6.0),

        // Stepper Labels Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (stepIdx) {
            final bool isDone = stepIdx < _currentStep;
            final bool isActive = stepIdx == _currentStep;
            final String label =
                isArabic ? steps[stepIdx]['ar']! : steps[stepIdx]['en']!;

            Color textColor;
            FontWeight fontWeight;
            if (isActive) {
              textColor = const Color(0xFF8B53FE);
              fontWeight = FontWeight.w600;
            } else if (isDone) {
              textColor = const Color(0xFF252527);
              fontWeight = FontWeight.w500;
            } else {
              textColor = const Color(0xFF8E8E93);
              fontWeight = FontWeight.w400;
            }

            return SizedBox(
              width: 60.0,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: isArabic
                    ? GoogleFonts.cairo(
                        fontSize: 9.5,
                        fontWeight: fontWeight,
                        color: textColor,
                        height: 1.1,
                      )
                    : GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: fontWeight,
                        color: textColor,
                        height: 1.1,
                      ),
                maxLines: 1,
                overflow: TextOverflow.visible,
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Route painter connecting pin to car
class _ActiveStreetRoutePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _ActiveStreetRoutePainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(18.0, 0.0);
    path.lineTo(6.0, size.height * 0.52);
    path.quadraticBezierTo(2.0, size.height * 0.65, 16.0, size.height * 0.78);
    path.lineTo(size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ActiveStreetRoutePainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}

/// Tooltip speech bubble painter with downward pointer
class _ActiveTooltipSpeechBubblePainter extends CustomPainter {
  final Color color;
  final double cornerRadius;
  final double pointerWidth;
  final double pointerHeight;
  final Color? shadowColor;

  const _ActiveTooltipSpeechBubblePainter({
    required this.color,
    this.cornerRadius = 6.0,
    this.pointerWidth = 8.0,
    this.pointerHeight = 6.0,
    this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bodyHeight = size.height - pointerHeight;
    final centerX = size.width / 2.0;

    final path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, bodyHeight),
        Radius.circular(cornerRadius),
      ),
    );

    // Downward pointer triangle
    path.moveTo(centerX - pointerWidth / 2.0, bodyHeight);
    path.lineTo(centerX, size.height);
    path.lineTo(centerX + pointerWidth / 2.0, bodyHeight);
    path.close();

    if (shadowColor != null) {
      canvas.drawShadow(path, shadowColor!, 4.0, true);
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ActiveTooltipSpeechBubblePainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Official WhatsApp Logo Painter (Authentic PathFillType.evenOdd vector)
class _ActiveOfficialWhatsAppLogoPainter extends CustomPainter {
  const _ActiveOfficialWhatsAppLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final double scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final path = Path()..fillType = PathFillType.evenOdd;

    // 1. Outer speech-bubble contour
    path.moveTo(12.04, 2.0);
    path.cubicTo(6.58, 2.0, 2.13, 6.45, 2.13, 11.91);
    path.cubicTo(2.13, 13.66, 2.59, 15.36, 3.45, 16.86);
    path.lineTo(2.05, 22.0);
    path.lineTo(7.3, 20.62);
    path.cubicTo(8.75, 21.41, 10.38, 21.83, 12.04, 21.83);
    path.cubicTo(17.5, 21.83, 21.95, 17.38, 21.95, 11.92);
    path.cubicTo(21.95, 9.27, 20.92, 6.78, 19.05, 4.91);
    path.cubicTo(17.18, 3.03, 14.69, 2.0, 12.04, 2.0);
    path.close();

    // 2. Inner speech-bubble hole (crisp outline cut)
    path.moveTo(12.05, 3.67);
    path.cubicTo(14.25, 3.67, 16.31, 4.53, 17.87, 6.09);
    path.cubicTo(19.42, 7.65, 20.28, 9.72, 20.28, 11.92);
    path.cubicTo(20.28, 16.46, 16.58, 20.16, 12.04, 20.16);
    path.cubicTo(10.66, 20.16, 9.3, 19.8, 8.1, 19.11);
    path.lineTo(7.81, 18.94);
    path.lineTo(4.7, 19.76);
    path.lineTo(5.53, 16.73);
    path.lineTo(5.34, 16.43);
    path.cubicTo(4.56, 15.19, 4.15, 13.57, 4.15, 11.91);
    path.cubicTo(4.15, 7.37, 7.85, 3.67, 12.05, 3.67);
    path.close();

    // 3. Official telephone handset inside
    path.moveTo(8.53, 7.33);
    path.cubicTo(8.37, 7.33, 8.1, 7.39, 7.87, 7.64);
    path.cubicTo(7.65, 7.89, 7.02, 8.48, 7.02, 9.71);
    path.cubicTo(7.02, 10.93, 7.91, 12.11, 8.03, 12.27);
    path.cubicTo(8.16, 12.44, 9.75, 14.88, 12.19, 15.93);
    path.cubicTo(14.22, 16.81, 14.63, 16.63, 15.08, 16.59);
    path.cubicTo(15.53, 16.55, 16.53, 16.0, 16.74, 15.42);
    path.cubicTo(16.95, 14.84, 16.95, 14.34, 16.89, 14.24);
    path.cubicTo(16.82, 14.13, 16.66, 14.07, 16.41, 13.95);
    path.cubicTo(16.16, 13.82, 14.94, 13.22, 14.71, 13.14);
    path.cubicTo(14.49, 13.06, 14.32, 13.01, 14.16, 13.26);
    path.cubicTo(13.99, 13.51, 13.52, 14.07, 13.37, 14.24);
    path.cubicTo(13.23, 14.4, 13.08, 14.42, 12.83, 14.3);
    path.cubicTo(12.58, 14.17, 11.78, 13.91, 10.83, 13.07);
    path.cubicTo(10.09, 12.41, 9.59, 11.6, 9.47, 11.35);
    path.cubicTo(9.34, 11.1, 9.45, 10.97, 9.58, 10.84);
    path.cubicTo(9.69, 10.73, 9.83, 10.55, 9.95, 10.41);
    path.cubicTo(10.08, 10.26, 10.12, 10.16, 10.2, 9.99);
    path.cubicTo(10.28, 9.83, 10.24, 9.68, 10.18, 9.56);
    path.cubicTo(10.12, 9.44, 9.63, 8.23, 9.42, 7.74);
    path.cubicTo(9.22, 7.25, 9.02, 7.32, 8.87, 7.31);
    path.cubicTo(8.72, 7.31, 8.55, 7.33, 8.53, 7.33);
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ActiveOfficialWhatsAppLogoPainter oldDelegate) =>
      false;
}

/// Customer Note notepad icon
class _ActiveCustomerNoteIcon extends StatelessWidget {
  const _ActiveCustomerNoteIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24.0,
      height: 26.0,
      child: CustomPaint(
        painter: _ActiveCustomerNoteIconPainter(),
      ),
    );
  }
}

class _ActiveCustomerNoteIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final darkPaint = Paint()
      ..color = const Color(0xFF252527)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final lightPaint = Paint()
      ..color = const Color(0xFFF3F2F5)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.0, 4.0, size.width, size.height - 4.0),
        const Radius.circular(6.0),
      ),
      darkPaint,
    );

    // Left binder clip
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(4.5, 0.0, 3.5, 6.0),
        const Radius.circular(1.75),
      ),
      darkPaint,
    );

    // Right binder clip
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(16.0, 0.0, 3.5, 6.0),
        const Radius.circular(1.75),
      ),
      darkPaint,
    );

    // Note line 1
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(5.0, 10.5, 8.5, 2.2),
        const Radius.circular(1.1),
      ),
      lightPaint,
    );

    // Note line 2
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(5.0, 15.5, 14.0, 2.2),
        const Radius.circular(1.1),
      ),
      lightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ActiveCustomerNoteIconPainter oldDelegate) =>
      false;
}
