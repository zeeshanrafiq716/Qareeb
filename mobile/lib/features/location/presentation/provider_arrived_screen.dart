import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Screen displayed automatically when provider reaches the location.
/// Follows the exact same layout and branding as LiveTrackingScreen,
/// with updated metric cards (0 km, Arrived) and the arrival status card.
class ProviderArrivedScreen extends ConsumerStatefulWidget {
  final String serviceCategory;
  final String providerName;
  final String arrivalTime;

  const ProviderArrivedScreen({
    super.key,
    this.serviceCategory = 'Pickup & Delivery',
    this.providerName = 'Ahmad Transport',
    this.arrivalTime = '9:40 PM',
  });

  @override
  ConsumerState<ProviderArrivedScreen> createState() =>
      _ProviderArrivedScreenState();
}

class _ProviderArrivedScreenState extends ConsumerState<ProviderArrivedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

            // Desktop framing simulates mobile view
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
                      // Top Map Section (width: containerWidth, height: 508.0, top: 0 to 508px)
                      SizedBox(
                        width: containerWidth,
                        height: 508.0,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 1. Background Map Layer
                            Positioned(
                              top: 0.0,
                              left: 0.0,
                              width: containerWidth,
                              height: 540.0,
                              child: Image.asset(
                                'assets/images/img.png',
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                  'assets/images/BG image.png',
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
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

                            // 2. Gradient Overlay Layer
                            Positioned(
                              top: 1.0,
                              left: 0.0,
                              width: containerWidth,
                              height: 508.0,
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

                            // 3. Arrived Car Marker (positioned beside user destination pin)
                            Positioned(
                              top: 160.0,
                              left: 155.0 + ((containerWidth - 390.0) / 2.0),
                              width: 18.0,
                              height: 28.0,
                              child: AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: child,
                                  );
                                },
                                child: Transform.rotate(
                                  angle: -30.0 * math.pi / 180.0,
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    'assets/images/car.png',
                                    width: 18.0,
                                    height: 28.0,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const CustomPaint(
                                      size: Size(18.0, 28.0),
                                      painter: _CarGraphicPainter(
                                        roofColor: Color(0xFF1D8070),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // 4. Location Marker Halo & Pin Branding
                            Positioned(
                              top: 153.0 - 12.0,
                              left: (111.0 - 12.0) +
                                  ((containerWidth - 390.0) / 2.0),
                              width: 60.0,
                              height: 60.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF1D8070)
                                      .withValues(alpha: 0.12),
                                  border: Border.all(
                                    color: const Color(0xFF1D8070)
                                        .withValues(alpha: 0.22),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 153.0 - 5.0,
                              left: (111.0 - 5.0) +
                                  ((containerWidth - 390.0) / 2.0),
                              width: 46.0,
                              height: 46.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF1D8070)
                                      .withValues(alpha: 0.18),
                                ),
                              ),
                            ),

                            // Location icon branding
                            Positioned(
                              top: 153.0,
                              left: 111.0 + ((containerWidth - 390.0) / 2.0),
                              width: 36.0,
                              height: 36.0,
                              child: Container(
                                width: 36.0,
                                height: 36.0,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFF0FFF7),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x669FFFCB),
                                      blurRadius: 4.0,
                                      spreadRadius: 0.0,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(4.0),
                                child: Center(
                                  child: Container(
                                    width: 28.0,
                                    height: 28.0,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1D8070),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: CustomPaint(
                                        size: Size(13.0, 16.0),
                                        painter: _LocationPinPainter(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // 5. Distance Badge: 0 km (Arrived)
                            Positioned(
                              top: 124.0,
                              left: 119.0 + ((containerWidth - 390.0) / 2.0),
                              width: 42.0,
                              height: 26.0,
                              child: CustomPaint(
                                size: const Size(42.0, 26.0),
                                painter: const _DistanceBadgeTooltipPainter(
                                  color: Color(0xFF1D8070),
                                  cornerRadius: 4.0,
                                  pointerX: 10.0,
                                  pointerWidth: 8.0,
                                  pointerHeight: 7.0,
                                ),
                                child: Align(
                                  alignment: const Alignment(0.0, -0.45),
                                  child: Text(
                                    '0 km',
                                    textHeightBehavior:
                                        const TextHeightBehavior(
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

                            // 6. Header
                            Positioned(
                              top: 56.0,
                              left: containerWidth >= 390
                                  ? 20.0
                                  : ((containerWidth - 350.0) / 2)
                                      .clamp(10.0, 20.0),
                              width: containerWidth >= 390
                                  ? 350.0
                                  : (containerWidth - 40.0).clamp(280.0, 350.0),
                              height: 36.0,
                              child: SizedBox(
                                width: containerWidth >= 390
                                    ? 350.0
                                    : (containerWidth - 40.0)
                                        .clamp(280.0, 350.0),
                                height: 36.0,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Circular Back Button
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        key: const Key(
                                            'provider_arrived_back_button'),
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
                                                color: Color(0x14000000),
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
                                    const SizedBox(width: 16.0),

                                    // Title
                                    Expanded(
                                      child: Text(
                                        widget.serviceCategory,
                                        textHeightBehavior:
                                            const TextHeightBehavior(
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

                                    // Arrived status badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 5.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5E9),
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        border: Border.all(
                                          color: const Color(0xFF81C784),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 7.0,
                                            height: 7.0,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF2E7D32),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 5.0),
                                          Text(
                                            'ARRIVED',
                                            style: GoogleFonts.inter(
                                              fontSize: 10.0,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF2E7D32),
                                              letterSpacing: 0.6,
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

                      // 7. Main Card Widget:
                      // width: 390; height: 336; top: 508px;
                      // border-top-left-radius: 28px; border-top-right-radius: 28px;
                      // background: #FFFFFF; box-shadow: 0px -2px 12px 0px #00000014;
                      Container(
                        width: containerWidth >= 390 ? 390.0 : containerWidth,
                        height: 336.0,
                        constraints: const BoxConstraints(minHeight: 336.0),
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
                        padding: const EdgeInsets.only(top: 12.0, bottom: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Card top indicator handle
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
                            const SizedBox(height: 16.0),

                            // content layout:
                            // width: 350; gap: 20px;
                            SizedBox(
                              width: containerWidth >= 390
                                  ? 350.0
                                  : (containerWidth - 40.0).clamp(280.0, 350.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // content inner layout:
                                  SizedBox(
                                    width: containerWidth >= 390
                                        ? 350.0
                                        : (containerWidth - 40.0).clamp(280.0, 350.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 1st row branding:
                                        // width: 350; height: 38; justify-content: space-between;
                                        SizedBox(
                                          width: containerWidth >= 390
                                              ? 350.0
                                              : (containerWidth - 40.0).clamp(280.0, 350.0),
                                          height: 38.0,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // left side branding:
                                              // width: 246; height: 38; gap: 16px;
                                              SizedBox(
                                                width: 246.0,
                                                height: 38.0,
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    // img branding: width: 36; height: 36;
                                                    Container(
                                                      width: 36.0,
                                                      height: 36.0,
                                                      decoration:
                                                          const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                            Color(0xFFFFAAA6),
                                                      ),
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      child: Image.network(
                                                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop&q=80',
                                                        width: 36.0,
                                                        height: 36.0,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                                error,
                                                                stackTrace) =>
                                                            Container(
                                                          color: const Color(
                                                              0xFFFFAAA6),
                                                          child: const Center(
                                                            child: Icon(
                                                              Icons.person,
                                                              size: 22.0,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16.0),

                                                    // content layout: width: 194; height: 38; gap: 12px;
                                                    SizedBox(
                                                      width: 194.0,
                                                      height: 38.0,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          // content inner: width: 194; height: 19; gap: 10px;
                                                          SizedBox(
                                                            width: 194.0,
                                                            height: 19.0,
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  widget
                                                                      .providerName,
                                                                  textHeightBehavior:
                                                                      const TextHeightBehavior(
                                                                    applyHeightToFirstAscent:
                                                                        false,
                                                                    applyHeightToLastDescent:
                                                                        false,
                                                                  ),
                                                                  style: GoogleFonts
                                                                      .inter(
                                                                    fontSize:
                                                                        14.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: const Color(
                                                                        0xFF1C2926),
                                                                    height: 1.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                const SizedBox(
                                                                    width: 10.0),

                                                                // Arrived badge
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                    horizontal:
                                                                        8.0,
                                                                    vertical:
                                                                        3.0,
                                                                  ),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: const Color(
                                                                        0xFFEBF7F2),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                60.0),
                                                                  ),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Text(
                                                                    'Arrived',
                                                                    textHeightBehavior:
                                                                        const TextHeightBehavior(
                                                                      applyHeightToFirstAscent:
                                                                          false,
                                                                      applyHeightToLastDescent:
                                                                          false,
                                                                    ),
                                                                    style: GoogleFonts
                                                                        .inter(
                                                                      fontSize:
                                                                          10.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: const Color(
                                                                          0xFF1D8070),
                                                                      height:
                                                                          1.0,
                                                                      letterSpacing:
                                                                          0.0,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),

                                                          // 2nd row: EAT Arrived
                                                          Text.rich(
                                                            TextSpan(
                                                              text: 'Status: ',
                                                              style:
                                                                  GoogleFonts
                                                                      .inter(
                                                                fontSize: 11.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: const Color(
                                                                    0xFF566663),
                                                                height: 1.0,
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                              children: [
                                                                TextSpan(
                                                                  text: 'At your location',
                                                                  style:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontSize:
                                                                        11.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: const Color(
                                                                        0xFF1D8070),
                                                                    height: 1.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            textHeightBehavior:
                                                                const TextHeightBehavior(
                                                              applyHeightToFirstAscent:
                                                                  false,
                                                              applyHeightToLastDescent:
                                                                  false,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // right side branding: WhatsApp and Call buttons
                                              SizedBox(
                                                width: 84.0,
                                                height: 36.0,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    // WhatsApp button
                                                    MouseRegion(
                                                      cursor: SystemMouseCursors
                                                          .click,
                                                      child: GestureDetector(
                                                        key: const Key(
                                                            'provider_arrived_whatsapp_button'),
                                                        onTap: () {
                                                          HapticFeedback
                                                              .lightImpact();
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Opening WhatsApp...'),
                                                              duration: Duration(
                                                                  seconds: 1),
                                                            ),
                                                          );
                                                        },
                                                        behavior:
                                                            HitTestBehavior
                                                                .opaque,
                                                        child: Container(
                                                          width: 36.0,
                                                          height: 36.0,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Color(
                                                                0xFF25D366),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: const Center(
                                                            child: CustomPaint(
                                                              size: Size(
                                                                  20.0, 20.0),
                                                              painter:
                                                                  _WhatsAppIconPainter(),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12.0),

                                                    // Call button
                                                    MouseRegion(
                                                      cursor: SystemMouseCursors
                                                          .click,
                                                      child: GestureDetector(
                                                        key: const Key(
                                                            'provider_arrived_call_button'),
                                                        onTap: () {
                                                          HapticFeedback
                                                              .lightImpact();
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  'Calling ${widget.providerName}...'),
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          1),
                                                            ),
                                                          );
                                                        },
                                                        behavior:
                                                            HitTestBehavior
                                                                .opaque,
                                                        child: Container(
                                                          width: 36.0,
                                                          height: 36.0,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Color(
                                                                0xFF1C2926),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: const Center(
                                                            child: Icon(
                                                              Icons.phone,
                                                              size: 18.0,
                                                              color:
                                                                  Colors.white,
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

                                        const SizedBox(height: 16.0),

                                        // Divider line matching screenshot
                                        Container(
                                          width: containerWidth >= 390
                                              ? 350.0
                                              : (containerWidth - 40.0).clamp(280.0, 350.0),
                                          height: 1.0,
                                          color: const Color(0xFFF3F4F6),
                                        ),

                                        const SizedBox(height: 16.0),

                                        // 2nd row: Toyota Hilux & Pickup & Delivery
                                        SizedBox(
                                          width: containerWidth >= 390
                                              ? 350.0
                                              : (containerWidth - 40.0).clamp(280.0, 350.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.directions_car_filled_rounded,
                                                    size: 14.0,
                                                    color: Color(0xFF1C2926),
                                                  ),
                                                  const SizedBox(width: 12.0),

                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        'Toyota Hilux',
                                                        textHeightBehavior:
                                                            const TextHeightBehavior(
                                                          applyHeightToFirstAscent:
                                                              false,
                                                          applyHeightToLastDescent:
                                                              false,
                                                        ),
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: const Color(
                                                              0xFF1C2926),
                                                          height: 22.0 / 12.0,
                                                          letterSpacing: 0.0,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12.0),

                                                      Text(
                                                        widget.serviceCategory,
                                                        textHeightBehavior:
                                                            const TextHeightBehavior(
                                                          applyHeightToFirstAscent:
                                                              false,
                                                          applyHeightToLastDescent:
                                                              false,
                                                        ),
                                                        style: GoogleFonts.inter(
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: const Color(
                                                              0xFF566663),
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

                                        const SizedBox(height: 16.0),

                                        // 3rd section: metric cards row (0 km Distance Away & Arrived 9:40 PM)
                                        SizedBox(
                                          width: containerWidth >= 390
                                              ? 350.0
                                              : (containerWidth - 40.0).clamp(280.0, 350.0),
                                          child: Row(
                                            children: [
                                              // 1st card branding: 0 km Distance Away
                                              Expanded(
                                                child: Container(
                                                  height: 64.0,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 12.0,
                                                    vertical: 12.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFF2F5F4),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.center,
                                                    children: [
                                                      // left side icon: 32x32 mint circle with location pin
                                                      Container(
                                                        width: 32.0,
                                                        height: 32.0,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Color(0xFFE2F0E6),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: const Center(
                                                          child: CustomPaint(
                                                            size: Size(
                                                                16.0, 18.0),
                                                            painter:
                                                                _LocationPinPainter(
                                                              color: Color(
                                                                  0xFF1C2926),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12.0),

                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            // content: 0 km
                                                            FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                '0 km',
                                                                textHeightBehavior:
                                                                    const TextHeightBehavior(
                                                                  applyHeightToFirstAscent:
                                                                      false,
                                                                  applyHeightToLastDescent:
                                                                      false,
                                                                ),
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontSize:
                                                                      14.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: const Color(
                                                                      0xFF1C2926),
                                                                  height: 1.1,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 2.0),

                                                            // content: Distance Away
                                                            FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                'Distance Away',
                                                                textHeightBehavior:
                                                                    const TextHeightBehavior(
                                                                  applyHeightToFirstAscent:
                                                                      false,
                                                                  applyHeightToLastDescent:
                                                                      false,
                                                                ),
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontSize:
                                                                      10.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: const Color(
                                                                      0xFF566663),
                                                                  height: 1.1,
                                                                  letterSpacing:
                                                                      0.0,
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
                                              const SizedBox(width: 12.0),

                                              // 2nd card branding: Arrived 9:40 PM
                                              Expanded(
                                                child: Container(
                                                  height: 64.0,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 12.0,
                                                    vertical: 12.0,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFF2F5F4),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.center,
                                                    children: [
                                                      // left side icon: 32x32 mint circle with clock icon
                                                      Container(
                                                        width: 32.0,
                                                        height: 32.0,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Color(0xFFE2F0E6),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: const Center(
                                                          child: CustomPaint(
                                                            size: Size(
                                                                20.0, 20.0),
                                                            painter:
                                                                _ClockIconPainter(
                                                              backgroundColor:
                                                                  Color(
                                                                      0xFF1C2926),
                                                              handColor:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12.0),

                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            // content: Arrived
                                                            FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                'Arrived',
                                                                textHeightBehavior:
                                                                    const TextHeightBehavior(
                                                                  applyHeightToFirstAscent:
                                                                      false,
                                                                  applyHeightToLastDescent:
                                                                      false,
                                                                ),
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontSize:
                                                                      14.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: const Color(
                                                                      0xFF1C2926),
                                                                  height: 1.1,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 2.0),

                                                            // content: 9:40 PM
                                                            FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                widget.arrivalTime,
                                                                textHeightBehavior:
                                                                    const TextHeightBehavior(
                                                                  applyHeightToFirstAscent:
                                                                      false,
                                                                  applyHeightToLastDescent:
                                                                      false,
                                                                ),
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontSize:
                                                                      10.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: const Color(
                                                                      0xFF566663),
                                                                  height: 1.1,
                                                                  letterSpacing:
                                                                      0.0,
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
                                        ),

                                        const SizedBox(height: 12.0),

                                        // 4th section: Replaced status card: "Your Provider has arrived!"
                                        // width: 350; minHeight: 64; gap: 12px; border-radius: 12px; padding: 16px; background: #F2F5F4;
                                        Container(
                                          width: containerWidth >= 390
                                              ? 350.0
                                              : (containerWidth - 40.0).clamp(280.0, 350.0),
                                          constraints:
                                              const BoxConstraints(minHeight: 64.0),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 12.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF2F5F4),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // left side icon: 32x32 mint circle with dark teal circle & white checkmark
                                              Container(
                                                width: 32.0,
                                                height: 32.0,
                                                decoration:
                                                    const BoxDecoration(
                                                  color: Color(0xFFDDF0E3),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Container(
                                                    width: 24.0,
                                                    height: 24.0,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Color(0xFF1D8070),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.check_rounded,
                                                        size: 16.0,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12.0),

                                              // right side content:
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    // content: Your Provider has arrived!
                                                    Text(
                                                      'Your Provider has arrived!',
                                                      textHeightBehavior:
                                                          const TextHeightBehavior(
                                                        applyHeightToFirstAscent:
                                                            false,
                                                        applyHeightToLastDescent:
                                                            false,
                                                      ),
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: const Color(
                                                            0xFF1C2926),
                                                        height: 22.0 / 14.0,
                                                        letterSpacing: 0.0,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 2.0),

                                                    // content: Provider has arrived. Start service now.
                                                    Text(
                                                      'Provider has arrived. Start service now.',
                                                      textHeightBehavior:
                                                          const TextHeightBehavior(
                                                        applyHeightToFirstAscent:
                                                            false,
                                                        applyHeightToLastDescent:
                                                            false,
                                                      ),
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: const Color(
                                                            0xFF566663),
                                                        height: 22.0 / 12.0,
                                                        letterSpacing: 0.0,
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
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),

                            // Bottom Bar Layout: width: 390; height: 24;
                            SizedBox(
                              width: containerWidth >= 390
                                  ? 390.0
                                  : containerWidth,
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
                        color: const Color(0xFF9FFFCB).withValues(alpha: 0.35),
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
}

/// Back Chevron Painter
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

/// Top-down car graphic painter
class _CarGraphicPainter extends CustomPainter {
  final Color roofColor;
  const _CarGraphicPainter({this.roofColor = const Color(0xFF1D8070)});

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

/// Location pin icon vector
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

/// Distance badge tooltip speech-bubble painter
class _DistanceBadgeTooltipPainter extends CustomPainter {
  final Color color;
  final double cornerRadius;
  final double pointerX;
  final double pointerWidth;
  final double pointerHeight;

  const _DistanceBadgeTooltipPainter({
    this.color = const Color(0xFF1D8070),
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

/// Official WhatsApp vector icon painter
class _WhatsAppIconPainter extends CustomPainter {
  const _WhatsAppIconPainter();

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

/// Real clock icon painter
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

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(Offset(cx, cy), radius, bgPaint);

    final handPaint = Paint()
      ..color = handColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final path = Path();
    path.moveTo(cx, cy - radius * 0.52);
    path.lineTo(cx, cy);
    path.lineTo(cx + radius * 0.42, cy + radius * 0.28);

    canvas.drawPath(path, handPaint);
  }

  @override
  bool shouldRepaint(covariant _ClockIconPainter oldDelegate) =>
      backgroundColor != oldDelegate.backgroundColor ||
      handColor != oldDelegate.handColor;
}
