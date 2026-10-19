import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../home/presentation/widgets/bottom_nav_bar_widget.dart';

/// Profile Tab screen designed strictly following Figma tokens:
/// - Background gradient: linear-gradient(180deg, #9FFFCB -36.97%, rgba(159, 255, 203, 0) 100%)
/// - Header layout: width: 350; height: 36; top: 56px; left: 20px; gap: 28px;
/// - Ellipse branding: width: 36; height: 36; background: #FFFFFF;
/// - Content layout: width: 223; height: 36; gap: 12px;
///   - Title: Profile (Inter Medium 20px, #1C2926, center aligned)
///   - Subtitle: Manage your account and preferences. (Inter Regular 12px, #566663, center aligned)
class ProfileScreen extends StatefulWidget {
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
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
                            Color(0xFF9FFFCB),
                            Color(0x009FFFCB), // rgba(159, 255, 203, 0)
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
                          height: math.max(containerHeight, 920.0),
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
                                            child: const Center(
                                              child: Icon(
                                                Icons.arrow_back_ios_new_rounded,
                                                size: 15.0,
                                                color: Color(0xFF1C2926),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // gap: 28px built-in by centering layout
                                      // content layout:
                                      // width: 223; height: 36; gap: 12px; angle: 0 deg; opacity: 1;
                                      SizedBox(
                                        width: 223.0,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // content: Profile
                                            // width: 223; height: 15; font-family: Inter; font-weight: 500; font-size: 20px;
                                            // line-height: 22px; text-align: center; color: #1C2926;
                                            Text(
                                              'Profile',
                                              textAlign: TextAlign.center,
                                              textHeightBehavior:
                                                  const TextHeightBehavior(
                                                applyHeightToFirstAscent: false,
                                                applyHeightToLastDescent: false,
                                              ),
                                              style: GoogleFonts.inter(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF1C2926),
                                                height: 1.15,
                                                letterSpacing: 0.0,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2.0),

                                            // content: Manage your account and preferences.
                                            // width: 223; height: 9; font-family: Inter; font-weight: 400; font-size: 12px;
                                            // line-height: 22px; text-align: center; color: #566663;
                                            Text(
                                              'Manage your account and preferences.',
                                              textAlign: TextAlign.center,
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
                                height: 83.0,
                                child: Container(
                                  width: containerWidth >= 390
                                      ? 350.0
                                      : (containerWidth - 40.0)
                                          .clamp(280.0, 350.0),
                                  height: 83.0,
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
                                        padding: const EdgeInsets.all(16.0), // padding: 16px;
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // left side content: width: 209; height: 51; gap: 12px;
                                            Row(
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
                                                                    style: GoogleFonts
                                                                        .inter(
                                                                      fontSize:
                                                                          18.0,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: const Color(
                                                                          0xFF1C2926),
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

                                                // content layout: width: 149; height: 34; gap: 10px;
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    // 1st row branding: width: 149; height: 15; gap: 6px;
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        // content: Abdul Ahad Omar
                                                        // font-family: Inter; font-weight: 500; font-size: 15px; color: #1C2926;
                                                        Text(
                                                          'Abdul Ahad Omar',
                                                          textHeightBehavior:
                                                              const TextHeightBehavior(
                                                            applyHeightToFirstAscent:
                                                                false,
                                                            applyHeightToLastDescent:
                                                                false,
                                                          ),
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 15.0,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: const Color(
                                                                0xFF1C2926),
                                                            height: 1.15,
                                                            letterSpacing: 0.0,
                                                          ),
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                            width: 6.0), // gap: 6px;

                                                        // vector branding: width: 16; height: 15; background: #1D8070;
                                                        const Icon(
                                                          Icons
                                                              .verified_rounded,
                                                          size: 16.0,
                                                          color: Color(
                                                              0xFF1D8070),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 3.0),

                                                    // 2nd row content branding: content: @abdulahadomar132
                                                    // font-family: Inter; font-weight: 400; font-size: 12px; color: #566663;
                                                    Text(
                                                      '@abdulahadomar132',
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
                                                        color: const Color(
                                                            0xFF566663),
                                                        height: 1.2,
                                                        letterSpacing: 0.0,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),

                                            // > branding: width: 8; height: 16; border: 1px solid #566663;
                                            const Icon(
                                              Icons.chevron_right_rounded,
                                              size: 20.0,
                                              color: Color(0xFF566663),
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
                                    SizedBox(
                                      width: containerWidth >= 390
                                          ? 350.0
                                          : (containerWidth - 40.0)
                                              .clamp(280.0, 350.0),
                                      height: 64.0,
                                      child: Row(
                                        children: [
                                          // 1st card branding: Total Requests (width: 169; height: 64;)
                                          Expanded(
                                            child: _buildMetricCard(
                                              title: 'Total Requests',
                                              value: '12',
                                              iconBgColor:
                                                  const Color(0xFFF2F5F3),
                                              icon: const CustomPaint(
                                                size: Size(18.0, 16.0),
                                                painter:
                                                    _TotalRequestsIconPainter(
                                                  color: Color(0xFF1D8070),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12.0), // gap: 12px;

                                          // 2nd card branding: Average Rating (width: 169; height: 64;)
                                          Expanded(
                                            child: _buildMetricCard(
                                              title: 'Average Rating',
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
                                    // Menu Options Card:
                                    // width: 350; height: 352; gap: 16px; border-radius: 12px;
                                    // padding: 16px; background: #FFFFFF;
                                    // box-shadow: 0px 1px 12px 0px #0000001A;
                                    // -------------------------------------------------------------
                                    Container(
                                      width: containerWidth >= 390
                                          ? 350.0
                                          : (containerWidth - 40.0)
                                              .clamp(280.0, 350.0),
                                      height: 352.0,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFFFF),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x1A000000), // 0px 1px 12px 0px #0000001A
                                            blurRadius: 12.0,
                                            offset: Offset(0, 1),
                                            spreadRadius: 0.0,
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(16.0), // padding: 16px;
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween, // gap: 16px between 7 items of 32px height
                                        children: [
                                          // 1. Personal Information
                                          _buildProfileMenuItem(
                                            icon: Icons.person_rounded,
                                            title: 'Personal Information',
                                            subtitle:
                                                'Name, phone number and more',
                                            onTap: () {
                                              // Navigate / handle personal information
                                            },
                                          ),

                                          // 2. Notifications
                                          _buildProfileMenuItem(
                                            icon: Icons.notifications_rounded,
                                            title: 'Notifications',
                                            subtitle:
                                                'Manage your alerts and updates',
                                            onTap: () {
                                              // Navigate / handle notifications
                                            },
                                          ),

                                          // 3. Language
                                          _buildProfileMenuItem(
                                            icon: Icons.language_rounded,
                                            title: 'Language',
                                            subtitle: 'English (US)',
                                            onTap: () {
                                              // Navigate / handle language
                                            },
                                          ),

                                          // 4. Saved Locations
                                          _buildProfileMenuItem(
                                            icon: Icons.location_on_rounded,
                                            title: 'Saved Locations',
                                            subtitle:
                                                'Home, Work, and other places',
                                            onTap: () {
                                              // Navigate / handle saved locations
                                            },
                                          ),

                                          // 5. Payment Methods
                                          _buildProfileMenuItem(
                                            icon: Icons.credit_card_rounded,
                                            title: 'Payment Methods',
                                            subtitle:
                                                'Manage your payment options',
                                            onTap: () {
                                              // Navigate / handle payment methods
                                            },
                                          ),

                                          // 6. Privacy & Security
                                          _buildProfileMenuItem(
                                            icon: Icons.shield_rounded,
                                            title: 'Privacy & Security',
                                            subtitle:
                                                'Manage your data and security',
                                            onTap: () {
                                              // Navigate / handle privacy & security
                                            },
                                          ),

                                          // 7. Help & Support
                                          _buildProfileMenuItem(
                                            icon: Icons.credit_card_rounded,
                                            title: 'Help & Support',
                                            subtitle:
                                                'Find help or contact us',
                                            onTap: () {
                                              // Navigate / handle help & support
                                            },
                                          ),
                                        ],
                                      ),
                                    ),

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

  /// Helper widget for the Profile Overview Metric Cards (e.g. Total Requests, Average Rating)
  /// Branding: width: 169; height: 64; border-radius: 12px; padding: 16px; background: #FFFFFF;
  /// box-shadow: 0px 1px 12px 0px #0000001A;
  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color iconBgColor,
    required Widget icon,
    VoidCallback? onTap,
  }) {
    return Container(
      height: 64.0,
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
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
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
                      // content: title (10px, Inter Regular, #566663)
                      Text(
                        title,
                        textHeightBehavior: const TextHeightBehavior(
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
                      const SizedBox(height: 2.0),
                      // content: value (14px, Inter Medium, #1C2926)
                      Text(
                        value,
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false,
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1C2926),
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
          ),
        ),
      ),
    );
  }

  /// Helper widget for the Profile Menu Items
  /// Branding: width: 318; height: 32; gap: 12px;
  /// Left side icon: width: 32; height: 32; border-radius: 8px; background: #F3F5F3;
  /// Content layout: width: 274; height: 26; gap: 10px;
  /// Title: 12px, Inter Medium, #1C2926; Subtitle: 10px, Inter Regular, #566663;
  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        child: SizedBox(
          height: 32.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // left side icon branding: width: 32; height: 32; border-radius: 8px; background: #F3F5F3;
              Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5F3),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 18.0,
                    color: const Color(0xFF1C2926),
                  ),
                ),
              ),
              const SizedBox(width: 12.0), // gap: 12px;

              // content layout: width: 274; height: 26; gap: 10px;
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // content: Title (12px, Inter Medium, #1C2926)
                    Text(
                      title,
                      textHeightBehavior: const TextHeightBehavior(
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
                    const SizedBox(height: 2.0),
                    // content: Subtitle (10px, Inter Regular, #566663)
                    Text(
                      subtitle,
                      textHeightBehavior: const TextHeightBehavior(
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

  const _TotalRequestsIconPainter({this.color = const Color(0xFF1D8070)});

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

