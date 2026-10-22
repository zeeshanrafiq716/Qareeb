import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_locale.dart';

/// Screen displayed automatically after provider arrives.
/// Contains the standard branding header and the success status layout,
/// ready for subsequent manual branding additions.
class ServiceInProgressScreen extends ConsumerStatefulWidget {
  final String serviceCategory;
  final String providerName;
  final String headerHeading;

  const ServiceInProgressScreen({
    super.key,
    this.serviceCategory = 'Pickup & Delivery',
    this.providerName = 'Ahmad Transport',
    this.headerHeading = 'Service Complete',
  });

  @override
  ConsumerState<ServiceInProgressScreen> createState() =>
      _ServiceInProgressScreenState();
}

class _ServiceInProgressScreenState
    extends ConsumerState<ServiceInProgressScreen>
    with SingleTickerProviderStateMixin {
  AppTranslations get tr => ref.read(translationsProvider);
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  int _userRating = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
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
    ref.watch(translationsProvider);
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
            final mediaQuery = MediaQuery.of(context);
            final screenWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : mediaQuery.size.width;
            final screenHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : mediaQuery.size.height;

            // Desktop framing simulates mobile view (390 x 844)
            final isDesktopWeb = screenWidth > 600;
            final containerWidth = isDesktopWeb ? 390.0 : screenWidth;
            final containerHeight = isDesktopWeb
                ? math.min(844.0, (screenHeight - 32.0).clamp(520.0, 844.0))
                : screenHeight;

            final double cardWidth = containerWidth >= 390
                ? 350.0
                : (containerWidth - 32.0).clamp(280.0, 350.0);
            final double horizontalPadding = math.max(16.0, (containerWidth - cardWidth) / 2.0);

            final Widget screenContent = ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                scrollbars: false,
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.stylus,
                },
              ),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Center(
                  child: SizedBox(
                    width: cardWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 56.0), // top padding to header

                        // 1. Header with given branding:
                        // width: 350; height: 36; top: 56px; left: 20px; gap: 16px; angle: 0 deg; opacity: 1;
                        // follow previous screens header , header heading will be service complete
                        SizedBox(
                          width: cardWidth,
                          height: 36.0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Circular Back Button matching previous screens
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                key: const Key('service_complete_back_button'),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.of(context).maybePop();
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 36.0,
                                  height: 36.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFFFFFF),
                                    border: Border.all(
                                      color: const Color(0xFF566663),
                                      width: 1.0,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x14000000), // #00000014
                                        blurRadius: 12.0,
                                        offset: Offset(0, -2),
                                        spreadRadius: 0.0,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Transform.scale(
                                      scaleX: tr.isArabic ? -1.0 : 1.0,
                                      child: const CustomPaint(
                                        size: Size(6.0, 13.0),
                                        painter: _BackChevronPainter(
                                          color: Color(0xFF566663),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16.0), // gap: 16px

                            // Header Heading: Service Complete
                            Expanded(
                              child: Text(
                                widget.headerHeading == 'Service Complete'
                                    ? tr.serviceCompleteHeader
                                    : widget.headerHeading,
                                style: tr.font(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1C2926),
                                  height: 22.0 / 16.0,
                                  letterSpacing: 0.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24.0), // gap: 24px

                        // 2. Success illustration and text
                          // img layout branding:
                          // width: 174; height: 80; angle: 0 deg; opacity: 1;
                          // tick branding:
                          // width: 62.60871124267578; height: 62.60871124267578; top: 9px; left: 144px;
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: const SizedBox(
                              width: 174.0,
                              height: 80.0,
                              child: Center(
                                child: CustomPaint(
                                  size: Size(174.0, 80.0),
                                  painter: _SuccessTickPainter(),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20.0), // gap: 20px;

                          // text layout:
                          // width: 350; gap: 12px; angle: 0 deg; opacity: 1;
                          SizedBox(
                            width: cardWidth,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // content: Service Completed!
                                // width: 350; height: 15; font-family: Inter; font-weight: 600; font-size: 20px;
                                // leading-trim: CAP_HEIGHT; line-height: 24px; color: #1C2926; text-align: center;
                                Text(
                                  tr.serviceCompleted,
                                  textAlign: TextAlign.center,
                                  style: tr.font(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1C2926),
                                    height: 24.0 / 20.0,
                                    letterSpacing: 0.0,
                                  ),
                                ),

                                const SizedBox(height: 12.0), // gap: 12px;

                                // content: Your request has been completed successfully
                                Text(
                                  tr.requestCompletedSuccess,
                                  textAlign: TextAlign.center,
                                  style: tr.font(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF566663),
                                    height: 1.35,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 26.0), // gap to cards
                          // 1st Card: Provider Profile Card
                          // width: 350; height: 84; gap: 16px; border-radius: 12px; padding: 16px; background: #F2F5F4;
                          Container(
                            width: cardWidth,
                            constraints: const BoxConstraints(minHeight: 84.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F5F4),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // left-side img layout: width: 52; height: 52;
                                Container(
                                  width: 52.0,
                                  height: 52.0,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFFFAAA6),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.asset(
                                    'assets/images/driver_avatar.png',
                                    width: 52.0,
                                    height: 52.0,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Image.network(
                                      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120&auto=format&fit=crop&q=80',
                                      width: 52.0,
                                      height: 52.0,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: const Color(0xFFFFAAA6),
                                        child: const Center(
                                          child: Icon(
                                            Icons.person,
                                            size: 28.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16.0), // gap: 16px;

                                // right side content branding: width: 250; height: 45; gap: 10px;
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 1st row text branding: content: Ahmad Transport
                                      Text(
                                        tr.formatProviderName(widget.providerName),
                                        style: tr.font(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1C2926),
                                          height: 1.2,
                                          letterSpacing: 0.0,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3.0),

                                      // content: Pickup & Delivery
                                      Text(
                                        tr.categoryName(widget.serviceCategory),
                                        style: tr.font(
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF566663),
                                          height: 1.2,
                                          letterSpacing: 0.0,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5.0),

                                      // reviews branding: width: 96; height: 10; gap: 8px;
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // star branding in brand purple (#8B53FE)
                                          const Icon(
                                            Icons.star_rounded,
                                            size: 13.0,
                                            color: Color(0xFF8B53FE),
                                          ),
                                          const SizedBox(width: 3.0),

                                          // content: 4.9 (120 reviews)
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: '4.9 ',
                                                  style: tr.font(
                                                    fontSize: 10.0,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color(0xFF1C2926),
                                                    height: 1.1,
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: tr.reviewsCount(120),
                                                  style: tr.font(
                                                    fontSize: 10.0,
                                                    fontWeight: FontWeight.w400,
                                                    color: const Color(0xFF566663),
                                                    height: 1.1,
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            textHeightBehavior:
                                                const TextHeightBehavior(
                                              applyHeightToFirstAscent: false,
                                              applyHeightToLastDescent: false,
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

                          const SizedBox(height: 12.0), // gap: 12px;

                          // 2nd card branding: Vehicle Details Card
                          // width: 350; height: 72; gap: 12px; angle: 0 deg; opacity: 1;
                          // border-radius: 12px; padding: 16px; background: #F2F5F4;
                          Container(
                            width: cardWidth,
                            constraints: const BoxConstraints(minHeight: 72.0),
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F5F4),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // left side img branding: width: 60; height: 40;
                                SizedBox(
                                  width: 60.0,
                                  height: 40.0,
                                  child: Image.asset(
                                    'assets/images/pickup.png',
                                    width: 60.0,
                                    height: 40.0,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                      Icons.directions_car_filled_rounded,
                                      size: 32.0,
                                      color: Color(0xFF1C2926),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16.0), // gap: 16px padding between image and text

                                // content layout
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // content: Toyota Hilux
                                      Text(
                                        tr.formatVehicleName('Toyota Hilux'),
                                        style: tr.font(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1C2926),
                                          height: 22.0 / 14.0,
                                          letterSpacing: 0.0,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3.0), // padding between title and subtitle

                                      // content: ABC-123
                                      Text(
                                        'ABC-123',
                                        style: tr.font(
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF566663),
                                          height: 1.2,
                                          letterSpacing: 0.0,
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

                          const SizedBox(height: 12.0), // gap: 12px;

                          // 3rd card branding: Completed Date & Time Card
                          // width: 350; height: 64; gap: 12px; angle: 0 deg; opacity: 1;
                          // border-radius: 12px; padding: 16px; background: #F2F5F4;
                          Container(
                            width: cardWidth,
                            constraints: const BoxConstraints(minHeight: 64.0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F5F4),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // calendar icon branding: width: 32; height: 32; border-radius: 8px; background: #E2F0E6;
                                Container(
                                  width: 32.0,
                                  height: 32.0,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0EAFE),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.calendar_today_rounded,
                                      size: 16.0,
                                      color: Color(0xFF8B53FE),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12.0), // gap: 12px;

                                // content branding: width: 147; height: 29; gap: 12px;
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // content: Completed on
                                    Text(
                                      tr.completedOn,
                                      style: tr.font(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF566663),
                                        height: 1.2,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                    const SizedBox(height: 2.0),

                                    // content: 12 Sep 2026, 9:58 PM
                                    Text(
                                      tr.sampleCompletedDateTime,
                                      style: tr.font(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF1C2926),
                                        height: 1.2,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12.0), // gap: 12px;

                          // 4th card branding: "Thank you!" Card
                          // width: 350; height: 64; gap: 12px; angle: 0 deg; opacity: 1;
                          // border-radius: 12px; padding: 16px; background: #EBFFF4;
                          Container(
                            width: cardWidth,
                            constraints: const BoxConstraints(minHeight: 64.0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0EAFE),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // icon branding: width: 32; height: 32; border-radius: 60px; background: #D7F5E5;
                                Container(
                                  width: 32.0,
                                  height: 32.0,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEAE0FE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.handshake_rounded,
                                      size: 18.0,
                                      color: Color(0xFF8B53FE),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12.0), // gap: 12px;

                                // content branding: width: 274; height: 31; gap: 12px;
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // content: Thank you!
                                      Text(
                                        tr.thankYou,
                                        style: tr.font(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF8B53FE),
                                          height: 1.2,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                      const SizedBox(height: 2.0),

                                      // content: We hope you had a great experience.
                                      Text(
                                        tr.hopeGreatExperience,
                                        style: tr.font(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF8B53FE),
                                          height: 14.0 / 12.0,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12.0), // gap: 12px;

                          // 5th card branding: Rating Card
                          // width: 350; height: 79; gap: 10px; angle: 0 deg; opacity: 1;
                          // border-radius: 12px; padding: 16px; background: #F2F5F4;
                          Container(
                            width: cardWidth,
                            constraints: const BoxConstraints(minHeight: 79.0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 14.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F5F4),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // content: Rate your experience (optional)
                                // width: 324.4; height: 7; font-family: Inter; font-weight: 500; font-size: 10px;
                                // text-align: center;
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: tr.rateYourExperience,
                                        style: tr.font(
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1C2926),
                                          height: 1.2,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                      TextSpan(
                                        text: tr.optional,
                                        style: tr.font(
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF566663),
                                          height: 1.2,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10.0), // gap: 10px;

                                // stars branding: width: 152; height: 24; justify-content: space-between;
                                SizedBox(
                                  width: 152.0,
                                  height: 24.0,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(5, (index) {
                                      final starNum = index + 1;
                                      final isFilled = _userRating >= starNum;
                                      return MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          key: Key('rating_star_$starNum'),
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            setState(() {
                                              if (_userRating == starNum) {
                                                _userRating = 0;
                                              } else {
                                                _userRating = starNum;
                                              }
                                            });
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: SizedBox(
                                            width: 24.0,
                                            height: 24.0,
                                            child: CustomPaint(
                                              size: const Size(24.0, 24.0),
                                              painter: _RatingStarPainter(
                                                isFilled: isFilled,
                                                fillColor:
                                                    const Color(0xFF8B53FE),
                                                strokeColor:
                                                    const Color(0xFF566663),
                                                strokeWidth: 0.8,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12.0), // gap: 12px;

                          // 6. Action Button: "Done"
                          // width: 350; height: 52; border-radius: 12px; background: #1D8070;
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              key: const Key('service_completed_done_button'),
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: cardWidth,
                                height: 52.0,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B53FE),
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1F8B53FE),
                                      blurRadius: 10.0,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    tr.done,
                                    style: tr.font(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      height: 22.0 / 14.0,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12.0), // gap: 12px;

                          // 7. Secondary Action: "View Details"
                          // width: 350; text-align: center; color: #1D8070;
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              key: const Key('service_completed_view_details_button'),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      tr.tripDetails(tr.formatProviderName(widget.providerName), tr.categoryName(widget.serviceCategory)),
                                      style: tr.font(
                                        color: Colors.white,
                                        fontSize: 13.0,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFF8B53FE),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                );
                              },
                              behavior: HitTestBehavior.opaque,
                              child: SizedBox(
                                width: cardWidth,
                                height: 26.0,
                                child: Center(
                                  child: Text(
                                    tr.viewDetails,
                                    textAlign: TextAlign.center,
                                    style: tr.font(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF8B53FE),
                                      height: 22.0 / 14.0,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16.0), // gap: 16px;

                          // 8. Bottom Indicator Bar: width: 134; height: 4; border-radius: 100px; background: #1C2926;
                          SizedBox(
                            width: cardWidth,
                            height: 24.0,
                            child: Center(
                              child: Container(
                                key: const Key('bottom_bar_indicator'),
                                width: 134.0,
                                height: 4.0,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1C2926),
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24.0), // bottom safe padding
                      ],
                    ),
                  ),
                ),
              ),
            );

            if (isDesktopWeb) {
              return Container(
                width: containerWidth,
                height: containerHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 28.0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: screenContent,
              );
            }

            return screenContent;
          },
        ),
      ),
    );
  }
}

/// Back Chevron Painter matching branding specs (width: 6, height: 13, stroke: 1.0)
class _BackChevronPainter extends CustomPainter {
  final Color color;
  const _BackChevronPainter({this.color = const Color(0xFF566663)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width - 0.5, 0.5);
    path.lineTo(0.5, size.height / 2.0);
    path.lineTo(size.width - 0.5, size.height - 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vector Painter fallback replicating the exact success tick illustration:
/// Brand purple halos, deep purple checkmark circle, white checkmark, radiating sparks
class _SuccessTickPainter extends CustomPainter {
  const _SuccessTickPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2.0;
    final double cy = size.height / 2.0;

    // 1. Concentric Soft Purple Halos (matching screenshot)
    final haloPaintOuter = Paint()
      ..color = const Color(0xFFF0EAFE).withValues(alpha: 0.70)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 38.0, haloPaintOuter);

    final haloPaintInner = Paint()
      ..color = const Color(0xFFE2D5FE).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 30.0, haloPaintInner);

    // 2. Main Purple Circle with subtle shadow
    final shadowPaint = Paint()
      ..color = const Color(0x338B53FE)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy + 2.0), 24.0, shadowPaint);

    final circlePaint = Paint()
      ..color = const Color(0xFF8B53FE)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), 24.0, circlePaint);

    // 3. Crisp White Checkmark
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final checkPath = Path();
    checkPath.moveTo(cx - 8.0, cy - 0.5);
    checkPath.lineTo(cx - 2.5, cy + 5.5);
    checkPath.lineTo(cx + 9.0, cy - 6.0);
    canvas.drawPath(checkPath, checkPaint);

    // 4. Radiating Sparks (matching screenshot)
    void drawRay(double angleDeg, double innerR, double outerR, Color color, [double width = 2.4]) {
      final rad = angleDeg * math.pi / 180.0;
      final rayPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx + innerR * math.cos(rad), cy + innerR * math.sin(rad)),
        Offset(cx + outerR * math.cos(rad), cy + outerR * math.sin(rad)),
        rayPaint,
      );
    }

    // Lavender Accent Sparks
    drawRay(240, 42.0, 52.0, const Color(0xFFC4A8FE), 2.6);
    drawRay(300, 42.0, 52.0, const Color(0xFFC4A8FE), 2.6);

    // Light Vibrant Purple Sparks
    drawRay(205, 42.0, 51.0, const Color(0xFFA67AFE), 2.4);
    drawRay(335, 42.0, 51.0, const Color(0xFFA67AFE), 2.4);
    drawRay(150, 44.0, 53.0, const Color(0xFFA67AFE), 2.2);
    drawRay(30, 44.0, 53.0, const Color(0xFFA67AFE), 2.2);

    // Deep Brand Purple Sparks
    drawRay(175, 45.0, 54.0, const Color(0xFF8B53FE), 2.4);
    drawRay(5, 45.0, 54.0, const Color(0xFF8B53FE), 2.4);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Star painter matching branding specs (width: 24, height: 24, border: 0.8px solid #566663)
class _RatingStarPainter extends CustomPainter {
  final bool isFilled;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  const _RatingStarPainter({
    required this.isFilled,
    this.fillColor = const Color(0xFF8B53FE),
    this.strokeColor = const Color(0xFF566663),
    this.strokeWidth = 0.8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2.0;
    final double cy = size.height / 2.0;
    final double outerR = size.width * 0.44;
    final double innerR = outerR * 0.44;

    final path = Path();
    for (int i = 0; i < 10; i++) {
      final double r = i.isEven ? outerR : innerR;
      final double angle = -math.pi / 2.0 + (i * math.pi / 5.0);
      final double x = cx + r * math.cos(angle);
      final double y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    if (isFilled) {
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      canvas.drawPath(path, fillPaint);

      final borderPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;
      canvas.drawPath(path, borderPaint);
    } else {
      final strokePaint = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RatingStarPainter oldDelegate) =>
      isFilled != oldDelegate.isFilled ||
      fillColor != oldDelegate.fillColor ||
      strokeColor != oldDelegate.strokeColor;
}

/// Alias matching the title branding
typedef ServiceCompletedScreen = ServiceInProgressScreen;
