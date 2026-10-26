import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_scroll_behavior.dart';
import 'package:mobile/features/provider/requests/presentation/provider_requests_screen.dart';

/// Provider Service Completed Screen
/// Screen branding:
/// - width: 390; height: 908; angle: 0 deg; opacity: 1; background: #FFFFFF;
/// - Header chevron: 36x36 at top: 56px, left: 20px, border: 1px solid #252527
/// - < chevron: 6x13 at top: 68px, left: 35px
/// - Celebration widget: 350x136 at top: 112px, left: 20px, gap: 20px
/// - Heading: "Service Details"
/// - Next widget layout: 350x518 at top: 268px, left: 20px, gap: 16px
///   Containing:
///   1. Service thumbnail ('assets/images/img.png'), Title ('Battery Jump Start'),
///      Vehicle ('Toyota Corolla'), Plate ('KSA 1234'), and 'Completed' pill badge
///   2. Customer ('Ahmed Khan')
///   3. Phone Number ('+966 50 123 4567')
///   4. Service Location ('Al Malaz, Riyadh Saudi Arabia')
///   5. Service Date ('Oct 5, 2026')
///   6. Service Duration ('42 minutes', '10:14 AM - 10:56 AM')
/// - "Back to Dashboard" Action Button
/// - Bottom Home Indicator (134x5)
class ProviderServiceCompletedScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String serviceTypeEn;
  final String serviceTypeAr;
  final String customerNameEn;
  final String customerNameAr;
  final String phoneNumber;
  final String serviceLocationEn;
  final String serviceLocationAr;
  final String serviceDateEn;
  final String serviceDateAr;
  final String serviceDurationEn;
  final String serviceDurationAr;
  final String serviceDurationRangeEn;
  final String serviceDurationRangeAr;
  final String vehicleModelEn;
  final String vehicleModelAr;
  final String plateNumber;
  final String price;
  final double rating;
  final String feedbackEn;
  final String feedbackAr;

  const ProviderServiceCompletedScreen({
    super.key,
    this.requestId = 'REQ-1042',
    this.serviceTypeEn = 'Battery Jump Start',
    this.serviceTypeAr = 'اشتراك بطارية',
    this.customerNameEn = 'Ahmed Khan',
    this.customerNameAr = 'أحمد خان',
    this.phoneNumber = '+966 50 123 4567',
    this.serviceLocationEn = 'Al Malaz, Riyadh Saudi Arabia',
    this.serviceLocationAr = 'الملز، الرياض المملكة العربية السعودية',
    this.serviceDateEn = 'Oct 5, 2026',
    this.serviceDateAr = '٥ أكتوبر ٢٠٢٦',
    this.serviceDurationEn = '42 minutes',
    this.serviceDurationAr = '٤٢ دقيقة',
    this.serviceDurationRangeEn = '10:14 AM - 10:56 AM',
    this.serviceDurationRangeAr = '١٠:١٤ ص - ١٠:٥٦ ص',
    this.vehicleModelEn = 'Toyota Corolla',
    this.vehicleModelAr = 'تويوتا كورولا',
    this.plateNumber = 'KSA 1234',
    this.price = 'SAR 150',
    this.rating = 4.8,
    this.feedbackEn =
        '“Excellent service! The technician arrived quickly and started the car within minutes. Very professional and helpful. Highly recommended!”',
    this.feedbackAr =
        '“خدمة ممتازة! وصل الفني بسرعة وقام بتشغيل السيارة في غضون دقائق. محترف ومتعاون للغاية. أنصح به بشدة!”',
  });

  static const double designWidth = 390.0;
  static const double designHeight = 908.0;

  @override
  ConsumerState<ProviderServiceCompletedScreen> createState() =>
      _ProviderServiceCompletedScreenState();
}

