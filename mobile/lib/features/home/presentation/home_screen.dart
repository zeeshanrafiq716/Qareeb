import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../emergency/presentation/emergency_services_screen.dart';
import '../../location/presentation/location_permission_screen.dart';
import 'widgets/home_header_widget.dart';
import 'widgets/services_section_widget.dart';
import 'widgets/bottom_nav_bar_widget.dart';

/// Home screen hosting the branding header layout and main services section.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
      backgroundColor: const Color(0xFFF9FBF9),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktopWeb = constraints.maxWidth > 500;
            final double containerWidth = isDesktopWeb ? 390.0 : constraints.maxWidth;
            // On desktop web, dynamically fit within browser viewport so frame never gets clipped
            final double containerHeight = isDesktopWeb
                ? math.min(844.0, (constraints.maxHeight - 32.0).clamp(520.0, 844.0))
                : constraints.maxHeight;

            final homeContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: const Color(0xFFF9FBF9),
              child: Stack(
                children: [
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
                    child: const BottomNavBarWidget(),
                  ),
                ],
              ),
            );

            if (isDesktopWeb) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFF141C1A), // Clean backdrop for web preview
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
