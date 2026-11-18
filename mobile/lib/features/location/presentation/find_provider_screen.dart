import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/localization/app_locale.dart';
import '../../../core/utils/contact_launcher.dart';
import '../../../models/category_model.dart';
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

class _FindProviderScreenState extends ConsumerState<FindProviderScreen> {
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int _selectedProviderCount = 10;
  Timer? _refreshTimer;

  AppTranslations get tr => ref.read(translationsProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.invalidate(nearbyProvidersProvider);
    });
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) ref.invalidate(nearbyProvidersProvider);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
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
            final liveCategories = ref.watch(categoriesProvider).value ?? const <CategoryModel>[];
            final streamLoc = ref.watch(userLocationProvider).value;
            final UserLocation? activeUserLoc =
                (streamLoc != null && streamLoc.hasValidDeviceGps)
                    ? streamLoc
                    : LocationService.lastKnownValidLocation;
            final List<ProviderMarkerModel> liveProviders =
                (nearbyProvidersAsync.value ?? []).where((p) => p.isOnline).toList();

            final String searchQuery = _searchController.text.trim().toLowerCase();
            final List<ProviderMarkerModel> searchedProviders = searchQuery.isEmpty
                ? List<ProviderMarkerModel>.from(liveProviders)
                : liveProviders.where((p) {
                    final meters = _computeRealDistanceMeters(p, activeUserLoc);
                    final distText = meters != null
                        ? _formatRealDistance(meters, tr.isArabic).toLowerCase()
                        : '';
                    return p.name.toLowerCase().contains(searchQuery) ||
                        p.categoryName.toLowerCase().contains(searchQuery) ||
                        p.categoryNameAr.toLowerCase().contains(searchQuery) ||
                        p.vehicleType.toLowerCase().contains(searchQuery) ||
                        p.plateNumber.toLowerCase().contains(searchQuery) ||
                        distText.contains(searchQuery);
                  }).toList();

            // Sort by real live distance ascending (nearest real provider first)
            searchedProviders.sort((a, b) {
              final distA = _computeRealDistanceMeters(a, activeUserLoc) ?? double.infinity;
              final distB = _computeRealDistanceMeters(b, activeUserLoc) ?? double.infinity;
              return distA.compareTo(distB);
            });

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
                                onChanged: (_) => setState(() {}),
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
                                  setState(() {});
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

                  // 3. Provider List with smooth scrolling & live pull-to-refresh:
                  Expanded(
                    child: RefreshIndicator(
                      color: const Color(0xFF8B53FE),
                      onRefresh: () async {
                        ref.invalidate(nearbyProvidersProvider);
                        await ref.read(nearbyProvidersProvider.future).catchError((_) => const <ProviderMarkerModel>[]);
                      },
                      child: ScrollConfiguration(
                        behavior: const _EasyScrollBehavior(),
                        child: ListView(
                          padding: EdgeInsets.only(
                            top: 4.0,
                            left: horizontalPadding,
                            right: horizontalPadding,
                            bottom: 40.0,
                          ),
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: ClampingScrollPhysics(),
                          ),
                          children: [
                            Center(child: _buildProvidersInnerCard(cardWidth)),

                            const SizedBox(height: 16.0),

                            if (nearbyProvidersAsync.isLoading && activeProviders.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF8B53FE),
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              )
                            else if (activeProviders.isEmpty)
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
                                    child: _buildServiceCard(
                                      cardWidth,
                                      item,
                                      activeUserLoc: activeUserLoc,
                                      liveCategories: liveCategories,
                                    ),
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

  /// Computes exact live distance in metres between customer GPS and provider GPS.
  /// Never substitutes fake fallback numbers.
  double? _computeRealDistanceMeters(ProviderMarkerModel item, UserLocation? userLoc) {
    final bool hasProviderGps =
        item.latitude.isFinite &&
        item.longitude.isFinite &&
        (item.latitude.abs() > 0.001 || item.longitude.abs() > 0.001);
    if (userLoc != null && userLoc.hasValidDeviceGps && hasProviderGps) {
      final m = Geolocator.distanceBetween(
        userLoc.latitude,
        userLoc.longitude,
        item.latitude,
        item.longitude,
      );
      if (m.isFinite && m >= 0) return m;
    }
    if (item.distanceMeters.isFinite && item.distanceMeters >= 0 && (item.distanceMeters > 0 || hasProviderGps)) {
      return item.distanceMeters;
    }
    if (item.distanceKm.isFinite && item.distanceKm > 0) {
      return item.distanceKm * 1000.0;
    }
    return null;
  }

  String _formatRealDistance(double meters, bool isArabic) {
    if (meters < 1000.0) {
      final rounded = meters.round();
      return isArabic ? '$rounded م' : '$rounded m';
    }
    final km = meters / 1000.0;
    return isArabic ? '${km.toStringAsFixed(1)} كم' : '${km.toStringAsFixed(1)} km';
  }

  String _formatRealEta(double meters, bool isArabic) {
    if (meters < 100.0) {
      return isArabic ? 'أقل من دقيقة' : '< 1 min';
    }
    final mins = ((meters / 1000.0) / 30.0 * 60.0).ceil().clamp(1, 180);
    return isArabic ? '$mins د' : '$mins min';
  }

  /// Resolves the provider's real service image from backend category iconUrl,
  /// matched live category asset, or provider's own uploaded photo (never a fake Sedan).
  Widget _buildRealServiceImage(
    ProviderMarkerModel item,
    List<CategoryModel> liveCategories,
  ) {
    String? networkUrl;
    String? localAsset;

    // 1. Direct category iconUrl from backend discovery payload
    final directIcon = item.categoryIconUrl?.trim() ?? '';
    if (directIcon.startsWith('http://') || directIcon.startsWith('https://')) {
      networkUrl = directIcon;
    } else if (directIcon.startsWith('assets/')) {
      localAsset = directIcon;
    } else if (directIcon.startsWith('/assets/')) {
      localAsset = directIcon.substring(1);
    }

    // 2. Match against live categories synced from backend admin panel
    if (networkUrl == null && localAsset == null && liveCategories.isNotEmpty) {
      final slugLower = item.categorySlug.trim().toLowerCase();
      final nameLower = item.categoryName.trim().toLowerCase();
      for (final cat in liveCategories) {
        if ((slugLower.isNotEmpty && cat.slug.toLowerCase() == slugLower) ||
            (nameLower.isNotEmpty && cat.name.toLowerCase() == nameLower)) {
          final catIcon = cat.iconUrl?.trim() ?? '';
          if (catIcon.startsWith('http://') || catIcon.startsWith('https://')) {
            networkUrl = catIcon;
          } else if (cat.displayAssetImage != null && cat.displayAssetImage!.isNotEmpty) {
            localAsset = cat.displayAssetImage;
          }
          break;
        }
      }
    }

    // 3. Map from provider's real category slug/name to official service image
    if (networkUrl == null &&
        localAsset == null &&
        (item.categorySlug.isNotEmpty || item.categoryName.isNotEmpty)) {
      final resolved = CategoryModel(
        id: 0,
        name: item.categoryName,
        slug: item.categorySlug,
      ).displayAssetImage;
      if (resolved != null && resolved.isNotEmpty) {
        localAsset = resolved;
      }
    }

    // 4. Provider's own uploaded photo if no category image exists
    if (networkUrl == null && localAsset == null) {
      final photo = item.photoUrl?.trim() ?? '';
      if (photo.startsWith('http://') || photo.startsWith('https://')) {
        networkUrl = photo;
      }
    }

    Widget placeholder() => Container(
          width: 52.0,
          height: 44.0,
          decoration: BoxDecoration(
            color: const Color(0xFFF3EEFF),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: const Icon(
            Icons.handyman_rounded,
            size: 22.0,
            color: Color(0xFF8B53FE),
          ),
        );

    if (networkUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          width: 52.0,
          height: 44.0,
          color: const Color(0xFFF8F6FF),
          child: Image.network(
            networkUrl,
            width: 52.0,
            height: 44.0,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => localAsset != null
                ? Image.asset(
                    localAsset,
                    width: 52.0,
                    height: 44.0,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => placeholder(),
                  )
                : placeholder(),
          ),
        ),
      );
    }

    if (localAsset != null) {
      return SizedBox(
        width: 52.0,
        height: 44.0,
        child: Image.asset(
          localAsset,
          width: 52.0,
          height: 44.0,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => placeholder(),
        ),
      );
    }

    return placeholder();
  }

  /// Provider list card displaying 100% real data: service image, vehicle/category,
  /// real rating & reviews, real order counter, live distance, live ETA, and real call action.
  Widget _buildServiceCard(
    double cardWidth,
    ProviderMarkerModel item, {
    required UserLocation? activeUserLoc,
    required List<CategoryModel> liveCategories,
  }) {
    final String providerName = item.name.trim().isNotEmpty
        ? tr.formatProviderName(item.name)
        : (tr.isArabic ? 'مزود خدمة' : 'Service Provider');

    final String realCategoryLabel = item.categoryName.isNotEmpty
        ? (tr.isArabic && item.categoryNameAr.isNotEmpty
            ? item.categoryNameAr
            : tr.categoryName(item.categoryName))
        : '';
    final String realVehicleLabel = item.vehicleType.trim();
    final String subtitleText;
    if (realVehicleLabel.isNotEmpty &&
        realCategoryLabel.isNotEmpty &&
        realVehicleLabel.toLowerCase() != realCategoryLabel.toLowerCase()) {
      subtitleText = '$realVehicleLabel • $realCategoryLabel';
    } else if (realVehicleLabel.isNotEmpty) {
      subtitleText = realVehicleLabel;
    } else {
      subtitleText = realCategoryLabel;
    }

    final double? liveMeters = _computeRealDistanceMeters(item, activeUserLoc);
    final String distanceStr = liveMeters != null
        ? _formatRealDistance(liveMeters, tr.isArabic)
        : '--';
    final String etaStr = liveMeters != null
        ? _formatRealEta(liveMeters, tr.isArabic)
        : '--';

    // Real rating, real review count, and real order counter (zero fake fallbacks)
    final double rating = item.ratingAvg;
    final int reviews = item.ratingCount;
    final int orders = item.ordersCount;
    final String ordersLabel = tr.isArabic
        ? '$orders طلب'
        : '$orders ${orders == 1 ? 'order' : 'orders'}';

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
            latitude: activeUserLoc?.latitude ?? item.latitude,
            longitude: activeUserLoc?.longitude ?? item.longitude,
          );
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProviderDetailScreen(
                serviceCategory: realCategoryLabel.isNotEmpty
                    ? realCategoryLabel
                    : tr.categoryName(widget.serviceCategory),
                providerName: providerName,
                providerPublicId: effectivePublicId,
                phoneNumber: item.phone,
                photoUrl: item.photoUrl,
                vehicleName: realVehicleLabel.isNotEmpty ? realVehicleLabel : realCategoryLabel,
                distance: distanceStr,
                estimatedTime: etaStr,
                rating: rating,
                reviews: reviews,
                ordersCount: orders,
                verified: item.verificationStatus == 'approved' || item.verificationStatus == 'verified',
                providerLatitude: item.latitude,
                providerLongitude: item.longitude,
              ),
            ),
          );
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: effectiveWidth,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 11.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
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
              // Left side content: Real Service Image + Real Provider Details
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildRealServiceImage(item, liveCategories),
                    const SizedBox(width: 10.0),

                    // Content details column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Provider Full Name (wraps cleanly without awkward dots)
                          Text(
                            providerName,
                            textHeightBehavior: const TextHeightBehavior(
                              applyHeightToFirstAscent: false,
                              applyHeightToLastDescent: false,
                            ),
                            style: tr.font(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C2926),
                              height: 1.2,
                            ),
                            maxLines: 2,
                            softWrap: true,
                          ),
                          const SizedBox(height: 3.0),

                          // Real Vehicle / Category + Online/Available badge
                          Wrap(
                            spacing: 6.0,
                            runSpacing: 3.0,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (subtitleText.isNotEmpty)
                                Text(
                                  subtitleText,
                                  textHeightBehavior: const TextHeightBehavior(
                                    applyHeightToFirstAscent: false,
                                    applyHeightToLastDescent: false,
                                  ),
                                  style: tr.font(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF566663),
                                    height: 1.15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: item.isOnline
                                      ? const Color(0xFFF0EAFE)
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(60.0),
                                ),
                                child: Text(
                                  item.isOnline
                                      ? (tr.isArabic ? 'متاح' : 'Available')
                                      : (tr.isArabic ? 'غير متصل' : 'Offline'),
                                  textHeightBehavior: const TextHeightBehavior(
                                    applyHeightToFirstAscent: false,
                                    applyHeightToLastDescent: false,
                                  ),
                                  style: tr.font(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w600,
                                    color: item.isOnline
                                        ? const Color(0xFF8B53FE)
                                        : const Color(0xFF6B7280),
                                    height: 1.1,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4.0),

                          // Real Reviews & Real Order Counter
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 2.0,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 12.0,
                                    color: Color(0xFF8B53FE),
                                  ),
                                  const SizedBox(width: 2.5),
                                  RichText(
                                    textHeightBehavior: const TextHeightBehavior(
                                      applyHeightToFirstAscent: false,
                                      applyHeightToLastDescent: false,
                                    ),
                                    text: TextSpan(
                                      text: '${rating.toStringAsFixed(1)} ',
                                      style: tr.font(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
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
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.receipt_long_rounded,
                                    size: 11.0,
                                    color: Color(0xFF8B53FE),
                                  ),
                                  const SizedBox(width: 2.5),
                                  Text(
                                    ordersLabel,
                                    textHeightBehavior: const TextHeightBehavior(
                                      applyHeightToFirstAscent: false,
                                      applyHeightToLastDescent: false,
                                    ),
                                    style: tr.font(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF566663),
                                      height: 1.15,
                                    ),
                                    maxLines: 1,
                                  ),
                                ],
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

              // Right side content: Real Live Distance, Real Live ETA & Real Call Button
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C2926),
                              height: 1.1,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3.0),
                      Text(
                        etaStr,
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false,
                        ),
                        style: tr.font(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF566663),
                          height: 1.1,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                  const SizedBox(width: 8.0),

                  // Functional Call Button: sends call_click notification to provider & launches real dialer
                  GestureDetector(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final effectivePublicId =
                          item.publicId.isNotEmpty ? item.publicId : 'QRB-${item.id}';
                      String? phone = item.phone?.trim();
                      try {
                        await ref.read(backendServiceProvider).trackCustomerEvent(
                          event: 'call_click',
                          providerPublicId: effectivePublicId,
                          latitude: activeUserLoc?.latitude ?? item.latitude,
                          longitude: activeUserLoc?.longitude ?? item.longitude,
                        );
                      } catch (_) {}
                      if ((phone == null || phone.isEmpty) && effectivePublicId.isNotEmpty) {
                        try {
                          final profile = await ref
                              .read(backendServiceProvider)
                              .getPublicProviderProfile(effectivePublicId);
                          final contact = profile?['contact'];
                          if (contact is Map) {
                            phone = contact['phone']?.toString().trim();
                          }
                          phone ??= profile?['phone']?.toString().trim();
                        } catch (_) {}
                      }
                      if (!mounted) return;
                      if (phone != null && phone.isNotEmpty) {
                        final launched = await ContactLauncher.call(phone);
                        if (!launched && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                tr.isArabic
                                    ? 'تعذر فتح تطبيق الاتصال'
                                    : 'Unable to open phone dialer',
                                style: tr.font(fontSize: 12.0, color: Colors.white),
                              ),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              tr.isArabic
                                  ? 'رقم هاتف مزود الخدمة غير متوفر'
                                  : 'Provider phone number is not available',
                              style: tr.font(fontSize: 12.0, color: Colors.white),
                            ),
                            backgroundColor: const Color(0xFF1C2926),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
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
                        size: 14.0,
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