class _ProviderServiceCompletedScreenState
    extends ConsumerState<ProviderServiceCompletedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;
    final String serviceType =
        isArabic ? widget.serviceTypeAr : widget.serviceTypeEn;
    final String customerName =
        isArabic ? widget.customerNameAr : widget.customerNameEn;
    final String serviceLocation =
        isArabic ? widget.serviceLocationAr : widget.serviceLocationEn;
    final String serviceDate =
        isArabic ? widget.serviceDateAr : widget.serviceDateEn;
    final String serviceDuration =
        isArabic ? widget.serviceDurationAr : widget.serviceDurationEn;
    final String serviceDurationRange = isArabic
        ? widget.serviceDurationRangeAr
        : widget.serviceDurationRangeEn;
    final String customerVehicle =
        isArabic ? widget.vehicleModelAr : widget.vehicleModelEn;
    final String customerPlate = widget.plateNumber;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // background: #FFFFFF
      body: SafeArea(
        top: false,
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final double screenHeight = constraints.maxHeight;
            final bool isDesktopWeb = screenWidth >= 768.0;

            final double containerWidth =
                isDesktopWeb ? ProviderServiceCompletedScreen.designWidth : screenWidth;
            final double containerHeight =
                isDesktopWeb ? ProviderServiceCompletedScreen.designHeight : screenHeight;

            // Responsive vertical spacing:
            // Allows the content to adjust on mobile screens without scrolling.
            final bool isCompactMobile = !isDesktopWeb && screenHeight < 880.0;
            final double topPadding = isCompactMobile
                ? (screenHeight < 800.0 ? 76.0 : 84.0)
                : 112.0;
            final double sectionGap = isCompactMobile
                ? (screenHeight < 800.0 ? 10.0 : 12.0)
                : 16.0;
            final double bottomPadding = isCompactMobile ? 12.0 : 24.0;

            final Widget screenContent = Container(
              color: const Color(0xFFFFFFFF),
              child: Stack(
              children: [
                // 1. Scrollable Content
                Positioned.fill(
                  child: ScrollConfiguration(
                    behavior: const ProviderCardScrollBehavior(),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                        top: topPadding,
                        bottom: bottomPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 1.1 Celebration Widget Layout:
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 350.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: SizedBox(
                                    width: isCompactMobile ? 150.0 : 174.0,
                                    height: isCompactMobile ? 68.0 : 80.0,
                                    child: Center(
                                      child: CustomPaint(
                                        size: Size(
                                          isCompactMobile ? 150.0 : 174.0,
                                          isCompactMobile ? 68.0 : 80.0,
                                        ),
                                        painter: const _SuccessCelebrationPainter(),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: isCompactMobile ? 8.0 : 16.0),

                                // Title: "Service Completed!"
                                Text(
                                  isArabic ? 'تم اكتمال الخدمة!' : 'Service Completed!',
                                  textAlign: TextAlign.center,
                                  style: (isArabic
                                      ? GoogleFonts.cairo
                                      : GoogleFonts.inter)(
                                    fontSize: isCompactMobile ? 18.0 : 20.0,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF252527),
                                    height: 1.2,
                                    letterSpacing: 0.0,
                                  ),
                                ),

                                const SizedBox(height: 4.0),

                                // Subtitle: "Your request has been completed successfully"
                                Text(
                                  isArabic
                                      ? 'تم إكمال طلبك بنجاح'
                                      : 'Your request has been completed successfully',
                                  textAlign: TextAlign.center,
                                  style: (isArabic
                                      ? GoogleFonts.cairo
                                      : GoogleFonts.inter)(
                                    fontSize: isCompactMobile ? 12.5 : 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF616166),
                                    height: 1.3,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: sectionGap),

                          // 1.2 "Service Details" Heading
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 350.0),
                            alignment: isArabic
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Text(
                              isArabic ? 'تفاصيل الخدمة' : 'Service Details',
                              style: (isArabic
                                  ? GoogleFonts.cairo
                                  : GoogleFonts.inter)(
                                fontSize: isCompactMobile ? 15.0 : 16.0,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF252527),
                                letterSpacing: 0.0,
                              ),
                            ),
                          ),

                          SizedBox(height: isCompactMobile ? 6.0 : 8.0),

                          // 1.3 Service Details Card Layout (Figma branding specs):
                        // width: 350; height: 357; gap: 20px; border-radius: 12px; padding: 16px;
                        // box-shadow: 0px 1px 12px 0px #0000001A; background: #FFFFFF;
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(
                            maxWidth: 350.0,
                            minHeight: 357.0,
                          ),
                          height: 357.0,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A000000), // #0000001A
                                offset: Offset(0, 1),
                                blurRadius: 12.0,
                                spreadRadius: 0.0,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 1st row layout: width: 318; height: 54; gap: 12px; border-radius: 12px;
                              SizedBox(
                                width: double.infinity,
                                height: 54.0,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // img layout: width: 52; height: 52; border-radius: 12px;
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12.0),
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
                                          child: const Center(
                                            child: Icon(
                                              Icons.build_rounded,
                                              size: 26.0,
                                              color: Color(0xFF8B53FE),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12.0), // gap: 12px

                                    // content layout: width: 254; height: 54;
                                    Expanded(
                                      child: SizedBox(
                                        height: 54.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // 1st row branding: width: 254; height: 19; justify-content: space-between;
                                            SizedBox(
                                              width: 254.0,
                                              height: 19.0,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      serviceType,
                                                      style: (isArabic
                                                          ? GoogleFonts.cairo
                                                          : GoogleFonts.inter)(
                                                        fontSize: 13.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: const Color(
                                                            0xFF252527),
                                                        height: 1.0,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6.0),
                                                  Container(
                                                    height: 19.0,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8.0,
                                                    ),
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFFF3EEFF),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                    ),
                                                    child: Text(
                                                      isArabic
                                                          ? 'مكتمل'
                                                          : 'Completed',
                                                      style: (isArabic
                                                          ? GoogleFonts.cairo
                                                          : GoogleFonts.inter)(
                                                        fontSize: 10.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: const Color(
                                                            0xFF8B53FE),
                                                        height: 1.0,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // 2nd row content: Toyota Corolla; width: 254; height: 7; background: #252527;
                                            SizedBox(
                                              width: 254.0,
                                              child: Text(
                                                customerVehicle,
                                                style: (isArabic
                                                    ? GoogleFonts.cairo
                                                    : GoogleFonts.inter)(
                                                  fontSize: 11.0,
                                                  fontWeight:
                                                      FontWeight.w400,
                                                  color: const Color(
                                                      0xFF252527),
                                                  height: 1.0,
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ),

                                            // 3rd row layout: width: 64; height: 10; gap: 8px;
                                            SizedBox(
                                              height: 10.0,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height: 10.0,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 3.0,
                                                    ),
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2.5),
                                                      border: Border.all(
                                                        color: const Color(
                                                            0xFF8E8E93),
                                                        width: 0.8,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'KSA',
                                                      style:
                                                          GoogleFonts.inter(
                                                        fontSize: 6.5,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: const Color(
                                                            0xFF8E8E93),
                                                        height: 1.0,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8.0), // gap: 8px
                                                  Text(
                                                    customerPlate,
                                                    style: (isArabic
                                                        ? GoogleFonts.cairo
                                                        : GoogleFonts.inter)(
                                                      fontSize: 10.0,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: const Color(
                                                          0xFF616166),
                                                      height: 1.0,
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

                              // next content layout: width: 318; height: 251; gap: 16px;
                              SizedBox(
                                width: double.infinity,
                                height: 251.0,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // 1st row layout: width: 318; height: 36; gap: 12px;
                                    _buildDetailRow(
                                      icon: Icons.person_rounded,
                                      label: isArabic ? 'العميل' : 'Customer',
                                      value: customerName,
                                      isArabic: isArabic,
                                    ),

                                    // 2nd row layout: width: 318; height: 36; gap: 12px;
                                    _buildDetailRow(
                                      icon: Icons.phone_rounded,
                                      label: isArabic
                                          ? 'رقم الهاتف'
                                          : 'Phone Number',
                                      value: widget.phoneNumber,
                                      isArabic: isArabic,
                                    ),

                                    // with equal gap remaining content will align:
                                    // Row 3: Service Location
                                    _buildDetailRow(
                                      icon: Icons.directions_car_rounded,
                                      label: isArabic
                                          ? 'موقع الخدمة'
                                          : 'Service Location',
                                      value: serviceLocation,
                                      isArabic: isArabic,
                                    ),

                                    // Row 4: Service Date
                                    _buildDetailRow(
                                      icon: Icons.location_on_rounded,
                                      label: isArabic
                                          ? 'تاريخ الخدمة'
                                          : 'Service Date',
                                      value: serviceDate,
                                      isArabic: isArabic,
                                    ),

                                    // Row 5: Service Duration
                                    _buildDetailRow(
                                      icon: Icons.access_time_filled_rounded,
                                      label: isArabic
                                          ? 'مدة الخدمة'
                                          : 'Service Duration',
                                      value: serviceDuration,
                                      subValue: serviceDurationRange,
                                      isArabic: isArabic,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: sectionGap),

                        // 1.4 Customer Feedback Card matching exact user screenshot
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 350.0),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: isCompactMobile ? 12.0 : 16.0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: const Color(0xFFF0F0F2),
                              width: 1.0,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                offset: Offset(0, 4),
                                blurRadius: 16.0,
                                spreadRadius: 0.0,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: Customer Feedback & ★ 4.8
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    isArabic
                                        ? 'تقييم العميل'
                                        : 'Customer Feedback',
                                    style: (isArabic
                                        ? GoogleFonts.cairo
                                        : GoogleFonts.inter)(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF252527),
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 16.0,
                                        color: Color(0xFF8B53FE),
                                      ),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        '${widget.rating}',
                                        style: GoogleFonts.inter(
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF252527),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: isCompactMobile ? 8.0 : 12.0),

                              // Lavender Feedback Message Container
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.0,
                                  vertical: isCompactMobile ? 9.0 : 12.0,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3EEFF),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  isArabic
                                      ? widget.feedbackAr
                                      : widget.feedbackEn,
                                  style: (isArabic
                                      ? GoogleFonts.cairo
                                      : GoogleFonts.inter)(
                                    fontSize: isCompactMobile ? 11.5 : 12.0,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF252527),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: sectionGap),

                        // 1.5 Primary Action Button: "View Requests / History ->"
                        GestureDetector(
                          key: const Key('service_completed_history_button'),
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProviderRequestsScreen(
                                  isHistoryMode: true,
                                  initialFilterIndex: 0,
                                ),
                              ),
                            );
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 350.0),
                            height: isCompactMobile ? 48.0 : 52.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F2F5),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  isArabic
                                      ? 'عرض الطلبات / السجل'
                                      : 'View Requests / History',
                                  style: (isArabic
                                      ? GoogleFonts.cairo
                                      : GoogleFonts.inter)(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF252527),
                                    height: 22.0 / 14.0,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Icon(
                                  isArabic
                                      ? Icons.arrow_back_rounded
                                      : Icons.arrow_forward_rounded,
                                  size: 18.0,
                                  color: const Color(0xFF252527),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: isCompactMobile ? 10.0 : 16.0),

                        // 1.5 Bottom Home Indicator Bar (134x5)
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

                // 2. Header Chevron Button matching exact Figma specifications:
                // width: 36; height: 36; angle: 0 deg; opacity: 1; top: 56px; left: 20px;
                // border-width: 1px; background: #FFFFFF; border: 1px solid #252527;
                // < styling: width: 6; height: 13; angle: 0 deg; opacity: 1; top: 68px; left: 35px;
                Positioned(
                  top: 56.0,
                  left: isArabic ? null : 20.0,
                  right: isArabic ? 20.0 : null,
                  child: GestureDetector(
                    key: const Key('service_completed_back_button'),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).maybePop();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF252527),
                          width: 1.0,
                        ),
                      ),
                      child: const Center(
                        child: CustomPaint(
                          size: Size(6.0, 13.0),
                          painter: _HeaderChevronPainter(
                            color: Color(0xFF252527),
                          ),
                        ),
                      ),
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
              color: const Color(0xFFFFFFFF), // pure white background
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Container(
                  width: ProviderServiceCompletedScreen.designWidth,
                  height: ProviderServiceCompletedScreen.designHeight,
                  margin: const EdgeInsets.symmetric(vertical: 24.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(44.0),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 32.0,
                        spreadRadius: 2.0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(42.0),
                    child: Container(
                      color: const Color(0xFFFFFFFF),
                      child: screenContent,
                    ),
                  ),
                ),
              ),
            );
          }

          return Container(
            color: const Color(0xFFFFFFFF),
            alignment: Alignment.center,
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

  /// Helper to build each detail row:
  /// width: 318; height: 36; gap: 12px;
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    String? subValue,
    required bool isArabic,
  }) {
    return SizedBox(
      height: subValue != null ? null : 36.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Squircle Icon Container matching exact 36px row height
          Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F2F5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 18.0,
                color: const Color(0xFF252527),
              ),
            ),
          ),
          const SizedBox(width: 12.0), // gap: 12px

          // Text Column (Label, Value, and optional subValue)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8E8E93),
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 1.0),
                Text(
                  value,
                  style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF252527),
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subValue != null) ...[
                  const SizedBox(height: 1.0),
                  Text(
                    subValue,
                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8E8E93),
                      height: 1.15,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Back Chevron Painter matching exact specs:
/// width: 6; height: 13; border: 1px solid #252527;
class _HeaderChevronPainter extends CustomPainter {
  final Color color;

  const _HeaderChevronPainter({
    this.color = const Color(0xFF252527),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final path = Path();
    path.moveTo(size.width - 0.5, 0.5);
    path.lineTo(0.5, size.height / 2.0);
    path.lineTo(size.width - 0.5, size.height - 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Success Celebration Painter matching exact design:
/// - Concentric purple halos
/// - Solid brand purple checkmark circle with drop shadow and crisp white checkmark
/// - Radiant colored rays: Yellow at top, Mint Green at angles, Purple at sides
class _SuccessCelebrationPainter extends CustomPainter {
  const _SuccessCelebrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2.0;
    final double cy = size.height / 2.0;

    // 1. Outer soft lavender halo
    final outerHaloPaint = Paint()
      ..color = const Color(0xFF8B53FE).withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 38.0, outerHaloPaint);

    // 2. Inner soft lavender halo
    final innerHaloPaint = Paint()
      ..color = const Color(0xFF8B53FE).withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 30.0, innerHaloPaint);

    // 3. Drop shadow for main circle
    final shadowPaint = Paint()
      ..color = const Color(0x338B53FE)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy + 2.5), 23.0, shadowPaint);

    // 4. Main solid brand purple circle (#8B53FE)
    final circlePaint = Paint()
      ..color = const Color(0xFF8B53FE)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), 23.0, circlePaint);

    // 5. White Checkmark (crisp and centered)
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final checkPath = Path();
    checkPath.moveTo(cx - 7.5, cy - 0.5);
    checkPath.lineTo(cx - 2.0, cy + 5.5);
    checkPath.lineTo(cx + 8.5, cy - 5.5);
    canvas.drawPath(checkPath, checkPaint);

    // Helper to draw pill/ray lines
    void drawRay(
      double angleDeg,
      double innerR,
      double outerR,
      Color color, [
      double width = 2.6,
    ]) {
      final rad = angleDeg * math.pi / 180.0;
      final rayPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;
      canvas.drawLine(
        Offset(cx + innerR * math.cos(rad), cy + innerR * math.sin(rad)),
        Offset(cx + outerR * math.cos(rad), cy + outerR * math.sin(rad)),
        rayPaint,
      );
    }

    // Radiating rays matching the screenshot:
    // Top-left Yellow rays
    drawRay(250, 40.0, 49.0, const Color(0xFFFFC000), 2.8);
    // Top-right Yellow rays
    drawRay(290, 40.0, 49.0, const Color(0xFFFFC000), 2.8);

    // Mint Green rays (top-left, upper-right, lower-right)
    drawRay(215, 41.0, 50.0, const Color(0xFF55E6A5), 2.8);
    drawRay(325, 41.0, 50.0, const Color(0xFF55E6A5), 2.8);
    drawRay(35, 40.0, 48.0, const Color(0xFF55E6A5), 2.6);
    drawRay(145, 40.0, 48.0, const Color(0xFF55E6A5), 2.6);

    // Brand Purple rays (sides)
    drawRay(180, 43.0, 52.0, const Color(0xFF8B53FE), 2.8);
    drawRay(0, 43.0, 52.0, const Color(0xFF8B53FE), 2.8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
