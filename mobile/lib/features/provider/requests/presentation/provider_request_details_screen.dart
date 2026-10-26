import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/requests/presentation/provider_active_request_screen.dart';
import 'package:mobile/features/location/presentation/widgets/top_down_car_widget.dart';
import 'package:mobile/features/location/presentation/widgets/real_map_background_widget.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_animated_language_toggle.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_scroll_behavior.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_header_back_button.dart';

/// Provider Request Details Screen
/// Exact Figma specification matching user screenshot:
///
/// header:
///   - Circular back button `<`
///   - Title: "Request Details"
///   - Language toggle on right side as in previous screens
///
/// complete screen layout:
///   width: 390;
///   height: 843;
///   top: 1px;
///   angle: 0 deg;
///   opacity: 1;
///   background: linear-gradient(180deg, #FFFFFF 2.14%, rgba(255, 255, 255, 0.839534) 17.05%, rgba(255, 255, 255, 0) 26.93%);
///
/// map layout:
///   - Route line from location pin to car
///   - Tooltip badge with distance (e.g. 2.4 km) pointing down to pin
///   - Pin with glowing halo rings
///   - Top-down vector car
///   - White speech-bubble tooltip badge above car: "You"
///   - Landmark: "النخيل مول / Al Nakheel Mall"
///   - Floating GPS / location re-center target button
///
/// bottom card layout:
///   - Customer side layout & branding
///   - Handle, customer profile, WhatsApp & Call shortcuts, service details, and Accept/Decline action buttons
class ProviderRequestDetailsScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String serviceTypeEn;
  final String serviceTypeAr;
  final String locationEn;
  final String locationAr;
  final String distanceEn;
  final String distanceAr;
  final String timeEn;
  final String timeAr;
  final String badgeEn;
  final String badgeAr;
  final String imageAsset;
  final String status;

  const ProviderRequestDetailsScreen({
    super.key,
    this.requestId = 'REQ-101',
    this.serviceTypeEn = 'Battery Jump Start',
    this.serviceTypeAr = 'شحن وتبديل بطارية',
    this.locationEn = 'King Abdullah Rd, Riyadh',
    this.locationAr = 'طريق الملك عبدالله، الرياض',
    this.distanceEn = '2.4 km',
    this.distanceAr = '٢.٤ كم',
    this.timeEn = 'Just now',
    this.timeAr = 'الآن',
    this.badgeEn = 'New Request',
    this.badgeAr = 'طلب جديد',
    this.imageAsset = 'assets/images/img.png',
    this.status = 'new',
  });

  static const double designWidth = 390.0;
  static const double designHeight = 843.0;

  @override
  ConsumerState<ProviderRequestDetailsScreen> createState() =>
      _ProviderRequestDetailsScreenState();
}

