import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/localization/app_locale.dart';
import '../../home/presentation/widgets/bottom_nav_bar_widget.dart';

/// Profile Tab screen designed strictly following Figma tokens:
/// - Background gradient: linear-gradient(180deg, #9FFFCB -36.97%, rgba(159, 255, 203, 0) 100%)
/// - Balanced header layout with safe-area spacing and comfortable top breathing room.
/// - Symmetrical horizontal margins ensuring equal left-to-right card spacing across all mobile devices.
/// - Bottom sheet for language switching with safe-area padding, close button, and non-blocking route transitions.
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

            // Equal left-to-right margin across all devices:
            // Symmetrical 20px padding on standard mobile screens,
            // and gracefully centered for larger or desktop previews.
            final double cardHorizontalMargin = isDesktopWeb
                ? 20.0
                : (containerWidth > 420.0
                    ? ((containerWidth - 380.0) / 2).clamp(20.0, 48.0)
                    : 20.0);

            // Safe area top padding: Ensure the header is comfortably spaced below notch/status bar
            final double safeTop = mediaQuery.padding.top;
            final double headerTopPadding = math.max(safeTop + 16.0, 66.0);

            final Widget screenContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Top Background Gradient
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    right: 0.0,
                    height: 260.0,
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
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: cardHorizontalMargin,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Top headroom spacing (balanced for English & Arabic, respecting status bar)
                              SizedBox(height: headerTopPadding),

                              // Header: Back Button + Profile Title & Subtitle + Symmetrical right spacer
                              _buildHeader(context, tr, isArabic),
                              const SizedBox(height: 22.0),

                              // User Profile Card (Equal left-to-right margins)
                              _buildUserProfileCard(context, tr, isArabic),
                              const SizedBox(height: 12.0),

                              // Metric Cards Row: Total Requests & Average Rating
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: _buildMetricCard(
                                        tr: tr,
                                        title: tr.totalRequests,
                                        value: '12',
                                        iconBgColor: const Color(0xFFF0EAFE),
                                        icon: const CustomPaint(
                                          size: Size(18.0, 16.0),
                                          painter: _TotalRequestsIconPainter(
                                            color: Color(0xFF8B53FE),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: _buildMetricCard(
                                        tr: tr,
                                        title: tr.averageRating,
                                        value: '4.8',
                                        iconBgColor: const Color(0xFFFFF6E9),
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
                              const SizedBox(height: 12.0),

                              // Menu Options Cards (Each item with equal left/right margins)
                              // 1. Personal Information
                              _buildProfileMenuCard(
                                tr: tr,
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
                                icon: Icons.headset_mic_rounded,
                                title: tr.helpSupport,
                                subtitle: tr.helpSupportSubtitle,
                                onTap: () {
                                  // Navigate / handle help & support
                                },
                              ),
                              const SizedBox(height: 120.0), // Generous clearance for bottom nav bar
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

  /// Header widget: Back Button + Profile Title & Subtitle + Optical Alignment Spacer
  Widget _buildHeader(BuildContext context, AppTranslations tr, bool isArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Ellipse branding back button
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            key: const Key('profile_header_back_button'),
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
                child: _ProfileChevron(
                  width: 7.0,
                  height: 13.0,
                  color: Color(0xFF1C2926),
                  strokeWidth: 1.8,
                  isLeft: true,
                ),
              ),
            ),
          ),
        ),

        // Centered Title & Subtitle
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile Title
                Text(
                  tr.profileTitle,
                  textAlign: TextAlign.center,
                  style: isArabic
                      ? GoogleFonts.cairo(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C2926),
                          height: 1.2,
                        )
                      : tr.font(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C2926),
                          height: 1.2,
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3.0),
                // Profile Subtitle (comfortably spaced below heading)
                Text(
                  tr.profileSubtitle,
                  textAlign: TextAlign.center,
                  style: isArabic
                      ? GoogleFonts.cairo(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF566663),
                          height: 1.15,
                        )
                      : tr.font(
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
        ),

        // Symmetrical 36px right placeholder maintains optical balance
        const SizedBox(
          width: 36.0,
          height: 36.0,
        ),
      ],
    );
  }

  /// User Profile Card with verified badge and avatar
  Widget _buildUserProfileCard(
    BuildContext context,
    AppTranslations tr,
    bool isArabic,
  ) {
    return Container(
      width: double.infinity,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar with camera icon badge
                      SizedBox(
                        width: 48.0,
                        height: 51.0,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
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
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 48.0,
                                      height: 48.0,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFC1CC),
                                        shape: BoxShape.circle,
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
                            Positioned(
                              top: 31.0,
                              left: 27.0,
                              width: 20.0,
                              height: 20.0,
                              child: Container(
                                width: 20.0,
                                height: 20.0,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFF1F2EF),
                                    width: 0.8,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1A000000),
                                      blurRadius: 4.0,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 11.0,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12.0),

                      // User name & handle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    tr.isArabic ? 'عبد الأحد عمر' : 'Abdul Ahad Omar',
                                    style: isArabic
                                        ? GoogleFonts.cairo(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1C2926),
                                            height: 1.1,
                                          )
                                        : tr.font(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF1C2926),
                                            height: 1.1,
                                          ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6.0),
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 16.0,
                                  color: Color(0xFF8B53FE),
                                ),
                              ],
                            ),
                            const SizedBox(height: 1.0),
                            Text(
                              '@abdulahadomar132',
                              textDirection: TextDirection.ltr,
                              style: tr.font(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF566663),
                                height: 1.1,
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
                const SizedBox(width: 8.0),

                // Trailing chevron (direction sensitive)
                _ProfileChevron(
                  width: 6.0,
                  height: 11.0,
                  color: const Color(0xFF566663),
                  strokeWidth: 1.6,
                  isLeft: isArabic || Directionality.of(context) == TextDirection.rtl,
                ),
              ],
            ),
          ),
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
                // Icon container
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
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
  Widget _buildProfileMenuCard({
    required AppTranslations tr,
    double width = double.infinity,
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
                    color: const Color(0xFFF0EAFE),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 20.0,
                      color: const Color(0xFF8B53FE),
                    ),
                  ),
                ),
                const SizedBox(width: 14.0),

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

                // Chevron arrow (strictly < in Arabic version)
                _ProfileChevron(
                  width: 6.0,
                  height: 11.0,
                  color: const Color(0xFF9EABA7),
                  strokeWidth: 1.6,
                  isLeft: tr.isArabic || Directionality.of(context) == TextDirection.rtl,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Interactive Modal Bottom Sheet allowing smooth switching between Arabic (Default) and English.
  /// Fixes freezing/sticking issues on mobile:
  /// - Includes dedicated visible close (X) button.
  /// - SafeArea bottom padding for gesture bars and home indicator.
  /// - SingleChildScrollView preventing overflow.
  /// - Non-blocking route dismissal before triggering locale update.
  void _showLanguageSelector(BuildContext context) {
    HapticFeedback.lightImpact();
    final tr = ref.read(translationsProvider);
    final currentLocale = ref.read(appLocaleProvider).languageCode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (bottomSheetContext) {
        final bottomInset = MediaQuery.of(bottomSheetContext).padding.bottom;
        return SafeArea(
          top: false,
          child: Container(
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
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.0,
                  12.0,
                  20.0,
                  math.max(16.0, bottomInset + 12.0),
                ),
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
                    const SizedBox(height: 14.0),

                    // Header row with Title and Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 32.0), // Optical balance for close button
                        Expanded(
                          child: Text(
                            tr.selectLanguageTitle,
                            textAlign: TextAlign.center,
                            style: tr.font(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C2926),
                            ),
                          ),
                        ),
                        // Close (X) button ensuring the modal never gets stuck on mobile
                        GestureDetector(
                          key: const Key('language_bottom_sheet_close_button'),
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(bottomSheetContext).pop();
                          },
                          child: Container(
                            width: 32.0,
                            height: 32.0,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.close_rounded,
                                size: 18.0,
                                color: Color(0xFF566663),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                    const SizedBox(height: 20.0),

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
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            ),
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
        onTap: () {
          HapticFeedback.selectionClick();
          // First close the modal bottom sheet cleanly
          Navigator.of(bottomSheetContext).pop();
          // Delay locale update slightly so modal dismiss animation completes without freezing MaterialApp
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              ref.read(appLocaleProvider.notifier).setLocale(code);
            }
          });
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

/// Precise vector chevron that guarantees < in Arabic and > in English without relying on font mirroring.
class _ProfileChevron extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double strokeWidth;
  final bool isLeft; // true = strictly <, false = strictly >

  const _ProfileChevron({
    this.width = 6.0,
    this.height = 11.0,
    required this.color,
    this.strokeWidth = 1.6,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _ProfileChevronPainter(
        color: color,
        strokeWidth: strokeWidth,
        isLeft: isLeft,
      ),
    );
  }
}

class _ProfileChevronPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool isLeft;

  _ProfileChevronPainter({
    required this.color,
    required this.strokeWidth,
    required this.isLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    if (isLeft) {
      // Strictly points LEFT: <
      path.moveTo(size.width - 0.5, 0.5);
      path.lineTo(0.5, size.height / 2);
      path.lineTo(size.width - 0.5, size.height - 0.5);
    } else {
      // Strictly points RIGHT: >
      path.moveTo(0.5, 0.5);
      path.lineTo(size.width - 0.5, size.height / 2);
      path.lineTo(0.5, size.height - 0.5);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ProfileChevronPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.isLeft != isLeft;
}
