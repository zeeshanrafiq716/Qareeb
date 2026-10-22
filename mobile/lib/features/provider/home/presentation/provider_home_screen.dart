import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/home/presentation/widgets/bottom_nav_bar_widget.dart';
import 'package:mobile/features/home/presentation/widgets/notification_popup_card.dart';
import 'package:mobile/features/profile/presentation/profile_screen.dart';
import 'package:mobile/features/provider/dashboard/presentation/provider_dashboard_screen.dart';
import 'package:mobile/features/provider/home/presentation/widgets/provider_home_header.dart';
import 'package:mobile/features/provider/home/presentation/widgets/provider_online_status_text.dart';
import 'package:mobile/features/provider/home/presentation/widgets/provider_online_toggle.dart';
import 'package:mobile/features/provider/home/presentation/widgets/provider_service_area_card.dart';
import 'package:mobile/features/provider/home/presentation/widgets/provider_stats_cards.dart';
import 'package:mobile/features/provider/home/presentation/widgets/provider_vehicle_card.dart';
import 'package:mobile/features/requests/presentation/requests_screen.dart';
import 'package:mobile/providers/notifications_provider.dart';

/// Provider Home Screen
/// Implements exact base branding specifications & artboard dimensions:
///
/// HOME SCREEN total height and width:
///   width: 392;
///   height: 844;
///   angle: 0 deg;
///   opacity: 1;
///
/// home screen branding:
///   background: linear-gradient(0deg, #FFFFFF, #FFFFFF),
///   linear-gradient(180.52deg, #8B53FE -66.75%, rgba(139, 83, 254, 0.37284) -0.59%, rgba(139, 83, 254, 0) 29.8%);
class ProviderHomeScreen extends ConsumerStatefulWidget {
  final Widget? body;
  final int initialTabIndex;

  const ProviderHomeScreen({
    super.key,
    this.body,
    this.initialTabIndex = 0,
  });

  static const double designWidth = 392.0;
  static const double designHeight = 844.0;

  @override
  ConsumerState<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends ConsumerState<ProviderHomeScreen> {
  static const double designWidth = 392.0;
  static const double designHeight = 844.0;

  int _currentTabIndex = 0;
  bool _isOnline = true;

  ScrollController? _scrollControllerInstance;
  ScrollController get _scrollController =>
      _scrollControllerInstance ??= ScrollController();

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTabIndex;
  }

