import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../home/presentation/widgets/bottom_nav_bar_widget.dart';

/// Requests Tab screen with branding header layout.
/// Hosts the request management view and floating bottom navigation bar.
class RequestsScreen extends StatefulWidget {
  final VoidCallback? onNotificationTap;
  final ValueChanged<int>? onTabSelected;
  final bool showBottomNav;

  const RequestsScreen({
    super.key,
    this.onNotificationTap,
    this.onTabSelected,
    this.showBottomNav = true,
  });

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  ScrollController? _scrollControllerInstance;
  ScrollController get _scrollController =>
      _scrollControllerInstance ??= ScrollController();

  TextEditingController? _searchControllerInstance;
  TextEditingController get _searchController =>
      _searchControllerInstance ??= TextEditingController();

  int? _selectedFilterIndex = 0; // 0: Active, 1: History
  int get _activeFilterIndex => _selectedFilterIndex ?? 0;

  @override
  void initState() {
    super.initState();
    _scrollControllerInstance ??= ScrollController();
    _searchControllerInstance ??= TextEditingController();
  }

  @override
  void dispose() {
    _scrollControllerInstance?.dispose();
    _searchControllerInstance?.dispose();
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
            final bool isDesktopWeb = screenWidth > 500;
            final double containerWidth = isDesktopWeb ? 390.0 : screenWidth;
            final double containerHeight = isDesktopWeb
                ? math.min(844.0, (screenHeight - 32.0).clamp(520.0, 844.0))
                : screenHeight;
            final double horizontalPadding = containerWidth < 360 ? 16.0 : 20.0;

            final Widget screenContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Smooth scroll view for tab content with full mouse, touch & trackpad support
                  Positioned.fill(
                    child: Listener(
                      behavior: HitTestBehavior.translucent,
                      onPointerSignal: (pointerSignal) {
                        if (pointerSignal is PointerScrollEvent && _scrollController.hasClients) {
                          final double target = (_scrollController.offset + pointerSignal.scrollDelta.dy)
                              .clamp(0.0, _scrollController.position.maxScrollExtent);
                          _scrollController.jumpTo(target);
                        }
                      },
                      child: ScrollConfiguration(
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
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          child: SizedBox(
                            width: containerWidth,
                            height: math.max(
                              containerHeight + 140.0,
                              _activeFilterIndex == 1
                                  ? math.max(containerHeight + 140.0, 260.0 + _filteredHistoryItems.length * 135.0 + 140.0)
                                  : 840.0,
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                              // 1. Header Layout:
                              // width: 350; height: 36; top: 56px; left: 20px; justify-content: space-between;
                              Positioned(
                                top: 56.0,
                                left: horizontalPadding,
                                right: horizontalPadding,
                                height: 36.0,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    // Content Layout:
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // content: Requests
                                          // width: 231; height: 12; font-family: Inter; font-weight: 500; font-size: 16px;
                                          // line-height: 22px; color: #1C2926;
                                          Text(
                                            'Requests',
                                            textHeightBehavior:
                                                const TextHeightBehavior(
                                              applyHeightToFirstAscent: false,
                                              applyHeightToLastDescent: false,
                                            ),
                                            style: GoogleFonts.inter(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF1C2926),
                                              height: 1.15,
                                              letterSpacing: 0.0,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2.0),

                                          // content: Track and manage your service requests
                                          // width: 231; height: 9; font-family: Inter; font-weight: 400; font-size: 12px;
                                          // line-height: 22px; color: #566663;
                                          Text(
                                            'Track and manage your service requests',
                                            textHeightBehavior:
                                                const TextHeightBehavior(
                                              applyHeightToFirstAscent: false,
                                              applyHeightToLastDescent: false,
                                            ),
                                            style: GoogleFonts.inter(
                                              fontSize: 12.0,
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

                                    // Right Icon Branding:
                                    // width: 36; height: 36; border: 1px solid #525252; box-shadow: 0px -2px 12px 0px #00000014;
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        key: const Key(
                                            'requests_header_notification_button'),
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          widget.onNotificationTap?.call();
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Container(
                                          width: 36.0,
                                          height: 36.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFFFFFFFF),
                                            border: Border.all(
                                              color: const Color(0xFF525252),
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
                                            child: Icon(
                                              Icons.notifications_none_rounded,
                                              size: 18.0,
                                              color: Color(0xFF525252),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 2. Tabs Branding Layout:
                              // width: 350; height: 52; top: 116px; left: 20px; gap: 12px;
                              Positioned(
                                top: 116.0,
                                left: horizontalPadding,
                                right: horizontalPadding,
                                height: 52.0,
                                child: Row(
                                  children: [
                                    // 1st Button: Active
                                    // width: 169; height: 52; gap: 6px; border-radius: 12px;
                                    // padding-top: 16px; padding-bottom: 16px; background: #1D8070;
                                    Expanded(
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 180),
                                          curve: Curves.easeInOut,
                                          height: 52.0,
                                          decoration: BoxDecoration(
                                            color: _activeFilterIndex == 0
                                                ? const Color(0xFF8B53FE)
                                                : const Color(0xFFF2F5F4),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              splashColor: (_activeFilterIndex == 0
                                                      ? Colors.white
                                                      : const Color(0xFF8B53FE))
                                                  .withValues(alpha: 0.18),
                                              highlightColor: (_activeFilterIndex == 0
                                                      ? Colors.white
                                                      : const Color(0xFF8B53FE))
                                                  .withValues(alpha: 0.08),
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                setState(() {
                                                  _selectedFilterIndex = 0;
                                                });
                                              },
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    // content: Active (width: 43, height: 10, Inter Medium 14px, #FFFFFF)
                                                    Text(
                                                      'Active',
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
                                                        color:
                                                            _activeFilterIndex ==
                                                                    0
                                                                ? const Color(
                                                                    0xFFFFFFFF)
                                                                : const Color(
                                                                    0xFF1C2926),
                                                        height: 1.15,
                                                        letterSpacing: 0.0,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6.0),

                                                    // circle branding: width: 20, height: 20, border-radius: 20px, padding: 4px, background: #FFFFFF
                                                    // content: 1 (font: Inter 400 12px, #1D8070)
                                                    Container(
                                                      width: 20.0,
                                                      height: 20.0,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            _activeFilterIndex ==
                                                                    0
                                                                ? const Color(
                                                                    0xFFFFFFFF)
                                                                : const Color(
                                                                    0xFF1C2926),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          '1',
                                                          textHeightBehavior:
                                                              const TextHeightBehavior(
                                                            applyHeightToFirstAscent:
                                                                false,
                                                            applyHeightToLastDescent:
                                                                false,
                                                          ),
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 12.0,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                _activeFilterIndex ==
                                                                        0
                                                                    ? const Color(
                                                                        0xFF8B53FE)
                                                                    : const Color(
                                                                        0xFFFFFFFF),
                                                            height: 1.0,
                                                            letterSpacing: 0.0,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // gap: 12px
                                    const SizedBox(width: 12.0),

                                    // 2nd Button: History
                                    // width: 169; height: 52; gap: 6px; border-radius: 12px;
                                    // padding-top: 16px; padding-bottom: 16px; background: #F2F5F4;
                                    Expanded(
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 180),
                                          curve: Curves.easeInOut,
                                          height: 52.0,
                                          decoration: BoxDecoration(
                                            color: _activeFilterIndex == 1
                                                ? const Color(0xFF8B53FE)
                                                : const Color(0xFFF2F5F4),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              splashColor: (_activeFilterIndex == 1
                                                      ? Colors.white
                                                      : const Color(0xFF8B53FE))
                                                  .withValues(alpha: 0.18),
                                              highlightColor: (_activeFilterIndex == 1
                                                      ? Colors.white
                                                      : const Color(0xFF8B53FE))
                                                  .withValues(alpha: 0.08),
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                setState(() {
                                                  _selectedFilterIndex = 1;
                                                });
                                              },
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    // content layout: width: 75, height: 20, gap: 6px
                                                    // history layout: width: 49, height: 10, content: History (Inter Medium 14px, #1C2926)
                                                    Text(
                                                      'History',
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
                                                        color:
                                                            _activeFilterIndex ==
                                                                    1
                                                                ? const Color(
                                                                    0xFFFFFFFF)
                                                                : const Color(
                                                                    0xFF1C2926),
                                                        height: 1.15,
                                                        letterSpacing: 0.0,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6.0),

                                                    // circle branding: width: 20, height: 20, border-radius: 20px, padding: 4px, background: #1C2926
                                                    // content: 12 (width: 13, height: 9, Inter 400 12px, #FFFFFF)
                                                    Container(
                                                      width: 20.0,
                                                      height: 20.0,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            _activeFilterIndex ==
                                                                    1
                                                                ? const Color(
                                                                    0xFFFFFFFF)
                                                                : const Color(
                                                                    0xFF1C2926),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          '12',
                                                          textHeightBehavior:
                                                              const TextHeightBehavior(
                                                            applyHeightToFirstAscent:
                                                                false,
                                                            applyHeightToLastDescent:
                                                                false,
                                                          ),
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 11.5,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                _activeFilterIndex ==
                                                                        1
                                                                    ? const Color(
                                                                        0xFF8B53FE)
                                                                    : const Color(
                                                                        0xFFFFFFFF),
                                                            height: 1.0,
                                                            letterSpacing: 0.0,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 3. Active Request Card:
                              // width: 350; height: 320; border-radius: 16px; background: #FFFFFF; box-shadow: 0px 1px 12px 0px #0000001A;
                              if (_activeFilterIndex == 0)
                                Positioned(
                                  top: 184.0,
                                  left: horizontalPadding,
                                  right: horizontalPadding,
                                  height: 320.0,
                                  child: Container(
                                    height: 320.0,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFFFF),
                                      borderRadius: BorderRadius.circular(16.0),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x1A000000), // #0000001A
                                          blurRadius: 12.0,
                                          offset: Offset(0, 1),
                                          spreadRadius: 0.0,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        // Heading layout: width: 318; top: 16px; left: 16px; gap: 16px;
                                        Positioned(
                                          top: 16.0,
                                          left: 16.0,
                                          right: 16.0,
                                          child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Left-side icon layout: width: 32; height: 32; border-radius: 60px; background: #E7F5EB;
                                            Container(
                                              width: 32.0,
                                              height: 32.0,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFF0EAFE),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                // Icon inner layout: width: 20; height: 20; top: 6px; left: 6px; border-width: 5px; background: #FFFFFF; border: 5px solid #1D8070
                                                child: Container(
                                                  width: 20.0,
                                                  height: 20.0,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFFFFFFF),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: const Color(
                                                          0xFF8B53FE),
                                                      width: 5.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16.0),

                                            // Right-side content layout: width: 270; height: 31; gap: 12px;
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // content: Your provider is on the way (Inter Medium 14px, #1C2926)
                                                  Text(
                                                    'Your provider is on the way',
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
                                                      height: 1.15,
                                                      letterSpacing: 0.0,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2.0),

                                                  // content: Almost there! Your provider will arrive soon. (Inter Regular 12px, #566663)
                                                  Text(
                                                    'Almost there! Your provider will arrive soon.',
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
                                                      height: 1.15,
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

                                      // Map Integration: width: 350; height: 160; border-radius: 12px; top: 64px;
                                      Positioned(
                                        top: 64.0,
                                        left: 0.0,
                                        right: 0.0,
                                        height: 160.0,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          child: LayoutBuilder(
                                            builder: (context, mapConstraints) {
                                              final double mapWidth =
                                                  mapConstraints.maxWidth;
                                              // Route cluster was designed for 350px card; center cluster dynamically on all screen widths
                                              final double offsetX =
                                                  (mapWidth - 350.0) / 2.0;

                                              return Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  // 1. Background map image: assets/images/BG image.png
                                                  Positioned.fill(
                                                    child: Image.asset(
                                                      'assets/images/BG image.png',
                                                      fit: BoxFit.cover,
                                                      alignment:
                                                          Alignment.center,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          Container(
                                                        color: const Color(
                                                            0xFFF3F4F6),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.map_outlined,
                                                            size: 40,
                                                            color: Color(
                                                                0xFF9CA3AF),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  // Soft subtle overlay tint
                                                  Positioned.fill(
                                                    child: Container(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.10),
                                                    ),
                                                  ),

                                                  // 2. Vector layout: width: 102.97; height: 57.56; top: 57.44px; left: 102.53px; border: 4px solid #1D8070
                                                  Positioned(
                                                    top: 57.44,
                                                    left: 102.53 + offsetX,
                                                    width: 102.97,
                                                    height: 57.56,
                                                    child: const CustomPaint(
                                                      size: Size(102.97, 57.56),
                                                      painter:
                                                          _RouteVectorPainter(
                                                        color:
                                                            Color(0xFF8B53FE),
                                                        strokeWidth: 4.0,
                                                      ),
                                                    ),
                                                  ),

                                                  // 3. Top-down aerodynamic car with brand purple roof (#A67AFE):
                                                  Positioned(
                                                    top: 40.0,
                                                    left: 79.0 + offsetX,
                                                    width: 18.0,
                                                    height: 28.0,
                                                    child: Transform.rotate(
                                                      angle: -120.0 * math.pi / 180.0,
                                                      alignment: Alignment.center,
                                                      child: const CustomPaint(
                                                        size: Size(18.0, 28.0),
                                                        painter: _CarGraphicPainter(
                                                          roofColor: Color(0xFFA67AFE),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  // 4. Timer badge layout: width: 55; height: 24; top: 18px; left: 78px;
                                                  // inner layout: width: 55; height: 18; border-radius: 4px; padding: 6px; background: #1D8070;
                                                  // content: 8 min away (Inter Regular 8px, #FFFFFF)
                                                  Positioned(
                                                    top: 18.0,
                                                    left: 78.0 + offsetX,
                                                    width: 55.0,
                                                    height: 24.0,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          width: 55.0,
                                                          height: 18.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color(
                                                                0xFF8B53FE),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0),
                                                            boxShadow: const [
                                                              BoxShadow(
                                                                color: Color(
                                                                    0x0F000000), // #0000000F
                                                                blurRadius: 8.0,
                                                                offset: Offset(
                                                                    0, 1),
                                                              ),
                                                            ],
                                                          ),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            '8 min away',
                                                            textHeightBehavior:
                                                                const TextHeightBehavior(
                                                              applyHeightToFirstAscent:
                                                                  false,
                                                              applyHeightToLastDescent:
                                                                  false,
                                                            ),
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize: 8.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: const Color(
                                                                  0xFFFFFFFF),
                                                              height: 1.0,
                                                              letterSpacing:
                                                                  0.0,
                                                            ),
                                                          ),
                                                        ),
                                                        CustomPaint(
                                                          size: const Size(
                                                              6.0, 4.0),
                                                          painter:
                                                              const _TooltipArrowPainter(
                                                            color: Color(
                                                                0xFF8B53FE),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // 5. Location Marker Halo & Brand Purple 3D Pin (replaces green Group 5.png):
                                                  Positioned(
                                                    top: 94.0,
                                                    left: 180.5 + offsetX,
                                                    width: 46.0,
                                                    height: 46.0,
                                                    child: Container(
                                                      width: 46.0,
                                                      height: 46.0,
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
                                                            blurRadius: 10.0,
                                                            spreadRadius: 2.0,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                  Positioned(
                                                    top: 97.0,
                                                    left: 184.5 + offsetX,
                                                    width: 38.0,
                                                    height: 38.0,
                                                    child: const Center(
                                                      child: _BrandPurpleLocationPinWidget(
                                                        size: 32.0,
                                                      ),
                                                    ),
                                                  ),

                                                  // 6. Badge layout ("You"):
                                                  Positioned(
                                                    top: 76.0,
                                                    left: 190.0 + offsetX,
                                                    width: 27.0,
                                                    height: 24.0,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          width: 27.0,
                                                          height: 18.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color(
                                                                0xFF8B53FE),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0),
                                                            boxShadow: const [
                                                              BoxShadow(
                                                                color: Color(
                                                                    0x0F000000), // #0000000F
                                                                blurRadius: 8.0,
                                                                offset: Offset(
                                                                    0, 1),
                                                              ),
                                                            ],
                                                          ),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            'You',
                                                            textHeightBehavior:
                                                                const TextHeightBehavior(
                                                              applyHeightToFirstAscent:
                                                                  false,
                                                              applyHeightToLastDescent:
                                                                  false,
                                                            ),
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize: 8.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: const Color(
                                                                  0xFFFFFFFF),
                                                              height: 1.0,
                                                              letterSpacing:
                                                                  0.0,
                                                            ),
                                                          ),
                                                        ),
                                                        CustomPaint(
                                                          size: const Size(
                                                              6.0, 4.0),
                                                          painter:
                                                              const _TooltipArrowPainter(
                                                            color: Color(
                                                                0xFF8B53FE),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // 7. Curent location icon layout: width: 24; height: 24; border-radius: 4px; top: 120px; right: 16px;
                                                  // background: #FFFFFF; box-shadow: 0px 1px 8px 0px #0000000F;
                                                  // icon inner layout: width: 13.33; height: 13.33; top: 5.33px; left: 5.33px; background: #1C2926;
                                                  Positioned(
                                                    top: 120.0,
                                                    right: 16.0,
                                                    width: 24.0,
                                                    height: 24.0,
                                                    child: Container(
                                                      width: 24.0,
                                                      height: 24.0,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFFFFFFFF),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                        boxShadow: const [
                                                          BoxShadow(
                                                            color: Color(
                                                                0x0F000000), // #0000000F
                                                            blurRadius: 8.0,
                                                            offset:
                                                                Offset(0, 1),
                                                          ),
                                                        ],
                                                      ),
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons
                                                              .my_location_rounded,
                                                          size: 13.33,
                                                          color:
                                                              Color(0xFF1C2926),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                      ),

                                      // Driver summary layout:
                                      // width: 350; height: 64; top: 240px; padding-left: 16px; padding-right: 16px; justify-content: space-between;
                                      Positioned(
                                        top: 240.0,
                                        left: 0.0,
                                        right: 0.0,
                                        height: 64.0,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // card inner branding: width: 311; height: 64; gap: 16px;
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  // img layout: width: 48; height: 48;
                                                  ClipOval(
                                                    child: Image.asset(
                                                      'assets/images/driver_avatar.png',
                                                      width: 48.0,
                                                      height: 48.0,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          Container(
                                                        width: 48.0,
                                                        height: 48.0,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Color(
                                                              0xFFFFB6C1),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.person_rounded,
                                                          size: 28.0,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16.0), // gap: 16px;

                                                  // content layout: width: 171; height: 64; gap: 12px;
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      // 1st row: content: Ahmad Transport
                                                      // width: 100; height: 9; font-family: Inter; font-weight: 500; font-size: 12px; color: #1C2926;
                                                      Text(
                                                        'Ahmad Transport',
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
                                                          height: 1.15,
                                                          letterSpacing: 0.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const SizedBox(
                                                          height: 2.0),

                                                      // 2nd row: star branding + 4.9 (120 trips)
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          // star branding: width: 10; height: 10; background: #1D8070;
                                                          const Icon(
                                                            Icons.star_rounded,
                                                            size: 11.0,
                                                            color: Color(
                                                                0xFF8B53FE),
                                                          ),
                                                          const SizedBox(
                                                              width: 4.0), // gap: 4px;
                                                          Text.rich(
                                                            TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text: '4.9 ',
                                                                  style: GoogleFonts
                                                                      .inter(
                                                                    fontSize:
                                                                        10.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: const Color(
                                                                        0xFF1C2926),
                                                                    height:
                                                                        1.15,
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      '(120 trips)',
                                                                  style: GoogleFonts
                                                                      .inter(
                                                                    fontSize:
                                                                        10.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: const Color(
                                                                        0xFF566663),
                                                                    height:
                                                                        1.15,
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
                                                      const SizedBox(
                                                          height: 2.0),

                                                      // Pickup & Delivery (matches screenshot)
                                                      Text(
                                                        'Pickup & Delivery',
                                                        textHeightBehavior:
                                                            const TextHeightBehavior(
                                                          applyHeightToFirstAscent:
                                                              false,
                                                          applyHeightToLastDescent:
                                                              false,
                                                        ),
                                                        style: GoogleFonts.inter(
                                                          fontSize: 10.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: const Color(
                                                              0xFF566663),
                                                          height: 1.15,
                                                          letterSpacing: 0.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const SizedBox(
                                                          height: 2.0),

                                                      // 3rd row: width: 158.5; height: 10; gap: 10px;
                                                      // Left side: Toyota Hilux | Right side: ABC-123
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          // left side: vector styling (width: 10, height: 9) + Toyota Hilux
                                                          const Icon(
                                                            Icons
                                                                .directions_car_filled_rounded,
                                                            size: 11.0,
                                                            color: Color(
                                                                0xFF1C2926),
                                                          ),
                                                          const SizedBox(
                                                              width: 4.0),
                                                          Text(
                                                            'Toyota Hilux',
                                                            textHeightBehavior:
                                                                const TextHeightBehavior(
                                                              applyHeightToFirstAscent:
                                                                  false,
                                                              applyHeightToLastDescent:
                                                                  false,
                                                            ),
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize: 10.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: const Color(
                                                                  0xFF1C2926),
                                                              height: 1.15,
                                                              letterSpacing:
                                                                  0.0,
                                                            ),
                                                          ),

                                                          // divider between Toyota Hilux and ABC-123
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        6.0),
                                                            width: 1.0,
                                                            height: 9.0,
                                                            color: const Color(
                                                                0xFFE5E7EB),
                                                          ),

                                                          // right side content: vector (width: 10, height: 10) + ABC-123
                                                          Container(
                                                            width: 10.0,
                                                            height: 10.0,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .transparent,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          2.0),
                                                              border:
                                                                  Border.all(
                                                                color: const Color(
                                                                    0xFF566663),
                                                                width: 0.8,
                                                              ),
                                                            ),
                                                            alignment:
                                                                Alignment.center,
                                                            child: Text(
                                                              '#',
                                                              style:
                                                                  GoogleFonts
                                                                      .inter(
                                                                fontSize: 7.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: const Color(
                                                                    0xFF566663),
                                                                height: 1.0,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 4.0),
                                                          Text(
                                                            'ABC-123',
                                                            textHeightBehavior:
                                                                const TextHeightBehavior(
                                                              applyHeightToFirstAscent:
                                                                  false,
                                                              applyHeightToLastDescent:
                                                                  false,
                                                            ),
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize: 10.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: const Color(
                                                                  0xFF566663),
                                                              height: 1.15,
                                                              letterSpacing:
                                                                  0.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),

                                              // right side of card icon >: width: 7; height: ~15; border: 1px solid #566663
                                              const Icon(
                                                Icons.chevron_right_rounded,
                                                size: 20.0,
                                                color: Color(0xFF566663),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                    ),
                                  ),
                                ),

                              // 4. Status Progress Stepper Card:
                              // width: 350; height: 81; border-radius: 12px; background: #F2F5F4;
                              if (_activeFilterIndex == 0)
                                Positioned(
                                  top: 520.0,
                                  left: horizontalPadding,
                                  right: horizontalPadding,
                                  height: 81.0,
                                  child: Container(
                                    height: 81.0,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F5F4),
                                      borderRadius:
                                          BorderRadius.circular(12.0),
                                    ),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        // Connecting line passing behind the 5 icons at Y = 26px
                                        Positioned(
                                          top: 25.5,
                                          left: 48.0,
                                          right: 48.0,
                                          height: 1.0,
                                          child: Container(
                                            color: const Color(0xFFEAEBE8),
                                          ),
                                        ),

                                        // 5 Step items row: padding-left: 17, padding-right: 17
                                        Positioned.fill(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 17.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: _buildStepperItem(
                                                    title: 'Request Sent',
                                                    time: '9:20 AM',
                                                    state: _RequestStepState
                                                        .completed,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: _buildStepperItem(
                                                    title: 'Accepted',
                                                    time: '9:22 AM',
                                                    state: _RequestStepState
                                                        .completed,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: _buildStepperItem(
                                                    title: 'On the way',
                                                    time: '9:28 AM',
                                                    state: _RequestStepState
                                                        .active,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: _buildStepperItem(
                                                    title: 'Arrived',
                                                    time: null,
                                                    state: _RequestStepState
                                                        .pending,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: _buildStepperItem(
                                                    title: 'Completed',
                                                    time: null,
                                                    state: _RequestStepState
                                                        .pending,
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

                              // 5. Metric cards row: 1.8 km Distance Away & 8 min Estimated time
                              // width: 350; height: 64; gap: 12px;
                              if (_activeFilterIndex == 0)
                                Positioned(
                                  top: 617.0,
                                  left: horizontalPadding,
                                  right: horizontalPadding,
                                  height: 64.0,
                                  child: Row(
                                    children: [
                                      // 1st card branding: 1.8 km Distance Away
                                        Expanded(
                                          child: Container(
                                            height: 64.0,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0,
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
                                                // left side icon branding: width: 32; height: 32; border-radius: 60px; background: #E2F0E6;
                                                Container(
                                                  width: 32.0,
                                                  height: 32.0,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Color(0xFFF0EAFE),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Center(
                                                    child: CustomPaint(
                                                      size: Size(16.0, 18.0),
                                                      painter:
                                                          _LocationPinPainter(
                                                        color:
                                                            Color(0xFF8B53FE),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12.0), // gap: 12px;

                                                // inner card content right side:
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      // content: 1.8 km
                                                      FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          '1.8 km',
                                                          textHeightBehavior:
                                                              const TextHeightBehavior(
                                                            applyHeightToFirstAscent:
                                                                false,
                                                            applyHeightToLastDescent:
                                                                false,
                                                          ),
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: const Color(
                                                                0xFF1C2926),
                                                            height: 1.1,
                                                            letterSpacing: 0.0,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 2.0),

                                                      // content: Distance Away
                                                      FittedBox(
                                                        fit: BoxFit.scaleDown,
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
                                                              GoogleFonts.inter(
                                                            fontSize: 10.0,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: const Color(
                                                                0xFF566663),
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

                                        // 2nd card branding: 8 min Estimated time
                                        Expanded(
                                          child: Container(
                                            height: 64.0,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0,
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
                                                // left side icon branding: width: 32; height: 32; border-radius: 60px; background: #E2F0E6;
                                                Container(
                                                  width: 32.0,
                                                  height: 32.0,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Color(0xFFF0EAFE),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Center(
                                                    child: CustomPaint(
                                                      size: Size(20.0, 20.0),
                                                      painter:
                                                          _ClockIconPainter(
                                                        backgroundColor:
                                                            Color(0xFF8B53FE),
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
                                                        CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      // content: 8 min
                                                      FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          '8 min',
                                                          textHeightBehavior:
                                                              const TextHeightBehavior(
                                                            applyHeightToFirstAscent:
                                                                false,
                                                            applyHeightToLastDescent:
                                                                false,
                                                          ),
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: const Color(
                                                                0xFF1C2926),
                                                            height: 1.1,
                                                            letterSpacing: 0.0,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 2.0),

                                                      // content: Estimated time
                                                      FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          'Estimated time',
                                                          textHeightBehavior:
                                                              const TextHeightBehavior(
                                                            applyHeightToFirstAscent:
                                                                false,
                                                            applyHeightToLastDescent:
                                                                false,
                                                          ),
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 10.0,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: const Color(
                                                                0xFF566663),
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
                                  ),

                              // -------------------------------------------------------------
                              // HISTORY TAB LAYOUT (_activeFilterIndex == 1)
                              // width: 350; height: 545.88; top: 192px; left: 20px; gap: 20px;
                              // -------------------------------------------------------------
                              if (_activeFilterIndex == 1)
                                Positioned(
                                  top: 192.0,
                                  left: horizontalPadding,
                                  right: horizontalPadding,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 1st widget branding: Searchbar & Filter icon row
                                      // width: 350; height: 49.88; gap: 16px;
                                      SizedBox(
                                        height: 49.88,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // searchbar layout: width: 284.12; height: 49.88; gap: 10px; border-radius: 40px; padding: 16px; background: #FFFFFF; box-shadow: 0px 1px 12px 0px #0000001A;
                                            Expanded(
                                              child: Container(
                                                height: 49.88,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFFFFFF),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          40.0),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Color(0x1A000000), // #0000001A
                                                      blurRadius: 12.0,
                                                      offset: Offset(0, 1),
                                                      spreadRadius: 0.0,
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    // search icon: width: 17.78; height: 17.88; background: #1C2926;
                                                    const Icon(
                                                      Icons.search_rounded,
                                                      size: 20.0,
                                                      color: Color(0xFF1C2926),
                                                    ),
                                                    const SizedBox(width: 10.0), // gap: 10px;

                                                    // content: Search requests (Inter Regular 12px, #566663)
                                                    Expanded(
                                                      child: TextField(
                                                        controller:
                                                            _searchController,
                                                        onChanged: (val) {
                                                          setState(() {});
                                                        },
                                                        cursorColor:
                                                            const Color(
                                                                0xFF8B53FE),
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: const Color(
                                                              0xFF1C2926),
                                                          height: 1.2,
                                                          letterSpacing: 0.0,
                                                        ),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              'Search requests',
                                                          hintStyle:
                                                              GoogleFonts
                                                                  .inter(
                                                            fontSize: 12.0,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: const Color(
                                                                0xFF566663),
                                                            height: 1.2,
                                                            letterSpacing: 0.0,
                                                          ),
                                                          suffixIcon: _searchController
                                                                  .text
                                                                  .isNotEmpty
                                                              ? MouseRegion(
                                                                  cursor:
                                                                      SystemMouseCursors
                                                                          .click,
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      _searchController
                                                                          .clear();
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .close_rounded,
                                                                      size: 16.0,
                                                                      color: Color(
                                                                          0xFF566663),
                                                                    ),
                                                                  ),
                                                                )
                                                              : null,
                                                          border:
                                                              InputBorder.none,
                                                          isDense: true,
                                                          contentPadding:
                                                              EdgeInsets.zero,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16.0), // gap: 16px;

                                            // right side icon layout: width: 49.88; height: 49.88; box-shadow: 0px 1px 8px 0px #0000000F;
                                            Material(
                                              color: Colors.transparent,
                                              shape: const CircleBorder(),
                                              child: InkWell(
                                                onTap: () {
                                                  HapticFeedback.lightImpact();
                                                },
                                                customBorder:
                                                    const CircleBorder(),
                                                child: Container(
                                                  width: 49.88,
                                                  height: 49.88,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFFFFFFF),
                                                    shape: BoxShape.circle,
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Color(0x0F000000), // #0000000F
                                                        blurRadius: 8.0,
                                                        offset: Offset(0, 1),
                                                        spreadRadius: 0.0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Center(
                                                    child: CustomPaint(
                                                      size: Size(23.82, 14.29),
                                                      painter:
                                                          _FilterLinesPainter(
                                                        color:
                                                            Color(0xFF1C2926),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 20.0), // gap: 20px;

                                      // -----------------------------------------------------------
                                      // Card widget layout:
                                      // width: 350; height: 476; gap: 12px; angle: 0 deg; opacity: 1;
                                      // -----------------------------------------------------------
                                      Column(
                                        children: [
                                          for (int i = 0;
                                              i < _filteredHistoryItems.length;
                                              i++) ...[
                                            if (i > 0)
                                              const SizedBox(height: 12.0), // gap: 12px;
                                            _buildHistoryCard(
                                              _filteredHistoryItems[i],
                                              containerWidth,
                                            ),
                                          ],
                                          if (_filteredHistoryItems.isEmpty)
                                            _buildEmptyHistoryState(
                                              containerWidth,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                  // Floating Bottom Navigation Bar (Request tab active: index 1)
                  if (widget.showBottomNav)
                    Positioned(
                      left: (containerWidth - 292.0) / 2,
                      width: 292.0,
                      bottom: isDesktopWeb
                          ? 16.0
                          : (MediaQuery.of(context).padding.bottom + 12.0),
                      child: BottomNavBarWidget(
                        currentIndex: 1,
                        initialIndex: 1,
                        onTabSelected: (index) {
                          if (widget.onTabSelected != null) {
                            widget.onTabSelected!(index);
                          } else {
                            if (index == 0) {
                              Navigator.of(context).pushReplacementNamed('/home');
                            } else if (index == 2) {
                              Navigator.of(context).pushReplacementNamed('/profile');
                            }
                          }
                        },
                      ),
                    ),
                ],
              ),
            );

            if (isDesktopWeb) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFF0F1F5), // Clean modern outer backdrop matching home tab
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerSignal: (pointerSignal) {
                    if (pointerSignal is PointerScrollEvent && _scrollController.hasClients) {
                      final double target = (_scrollController.offset + pointerSignal.scrollDelta.dy)
                          .clamp(0.0, _scrollController.position.maxScrollExtent);
                      _scrollController.jumpTo(target);
                    }
                  },
                  child: Center(
                    child: Container(
                      width: containerWidth,
                      height: containerHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(42),
                        border: Border.all(
                          color: const Color(0xFF8B53FE).withValues(alpha: 0.25),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B53FE).withValues(alpha: 0.12),
                            blurRadius: 40,
                            spreadRadius: 6,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: screenContent,
                    ),
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

  Widget _buildStepperItem({
    required String title,
    String? time,
    required _RequestStepState state,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16.0), // top: 16px;
        SizedBox(
          height: 20.0,
          child: Center(
            child: _buildStepIcon(state),
          ),
        ),
        const SizedBox(height: 8.0), // gap: 8px to text row at top: 44px
        SizedBox(
          width: 64.0,
          child: Text(
            title,
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10.0,
              fontWeight: FontWeight.w500,
              color: state == _RequestStepState.pending
                  ? const Color(0xFF566663)
                  : const Color(0xFF8B53FE),
              height: 1.15,
              letterSpacing: 0.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
        ),
        if (time != null) ...[
          const SizedBox(height: 2.0),
          SizedBox(
            width: 64.0,
            child: Text(
              time,
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 8.0,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF566663),
                height: 1.15,
                letterSpacing: 0.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStepIcon(_RequestStepState state) {
    switch (state) {
      case _RequestStepState.completed:
        return Container(
          width: 16.0,
          height: 16.0,
          decoration: BoxDecoration(
            color: const Color(0xFF8B53FE),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFFFFFF),
              width: 0.8,
            ),
          ),
          alignment: Alignment.center,
          child: const CustomPaint(
            size: Size(7.5, 5.0),
            painter: _CheckmarkPainter(
              color: Colors.white,
              strokeWidth: 0.8,
            ),
          ),
        );

      case _RequestStepState.active:
        return Container(
          width: 20.0,
          height: 20.0,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F5F4),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF8B53FE),
              width: 1.6,
            ),
          ),
          alignment: Alignment.center,
          child: Container(
            width: 10.0,
            height: 10.0,
            decoration: const BoxDecoration(
              color: Color(0xFF8B53FE),
              shape: BoxShape.circle,
            ),
          ),
        );

      case _RequestStepState.pending:
        return Container(
          width: 16.0,
          height: 16.0,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFEAEBE8),
              width: 1.0,
            ),
          ),
        );
    }
  }

  // -------------------------------------------------------------
  // HISTORY TAB STATE & CARDS BUILDER
  // -------------------------------------------------------------
  static const List<_HistoryRequestItem> _allHistoryItems = [
    _HistoryRequestItem(
      providerName: 'Ahmad Transport',
      statusText: 'Completed',
      statusBgColor: Color(0xFFF0EAFE),
      statusTextColor: Color(0xFF8B53FE),
      rating: '4.9',
      trips: '(120 trips)',
      serviceCategory: 'Pickup & Delivery',
      vehicleName: 'Toyota Hilux',
      vehicleIcon: Icons.local_shipping_outlined,
      plateNumber: 'ABC-123',
      dateTime: '10 Sep 2026, 2:15 PM',
      avatarPath: 'assets/images/history_avatar_1.png',
      avatarFallbackColor: Color(0xFFFFC1CC),
    ),
    _HistoryRequestItem(
      providerName: 'Babar Logistics',
      statusText: 'Cancelled',
      statusBgColor: Color(0xFFFFF0F0),
      statusTextColor: Color(0xFFDC2626),
      rating: '4.9',
      trips: '(120 trips)',
      serviceCategory: 'Truck',
      vehicleName: 'Suzuki Ravi',
      vehicleIcon: Icons.airport_shuttle_outlined,
      plateNumber: 'XYZ-789',
      dateTime: '5 Sep 2026, 11:00 PM',
      avatarPath: 'assets/images/history_avatar_2.png',
      avatarFallbackColor: Color(0xFFDBEAFE),
    ),
    _HistoryRequestItem(
      providerName: 'Hassan Rider',
      statusText: 'Completed',
      statusBgColor: Color(0xFFF0EAFE),
      statusTextColor: Color(0xFF8B53FE),
      rating: '4.9',
      trips: '(120 trips)',
      serviceCategory: 'Rider',
      vehicleName: 'Honda 125',
      vehicleIcon: Icons.two_wheeler_rounded,
      plateNumber: 'RID-456',
      dateTime: '2 Sep 2026, 4:15 PM',
      avatarPath: 'assets/images/history_avatar_3.png',
      avatarFallbackColor: Color(0xFFD1FAE5),
    ),
    _HistoryRequestItem(
      providerName: 'Ali Transport',
      statusText: 'Completed',
      statusBgColor: Color(0xFFF0EAFE),
      statusTextColor: Color(0xFF8B53FE),
      rating: '4.9',
      trips: '(120 trips)',
      serviceCategory: 'Ride',
      vehicleName: 'Toyota Corolla',
      vehicleIcon: Icons.directions_car_rounded,
      plateNumber: 'CAR-654',
      dateTime: '28 Aug 2026, 6:15 PM',
      avatarPath: 'assets/images/history_avatar_4.png',
      avatarFallbackColor: Color(0xFFE2E8F0),
    ),
  ];

  List<_HistoryRequestItem> get _filteredHistoryItems {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _allHistoryItems;
    }
    return _allHistoryItems.where((item) {
      return item.providerName.toLowerCase().contains(query) ||
          item.serviceCategory.toLowerCase().contains(query) ||
          item.vehicleName.toLowerCase().contains(query) ||
          item.plateNumber.toLowerCase().contains(query) ||
          item.statusText.toLowerCase().contains(query) ||
          item.dateTime.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildEmptyHistoryState(double containerWidth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
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
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 36.0,
              color: Color(0xFF566663),
            ),
            const SizedBox(height: 10.0),
            Text(
              'No requests found',
              style: GoogleFonts.inter(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1C2926),
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              'Try searching with a different term',
              style: GoogleFonts.inter(
                fontSize: 11.0,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF566663),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(_HistoryRequestItem item, double containerWidth) {
    return Container(
      width: double.infinity,
      height: 110.0, // height: 110;
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // background: #FFFFFF;
        borderRadius: BorderRadius.circular(12.0), // border-radius: 12px;
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000), // box-shadow: 0px 1px 12px 0px #0000001A;
            blurRadius: 12.0,
            offset: Offset(0, 1),
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            HapticFeedback.lightImpact();
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0), // padding: 16px;
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // left side img: width: 48; height: 48;
                ClipOval(
                  child: SizedBox(
                    width: 48.0,
                    height: 48.0,
                    child: Image.asset(
                      item.avatarPath,
                      width: 48.0,
                      height: 48.0,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to driver_avatar or initials
                        return Image.asset(
                          'assets/images/driver_avatar.png',
                          width: 48.0,
                          height: 48.0,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error2, stackTrace2) {
                            return Container(
                              width: 48.0,
                              height: 48.0,
                              decoration: BoxDecoration(
                                color: item.avatarFallbackColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  item.providerName.isNotEmpty
                                      ? item.providerName[0]
                                      : '?',
                                  style: GoogleFonts.inter(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1C2926),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16.0), // gap: 16px;

                // content layout: width: 254; height: 78; justify-content: space-between;
                Expanded(
                  child: SizedBox(
                    height: 78.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // left content layout: width: 238; height: 78; gap: 12px;
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1st row branding: width: 238; height: 19; justify-content: space-between;
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // 1st row inner branding: content: Ahmad Transport
                                  // font-family: Inter; font-weight: 500; font-size: 12px; line-height: 22px; color: #1C2926;
                                  Flexible(
                                    child: Text(
                                      item.providerName,
                                      textHeightBehavior:
                                          const TextHeightBehavior(
                                        applyHeightToFirstAscent: false,
                                        applyHeightToLastDescent: false,
                                      ),
                                      style: GoogleFonts.inter(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF1C2926),
                                        height: 1.15,
                                        letterSpacing: 0.0,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),

                                  // 1st row right content: status badge
                                  // width: 64; height: 19; border-radius: 60px; padding: 6px; background: #F0F5F2;
                                  // content: Completed / Cancelled
                                  Container(
                                    height: 19.0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 3.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item.statusBgColor,
                                      borderRadius: BorderRadius.circular(60.0),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      item.statusText,
                                      textHeightBehavior:
                                          const TextHeightBehavior(
                                        applyHeightToFirstAscent: false,
                                        applyHeightToLastDescent: false,
                                      ),
                                      style: GoogleFonts.inter(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w400,
                                        color: item.statusTextColor,
                                        height: 1.0,
                                        letterSpacing: 0.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // 2nd row layout: width: 171; height: 10; gap: 8px;
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // star branding: width: 10; height: 10; background: #1D8070;
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 11.0,
                                    color: Color(0xFF8B53FE),
                                  ),
                                  const SizedBox(width: 4.0), // gap: 4px;

                                  // content: 4.9 (120 trips) (Inter Regular 10px)
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${item.rating} ',
                                          style: GoogleFonts.inter(
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF1C2926),
                                            height: 1.15,
                                            letterSpacing: 0.0,
                                          ),
                                        ),
                                        TextSpan(
                                          text: item.trips,
                                          style: GoogleFonts.inter(
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF566663),
                                            height: 1.15,
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
                                  const SizedBox(width: 8.0), // gap: 8px;

                                  // content: Pickup & Delivery (Inter Regular 10px, #566663)
                                  Flexible(
                                    child: Text(
                                      item.serviceCategory,
                                      textHeightBehavior:
                                          const TextHeightBehavior(
                                        applyHeightToFirstAscent: false,
                                        applyHeightToLastDescent: false,
                                      ),
                                      style: GoogleFonts.inter(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF566663),
                                        height: 1.15,
                                        letterSpacing: 0.0,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              // 3rd row layout: width: 160.5; height: 10; gap: 10px;
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // vector of car branding: width: 12; height: 10; background: #1C2926;
                                  Icon(
                                    item.vehicleIcon,
                                    size: 11.5,
                                    color: const Color(0xFF1C2926),
                                  ),
                                  const SizedBox(width: 4.0),

                                  // content: Toyota Hilux (Inter Medium 10px, #1C2926)
                                  Text(
                                    item.vehicleName,
                                    textHeightBehavior:
                                        const TextHeightBehavior(
                                      applyHeightToFirstAscent: false,
                                      applyHeightToLastDescent: false,
                                    ),
                                    style: GoogleFonts.inter(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1C2926),
                                      height: 1.15,
                                      letterSpacing: 0.0,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(width: 6.0),
                                  // separator divider
                                  Container(
                                    width: 1.0,
                                    height: 8.0,
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                  const SizedBox(width: 6.0),

                                  // vector of # branding: width: 10; height: 10; background: #566663;
                                  Container(
                                    width: 10.0,
                                    height: 10.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFF566663),
                                        width: 0.8,
                                      ),
                                      borderRadius: BorderRadius.circular(2.0),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '#',
                                      textHeightBehavior:
                                          const TextHeightBehavior(
                                        applyHeightToFirstAscent: false,
                                        applyHeightToLastDescent: false,
                                      ),
                                      style: GoogleFonts.inter(
                                        fontSize: 6.5,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF566663),
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4.0),

                                  // content: ABC-123 (Inter Regular 10px, #566663)
                                  Text(
                                    item.plateNumber,
                                    textHeightBehavior:
                                        const TextHeightBehavior(
                                      applyHeightToFirstAscent: false,
                                      applyHeightToLastDescent: false,
                                    ),
                                    style: GoogleFonts.inter(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF566663),
                                      height: 1.15,
                                      letterSpacing: 0.0,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),

                              // 4th row branding: content: 10 Sep 2026, 2:15 PM (Inter Regular 10px, #566663)
                              Text(
                                item.dateTime,
                                textHeightBehavior:
                                    const TextHeightBehavior(
                                  applyHeightToFirstAscent: false,
                                  applyHeightToLastDescent: false,
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF566663),
                                  height: 1.15,
                                  letterSpacing: 0.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // card right side > branding: width: 6; height: 12; angle: -180 deg; border: 0.8px solid #566663
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 18.0,
                            color: Color(0xFF566663),
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
      ),
    );
  }
}

enum _RequestStepState { completed, active, pending }

/// Data model for history tab request cards
class _HistoryRequestItem {
  final String providerName;
  final String statusText;
  final Color statusBgColor;
  final Color statusTextColor;
  final String rating;
  final String trips;
  final String serviceCategory;
  final String vehicleName;
  final IconData vehicleIcon;
  final String plateNumber;
  final String dateTime;
  final String avatarPath;
  final Color avatarFallbackColor;

  const _HistoryRequestItem({
    required this.providerName,
    required this.statusText,
    required this.statusBgColor,
    required this.statusTextColor,
    required this.rating,
    required this.trips,
    required this.serviceCategory,
    required this.vehicleName,
    required this.vehicleIcon,
    required this.plateNumber,
    required this.dateTime,
    required this.avatarPath,
    required this.avatarFallbackColor,
  });
}

/// Custom painter for checkmark vector: width: 7.5; height: 5; border: 0.8px solid #FFFFFF
class _CheckmarkPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _CheckmarkPainter({
    this.color = Colors.white,
    this.strokeWidth = 0.8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0, size.height * 0.45)
      ..lineTo(size.width * 0.38, size.height)
      ..lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter oldDelegate) => false;
}

/// Route vector line painter matching Figma route geometry
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
    path.moveTo(2.0, 4.0);
    path.cubicTo(
      size.width * 0.40,
      2.0,
      size.width * 0.60,
      size.height * 0.80,
      size.width - 2.0,
      size.height - 2.0,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RouteVectorPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}

/// Downward tooltip pointer arrow painter
class _TooltipArrowPainter extends CustomPainter {
  final Color color;
  const _TooltipArrowPainter({this.color = const Color(0xFF8B53FE)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TooltipArrowPainter oldDelegate) =>
      color != oldDelegate.color;
}

/// Detailed aerodynamic top-down car painter with purple roof (#A67AFE)
class _CarGraphicPainter extends CustomPainter {
  final Color roofColor;
  const _CarGraphicPainter({this.roofColor = const Color(0xFFA67AFE)});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Subtle soft shadow
    final shadowPaint = Paint()
      ..color = const Color(0x22000000)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.5, 1.2, w - 1.0, h - 0.8),
        Radius.circular(w * 0.28),
      ),
      shadowPaint,
    );

    // 2. Wheels / Tires (Dark rubber)
    final wheelPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    final double wheelW = w * 0.16;
    final double wheelH = h * 0.20;
    // Front wheels
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, h * 0.16, wheelW, wheelH), const Radius.circular(1.0)),
      wheelPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w - wheelW, h * 0.16, wheelW, wheelH), const Radius.circular(1.0)),
      wheelPaint,
    );
    // Rear wheels
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, h * 0.64, wheelW, wheelH), const Radius.circular(1.0)),
      wheelPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w - wheelW, h * 0.64, wheelW, wheelH), const Radius.circular(1.0)),
      wheelPaint,
    );

    // 3. Aerodynamic White Car Body
    final bodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final bodyBorder = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final bodyPath = Path();
    final double bodyInset = w * 0.08;
    final double bw = w - bodyInset * 2.0;
    bodyPath.addRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(bodyInset, 0, bw, h),
        topLeft: Radius.circular(bw * 0.42),
        topRight: Radius.circular(bw * 0.42),
        bottomLeft: Radius.circular(bw * 0.35),
        bottomRight: Radius.circular(bw * 0.35),
      ),
    );
    canvas.drawPath(bodyPath, bodyPaint);
    canvas.drawPath(bodyPath, bodyBorder);

    // 4. Side Mirrors (Purple body accent)
    final mirrorPaint = Paint()
      ..color = roofColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(bodyInset * 0.5, h * 0.32), w * 0.08, mirrorPaint);
    canvas.drawCircle(Offset(w - bodyInset * 0.5, h * 0.32), w * 0.08, mirrorPaint);

    // 5. Dark Panoramic Glasshouse (Windshield & Rear glass)
    final glassPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    // Front windshield
    final frontGlass = Path()
      ..moveTo(w * 0.22, h * 0.26)
      ..lineTo(w * 0.78, h * 0.26)
      ..lineTo(w * 0.82, h * 0.38)
      ..lineTo(w * 0.18, h * 0.38)
      ..close();
    canvas.drawPath(frontGlass, glassPaint);

    // Rear windshield
    final rearGlass = Path()
      ..moveTo(w * 0.20, h * 0.68)
      ..lineTo(w * 0.80, h * 0.68)
      ..lineTo(w * 0.76, h * 0.80)
      ..lineTo(w * 0.24, h * 0.80)
      ..close();
    canvas.drawPath(rearGlass, glassPaint);

    // 6. Purple Roof (#A67AFE)
    final roofPaint = Paint()
      ..color = roofColor
      ..style = PaintingStyle.fill;
    final roofRRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.20, h * 0.36, w * 0.80, h * 0.68),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(roofRRect, roofPaint);

    // 7. Antenna dot
    final dotPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.60), w * 0.05, dotPaint);

    // 8. Front Headlights (Warm white/amber)
    final headPaint = Paint()
      ..color = const Color(0xFFFDE68A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.22, h * 0.06), w * 0.07, headPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.06), w * 0.07, headPaint);

    // 9. Rear Taillights (Red)
    final tailPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(w * 0.18, h * 0.94, w * 0.16, h * 0.04), tailPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.66, h * 0.94, w * 0.16, h * 0.04), tailPaint);
  }

  @override
  bool shouldRepaint(covariant _CarGraphicPainter oldDelegate) =>
      oldDelegate.roofColor != roofColor;
}

/// Brand 3D-styled Purple Location Pin (replaces green Group 5.png)
class _BrandPurpleLocationPinWidget extends StatelessWidget {
  final double size;
  const _BrandPurpleLocationPinWidget({this.size = 32.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: const _BrandPurpleLocationPinPainter(),
    );
  }
}

class _BrandPurpleLocationPinPainter extends CustomPainter {
  const _BrandPurpleLocationPinPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // 1. Oval shadow at bottom base of pin
    final shadowPaint = Paint()
      ..color = const Color(0x358B53FE)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.90),
        width: w * 0.70,
        height: h * 0.22,
      ),
      shadowPaint,
    );

    // 2. Base beacon ring at bottom
    final baseRingPaint = Paint()
      ..color = const Color(0xFF8B53FE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.88),
        width: w * 0.60,
        height: h * 0.18,
      ),
      baseRingPaint,
    );

    // 3. Teardrop pin body with rich purple gradient
    final Rect pinRect = Rect.fromLTWH(w * 0.14, 0.0, w * 0.72, h * 0.85);
    final pinGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFA67AFE), // Lighter vibrant purple highlight
        Color(0xFF8B53FE), // Deep brand purple
      ],
    );

    final pinPaint = Paint()
      ..shader = pinGradient.createShader(pinRect)
      ..style = PaintingStyle.fill;

    final pinBorderPaint = Paint()
      ..color = const Color(0xFF6E36E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final double cx = w * 0.5;
    final double radius = w * 0.32;
    final double cy = radius + h * 0.04;
    final double tipY = h * 0.86;

    final path = Path();
    path.addArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      math.pi * 0.78,
      math.pi * 1.44,
    );
    path.lineTo(cx, tipY);
    path.close();

    canvas.drawPath(path, pinPaint);
    canvas.drawPath(path, pinBorderPaint);

    // 4. Inner glossy white center dot/lens
    final innerCenter = Offset(cx, cy);
    final innerRadius = radius * 0.44;

    final innerLensPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Colors.white,
          Color(0xFFEFE6FF),
        ],
      ).createShader(Rect.fromCircle(center: innerCenter, radius: innerRadius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(innerCenter, innerRadius, innerLensPaint);

    final innerLensBorder = Paint()
      ..color = const Color(0x338B53FE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(innerCenter, innerRadius, innerLensBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Location pin icon painter matching Figma specifications:
class _LocationPinPainter extends CustomPainter {
  final Color color;
  const _LocationPinPainter({this.color = const Color(0xFF1C2926)});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
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
    canvas.drawCircle(Offset(cx, cy), 2.2, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _LocationPinPainter oldDelegate) =>
      color != oldDelegate.color;
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

    // 2. White clock hands (matching Figma: 12:00 -> center -> ~4:00)
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

/// Custom painter for the 3-line filter vector: width: 23.82; height: 14.29; background: #1C2926;
class _FilterLinesPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _FilterLinesPainter({
    this.color = const Color(0xFF1C2926),
    this.strokeWidth = 2.2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2.0;

    // Line 1 (top): width: 23.82
    final topHalf = (size.width - strokeWidth) / 2.0;
    canvas.drawLine(
      Offset(cx - topHalf, strokeWidth / 2.0),
      Offset(cx + topHalf, strokeWidth / 2.0),
      paint,
    );

    // Line 2 (middle): width ~15.5
    final midHalf = topHalf * 0.65;
    canvas.drawLine(
      Offset(cx - midHalf, size.height / 2.0),
      Offset(cx + midHalf, size.height / 2.0),
      paint,
    );

    // Line 3 (bottom): width ~8.3
    final botHalf = topHalf * 0.35;
    canvas.drawLine(
      Offset(cx - botHalf, size.height - (strokeWidth / 2.0)),
      Offset(cx + botHalf, size.height - (strokeWidth / 2.0)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FilterLinesPainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}


