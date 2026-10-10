import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'provider_detail_screen.dart';

/// Custom scroll behavior enabling smooth mouse dragging, trackpad gestures, and touch on all devices:
class _EasyScrollBehavior extends MaterialScrollBehavior {
  const _EasyScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

/// Screen displayed when user clicks 'Find a Provider'.
/// Header strictly matches the branding of PickupDeliveryScreen.
/// Ready for manual layout branding.
class FindProviderScreen extends ConsumerStatefulWidget {
  final String serviceCategory;

  const FindProviderScreen({
    super.key,
    this.serviceCategory = 'Pickup & Delivery',
  });

  @override
  ConsumerState<FindProviderScreen> createState() => _FindProviderScreenState();
}

class _NearbyProviderItem {
  final String name;
  final String vehicle;
  final double rating;
  final int reviews;
  final String status;
  final String distance;
  final String eta;
  final String imagePath;
  final String phone;

  const _NearbyProviderItem({
    required this.name,
    required this.vehicle,
    required this.rating,
    required this.reviews,
    required this.status,
    required this.distance,
    required this.eta,
    required this.imagePath,
    required this.phone,
  });
}

const List<_NearbyProviderItem> _nearbyProviders = [
  _NearbyProviderItem(
    name: 'Ahmad Raza',
    vehicle: 'Sedan . AC',
    rating: 4.9,
    reviews: 120,
    status: 'Available',
    distance: '0.3 km',
    eta: '2 min away',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 300 1234567',
  ),
  _NearbyProviderItem(
    name: 'Muhammad Bilal',
    vehicle: 'Sedan . AC',
    rating: 4.8,
    reviews: 95,
    status: 'Available',
    distance: '0.6 km',
    eta: '4 min away',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 301 2345678',
  ),
  _NearbyProviderItem(
    name: 'Usman Ali',
    vehicle: 'Pickup . AC',
    rating: 4.9,
    reviews: 142,
    status: 'Available',
    distance: '0.9 km',
    eta: '5 min away',
    imagePath: 'assets/images/pickup.png',
    phone: '+92 302 3456789',
  ),
  _NearbyProviderItem(
    name: 'Hamza Sheikh',
    vehicle: 'Sedan . Non-AC',
    rating: 4.7,
    reviews: 80,
    status: 'Available',
    distance: '1.2 km',
    eta: '7 min away',
    imagePath: 'assets/images/car_ride.png',
    phone: '+92 303 4567890',
  ),
];

class _FindProviderScreenState extends ConsumerState<FindProviderScreen> {
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int _selectedProviderCount = 10;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
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
            final bool isDesktopWeb = constraints.maxWidth > 500;
            final double containerWidth = isDesktopWeb ? 390.0 : constraints.maxWidth;
            final double cardWidth = containerWidth >= 390 ? 350.0 : (containerWidth - 40.0).clamp(280.0, 350.0);
            final double containerHeight = isDesktopWeb
                ? math.min(844.0, (constraints.maxHeight - 32.0).clamp(520.0, 844.0))
                : constraints.maxHeight;

