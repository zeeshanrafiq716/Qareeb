import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_locale.dart';
import '../../emergency/presentation/emergency_services_screen.dart';
import '../../location/presentation/location_permission_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../requests/presentation/requests_screen.dart';
import '../../../providers/backend_provider.dart';
import '../../../providers/notifications_provider.dart';
import 'widgets/home_header_widget.dart';
import 'widgets/notification_popup_card.dart';
import 'widgets/services_section_widget.dart';
import 'widgets/bottom_nav_bar_widget.dart';

/// Home screen hosting the branding header layout and main services section.
class HomeScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const HomeScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTabIndex = 0;
  ScrollController? _scrollControllerInstance;
  ScrollController get _scrollController =>
      _scrollControllerInstance ??= ScrollController();

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTabIndex;
    _scrollControllerInstance ??= ScrollController();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      _currentTabIndex = widget.initialTabIndex;
    }
  }

  @override
  void dispose() {
    _scrollControllerInstance?.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_currentTabIndex == index) return;
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _currentTabIndex,
      children: [
        _buildHomeTab(context),
        RequestsScreen(
          onTabSelected: _onTabSelected,
        ),
        ProfileScreen(
          onBackTap: () => _onTabSelected(0),
          onTabSelected: _onTabSelected,
        ),
      ],
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final notifState = ref.watch(notificationsProvider);
    final userLocAsync = ref.watch(userLocationProvider);
    final String locationText = userLocAsync.when(
      data: (loc) => loc.cityName.isNotEmpty
          ? loc.cityName
          : (tr.isArabic ? 'كراتشي، باكستان' : 'Karachi Pakistan'),
      loading: () => tr.gpsDetecting,
      error: (_, _) => (tr.isArabic ? 'كراتشي، باكستان' : 'Karachi Pakistan'),
    );
    final String locationLabel = userLocAsync.when(
      data: (loc) => loc.isGpsDetected ? tr.realGps : tr.currentLocation,
      loading: () => tr.gpsDetecting,
      error: (_, _) => tr.currentLocation,
    );

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
            final double containerWidth = isDesktopWeb ? 392.0 : constraints.maxWidth;
            // On desktop web, dynamically fit within browser viewport so frame never gets clipped
            final double containerHeight = isDesktopWeb
                ? math.min(844.0, (constraints.maxHeight - 32.0).clamp(520.0, 844.0))
                : constraints.maxHeight;

            final homeContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                children: [
                  // Top Purple Glow Gradient from user branding specifications:
                  // linear-gradient(180.52deg, #8B53FE -66.75%, rgba(139, 83, 254, 0.37284) -0.59%, rgba(139, 83, 254, 0) 29.8%)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: containerHeight * 0.298,
                    child: const IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(0.009, -1.0),
                            end: Alignment(-0.009, 1.0),
                            stops: [0.0, 1.0],
                            colors: [
                              Color(0x5F8B53FE), // rgba(139, 83, 254, 0.37284) at top
                              Color(0x008B53FE), // rgba(139, 83, 254, 0) at 29.8%
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Smooth, effortless scroll view with full touch, trackpad, and mouse drag support
                  Positioned.fill(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Branding Header Layout (width: 390, height: 246, ends at 246px)
                            HomeHeaderWidget(
                              location: locationText,
                              locationLabel: locationLabel,
                              onLocationTap: () {
                                HapticFeedback.lightImpact();
                                ref.refresh(userLocationProvider);
                              },
                              onCardTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const EmergencyServicesScreen(),
                                  ),
                                );
                              },
                            ),

                            // 20px vertical spacing (brings top coordinate from 246px to exactly 266px)
                            const SizedBox(height: 20.0),

                            // 2. Services Section (All Category Cards with real images & exact branding)
                            ServicesSectionWidget(
                              onCategoryTap: (category) {
                                if (category.slug == 'emergency') {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const EmergencyServicesScreen(),
                                    ),
                                  );
                                } else {
                                  final String displayName = category.name == 'Pickup'
                                      ? 'Pickup & Delivery'
                                      : category.name;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => LocationPermissionScreen(
                                        serviceName: displayName,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),

                            // Clearance space so floating bottom navigation bar doesn't overlap cards
                            SizedBox(height: 140.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Floating Bottom Navigation Bar (exact width: 292, centered, doesn't block side scroll gestures)
                  Positioned(
                    left: (containerWidth - 292.0) / 2,
                    width: 292.0,
                    bottom: isDesktopWeb ? 16.0 : (MediaQuery.of(context).padding.bottom + 12.0),
                    child: BottomNavBarWidget(
                      currentIndex: _currentTabIndex,
                      initialIndex: _currentTabIndex,
                      onTabSelected: _onTabSelected,
                    ),
                  ),

                  // 3. Notification Card Overlay after clicking bell icon
                  //    Exact layout: width: 350; height: 96; top: 106px; left: 21px;
                  if (notifState.isCustomerCardVisible) ...[
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          ref
                              .read(notificationsProvider.notifier)
                              .hideCustomerCard();
                        },
                      ),
                    ),
                    Positioned(
                      top: 106.0,
                      left: isDesktopWeb ? 21.0 : ((containerWidth - 350.0) / 2).clamp(10.0, 21.0),
                      width: 350.0,
                      height: 96.0,
                      child: NotificationPopupCard(
                        badgeText: tr.isArabic
                            ? notifState.customerNotification.badgeTextAr
                            : notifState.customerNotification.badgeTextEn,
                        title: tr.isArabic
                            ? notifState.customerNotification.titleAr
                            : notifState.customerNotification.titleEn,
                        location: tr.isArabic
                            ? notifState.customerNotification.locationAr
                            : notifState.customerNotification.locationEn,
                        distance: tr.isArabic
                            ? notifState.customerNotification.distanceAr
                            : notifState.customerNotification.distanceEn,
                        time: tr.isArabic
                            ? notifState.customerNotification.timeAr
                            : notifState.customerNotification.timeEn,
                        imageAsset: notifState.customerNotification.imageAsset,
                        onDismiss: () {
                          ref
                              .read(notificationsProvider.notifier)
                              .dismissCustomerNotification();
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );

            if (isDesktopWeb) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFF0F1F5), // Clean modern outer backdrop for web preview
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerSignal: (pointerSignal) {
                    // Forward mouse wheel scrolling from anywhere on desktop screen to the phone view
                    if (pointerSignal is PointerScrollEvent && _scrollController.hasClients) {
                      final RenderBox? box = context.findRenderObject() as RenderBox?;
                      if (box != null) {
                        final localPos = pointerSignal.localPosition;
                        final centerX = box.size.width / 2;
                        final centerY = box.size.height / 2;
                        final phoneRect = Rect.fromCenter(
                          center: Offset(centerX, centerY),
                          width: containerWidth,
                          height: containerHeight,
                        );
                        // If user scrolls mouse wheel outside the phone frame, forward the scroll
                        if (!phoneRect.contains(localPos)) {
                          final double target = (_scrollController.offset + pointerSignal.scrollDelta.dy)
                              .clamp(0.0, _scrollController.position.maxScrollExtent);
                          _scrollController.jumpTo(target);
                        }
                      }
                    }
                  },
                  child: Center(
                    child: Container(
                      width: containerWidth,
                      height: containerHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(42),
                        border: Border.all(
                          color: const Color(0xFF8B53FE).withValues(alpha: 0.20),
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
                      child: homeContent,
                    ),
                  ),
                ),
              );
            }

            return homeContent;
          },
        ),
      ),
    );
  }
}
