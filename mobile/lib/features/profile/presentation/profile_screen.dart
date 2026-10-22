import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_locale.dart';
import '../../home/presentation/widgets/bottom_nav_bar_widget.dart';

/// Profile Tab screen designed strictly following Figma tokens:
/// - Background gradient: linear-gradient(180deg, #9FFFCB -36.97%, rgba(159, 255, 203, 0) 100%)
/// - Header layout: width: 350; height: 36; top: 56px; left: 20px; gap: 28px;
/// - Ellipse branding: width: 36; height: 36; background: #FFFFFF;
/// - Content layout: width: 223; height: 36; gap: 12px;
///   - Title: Profile (Inter/Cairo Medium 20px, #1C2926, center aligned)
///   - Subtitle: Manage your account and preferences. (Inter/Cairo Regular 12px, #566663, center aligned)
class ProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBackTap;
  final ValueChanged<int>? onTabSelected;
  final bool showBottomNav;

  const ProfileScreen({
    super.key,
    this.onBackTap,
    this.onTabSelected,
    this.showBottomNav = true,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  ScrollController? _scrollControllerInstance;
  ScrollController get _scrollController =>
      _scrollControllerInstance ??= ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollControllerInstance ??= ScrollController();
  }

  @override
  void dispose() {
    _scrollControllerInstance?.dispose();
    super.dispose();
  }

  void _handleBack() {
    HapticFeedback.lightImpact();
    if (widget.onBackTap != null) {
      widget.onBackTap!();
    } else if (widget.onTabSelected != null) {
      widget.onTabSelected!(0);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final isArabic = tr.isArabic;

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

            final Widget screenContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Top Background Gradient:
                  // background: linear-gradient(180deg, #9FFFCB -36.97%, rgba(159, 255, 203, 0) 100%);
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    right: 0.0,
                    height: 220.0,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFF0EAFE),
                            Color(0x00F0EAFE),
                          ],
                          stops: [0.0, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Smooth scrollable area for Profile Tab content
                  Positioned.fill(
                    child: ScrollConfiguration(
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
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        child: SizedBox(
                          width: containerWidth,
                          height: math.max(containerHeight, 960.0),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // 2. Header Layout:
                              // width: 350; height: 36; top: 56px; left: 20px; gap: 28px;
                              Positioned(
                                top: 56.0,
                                left: containerWidth >= 390
                                    ? 20.0
                                    : ((containerWidth - 350.0) / 2)
                                        .clamp(10.0, 20.0),
                                width: containerWidth >= 390
                                    ? 350.0
                                    : (containerWidth - 40.0)
                                        .clamp(280.0, 350.0),
                                child: SizedBox(
                                  width: containerWidth >= 390
                                      ? 350.0
                                      : (containerWidth - 40.0)
                                          .clamp(280.0, 350.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // ellipse branding:
                                      // width: 36; height: 36; angle: 0 deg; opacity: 1; background: #FFFFFF;
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          key: const Key(
                                              'profile_header_back_button'),
                                          onTap: _handleBack,
                                          behavior: HitTestBehavior.opaque,
                                          child: Container(
                                            width: 36.0,
                                            height: 36.0,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFFFFFF),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color(0x14000000), // 0px 1px 8px 0px #00000014
                                                  blurRadius: 8.0,
                                                  offset: Offset(0, 1),
                                                  spreadRadius: 0.0,
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Icon(
                                                isArabic
                                                    ? Icons.arrow_forward_ios_rounded
                                                    : Icons.arrow_back_ios_new_rounded,
                                                size: 15.0,
                                                color: const Color(0xFF1C2926),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // gap: 28px built-in by centering layout
                                      // content layout:
                                      // width: 223; height: 36; gap: 12px; angle: 0 deg; opacity: 1;
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // content: Profile
                                            Text(
                                              tr.profileTitle,
                                              textAlign: TextAlign.center,
                                              textHeightBehavior:
                                                  const TextHeightBehavior(
                                                applyHeightToFirstAscent: false,
                                                applyHeightToLastDescent: false,
                                              ),
                                              style: tr.font(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF1C2926),
                                                height: 1.15,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2.0),

                                            // content: Manage your account and preferences.
                                            Text(
                                              tr.profileSubtitle,
                                              textAlign: TextAlign.center,
                                              textHeightBehavior:
                                                  const TextHeightBehavior(
                                                applyHeightToFirstAscent: false,
                                                applyHeightToLastDescent: false,
                                              ),
                                              style: tr.font(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w400,
                                                color: const Color(0xFF566663),
                                                height: 1.2,
                                              ),
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Symmetrical 36px right placeholder maintains exact 28px gaps & optical centering
                                      const SizedBox(
                                        width: 36.0,
                                        height: 36.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // -------------------------------------------------------------
                              // 3. User Profile Card:
                              // width: 350; height: 83; top: 116px; left: 20px;
                              // border-radius: 12px; padding: 16px; background: #FFFFFF;
                              // -------------------------------------------------------------
                              Positioned(
                                top: 116.0,
                                left: containerWidth >= 390
                                    ? 20.0
                                    : ((containerWidth - 350.0) / 2)
                                        .clamp(10.0, 20.0),
                                width: containerWidth >= 390
                                    ? 350.0
                                    : (containerWidth - 40.0)
                                        .clamp(280.0, 350.0),
                                height: 86.0,
                                child: Container(
                                  width: containerWidth >= 390
                                      ? 350.0
                                      : (containerWidth - 40.0)
                                          .clamp(280.0, 350.0),
                                  height: 86.0,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.circular(12.0),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x14000000), // #00000014
                                        blurRadius: 12.0,
                                        offset: Offset(0, 2),
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
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 12.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // left side content:
                                            Expanded(
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                // left-side img branding: width: 48; height: 51;
                                                SizedBox(
                                                  width: 48.0,
                                                  height: 51.0,
                                                  child: Stack(
                                                    clipBehavior: Clip.none,
                                                    children: [
                                                      // img inner branding: width: 48; height: 48;
                                                      Positioned(
                                                        top: 0.0,
                                                        left: 0.0,
                                                        width: 48.0,
                                                        height: 48.0,
                                                        child: ClipOval(
                                                          child: Image.asset(
                                                            'assets/images/driver_avatar.png',
                                                            width: 48.0,
                                                            height: 48.0,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (context,
                                                                    error,
                                                                    stackTrace) {
                                                              return Container(
                                                                width: 48.0,
                                                                height: 48.0,
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  color: Color(
                                                                      0xFFFFC1CC),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child: Center(
                                                                  child: Text(
                                                                    'A',
                                                                    style: tr.font(
                                                                      fontSize: 18.0,
                                                                      fontWeight: FontWeight.w600,
                                                                      color: const Color(0xFF1C2926),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),

                                                      // camera icon layout: width: 20; height: 20; top: 31px; left: 27px;
                                                      // border: 0.2px solid #F1F2EF;
                                                      Positioned(
                                                        top: 31.0,
                                                        left: 27.0,
                                                        width: 20.0,
                                                        height: 20.0,
                                                        child: Container(
                                                          width: 20.0,
                                                          height: 20.0,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color(
                                                                0xFFFFFFFF),
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                              color: const Color(
                                                                  0xFFF1F2EF),
                                                              width: 0.8,
                                                            ),
                                                            boxShadow: const [
                                                              BoxShadow(
                                                                color: Color(
                                                                    0x1A000000),
                                                                blurRadius: 4.0,
                                                                offset: Offset(
                                                                    0, 1),
                                                              ),
                                                            ],
                                                          ),
                                                          child: const Center(
                                                            child: Icon(
                                                              Icons
                                                                  .camera_alt_rounded,
                                                              size: 11.0,
                                                              color: Color(
                                                                  0xFF000000),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 12.0), // gap: 12px;

                                                // content layout:
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      // 1st row branding:
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Flexible(
                                                            child: Text(
                                                              tr.isArabic ? 'عبد الأحد عمر' : 'Abdul Ahad Omar',
                                                              textHeightBehavior:
                                                                  const TextHeightBehavior(
                                                                applyHeightToFirstAscent:
                                                                    false,
                                                                applyHeightToLastDescent:
                                                                    false,
                                                              ),
                                                              style: tr.font(
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight.w500,
                                                                color: const Color(
                                                                    0xFF1C2926),
                                                                height: 1.1,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 6.0), // gap: 6px;

                                                          // vector branding: width: 16; height: 15; background: #1D8070;
                                                          const Icon(
                                                            Icons
                                                                .verified_rounded,
                                                            size: 16.0,
                                                            color: Color(
                                                                0xFF8B53FE),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 2.0),

                                                      // 2nd row content branding: content: @abdulahadomar132
                                                      Text(
                                                        '@abdulahadomar132',
                                                        textHeightBehavior:
                                                            const TextHeightBehavior(
                                                          applyHeightToFirstAscent:
                                                              false,
                                                          applyHeightToLastDescent:
                                                              false,
                                                        ),
                                                        style: tr.font(
                                                          fontSize: 12.0,
                                                          fontWeight: FontWeight.w400,
                                                          color: const Color(0xFF566663),
                                                          height: 1.1,
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
                                          const SizedBox(width: 8.0),

                                          // > branding: width: 8; height: 16; border: 1px solid #566663;
                                          Icon(
                                            tr.isArabic
                                                ? Icons.chevron_left_rounded
                                                : Icons.chevron_right_rounded,
                                            size: 20.0,
                                            color: const Color(0xFF566663),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // -------------------------------------------------------------
                              // 4. Next card widget layout:
                              // width: 350; height: 512; top: 219px; left: 20px; gap: 12px;
                              // -------------------------------------------------------------
                              Positioned(
                                top: 219.0,
                                left: containerWidth >= 390
                                    ? 20.0
                                    : ((containerWidth - 350.0) / 2)
                                        .clamp(10.0, 20.0),
                                width: containerWidth >= 390
                                    ? 350.0
                                    : (containerWidth - 40.0)
                                        .clamp(280.0, 350.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 1st row branding:
                                    // width: 350; height: 64; gap: 12px;
                                    IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          // 1st card branding: Total Requests (width: 169; height: 64;)
                                          Expanded(
                                            child: _buildMetricCard(
                                              tr: tr,
                                              title: tr.totalRequests,
                                              value: '12',
                                              iconBgColor:
                                                  const Color(0xFFF0EAFE),
                                              icon: const CustomPaint(
                                                size: Size(18.0, 16.0),
                                                painter:
                                                    _TotalRequestsIconPainter(
                                                  color: Color(0xFF8B53FE),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12.0), // gap: 12px;

                                          // 2nd card branding: Average Rating (width: 169; height: 64;)
                                          Expanded(
                                            child: _buildMetricCard(
                                              tr: tr,
                                              title: tr.averageRating,
                                              value: '4.8',
                                              iconBgColor:
                                                  const Color(0xFFFFF6E9),
                                              icon: const Icon(
                                                Icons.star_rounded,
                                                size: 20.0,
                                                color: Color(0xFFF59E0B),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12.0), // gap: 12px;

                                    // -------------------------------------------------------------
                                    // Menu Options Cards (Every tab in its own separate card)
                                    // -------------------------------------------------------------
                                    // 1. Personal Information
                                    _buildProfileMenuCard(
                                      tr: tr,
                                      width: containerWidth >= 390
                                          ? 350.0
                                          : (containerWidth - 40.0)
                                              .clamp(280.0, 350.0),
                                      icon: Icons.person_rounded,
                                      title: tr.personalInfo,
                                      subtitle: tr.personalInfoSubtitle,
                                      onTap: () {
                                        // Navigate / handle personal information
                                      },
                                    ),
                                    const SizedBox(height: 10.0),

                                    // 2. Notifications
                                    _buildProfileMenuCard(
                                      tr: tr,
                                      width: containerWidth >= 390
                                          ? 350.0
                                          : (containerWidth - 40.0)
                                              .clamp(280.0, 350.0),
                                      icon: Icons.notifications_rounded,
                                      title: tr.notifications,
                                      subtitle: tr.notificationsSubtitle,
                                      onTap: () {
                                        // Navigate / handle notifications
                                      },
                                    ),
                                    const SizedBox(height: 10.0),

                                    // 3. Language
                                    _buildProfileMenuCard(
                                      tr: tr,
                                      width: containerWidth >= 390
                                          ? 350.0
                                          : (containerWidth - 40.0)
                                              .clamp(280.0, 350.0),
                                      icon: Icons.language_rounded,
                                      title: tr.language,
                                      subtitle: tr.currentLanguageDisplay,
                                      trailingText: tr.currentLanguageDisplay,
                                      onTap: () => _showLanguageSelector(context),
                                    ),
                                    const SizedBox(height: 10.0),

                                    // 4. Saved Locations
                                    _buildProfileMenuCard(
                                      tr: tr,
                                      width: containerWidth >= 390
                                          ? 350.0
                                          : (containerWidth - 40.0)
                                              .clamp(280.0, 350.0),
                                      icon: Icons.location_on_rounded,
                                      title: tr.savedLocations,
                                      subtitle: tr.savedLocationsSubtitle,
                                      onTap: () {
                                        // Navigate / handle saved locations
                                      },
                                    ),
                                    const SizedBox(height: 10.0),

                                    // 5. Payment Methods
                                    _buildProfileMenuCard(
                                      tr: tr,
                                      width: containerWidth >= 390
                                          ? 350.0
                                          : (containerWidth - 40.0)
                                              .clamp(280.0, 350.0),
                                      icon: Icons.credit_card_rounded,
                                      title: tr.paymentMethods,
                                      subtitle: tr.paymentMethodsSubtitle,
                                      onTap: () {
                                        // Navigate / handle payment methods
                                      },
                                    ),
                                    const SizedBox(height: 10.0),

                                    // 6. Privacy & Security
                                    _buildProfileMenuCard(
                                      tr: tr,
                                      width: containerWidth >= 390
                                          ? 350.0
                                          : (containerWidth - 40.0)
                                              .clamp(280.0, 350.0),
                                      icon: Icons.shield_rounded,
                                      title: tr.privacySecurity,
                                      subtitle: tr.privacySecuritySubtitle,
                                      onTap: () {
                                        // Navigate / handle privacy & security
                                      },
                                    ),
                                    const SizedBox(height: 10.0),

                                    // 7. Help & Support
                                    _buildProfileMenuCard(
                                      tr: tr,
                                      width: containerWidth >= 390
                                          ? 350.0
                                          : (containerWidth - 40.0)
                                              .clamp(280.0, 350.0),
                                      icon: Icons.headset_mic_rounded,
                                      title: tr.helpSupport,
                                      subtitle: tr.helpSupportSubtitle,
                                      onTap: () {
                                        // Navigate / handle help & support
                                      },
                                    ),
                                    const SizedBox(height: 90.0),

                                    // Subsequent widgets inside 512px overview container will be added below
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Floating Bottom Navigation Bar (Profile tab active: index 2)
                  if (widget.showBottomNav)
                    Positioned(
                      left: (containerWidth - 292.0) / 2,
                      width: 292.0,
                      bottom: isDesktopWeb
                          ? 16.0
                          : (MediaQuery.of(context).padding.bottom + 12.0),
                      child: BottomNavBarWidget(
                        currentIndex: 2,
                        initialIndex: 2,
                        onTabSelected: (index) {
                          if (widget.onTabSelected != null) {
                            widget.onTabSelected!(index);
                          } else {
                            if (index == 0) {
                              Navigator.of(context).pushReplacementNamed('/home');
                            } else if (index == 1) {
                              Navigator.of(context).pushReplacementNamed('/requests');
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
                color: const Color(0xFF141C1A),
                child: Center(
                  child: Container(
                    width: containerWidth,
                    height: containerHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
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

  /// Helper widget for the Profile Overview Metric Cards (e.g. Total Requests, Average Rating)
  Widget _buildMetricCard({
    required AppTranslations tr,
    required String title,
    required String value,
    required Color iconBgColor,
    required Widget icon,
    VoidCallback? onTap,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 64.0),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // left-side icon branding: width: 32; height: 32; border-radius: 60px;
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconBgColor,
                  ),
                  child: Center(
                    child: icon,
                  ),
                ),
                const SizedBox(width: 10.0), // gap: 10-12px
                // content layout: width: 93; height: 29;
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // content: title
                      Text(
                        title,
                        style: tr.font(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF566663),
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1.0),
                      // content: value
                      Text(
                        value,
                        style: tr.font(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1C2926),
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper widget for the Profile Menu Items - Each rendered in an independent card
  /// Exact branding:
  /// - Card: border radius 14px, white background, 1px solid #F0F1F5 border, soft shadow
  /// - Icon Container: 38x38, border radius 10px, soft purple background #F0EAFE
  /// - Icon: 20px, brand purple #8B53FE
  /// - Title: 13.5px, Medium (w500), #1C2926
  /// - Subtitle: 11px, Regular (w400), #566663
  /// - Trailing: Chevron arrow mirrored for RTL
  Widget _buildProfileMenuCard({
    required AppTranslations tr,
    required double width,
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return Container(
      width: width,
      constraints: const BoxConstraints(minHeight: 62.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: const Color(0xFFF0F1F5),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000), // very soft, clean modern elevation
            blurRadius: 10.0,
            offset: Offset(0, 2),
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.0),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 11.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon in purple shade container
                Container(
                  width: 38.0,
                  height: 38.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EAFE), // Soft purple shade
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 20.0,
                      color: const Color(0xFF8B53FE), // Brand purple
                    ),
                  ),
                ),
                const SizedBox(width: 14.0), // gap: 14px

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: tr.font(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1C2926),
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1.0),
                      Text(
                        subtitle,
                        style: tr.font(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF566663),
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Trailing text if any (e.g. for language)
                if (trailingText != null) ...[
                  Text(
                    trailingText,
                    style: tr.font(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8B53FE),
                    ),
                  ),
                  const SizedBox(width: 4.0),
                ],

                // Chevron arrow (mirrored in RTL)
                Icon(
                  tr.isArabic
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  size: 20.0,
                  color: const Color(0xFF9EABA7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Interactive Modal Bottom Sheet allowing instantaneous switching between Arabic (Default) and English
  void _showLanguageSelector(BuildContext context) {
    HapticFeedback.lightImpact();
    final tr = ref.read(translationsProvider);
    final currentLocale = ref.read(appLocaleProvider).languageCode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 20.0,
                offset: Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top drag indicator
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 18.0),

              // Title
              Text(
                tr.selectLanguageTitle,
                textAlign: TextAlign.center,
                style: tr.font(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1C2926),
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                tr.isArabic
                    ? 'اختر لغة التطبيق المفضلة لديك'
                    : 'Choose your preferred application language',
                textAlign: TextAlign.center,
                style: tr.font(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF566663),
                ),
              ),
              const SizedBox(height: 22.0),

              // Option 1: Arabic (Default)
              _buildLanguageOptionCard(
                bottomSheetContext: bottomSheetContext,
                title: 'العربية',
                subtitle: 'Arabic (الافتراضي)',
                code: 'ar',
                isSelected: currentLocale == 'ar',
                tr: tr,
              ),
              const SizedBox(height: 12.0),

              // Option 2: English
              _buildLanguageOptionCard(
                bottomSheetContext: bottomSheetContext,
                title: 'English (US)',
                subtitle: 'الإنجليزية',
                code: 'en',
                isSelected: currentLocale == 'en',
                tr: tr,
              ),
              const SizedBox(height: 12.0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOptionCard({
    required BuildContext bottomSheetContext,
    required String title,
    required String subtitle,
    required String code,
    required bool isSelected,
    required AppTranslations tr,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.0),
        onTap: () async {
          HapticFeedback.selectionClick();
          Navigator.of(bottomSheetContext).pop();
          await ref.read(appLocaleProvider.notifier).setLocale(code);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF7F3FF) : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: isSelected ? const Color(0xFF8B53FE) : const Color(0xFFE5E7EB),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF0EAFE) : const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.language_rounded,
                    size: 20.0,
                    color: isSelected ? const Color(0xFF8B53FE) : const Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tr.font(
                        fontSize: 15.0,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: const Color(0xFF1C2926),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      subtitle,
                      style: tr.font(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF566663),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 22.0,
                height: 22.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? const Color(0xFF8B53FE) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF8B53FE) : const Color(0xFF9EABA7),
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(
                          Icons.check_rounded,
                          size: 14.0,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the "Total Requests" stacked badge/card icon
class _TotalRequestsIconPainter extends CustomPainter {
  final Color color;

  const _TotalRequestsIconPainter({this.color = const Color(0xFF8B53FE)});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final whiteLinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    final whiteCircleStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    final whiteCircleDot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Back card (stacked behind, top-right)
    final backRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.16, 0.0, w * 0.82, h * 0.82),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(backRRect, fillPaint);

    // Subtle edge separation between cards
    final edgePaint = Paint()
      ..color = const Color(0xFFF2F5F3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawRRect(backRRect, edgePaint);

    // Front card (foreground, bottom-left)
    final frontRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.0, h * 0.16, w * 0.82, h * 0.82),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(frontRRect, fillPaint);

    // Inside front card:
    final centerY = h * 0.16 + (h * 0.82) * 0.52;
    // Ring icon with inner dot
    canvas.drawCircle(Offset(w * 0.22, centerY), 1.8, whiteCircleStroke);
    canvas.drawCircle(Offset(w * 0.22, centerY), 0.6, whiteCircleDot);
    // Line next to it
    canvas.drawLine(
      Offset(w * 0.38, centerY),
      Offset(w * 0.66, centerY),
      whiteLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TotalRequestsIconPainter oldDelegate) =>
      color != oldDelegate.color;
}

