import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale.dart';
import '../../../models/provider_model.dart';
import '../../../providers/backend_provider.dart';
import '../../../services/location_service.dart';
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

  AppTranslations get tr => ref.read(translationsProvider);

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

    ref.watch(translationsProvider);

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

            final tr = ref.watch(translationsProvider);
            final userLocAsync = ref.watch(userLocationProvider);
            final userLoc = userLocAsync.value ?? UserLocation.defaultLocation;

            final nearbyProvidersAsync = ref.watch(nearbyProvidersProvider);
            final List<ProviderMarkerModel> liveProviders = nearbyProvidersAsync.value ?? [];

            final String searchQuery = _searchController.text.trim().toLowerCase();
            final List<ProviderMarkerModel> filteredProviders = searchQuery.isEmpty
                ? liveProviders
                : liveProviders.where((p) {
                    return p.name.toLowerCase().contains(searchQuery) ||
                        p.categoryName.toLowerCase().contains(searchQuery) ||
                        p.coordinatesDisplay.contains(searchQuery);
                  }).toList();

            final int itemsCount = filteredProviders.isNotEmpty
                ? math.min(_selectedProviderCount, filteredProviders.length)
                : _selectedProviderCount;

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
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              tr.gpsDetecting,
                              style: tr.font(
                                fontSize: 12.0,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: const Color(0xFF8B53FE),
                            duration: const Duration(milliseconds: 1000),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );

                        final freshLoc = await ref.read(locationServiceProvider).getCurrentLocation();
                        ref.refresh(userLocationProvider);
                        ref.refresh(nearbyProvidersProvider);

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              freshLoc.isGpsDetected
                                  ? (tr.isArabic
                                      ? 'تحديد تلقائي: ${freshLoc.coordinatesDisplay} (${freshLoc.cityName})'
                                      : 'GPS: ${freshLoc.coordinatesDisplay} (${freshLoc.cityName})')
                                  : (tr.isArabic
                                      ? 'الموقع: ${freshLoc.cityName}'
                                      : 'Location: ${freshLoc.cityName}'),
                              style: tr.font(
                                fontSize: 12.0,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: const Color(0xFF8B53FE),
                            duration: const Duration(seconds: 2),
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
                            color: Color(0xFF8B53FE),
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
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Text(
                              tr.nearbyProviders,
                              textHeightBehavior: const TextHeightBehavior(
                                applyHeightToFirstAscent: false,
                                applyHeightToLastDescent: false,
                              ),
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
                                    ? Border.all(color: const Color(0xFF8B53FE), width: 1.2)
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
                                        ? const Color(0xFF8B53FE)
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
                    height: containerHeight > 162.0 ? (containerHeight - 162.0) : 520.0,
                    child: Container(
                      key: const Key('nearby_providers_card_layout'),
                      width: containerWidth,
                      height: containerHeight > 162.0 ? (containerHeight - 162.0) : 520.0,
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
                              left: ((containerWidth - cardWidth) / 2.0).clamp(12.0, 60.0),
                              right: ((containerWidth - cardWidth) / 2.0).clamp(12.0, 60.0),
                              bottom: 80.0,
                            ),
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            children: [
                              // 1. Header controls (Providers to show, buttons, bar, total providers):
                              Center(child: _buildProvidersInnerCard(containerWidth, filteredProviders.length, userLoc)),

                              const SizedBox(height: 16.0),

                              // 2. Services cards:
                              ...List.generate(
                                itemsCount,
                                (index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Center(
                                    child: _buildServiceCard(cardWidth, index, filteredProviders),
                                  ),
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
                                  style: tr.font(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF1C2926),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: tr.isArabic ? 'ابحث عن مزودي الخدمة...' : 'Search nearby providers...',
                                    hintStyle: tr.font(
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
                color: const Color(0xFFF0F1F5),
                child: Center(
                  child: Container(
                    width: containerWidth,
                    height: containerHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(42),
                      border: Border.all(
                        color: const Color(0xFF8B53FE).withValues(alpha: 0.25),
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
  Widget _buildProvidersInnerCard(double containerWidth, [int? totalCount, UserLocation? userLoc]) {
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
              // Left side icon branding: width: 36; height: 36; border-radius: 40px; background: #F0EAFE;
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EAFE),
                  borderRadius: BorderRadius.circular(40.0),
                ),
                child: const Center(
                  // Vector branding: dual user silhouettes matching Figma
                  child: CustomPaint(
                    size: Size(20.0, 19.0),
                    painter: _ProviderGroupVectorPainter(
                      color: Color(0xFF8B53FE),
                      backgroundColor: Color(0xFFF0EAFE),
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
                      tr.isArabic ? 'عدد المزودين المعروضين' : 'Providers to show',
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                      style: tr.font(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1C2926),
                        height: 1.15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3.0),
                    // Content: Adjust the number of providers on the map. (12px, weight 400, line-height 22px, #566663)
                    Text(
                      tr.isArabic ? 'حدد عدد المزودين الظاهرين على الخريطة.' : 'Adjust the number of providers on the map.',
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                      style: tr.font(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF566663),
                        height: 1.15,
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
          _buildTotalProvidersLayout(cardWidth, totalCount, userLoc),
        ],
      ),
    );
  }

  /// Total number of providers layout widget matching exact Figma specifications:
  /// width: 350; height: 42; justify-content: space-between; angle: 0 deg; opacity: 1;
  Widget _buildTotalProvidersLayout(double cardWidth, [int? totalCount, UserLocation? userLoc]) {
    return SizedBox(
      width: cardWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side content layout: gap: 12px;
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // content: 18 Providers nearby
                // width: 152; height: 12; font-family: Inter; font-weight: 500; font-size: 16px; leading-trim: CAP_HEIGHT; line-height: 22px; color: #1C2926;
                Text(
                  tr.providersNearbyCount(totalCount != null && totalCount > 0 ? totalCount : 18),
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                  style: tr.font(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1C2926),
                    height: 1.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2.0),
                // content: Within 1 km radius • locality
                Text(
                  (userLoc != null && userLoc.cityName.isNotEmpty && userLoc.cityName != 'Detecting Location...')
                      ? (tr.isArabic
                          ? 'ضمن نطاق 1 كم • ${userLoc.cityName == 'Karachi Pakistan' ? 'كراتشي، باكستان' : userLoc.cityName}'
                          : 'Within 1 km radius • ${userLoc.cityName}')
                      : tr.withinRadius,
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                  ),
                  style: tr.font(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF566663),
                    height: 1.15,
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
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              constraints: const BoxConstraints(minHeight: 42.0, minWidth: 100.0),
              decoration: BoxDecoration(
                color: const Color(0xFF8B53FE),
                borderRadius: BorderRadius.circular(60.0),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x338B53FE),
                    blurRadius: 6.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // vector arrow up and down branding
                  const CustomPaint(
                    size: Size(12.0, 10.0),
                    painter: _ArrowUpDownVectorPainter(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  // content: View All
                  Text(
                    tr.viewAll,
                    style: tr.font(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      height: 1.15,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(width: 8.0),
                  // vector > branding
                  Transform.scale(
                    scaleX: tr.isArabic ? -1.0 : 1.0,
                    child: const CustomPaint(
                      size: Size(4.0, 8.0),
                      painter: _ChevronRightVectorPainter(
                        color: Colors.white,
                      ),
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
  /// Equal gap from left to right and equal 12px gap between cards
  Widget _buildServicesCardsLayout(double containerWidth) {
    final double cardWidth = containerWidth >= 390
        ? 350.0
        : (containerWidth - 32.0).clamp(280.0, 350.0);
    final double horizontalGap = ((containerWidth - cardWidth) / 2.0).clamp(12.0, 40.0);

    return ScrollConfiguration(
      behavior: const _EasyScrollBehavior(),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: horizontalGap, vertical: 12.0),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _selectedProviderCount,
        separatorBuilder: (context, index) => const SizedBox(height: 12.0), // gap: 12px;
        itemBuilder: (context, index) => Center(
          child: _buildServiceCard(cardWidth, index),
        ),
      ),
    );
  }

  /// Card branding matching exact Figma specifications:
  /// card layout:
  /// width: 350; height: 78; border-radius: 12px; justify-content: space-between;
  /// angle: 0 deg; opacity: 1; padding: 16px;
  /// background: #FFFFFF; box-shadow: 0px 1px 12px 0px #0000001A;
  ///
  /// left side content layout: width: 195; height: 46; gap: 12px;
  /// left side img branding: width: 60; height: 40; angle: -180 deg; opacity: 1;
  /// content branding: width: 123; height: 46; gap: 12px;
  /// row 1 name branding: Ahmad Raza, 12px Inter Medium (500), #1C2926;
  /// row 2 and 3 layout: width: 123; height: 25; gap: 24px;
  /// text layout: width: 57; height: 25; gap: 8px;
  ///   content: Sedan . AC, 10px Inter Regular (400), #566663;
  ///   row 3 layout: width: 57; height: 10; gap: 4px;
  ///     star branding: width: 10; height: 10; background: #8B53FE;
  ///     content: 4.9 (120), 10px Inter Regular (400);
  /// available badge layout: width: 42; height: 14; border-radius: 60px; padding: 4px; background: #F0EAFE;
  ///   content: Available, 8px Inter Regular (400), #8B53FE;
  ///
  /// right side content layout:
  /// distance and timer layout: width: 54; height: 29; gap: 12px;
  ///   distance layout: width: 54; height: 10; gap: 4px;
  ///     send vector branding: width: 10; height: 10; background: #1C2926;
  ///     content: 0.3 km, 12px Inter Medium (500), #1C2926;
  ///   timer layout: 2 min away, 10px Inter Regular (400), #566663;
  /// call icon layout: width: 36; height: 36; border-radius: 60px; border-width: 0.6px; background: #F5F7F7;
  ///   call icon inner branding: width: 12; height: 12; background: #1C2926;
  Widget _buildServiceCard(double cardWidth, int index, [List<ProviderMarkerModel>? liveProviders]) {
    final ProviderMarkerModel? liveItem =
        (liveProviders != null && index < liveProviders.length)
            ? liveProviders[index]
            : null;

    final baseItem = _nearbyProviders[index % _nearbyProviders.length];

    // Card 0 is strictly Ahmad Raza from specs, subsequent cards vary realistically
    final String providerName = liveItem != null
        ? tr.formatProviderName(liveItem.name)
        : (index == 0
            ? (tr.isArabic ? 'أحمد رضا' : 'Ahmad Raza')
            : index == 1
                ? (tr.isArabic ? 'محمد بلال' : 'Muhammad Bilal')
                : index == 2
                    ? (tr.isArabic ? 'عثمان علي' : 'Usman Ali')
                    : index == 3
                        ? (tr.isArabic ? 'حمزة شيخ' : 'Hamza Sheikh')
                        : (tr.isArabic ? 'مزود خدمة ${index + 1}' : 'Provider ${index + 1}'));

    final String imagePath = (liveItem?.categorySlug == 'pickup' || index % 3 == 2)
        ? 'assets/images/pickup.png'
        : 'assets/images/car_ride.png';

    final String vehicleType = liveItem != null
        ? '${tr.categoryName(liveItem.categoryName)} • ${tr.isArabic ? 'مكيف' : 'AC'}'
        : (index % 3 == 2
            ? '${tr.isArabic ? 'شاحنة نقل' : 'Pickup'} • ${tr.isArabic ? 'مكيف' : 'AC'}'
            : '${tr.isArabic ? 'سيدان' : 'Sedan'} • ${tr.isArabic ? 'مكيف' : 'AC'}');

    final double distanceKm = liveItem?.distanceKm ?? (0.3 + (index * 0.25));
    final String etaStr = tr.isArabic
        ? 'على بعد ${2 + (index * 2)} د'
        : (liveItem?.etaDisplay ?? ('${2 + (index * 2)} min away'));
    final String distanceStr = tr.isArabic
        ? '${distanceKm.toStringAsFixed(1)} كم'
        : '${distanceKm.toStringAsFixed(1)} km';

    final double rating = liveItem?.ratingAvg ??
        (index == 0
            ? 4.9
            : (4.7 + ((index * 3) % 4) * 0.1).clamp(4.6, 5.0));

    final int reviews = liveItem?.ratingCount ??
        (index == 0
            ? 120
            : (75 + ((index * 19) % 80)));

    final double effectiveWidth = math.min(350.0, cardWidth);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProviderDetailScreen(
                serviceCategory: tr.categoryName(liveItem?.categoryName ?? widget.serviceCategory),
                providerName: providerName,
              ),
            ),
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: effectiveWidth,
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side content: Image + Details
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Provider vehicle image
                    SizedBox(
                      width: 54.0,
                      height: 38.0,
                      child: Transform.flip(
                        flipX: true,
                        child: Image.asset(
                          imagePath,
                          width: 54.0,
                          height: 38.0,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 54.0,
                            height: 38.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0EAFE),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: const Icon(
                              Icons.directions_car_filled,
                              size: 20,
                              color: Color(0xFF8B53FE),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0), // gap: 10px;

                    // Content details column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Provider Name
                          Text(
                            providerName,
                            textHeightBehavior: const TextHeightBehavior(
                              applyHeightToFirstAscent: false,
                              applyHeightToLastDescent: false,
                            ),
                            style: tr.font(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C2926),
                              height: 1.15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2.0),

                          // Vehicle Type and Available badge row
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  vehicleType,
                                  textHeightBehavior: const TextHeightBehavior(
                                    applyHeightToFirstAscent: false,
                                    applyHeightToLastDescent: false,
                                  ),
                                  style: tr.font(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF566663),
                                    height: 1.15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6.0),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0EAFE),
                                  borderRadius: BorderRadius.circular(60.0),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  tr.isArabic ? 'متاح' : 'Available',
                                  textHeightBehavior: const TextHeightBehavior(
                                    applyHeightToFirstAscent: false,
                                    applyHeightToLastDescent: false,
                                  ),
                                  style: tr.font(
                                    fontSize: 8.0,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF8B53FE),
                                    height: 1.15,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2.0),

                          // Rating and Reviews
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 11.0,
                                color: Color(0xFF8B53FE),
                              ),
                              const SizedBox(width: 3.0),
                              RichText(
                                textHeightBehavior: const TextHeightBehavior(
                                  applyHeightToFirstAscent: false,
                                  applyHeightToLastDescent: false,
                                ),
                                text: TextSpan(
                                  text: '${rating.toStringAsFixed(1)} ',
                                  style: tr.font(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1C2926),
                                    height: 1.15,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '($reviews)',
                                      style: tr.font(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF566663),
                                        height: 1.15,
                                      ),
                                    ),
                                  ],
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
              const SizedBox(width: 8.0),

              // Right side content: Distance, Timer & Call Icon
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Distance row
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.rotate(
                            angle: -math.pi / 4.0,
                            child: const Icon(
                              Icons.navigation,
                              size: 9.0,
                              color: Color(0xFF1C2926),
                            ),
                          ),
                          const SizedBox(width: 3.0),
                          Text(
                            distanceStr,
                            textHeightBehavior: const TextHeightBehavior(
                              applyHeightToFirstAscent: false,
                              applyHeightToLastDescent: false,
                            ),
                            style: tr.font(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C2926),
                              height: 1.15,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2.0),

                      // ETA Timer
                      Text(
                        etaStr,
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false,
                        ),
                        style: tr.font(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF566663),
                          height: 1.15,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                  const SizedBox(width: 10.0), // gap: 10px;

                  // Call icon
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            liveItem != null
                                ? (tr.isArabic
                                    ? 'جارٍ الاتصال بـ $providerName...'
                                    : 'Calling $providerName (GPS: ${liveItem.coordinatesDisplay})...')
                                : (tr.isArabic
                                    ? 'جارٍ الاتصال بـ $providerName...'
                                    : 'Calling $providerName (${baseItem.phone})...'),
                            style: tr.font(fontSize: 12.0, color: Colors.white),
                          ),
                          backgroundColor: const Color(0xFF8B53FE),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 36.0,
                      height: 36.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7F7),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE2E8E6),
                          width: 0.6,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.phone,
                        size: 13.0,
                        color: Color(0xFF1C2926),
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
  /// Selected (10 default): background: #8B53FE; content: #FFFFFF; font: Inter 500, 15px
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
          color: isSelected ? const Color(0xFF8B53FE) : Colors.white,
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
                    color: Color(0x268B53FE),
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
          style: tr.font(
            fontSize: 15.0,
            fontWeight: FontWeight.w500,
            color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF1C2926),
            height: 1.2,
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
    this.color = const Color(0xFF8B53FE),
    this.backgroundColor = const Color(0xFFF0EAFE),
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
