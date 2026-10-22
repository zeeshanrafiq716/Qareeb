import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_locale.dart';
import 'send_location_screen.dart';
import 'send_request_screen.dart';
import 'widgets/top_down_car_widget.dart';

/// Screen displayed when user clicks on a provider card.
/// We proceed step by step following Figma manual branding specifications.
class ProviderDetailScreen extends ConsumerStatefulWidget {
  final String serviceCategory;
  final String providerName;

  const ProviderDetailScreen({
    super.key,
    this.serviceCategory = 'Pickup & Delivery',
    this.providerName = 'Ahmad Raza',
  });

  @override
  ConsumerState<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends ConsumerState<ProviderDetailScreen> {
  AppTranslations get tr => ref.read(translationsProvider);

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
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
            final double containerWidth = isDesktopWeb ? 390.0 : constraints.maxWidth;
            final double containerHeight = isDesktopWeb
                ? math.min(844.0, (constraints.maxHeight - 32.0).clamp(520.0, 844.0))
                : constraints.maxHeight;

            final screenContent = ScrollConfiguration(
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
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: SizedBox(
                  width: containerWidth,
                  height: math.max(844.0, containerHeight),
                  child: Stack(
                    children: [
                  // 1. Background Map Layer ("use map img"):
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/img.png',
                      width: containerWidth,
                      height: containerHeight,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/BG image.png',
                        width: containerWidth,
                        height: containerHeight,
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

                  // 2. Gradient Overlay Layer ("pickup & delivery screen layout branding"):
                  // width: 390; height: 843; top: 1px; angle: 0 deg; opacity: 1;
                  // background: linear-gradient(180deg, #FFFFFF 2.14%, rgba(255, 255, 255, 0.839534) 17.05%, rgba(255, 255, 255, 0) 26.93%);
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
                  // width: 145.5; height: 91; angle: 0 deg; top: 183px; left: 116.5px; border: 4px solid #8B53FE;
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
                    child: TopDownCarWidget(
                      width: 16.5,
                      height: 28.5,
                      angle: -60.0,
                      driverName: widget.providerName,
                      distanceKm: 1.8,
                      showBadge: true,
                      bodyColor: const Color(0xFFA67AFE),
                    ),
                  ),

                  // 5. Location Marker Halo & Pin Branding:
                  // Outer soft glowing purple halo rings:
                  Positioned(
                    top: 153.0 - 12.0,
                    left: (111.0 - 12.0) + ((containerWidth - 390.0) / 2.0),
                    width: 60.0,
                    height: 56.0,
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

                  // location icon branding:
                  // width: 36; height: 36; gap: 10px; angle: 0 deg; opacity: 1; border-radius: 40px;
                  // padding: 4px; top: 153px; left: 111px; background: #F0EAFE; box-shadow: 0px 0px 4px 0px #8B53FE40 inset;
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
                        boxShadow: const [
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
                  // distance badge branding: width: 42; height: 26; angle: 0 deg; top: 124px; left: 119px; background: #8B53FE;
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
                          tr.onePointEightKm,
                          textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
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
                              key: const Key('provider_detail_back_button'),
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
                                height: 1.15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 8. Card Widget Branding:
                  // width: 390; height: 458; angle: 0 deg; opacity: 1; top: 386px;
                  // border-top-left-radius: 28px; border-top-right-radius: 28px;
                  // background: #FFFFFF; box-shadow: 0px -2px 12px 0px #00000014;
                  Positioned(
                    top: 386.0,
                    left: containerWidth >= 390
                        ? ((containerWidth - 390.0) / 2.0)
                        : 0.0,
                    width: containerWidth >= 390 ? 390.0 : containerWidth,
                    height: 458.0,
                    child: Container(
                      width: containerWidth >= 390 ? 390.0 : containerWidth,
                      height: 458.0,
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
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Card top indicator handle
                          Positioned(
                            top: 12.0,
                            left: (((containerWidth >= 390 ? 390.0 : containerWidth) - 40.0) / 2.0),
                            width: 40.0,
                            height: 4.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                            ),
                          ),

                          // content layout:
                          // width: 350; height: 366.79998779296875; gap: 16px; angle: 0 deg; opacity: 1; top: 36px; left: 19px;
                          Positioned(
                            top: 36.0,
                            bottom: 32.0,
                            left: (containerWidth >= 390)
                                ? 19.0
                                : (((containerWidth - 350.0) / 2.0).clamp(10.0, 19.0)),
                            width: (containerWidth >= 390)
                                ? 350.0
                                : (containerWidth - 38.0).clamp(280.0, 350.0),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                // 1st row designing:
                                // width: 350; height: 40; justify-content: space-between; angle: 0 deg; opacity: 1;
                                SizedBox(
                                  width: (containerWidth >= 390)
                                      ? 350.0
                                      : (containerWidth - 38.0).clamp(280.0, 350.0),
                                  height: 40.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // left side content layout:
                                      // width: 228; height: 40; gap: 16px; angle: 0 deg; opacity: 1;
                                      SizedBox(
                                        width: 228.0,
                                        height: 40.0,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            // img layout:
                                            // width: 36; height: 36; angle: 0 deg; opacity: 1;
                                            Container(
                                              width: 36.0,
                                              height: 36.0,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFFFFAAA6),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              child: Image.network(
                                                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&auto=format&fit=crop&q=80',
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

                                            // content layout:
                                            // width: 176; height: 40; gap: 12px; angle: 0 deg; opacity: 1;
                                            SizedBox(
                                              width: 176.0,
                                              height: 40.0,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  // content 1st row branding:
                                                  // width: 176; height: 18; gap: 12px; angle: 0 deg; opacity: 1;
                                                  SizedBox(
                                                    width: 176.0,
                                                    height: 18.0,
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        // content: Ahmad Transport
                                                        // width: 117; height: 10; font-family: Inter; font-weight: 500; font-size: 14px; line-height: 22px; color: #1C2926;
                                                        Expanded(
                                                          child: FittedBox(
                                                            fit: BoxFit.scaleDown,
                                                            alignment: AlignmentDirectional.centerStart,
                                                            child: Text(
                                                              tr.formatProviderName(widget.providerName),
                                                              style: tr.font(
                                                                fontSize: 14.0,
                                                                fontWeight: FontWeight.w500,
                                                                color: const Color(0xFF1C2926),
                                                                height: 1.15,
                                                              ),
                                                              maxLines: 1,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12.0), // gap: 12px;

                                                        // available badge layout:
                                                        // width: 47; height: 18; gap: 10px; border-radius: 60px; padding: 6px; background: #F0F5F2;
                                                        // content: Available (width: 35; height: 6; font-family: Inter; font-weight: 500; font-size: 8px; line-height: 22px; color: #1D8070)
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                                          constraints: const BoxConstraints(minWidth: 47.0),
                                                          height: 18.0,
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFFF0EAFE),
                                                            borderRadius: BorderRadius.circular(60.0),
                                                          ),
                                                          alignment: Alignment.center,
                                                          child: Text(
                                                            tr.isArabic ? 'متاح' : 'Available',
                                                            style: tr.font(
                                                              fontSize: 8.0,
                                                              fontWeight: FontWeight.w500,
                                                              color: const Color(0xFF8B53FE),
                                                              height: 1.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // review and counter branding:
                                                  // width: 80; height: 10; gap: 8px; angle: 0 deg; opacity: 1;
                                                  SizedBox(
                                                    width: 80.0,
                                                    height: 10.0,
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        // star branding: width: 10; height: 10; border-radius: 0.4px; background: #1D8070;
                                                        const Icon(
                                                          Icons.star_rounded,
                                                          size: 10.0,
                                                          color: Color(0xFF8B53FE),
                                                        ),
                                                        const SizedBox(width: 8.0), // gap: 8px;

                                                        // content: 4.9 (120 trips)
                                                        // width: 66; height: 7; font-family: Inter; font-weight: 400; font-size: 10px; line-height: 22px; color: #566663
                                                        Expanded(
                                                          child: FittedBox(
                                                            fit: BoxFit.scaleDown,
                                                            alignment: AlignmentDirectional.centerStart,
                                                            child: Text(
                                                              tr.isArabic ? '4.9 (120 رحلة)' : '4.9 (120 trips)',
                                                              style: tr.font(
                                                                fontSize: 10.0,
                                                                fontWeight: FontWeight.w400,
                                                                color: const Color(0xFF566663),
                                                                height: 1.0,
                                                              ),
                                                              maxLines: 1,
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

                                      // right side icons layout:
                                      // width: 84; height: 36; gap: 12px; angle: 0 deg; opacity: 1;
                                      SizedBox(
                                        width: 84.0,
                                        height: 36.0,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            // wtsap icon branding:
                                            // width: 36; height: 36; angle: 0 deg; opacity: 1; border-radius: 60px; background: #25D366;
                                            MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                key: const Key('provider_detail_whatsapp_button'),
                                                onTap: () {
                                                  HapticFeedback.lightImpact();
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        tr.openingWhatsApp,
                                                        style: tr.font(color: Colors.white),
                                                      ),
                                                      duration: const Duration(seconds: 1),
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

                                            // call icon branding:
                                            // width: 36; height: 36; angle: 0 deg; opacity: 1; border-radius: 60px; background: #1C2926;
                                            MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                key: const Key('provider_detail_call_button'),
                                                onTap: () {
                                                  HapticFeedback.lightImpact();
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        tr.callingProvider(tr.formatProviderName(widget.providerName)),
                                                        style: tr.font(color: Colors.white),
                                                      ),
                                                      duration: const Duration(seconds: 1),
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

                                // 2nd row: next widget branding:
                                // width: 350; height: 10; justify-content: space-between; angle: 0 deg; opacity: 1;
                                SizedBox(
                                  width: (containerWidth >= 390)
                                      ? 350.0
                                      : (containerWidth - 38.0).clamp(280.0, 350.0),
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
                                                tr.formatVehicleName('Toyota Hilux'),
                                                style: tr.font(
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
                                                tr.categoryName(widget.serviceCategory),
                                                style: tr.font(
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

                                // 3rd section: next widget styling (metric cards grid):
                                // width: 350; height: 136; gap: 12px; angle: 0 deg; opacity: 1;
                                Container(
                                  width: (containerWidth >= 390)
                                      ? 350.0
                                      : (containerWidth - 38.0).clamp(280.0, 350.0),
                                  constraints: const BoxConstraints(minHeight: 136.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 1st row of metric cards:
                                      Row(
                                        children: [
                                          // 1st card branding: 1.8 km Distance Away
                                          // width: 169 (flexible on mobile); height: 64; gap: 12px;
                                          Expanded(
                                            child: Container(
                                              constraints: const BoxConstraints(minHeight: 56.0),
                                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF2F5F4),
                                                borderRadius: BorderRadius.circular(12.0),
                                              ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                // icon syling on left side:
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
                                                        alignment: AlignmentDirectional.centerStart,
                                                        child: Text(
                                                          tr.onePointEightKm,
                                                          style: tr.font(
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
                                                        alignment: AlignmentDirectional.centerStart,
                                                        child: Text(
                                                          tr.distanceAway,
                                                          style: tr.font(
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
                                            constraints: const BoxConstraints(minHeight: 56.0),
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
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
                                                        alignment: AlignmentDirectional.centerStart,
                                                        child: Text(
                                                          tr.sixMin,
                                                          style: tr.font(
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
                                                        alignment: AlignmentDirectional.centerStart,
                                                        child: Text(
                                                          tr.estimatedTime,
                                                          style: tr.font(
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
                                        width: (containerWidth >= 390)
                                            ? 350.0
                                            : (containerWidth - 38.0).clamp(280.0, 350.0),
                                        constraints: const BoxConstraints(minHeight: 58.0),
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF2F5F4),
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            // left side content:
                                            Expanded(
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  // icon on left side branding:
                                                  Container(
                                                    width: 28.0,
                                                    height: 28.0,
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFFF0EAFE),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Center(
                                                      child: CustomPaint(
                                                        size: Size(14.0, 16.0),
                                                        painter: _VerifiedShieldPainter(
                                                          shieldColor: Color(0xFF8B53FE),
                                                          checkColor: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8.0),

                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          alignment: AlignmentDirectional.centerStart,
                                                          child: Text(
                                                            tr.verified,
                                                            maxLines: 1,
                                                            textHeightBehavior: const TextHeightBehavior(
                                                              applyHeightToFirstAscent: false,
                                                              applyHeightToLastDescent: false,
                                                            ),
                                                            style: tr.font(
                                                              fontSize: 12.0,
                                                              fontWeight: FontWeight.w500,
                                                              color: const Color(0xFF1C2926),
                                                              height: 1.1,
                                                              letterSpacing: 0.0,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 1.0),

                                                        FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          alignment: AlignmentDirectional.centerStart,
                                                          child: Text(
                                                            tr.providersLabel,
                                                            maxLines: 1,
                                                            textHeightBehavior: const TextHeightBehavior(
                                                              applyHeightToFirstAscent: false,
                                                              applyHeightToLastDescent: false,
                                                            ),
                                                            style: tr.font(
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
                                            Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                              width: 0.8,
                                              height: 24.0,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEDF0E9),
                                                borderRadius: BorderRadius.circular(40.0),
                                              ),
                                            ),

                                            // center content:
                                            Expanded(
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 28.0,
                                                    height: 28.0,
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFFF0EAFE),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.group_rounded,
                                                        size: 16.0,
                                                        color: Color(0xFF8B53FE),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8.0),

                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          alignment: AlignmentDirectional.centerStart,
                                                          child: Text(
                                                            '500+',
                                                            maxLines: 1,
                                                            textHeightBehavior: const TextHeightBehavior(
                                                              applyHeightToFirstAscent: false,
                                                              applyHeightToLastDescent: false,
                                                            ),
                                                            style: tr.font(
                                                              fontSize: 12.0,
                                                              fontWeight: FontWeight.w500,
                                                              color: const Color(0xFF1C2926),
                                                              height: 1.1,
                                                              letterSpacing: 0.0,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 1.0),

                                                        FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          alignment: AlignmentDirectional.centerStart,
                                                          child: Text(
                                                            tr.deliveriesLabel,
                                                            maxLines: 1,
                                                            textHeightBehavior: const TextHeightBehavior(
                                                              applyHeightToFirstAscent: false,
                                                              applyHeightToLastDescent: false,
                                                            ),
                                                            style: tr.font(
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
                                            Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                              width: 0.8,
                                              height: 24.0,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEDF0E9),
                                                borderRadius: BorderRadius.circular(40.0),
                                              ),
                                            ),

                                            // right content layout:
                                            Expanded(
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
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
                                                  const SizedBox(width: 8.0),

                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          alignment: AlignmentDirectional.centerStart,
                                                          child: Text(
                                                            '98%',
                                                            maxLines: 1,
                                                            textHeightBehavior: const TextHeightBehavior(
                                                              applyHeightToFirstAscent: false,
                                                              applyHeightToLastDescent: false,
                                                            ),
                                                            style: tr.font(
                                                              fontSize: 12.0,
                                                              fontWeight: FontWeight.w500,
                                                              color: const Color(0xFF1C2926),
                                                              height: 1.1,
                                                              letterSpacing: 0.0,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 1.0),

                                                        FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          alignment: AlignmentDirectional.centerStart,
                                                          child: Text(
                                                            tr.onTime,
                                                            maxLines: 1,
                                                            textHeightBehavior: const TextHeightBehavior(
                                                              applyHeightToFirstAscent: false,
                                                              applyHeightToLastDescent: false,
                                                            ),
                                                            style: tr.font(
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

                                // 4th section: next widget layout (buttons):
                                // width: 350; height: 116; gap: 12px; angle: 0 deg; opacity: 1;
                                SizedBox(
                                  width: (containerWidth >= 390)
                                      ? 350.0
                                      : (containerWidth - 38.0).clamp(280.0, 350.0),
                                  height: 116.0,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // button layout:
                                      // width: 350; height: 52; angle: 0 deg; opacity: 1; border-radius: 12px; background: #F2F5F4;
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          key: const Key('provider_detail_send_location_button'),
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => SendLocationScreen(serviceCategory: widget.serviceCategory, providerName: widget.providerName)));
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Container(
                                            width: (containerWidth >= 390)
                                                ? 350.0
                                                : (containerWidth - 38.0).clamp(280.0, 350.0),
                                            height: 52.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF2F5F4),
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                // left icon branding:
                                                // width: 16; height: 16; angle: 0 deg; opacity: 1; background: #1C2926;
                                                const CustomPaint(
                                                  size: Size(14.0, 16.0),
                                                  painter: _LocationPinPainter(
                                                    color: Color(0xFF1C2926),
                                                  ),
                                                ),
                                                const SizedBox(width: 10.0), // gap: 10px;

                                                // content: Send My Location
                                                // width: 121; height: 10; font-family: Inter; font-weight: 500; font-size: 14px; line-height: 22px; color: #1C2926;
                                                Text(
                                                  tr.sendMyLocation,
                                                  style: tr.font(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color(0xFF1C2926),
                                                    height: 1.1,
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      // 2nd button layout:
                                      // width: 350; height: 52; angle: 0 deg; opacity: 1; border-radius: 12px; background: #1D8070;
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          key: const Key('provider_detail_send_request_button'),
                                          onTap: () {
                                            HapticFeedback.mediumImpact();
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => SendRequestScreen(
                                                  serviceCategory: widget.serviceCategory,
                                                  providerName: widget.providerName,
                                                  distance: tr.onePointEightKm,
                                                ),
                                              ),
                                            );
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Container(
                                            width: (containerWidth >= 390)
                                                ? 350.0
                                                : (containerWidth - 38.0).clamp(280.0, 350.0),
                                            height: 52.0,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF8B53FE),
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                // content: Send Request
                                                // width: 94; height: 10; font-family: Inter; font-weight: 500; font-size: 14px; line-height: 22px; color: #FFFFFF;
                                                Text(
                                                  tr.sendRequest,
                                                  style: tr.font(
                                                    fontSize: 14.0,
                                                    fontWeight: FontWeight.w500,
                                                    color: const Color(0xFFFFFFFF),
                                                    height: 1.1,
                                                    letterSpacing: 0.0,
                                                  ),
                                                ),
                                                const SizedBox(width: 10.0), // gap: 10px;

                                                // right side icon layout:
                                                // arrow vector: width: 14; height: 12; angle: -180 deg; border-width: 1.5px; border: 1.5px solid #FFFFFF;
                                                Transform.scale(
                                                  scaleX: tr.isArabic ? -1.0 : 1.0,
                                                  child: const CustomPaint(
                                                    size: Size(14.0, 12.0),
                                                    painter: _ArrowRightPainter(
                                                      color: Color(0xFFFFFFFF),
                                                      strokeWidth: 1.5,
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
                                const SizedBox(height: 24.0),
                              ],
                            ),
                          ),
                        ),

                        // Bottom Bar Layout: width: 390; height: 24;
                        Positioned(
                          bottom: 8.0,
                          left: 0.0,
                          width: containerWidth >= 390 ? 390.0 : containerWidth,
                          height: 24.0,
                          child: Center(
                            // Bar branding: width: 134; height: 4; border-radius: 100px; background: #1C2926;
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

/// Back chevron vector < matching Figma specifications exactly:
/// width: 6; height: 13; border: 1px solid #566663
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
/// width: 145.5; height: 91; border-width: 4px; border: 4px solid #1D8070;
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
    // Starts directly beneath the location pin (pin center is x ~ 12.5)
    path.moveTo(12.5, 0.0);
    // Heads down-left to intersection corner
    path.lineTo(2.0, 18.0);
    // Smooth corner turn into the avenue
    path.quadraticBezierTo(2.0, 24.0, 8.0, 27.0);
    // Straight diagonal run southeast towards the car
    path.lineTo(size.width - 2.0, size.height - 4.0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RouteVectorPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}

/// Top-down car graphic painter matching Figma car asset:
/// width: 15; height: 24;
class _CarGraphicPainter extends CustomPainter {
  final Color roofColor;
  const _CarGraphicPainter({this.roofColor = const Color(0xFFA67AFE)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Car body paint (white with subtle border)
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

    // Front Windshield (dark glass)
    final glassPaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.fill;

    final windshieldRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3.0, 5.0, w - 6.0, 3.5),
      const Radius.circular(1.0),
    );
    canvas.drawRRect(windshieldRect, glassPaint);

    // Roof (brand teal)
    final roofPaint = Paint()
      ..color = roofColor
      ..style = PaintingStyle.fill;

    final roofRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3.2, 9.0, w - 6.4, 7.0),
      const Radius.circular(1.0),
    );
    canvas.drawRRect(roofRect, roofPaint);

    // Rear Windshield (dark glass)
    final rearGlassRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3.0, 16.5, w - 6.0, 2.5),
      const Radius.circular(1.0),
    );
    canvas.drawRRect(rearGlassRect, glassPaint);

    // Taillights (red accents at bottom)
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

    // Headlights (subtle white/cyan at top)
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

/// Location pin icon vector matching Figma icon inside 36x36 circular button:
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
/// width: 42; height: 26; angle: 0 deg; top: 124px; left: 119px; background: #1D8070;
/// inner body: width: 42; height: 19; border-radius: 4px; padding: 6px;
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

    final bodyHeight = size.height - pointerHeight; // 26 - 7 = 19px
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, bodyHeight),
      Radius.circular(cornerRadius),
    );

    final path = Path()..addRRect(rrect);

    // Pointer pointing downward towards the location pin
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


/// Arrow vector painter matching Figma specifications:
/// width: 14; height: 12; angle: -180 deg; border-width: 1.5px; border: 1.5px solid #FFFFFF;
class _ArrowRightPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _ArrowRightPainter({
    this.color = Colors.white,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final path = Path();
    final double midY = size.height / 2.0;

    // Horizontal stem
    path.moveTo(1.0, midY);
    path.lineTo(size.width - 1.5, midY);

    // Arrowhead chevron pointing forward / right
    path.moveTo(size.width - 5.5, 1.5);
    path.lineTo(size.width - 1.5, midY);
    path.lineTo(size.width - 5.5, size.height - 1.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowRightPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}



