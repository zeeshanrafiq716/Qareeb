import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Screen displayed when user clicks 'Send My Location' on the Provider Detail screen.
/// Implements the pickup & delivery header and map navigation with identical branding.
class SendLocationScreen extends ConsumerStatefulWidget {
  final String serviceCategory;
  final String providerName;
  final String distance;

  const SendLocationScreen({
    super.key,
    this.serviceCategory = 'Pickup & Delivery',
    this.providerName = 'Ahamd Transport',
    this.distance = '1.8 km',
  });

  @override
  ConsumerState<SendLocationScreen> createState() => _SendLocationScreenState();
}

class _SendLocationScreenState extends ConsumerState<SendLocationScreen> {
  int _selectedShareIndex = 0;
  bool _isCardExpanded = true;

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

            // Responsive framing: Desktop web or wide tablet gets simulated iPhone frame (390 x 844)
            final isDesktopWeb = screenWidth > 600;
            final containerWidth = isDesktopWeb ? 390.0 : screenWidth;
            final containerHeight = isDesktopWeb
                ? math.min(844.0, (screenHeight - 32.0).clamp(520.0, 844.0))
                : screenHeight;

            final Widget screenContent = ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false,
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.invertedStylus,
                  PointerDeviceKind.unknown,
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
                      // Top Map Section (expanded: 283.0 to match Figma top: 283px branding; collapsed: expands for full map view)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeInOutCubic,
                        width: containerWidth,
                        height: _isCardExpanded
                            ? 283.0
                            : (containerHeight - 120.0).clamp(283.0, 900.0),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                      // 1. Background Map Layer ("use map img"):
                      Positioned.fill(
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

                      // 2. Gradient Overlay Layer ("pickup & delivery screen layout branding"):
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
                            color: Color(0xFF1D8070),
                            strokeWidth: 4.0,
                          ),
                        ),
                      ),

                      // 4. Car Branding:
                      // width: 15; height: 24; angle: 60 deg; top: 250px; left: 236px;
                      Positioned(
                        top: 250.0,
                        left: 236.0 + ((containerWidth - 390.0) / 2.0),
                        width: 15.0,
                        height: 24.0,
                        child: Transform.rotate(
                          angle: -60.0 * math.pi / 180.0,
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/car.png',
                            width: 15.0,
                            height: 24.0,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const CustomPaint(
                              size: Size(15.0, 24.0),
                              painter: _CarGraphicPainter(
                                roofColor: Color(0xFF1D8070),
                              ),
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
                            color: const Color(0xFF1D8070).withValues(alpha: 0.12),
                            border: Border.all(
                              color: const Color(0xFF1D8070).withValues(alpha: 0.22),
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
                            color: const Color(0xFF1D8070).withValues(alpha: 0.18),
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
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF0FFF7),
                            boxShadow: const [
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
                                child: Icon(
                                  Icons.location_on_rounded,
                                  size: 16.0,
                                  color: Colors.white,
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
                            color: Color(0xFF1D8070),
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
                                  key: const Key('send_location_back_button'),
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

                      // 8. Sharing Card Branding:
                      // width: 390; height: 561; angle: 0 deg; opacity: 1; top: 283px;
                      // Reduced border radius from corners (16px / 12px) for sleek, refined modern look
                      Container(
                        width: containerWidth >= 390 ? 390.0 : containerWidth,
                        height: _isCardExpanded ? 561.0 : null,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                            bottomRight: Radius.circular(16.0),
                            bottomLeft: Radius.circular(12.0),
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
                        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Top header with centered drag handle
                            _buildCardHeader(containerWidth),

                            const SizedBox(height: 6.0),

                            // Expandable / Collapsible Body with AnimatedCrossFade
                            AnimatedCrossFade(
                              firstChild: _buildExpandedCardBody(containerWidth),
                              secondChild: _buildCollapsedCardBody(containerWidth),
                              crossFadeState: _isCardExpanded
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                              duration: const Duration(milliseconds: 300),
                              firstCurve: Curves.easeInOutCubic,
                              secondCurve: Curves.easeInOutCubic,
                              sizeCurve: Curves.easeInOutCubic,
                            ),
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

  /// Card top header with centered drag handle
  Widget _buildCardHeader(double containerWidth) {
    final double targetWidth = (containerWidth >= 390)
        ? 350.0
        : (containerWidth - 40.0).clamp(280.0, 350.0);

    return SizedBox(
      width: targetWidth,
      height: 16.0,
      child: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _isCardExpanded = !_isCardExpanded;
            });
          },
          child: Container(
            width: 44.0,
            height: 4.5,
            decoration: BoxDecoration(
              color: const Color(0xFFDDE3E1),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
        ),
      ),
    );
  }

  /// Collapsed mini card body for maximum map visibility
  Widget _buildCollapsedCardBody(double containerWidth) {
    final double targetWidth = (containerWidth >= 390)
        ? 350.0
        : (containerWidth - 40.0).clamp(280.0, 350.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _isCardExpanded = true;
        });
      },
      child: SizedBox(
        width: targetWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  // Mini location pin badge
                  Container(
                    width: 38.0,
                    height: 38.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEBFFF4),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 20.0,
                        color: Color(0xFF1D8070),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  // Summary text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Share your location?',
                          style: GoogleFonts.inter(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1C2926),
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          'Tap or swipe up to view options',
                          style: GoogleFonts.inter(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF566663),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Distance pill badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D8070),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      widget.distance,
                      style: GoogleFonts.inter(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12.0),
            // Bottom Home Indicator
            Container(
              width: 134.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: const Color(0xFF1C2926),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Full expanded card body with all sharing options and action buttons
  Widget _buildExpandedCardBody(double containerWidth) {
    final double targetWidth = (containerWidth >= 390)
        ? 350.0
        : (containerWidth - 40.0).clamp(280.0, 350.0);

    return SizedBox(
      width: targetWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Location Pin Icon Avatar (matching screenshot: 60x60 green circle with teal pin)
          Container(
            width: 60.0,
            height: 60.0,
            decoration: const BoxDecoration(
              color: Color(0xFFEBFFF4),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 44.0,
                height: 44.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFD4F8E8),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 26.0,
                    color: Color(0xFF1D8070),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12.0),

          // 2. Heading
          Text(
            'Share your location?',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C2926),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4.0),

          // 3. Subtitle
          Text(
            'Share your live location with ${widget.providerName} for faster pickup',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF566663),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10.0),

          // 4. Verified Security Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FFF7),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: const Color(0xFF9FFFCB).withValues(alpha: 0.6),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CustomPaint(
                  size: Size(12.0, 14.0),
                  painter: _VerifiedShieldPainter(
                    shieldColor: Color(0xFF1D8070),
                    checkColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 6.0),
                Text(
                  'End-to-end encrypted • Live tracking active',
                  style: GoogleFonts.inter(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1D8070),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18.0),

          // 5. "Share via" section title
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Share via',
              style: GoogleFonts.inter(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1C2926),
                height: 22.0 / 14.0,
                letterSpacing: 0.0,
              ),
            ),
          ),
          const SizedBox(height: 10.0),

          // 6. Share Options Row (WhatsApp, Copy Link, Instagram)
          _buildShareCardsRow(containerWidth),
          const SizedBox(height: 18.0),

          // 7. Location Details Card & Action Buttons (Cancel / Send Location)
          _buildLocationDetailsAndActions(containerWidth),
          const SizedBox(height: 18.0),

          // 8. Bottom Home Indicator
          Container(
            width: 134.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: const Color(0xFF1C2926),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
        ],
      ),
    );
  }

  /// Row of 3 share options: WhatsApp, Copy Link, Instagram
  /// width: 350; height: 97.5999984741211; gap: 12px;
  Widget _buildShareCardsRow(double containerWidth) {
    return SizedBox(
      width: (containerWidth >= 390)
          ? 350.0
          : (containerWidth - 40.0).clamp(280.0, 350.0),
      height: 97.6,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1st card layout: WhatsApp
          // width: 108.66666412353516; height: 97.5999984741211; gap: 12px;
          _buildShareCard(
            index: 0,
            iconWidget: Container(
              width: 28.0,
              height: 28.0,
              decoration: const BoxDecoration(
                color: Color(0xFF25D366),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CustomPaint(
                  size: Size(16.0, 16.0),
                  painter: _WhatsAppIconPainter(),
                ),
              ),
            ),
            title: 'WhatsApp',
            subtitle: 'Chat & Share',
          ),
          const SizedBox(width: 12.0), // gap: 12px;

          // 2nd card layout: Copy Link
          _buildShareCard(
            index: 1,
            iconWidget: const SizedBox(
              width: 28.0,
              height: 28.0,
              child: Center(
                child: Icon(
                  Icons.link_rounded,
                  size: 26.0,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
            title: 'Copy Link',
            subtitle: 'Copy to share',
          ),
          const SizedBox(width: 12.0), // gap: 12px;

          // 3rd card layout: Instagram
          _buildShareCard(
            index: 2,
            iconWidget: Container(
              width: 26.0,
              height: 26.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7.0),
                gradient: const LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xFFFEDA75), // Yellow
                    Color(0xFFFA7E1E), // Orange
                    Color(0xFFD62976), // Pink
                    Color(0xFF962FBF), // Purple
                    Color(0xFF4F5BD5), // Blue
                  ],
                ),
              ),
              child: const Center(
                child: CustomPaint(
                  size: Size(15.0, 15.0),
                  painter: _InstagramCameraPainter(),
                ),
              ),
            ),
            title: 'Instagram',
            subtitle: 'Share in Dm',
          ),
        ],
      ),
    );
  }

  Widget _buildShareCard({
    required int index,
    required Widget iconWidget,
    required String title,
    required String subtitle,
  }) {
    final bool isSelected = _selectedShareIndex == index;

    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _selectedShareIndex = index;
            });
            if (index == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening WhatsApp to share location...'),
                  duration: Duration(seconds: 1),
                ),
              );
            } else if (index == 1) {
              Clipboard.setData(
                const ClipboardData(text: 'https://qareeb.app/location/live/track-8492'),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location link copied to clipboard!'),
                  duration: Duration(seconds: 1),
                ),
              );
            } else if (index == 2) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening Instagram to share in DM...'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 97.6,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEBFFF4) : const Color(0xFFF2F5F4),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: isSelected ? const Color(0xFF1D8070) : Colors.transparent,
                width: 0.8,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // inner branding icon: width: 28; height: 28;
                SizedBox(
                  width: 28.0,
                  height: 28.0,
                  child: Center(child: iconWidget),
                ),
                const SizedBox(height: 8.0), // gap: 8px;

                // content title: width: 62; height: 9; Inter 12px Medium #1C2926; line-height: 22px;
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
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
                const SizedBox(height: 2.0),

                // content subtitle: width: 62; height: 7; Inter 10px Regular #566663; line-height: 22px;
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    subtitle,
                    textAlign: TextAlign.center,
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
        ),
      ),
    );
  }

  /// Location Details card & Action buttons (Cancel / Send Location)
  /// width: 350; height: 132.82666015625; gap: 20px;
  Widget _buildLocationDetailsAndActions(double containerWidth) {
    final double targetWidth = (containerWidth >= 390)
        ? 350.0
        : (containerWidth - 40.0).clamp(280.0, 350.0);

    return SizedBox(
      width: targetWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // content layou branding (Location Details Card):
          // width: 350; height: 60.82666015625; gap: 12px; border-radius: 12px; padding: 16px; background: #FFFFFF; box-shadow: 0px 1px 12px 0px #0000001A;
          Container(
            width: targetWidth,
            constraints: const BoxConstraints(minHeight: 60.83),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000), // 0px 1px 12px 0px #0000001A
                  blurRadius: 12.0,
                  offset: Offset(0, 1),
                  spreadRadius: 0.0,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // location icon branding:
                // width: 28.82666015625; height: 28.82666015625; border-radius: 54.05px; background: #F0F5F2;
                Container(
                  width: 28.83,
                  height: 28.83,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F5F2),
                    borderRadius: BorderRadius.circular(54.05),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 16.0,
                      color: Color(0xFF1C2926),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0), // gap: 12px;

                // content layout:
                // width: 282; height: 26; gap: 10px;
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // content: Location Details
                      // width: 282; height: 9; font-family: Inter; font-weight: 500; font-size: 12px; line-height: 100%; color: #1C2926;
                      Flexible(
                        child: Text(
                          'Location Details',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                      ),
                      const SizedBox(height: 2.0),

                      // content: King Fahd Road, Al Olaya Riyadh, Saudi Arabia
                      // width: 282; height: 7; font-family: Inter; font-weight: 400; font-size: 10px; line-height: 100%; color: #566663;
                      Flexible(
                        child: Text(
                          'King Fahd Road, Al Olaya Riyadh, Saudi Arabia',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20.0), // gap: 20px;

          // button layout:
          // width: 350; height: 52; gap: 12px;
          SizedBox(
            width: targetWidth,
            height: 52.0,
            child: Row(
              children: [
                // 1st button branding: Cancel
                // width: 169; height: 52; gap: 10px; border-radius: 12px; padding: 16px 53px; background: #F2F5F4;
                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      key: const Key('send_location_cancel_button'),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).maybePop();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 52.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F5F4),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Center(
                          // content: Cancel
                          // width: 47; height: 10; font-family: Inter; font-weight: 500; font-size: 14px; line-height: 22px; color: #1C2926;
                          child: Text(
                            'Cancel',
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
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0), // gap: 12px;

                // 2nd button branding: Send Location
                // width: 169; height: 52; border-radius: 12px; padding: 16px; background: #1D8070;
                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      key: const Key('send_location_submit_button'),
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _handleSendLocation();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 52.0,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D8070),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // icon branding: width: 16; height: 16; background: #FFFFFF;
                            const Icon(
                              Icons.near_me_rounded,
                              size: 16.0,
                              color: Color(0xFFFFFFFF),
                            ),
                            const SizedBox(width: 8.0),

                            // content: Send Location
                            // width: 96; height: 10; font-family: Inter; font-weight: 500; font-size: 14px; line-height: 22px; color: #FFFFFF;
                            Flexible(
                              child: Text(
                                'Send Location',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textHeightBehavior: const TextHeightBehavior(
                                  applyHeightToFirstAscent: false,
                                  applyHeightToLastDescent: false,
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFFFFFFF),
                                  height: 22.0 / 14.0,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  void _handleSendLocation() {
    final String provider =
        widget.providerName.isNotEmpty ? widget.providerName : 'Ahamd Transport';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Location sent successfully to $provider!',
                style: GoogleFonts.inter(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1D8070),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
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
    this.color = const Color(0xFF1D8070),
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
  const _CarGraphicPainter({this.roofColor = const Color(0xFF1D8070)});

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

    final bodyHeight = size.height - pointerHeight; // 26 - 7 = 19px
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, bodyHeight),
      Radius.circular(cornerRadius),
    );

    // Pointer pointing downward towards the location pin
    final pointerPath = Path();
    final halfWidth = pointerWidth / 2.0;
    pointerPath.moveTo(pointerX - halfWidth, bodyHeight - 0.5);
    pointerPath.lineTo(pointerX + halfWidth, bodyHeight - 0.5);
    pointerPath.lineTo(pointerX, size.height);
    pointerPath.close();

    canvas.drawRRect(rrect, paint);
    canvas.drawPath(pointerPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DistanceBadgeTooltipPainter oldDelegate) =>
      color != oldDelegate.color ||
      cornerRadius != oldDelegate.cornerRadius ||
      pointerX != oldDelegate.pointerX ||
      pointerWidth != oldDelegate.pointerWidth ||
      pointerHeight != oldDelegate.pointerHeight;
}

/// Verified shield icon vector painter matching Figma specifications:
/// width: 14; height: 16;
class _VerifiedShieldPainter extends CustomPainter {
  final Color shieldColor;
  final Color checkColor;

  const _VerifiedShieldPainter({
    this.shieldColor = const Color(0xFF1D8070),
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

/// Official WhatsApp vector icon painter matching Figma specifications:
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

    // 2. Inner speech-bubble hole
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



/// Official Instagram glyph camera painter:
class _InstagramCameraPainter extends CustomPainter {
  const _InstagramCameraPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // 1. Camera rounded square body
    final cameraRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, w - 1.0, h - 1.0),
      const Radius.circular(3.8),
    );
    canvas.drawRRect(cameraRRect, strokePaint);

    // 2. Center lens circle
    final cx = w / 2.0;
    final cy = h / 2.0;
    canvas.drawCircle(Offset(cx, cy), 3.0, strokePaint);

    // 3. Small flash dot at top-right
    canvas.drawCircle(Offset(w - 3.2, 3.2), 0.9, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