  @override
  void didUpdateWidget(covariant ProviderHomeScreen oldWidget) {
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
    final notifState = ref.watch(notificationsProvider);

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
            final double containerWidth = isDesktopWeb
                ? designWidth
                : (constraints.maxWidth > designWidth ? designWidth : constraints.maxWidth);
            final double containerHeight = isDesktopWeb ? designHeight : constraints.maxHeight;

            final double topSafeArea = MediaQuery.of(context).padding.top;
            final double headerTop = topSafeArea > 0 ? (topSafeArea + 10.0) : 48.0;

            // HOME SCREEN total layout:
            // width: 392; height: 844; angle: 0 deg; opacity: 1;
            final Widget screenContent = Opacity(
              opacity: 1.0, // opacity: 1
              child: Transform.rotate(
                angle: 0.0, // angle: 0 deg
                child: Container(
                  width: containerWidth, // width: 392
                  height: containerHeight, // height: 844
                  color: Colors.white, // background: linear-gradient(0deg, #FFFFFF, #FFFFFF)
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
                                  Color(0x5F8B53FE), // rgba(139, 83, 254, 0.37284) at top (-0.59%)
                                  Color(0x008B53FE), // rgba(139, 83, 254, 0) at 29.8%
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 1. Pinned Header Layout:
                      // width: 390; height: 36; justify-content: space-between; padding: 20px;
                      Positioned(
                        top: headerTop,
                        left: 0,
                        right: 0,
                        child: const ProviderHomeHeader(showLanguageToggle: true),
                      ),

                      // 2. Fixed, non-scrollable Home layout with full touch support
                      Positioned.fill(
                        top: headerTop + ProviderHomeHeader.designHeight + 24.0,
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            scrollbars: false,
                          ),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(
                              left: 20.0,
                              right: 20.0,
                              bottom: 12.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Stats Cards (width: double.infinity; height: 68)
                                ProviderStatsCards(
                                  onViewsTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const ProviderDashboardScreen(),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 12.0),

                                // Main Screen Text Layout (Online Status Text: height: 33)
                                ProviderOnlineStatusText(isOnline: _isOnline),

                                const SizedBox(height: 10.0),

                                // Online / Offline Toggle & Live Presence (height: 154)
                                ProviderOnlineToggle(
                                  isOnline: _isOnline,
                                  onChanged: (val) {
                                    setState(() {
                                      _isOnline = val;
                                    });
                                  },
                                ),

                                const SizedBox(height: 12.0),

                                // Next Card: Vehicle Info Card (height: 150)
                                const ProviderVehicleCard(),

                                const SizedBox(height: 10.0),

                                // Next Card: Service Area Card (height: 68)
                                const ProviderServiceAreaCard(),

                                if (widget.body != null) ...[
                                  const SizedBox(height: 12.0),
                                  widget.body!,
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),

                      // 3. Floating Bottom Navigation Bar (exact width: 292, centered, matches customer side)
                      Positioned(
                        left: (containerWidth - 292.0) / 2,
                        width: 292.0,
                        bottom: isDesktopWeb ? 20.0 : (MediaQuery.of(context).padding.bottom + 12.0),
                        child: BottomNavBarWidget(
                          currentIndex: _currentTabIndex,
                          initialIndex: _currentTabIndex,
                          onTabSelected: _onTabSelected,
                        ),
                      ),

                      // 4. Notification Card Overlay after clicking bell icon
                      //    Exact layout: width: 350; height: 96; top: 106px; left: 21px;
                      if (notifState.isProviderCardVisible) ...[
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              ref
                                  .read(notificationsProvider.notifier)
                                  .hideProviderCard();
                            },
                          ),
                        ),
                        Positioned(
                          top: 106.0,
                          left: isDesktopWeb
                              ? 21.0
                              : ((containerWidth - 350.0) / 2).clamp(10.0, 21.0),
                          width: 350.0,
                          height: 96.0,
                          child: NotificationPopupCard(
                            badgeText: context.isArabic
                                ? notifState.providerNotification.badgeTextAr
                                : notifState.providerNotification.badgeTextEn,
                            title: context.isArabic
                                ? notifState.providerNotification.titleAr
                                : notifState.providerNotification.titleEn,
                            location: context.isArabic
                                ? notifState.providerNotification.locationAr
                                : notifState.providerNotification.locationEn,
                            distance: context.isArabic
                                ? notifState.providerNotification.distanceAr
                                : notifState.providerNotification.distanceEn,
                            time: context.isArabic
                                ? notifState.providerNotification.timeAr
                                : notifState.providerNotification.timeEn,
                            imageAsset: notifState.providerNotification.imageAsset,
                            onDismiss: () {
                              ref
                                  .read(notificationsProvider.notifier)
                                  .dismissProviderNotification();
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );

            if (isDesktopWeb) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFFF0F1F5),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Container(
                    width: designWidth,
                    height: designHeight,
                    margin: const EdgeInsets.symmetric(vertical: 24.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(44),
                      border: Border.all(
                        color: const Color(0xFF8B53FE).withValues(alpha: 0.35),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 36,
                          spreadRadius: 6,
                        ),
                        BoxShadow(
                          color: const Color(0xFF8B53FE).withValues(alpha: 0.10),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(42),
                      child: screenContent,
                    ),
                  ),
                ),
              );
            }

            return Center(
              child: SizedBox(
                width: containerWidth,
                height: containerHeight,
                child: screenContent,
              ),
            );
          },
        ),
      ),
    );
  }
}
