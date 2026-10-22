import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_locale.dart';
import 'provider_arrived_screen.dart';
import 'widgets/top_down_car_widget.dart';

/// Screen displayed automatically when provider accepts the request.
/// Integrates the exact same header and map layer as SendRequestScreen.
class LiveTrackingScreen extends ConsumerStatefulWidget {
  final String serviceCategory;
  final String providerName;
  final String distance;
  final String duration;

  const LiveTrackingScreen({
    super.key,
    this.serviceCategory = 'Pickup & Delivery',
    this.providerName = 'Ahmad Transport',
    this.distance = '1.8 km',
    this.duration = '8 min',
  });

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen>
    with SingleTickerProviderStateMixin {
  AppTranslations get tr => ref.read(translationsProvider);
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _arrivalTimer;

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

    // Automatically navigate to ProviderArrivedScreen when provider reaches destination
    _arrivalTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ProviderArrivedScreen(
            serviceCategory: widget.serviceCategory,
            providerName: widget.providerName,
          ),
        ),
      );
    });
  }

  @override
  void deactivate() {
    _pulseController.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    _arrivalTimer?.cancel();
    _pulseController.stop();
    _pulseController.dispose();
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
                      // Top Map Section (width: containerWidth, height: 508.0, top: 0 to 508px)
                      SizedBox(
                        width: containerWidth,
                        height: 508.0,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 1. Background Map Layer ("use map img")
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

                            // 2. Gradient Overlay Layer ("pickup & delivery screen layout branding")
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
                                        Color(0xFFFFFFFF), // #FFFFFF 2.14%
                                        Color(0xD6FFFFFF), // rgba(255, 255, 255, 0.839534) 17.05%
                                        Color(0x00FFFFFF), // rgba(255, 255, 255) 26.93%
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

                            // 4. Car Branding (with live pulse animation):
                            // width: 15; height: 24; angle: 60 deg; top: 258px; left: 241px;
                            Positioned(
                              top: 258.0,
                              left: 241.0 + ((containerWidth - 390.0) / 2.0),
                              child: AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: child,
                                  );
                                },
                                child: TopDownCarWidget(
                                  width: 16.5,
                                  height: 28.5,
                                  angle: -60.0,
                                  driverName: widget.providerName,
                                  distanceKm: double.tryParse(widget.distance.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 1.8,
                                  showBadge: true,
                                  isSelected: true,
                                  bodyColor: const Color(0xFFA67AFE),
                                ),
                              ),
                            ),

                            // 5. Location Marker Halo & Pin Branding:
                            // Outer soft glowing mint halo rings:
                            Positioned(
                              top: 153.0 - 12.0,
                              left: (111.0 - 12.0) +
                                  ((containerWidth - 390.0) / 2.0),
                              width: 60.0,
                              height: 56.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF8B53FE)
                                      .withValues(alpha: 0.12),
                                  border: Border.all(
                                    color: const Color(0xFF8B53FE)
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
                                  color: const Color(0xFF8B53FE)
                                      .withValues(alpha: 0.18),
                                ),
                              ),
                            ),

                            // Location icon branding:
                            // width: 36; height: 36; gap: 10px; angle: 0 deg; opacity: 1; border-radius: 40px;
                            // padding: 4px; top: 153px; left: 111px; background: #F0FFF7; box-shadow: 0px 0px 4px 0px #9FFFCB66 inset;
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
                                  color: Color(0xFFF0EAFE),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x408B53FE),
                                      blurRadius: 4.0,
                                      spreadRadius: 0.0,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(4.0),
                                child: Center(
                                  child: Container(
                                    width: 28.0,
                                    constraints: const BoxConstraints(minHeight: 28.0),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF8B53FE),
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
                                    tr.isArabic
                                        ? widget.distance
                                            .replaceAll('km', 'كم')
                                            .replaceAll('min', 'د')
                                        : widget.distance,
                                    style: tr.font(
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
                                            'live_tracking_back_button'),
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
                                    const SizedBox(width: 16.0), // gap: 16px;

                                    // Title: Pickup & Delivery
                                    Expanded(
                                      child: Text(
                                        tr.categoryName(widget.serviceCategory),
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

                                    // Live pulse status badge
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
                                            tr.liveBadge,
                                            style: tr.font(
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

                      // 8. Main Card Widget (Live Tracking Card):
                      // width: 390; height: 336; top: 508px;
                      // border-top-left-radius: 28px; border-top-right-radius: 28px;
                      // angle: 0 deg; opacity: 1; background: #FFFFFF;
                      // box-shadow: 0px -2px 12px 0px #00000014;
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
                            const SizedBox(height: 16.0),

                            // content layout:
                            // width: 350; height: 268.79998779296875; top: 12px; left: 20px; gap: 20px;
                            SizedBox(
                              width: containerWidth >= 390
                                  ? 350.0
                                  : (containerWidth - 40.0).clamp(280.0, 350.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // content inner layout:
                                  // width: 350; height: 244.8000030517578; gap: 20px;
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
                                                    const SizedBox(width: 16.0), // gap: 16px;

                                                    // content layout: Flexible responsive provider details
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          // content inner: responsive row
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              // content: Ahmad Transport
                                                              Flexible(
                                                                child: Text(
                                                                  tr.formatProviderName(widget.providerName),
                                                                  style: tr.font(
                                                                    fontSize:
                                                                        14.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: const Color(
                                                                        0xFF1C2926),
                                                                    height: 1.2,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 8.0),

                                                              // On the way badge
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
                                                                      0xFFF0EAFE),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              60.0),
                                                                ),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                  tr.onTheWay,
                                                                  style: tr.font(
                                                                    fontSize:
                                                                        10.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: const Color(
                                                                        0xFF8B53FE),
                                                                    height: 1.2,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),

                                                          const SizedBox(height: 4.0),

                                                          // 2nd row: EAT 8 min
                                                          Text.rich(
                                                            TextSpan(
                                                              text: tr.eatEta,
                                                              style:
                                                                  tr.font(
                                                                fontSize: 11.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: const Color(
                                                                    0xFF566663),
                                                                height: 1.2,
                                                                letterSpacing:
                                                                    0.0,
                                                              ),
                                                              children: [
                                                                TextSpan(
                                                                  text: tr.isArabic
                                                                      ? widget.duration.replaceAll('min', 'دقيقة').replaceAll('m', 'د')
                                                                      : widget.duration,
                                                                  style:
                                                                      tr.font(
                                                                    fontSize:
                                                                        11.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: const Color(
                                                                        0xFF8B53FE),
                                                                    height: 1.2,
                                                                    letterSpacing:
                                                                        0.0,
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

                                              // right side branding:
                                              // width: 84; height: 36; gap: 12px;
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
                                                            'live_tracking_whatsapp_button'),
                                                        onTap: () {
                                                          HapticFeedback
                                                              .lightImpact();
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                tr.openingWhatsApp,
                                                                style: tr.font(color: Colors.white),
                                                              ),
                                                              duration: const Duration(
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
                                                    const SizedBox(
                                                        width: 12.0), // gap: 12px;

                                                    // Call button
                                                    MouseRegion(
                                                      cursor: SystemMouseCursors
                                                          .click,
                                                      child: GestureDetector(
                                                        key: const Key(
                                                            'live_tracking_call_button'),
                                                        onTap: () {
                                                          HapticFeedback
                                                              .lightImpact();
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                tr.callingProvider(
                                                                    tr.formatProviderName(
                                                                        widget.providerName)),
                                                                style: tr.font(
                                                                    color: Colors.white),
                                                              ),
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

                                        const SizedBox(height: 16.0), // gap: 16px;

                                        // Divider line matching screenshot
                                        Container(
                                          width: containerWidth >= 390
                                              ? 350.0
                                              : (containerWidth - 40.0).clamp(280.0, 350.0),
                                          height: 1.0,
                                          color: const Color(0xFFF3F4F6),
                                        ),

                                        const SizedBox(height: 16.0), // gap: 16px;

                                        // 2nd row: Toyota Hilux & Pickup & Delivery
                                        // width: 350; height: 10; justify-content: space-between; angle: 0 deg; opacity: 1;
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
                                                  // car icon branding: width: 12; height: 10; background: #1C2926;
                                                  const Icon(
                                                    Icons.directions_car_filled_rounded,
                                                    size: 14.0,
                                                    color: Color(0xFF1C2926),
                                                  ),
                                                  const SizedBox(width: 12.0), // gap: 12px;

                                                  // text branding: width: 182; height: 9; gap: 12px;
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.center,
                                                    children: [
                                                      // content: Toyota Hilux
                                                      Text(
                                                        tr.formatVehicleName('Toyota Hilux'),
                                                        style: tr.font(
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: const Color(
                                                              0xFF1C2926),
                                                          height: 22.0 / 12.0,
                                                          letterSpacing: 0.0,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12.0), // gap: 12px;

                                                      // content: Pickup & Delivery
                                                      Text(
                                                        tr.categoryName(widget.serviceCategory),
                                                        style: tr.font(
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

                                        const SizedBox(height: 16.0), // gap: 16px;

                                        // 3rd section: metric cards row (3.8 km Distance Away & 6 min Estimated time)
                                        // width: 350; height: 64; gap: 12px;
                                        SizedBox(
                                          width: containerWidth >= 390
                                              ? 350.0
                                              : (containerWidth - 40.0).clamp(280.0, 350.0),
                                          child: Row(
                                            children: [
                                              // 1st card branding: 3.8 km Distance Away
                                              Expanded(
                                                child: Container(
                                                  constraints: const BoxConstraints(minHeight: 56.0),
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
                                                      // left side icon branding: width: 32; height: 32; border-radius: 60px; background: #E2F0E6;
                                                      Container(
                                                        width: 32.0,
                                                        height: 32.0,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Color(0xFFF0EAFE),
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
                                                                  0xFF8B53FE),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12.0), // gap: 12px;

                                                      // inner card content right side:
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            // content: 3.8 km
                                                            FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              alignment: AlignmentDirectional
                                                                  .centerStart,
                                                              child: Text(
                                                                tr.threePointEightKm,
                                                                style:
                                                                    tr.font(
                                                                  fontSize:
                                                                      14.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: const Color(
                                                                      0xFF1C2926),
                                                                  height: 1.2,
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
                                                              alignment: AlignmentDirectional
                                                                  .centerStart,
                                                              child: Text(
                                                                tr.distanceAway,
                                                                style:
                                                                    tr.font(
                                                                  fontSize:
                                                                      10.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: const Color(
                                                                      0xFF566663),
                                                                  height: 1.2,
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
                                              const SizedBox(width: 12.0), // gap: 12px;

                                              // 2nd card branding: 6 min Estimated time
                                              Expanded(
                                                child: Container(
                                                  constraints: const BoxConstraints(minHeight: 56.0),
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
                                                      // left side icon branding: width: 32; height: 32; border-radius: 60px; background: #E2F0E6;
                                                      Container(
                                                        width: 32.0,
                                                        height: 32.0,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Color(0xFFF0EAFE),
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
                                                                      0xFF8B53FE),
                                                              handColor:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12.0), // gap: 12px;

                                                      // inner card content right side:
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            // content: 6 min
                                                            FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              alignment: AlignmentDirectional
                                                                  .centerStart,
                                                              child: Text(
                                                                tr.sixMin,
                                                                style:
                                                                    tr.font(
                                                                  fontSize:
                                                                      14.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: const Color(
                                                                      0xFF1C2926),
                                                                  height: 1.2,
                                                                  letterSpacing:
                                                                      0.0,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 2.0),

                                                            // content: Estimated time
                                                            FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              alignment: AlignmentDirectional
                                                                  .centerStart,
                                                              child: Text(
                                                                tr.estimatedTime,
                                                                style:
                                                                    tr.font(
                                                                  fontSize:
                                                                      10.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: const Color(
                                                                      0xFF566663),
                                                                  height: 1.2,
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

                                        const SizedBox(height: 12.0), // gap: 12px;

                                        // 4th section: Driver location updating card layout:
                                        // width: 350; height: 64; angle: 0 deg; opacity: 1; gap: 12px;
                                        // border-radius: 12px; padding: 16px; background: #F2F5F4;
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
                                              // left side icon branding of rotation:
                                              // width: 32; height: 32; angle: 0 deg; opacity: 1; border-radius: 60px; background: #DDF0E3;
                                              Container(
                                                width: 32.0,
                                                height: 32.0,
                                                decoration:
                                                    const BoxDecoration(
                                                  color: Color(0xFFF0EAFE),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Center(
                                                  // ellipse inner branding of rotation:
                                                  // width: 24; height: 24; top: 3.6px; left: 4px; background: #1D8070;
                                                  child: SizedBox(
                                                    width: 18.0,
                                                    height: 18.0,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2.2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        Color(0xFF8B53FE),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                  width: 12.0), // gap: 12px;

                                              // right side content layout:
                                              // width: 274; height: 31; gap: 12px;
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    // content: Driver location updating...
                                                    Text(
                                                      tr.driverLocationUpdating,
                                                      style: tr.font(
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

                                                    // content: You’ll see live movement on the map
                                                    Text(
                                                      tr.liveMovementOnMap,
                                                      style: tr.font(
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
