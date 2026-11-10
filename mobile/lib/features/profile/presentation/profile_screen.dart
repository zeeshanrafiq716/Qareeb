import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_locale.dart';
import '../../../services/profile_stats_service.dart';
import '../../home/presentation/widgets/bottom_nav_bar_widget.dart';
import '../../provider/auth/data/provider_registration_state.dart';
import '../../provider/auth/presentation/provider_profile_details_screen.dart';
import '../../provider/auth/presentation/vehicle_service_details_screen.dart';
import '../../provider/splash/presentation/provider_splash_screen.dart';
import '../../splash/presentation/splash_screen.dart';
import 'customer_feedback_support_screen.dart';
import 'notifications_screen.dart';
import 'privacy_security_screen.dart';
import 'provider_help_support_screen.dart';

/// Profile Tab screen designed strictly following Figma tokens:
/// - Background gradient: linear-gradient(180deg, #9FFFCB -36.97%, rgba(159, 255, 203, 0) 100%)
/// - Balanced header layout with safe-area spacing and comfortable top breathing room.
/// - Symmetrical horizontal margins ensuring equal left-to-right card spacing across all mobile devices.
/// - Bottom sheet for language switching with safe-area padding, close button, and non-blocking route transitions.
class ProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBackTap;
  final ValueChanged<int>? onTabSelected;
  final bool showBottomNav;
  final bool isProvider;

  const ProfileScreen({
    super.key,
    this.onBackTap,
    this.onTabSelected,
    this.showBottomNav = true,
    this.isProvider = false,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  ScrollController? _scrollControllerInstance;
  ScrollController get _scrollController =>
      _scrollControllerInstance ??= ScrollController();

  ProfileStatsData _stats = const ProfileStatsData(
    totalRequests: 0,
    completedRequests: 0,
    rating: 5.0,
    reviewsCount: 0,
  );

  String _customerName = '';

  @override
  void initState() {
    super.initState();
    _scrollControllerInstance ??= ScrollController();
    _loadProfileData();
    _loadCustomerName();
  }

  Future<void> _loadCustomerName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('customer_profile_name') ?? '';
      if (mounted) {
        setState(() => _customerName = saved);
      }
    } catch (_) {}
  }

  Future<void> _saveCustomerName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('customer_profile_name', name.trim());
      if (mounted) {
        setState(() => _customerName = name.trim());
      }
    } catch (_) {}
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isProvider != widget.isProvider) {
      _loadProfileData();
    }
  }

  Future<void> _loadProfileData() async {
    final stats = await ProfileStatsService.instance.getStats(
      isProvider: widget.isProvider,
    );
    if (!mounted) return;
    setState(() {
      _stats = stats;
    });
  }

  Future<void> _showPhotoOptionsSheet(BuildContext context, AppTranslations tr, bool isArabic) async {
    HapticFeedback.lightImpact();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
          ),
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 16.0,
            bottom: MediaQuery.of(bottomSheetContext).padding.bottom + 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Title
              Text(
                isArabic ? 'الصورة الشخصية' : 'Profile Photo',
                style: tr.font(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1C2926),
                ),
              ),
              const SizedBox(height: 18.0),

              // Option: Take Photo
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                leading: Container(
                  width: 42.0,
                  height: 42.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EAFE),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF8B53FE),
                    size: 22.0,
                  ),
                ),
                title: Text(
                  isArabic ? 'التقاط صورة (الكاميرا)' : 'Take Photo (Camera)',
                  style: tr.font(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1C2926),
                  ),
                ),
                onTap: () async {
                  Navigator.of(bottomSheetContext).pop();
                  final newPath = await ProfileStatsService.instance.pickAndSavePhoto(
                    source: ImageSource.camera,
                    isProvider: widget.isProvider,
                  );
                  if (newPath != null && mounted) {
                    setState(() {
                      _stats = _stats.copyWith(photoPath: newPath);
                    });
                  }
                },
              ),

              // Option: Choose from Gallery
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                leading: Container(
                  width: 42.0,
                  height: 42.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EAFE),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF8B53FE),
                    size: 22.0,
                  ),
                ),
                title: Text(
                  isArabic ? 'اختيار من المعرض' : 'Choose from Gallery',
                  style: tr.font(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1C2926),
                  ),
                ),
                onTap: () async {
                  Navigator.of(bottomSheetContext).pop();
                  final newPath = await ProfileStatsService.instance.pickAndSavePhoto(
                    source: ImageSource.gallery,
                    isProvider: widget.isProvider,
                  );
                  if (newPath != null && mounted) {
                    setState(() {
                      _stats = _stats.copyWith(photoPath: newPath);
                    });
                  }
                },
              ),

              // Option: Remove Photo (if set)
              if (_stats.photoPath != null && _stats.photoPath!.isNotEmpty)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  leading: Container(
                    width: 42.0,
                    height: 42.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFDC2626),
                      size: 22.0,
                    ),
                  ),
                  title: Text(
                    isArabic ? 'إزالة الصورة الحالية' : 'Remove Current Photo',
                    style: tr.font(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(bottomSheetContext).pop();
                    await ProfileStatsService.instance.removePhoto(
                      isProvider: widget.isProvider,
                    );
                    if (mounted) {
                      setState(() {
                        _stats = _stats.copyWith(photoPath: null);
                      });
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
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
                        physics: const ClampingScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: cardHorizontalMargin,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Top headroom spacing (balanced for English & Arabic, respecting status bar)
                              SizedBox(height: headerTopPadding),

                              // Header: Back Button + Profile Title (Centered) + Symmetrical right spacer
                              _buildHeader(context, tr, isArabic),
                              const SizedBox(height: 20.0),

                              // Centered User Profile Top Section (Avatar + Name + Verified Badge + Rating)
                              _buildTopProfileSection(context, tr, isArabic),
                              const SizedBox(height: 20.0),

                              // Metric Cards Row: Real Total Requests & Real Completed
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: _buildMetricCard(
                                        tr: tr,
                                        title: tr.totalRequests,
                                        value: '${_stats.totalRequests}',
                                        icon: Container(
                                          width: 38.0,
                                          height: 38.0,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0EAFE),
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          child: const Center(
                                            child: CustomPaint(
                                              size: Size(18.0, 16.0),
                                              painter: _TotalRequestsIconPainter(
                                                color: Color(0xFF8B53FE),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: _buildMetricCard(
                                        tr: tr,
                                        title: tr.completed,
                                        value: '${_stats.completedRequests}',
                                        icon: Container(
                                          width: 38.0,
                                          height: 38.0,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF0EAFE),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: 22.0,
                                              height: 22.0,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF8B53FE),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.check_rounded,
                                                  size: 14.0,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14.0),

                              // Menu Options Cards (Each item with equal left/right margins)
                              // 1. Personal Information (Only displayed on Provider side)
                              if (widget.isProvider) ...[
                                _buildProfileMenuCard(
                                  tr: tr,
                                  icon: Icons.person_rounded,
                                  title: tr.personalInfo,
                                  subtitle: tr.personalInfoSubtitle,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const ProviderProfileDetailsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10.0),

                                // 1b. Vehicle & Service Details (Provider side onboarding screen 2)
                                _buildProfileMenuCard(
                                  tr: tr,
                                  icon: Icons.directions_car_rounded,
                                  title: isArabic
                                      ? 'تفاصيل المركبة والخدمة'
                                      : 'Vehicle & Service Details',
                                  subtitle: isArabic
                                      ? 'نوع المركبة ورقم اللوحة والفئة'
                                      : 'Vehicle, plate number & category',
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const VehicleServiceDetailsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10.0),
                              ],

                              // 2. Notifications
                              _buildProfileMenuCard(
                                tr: tr,
                                icon: Icons.notifications_rounded,
                                title: tr.notifications,
                                subtitle: tr.notificationsSubtitle,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const NotificationsScreen(),
                                    ),
                                  );
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

                              // Switch Mode Card:
                              // On Provider side: "Login as Customer"
                              // On Customer side: "Login as Service Provider"
                              if (widget.isProvider)
                                _buildProfileMenuCard(
                                  tr: tr,
                                  icon: Icons.person_pin_circle_rounded,
                                  title: isArabic
                                      ? 'تسجيل الدخول كعميل'
                                      : 'Login as Customer',
                                  subtitle: isArabic
                                      ? 'التبديل إلى حساب العميل وطلب الخدمات'
                                      : 'Switch to customer mode & request services',
                                  onTap: () async {
                                    await ProviderRegistrationStore.instance
                                        .setActiveAppMode('customer');
                                    if (!context.mounted) return;
                                    Navigator.of(context).pushAndRemoveUntil(
                                      PageRouteBuilder(
                                        pageBuilder: (_, _, _) => const SplashScreen(),
                                        transitionsBuilder: (_, animation, _, child) => FadeTransition(
                                          opacity: CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeInOutCubic,
                                          ),
                                          child: child,
                                        ),
                                        transitionDuration: const Duration(milliseconds: 350),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                )
                              else
                                _buildProfileMenuCard(
                                  tr: tr,
                                  icon: Icons.handyman_rounded,
                                  title: isArabic
                                      ? 'تسجيل الدخول كمزود خدمة'
                                      : 'Login as Service Provider',
                                  subtitle: isArabic
                                      ? 'التبديل إلى وضع مزود الخدمة وتقديم الخدمات'
                                      : 'Switch to partner mode & offer services',
                                  onTap: () async {
                                    await ProviderRegistrationStore.instance
                                        .setActiveAppMode('provider');
                                    if (!context.mounted) return;
                                    Navigator.of(context).pushAndRemoveUntil(
                                      PageRouteBuilder(
                                        pageBuilder: (_, _, _) => const ProviderSplashScreen(),
                                        transitionsBuilder: (_, animation, _, child) => FadeTransition(
                                          opacity: CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeInOutCubic,
                                          ),
                                          child: child,
                                        ),
                                        transitionDuration: const Duration(milliseconds: 350),
                                      ),
                                      (route) => false,
                                    );
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
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => PrivacySecurityScreen(
                                        isProvider: widget.isProvider,
                                      ),
                                    ),
                                  );
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
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => widget.isProvider
                                          ? const ProviderHelpSupportScreen()
                                          : const CustomerFeedbackSupportScreen(),
                                    ),
                                  );
                                },
                              ),

                              // 8. Logout Button (Only on Provider Side after card tabs)
                              if (widget.isProvider) ...[
                                const SizedBox(height: 12.0),
                                _buildLogoutButton(context, tr, isArabic),
                              ],

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

  /// Header widget: Back Button + Centered Profile Title + Symmetrical Spacer
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

        // Centered Title
        Expanded(
          child: Text(
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
        ),

        // Symmetrical 36px right placeholder maintains optical balance
        const SizedBox(
          width: 36.0,
          height: 36.0,
        ),
      ],
    );
  }

  void _showEditCustomerNameDialog(BuildContext context, bool isArabic) {
    HapticFeedback.lightImpact();
    final controller = TextEditingController(text: _customerName);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text(
          isArabic ? 'تعديل اسم الملف الشخصي' : 'Edit Profile Name',
          style: isArabic
              ? GoogleFonts.cairo(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C2926),
                )
              : GoogleFonts.inter(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C2926),
                ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic
                  ? 'أدخل اسمك الحقيقي الذي يظهر لمقدمي الخدمة'
                  : 'Enter your real name as it will appear to service providers',
              style: isArabic
                  ? GoogleFonts.cairo(fontSize: 12.0, color: const Color(0xFF616166))
                  : GoogleFonts.inter(fontSize: 12.0, color: const Color(0xFF616166)),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: controller,
              autofocus: true,
              style: GoogleFonts.inter(fontSize: 14.0, color: const Color(0xFF1C2926)),
              decoration: InputDecoration(
                hintText: isArabic ? 'مثال: أحمد محمد' : 'e.g. Ahmed Mohammed',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Color(0xFF8B53FE), width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              isArabic ? 'إلغاء' : 'Cancel',
              style: GoogleFonts.inter(color: const Color(0xFF616166)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B53FE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
            onPressed: () {
              final newName = controller.text.trim();
              Navigator.of(dialogCtx).pop();
              _saveCustomerName(newName);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic ? 'تم تحديث الاسم بنجاح' : 'Name updated successfully',
                  ),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            child: Text(isArabic ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }

  /// Top Profile Section with large centered avatar, photo picker, name, verified badge, and real reviews rating
  Widget _buildTopProfileSection(BuildContext context, AppTranslations tr, bool isArabic) {
    final String displayName;
    if (widget.isProvider) {
      final String providerName = ProviderRegistrationStore.instance.data.fullName.trim();
      displayName = providerName.isNotEmpty
          ? providerName
          : (isArabic ? 'شريك زشو' : 'Zesho Partner');
    } else {
      displayName = _customerName.isNotEmpty
          ? _customerName
          : (isArabic ? 'عميل زشو' : 'Zesho User');
    }

    final bool hasCustomPhoto = _stats.photoPath != null &&
        _stats.photoPath!.isNotEmpty &&
        File(_stats.photoPath!).existsSync();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Large Centered Circular Avatar with Camera Edit Badge
        GestureDetector(
          onTap: () => _showPhotoOptionsSheet(context, tr, isArabic),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 86.0,
                height: 86.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0EAFE),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: hasCustomPhoto
                      ? Image.file(
                          File(_stats.photoPath!),
                          width: 86.0,
                          height: 86.0,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.person_rounded,
                                size: 52.0,
                                color: Color(0xFF8B53FE),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.person_rounded,
                            size: 52.0,
                            color: Color(0xFF8B53FE),
                          ),
                        ),
                ),
              ),

              // Small Camera Add/Edit Badge Button
              Positioned(
                bottom: 0.0,
                right: isArabic ? null : 0.0,
                left: isArabic ? 0.0 : null,
                child: Container(
                  width: 28.0,
                  height: 28.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B53FE),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 6.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 14.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12.0),

        // Centered Name + (Verified Badge on Provider, Edit Pen on Customer)
        GestureDetector(
          onTap: widget.isProvider
              ? null
              : () => _showEditCustomerNameDialog(context, isArabic),
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  displayName,
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
              ),
              const SizedBox(width: 6.0),
              if (widget.isProvider)
                const Icon(
                  Icons.verified_rounded,
                  size: 20.0,
                  color: Color(0xFF8B53FE),
                )
              else
                Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0EAFE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 13.0,
                    color: Color(0xFF8B53FE),
                  ),
                ),
            ],
          ),
        ),

        // Real Rating & Reviews row: ★ 4.8 (120 reviews) - Only visible on Provider side
        if (widget.isProvider) ...[
          const SizedBox(height: 6.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.star_rounded,
                size: 18.0,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(width: 4.0),
              Text(
                _stats.rating.toStringAsFixed(1),
                style: tr.font(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1C2926),
                ),
              ),
              Text(
                isArabic ? ' (${_stats.reviewsCount} تقييم)' : ' (${_stats.reviewsCount} reviews)',
                style: tr.font(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF566663),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Helper widget for the Profile Overview Metric Cards (e.g. Total Requests, Completed)
  Widget _buildMetricCard({
    required AppTranslations tr,
    required String title,
    required String value,
    required Widget icon,
    VoidCallback? onTap,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 68.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFF1F2EF),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000), // subtle soft card shadow
            blurRadius: 10.0,
            offset: Offset(0, 2),
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          title,
                          style: tr.font(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF566663),
                            height: 1.15,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          value,
                          style: tr.font(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1C2926),
                            height: 1.15,
                          ),
                          maxLines: 1,
                        ),
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
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          title,
                          style: tr.font(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1C2926),
                            height: 1.15,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          subtitle,
                          style: tr.font(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF566663),
                            height: 1.15,
                          ),
                          maxLines: 1,
                        ),
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

  /// Logout Button widget exclusively for the Provider side
  Widget _buildLogoutButton(BuildContext context, AppTranslations tr, bool isArabic) {
    final String logoutText = isArabic ? 'تسجيل الخروج' : 'Log Out';
    final String logoutSubtitle = isArabic
        ? 'تسجيل الخروج من حساب مزود الخدمة'
        : 'Sign out from provider account';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFFCA5A5).withValues(alpha: 0.5),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10.0,
            offset: Offset(0, 2),
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('provider_profile_logout_button'),
          borderRadius: BorderRadius.circular(16.0),
          onTap: () => _showLogoutConfirmation(context, tr, isArabic),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Red Logout Icon container
                Container(
                  width: 38.0,
                  height: 38.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.logout_rounded,
                      size: 20.0,
                      color: Color(0xFFEF4444),
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
                        logoutText,
                        style: tr.font(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFDC2626),
                          height: 1.1,
                        ),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        logoutSubtitle,
                        style: tr.font(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF991B1B),
                          height: 1.1,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),

                // Chevron arrow matching profile style
                Icon(
                  isArabic ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                  size: 22.0,
                  color: const Color(0xFFEF4444),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Confirmation dialog before logging out from provider account
  void _showLogoutConfirmation(BuildContext context, AppTranslations tr, bool isArabic) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text(
          isArabic ? 'تسجيل الخروج' : 'Log Out',
          style: tr.font(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1C2926),
          ),
        ),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من رغبتك في تسجيل الخروج من حساب مزود الخدمة؟'
              : 'Are you sure you want to log out from your provider account?',
          style: tr.font(
            fontSize: 14.0,
            color: const Color(0xFF566663),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              isArabic ? 'إلغاء' : 'Cancel',
              style: tr.font(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF566663),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await ProviderRegistrationStore.instance.clear();
              await ProviderRegistrationStore.instance.setActiveAppMode('customer');
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (_, _, _) => const SplashScreen(),
                  transitionsBuilder: (_, animation, _, child) => FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutCubic,
                    ),
                    child: child,
                  ),
                  transitionDuration: const Duration(milliseconds: 350),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            ),
            child: Text(
              isArabic ? 'تسجيل الخروج' : 'Log Out',
              style: tr.font(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
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