class _ProviderRequestDetailsScreenState
    extends ConsumerState<ProviderRequestDetailsScreen> {
  static const double designWidth = 390.0;
  static const double designHeight = 843.0;

  bool _isSheetExpanded = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;
    final cleanDistance = (isArabic ? widget.distanceAr : widget.distanceEn)
        .replaceAll(' away', '')
        .replaceAll('على بعد ', '')
        .trim();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

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

            final double topSafeArea =
                MediaQuery.maybeOf(context)?.padding.top ?? 0.0;
            final double bottomSafeArea =
                MediaQuery.maybeOf(context)?.padding.bottom ?? 0.0;
            final double headerTop =
                topSafeArea > 0 ? (topSafeArea + 8.0) : 52.0;

            final Widget screenContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Map Section Background (top 0 to ~ 515px)
                  Positioned(
                    top: 1.0,
                    left: 0.0,
                    width: containerWidth,
                    height: 520.0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 1a. Live Real Slippy Map Layer
                        Positioned.fill(
                          child: RealMapBackgroundWidget(
                            enableDrag: true,
                            zoom: 15.0,
                            trackingStep: MapTrackingStep.onTheWay,
                            driverName: isArabic ? 'أنت' : 'You',
                            etaText: cleanDistance,
                            distanceText: cleanDistance,
                            showControls: true,
                          ),
                        ),

                        // 1b. Complete Screen Gradient Overlay Layer:
                        // background: linear-gradient(180deg, #FFFFFF 2.14%, rgba(255, 255, 255, 0.839534) 17.05%, rgba(255, 255, 255, 0) 26.93%);
                        Positioned.fill(
                          child: const IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: [0.0214, 0.1705, 0.2693, 1.0],
                                  colors: [
                                    Color(0xFFFFFFFF), // #FFFFFF 2.14%
                                    Color(0xD6FFFFFF), // rgba(255, 255, 255, 0.839534) 17.05%
                                    Color(0x00FFFFFF), // rgba(255, 255, 255, 0) 26.93%
                                    Color(0x00FFFFFF),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),


                        // 1h. Landmark Indicator: "Al Nakheel Mall / النخيل مول"
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
                                  color: const Color(0xFF566663).withValues(alpha: 0.15),
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

                        // 1i. Floating Location / GPS Re-Center Target Button:
                        Positioned(
                          top: 232.0,
                          right: 20.0 + ((containerWidth - 390.0) / 2.0),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
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

                  // 2. Header: Circular Chevron Back Button + Title + Language Toggle on Right
                  Positioned(
                    top: headerTop,
                    left: 20.0,
                    right: 20.0,
                    height: 38.0,
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

                        const SizedBox(width: 12.0),

                        // Title: Request Details
                        Expanded(
                          child: Text(
                            isArabic ? 'تفاصيل الطلب' : 'Request Details',
                            style: isArabic
                                ? GoogleFonts.cairo(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1C2926),
                                    height: 1.2,
                                  )
                                : GoogleFonts.inter(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1C2926),
                                    height: 1.2,
                                  ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 8.0),

                        // Animated Language Toggle on right side of header
                        const ProviderAnimatedLanguageToggle.compact(),
                      ],
                    ),
                  ),

                  // 3. User-friendly Expandable & Scrollable Bottom Card
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    top: _isSheetExpanded
                        ? (topSafeArea > 0 ? (topSafeArea + 50.0) : 88.0)
                        : 291.0,
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
                            color: Color(0x14000000), // 0px -2px 12px 0px #00000014
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
                                  HapticFeedback.lightImpact();
                                  setState(() => _isSheetExpanded = true);
                                } else if (details.primaryVelocity! > 80) {
                                  HapticFeedback.lightImpact();
                                  setState(() => _isSheetExpanded = false);
                                }
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
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

                          // Complete Card Content Area (Scrollable with AlwaysScrollableScrollPhysics)
                          Expanded(
                            child: ScrollConfiguration(
                              behavior: const ProviderCardScrollBehavior(),
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                padding: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, bottomSafeArea > 0 ? (bottomSafeArea + 24.0) : 24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 3a. Row 1: Service Image + Service Title + Client Name & Location
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12.0),
                                          child: Image.asset(
                                            widget.imageAsset.isNotEmpty
                                                ? widget.imageAsset
                                                : 'assets/images/img.png',
                                            width: 52.0,
                                            height: 52.0,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: 52.0,
                                                height: 52.0,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF3F2F5),
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                                child: const Icon(
                                                  Icons.car_repair_rounded,
                                                  color: Color(0xFF8B53FE),
                                                  size: 26.0,
                                                ),
                                              );
                                            },
                                          ),
                                        ),

                                        const SizedBox(width: 16.0),

                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                isArabic ? widget.serviceTypeAr : widget.serviceTypeEn,
                                                style: isArabic
                                                    ? GoogleFonts.cairo(
                                                        fontSize: 14.0,
                                                        fontWeight: FontWeight.w500,
                                                        color: const Color(0xFF252527),
                                                        height: 1.2,
                                                      )
                                                    : GoogleFonts.inter(
                                                        fontSize: 14.0,
                                                        fontWeight: FontWeight.w500,
                                                        color: const Color(0xFF252527),
                                                        height: 1.2,
                                                      ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4.0),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    isArabic ? 'من فيصل الحربي' : 'From Faisal Al-Harbi',
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
                                                          ),
                                                  ),
                                                  const SizedBox(width: 8.0),
                                                  Container(
                                                    width: 4.0,
                                                    height: 4.0,
                                                    decoration: const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color(0xFF616166),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8.0),
                                                  Flexible(
                                                    child: Text(
                                                      isArabic ? widget.locationAr : widget.locationEn,
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
                                                            ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14.0),

                                    // 3b. Customer Location Card
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F2F5),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 36.0,
                                            height: 36.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE7E6EB),
                                              borderRadius: BorderRadius.circular(8.0),
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
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  isArabic ? 'موقع العميل' : 'Customer Location',
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
                                                        ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4.0),
                                                Text(
                                                  isArabic ? widget.locationAr : widget.locationEn,
                                                  style: isArabic
                                                      ? GoogleFonts.cairo(
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight.w500,
                                                          color: const Color(0xFF252527),
                                                          height: 1.1,
                                                        )
                                                      : GoogleFonts.inter(
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight.w500,
                                                          color: const Color(0xFF252527),
                                                          height: 1.1,
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

                                    const SizedBox(height: 12.0),

                                    // 3c. Distance Away & Estimated Time Twin Cards
                                    Row(
                                      children: [
                                        // 1st Card: Distance Away
                                        Expanded(
                                          child: Container(
                                            height: 64.0,
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3F2F5),
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 36.0,
                                                  height: 36.0,
                                                  decoration: const BoxDecoration(
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
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        isArabic ? widget.distanceAr : widget.distanceEn,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 13.5,
                                                          fontWeight: FontWeight.w600,
                                                          color: const Color(0xFF252527),
                                                          height: 1.1,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 2.0),
                                                      Text(
                                                        isArabic ? 'المسافة' : 'Distance Away',
                                                        style: isArabic
                                                            ? GoogleFonts.cairo(
                                                                fontSize: 10.0,
                                                                fontWeight: FontWeight.w400,
                                                                color: const Color(0xFF616166),
                                                                height: 1.1,
                                                              )
                                                            : GoogleFonts.inter(
                                                                fontSize: 10.0,
                                                                fontWeight: FontWeight.w400,
                                                                color: const Color(0xFF616166),
                                                                height: 1.1,
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
                                        ),

                                        const SizedBox(width: 12.0),

                                        // 2nd Card: Estimated Time
                                        Expanded(
                                          child: Container(
                                            height: 64.0,
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3F2F5),
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 36.0,
                                                  height: 36.0,
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xFFE7E6EB),
                                                  ),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.access_time_filled_rounded,
                                                      size: 18.0,
                                                      color: Color(0xFF252527),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12.0),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        isArabic ? '٨ دقائق' : '8 min',
                                                        style: isArabic
                                                            ? GoogleFonts.cairo(
                                                                fontSize: 13.5,
                                                                fontWeight: FontWeight.w600,
                                                                color: const Color(0xFF252527),
                                                                height: 1.1,
                                                              )
                                                            : GoogleFonts.inter(
                                                                fontSize: 13.5,
                                                                fontWeight: FontWeight.w600,
                                                                color: const Color(0xFF252527),
                                                                height: 1.1,
                                                              ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 2.0),
                                                      Text(
                                                        isArabic ? 'الوقت المتوقع' : 'Estimated time',
                                                        style: isArabic
                                                            ? GoogleFonts.cairo(
                                                                fontSize: 10.0,
                                                                fontWeight: FontWeight.w400,
                                                                color: const Color(0xFF616166),
                                                                height: 1.1,
                                                              )
                                                            : GoogleFonts.inter(
                                                                fontSize: 10.0,
                                                                fontWeight: FontWeight.w400,
                                                                color: const Color(0xFF616166),
                                                                height: 1.1,
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
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12.0),

                                    // 3d. Customer Card (Avatar, Name, WhatsApp, Call, Vehicle, Plate)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F2F5),
                                        borderRadius: BorderRadius.circular(16.0),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                                      errorBuilder: (context, error, stackTrace) => Image.asset(
                                                        'assets/images/img.png',
                                                        width: 44.0,
                                                        height: 44.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12.0),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        isArabic ? 'العميل' : 'Customer',
                                                        style: isArabic
                                                            ? GoogleFonts.cairo(
                                                                fontSize: 11.0,
                                                                fontWeight: FontWeight.w400,
                                                                color: const Color(0xFF75757A),
                                                              )
                                                            : GoogleFonts.inter(
                                                                fontSize: 11.0,
                                                                fontWeight: FontWeight.w400,
                                                                color: const Color(0xFF75757A),
                                                              ),
                                                      ),
                                                      const SizedBox(height: 2.0),
                                                      Text(
                                                        isArabic ? 'أحمد خان' : 'Ahmed Khan',
                                                        style: isArabic
                                                            ? GoogleFonts.cairo(
                                                                fontSize: 15.0,
                                                                fontWeight: FontWeight.w600,
                                                                color: const Color(0xFF1C1C1E),
                                                              )
                                                            : GoogleFonts.inter(
                                                                fontSize: 15.0,
                                                                fontWeight: FontWeight.w600,
                                                                color: const Color(0xFF1C1C1E),
                                                              ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),

                                              // Contact Buttons: WhatsApp green, Call dark #252527
                                              Row(
                                                children: [
                                                  // WhatsApp Button
                                                  GestureDetector(
                                                    onTap: () {
                                                      HapticFeedback.lightImpact();
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            isArabic ? 'جاري فتح واتساب...' : 'Opening WhatsApp...',
                                                            style: GoogleFonts.inter(color: Colors.white),
                                                          ),
                                                          duration: const Duration(seconds: 1),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      width: 38.0,
                                                      height: 38.0,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFF25D366),
                                                      ),
                                                      child: const Center(
                                                        child: SizedBox(
                                                          width: 20.0,
                                                          height: 20.0,
                                                          child: CustomPaint(
                                                            painter: _OfficialWhatsAppLogoPainter(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10.0),
                                                  // Call Button (dark #252527)
                                                  GestureDetector(
                                                    onTap: () {
                                                      HapticFeedback.lightImpact();
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            isArabic ? 'جاري الاتصال بالعميل...' : 'Calling client...',
                                                            style: GoogleFonts.inter(color: Colors.white),
                                                          ),
                                                          duration: const Duration(seconds: 1),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      width: 38.0,
                                                      height: 38.0,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFF252527),
                                                      ),
                                                      child: const Center(
                                                        child: Icon(Icons.phone_rounded, size: 18.0, color: Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 14.0),

                                          // Vehicle row: Toyota Corolla | Plate badge KSA 1234
                                          Row(
                                            children: [
                                              const Icon(Icons.directions_car_rounded, size: 18.0, color: Color(0xFF252527)),
                                              const SizedBox(width: 8.0),
                                              Text(
                                                isArabic ? 'تويوتا كورولا' : 'Toyota Corolla',
                                                style: isArabic
                                                    ? GoogleFonts.cairo(
                                                        fontSize: 13.0,
                                                        fontWeight: FontWeight.w500,
                                                        color: const Color(0xFF252527),
                                                      )
                                                    : GoogleFonts.inter(
                                                        fontSize: 13.0,
                                                        fontWeight: FontWeight.w500,
                                                        color: const Color(0xFF252527),
                                                      ),
                                              ),
                                              const SizedBox(width: 12.0),
                                              Container(width: 1.0, height: 14.0, color: const Color(0xFFE0DFE4)),
                                              const SizedBox(width: 12.0),
                                              // Plate icon badge matching screenshot
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2.0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: const Color(0xFF9E9EA4), width: 1.0),
                                                  borderRadius: BorderRadius.circular(3.5),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Container(width: 1.0, height: 7.5, color: const Color(0xFF75757A)),
                                                    const SizedBox(width: 2.0),
                                                    Container(width: 1.0, height: 7.5, color: const Color(0xFF75757A)),
                                                    const SizedBox(width: 2.0),
                                                    Container(width: 1.0, height: 7.5, color: const Color(0xFF75757A)),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 6.0),
                                              Text(
                                                'KSA 1234',
                                                style: GoogleFonts.inter(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color(0xFF5E5E63),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 12.0),

                                    // 3e. Customer Note Card
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F2F5),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const _CustomerNoteIcon(),
                                          const SizedBox(width: 11.0),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  isArabic ? 'ملاحظة العميل' : 'Customer Note',
                                                  style: isArabic
                                                      ? GoogleFonts.cairo(
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight.w500,
                                                          color: const Color(0xFF252527),
                                                          height: 1.0,
                                                          letterSpacing: 0.0,
                                                        )
                                                      : GoogleFonts.inter(
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight.w500,
                                                          color: const Color(0xFF252527),
                                                          height: 1.0,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6.0),
                                                Text(
                                                  isArabic
                                                      ? 'البطارية فارغة والسيارة لا تعمل. أحتاج إلى شحن بطارية.'
                                                      : 'Battery is dead and the car won’t start. Need a jump start.',
                                                  style: isArabic
                                                      ? GoogleFonts.cairo(
                                                          fontSize: 10.0,
                                                          fontWeight: FontWeight.w400,
                                                          color: const Color(0xFF616166),
                                                          height: 1.2,
                                                          letterSpacing: 0.0,
                                                        )
                                                      : GoogleFonts.inter(
                                                          fontSize: 10.0,
                                                          fontWeight: FontWeight.w400,
                                                          color: const Color(0xFF616166),
                                                          height: 1.2,
                                                          letterSpacing: 0.0,
                                                        ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 16.0),

                                    // 3f. Action Buttons: Decline & Accept Request
                                    Row(
                                      children: [
                                        // Decline button
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              HapticFeedback.lightImpact();
                                              Navigator.of(context).maybePop();
                                            },
                                            child: Container(
                                              height: 52.0,
                                              padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFEBEB),
                                                borderRadius: BorderRadius.circular(12.0),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                isArabic ? 'رفض' : 'Decline',
                                                style: isArabic
                                                    ? GoogleFonts.cairo(
                                                        fontSize: 14.0,
                                                        fontWeight: FontWeight.w500,
                                                        color: const Color(0xFFFF383C),
                                                        height: 1.2,
                                                        letterSpacing: 0.0,
                                                      )
                                                    : GoogleFonts.inter(
                                                        fontSize: 14.0,
                                                        fontWeight: FontWeight.w500,
                                                        color: const Color(0xFFFF383C),
                                                        height: 1.2,
                                                        letterSpacing: 0.0,
                                                      ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 12.0),

                                        // Accept button
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              HapticFeedback.mediumImpact();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  backgroundColor: const Color(0xFF8B53FE),
                                                  content: Text(
                                                    isArabic
                                                        ? 'تم قبول الطلب بنجاح!'
                                                        : 'Request Accepted Successfully!',
                                                    style: GoogleFonts.inter(color: Colors.white),
                                                  ),
                                                  duration: const Duration(seconds: 1),
                                                ),
                                              );
                                              Navigator.of(context).pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (_) => ProviderActiveRequestScreen(
                                                    requestId: widget.requestId,
                                                    serviceTypeEn: widget.serviceTypeEn,
                                                    serviceTypeAr: widget.serviceTypeAr,
                                                    locationEn: widget.locationEn,
                                                    locationAr: widget.locationAr,
                                                    distanceEn: widget.distanceEn,
                                                    distanceAr: widget.distanceAr,
                                                    timeEn: '8 min',
                                                    timeAr: '٨ دقائق',
                                                    customerNameEn: 'Ahmed Khan',
                                                    customerNameAr: 'أحمد خان',
                                                    vehicleModelEn: 'Toyota Corolla',
                                                    vehicleModelAr: 'تويوتا كورولا',
                                                    plateNumber: 'KSA 1234',
                                                    customerNoteEn: 'Battery is dead and the car won’t start. Need a jump start.',
                                                    customerNoteAr: 'البطارية فارغة والسيارة لا تعمل. أحتاج إلى شحن بطارية.',
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              height: 52.0,
                                              padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
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
                                              child: Text(
                                                isArabic ? 'قبول الطلب' : 'Accept Request',
                                                style: isArabic
                                                    ? GoogleFonts.cairo(
                                                        fontSize: 14.0,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.white,
                                                        height: 1.2,
                                                        letterSpacing: 0.0,
                                                      )
                                                    : GoogleFonts.inter(
                                                        fontSize: 14.0,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.white,
                                                        height: 1.2,
                                                        letterSpacing: 0.0,
                                                      ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16.0),

                                    // 3g. Bottom Home Indicator Bar (with dynamic safe-area)
                                    Center(
                                      child: Container(
                                        width: 134.0,
                                        height: 5.0,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1C1C1E),
                                          borderRadius: BorderRadius.circular(100.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
}

/// Street route painter connecting pin to car matching user screenshot
class _StreetRoutePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _StreetRoutePainter({
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
    // Starting at top under pin (x: 18, y: 0)
    path.moveTo(18.0, 0.0);
    // Going down along street
    path.lineTo(6.0, size.height * 0.52);
    // Curve corner smoothly
    path.quadraticBezierTo(2.0, size.height * 0.65, 16.0, size.height * 0.78);
    // Follow street down-right straight to the vehicle
    path.lineTo(size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StreetRoutePainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}

/// Speech bubble tooltip painter with downward pointer
class _TooltipSpeechBubblePainter extends CustomPainter {
  final Color color;
  final double cornerRadius;
  final double pointerWidth;
  final double pointerHeight;
  final Color? shadowColor;

  const _TooltipSpeechBubblePainter({
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
  bool shouldRepaint(covariant _TooltipSpeechBubblePainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Custom notepad/calendar icon with binder rings and cutouts matching user screenshot
class _CustomerNoteIcon extends StatelessWidget {
  const _CustomerNoteIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24.0,
      height: 26.0,
      child: CustomPaint(
        painter: _CustomerNoteIconPainter(),
      ),
    );
  }
}

class _CustomerNoteIconPainter extends CustomPainter {
  const _CustomerNoteIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bodyPaint = Paint()
      ..color = const Color(0xFF252527)
      ..style = PaintingStyle.fill;

    final Paint cutoutPaint = Paint()
      ..color = const Color(0xFFF3F2F5)
      ..style = PaintingStyle.fill;

    // Body: rounded rectangle starting at y = 4 to leave room for top binder rings
    final RRect bodyRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 4.0, size.width, size.height - 4.0),
      const Radius.circular(6.0),
    );
    canvas.drawRRect(bodyRRect, bodyPaint);

    // Two binder rings on top
    final RRect ring1 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(4.5, 0.0, 3.5, 6.0),
      const Radius.circular(1.75),
    );
    final RRect ring2 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(16.0, 0.0, 3.5, 6.0),
      const Radius.circular(1.75),
    );
    canvas.drawRRect(ring1, bodyPaint);
    canvas.drawRRect(ring2, bodyPaint);

    // Two horizontal cutouts inside notepad body
    // Top shorter slit
    final RRect line1 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(5.0, 10.5, 8.5, 2.2),
      const Radius.circular(1.1),
    );
    // Bottom longer slit
    final RRect line2 = RRect.fromRectAndRadius(
      const Rect.fromLTWH(5.0, 15.5, 14.0, 2.2),
      const Radius.circular(1.1),
    );
    canvas.drawRRect(line1, cutoutPaint);
    canvas.drawRRect(line2, cutoutPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Real Official WhatsApp Vector Logo Painter
class _OfficialWhatsAppLogoPainter extends CustomPainter {
  const _OfficialWhatsAppLogoPainter();

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


