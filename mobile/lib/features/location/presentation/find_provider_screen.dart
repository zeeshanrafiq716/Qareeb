import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_locale.dart';
import '../../../models/provider_model.dart';
import '../../../providers/backend_provider.dart';
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
            final double horizontalPadding = isDesktopWeb
                ? 20.0
                : (containerWidth > 420.0
                    ? ((containerWidth - 380.0) / 2.0).clamp(16.0, 40.0)
                    : 20.0);
            final double cardWidth = containerWidth - (horizontalPadding * 2.0);
            final double containerHeight = isDesktopWeb
                ? math.min(844.0, (constraints.maxHeight - 32.0).clamp(520.0, 844.0))
                : constraints.maxHeight;

            final tr = ref.watch(translationsProvider);
            final nearbyProvidersAsync = ref.watch(nearbyProvidersProvider);
            final List<ProviderMarkerModel> liveProviders = nearbyProvidersAsync.value ?? [];

            final String searchQuery = _searchController.text.trim().toLowerCase();
            final List<ProviderMarkerModel> searchedProviders = searchQuery.isEmpty
                ? liveProviders
                : liveProviders.where((p) {
                    return p.name.toLowerCase().contains(searchQuery) ||
                        p.categoryName.toLowerCase().contains(searchQuery) ||
                        '${p.distanceKm} km'.contains(searchQuery);
                  }).toList();

            final List<ProviderMarkerModel> activeProviders = searchedProviders
                .take(_selectedProviderCount)
                .toList();

            final double statusBarHeight = MediaQuery.of(context).padding.top;
            final double topInset = statusBarHeight > 0 ? statusBarHeight + 12.0 : 44.0;

            final screenContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: const Color(0xFFF8F9FA),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: topInset),

                  // 1. Header Branding (Back Button, Nearby Providers, Search Button):
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: SizedBox(
                      width: cardWidth,
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
                                  scaleX: (tr.isArabic || Directionality.of(context) == TextDirection.rtl) ? -1.0 : 1.0,
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
                                    color: Color(0x0F000000),
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

                  // 2. Animated Search Bar:
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 220),
                    crossFadeState: _isSearchOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    firstChild: const SizedBox(width: double.infinity, height: 0.0),
                    secondChild: Padding(
                      padding: EdgeInsets.only(
                        top: 12.0,
                        left: horizontalPadding,
                        right: horizontalPadding,
                      ),
                      child: Container(
                        key: const Key('header_search_bar_container'),
                        width: cardWidth,
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
                              color: Color(0x0F000000),
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

                  const SizedBox(height: 16.0),

                  // 3. Provider List with smooth scrolling:
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: const _EasyScrollBehavior(),
                      child: ListView(
                        padding: EdgeInsets.only(
                          top: 4.0,
                          left: horizontalPadding,
                          right: horizontalPadding,
                          bottom: 40.0,
                        ),
                        physics: const ClampingScrollPhysics(),
                        children: [
                          Center(child: _buildProvidersInnerCard(cardWidth)),

                          const SizedBox(height: 16.0),

                          if (activeProviders.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 36.0),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 56.0,
                                      height: 56.0,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF0EAFE),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.person_search_rounded,
                                          size: 28.0,
                                          color: Color(0xFF8B53FE),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16.0),
                                    Text(
                                      tr.isArabic ? 'لا يوجد مزودين متاحين حالياً' : 'No providers available nearby',
                                      style: tr.font(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1C2926),
                                      ),
                                    ),
                                    const SizedBox(height: 6.0),
                                    Text(
                                      tr.isArabic
                                          ? 'سيظهر المزودون المعتمدون هنا عند تواجدهم بالقرب منك.'
                                          : 'Approved providers will appear here when active nearby.',
                                      style: tr.font(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF718096),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...activeProviders.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Center(
                                  child: _buildServiceCard(cardWidth, item),
                                ),
                              ),
                            ),

                          const SizedBox(height: 16.0),

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
  Widget _buildProvidersInnerCard(double cardWidth) {
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
                        height: tr.isArabic ? 1.0 : 1.15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: tr.isArabic ? 0.0 : 2.0),
                    // Content: Adjust the number of providers on the map. (wrapped without dots)
                    Transform.translate(
                      offset: Offset(0, tr.isArabic ? -3.5 : 0.0),
                      child: Text(
                        tr.isArabic ? 'حدد عدد المزودين المعروضين في القائمة.' : 'Adjust the number of providers to show.',
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false,
                        ),
                        style: tr.font(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF566663),
                          height: tr.isArabic ? 1.05 : 1.15,
                        ),
                        maxLines: 2,
                        softWrap: true,
                      ),
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
        ],
      ),
    );
  }

  /// Card branding matching exact Figma specifications:
  Widget _buildServiceCard(double cardWidth, ProviderMarkerModel item) {
    final String providerName = tr.formatProviderName(item.name);

    final String imagePath = (item.categorySlug.contains('pickup'))
        ? 'assets/images/pickup.png'
        : 'assets/images/car_ride.png';

    final String vehicleType = item.categorySlug.contains('pickup')
        ? (tr.isArabic ? 'بيك أب • مكيف' : 'Pickup • AC')
        : (tr.isArabic ? 'سيدان • مكيف' : 'Sedan • AC');

    final double distanceKm = item.distanceKm > 0 ? item.distanceKm : 1.0;
    final String etaStr = tr.isArabic
        ? '${(distanceKm * 3.5).round().clamp(1, 99)} د'
        : '${(distanceKm * 3.5).round().clamp(1, 99)} min away';
    final String distanceStr = tr.isArabic
        ? '${distanceKm.toStringAsFixed(1)} كم'
        : '${distanceKm.toStringAsFixed(1)} km';

    final double rating = item.ratingAvg > 0 ? item.ratingAvg : 5.0;
    final int reviews = item.ratingCount > 0 ? item.ratingCount : 1;

    final double effectiveWidth = cardWidth;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          final effectivePublicId = item.publicId.isNotEmpty ? item.publicId : 'QRB-${item.id}';
          ref.read(backendServiceProvider).trackCustomerEvent(
            event: 'profile_view',
            providerPublicId: effectivePublicId,
            latitude: item.latitude,
            longitude: item.longitude,
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProviderDetailScreen(
                serviceCategory: tr.categoryName(item.categoryName.isNotEmpty ? item.categoryName : widget.serviceCategory),
                providerName: providerName,
                providerPublicId: effectivePublicId,
              ),
            ),
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: effectiveWidth,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
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
                    // Provider vehicle image (optimized size for mobile screens)
                    SizedBox(
                      width: 48.0,
                      height: 34.0,
                      child: Transform.flip(
                        flipX: true,
                        child: Image.asset(
                          imagePath,
                          width: 48.0,
                          height: 34.0,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 48.0,
                            height: 34.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0EAFE),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: const Icon(
                              Icons.directions_car_filled,
                              size: 18,
                              color: Color(0xFF8B53FE),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0), // gap: 8px;

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

                          // Vehicle Type and Available badge row (Maintains exact original branding)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
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
                              ),
                              const SizedBox(width: 6.0),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
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
                      // Distance row with clean navigation arrow icon
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scaleX: (tr.isArabic || Directionality.of(context) == TextDirection.rtl) ? -1.0 : 1.0,
                            child: const Icon(
                              Icons.near_me_rounded,
                              size: 11.5,
                              color: Color(0xFF8B53FE),
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
                              height: 1.0,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                      SizedBox(height: tr.isArabic ? 0.0 : 1.0),

                      // ETA Timer (gap decreased)
                      Transform.translate(
                        offset: Offset(0, tr.isArabic ? -3.0 : -1.0),
                        child: Text(
                          etaStr,
                          textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                          style: tr.font(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF566663),
                            height: 1.0,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8.0),

                  // Call icon
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      final effectivePublicId = item.publicId.isNotEmpty ? item.publicId : 'QRB-${item.id}';
                      ref.read(backendServiceProvider).trackCustomerEvent(
                        event: 'call_click',
                        providerPublicId: effectivePublicId,
                        latitude: item.latitude,
                        longitude: item.longitude,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            tr.isArabic
                                ? 'جارٍ الاتصال بـ $providerName...'
                                : 'Calling $providerName (GPS: ${item.coordinatesDisplay})...',
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
          color: isSelected ? const Color(0xFF8B53FE) : const Color(0xFF2D2A3D),
          borderRadius: BorderRadius.circular(8.0),
          border: isSelected
              ? null
              : Border.all(
                  color: const Color(0xFF8B53FE).withValues(alpha: 0.3),
                  width: 1.2,
                ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x338B53FE),
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
            color: const Color(0xFFFFFFFF),
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

