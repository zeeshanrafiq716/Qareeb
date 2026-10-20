import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'live_tracking_screen.dart';

/// Screen displayed when user clicks 'Send Request' in ProviderDetailScreen.
/// Implements the exact header and map layer of Pickup & Delivery screens as requested.
class SendRequestScreen extends ConsumerStatefulWidget {
  final String serviceCategory;
  final String providerName;
  final String distance;

  const SendRequestScreen({
    super.key,
    this.serviceCategory = 'Pickup & Delivery',
    this.providerName = 'Ahmad Transport',
    this.distance = '1.8 km',
  });

  @override
  ConsumerState<SendRequestScreen> createState() => _SendRequestScreenState();
}

class _SendRequestScreenState extends ConsumerState<SendRequestScreen> {
  Timer? _acceptanceTimer;
  Timer? _navigationTimer;
  bool _isAccepted = false;

  @override
  void initState() {
    super.initState();
    _startAcceptanceSimulation();
  }

  void _startAcceptanceSimulation() {
    // Automatically accept request after 3.5 seconds and move to LiveTrackingScreen
    _acceptanceTimer = Timer(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() {
        _isAccepted = true;
      });

      _navigationTimer = Timer(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LiveTrackingScreen(
              serviceCategory: widget.serviceCategory,
              providerName: widget.providerName,
              distance: widget.distance,
            ),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _acceptanceTimer?.cancel();
    _navigationTimer?.cancel();
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

            // Desktop framing: simulates mobile view on desktop web
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top Map Section (width: containerWidth, height: 295.0)
                      SizedBox(
                        width: containerWidth,
                        height: 295.0,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                  // 1. Background Map Layer ("use map img")
                            Positioned(
                              top: 0.0,
                              left: 0.0,
                              width: containerWidth,
                              height: 325.0,
                    child: Image.asset(
                      'assets/images/img.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/BG image.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (context, error, stackTrace) => Container(
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

                  // 2. Gradient Overlay Layer ("pickup & delivery screen layout branding")
                  Positioned(
                    top: 1.0,
                    left: 0.0,
                    width: containerWidth,
                    height: containerHeight,
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

                  // 3. Route Line Vector:
                  // width: 145.5; height: 91; angle: 0 deg; top: 183px; left: 116.5px; border: 4px solid #1D8070;
                  Positioned(
                    top: 183.0,
                    left: 116.5 + ((containerWidth - 390.0) / 2.0),
                    width: 145.5,
                    height: 91.0,
                    child: const CustomPaint(
                      size: Size(145.5, 91.0),
                      painter: _RouteVectorPainter(
                        color: Color(0xFF8B53FE),
                        strokeWidth: 4.0,
                      ),
                    ),
                  ),

                  // 4. Car Branding:
                  // width: 15; height: 24; angle: 60 deg; top: 258px; left: 241px;
                  Positioned(
                    top: 258.0,
                    left: 241.0 + ((containerWidth - 390.0) / 2.0),
                    width: 18.0,
                    height: 28.0,
                    child: Transform.rotate(
                      angle: -60.0 * math.pi / 180.0,
                      alignment: Alignment.center,
                      child: const CustomPaint(
                        size: Size(18.0, 28.0),
                        painter: _CarGraphicPainter(
                          roofColor: Color(0xFFA67AFE),
                        ),
                      ),
                    ),
                  ),

                  // 5. Location Marker Halo & Pin Branding:
                  // Outer soft glowing mint halo rings:
                  Positioned(
                    top: 153.0 - 12.0,
                    left: (111.0 - 12.0) + ((containerWidth - 390.0) / 2.0),
                    width: 60.0,
                    height: 60.0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF8B53FE).withValues(alpha: 0.12),
                        border: Border.all(
                          color: const Color(0xFF8B53FE).withValues(alpha: 0.22),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 153.0 - 5.0,
                    left: (111.0 - 5.0) + ((containerWidth - 390.0) / 2.0),
                    width: 46.0,
                    height: 46.0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF8B53FE).withValues(alpha: 0.18),
                      ),
                    ),
                  ),

                  // Location icon branding in brand purple (#8B53FE):
                  Positioned(
                    top: 153.0,
                    left: 111.0 + ((containerWidth - 390.0) / 2.0),
                    width: 36.0,
                    height: 36.0,
                    child: Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF0EAFE),
                        border: Border.all(
                          color: const Color(0x668B53FE),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x268B53FE),
                            blurRadius: 8.0,
                            spreadRadius: 1.0,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 20.0,
                          color: Color(0xFF8B53FE),
                        ),
                      ),
                    ),
                  ),

                  // 6. Distance Badge Branding:
                  // distance badge branding: width: 42; height: 26; angle: 0 deg; top: 124px; left: 119px; background: #1D8070;
                  // inner branding: width: 42; height: 19; gap: 10px; border-radius: 4px; padding: 6px; top: 124px; left: 119px;
                  // content: 1.8 km (width: 30; height: 7; Inter 400 10px line-height 22px #FFFFFF)
                  Positioned(
                    top: 124.0,
                    left: 119.0 + ((containerWidth - 390.0) / 2.0),
                    width: 42.0,
                    height: 26.0,
                    child: CustomPaint(
                      size: const Size(42.0, 26.0),
                      painter: const _DistanceBadgeTooltipPainter(
                        color: Color(0xFF8B53FE),
                        cornerRadius: 4.0,
                        pointerX: 10.0,
                        pointerWidth: 8.0,
                        pointerHeight: 7.0,
                      ),
                      child: Align(
                        alignment: const Alignment(0.0, -0.45),
                        child: Text(
                          widget.distance,
                          textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFFFFFFF),
                            height: 1.15,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 7. Header with same previous branding:
                  // width: 350; height: 36; gap: 16px; top: 56px; left: 20px;
                  Positioned(
                    top: 56.0,
                    left: containerWidth >= 390
                        ? 20.0
                        : ((containerWidth - 350.0) / 2).clamp(10.0, 20.0),
                    width: containerWidth >= 390
                        ? 350.0
                        : (containerWidth - 40.0).clamp(280.0, 350.0),
                    height: 36.0,
                    child: SizedBox(
                      width: containerWidth >= 390
                          ? 350.0
                          : (containerWidth - 40.0).clamp(280.0, 350.0),
                      height: 36.0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Circular Back Button
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              key: const Key('send_request_back_button'),
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
                          const SizedBox(width: 16.0), // gap: 16px;

                          // Title: Pickup & Delivery
                          Expanded(
                            child: Text(
                              widget.serviceCategory,
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

                          ],
                        ),
                      ),

                      // 8. Card Widget Branding (Send Request Card):
                      // border-top-left-radius: 28px; border-top-right-radius: 28px;
                      // angle: 0 deg; opacity: 1; background: #FFFFFF;
                      // box-shadow: 0px -2px 12px 0px #00000014;
                      Container(
                        width: containerWidth >= 390 ? 390.0 : containerWidth,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28.0),
                            topRight: Radius.circular(28.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x14000000), // #00000014
                              offset: Offset(0, -2),
                              blurRadius: 12.0,
                              spreadRadius: 0.0,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.only(top: 12.0, bottom: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Card top indicator handle (width: 40; height: 4; gap: 20px)
                            Center(
                              child: Container(
                                width: 40.0,
                                height: 4.0,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20.0), // gap: 20px;

                            // Content layout branding:
                            // width: 350; angle: 0 deg; opacity: 1; gap: 20px;
                            SizedBox(
                              width: containerWidth >= 390
                                  ? 350.0
                                  : (containerWidth - 40.0).clamp(280.0, 350.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                        // width: 350; height: 41; justify-content: space-between; angle: 0 deg; opacity: 1;
                                        SizedBox(
                                          width: containerWidth >= 390
                                              ? 350.0
                                              : (containerWidth - 40.0).clamp(280.0, 350.0),
                                          height: 41.0,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              // Left side content branding layout:
                                              // width: 236; height: 41; angle: 0 deg; opacity: 1; gap: 16px;
                                              SizedBox(
                                                width: 236.0,
                                                height: 41.0,
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    // Left side img layout: width: 36; height: 36;
                                                    Container(
                                                      width: 36.0,
                                                      height: 36.0,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Color(0xFFFFAAA6),
                                                      ),
                                                      clipBehavior: Clip.antiAlias,
                                                      child: Image.network(
                                                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=80',
                                                        width: 36.0,
                                                        height: 36.0,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) => Container(
                                                          color: const Color(0xFFFFAAA6),
                                                          child: const Center(
                                                            child: Icon(
                                                              Icons.person,
                                                              size: 22.0,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16.0), // gap: 16px;

                                                    // Content inner layout: width: 184; height: 41; gap: 12px;
                                                    SizedBox(
                                                      width: 184.0,
                                                      height: 41.0,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          // Text row layout: width: 184; height: 19; gap: 12px;
                                                          SizedBox(
                                                            width: 184.0,
                                                            height: 19.0,
                                                            child: Row(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                // content: Ahmad Transport
                                                                // width: 117; height: 10; font-family: Inter; font-weight: 500; font-size: 14px; line-height: 22px; color: #1C2926;
                                                                SizedBox(
                                                                  width: 117.0,
                                                                  child: Align(
                                                                    alignment: Alignment.centerLeft,
                                                                    child: Text(
                                                                      'Ahmad Transport',
                                                                      textHeightBehavior: const TextHeightBehavior(
                                                                        applyHeightToFirstAscent: false,
                                                                        applyHeightToLastDescent: false,
                                                                      ),
                                                                      style: GoogleFonts.inter(
                                                                        fontSize: 14.0,
                                                                        fontWeight: FontWeight.w500,
                                                                        color: const Color(0xFF1C2926),
                                                                        height: 22.0 / 14.0,
                                                                        letterSpacing: 0.0,
                                                                      ),
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 12.0), // gap: 12px;

                                                                // available word layout:
                                                                // width: 55; height: 19; gap: 10px; border-radius: 60px; padding: 6px; background: #F0F5F2;
                                                                // content: Available (width: 43; height: 7; font-family: Inter; font-weight: 500; font-size: 10px; line-height: 22px; color: #1D8070;)
                                                                Container(
                                                                  width: 55.0,
                                                                  height: 19.0,
                                                                  decoration: BoxDecoration(
                                                                    color: const Color(0xFFF0EAFE),
                                                                    borderRadius: BorderRadius.circular(60.0),
                                                                  ),
                                                                  alignment: Alignment.center,
                                                                  child: Text(
                                                                    'Available',
                                                                    textHeightBehavior: const TextHeightBehavior(
                                                                      applyHeightToFirstAscent: false,
                                                                      applyHeightToLastDescent: false,
                                                                    ),
                                                                    style: GoogleFonts.inter(
                                                                      fontSize: 10.0,
                                                                      fontWeight: FontWeight.w500,
                                                                      color: const Color(0xFF8B53FE),
                                                                      height: 22.0 / 10.0,
                                                                      letterSpacing: 0.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),

                                                          // reviews and status layout:
                                                          // width: 177; height: 10; gap: 8px;
                                                          SizedBox(
                                                            width: 177.0,
                                                            child: Row(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                // reviews layout: width: 57; height: 10; gap: 4px;
                                                                SizedBox(
                                                                  width: 57.0,
                                                                  child: Row(
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                      // star branding: width: 10; height: 10; border-radius: 0.4px; background: #07AF2C;
                                                                      const Icon(
                                                                        Icons.star_rounded,
                                                                        size: 10.0,
                                                                        color: Color(0xFF8B53FE),
                                                                      ),
                                                                      const SizedBox(width: 4.0), // gap: 4px;
                                                                      // content: 4.9 (120)
                                                                      Text.rich(
                                                                        TextSpan(
                                                                          text: '4.9',
                                                                          style: GoogleFonts.inter(
                                                                            fontSize: 10.0,
                                                                            fontWeight: FontWeight.w500,
                                                                            color: const Color(0xFF1C2926),
                                                                            height: 1.0,
                                                                            letterSpacing: 0.0,
                                                                          ),
                                                                          children: [
                                                                            TextSpan(
                                                                              text: ' (120)',
                                                                              style: GoogleFonts.inter(
                                                                                fontSize: 10.0,
                                                                                fontWeight: FontWeight.w400,
                                                                                color: const Color(0xFF566663),
                                                                                height: 1.0,
                                                                                letterSpacing: 0.0,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        textHeightBehavior: const TextHeightBehavior(
                                                                          applyHeightToFirstAscent: false,
                                                                          applyHeightToLastDescent: false,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 8.0), // gap: 8px;

                                                                // status layout: width: 112; height: 10; gap: 4px;
                                                                SizedBox(
                                                                  width: 112.0,
                                                                  child: Row(
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                      // rotating loader layout: width: 10; height: 10; background: #FFAE00;
                                                                      const _RotatingLoaderWidget(
                                                                        size: 10.0,
                                                                        color: Color(0xFFFFAE00),
                                                                      ),
                                                                      const SizedBox(width: 4.0), // gap: 4px;
                                                                      // content: Waiting for response
                                                                      Expanded(
                                                                        child: Text(
                                                                          'Waiting for response',
                                                                          textHeightBehavior: const TextHeightBehavior(
                                                                            applyHeightToFirstAscent: false,
                                                                            applyHeightToLastDescent: false,
                                                                          ),
                                                                          style: GoogleFonts.inter(
                                                                            fontSize: 10.0,
                                                                            fontWeight: FontWeight.w400,
                                                                            color: const Color(0xFFFFAE00),
                                                                            height: 1.0,
                                                                            letterSpacing: 0.0,
                                                                          ),
                                                                          maxLines: 1,
                                                                          overflow: TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // right side icons layout:
                                              // width: 84; height: 36; angle: 0 deg; opacity: 1; gap: 12px;
                                              SizedBox(
                                                width: 84.0,
                                                height: 36.0,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    // whatsap icon branding:
                                                    // width: 36; height: 36; angle: 0 deg; opacity: 1; border-radius: 60px; background: #25D366;
                                                    MouseRegion(
                                                      cursor: SystemMouseCursors.click,
                                                      child: GestureDetector(
                                                        key: const Key('send_request_whatsapp_button'),
                                                        onTap: () {
                                                          HapticFeedback.lightImpact();
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(
                                                              content: Text('Opening WhatsApp...'),
                                                              duration: Duration(seconds: 1),
                                                            ),
                                                          );
                                                        },
                                                        behavior: HitTestBehavior.opaque,
                                                        child: Container(
                                                          width: 36.0,
                                                          height: 36.0,
                                                          decoration: const BoxDecoration(
                                                            color: Color(0xFF25D366),
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: const Center(
                                                            child: CustomPaint(
                                                              size: Size(20.0, 20.0),
                                                              painter: _WhatsAppIconPainter(),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12.0), // gap: 12px;

                                                    // call icon layout:
                                                    // width: 36; height: 36; angle: 0 deg; opacity: 1; border-radius: 60px; background: #1C2926;
                                                    MouseRegion(
                                                      cursor: SystemMouseCursors.click,
                                                      child: GestureDetector(
                                                        key: const Key('send_request_call_button'),
                                                        onTap: () {
                                                          HapticFeedback.lightImpact();
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(
                                                              content: Text('Calling Ahmad Transport...'),
                                                              duration: Duration(seconds: 1),
                                                            ),
                                                          );
                                                        },
                                                        behavior: HitTestBehavior.opaque,
                                                        child: Container(
                                                          width: 36.0,
                                                          height: 36.0,
                                                          decoration: const BoxDecoration(
                                                            color: Color(0xFF1C2926),
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: const Center(
                                                            child: Icon(
                                                              Icons.phone,
                                                              size: 18.0,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16.0), // gap: 16px;

                                        // 2nd row: Toyota Hilux & Pickup & Delivery:
                                        // width: 350; height: 10; justify-content: space-between; angle: 0 deg; opacity: 1;
                                        SizedBox(
                                          width: containerWidth >= 390
                                              ? 350.0
                                              : (containerWidth - 40.0).clamp(280.0, 350.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              // content branding:
                                              // width: 202; height: 10; gap: 12px; angle: 0 deg; opacity: 1;
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  // car icon branding:
                                                  // width: 12; height: 10; angle: 0 deg; opacity: 1; background: #1C2926;
                                                  const Icon(
                                                    Icons.directions_car_filled_rounded,
                                                    size: 12.0,
                                                    color: Color(0xFF1C2926),
                                                  ),
                                                  const SizedBox(width: 12.0), // gap: 12px;

                                                  // text branding:
                                                  // width: 182; height: 9; gap: 12px; angle: 0 deg; opacity: 1;
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      // content: Toyota Hilux
                                                      // width: 71; height: 9; font-family: Inter; font-weight: 500; font-size: 12px; line-height: 22px; color: #1C2926;
                                                      Text(
                                                        'Toyota Hilux',
                                                        textHeightBehavior: const TextHeightBehavior(
                                                          applyHeightToFirstAscent: false,
                                                          applyHeightToLastDescent: false,
                                                        ),
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight.w500,
                                                          color: const Color(0xFF1C2926),
                                                          height: 22.0 / 12.0,
                                                          letterSpacing: 0.0,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12.0), // gap: 12px;

                                                      // content: Pickup & Delivery
                                                      // width: 99; height: 9; font-family: Inter; font-weight: 400; font-size: 12px; line-height: 22px; color: #566663;
                                                      Text(
                                                        'Pickup & Delivery',
                                                        textHeightBehavior: const TextHeightBehavior(
                                                          applyHeightToFirstAscent: false,
                                                          applyHeightToLastDescent: false,
                                                        ),
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight.w400,
                                                          color: const Color(0xFF566663),
                                                          height: 22.0 / 12.0,
                                                          letterSpacing: 0.0,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16.0), // gap: 16px;

                                        // 3rd section: metric cards grid:
                                        // width: 350; height: 136; gap: 12px; angle: 0 deg; opacity: 1;
                                        Container(
                                          width: containerWidth >= 390
                                              ? 350.0
                                              : (containerWidth - 40.0).clamp(280.0, 350.0),
                                          constraints: const BoxConstraints(minHeight: 136.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // 1st row of metric cards:
                                              Row(
                                                children: [
                                                  // 1st card branding: 1.8 km Distance Away
                                                  // width: 169 (flexible on mobile); height: 64; gap: 12px;
                                                  Expanded(
                                                    child: Container(
                                                      height: 64.0,
                                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFF2F5F4),
                                                        borderRadius: BorderRadius.circular(12.0),
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          // icon styling on left side:
                                                          // width: 32; height: 32; angle: 0 deg; opacity: 1; border-radius: 60px; background: #E2F0E6;
                                                          Container(
                                                            width: 32.0,
                                                            height: 32.0,
                                                            decoration: const BoxDecoration(
                                                              color: Color(0xFFF0EAFE),
                                                              shape: BoxShape.circle,
                                                            ),
                                                            child: const Center(
                                                              child: CustomPaint(
                                                                size: Size(16.0, 18.0),
                                                                painter: _LocationPinPainter(
                                                                  color: Color(0xFF8B53FE),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 12.0), // gap: 12px;

                                                          // inner card content right side:
                                                          // width: 93; height: 29; gap: 12px; angle: 0 deg; opacity: 1;
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                // content: 1.8 km
                                                                // width: 43; height: 10; font-family: Inter; font-weight: 500; font-size: 14px; line-height: 22px; color: #1C2926;
                                                                FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.centerLeft,
                                                                  child: Text(
                                                                    '1.8 km',
                                                                    textHeightBehavior: const TextHeightBehavior(
                                                                      applyHeightToFirstAscent: false,
                                                                      applyHeightToLastDescent: false,
                                                                    ),
                                                                    style: GoogleFonts.inter(
                                                                      fontSize: 14.0,
                                                                      fontWeight: FontWeight.w500,
                                                                      color: const Color(0xFF1C2926),
                                                                      height: 1.1,
                                                                      letterSpacing: 0.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 2.0),

                                                                // content: Distance Away
                                                                FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.centerLeft,
                                                                  child: Text(
                                                                    'Distance Away',
                                                                    textHeightBehavior: const TextHeightBehavior(
                                                                      applyHeightToFirstAscent: false,
                                                                      applyHeightToLastDescent: false,
                                                                    ),
                                                                    style: GoogleFonts.inter(
                                                                      fontSize: 10.0,
                                                                      fontWeight: FontWeight.w400,
                                                                      color: const Color(0xFF566663),
                                                                      height: 1.1,
                                                                      letterSpacing: 0.0,
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
                                                  const SizedBox(width: 12.0), // gap: 12px;

                                                  // 2nd card branding in same row: 6 min Estimated time
                                                  // width: 169 (flexible on mobile); height: 64; gap: 12px;
                                                  Expanded(
                                                    child: Container(
                                                      height: 64.0,
                                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFF2F5F4),
                                                        borderRadius: BorderRadius.circular(12.0),
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          // left side icon branding:
                                                          // width: 32; height: 32; angle: 0 deg; opacity: 1; border-radius: 60px; background: #E2F0E6;
                                                          Container(
                                                            width: 32.0,
                                                            height: 32.0,
                                                            decoration: const BoxDecoration(
                                                              color: Color(0xFFF0EAFE),
                                                              shape: BoxShape.circle,
                                                            ),
                                                            child: const Center(
                                                              // icon inner branding:
                                                              // width: 20; height: 20; angle: 0 deg; opacity: 1; top: 6.2px; left: 6.2px; background: #8B53FE;
                                                              child: CustomPaint(
                                                                size: Size(20.0, 20.0),
                                                                painter: _ClockIconPainter(
                                                                  backgroundColor: Color(0xFF8B53FE),
                                                                  handColor: Colors.white,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 12.0), // gap: 12px;

                                                          // content layout:
                                                          // width: 93; height: 29; gap: 12px; angle: 0 deg; opacity: 1;
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                // content: 6 min
                                                                // width: 37; height: 10; font-family: Inter; font-weight: 500; font-size: 14px; line-height: 22px; color: #1C2926;
                                                                FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.centerLeft,
                                                                  child: Text(
                                                                    '6 min',
                                                                    textHeightBehavior: const TextHeightBehavior(
                                                                      applyHeightToFirstAscent: false,
                                                                      applyHeightToLastDescent: false,
                                                                    ),
                                                                    style: GoogleFonts.inter(
                                                                      fontSize: 14.0,
                                                                      fontWeight: FontWeight.w500,
                                                                      color: const Color(0xFF1C2926),
                                                                      height: 1.1,
                                                                      letterSpacing: 0.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 2.0),

                                                                // content: Estimated time
                                                                // width: 71; height: 7; font-family: Inter; font-weight: 400; font-size: 10px; line-height: 22px; color: #566663;
                                                                FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.centerLeft,
                                                                  child: Text(
                                                                    'Estimated time',
                                                                    textHeightBehavior: const TextHeightBehavior(
                                                                      applyHeightToFirstAscent: false,
                                                                      applyHeightToLastDescent: false,
                                                                    ),
                                                                    style: GoogleFonts.inter(
                                                                      fontSize: 10.0,
                                                                      fontWeight: FontWeight.w400,
                                                                      color: const Color(0xFF566663),
                                                                      height: 1.1,
                                                                      letterSpacing: 0.0,
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
                                                ],
                                              ),
                                              const SizedBox(height: 12.0), // gap: 12px;

                                              // 2nd row branding:
                                              // width: 350; height: 60; justify-content: space-between; angle: 0 deg; opacity: 1;
                                              // border-radius: 12px; padding: 16px; background: #F2F5F4;
                                              Container(
                                                width: containerWidth >= 390
                                                    ? 350.0
                                                    : (containerWidth - 40.0).clamp(280.0, 350.0),
                                                height: 60.0,
                                                padding: const EdgeInsets.all(16.0),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF2F5F4),
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    // left side content:
                                                    // width: 83; height: 28; gap: 10px; angle: 0 deg; opacity: 1;
                                                    SizedBox(
                                                      width: 83.0,
                                                      height: 28.0,
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          // icon on left side branding:
                                                          // width: 28; height: 28; angle: 0 deg; opacity: 1; border-radius: 60px; background: #DDF0E3;
                                                          Container(
                                                            width: 28.0,
                                                            height: 28.0,
                                                            decoration: const BoxDecoration(
                                                              color: Color(0xFFF0EAFE),
                                                              shape: BoxShape.circle,
                                                            ),
                                                            child: const Center(
                                                              // icon inner branding :
                                                              // width: 14; height: 16; top: 6px; left: 7px; background: #1D8070;
                                                              child: CustomPaint(
                                                                size: Size(14.0, 16.0),
                                                                painter: _VerifiedShieldPainter(
                                                                  shieldColor: Color(0xFF8B53FE),
                                                                  checkColor: Colors.white,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 10.0), // gap: 10px;

                                                          // content branding:
                                                          // width: 45; height: 26; gap: 10px; angle: 0 deg; opacity: 1;
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                // content: Verified
                                                                // width: 45; height: 9; font-family: Inter; font-weight: 500; font-size: 12px; line-height: 22px; color: #1C2926;
                                                                FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.centerLeft,
                                                                  child: Text(
                                                                    'Verified',
                                                                    textHeightBehavior: const TextHeightBehavior(
                                                                      applyHeightToFirstAscent: false,
                                                                      applyHeightToLastDescent: false,
                                                                    ),
                                                                    style: GoogleFonts.inter(
                                                                      fontSize: 12.0,
                                                                      fontWeight: FontWeight.w500,
                                                                      color: const Color(0xFF1C2926),
                                                                      height: 1.1,
                                                                      letterSpacing: 0.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 1.0),

                                                                // content: Providers
                                                                // width: 45; height: 7; font-family: Inter; font-weight: 400; font-size: 10px; line-height: 22px; color: #566663;
                                                                FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.centerLeft,
                                                                  child: Text(
                                                                    'Providers',
                                                                    textHeightBehavior: const TextHeightBehavior(
                                                                      applyHeightToFirstAscent: false,
                                                                      applyHeightToLastDescent: false,
                                                                    ),
                                                                    style: GoogleFonts.inter(
                                                                      fontSize: 10.0,
                                                                      fontWeight: FontWeight.w400,
                                                                      color: const Color(0xFF566663),
                                                                      height: 1.1,
                                                                      letterSpacing: 0.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    // | branding:
                                                    // width: 0.800000011920929; height: 24; angle: 0 deg; opacity: 1; border-radius: 40px; background: #EDF0E9;
                                                    Container(
                                                      width: 0.8,
                                                      height: 24.0,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFEDF0E9),
                                                        borderRadius: BorderRadius.circular(40.0),
                                                      ),
                                                    ),

                                                    // center content:
                                                    // width: 85; height: 28; gap: 10px; angle: 0 deg; opacity: 1;
                                                    SizedBox(
                                                      width: 85.0,
                                                      height: 28.0,
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          // left side icon layout:
                                                          // width: 28; height: 28; angle: 0 deg; opacity: 1; border-radius: 60px; background: #DDF0E3;
                                                          Container(
                                                            width: 28.0,
                                                            height: 28.0,
                                                            decoration: const BoxDecoration(
                                                              color: Color(0xFFF0EAFE),
                                                              shape: BoxShape.circle,
                                                            ),
                                                            child: const Center(
                                                              // inner icon branding:
                                                              // width: 16; height: 12; angle: 0 deg; opacity: 1; top: 7.6px; left: 5.5px; background: #1D8070;
                                                              child: Icon(
                                                                Icons.group_rounded,
                                                                size: 16.0,
                                                                color: Color(0xFF8B53FE),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 10.0), // gap: 10px;

                                                          // content layout:
                                                          // width: 47; height: 26; gap: 10px; angle: 0 deg; opacity: 1;
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                // content: 500+
                                                                // width: 31; height: 9; font-family: Inter; font-weight: 500; font-size: 12px; line-height: 22px; color: #1C2926;
                                                                FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.centerLeft,
                                                                  child: Text(
                                                                    '500+',
                                                                    textHeightBehavior: const TextHeightBehavior(
                                                                      applyHeightToFirstAscent: false,
                                                                      applyHeightToLastDescent: false,
                                                                    ),
                                                                    style: GoogleFonts.inter(
                                                                      fontSize: 12.0,
                                                                      fontWeight: FontWeight.w500,
                                                                      color: const Color(0xFF1C2926),
                                                                      height: 1.1,
                                                                      letterSpacing: 0.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 1.0),

                                                                // content: Deliveries
                                                                // width: 47; height: 7; font-family: Inter; font-weight: 400; font-size: 10px; line-height: 22px; color: #566663;
                                                                FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.centerLeft,
                                                                  child: Text(
                                                                    'Deliveries',
                                                                    textHeightBehavior: const TextHeightBehavior(
                                                                      applyHeightToFirstAscent: false,
                                                                      applyHeightToLastDescent: false,
                                                                    ),
                                                                    style: GoogleFonts.inter(
                                                                      fontSize: 10.0,
                                                                      fontWeight: FontWeight.w400,
                                                                      color: const Color(0xFF566663),
                                                                      height: 1.1,
                                                                      letterSpacing: 0.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    // | branding will remain same:
                                                    // width: 0.800000011920929; height: 24; angle: 0 deg; opacity: 1; border-radius: 40px; background: #EDF0E9;
                                                    Container(
                                                      width: 0.8,
                                                      height: 24.0,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFEDF0E9),
                                                        borderRadius: BorderRadius.circular(40.0),
                                                      ),
                                                    ),

                                                    // right content layout:
                                                    // width: 75; height: 28; gap: 10px; angle: 0 deg; opacity: 1;
                                                    SizedBox(
                                                      width: 75.0,
                                                      height: 28.0,
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          // icon layout and inner branding will same:
                                                          // width: 28; height: 28; border-radius: 60px; background: #DDF0E3;
                                                          Container(
                                                            width: 28.0,
                                                            height: 28.0,
                                                            decoration: const BoxDecoration(
                                                              color: Color(0xFFF0EAFE),
                                                              shape: BoxShape.circle,
                                                            ),
                                                            child: const Center(
                                                              child: Icon(
                                                                Icons.thumb_up_rounded,
                                                                size: 15.0,
                                                                color: Color(0xFF8B53FE),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 10.0), // gap: 10px;

                                                          // content branding also will same:
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                // content: 98%
                                                                // width: 31; height: 9; font-family: Inter; font-weight: 500; font-size: 12px; line-height: 22px; color: #1C2926;
                                                                FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.centerLeft,
                                                                  child: Text(
                                                                    '98%',
                                                                    textHeightBehavior: const TextHeightBehavior(
                                                                      applyHeightToFirstAscent: false,
                                                                      applyHeightToLastDescent: false,
                                                                    ),
                                                                    style: GoogleFonts.inter(
                                                                      fontSize: 12.0,
                                                                      fontWeight: FontWeight.w500,
                                                                      color: const Color(0xFF1C2926),
                                                                      height: 1.1,
                                                                      letterSpacing: 0.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 1.0),

                                                                // content: On time
                                                                // width: 47; height: 7; font-family: Inter; font-weight: 400; font-size: 10px; line-height: 22px; color: #566663;
                                                                FittedBox(
                                                                  fit: BoxFit.scaleDown,
                                                                  alignment: Alignment.centerLeft,
                                                                  child: Text(
                                                                    'On time',
                                                                    textHeightBehavior: const TextHeightBehavior(
                                                                      applyHeightToFirstAscent: false,
                                                                      applyHeightToLastDescent: false,
                                                                    ),
                                                                    style: GoogleFonts.inter(
                                                                      fontSize: 10.0,
                                                                      fontWeight: FontWeight.w400,
                                                                      color: const Color(0xFF566663),
                                                                      height: 1.1,
                                                                      letterSpacing: 0.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16.0), // gap: 16px;

                                  // 4th section: Request Sent card layout:
                                  // width: 350; minHeight: 64; gap: 12px; border-radius: 12px; padding: 12px 16px; background: #F2F5F4;
                                  Container(
                                    width: containerWidth >= 390
                                        ? 350.0
                                        : (containerWidth - 40.0).clamp(280.0, 350.0),
                                    constraints: const BoxConstraints(minHeight: 64.0),
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F5F4),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // left side icon branding:
                                        // width: 32; height: 32; angle: 0 deg; opacity: 1; border-radius: 60px; background: #DDF0E3;
                                        Container(
                                          width: 32.0,
                                          height: 32.0,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF0EAFE),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            // icon inner branding:
                                            child: Icon(
                                              _isAccepted
                                                  ? Icons.check_circle_rounded
                                                  : Icons.send_rounded,
                                              size: 18.0,
                                              color: const Color(0xFF8B53FE),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12.0), // gap: 12px;

                                        // content layout:
                                        // width: 274; height: 31; gap: 12px;
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // content: Request Sent or Request Accepted
                                              Text(
                                                _isAccepted
                                                    ? 'Request Accepted!'
                                                    : 'Request Sent',
                                                textHeightBehavior: const TextHeightBehavior(
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
                                              const SizedBox(height: 2.0),

                                              // content: Waiting or Navigating
                                              Text(
                                                _isAccepted
                                                    ? 'Provider accepted. Starting live tracking...'
                                                    : 'Waiting for provider to accept your request.',
                                                textHeightBehavior: const TextHeightBehavior(
                                                  applyHeightToFirstAscent: false,
                                                  applyHeightToLastDescent: false,
                                                ),
                                                style: GoogleFonts.inter(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w400,
                                                  color: _isAccepted
                                                      ? const Color(0xFF8B53FE)
                                                      : const Color(0xFF566663),
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
                                  const SizedBox(height: 16.0), // gap: 16px;
                                        // 5th section: next layout branding (progress timeline):
                                        // width: 350; height: 59; gap: 12px; angle: 0 deg; opacity: 1;
                                        Container(
                                          width: containerWidth >= 390
                                              ? 350.0
                                              : (containerWidth - 40.0).clamp(280.0, 350.0),
                                          constraints: const BoxConstraints(minHeight: 59.0),
                                          child: IntrinsicHeight(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                // left side icons layout:
                                                // width: 12; angle: 0 deg; opacity: 1;
                                                const SizedBox(
                                                  width: 12.0,
                                                  child: CustomPaint(
                                                    painter: _TimelineTrackPainter(),
                                                  ),
                                                ),
                                                const SizedBox(width: 12.0), // gap: 12px;

                                                // right side content layout:
                                                // width: 326; gap: 16px;
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      // 1st row branding:
                                                      // width: 326; height: 9; justify-content: space-between;
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          // content: Request sent
                                                          // font-family: Inter; font-weight: 500; font-size: 12px; line-height: 22px; color: #1C2926;
                                                          Text(
                                                            'Request sent',
                                                            textHeightBehavior: const TextHeightBehavior(
                                                              applyHeightToFirstAscent: false,
                                                              applyHeightToLastDescent: false,
                                                            ),
                                                            style: GoogleFonts.inter(
                                                              fontSize: 12.0,
                                                              fontWeight: FontWeight.w500,
                                                              color: const Color(0xFF1C2926),
                                                              height: 1.0,
                                                              letterSpacing: 0.0,
                                                            ),
                                                          ),

                                                          // content: Just now
                                                          // font-family: Inter; font-weight: 400; font-size: 10px; line-height: 22px; color: #566663;
                                                          Text(
                                                            'Just now',
                                                            textHeightBehavior: const TextHeightBehavior(
                                                              applyHeightToFirstAscent: false,
                                                              applyHeightToLastDescent: false,
                                                            ),
                                                            style: GoogleFonts.inter(
                                                              fontSize: 10.0,
                                                              fontWeight: FontWeight.w400,
                                                              color: const Color(0xFF566663),
                                                              height: 1.0,
                                                              letterSpacing: 0.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      // 2nd row content:
                                                      // content: Provider accepted
                                                      // font-family: Inter; font-weight: 400; font-size: 12px; line-height: 22px; color: #566663;
                                                      Text(
                                                        'Provider accepted',
                                                        textHeightBehavior: const TextHeightBehavior(
                                                          applyHeightToFirstAscent: false,
                                                          applyHeightToLastDescent: false,
                                                        ),
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight.w400,
                                                          color: const Color(0xFF566663),
                                                          height: 1.0,
                                                          letterSpacing: 0.0,
                                                        ),
                                                      ),

                                                      // 3rd row branding:
                                                      // content: On the way
                                                      // font-family: Inter; font-weight: 400; font-size: 12px; line-height: 22px; color: #566663;
                                                      Text(
                                                        'On the way',
                                                        textHeightBehavior: const TextHeightBehavior(
                                                          applyHeightToFirstAscent: false,
                                                          applyHeightToLastDescent: false,
                                                        ),
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight.w400,
                                                          color: const Color(0xFF566663),
                                                          height: 1.0,
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

                                        const SizedBox(height: 20.0), // gap: 20px

                                        // cancel button layout:
                                        // width: 350; height: 52; angle: 0 deg; opacity: 1; gap: 10px;
                                        // border-radius: 12px; border-width: 0.6px;
                                        // padding-top: 20px; padding-right: 151px; padding-bottom: 20px; padding-left: 151px;
                                        // background: #FFF1F0; border: 0.6px solid #FFA399;
                                        // box-shadow: 0px 1px 8px 0px #0000000F;
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            key: const Key('send_request_cancel_button'),
                                            onTap: () {
                                              HapticFeedback.mediumImpact();
                                              _showCancelDialog(context);
                                            },
                                            behavior: HitTestBehavior.opaque,
                                            child: Container(
                                              width: containerWidth >= 390
                                                  ? 350.0
                                                  : (containerWidth - 40.0).clamp(280.0, 350.0),
                                              height: 52.0,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFF1F0),
                                                borderRadius: BorderRadius.circular(12.0),
                                                border: Border.all(
                                                  color: const Color(0xFFFFA399),
                                                  width: 0.6,
                                                ),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Color(0x0F000000), // #0000000F
                                                    offset: Offset(0, 1),
                                                    blurRadius: 8.0,
                                                    spreadRadius: 0.0,
                                                  ),
                                                ],
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                'Cancel',
                                                textHeightBehavior: const TextHeightBehavior(
                                                  applyHeightToFirstAscent: false,
                                                  applyHeightToLastDescent: false,
                                                ),
                                                style: GoogleFonts.inter(
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.w500,
                                                  color: const Color(0xFFFF1A00),
                                                  height: 22.0 / 14.0,
                                                  letterSpacing: 0.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                              ),
                            ),

                            const SizedBox(height: 24.0),

                            // Bottom Bar Layout: width: 390; height: 24;
                            SizedBox(
                              width: containerWidth >= 390 ? 390.0 : containerWidth,
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
                            const SizedBox(height: 8.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
            if (isDesktopWeb) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFF141C1A),
                child: Center(
                  child: Container(
                    width: containerWidth,
                    height: containerHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(42),
                      border: Border.all(
                        color: const Color(0xFF8B53FE).withValues(alpha: 0.35),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: screenContent,
                  ),
                ),
              );
            }

            return screenContent;
          },
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            'Cancel Request?',
            style: GoogleFonts.inter(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C2926),
            ),
          ),
          content: Text(
            'Are you sure you want to cancel your request to Ahmad Transport?',
            style: GoogleFonts.inter(
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF566663),
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'No, Keep',
                      style: GoogleFonts.inter(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF566663),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF1A00),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      'Yes, Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        _acceptanceTimer?.cancel();
        _navigationTimer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request cancelled'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).maybePop();
      }
    });
  }
}

/// Back Chevron Painter matching Figma specifications:
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

/// Route vector line painter matching Figma specifications:
class _RouteVectorPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _RouteVectorPainter({
    this.color = const Color(0xFF8B53FE),
    this.strokeWidth = 4.0,
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
    path.moveTo(12.5, 0.0);
    path.lineTo(2.0, 18.0);
    path.quadraticBezierTo(2.0, 24.0, 8.0, 27.0);
    path.lineTo(size.width - 2.0, size.height - 4.0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RouteVectorPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}

/// Top-down car graphic painter matching Figma car asset:
class _CarGraphicPainter extends CustomPainter {
  final Color roofColor;
  const _CarGraphicPainter({this.roofColor = const Color(0xFFA67AFE)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF2C3A36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final bodyRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1.5, 1.0, w - 3.0, h - 2.0),
      const Radius.circular(3.5),
    );
    canvas.drawRRect(bodyRRect, bodyPaint);
    canvas.drawRRect(bodyRRect, borderPaint);

    final glassPaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.fill;

    final windshieldRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3.0, 5.0, w - 6.0, 3.5),
      const Radius.circular(1.0),
    );
    canvas.drawRRect(windshieldRect, glassPaint);

    final roofPaint = Paint()
      ..color = roofColor
      ..style = PaintingStyle.fill;

    final roofRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3.2, 9.0, w - 6.4, 7.0),
      const Radius.circular(1.0),
    );
    canvas.drawRRect(roofRect, roofPaint);

    final rearGlassRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3.0, 16.5, w - 6.0, 2.5),
      const Radius.circular(1.0),
    );
    canvas.drawRRect(rearGlassRect, glassPaint);

    final tailPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2.5, h - 2.5, 2.5, 1.0),
        const Radius.circular(0.5),
      ),
      tailPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w - 5.0, h - 2.5, 2.5, 1.0),
        const Radius.circular(0.5),
      ),
      tailPaint,
    );

    final headPaint = Paint()
      ..color = const Color(0xFFE0F2FE)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2.5, 1.5, 2.5, 1.2),
        const Radius.circular(0.5),
      ),
      headPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w - 5.0, 1.5, 2.5, 1.2),
        const Radius.circular(0.5),
      ),
      headPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CarGraphicPainter oldDelegate) =>
      roofColor != oldDelegate.roofColor;
}

/// Location pin icon vector matching Figma icon:
class _LocationPinPainter extends CustomPainter {
  final Color color;
  const _LocationPinPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2.0;
    final r = (size.width / 2.0) - 1.0;
    final cy = r + 1.0;

    final pinPath = Path();
    pinPath.addArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      math.pi * 0.8,
      math.pi * 1.4,
    );
    pinPath.lineTo(cx, size.height);
    pinPath.close();

    canvas.drawPath(pinPath, strokePaint);
    canvas.drawCircle(Offset(cx, cy), 1.8, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _LocationPinPainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Distance badge tooltip speech-bubble painter:
class _DistanceBadgeTooltipPainter extends CustomPainter {
  final Color color;
  final double cornerRadius;
  final double pointerX;
  final double pointerWidth;
  final double pointerHeight;

  const _DistanceBadgeTooltipPainter({
    this.color = const Color(0xFF8B53FE),
    this.cornerRadius = 4.0,
    this.pointerX = 10.0,
    this.pointerWidth = 8.0,
    this.pointerHeight = 7.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final bodyHeight = size.height - pointerHeight;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, bodyHeight),
      Radius.circular(cornerRadius),
    );

    final path = Path()..addRRect(rrect);

    final pointerPath = Path();
    final halfWidth = pointerWidth / 2.0;
    pointerPath.moveTo(pointerX - halfWidth, bodyHeight - 0.5);
    pointerPath.lineTo(pointerX + halfWidth, bodyHeight - 0.5);
    pointerPath.lineTo(pointerX, size.height);
    pointerPath.close();

    final combined = Path.combine(PathOperation.union, path, pointerPath);
    canvas.drawPath(combined, paint);
  }

  @override
  bool shouldRepaint(covariant _DistanceBadgeTooltipPainter oldDelegate) =>
      color != oldDelegate.color ||
      cornerRadius != oldDelegate.cornerRadius ||
      pointerX != oldDelegate.pointerX ||
      pointerWidth != oldDelegate.pointerWidth ||
      pointerHeight != oldDelegate.pointerHeight;
}

/// Smooth Rotating Loader Widget (width: 10; height: 10; background: #FFAE00)
class _RotatingLoaderWidget extends StatefulWidget {
  final Color color;
  final double size;

  const _RotatingLoaderWidget({
    this.color = const Color(0xFFFFAE00),
    this.size = 10.0,
  });

  @override
  State<_RotatingLoaderWidget> createState() => _RotatingLoaderWidgetState();
}

class _RotatingLoaderWidgetState extends State<_RotatingLoaderWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void deactivate() {
    _controller.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _LoaderArcPainter(color: widget.color),
      ),
    );
  }
}

class _LoaderArcPainter extends CustomPainter {
  final Color color;
  const _LoaderArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0.8, 0.8, size.width - 1.6, size.height - 1.6);
    canvas.drawArc(rect, 0.0, math.pi * 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant _LoaderArcPainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Real WhatsApp official vector icon painter matching Figma specifications:
/// Outer speech-bubble ring + classic telephone receiver inside
class _WhatsAppIconPainter extends CustomPainter {
  const _WhatsAppIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Official WhatsApp vector path defined on a 24x24 viewBox
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

    // 2. Inner speech-bubble hole (creating the crisp outline)
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

/// Real clock icon painter matching Figma specifications:
/// width: 20; height: 20; background: #1C2926; with crisp white clock hands (#FFFFFF)
class _ClockIconPainter extends CustomPainter {
  final Color backgroundColor;
  final Color handColor;

  const _ClockIconPainter({
    this.backgroundColor = const Color(0xFF1C2926),
    this.handColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2.0;
    final double cy = size.height / 2.0;
    final double radius = size.width / 2.0;

    // 1. Dark circular clock body (#1C2926)
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(Offset(cx, cy), radius, bgPaint);

    // 2. White clock hands (matching Figma / Lucide clock polyline: 12:00 -> center -> ~4:00)
    final handPaint = Paint()
      ..color = handColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final path = Path();
    // Vertical hand from ~12 o'clock down to center
    path.moveTo(cx, cy - radius * 0.52);
    path.lineTo(cx, cy);
    // Minute hand pointing down-right towards ~4 o'clock
    path.lineTo(cx + radius * 0.42, cy + radius * 0.28);

    canvas.drawPath(path, handPaint);
  }

  @override
  bool shouldRepaint(covariant _ClockIconPainter oldDelegate) =>
      backgroundColor != oldDelegate.backgroundColor ||
      handColor != oldDelegate.handColor;
}

/// Verified shield icon painter matching Figma specifications:
/// width: 14; height: 16; background: #1D8070; with crisp white checkmark
class _VerifiedShieldPainter extends CustomPainter {
  final Color shieldColor;
  final Color checkColor;

  const _VerifiedShieldPainter({
    this.shieldColor = const Color(0xFF8B53FE),
    this.checkColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw smooth shield contour
    final shieldPaint = Paint()
      ..color = shieldColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final shieldPath = Path();
    shieldPath.moveTo(size.width * 0.5, 0.5);
    // Top-right curve
    shieldPath.quadraticBezierTo(size.width * 0.75, 0.5, size.width - 0.5, 2.5);
    // Right side down to bottom tip
    shieldPath.cubicTo(size.width - 0.5, 8.5, size.width * 0.75, 13.5, size.width * 0.5, size.height - 0.5);
    // Bottom tip up left side
    shieldPath.cubicTo(size.width * 0.25, 13.5, 0.5, 8.5, 0.5, 2.5);
    // Top-left curve back to top center
    shieldPath.quadraticBezierTo(size.width * 0.25, 0.5, size.width * 0.5, 0.5);
    shieldPath.close();

    canvas.drawPath(shieldPath, shieldPaint);

    // 2. Draw crisp checkmark inside shield
    final checkPaint = Paint()
      ..color = checkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final checkPath = Path();
    checkPath.moveTo(size.width * 0.30, size.height * 0.50);
    checkPath.lineTo(size.width * 0.46, size.height * 0.64);
    checkPath.lineTo(size.width * 0.72, size.height * 0.36);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant _VerifiedShieldPainter oldDelegate) =>
      shieldColor != oldDelegate.shieldColor ||
      checkColor != oldDelegate.checkColor;
}

/// Timeline progress track painter matching Figma specifications:
/// width: 12; height: 58;
/// 1st circle: top 0.5px, 12x12, border 3.5px #1D8070, bg #FFFFFF
/// 2nd circle: top 24.5px, 10x10, border 4px #1D8070, bg #FFFFFF
/// 3rd circle: top 46.5px, 12x12, border 1.5px #1D8070, bg #FFFFFF, inner 6x6 circle #1D8070
class _TimelineTrackPainter extends CustomPainter {
  const _TimelineTrackPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const brandColor = Color(0xFF8B53FE);

    final double topY = 6.5;
    final double botY = math.max(topY + 20.0, size.height - 6.5);
    final double midY = (topY + botY) / 2.0;

    // 1. Vertical connector line running between top and bottom node (center x = 6.0)
    final linePaint = Paint()
      ..color = brandColor
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawLine(
      Offset(6.0, topY),
      Offset(6.0, botY),
      linePaint,
    );

    // 2. 1st circle: center: (6.0, topY)
    final topFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(6.0, topY), 6.0, topFillPaint);

    final topBorderPaint = Paint()
      ..color = brandColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(6.0, topY), 6.0 - 3.5 / 2.0, topBorderPaint);

    // 3. 2nd circle: center: (6.0, midY)
    final midFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(6.0, midY), 5.0, midFillPaint);

    final midBorderPaint = Paint()
      ..color = brandColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(6.0, midY), 5.0 - 4.0 / 2.0, midBorderPaint);

    // 4. 3rd circle: center: (6.0, botY)
    final botFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(6.0, botY), 6.0, botFillPaint);

    final botBorderPaint = Paint()
      ..color = brandColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(6.0, botY), 6.0 - 1.5 / 2.0, botBorderPaint);

    // 5. 3rd circle inner branding: width: 6, height: 6
    final botInnerPaint = Paint()
      ..color = brandColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(Offset(6.0, botY), 3.0, botInnerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}