            final screenContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                children: [
                  // 1. Background Map Layer ("in bg map hoga"):
                  Positioned.fill(
                    child: Image.asset(
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

                  // 2. Gradient Overlay Layer ("after header"):
                  // width: 390; height: 843; top: 1px;
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

                  // 3. Location Button Layout:
                  // width: 36; height: 36; top: 106px; left: 334px;
                  // border-radius: 8px; background: #FFFFFF; box-shadow: 0px 1px 8px 0px #0000000F;
                  // icon styling: width: 20; height: 20; top: 8px; left: 8px; background: #1C2926;
                  Positioned(
                    top: 106.0,
                    left: containerWidth >= 390
                        ? 334.0
                        : (containerWidth - 36.0 - 20.0),
                    width: 36.0,
                    height: 36.0,
                    child: GestureDetector(
                      key: const Key('find_provider_location_button'),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Centering to your location...',
                              style: GoogleFonts.inter(
                                fontSize: 12.0,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: const Color(0xFF1D8070),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 36.0,
                        height: 36.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(8.0),
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
                          child: Icon(
                            Icons.my_location_rounded,
                            size: 20.0,
                            color: Color(0xFF1C2926),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 4. Header Branding (Matches PickupDeliveryScreen exactly):
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
                          GestureDetector(
                            key: const Key('find_provider_back_button'),
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
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Text(
                              'Nearby Providers',
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
                          const SizedBox(width: 16.0),
                          // search icon in header on right side matching screenshot:
                          // width: 36; height: 36; angle: 0 deg; opacity: 1; border-radius: 8px; background: #FFFFFF; box-shadow: 0px 1px 8px 0px #0000000F;
                          GestureDetector(
                            key: const Key('header_search_button'),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _isSearchOpen = !_isSearchOpen;
                              });
                              if (_isSearchOpen) {
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  _searchFocusNode.requestFocus();
                                });
                              }
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 36.0,
                              height: 36.0,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(8.0),
                                border: _isSearchOpen
                                    ? Border.all(color: const Color(0xFF1D8070), width: 1.2)
                                    : null,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0F000000), // #0000000F
                                    blurRadius: 8.0,
                                    offset: Offset(0, 1),
                                    spreadRadius: 0.0,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: CustomPaint(
                                  size: const Size(18.0, 18.0),
                                  painter: _SearchVectorPainter(
                                    color: _isSearchOpen
                                        ? const Color(0xFF1D8070)
                                        : const Color(0xFF1C2926),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 5. Card Styling:
                  // width: 390; height: 682; top: 162px;
                  // angle: 0 deg; opacity: 1;
                  // border-top-left-radius: 28px; border-top-right-radius: 28px;
                  // background: #FFFFFF; box-shadow: 0px -2px 12px 0px #00000014;
                  Positioned(
                    top: 162.0,
                    left: 0.0,
                    width: containerWidth,
                    height: 682.0,
                    child: Container(
                      key: const Key('nearby_providers_card_layout'),
                      width: containerWidth,
                      height: 682.0,
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
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28.0),
                          topRight: Radius.circular(28.0),
                        ),
                        child: ScrollConfiguration(
                          behavior: const _EasyScrollBehavior(),
                          child: ListView(
                            padding: EdgeInsets.only(
                              top: 24.0,
                              left: containerWidth >= 390 ? 20.0 : 16.0,
                              right: containerWidth >= 390 ? 20.0 : 16.0,
                              bottom: 80.0,
                            ),
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            children: [
                              // 1. Header controls (Providers to show, buttons, bar, total providers):
                              _buildProvidersInnerCard(containerWidth),

                              const SizedBox(height: 16.0),

                              // 2. Services cards:
                              ...List.generate(
                                _selectedProviderCount,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: _buildServiceCard(cardWidth, index),
                                ),
                              ),

                              const SizedBox(height: 16.0),

                              // 3. Bottom bar indicator after last card:
                              Center(
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
                              const SizedBox(height: 24.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 6. Search Bar opening below header on search icon tap:
                  // width: 350; height: 48; top: 104px; left: 20px;
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    top: _isSearchOpen ? 104.0 : 76.0,
                    left: containerWidth >= 390
                        ? 20.0
                        : ((containerWidth - 350.0) / 2).clamp(10.0, 20.0),
                    width: containerWidth >= 390
                        ? 350.0
                        : (containerWidth - 40.0).clamp(280.0, 350.0),
                    height: 48.0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      opacity: _isSearchOpen ? 1.0 : 0.0,
                      child: IgnorePointer(
                        ignoring: !_isSearchOpen,
                        child: Container(
                          key: const Key('header_search_bar_container'),
                          width: containerWidth >= 390
                              ? 350.0
                              : (containerWidth - 40.0).clamp(280.0, 350.0),
                          height: 48.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: const Color(0xFFEDF0EF),
                              width: 1.2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0F000000), // #0000000F
                                blurRadius: 10.0,
                                offset: Offset(0, 2),
                                spreadRadius: 0.0,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CustomPaint(
                                size: Size(16.0, 16.0),
                                painter: _SearchVectorPainter(
                                  color: Color(0xFF566663),
                                ),
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  style: GoogleFonts.inter(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF1C2926),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search nearby providers...',
                                    hintStyle: GoogleFonts.inter(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF8F9E9B),
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (_searchController.text.isNotEmpty) {
                                    _searchController.clear();
                                  } else {
                                    setState(() {
                                      _isSearchOpen = false;
                                    });
                                  }
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: const EdgeInsets.all(4.0),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    size: 18.0,
                                    color: Color(0xFF566663),
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

  /// Providers to show widget matching Figma branding from pickup screen:
  Widget _buildProvidersInnerCard(double containerWidth) {
    final double cardWidth = containerWidth >= 390
        ? 350.0
        : (containerWidth - 40.0).clamp(280.0, 350.0);

    return SizedBox(
      width: cardWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Heading Branding Row (36x36 icon + title + subtitle)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side icon branding: width: 36; height: 36; border-radius: 40px; background: #F0F5F2;
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F5F2),
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: const Center(
                  // Vector branding: dual user silhouettes matching Figma
                  child: CustomPaint(
                    size: Size(20.0, 19.0),
                    painter: _ProviderGroupVectorPainter(
                      color: Color(0xFF1D8070),
                      backgroundColor: Color(0xFFF0F5F2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0), // gap: 12px;

              // Inner content branding: width: 302; gap: 12px;
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Content: Providers to show (16px, weight 500, line-height 22px, #1C2926)
                    Text(
                      'Providers to show',
                      textHeightBehavior: const TextHeightBehavior(
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
                    const SizedBox(height: 3.0),
                    // Content: Adjust the number of providers on the map. (12px, weight 400, line-height 22px, #566663)
                    Text(
                      'Adjust the number of providers on the map.',
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 12.0,
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
            ],
          ),

          const SizedBox(height: 16.0), // gap: 16px;

          // 2. Buttons layout: width: 350; height: 44.400001525878906; gap: 8px;
          SizedBox(
            width: cardWidth,
            height: 44.4,
            child: Row(
              children: [
                Expanded(child: _buildCountButton(10)),
                const SizedBox(width: 8.0), // gap: 8px;
                Expanded(child: _buildCountButton(20)),
                const SizedBox(width: 8.0), // gap: 8px;
                Expanded(child: _buildCountButton(30)),
              ],
            ),
          ),

          const SizedBox(height: 16.0),

          // Bar branding:
          // width: 350; height: 1; angle: 0 deg; opacity: 1; border-radius: 16px; background: #F4F5F2;
          Container(
            key: const Key('providers_to_show_divider_bar'),
            width: cardWidth,
            height: 1.0,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5F2),
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),

          const SizedBox(height: 16.0),

          // 4. Total number of providers layout widget branding:
          // width: 350; height: 42; justify-content: space-between;
          _buildTotalProvidersLayout(cardWidth),
        ],
      ),
    );
  }

  /// Total number of providers layout widget matching exact Figma specifications:
  /// width: 350; height: 42; justify-content: space-between; angle: 0 deg; opacity: 1;
  Widget _buildTotalProvidersLayout(double cardWidth) {
    return SizedBox(
      width: cardWidth,
      height: 42.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side content layout: width: 152; gap: 12px;
          SizedBox(
            width: 152.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // content: 18 Providers nearby
                // width: 152; height: 12; font-family: Inter; font-weight: 500; font-size: 16px; leading-trim: CAP_HEIGHT; line-height: 22px; color: #1C2926;
                Text(
                  '18 Providers nearby',
                  textHeightBehavior: const TextHeightBehavior(
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
                // content: Within 1 km radius
                // width: 152; height: 9; font-family: Inter; font-weight: 400; font-size: 12px; leading-trim: CAP_HEIGHT; line-height: 22px; color: #566663;
                Text(
                  'Within 1 km radius',
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
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

          // Right side content layout:
          // width: 117; height: 42; angle: 0 deg; opacity: 1; border-radius: 60px; gap: 12px; padding: 16px; background: #F2F5F4;
          GestureDetector(
            key: const Key('view_all_providers_chip'),
            onTap: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Viewing all providers nearby',
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: const Color(0xFF1D8070),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 117.0,
              height: 42.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F5F4),
                borderRadius: BorderRadius.circular(60.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // vector arrow up and down branding: width: 12; height: 10; angle: 0 deg; opacity: 1; background: #1C2926;
                  const CustomPaint(
                    size: Size(12.0, 10.0),
                    painter: _ArrowUpDownVectorPainter(
                      color: Color(0xFF1C2926),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  // content: View All
                  // width: 45; height: 9; font-family: Inter; font-weight: 400; font-size: 12px; leading-trim: CAP_HEIGHT; line-height: 22px; color: #1C2926;
                  Text(
                    'View All',
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF1C2926),
                      height: 1.15,
                      letterSpacing: 0.0,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(width: 8.0),
                  // vector > branding: width: 4; height: 8; angle: -180 deg; opacity: 1; border-width: 0.6px; border: 0.6px solid #1C2926;
                  const CustomPaint(
                    size: Size(4.0, 8.0),
                    painter: _ChevronRightVectorPainter(
                      color: Color(0xFF1C2926),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Services cards layout branding:
  /// Smooth scrolling with mouse drag, trackpad, and touch support across all platforms
  Widget _buildServicesCardsLayout(double containerWidth) {
    final double cardWidth = containerWidth >= 390
        ? 350.0
        : (containerWidth - 40.0).clamp(280.0, 350.0);

    return ScrollConfiguration(
      behavior: const _EasyScrollBehavior(),
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 2.0, bottom: 28.0),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _selectedProviderCount,
        separatorBuilder: (context, index) => const SizedBox(height: 12.0), // gap: 12px;
        itemBuilder: (context, index) => _buildServiceCard(cardWidth, index),
      ),
    );
  }

  /// Card branding strictly matching user screenshot:
  /// Left: Car Image (60x40)
  /// Center: Ahmad Raza (15px w600), Sedan . AC (12px w400), ★ 4.9 (120) [Available]
  /// Right: Navigation arrow 0.3 km, 2 min away, Circular Call Button (38x38)
  Widget _buildServiceCard(double cardWidth, int index) {
    final baseItem = _nearbyProviders[index % _nearbyProviders.length];

    // Card 0 is strictly Ahmad Raza from screenshot, subsequent cards vary realistically
    final String providerName = index == 0
        ? 'Ahmad Raza'
        : index == 1
            ? 'Muhammad Bilal'
            : index == 2
                ? 'Usman Ali'
                : index == 3
                    ? 'Hamza Sheikh'
                    : 'Provider ${index + 1}';

    final String imagePath = index % 3 == 2
        ? 'assets/images/pickup.png'
        : 'assets/images/car_ride.png';

    final String vehicleType = index % 3 == 2
        ? 'Pickup . AC'
        : 'Sedan . AC';

    final double distanceKm = 0.3 + (index * 0.25);
    final int etaMin = 2 + (index * 2);
    final String distanceStr = '${distanceKm.toStringAsFixed(1)} km';
    final String etaStr = '$etaMin min away';

    final double rating = index == 0
        ? 4.9
        : (4.7 + ((index * 3) % 4) * 0.1).clamp(4.6, 5.0);

    final int reviews = index == 0
        ? 120
        : (75 + ((index * 19) % 80));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProviderDetailScreen(
                serviceCategory: widget.serviceCategory,
                providerName: providerName,
              ),
            ),
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: cardWidth,
          height: 78.0,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000), // #0000001A
                blurRadius: 12.0,
                offset: Offset(0, 1),
                spreadRadius: 0.0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0), // padding: 16px;
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // justify-content: space-between;
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side layout branding of card: width: 195; height: 46; gap: 12px;
              SizedBox(
                width: 195.0,
                height: 46.0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // img branding: width: 60; height: 40;
                    SizedBox(
                      width: 60.0,
                      height: 40.0,
                      child: Image.asset(
                        imagePath,
                        width: 60.0,
                        height: 40.0,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F5F2),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: const Icon(
                            Icons.directions_car_filled,
                            size: 22,
                            color: Color(0xFF1D8070),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0), // gap: 12px;

                    // content layout: width: 123; height: 46; gap: 12px;
                    SizedBox(
                      width: 123.0,
                      height: 46.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // name branding: width: 72; height: 9; gap: 8px;
                          SizedBox(
                            width: 123.0,
                            height: 16.0,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                providerName,
                                textHeightBehavior: const TextHeightBehavior(
                                  applyHeightToFirstAscent: false,
                                  applyHeightToLastDescent: false,
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1C2926),
                                  height: 1.15,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ),

                          // review and text layout (width: 60; height: 25; gap: 8px) + available badge layout (width: 42; height: 14; gap: 10px; border-radius: 60px; padding: 4px)
                          SizedBox(
                            width: 123.0,
                            height: 25.0,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // review and text layout: width: 60; height: 25; gap: 8px; angle: 0 deg; opacity: 1;
                                SizedBox(
                                  width: 60.0,
                                  height: 25.0,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          size: 13.0,
                                          color: Color(0xFF1D8070),
                                        ),
                                        const SizedBox(width: 2.0),
                                        Text(
                                          '$rating',
                                          style: GoogleFonts.inter(
                                            fontSize: 11.0,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1C2926),
                                          ),
                                        ),
                                        const SizedBox(width: 2.0),
                                        Text(
                                          '($reviews)',
                                          style: GoogleFonts.inter(
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF566663),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0), // gap: 8px;

                                // available badge layout: width: 42; height: 14; gap: 10px; angle: 0 deg; opacity: 1; border-radius: 60px; padding: 4px;
                                Container(
                                  width: 42.0,
                                  height: 14.0,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEDF6F3),
                                    borderRadius: BorderRadius.circular(60.0),
                                  ),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      baseItem.status,
                                      style: GoogleFonts.inter(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF1D8070),
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

              // Right side: distance and time layout + call button layout
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // distance and time layout: width: 54; height: 29; gap: 12px; angle: 0 deg; opacity: 1;
                  SizedBox(
                    width: 54.0,
                    height: 29.0,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Transform.rotate(
                                angle: -math.pi / 4.0,
                                child: const Icon(
                                  Icons.navigation,
                                  size: 10.0,
                                  color: Color(0xFF1C2926),
                                ),
                              ),
                              const SizedBox(width: 2.0),
                              Text(
                                distanceStr,
                                style: GoogleFonts.inter(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1C2926),
                                  height: 1.15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            etaStr,
                            style: GoogleFonts.inter(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF566663),
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8.0),

                  // call button layout: width: 32; height: 32; angle: 0 deg; opacity: 1; border-radius: 60px; border-width: 0.6px; background: #F5F7F7; border: 0.6px solid #F0F2F2
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Calling $providerName (${baseItem.phone})...',
                            style: GoogleFonts.inter(fontSize: 12.0, color: Colors.white),
                          ),
                          backgroundColor: const Color(0xFF1D8070),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 32.0,
                      height: 32.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7F7),
                        borderRadius: BorderRadius.circular(60.0),
                        border: Border.all(
                          color: const Color(0xFFF0F2F2),
                          width: 0.6,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.phone_rounded,
                          size: 15.0,
                          color: Color(0xFF1C2926),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Button branding matching Figma specifications:
  /// Selected (10 default): background: #1D8070; content: #FFFFFF; font: Inter 500, 15px
  /// Unselected (20, 30): border: 1.2px solid #EDF0EF; content: #1C2926; font: Inter 500, 15px
  Widget _buildCountButton(int count) {
    final bool isSelected = _selectedProviderCount == count;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedProviderCount = count;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44.4,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1D8070) : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: isSelected
              ? null
              : Border.all(
                  color: const Color(0xFFEDF0EF),
                  width: 1.2,
                ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x261D8070),
                    blurRadius: 6.0,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          '$count',
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
          style: GoogleFonts.inter(
            fontSize: 15.0,
            fontWeight: FontWeight.w500,
            color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF1C2926),
            height: 1.2,
            letterSpacing: 0.0,
          ),
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

/// Search vector icon matching user design:
/// Geometric circular lens with straight 45-degree angle handle to bottom-right
class _SearchVectorPainter extends CustomPainter {
  final Color color;
  const _SearchVectorPainter({this.color = const Color(0xFF1C2926)});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // Center and radius of the magnifying glass ring
    final center = Offset(size.width * 0.42, size.height * 0.42);
    final radius = size.width * 0.32;

    // Draw circular lens
    canvas.drawCircle(center, radius, strokePaint);

    // Draw handle at 45 degree angle
    const angle = math.pi / 4.0;
    final handleStart = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    final handleEnd = Offset(
      size.width - 1.0,
      size.height - 1.0,
    );

    canvas.drawLine(handleStart, handleEnd, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SearchVectorPainter oldDelegate) => color != oldDelegate.color;
}

/// Vector group/providers branding matching Figma specifications:
/// Dual user silhouettes (foreground user + background user with cutout contour)
class _ProviderGroupVectorPainter extends CustomPainter {
  final Color color;
  final Color backgroundColor;

  const _ProviderGroupVectorPainter({
    this.color = const Color(0xFF1D8070),
    this.backgroundColor = const Color(0xFFF0F5F2),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final cutoutPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    // Scale / center within the provided size (normalized around 20.0 x 19.0)
    final double scaleX = size.width / 20.0;
    final double scaleY = size.height / 19.0;
    canvas.save();
    canvas.scale(scaleX, scaleY);

    // --- 1. Background Person (Person 2 - Right side) ---
    // Head 2
    canvas.drawCircle(const Offset(14.5, 4.4), 3.6, fillPaint);

    // Torso 2 (shoulder peeking out on right)
    final body2RRect = RRect.fromRectAndCorners(
      const Rect.fromLTRB(9.5, 10.8, 18.2, 18.2),
      topLeft: const Radius.circular(5.0),
      topRight: const Radius.circular(5.0),
      bottomLeft: const Radius.circular(3.2),
      bottomRight: const Radius.circular(3.2),
    );
    canvas.drawRRect(body2RRect, fillPaint);

    // --- 2. Cutout Contour of Foreground Person (creates transparent gap) ---
    // Head 1 cutout
    canvas.drawCircle(const Offset(7.0, 4.8), 3.8, cutoutPaint);

    // Torso 1 cutout
    final body1RRect = RRect.fromRectAndCorners(
      const Rect.fromLTRB(0.8, 10.8, 13.2, 18.2),
      topLeft: const Radius.circular(5.0),
      topRight: const Radius.circular(5.0),
      bottomLeft: const Radius.circular(3.2),
      bottomRight: const Radius.circular(3.2),
    );
    canvas.drawRRect(body1RRect, cutoutPaint);

    // --- 3. Foreground Person (Person 1 - Left side) ---
    // Head 1 fill
    canvas.drawCircle(const Offset(7.0, 4.8), 3.8, fillPaint);

    // Torso 1 fill
    canvas.drawRRect(body1RRect, fillPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ProviderGroupVectorPainter oldDelegate) =>
      color != oldDelegate.color || backgroundColor != oldDelegate.backgroundColor;
}

/// Vector arrow up and down branding matching Figma specifications:
/// width: 12; height: 10; angle: 0 deg; opacity: 1; background: #1C2926;
class _ArrowUpDownVectorPainter extends CustomPainter {
  final Color color;
  const _ArrowUpDownVectorPainter({this.color = const Color(0xFF1C2926)});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Up arrow on left (x = 3.0):
    canvas.drawLine(const Offset(3.0, 9.0), const Offset(3.0, 1.5), strokePaint);
    final upHead = Path()
      ..moveTo(0.8, 3.8)
      ..lineTo(3.0, 1.5)
      ..lineTo(5.2, 3.8);
    canvas.drawPath(upHead, strokePaint);

    // Down arrow on right (x = 9.0):
    canvas.drawLine(const Offset(9.0, 1.0), const Offset(9.0, 8.5), strokePaint);
    final downHead = Path()
      ..moveTo(6.8, 6.2)
      ..lineTo(9.0, 8.5)
      ..lineTo(11.2, 6.2);
    canvas.drawPath(downHead, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _ArrowUpDownVectorPainter oldDelegate) => color != oldDelegate.color;
}

/// Vector chevron right matching Figma specifications:
/// width: 4; height: 8; angle: -180 deg; opacity: 1; border-width: 0.6px; border: 0.6px solid #1C2926;
class _ChevronRightVectorPainter extends CustomPainter {
  final Color color;
  const _ChevronRightVectorPainter({this.color = const Color(0xFF1C2926)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0.5, 0.5)
      ..lineTo(size.width - 0.5, size.height / 2.0)
      ..lineTo(0.5, size.height - 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
