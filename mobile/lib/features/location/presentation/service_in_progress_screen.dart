import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
                child: SizedBox(
                  width: containerWidth,
                  height: math.max(containerHeight, 860.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                  // 1. Header with given branding:
                  // width: 350; height: 36; top: 56px; left: 20px; gap: 16px; angle: 0 deg; opacity: 1;
                  // follow previous screens header , header heading will be service complete
                  Positioned(
                    top: 56.0,
                    left: containerWidth >= 390
                        ? 20.0
                        : ((containerWidth - 350.0) / 2).clamp(10.0, 20.0),
                    width: containerWidth >= 390
                        ? 350.0
                        : (containerWidth - 40.0).clamp(280.0, 350.0),
                    height: 36.0,
                    child: Opacity(
                      opacity: 1.0,
                      child: SizedBox(
                        width: containerWidth >= 390
                            ? 350.0
                            : (containerWidth - 40.0).clamp(280.0, 350.0),
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
                                  child: const Center(
                                    child: CustomPaint(
                                      size: Size(6.0, 13.0),
                                      painter: _BackChevronPainter(
                                        color: Color(0xFF566663),
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
                                widget.headerHeading,
                                textHeightBehavior: const TextHeightBehavior(
                                  applyHeightToFirstAscent: false,
                                  applyHeightToLastDescent: false,
                                ),
                                style: GoogleFonts.inter(
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
                    ),
                  ),

                  // 2. Next layout branding:
                  // width: 350; minHeight: 160; top: 116px; left: 20px; gap: 20px; angle: 0 deg; opacity: 1;
                  Positioned(
                    top: 116.0,
                    left: containerWidth >= 390
                        ? 20.0
                        : ((containerWidth - 350.0) / 2).clamp(10.0, 20.0),
                    width: containerWidth >= 390
                        ? 350.0
                        : (containerWidth - 40.0).clamp(280.0, 350.0),
                    child: SizedBox(
                      width: containerWidth >= 390
                          ? 350.0
                          : (containerWidth - 40.0).clamp(280.0, 350.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // img layout branding:
                          // width: 174; height: 80; angle: 0 deg; opacity: 1;
                          // tick branding:
                          // width: 62.60871124267578; height: 62.60871124267578; top: 9px; left: 144px;
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: SizedBox(
                              width: 174.0,
                              height: 80.0,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/service_success_check.png',
                                    width: 174.0,
                                    height: 80.0,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const CustomPaint(
                                      size: Size(174.0, 80.0),
                                      painter: _SuccessTickPainter(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20.0), // gap: 20px;

                          // text layout:
                          // width: 350; gap: 12px; angle: 0 deg; opacity: 1;
                          SizedBox(
                            width: containerWidth >= 390
                                ? 350.0
                                : (containerWidth - 40.0).clamp(280.0, 350.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // content: Service Completed!
                                // width: 350; height: 15; font-family: Inter; font-weight: 600; font-size: 20px;
                                // leading-trim: CAP_HEIGHT; line-height: 24px; color: #1C2926; text-align: center;
                                Text(
                                  'Service Completed!',
                                  textAlign: TextAlign.center,
                                  textHeightBehavior: const TextHeightBehavior(
                                    applyHeightToFirstAscent: false,
                                    applyHeightToLastDescent: false,
                                  ),
                                  style: GoogleFonts.inter(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1C2926),
                                    height: 24.0 / 20.0,
                                    letterSpacing: 0.0,
                                  ),
                                ),

                                const SizedBox(height: 12.0), // gap: 12px;

                                // content: Your request has been completed successfully
                                // width: 350; height: 27; font-family: Inter; font-weight: 400; font-size: 14px;
                                // line-height: 100%; color: #566663; text-align: center;
                                Text(
                                  'Your request has been completed\nsuccessfully',
                                  textAlign: TextAlign.center,
                                  textHeightBehavior: const TextHeightBehavior(
                                    applyHeightToFirstAscent: false,
                                    applyHeightToLastDescent: false,
                                  ),
                                  style: GoogleFonts.inter(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF566663),
                                    height: 1.25,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Next widget layout:
                  // width: 350; minHeight: 411; top: 296px; left: 20px; gap: 12px; angle: 0 deg; opacity: 1;
                  Positioned(
                    top: 296.0,
                    left: containerWidth >= 390
                        ? 20.0
                        : ((containerWidth - 350.0) / 2).clamp(10.0, 20.0),
                    width: containerWidth >= 390
                        ? 350.0
                        : (containerWidth - 40.0).clamp(280.0, 350.0),
                    child: SizedBox(
                      width: containerWidth >= 390
                          ? 350.0
                          : (containerWidth - 40.0).clamp(280.0, 350.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1st Card: Provider Profile Card
                          // width: 350; height: 84; gap: 16px; border-radius: 12px; padding: 16px; background: #F2F5F4;
                          Container(
                            width: containerWidth >= 390
                                ? 350.0
                                : (containerWidth - 40.0).clamp(280.0, 350.0),
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
                                      // width: 117; height: 10; font-family: Inter; font-weight: 500; font-size: 14px;
                                      // line-height: 22px; color: #1C2926;
                                      Text(
                                        widget.providerName,
                                        textHeightBehavior:
                                            const TextHeightBehavior(
                                          applyHeightToFirstAscent: false,
                                          applyHeightToLastDescent: false,
                                        ),
                                        style: GoogleFonts.inter(
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
                                      // width: 83; height: 7; font-family: Inter; font-weight: 400; font-size: 10px;
                                      // line-height: 22px; color: #566663;
                                      Text(
                                        widget.serviceCategory,
                                        textHeightBehavior:
                                            const TextHeightBehavior(
                                          applyHeightToFirstAscent: false,
                                          applyHeightToLastDescent: false,
                                        ),
                                        style: GoogleFonts.inter(
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
                                          // star branding: width: 10; height: 10; background: #07AF2C;
                                          const Icon(
                                            Icons.star_rounded,
                                            size: 13.0,
                                            color: Color(0xFF07AF2C),
                                          ),
                                          const SizedBox(width: 3.0),

                                          // content: 4.9 (120 reviews)
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: '4.9 ',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 10.0,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color(0xFF1C2926),
                                                    height: 1.1,
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '(120 reviews)',
                                                  style: GoogleFonts.inter(
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
                            width: containerWidth >= 390
                                ? 350.0
                                : (containerWidth - 40.0).clamp(280.0, 350.0),
                            constraints: const BoxConstraints(minHeight: 72.0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 16.0,
                            ),
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
                                const SizedBox(width: 12.0), // gap: 12px;

                                // content branding: width: 83; height: 29; gap: 12px;
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // content: Toyota Hilux
                                    // width: 83; height: 10; font-family: Inter; font-weight: 500; font-size: 14px;
                                    // line-height: 22px; color: #1C2926;
                                    Text(
                                      'Toyota Hilux',
                                      textHeightBehavior:
                                          const TextHeightBehavior(
                                        applyHeightToFirstAscent: false,
                                        applyHeightToLastDescent: false,
                                      ),
                                      style: GoogleFonts.inter(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF1C2926),
                                        height: 1.2,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                    const SizedBox(height: 3.0),

                                    // content: ABC-123
                                    // width: 43; height: 7; font-family: Inter; font-weight: 400; font-size: 10px;
                                    // line-height: 22px; color: #566663;
                                    Text(
                                      'ABC-123',
                                      textHeightBehavior:
                                          const TextHeightBehavior(
                                        applyHeightToFirstAscent: false,
                                        applyHeightToLastDescent: false,
                                      ),
                                      style: GoogleFonts.inter(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF566663),
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

                          // 3rd card branding: Completed Date & Time Card
                          // width: 350; height: 64; gap: 12px; angle: 0 deg; opacity: 1;
                          // border-radius: 12px; padding: 16px; background: #F2F5F4;
                          Container(
                            width: containerWidth >= 390
                                ? 350.0
                                : (containerWidth - 40.0).clamp(280.0, 350.0),
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
                                    color: const Color(0xFFE2F0E6),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.calendar_today_rounded,
                                      size: 16.0,
                                      color: Color(0xFF1D8070),
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
                                    // width: 147; height: 7; font-family: Inter; font-weight: 400; font-size: 10px;
                                    // line-height: 22px; color: #566663;
                                    Text(
                                      'Completed on',
                                      textHeightBehavior:
                                          const TextHeightBehavior(
                                        applyHeightToFirstAscent: false,
                                        applyHeightToLastDescent: false,
                                      ),
                                      style: GoogleFonts.inter(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF566663),
                                        height: 1.2,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                    const SizedBox(height: 2.0),

                                    // content: 12 Sep 2026, 9:58 PM
                                    // width: 147; height: 10; font-family: Inter; font-weight: 500; font-size: 14px;
                                    // line-height: 22px; color: #1C2926;
                                    Text(
                                      '12 Sep 2026, 9:58 PM',
                                      textHeightBehavior:
                                          const TextHeightBehavior(
                                        applyHeightToFirstAscent: false,
                                        applyHeightToLastDescent: false,
                                      ),
                                      style: GoogleFonts.inter(
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
                            width: containerWidth >= 390
                                ? 350.0
                                : (containerWidth - 40.0).clamp(280.0, 350.0),
                            constraints: const BoxConstraints(minHeight: 64.0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBFFF4),
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
                                    color: Color(0xFFD7F5E5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.handshake_rounded,
                                      size: 18.0,
                                      color: Color(0xFF1D8070),
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
                                      // width: 274; height: 10; font-family: Inter; font-weight: 500; font-size: 14px;
                                      // line-height: 22px; color: #1D8070;
                                      Text(
                                        'Thank you!',
                                        textHeightBehavior:
                                            const TextHeightBehavior(
                                          applyHeightToFirstAscent: false,
                                          applyHeightToLastDescent: false,
                                        ),
                                        style: GoogleFonts.inter(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1D8070),
                                          height: 1.2,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                      const SizedBox(height: 2.0),

                                      // content: We hope you had a great experience.
                                      // width: 274; height: 9; font-family: Inter; font-weight: 400; font-size: 12px;
                                      // line-height: 14px; color: #1D8070;
                                      Text(
                                        'We hope you had a great experience.',
                                        textHeightBehavior:
                                            const TextHeightBehavior(
                                          applyHeightToFirstAscent: false,
                                          applyHeightToLastDescent: false,
                                        ),
                                        style: GoogleFonts.inter(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF1D8070),
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
                            width: containerWidth >= 390
                                ? 350.0
                                : (containerWidth - 40.0).clamp(280.0, 350.0),
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
                                        text: 'Rate your experience ',
                                        style: GoogleFonts.inter(
                                          fontSize: 10.0,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1C2926),
                                          height: 1.2,
                                          letterSpacing: 0.0,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '(optional)',
                                        style: GoogleFonts.inter(
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
                                  textHeightBehavior:
                                      const TextHeightBehavior(
                                    applyHeightToFirstAscent: false,
                                    applyHeightToLastDescent: false,
                                  ),
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
                                                    const Color(0xFFF9BD15),
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

                          const SizedBox(height: 16.0), // gap: 16px;

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
                                width: containerWidth >= 390
                                    ? 350.0
                                    : (containerWidth - 40.0).clamp(280.0, 350.0),
                                height: 52.0,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1D8070),
                                  borderRadius: BorderRadius.circular(12.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1F1D8070),
                                      blurRadius: 10.0,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Done',
                                    textHeightBehavior: const TextHeightBehavior(
                                      applyHeightToFirstAscent: false,
                                      applyHeightToLastDescent: false,
                                    ),
                                    style: GoogleFonts.inter(
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
                                      'Trip details for ${widget.providerName} - ${widget.serviceCategory}',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 13.0,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFF1D8070),
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
                                width: containerWidth >= 390
                                    ? 350.0
                                    : (containerWidth - 40.0).clamp(280.0, 350.0),
                                height: 26.0,
                                child: Center(
                                  child: Text(
                                    'View Details',
                                    textAlign: TextAlign.center,
                                    textHeightBehavior: const TextHeightBehavior(
                                      applyHeightToFirstAscent: false,
                                      applyHeightToLastDescent: false,
                                    ),
                                    style: GoogleFonts.inter(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1D8070),
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
                            width: containerWidth >= 390
                                ? 350.0
                                : (containerWidth - 40.0).clamp(280.0, 350.0),
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

                          const SizedBox(height: 16.0), // bottom safe padding
                        ],
                      ),
                    ),
                  ),
                ],
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
/// Mint halos, dark teal checkmark circle, white checkmark, radiating sparks
class _SuccessTickPainter extends CustomPainter {
  const _SuccessTickPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2.0;
    final double cy = size.height / 2.0;

    // 1. Concentric Mint Halos
    final haloPaintOuter = Paint()
      ..color = const Color(0xFFE8F7F0).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 35.0, haloPaintOuter);

    final haloPaintInner = Paint()
      ..color = const Color(0xFFD6F2E4).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 28.0, haloPaintInner);

    // 2. Main Teal Circle (tick circle: ~62.6px bound)
    final circlePaint = Paint()
      ..color = const Color(0xFF1D8070)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(cx, cy), 22.0, circlePaint);

    // 3. White Checkmark
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final checkPath = Path();
    checkPath.moveTo(cx - 7.5, cy - 0.5);
    checkPath.lineTo(cx - 2.5, cy + 5.5);
    checkPath.lineTo(cx + 8.5, cy - 5.5);
    canvas.drawPath(checkPath, checkPaint);

    // 4. Radiating Sparks (dashes)
    void drawRay(double angleDeg, double innerR, double outerR, Color color) {
      final rad = angleDeg * math.pi / 180.0;
      final rayPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx + innerR * math.cos(rad), cy + innerR * math.sin(rad)),
        Offset(cx + outerR * math.cos(rad), cy + outerR * math.sin(rad)),
        rayPaint,
      );
    }

    // Yellow sparks
    drawRay(240, 38.0, 47.0, const Color(0xFFF9BD15));
    drawRay(300, 38.0, 47.0, const Color(0xFFF9BD15));

    // Mint sparks
    drawRay(205, 38.0, 46.0, const Color(0xFF7DE6B5));
    drawRay(335, 38.0, 46.0, const Color(0xFF7DE6B5));
    drawRay(150, 40.0, 48.0, const Color(0xFF7DE6B5));
    drawRay(30, 40.0, 48.0, const Color(0xFF7DE6B5));

    // Teal sparks
    drawRay(175, 42.0, 49.0, const Color(0xFF1D8070));
    drawRay(5, 42.0, 49.0, const Color(0xFF1D8070));
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
    this.fillColor = const Color(0xFFF9BD15),
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
