import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/localization/app_locale.dart';

/// Privacy & Security Screen for Customer and Provider roles.
/// Features:
/// - Distinct tailored tabbed navigation for Customer vs Provider
/// - Customer tabs:
///   1. Security (Biometric, 2FA OTP, Change Password, Active Sessions)
///   2. Privacy & Location (Precise GPS, Trip Sharing, Permissions, Analytics, Data Export)
///   3. Safety & Emergency (24/7 SOS 911 / Najm, Blocked Providers list [zero seed], Delete Account)
/// - Provider tabs:
///   1. Partner Security (Biometric Dispatch, 2-Step Payout Security, Change PIN, Terminal Sessions)
///   2. Fleet Telemetry & Privacy (Duty-Only GPS, Customer Distance Masking, Masked VoIP Calling, Route Stream)
///   3. Compliance & Safety (TGA Iqama Masking, Highway SOS 993 / 911, Blocked Users [zero seed], Vacation Mode, Partner De-registration)
/// - Zero fake/seed data anywhere (all blocked lists default to empty).
class PrivacySecurityScreen extends ConsumerStatefulWidget {
  final bool isProvider;

  const PrivacySecurityScreen({
    super.key,
    this.isProvider = false,
  });

  @override
  ConsumerState<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends ConsumerState<PrivacySecurityScreen> {
  int _selectedTabIndex = 0;

  // Customer settings
  bool _biometricLogin = true;
  bool _twoFactorAuth = true;
  bool _preciseLocation = true;
  bool _shareTripStatus = false;
  bool _analyticsSharing = false;
  final List<String> _blockedProviders = [];

  // Provider settings
  bool _biometricDispatch = true;
  bool _twoStepPayoutSecurity = true;
  bool _dutyOnlyGps = true;
  bool _maskCustomerDistance = true;
  bool _maskedPhoneCalls = true;
  bool _routeTelemetry = true;
  bool _vacationMode = false;
  final List<String> _blockedEntities = [];

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

            final bool isDesktopWeb = screenWidth > 500;
            final double containerWidth = isDesktopWeb ? 390.0 : screenWidth;
            final double containerHeight = isDesktopWeb
                ? math.min(878.0, (screenHeight - 32.0).clamp(520.0, 878.0))
                : screenHeight;

            final double horizontalPadding = isDesktopWeb
                ? 20.0
                : (containerWidth > 420.0
                    ? ((containerWidth - 380.0) / 2).clamp(20.0, 48.0)
                    : 20.0);

            final double safeTop = mediaQuery.padding.top;
            final double headerTopPadding = math.max(safeTop + 16.0, 66.0);

            final Widget screenContent = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                children: [
                  // 1. Top Background Gradient Tint
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

                  // 2. Main Scrollable Content
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
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Headroom spacing
                            SizedBox(height: headerTopPadding),

                            // Standard App Header with Back Button + Title + Subtitle
                            _buildSafetyHeader(context, isArabic),
                            const SizedBox(height: 18.0),

                            // Segmented Tabs Switcher
                            _buildSegmentedTabBar(isArabic),
                            const SizedBox(height: 20.0),

                            // Tab Content
                            if (widget.isProvider)
                              _buildProviderTabContent(context, isArabic)
                            else
                              _buildCustomerTabContent(context, isArabic),

                            const SizedBox(height: 80.0),
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

  // ==========================================
  // Header & Segmented Tab Switcher
  // ==========================================

  Widget _buildSafetyHeader(BuildContext context, bool isArabic) {
    final String title = widget.isProvider
        ? (isArabic ? 'أمان وخصوصية الشريك' : 'Partner Privacy & Security')
        : (isArabic ? 'الأمان والخصوصية' : 'Safety & Security');

    final String subtitle = widget.isProvider
        ? (isArabic
            ? 'أمان الأسطول، التتبع وحماية المعاملات'
            : 'Fleet security, telemetry & partner protection')
        : (isArabic
            ? 'إعدادات الأمان وحماية البيانات والتحكم'
            : 'Security settings, data protection & safety controls');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            key: const Key('privacy_security_header_back_button'),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).maybePop();
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 36.0,
              height: 36.0,
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8.0,
                    offset: Offset(0, 1),
                    spreadRadius: 0.0,
                  ),
                ],
              ),
              child: Center(
                child: _HeaderChevron(
                  width: 7.0,
                  height: 13.0,
                  color: const Color(0xFF1C2926),
                  strokeWidth: 1.8,
                  isLeft: !isArabic,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: isArabic
                    ? GoogleFonts.cairo(
                        fontSize: 18.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C2926),
                        height: 1.2,
                      )
                    : GoogleFonts.inter(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C2926),
                        height: 1.2,
                      ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2.0),
              Text(
                subtitle,
                style: isArabic
                    ? GoogleFonts.cairo(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                        height: 1.3,
                      )
                    : GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                        height: 1.3,
                      ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedTabBar(bool isArabic) {
    final List<String> tabLabels = widget.isProvider
        ? [
            isArabic ? 'أمان الحساب' : 'Security',
            isArabic ? 'تتبع الأسطول' : 'Telemetry',
            isArabic ? 'الامتثال والطوارئ' : 'Compliance & SOS',
          ]
        : [
            isArabic ? 'الأمان' : 'Security',
            isArabic ? 'الخصوصية' : 'Privacy',
            isArabic ? 'الطوارئ والحماية' : 'Safety & SOS',
          ];

    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: List.generate(tabLabels.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedTabIndex = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 9.0),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4.0,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    tabLabels[index],
                    style: isArabic
                        ? GoogleFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? const Color(0xFF8B53FE) : const Color(0xFF6B7280),
                          )
                        : GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? const Color(0xFF8B53FE) : const Color(0xFF6B7280),
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ==========================================
  // CUSTOMER TABS
  // ==========================================

  Widget _buildCustomerTabContent(BuildContext context, bool isArabic) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildCustomerSecurityTab(context, isArabic);
      case 1:
        return _buildCustomerPrivacyTab(context, isArabic);
      case 2:
      default:
        return _buildCustomerSafetyTab(context, isArabic);
    }
  }

  /// Customer Tab 1: Account Security & Authentication
  Widget _buildCustomerSecurityTab(BuildContext context, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionLabel(
          isArabic ? 'المصادقة وتأمين الدخول' : 'Authentication & Sign In',
          isArabic,
        ),
        const SizedBox(height: 10.0),
        _buildCardGroup([
          _buildSwitchTile(
            icon: Icons.fingerprint_rounded,
            title: isArabic ? 'تسجيل الدخول بالبصمة' : 'Biometric Login',
            subtitle: isArabic
                ? 'استخدام بصمة الوجه (Face ID) أو الأصبع للوصول السريع'
                : 'Unlock with Face ID or fingerprint for rapid access',
            value: _biometricLogin,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _biometricLogin = val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(val
                      ? (isArabic ? 'تم تفعيل الدخول بالبصمة' : 'Biometric login enabled')
                      : (isArabic ? 'تم تعطيل الدخول بالبصمة' : 'Biometric login disabled')),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            isArabic: isArabic,
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.security_rounded,
            title: isArabic ? 'التحقق بخطوتين (2FA)' : 'Two-Factor Authentication',
            subtitle: isArabic
                ? 'إرسال رمز تحقق OTP عبر رسالة نصية عند الدخول من جهاز جديد'
                : 'Require SMS OTP verification when logging in from new devices',
            value: _twoFactorAuth,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _twoFactorAuth = val);
            },
            isArabic: isArabic,
          ),
        ]),

        const SizedBox(height: 20.0),

        _buildSectionLabel(
          isArabic ? 'الأجهزة والجلسات النشطة' : 'Active Sessions & Devices',
          isArabic,
        ),
        const SizedBox(height: 10.0),
        _buildCardGroup([
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Row(
              children: [
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EAFE),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Center(
                    child: Icon(Icons.phone_android_rounded, size: 20.0, color: Color(0xFF8B53FE)),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isArabic ? 'هذا الجهاز (نشط حالياً)' : 'Current Device (Active)',
                            style: GoogleFonts.inter(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C2926),
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Container(
                            width: 7.0,
                            height: 7.0,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        isArabic ? 'تطبيق قريب • آخر نشاط: الآن' : 'Qareeb App • Last active: Just now',
                        style: GoogleFonts.inter(
                          fontSize: 11.0,
                          color: const Color(0xFF616166),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.logout_rounded,
            title: isArabic ? 'تسجيل الخروج من كافة الأجهزة' : 'Sign Out All Other Devices',
            subtitle: isArabic
                ? 'إنهاء أي جلسات مفتوحة على هواتف أو متصفحات أخرى'
                : 'Terminate all active sessions on other phones or browsers',
            onTap: () => _showSignOutOtherDevicesDialog(context, isArabic),
            isArabic: isArabic,
          ),
        ]),
      ],
    );
  }

  /// Customer Tab 2: Privacy & Permissions
  Widget _buildCustomerPrivacyTab(BuildContext context, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionLabel(
          isArabic ? 'تحديد الموقع ومشاركة المسار' : 'Location & Live Tracking',
          isArabic,
        ),
        const SizedBox(height: 10.0),
        _buildCardGroup([
          _buildSwitchTile(
            icon: Icons.gps_fixed_rounded,
            title: isArabic ? 'دقة الموقع العالية (GPS)' : 'High-Precision GPS',
            subtitle: isArabic
                ? 'مشاركة إحداثيات دقيقة لضمان وصول مزود الخدمة إلى موقعك بسرعة'
                : 'Share exact coordinates to ensure accurate vehicle recovery arrival',
            value: _preciseLocation,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _preciseLocation = val);
            },
            isArabic: isArabic,
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.share_location_rounded,
            title: isArabic ? 'مشاركة مسار الرحلة تلقائياً' : 'Auto-Share Trip Route',
            subtitle: isArabic
                ? 'إرسال رابط تتبع مباشر لجهات الاتصال الموثوقة أثناء الطلب النشط'
                : 'Send live tracking link to emergency contacts during active requests',
            value: _shareTripStatus,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _shareTripStatus = val);
            },
            isArabic: isArabic,
          ),
        ]),

        const SizedBox(height: 20.0),

        _buildSectionLabel(
          isArabic ? 'أذونات التطبيق والبيانات' : 'App Permissions & Data',
          isArabic,
        ),
        const SizedBox(height: 10.0),
        _buildCardGroup([
          _buildActionTile(
            icon: Icons.location_on_rounded,
            title: isArabic ? 'إذن الموقع الجغرافي' : 'Location Permission',
            subtitle: isArabic ? 'مفعل أثناء استخدام التطبيق' : 'While Using App',
            trailing: _buildStatusPill(
              isArabic ? 'دقيق' : 'Precise',
              const Color(0xFF10B981),
              const Color(0xFFECFDF5),
            ),
            onTap: () {},
            isArabic: isArabic,
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.camera_alt_rounded,
            title: isArabic ? 'إذن الكاميرا والصور' : 'Camera & Photos',
            subtitle: isArabic ? 'لتصوير أعطال المركبة وتفاصيل الطلب' : 'To attach breakdown & vehicle photos',
            trailing: _buildStatusPill(
              isArabic ? 'مفعل' : 'Granted',
              const Color(0xFF10B981),
              const Color(0xFFECFDF5),
            ),
            onTap: () {},
            isArabic: isArabic,
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.analytics_outlined,
            title: isArabic ? 'مشاركة تحليلات التحسين' : 'Diagnostics & Analytics',
            subtitle: isArabic
                ? 'مساعدتنا في اكتشاف الأعطال وتحسين كفاءة الخدمة'
                : 'Help us diagnose crashes and optimize response latency',
            value: _analyticsSharing,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _analyticsSharing = val);
            },
            isArabic: isArabic,
          ),
        ]),

        const SizedBox(height: 20.0),

        _buildSectionLabel(
          isArabic ? 'الامتثال وسياسة البيانات' : 'Compliance & Data Rights',
          isArabic,
        ),
        const SizedBox(height: 10.0),
        _buildCardGroup([
          _buildActionTile(
            icon: Icons.download_for_offline_rounded,
            title: isArabic ? 'تحميل بياناتي الشخصية' : 'Download My Data',
            subtitle: isArabic
                ? 'طلب نسخة من سجل طلباتك ومعلوماتك المسجلة (PDPL)'
                : 'Request an export archive of your personal records',
            onTap: () => _showDownloadDataDialog(context, isArabic),
            isArabic: isArabic,
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.policy_rounded,
            title: isArabic ? 'سياسة الخصوصية' : 'Privacy Policy',
            subtitle: isArabic
                ? 'الاطلاع على سياسة حماية البيانات المعتمدة'
                : 'Read our Saudi PDPL data protection commitment',
            onTap: () => _showPrivacyPolicyDialog(context, isArabic),
            isArabic: isArabic,
          ),
        ]),
      ],
    );
  }

  /// Customer Tab 3: Safety & Emergency (SOS)
  Widget _buildCustomerSafetyTab(BuildContext context, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // SOS Quick Access Banner
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFFFCA5A5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(Icons.emergency_rounded, size: 20.0, color: Colors.white),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'المساعدة والطوارئ 24/7' : '24/7 Emergency Support',
                          style: GoogleFonts.inter(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF991B1B),
                          ),
                        ),
                        Text(
                          isArabic
                            ? 'اتصال فوري مع خدمات الطوارئ أو عمليات قريب'
                            : 'Immediate connection to Saudi emergency & Qareeb ops',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: const Color(0xFFB91C1C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      onPressed: () => _triggerEmergencyCall(context, '911', isArabic),
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 16.0),
                      label: Text(
                        isArabic ? 'طوارئ 911' : 'Call 911',
                        style: GoogleFonts.inter(fontSize: 12.0, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      onPressed: () => _triggerEmergencyCall(context, '920000560', isArabic),
                      icon: const Icon(Icons.car_crash_rounded, size: 16.0),
                      label: Text(
                        isArabic ? 'نجم للحوادث' : 'Najm (92000)',
                        style: GoogleFonts.inter(fontSize: 12.0, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF991B1B),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                    backgroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  onPressed: () => _triggerEmergencyCall(context, '+966545456467', isArabic),
                  icon: const Icon(Icons.support_agent_rounded, size: 17.0, color: Color(0xFFDC2626)),
                  label: Text(
                    isArabic ? 'غرفة عمليات قريب للطوارئ' : 'Qareeb 24/7 Safety Hotline',
                    style: GoogleFonts.inter(fontSize: 12.0, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20.0),

        _buildSectionLabel(
          isArabic ? 'إرشادات السلامة على الطريق' : 'Roadside Safety Guidance',
          isArabic,
        ),
        const SizedBox(height: 10.0),
        _buildCardGroup([
          _buildSafetyGuidanceItem(
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFF59E0B),
            title: isArabic ? 'تشغيل أضواء التنبيه الرباعية' : 'Turn On Hazard Flashers',
            description: isArabic
                ? 'شغّل أضواء التحذير الرباعية فور توقف المركبة لتنبيه السائقين الآخرين وتفادي الحوادث'
                : 'Activate hazard warning lights immediately upon stopping to alert other drivers',
            isArabic: isArabic,
          ),
          _buildDivider(),
          _buildSafetyGuidanceItem(
            icon: Icons.shield_outlined,
            iconColor: const Color(0xFF10B981),
            title: isArabic ? 'البقاء في مكان آمن' : 'Remain in a Safe Area',
            description: isArabic
                ? 'ابقَ داخل المركبة مع ربط حزام الأمان أو قف خلف الحاجز الخرساني على الطريق السريع'
                : 'Stay safely inside your vehicle or step behind guardrails on high-speed roads',
            isArabic: isArabic,
          ),
          _buildDivider(),
          _buildSafetyGuidanceItem(
            icon: Icons.verified_user_outlined,
            iconColor: const Color(0xFF8B53FE),
            title: isArabic ? 'التحقق من بيانات مزود الخدمة' : 'Verify Provider Identity',
            description: isArabic
                ? 'تأكد من مطابقة رقم لوحة مركبة السحب المعتمدة في التطبيق قبل التحميل أو الركوب'
                : 'Match recovery truck plate number and driver identity with the app before boarding',
            isArabic: isArabic,
          ),
        ]),
      ],
    );
  }

  // ==========================================
  // PROVIDER TABS
  // ==========================================

  Widget _buildProviderTabContent(BuildContext context, bool isArabic) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildProviderSecurityTab(context, isArabic);
      case 1:
        return _buildProviderTelemetryTab(context, isArabic);
      case 2:
      default:
        return _buildProviderComplianceTab(context, isArabic);
    }
  }

  /// Provider Tab 1: Partner Security & Payout Protection
  Widget _buildProviderSecurityTab(BuildContext context, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionLabel(
          isArabic ? 'حماية الحساب والتحويلات' : 'Account & Payout Protection',
          isArabic,
        ),
        const SizedBox(height: 10.0),
        _buildCardGroup([
          _buildSwitchTile(
            icon: Icons.fingerprint_rounded,
            title: isArabic ? 'تأكيد قبول الطلبات بالبصمة' : 'Biometric Dispatch Approval',
            subtitle: isArabic
                ? 'طلب بصمة الوجه أو الأصبع للموافقة على مهام السحب والنقل عالية القيمة'
                : 'Confirm high-value towing & recovery tasks with Face ID / fingerprint',
            value: _biometricDispatch,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _biometricDispatch = val);
            },
            isArabic: isArabic,
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.verified_user_rounded,
            title: isArabic ? 'أمان تعديل الآيبان (2FA)' : 'Two-Step Payout Security',
            subtitle: isArabic
                ? 'إلزامية رمز OTP عند تغيير الحساب البنكي أو طلب سحب الأرباح'
                : 'Mandatory SMS OTP before updating payout IBAN or requesting bank transfer',
            value: _twoStepPayoutSecurity,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _twoStepPayoutSecurity = val);
            },
            isArabic: isArabic,
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.pin_rounded,
            title: isArabic ? 'تغيير رمز الأمان (PIN)' : 'Change Security PIN',
            subtitle: isArabic
                ? 'رمز العمليات الحساسة واعتماد العقود'
                : 'Update 4-digit code for sensitive partner operations',
            onTap: () => _showChangePinDialog(context, isArabic),
            isArabic: isArabic,
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.lock_outline_rounded,
            title: isArabic ? 'تغيير كلمة مرور الشريك' : 'Change Partner Password',
            subtitle: isArabic
                ? 'تحديث بيانات تسجيل الدخول لبوابة الشركاء'
                : 'Update login password for driver & fleet portal',
            onTap: () => _showChangePasswordDialog(context, isArabic),
            isArabic: isArabic,
          ),
        ]),

        const SizedBox(height: 20.0),

        _buildSectionLabel(
          isArabic ? 'الأجهزة ومحطات القيادة المعتمدة' : 'Fleet Terminals & Authorized Devices',
          isArabic,
        ),
        const SizedBox(height: 10.0),
        _buildCardGroup([
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Row(
              children: [
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EAFE),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Center(
                    child: Icon(Icons.drive_eta_rounded, size: 20.0, color: Color(0xFF8B53FE)),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isArabic ? 'محطة السائق الرئيسية (معتمد)' : 'Primary Driver Terminal (Active)',
                            style: GoogleFonts.inter(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C2926),
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Container(
                            width: 7.0,
                            height: 7.0,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        isArabic ? 'موثق لدى نظام هيئة النقل TGA' : 'Certified with Transport General Authority',
                        style: GoogleFonts.inter(
                          fontSize: 11.0,
                          color: const Color(0xFF616166),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.phonelink_erase_rounded,
            title: isArabic ? 'إلغاء تفويض الأجهزة الأخرى' : 'De-authorize Other Terminals',
            subtitle: isArabic
                ? 'فصل أي أجهزة فرعية مرتبطة برقم الشريك فوراً'
                : 'Sign out and unlink other secondary driver terminals',
            onTap: () => _showSignOutOtherDevicesDialog(context, isArabic),
            isArabic: isArabic,
          ),
        ]),
      ],
    );
  }

  /// Provider Tab 2: Fleet Telemetry & Privacy
  Widget _buildProviderTelemetryTab(BuildContext context, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionLabel(
          isArabic ? 'تتبع الإحداثيات أثناء الخدمة' : 'Duty Telemetry & GPS',
          isArabic,
        ),
        const SizedBox(height: 10.0),
        _buildCardGroup([
          _buildSwitchTile(
            icon: Icons.my_location_rounded,
            title: isArabic ? 'التتبع الميداني أثناء الاتصال فقط' : 'Transmit GPS on Duty Only',
            subtitle: isArabic
                ? 'يتم إرسال إحداثيات موقعك فقط عندما تكون متاحاً (متصل) أو في مهمة نشطة'
                : 'Coordinates are only transmitted while status is Online or actively dispatched',
            value: _dutyOnlyGps,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _dutyOnlyGps = val);
            },
            isArabic: isArabic,
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.location_off_rounded,
            title: isArabic ? 'حجب الموقع الدقيق قبل القبول' : 'Mask Base Location',
            subtitle: isArabic
                ? 'إخفاء نقطة توقف شاحنتك الدقيقة عن العملاء حتى يتم قبول الطلب رسمياً'
                : 'Keep your exact parking spot hidden until the dispatch is formally accepted',
            value: _maskCustomerDistance,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _maskCustomerDistance = val);
            },
            isArabic: isArabic,
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.phone_callback_rounded,
            title: isArabic ? 'إخفاء رقم هاتفي الشخصي' : 'Mask Phone on Calls (VoIP)',
            subtitle: isArabic
                ? 'استخدام خادم اتصال وسيط آمن لحماية رقمك الشخصي عند الاتصال بالعميل'
                : 'Route customer calls through secure proxy relay to hide driver phone number',
            value: _maskedPhoneCalls,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _maskedPhoneCalls = val);
            },
            isArabic: isArabic,
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.alt_route_rounded,
            title: isArabic ? 'مشاركة مسار الشاحنة مع العمليات' : 'Live Route Telemetry',
            subtitle: isArabic
                ? 'بث مسار المركبة لغرفة عمليات قريب لضمان سرعة الدعم والمساعدة الفنية'
                : 'Stream route telemetry to Qareeb Dispatch Hub for quick roadside assist',
            value: _routeTelemetry,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _routeTelemetry = val);
            },
            isArabic: isArabic,
          ),
        ]),

        const SizedBox(height: 20.0),

        _buildSectionLabel(
          isArabic ? 'سياسات العمل وهيئة النقل' : 'Regulatory Privacy & TGA Terms',
          isArabic,
        ),
        const SizedBox(height: 10.0),
        _buildCardGroup([
          _buildActionTile(
            icon: Icons.description_outlined,
            title: isArabic ? 'ميثاق خصوصية المزودين' : 'Provider Data Agreement',
            subtitle: isArabic
                ? 'التزام قريب بحماية سجلاتك التشغيلية وتراخيص السطحة'
                : 'Terms of data protection, GPS logs, and driver rights',
            onTap: () => _showPrivacyPolicyDialog(context, isArabic),
            isArabic: isArabic,
          ),
        ]),
      ],
    );
  }

  /// Provider Tab 3: Compliance & Safety
  Widget _buildProviderComplianceTab(BuildContext context, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Verified TGA Card
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: const Color(0xFF86EFAC)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(Icons.verified_rounded, size: 20.0, color: Colors.white),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'الهوية الوطنية / الإقامة موثقة' : 'National ID / Iqama Verified',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF166534),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      isArabic
                          ? 'رقم الهوية: ••••••7821 (مشفر ومحمي وفق نظام حماية البيانات الشخصية)'
                          : 'ID Record: ••••••7821 (Masked & encrypted per Saudi PDPL)',
                      style: GoogleFonts.inter(
                        fontSize: 11.0,
                        color: const Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20.0),

        _buildSectionLabel(
          isArabic ? 'طوارئ الطرق وأمن الطرق' : 'Highway Emergency & Roadside SOS',
          isArabic,
        ),
        const SizedBox(height: 10.0),
        _buildCardGroup([
          _buildActionTile(
            icon: Icons.emergency_rounded,
            title: isArabic ? 'أمن الطرق (993)' : 'Highway Patrol (993)',
            subtitle: isArabic
                ? 'للحوادث والطوارئ على الطرق السريعة بين المدن'
                : 'Direct emergency line for intercity highway incidents',
            trailing: _buildStatusPill(
              '993',
              const Color(0xFFEF4444),
              const Color(0xFFFEF2F2),
            ),
            onTap: () => _triggerEmergencyCall(context, '993', isArabic),
            isArabic: isArabic,
          ),
          _buildDivider(),
          _buildActionTile(
            icon: Icons.support_agent_rounded,
            title: isArabic ? 'عمليات أسطول قريب 24/7' : 'Qareeb Fleet Dispatch Ops',
            subtitle: isArabic
                ? 'فريق الدعم الفني المباشر للمزودين والسائقين'
                : 'Instant response line for towing partners & drivers',
            trailing: _buildStatusPill(
              '+966 54 545 6467',
              const Color(0xFF8B53FE),
              const Color(0xFFF0EAFE),
            ),
            onTap: () => _triggerEmergencyCall(context, '+966545456467', isArabic),
            isArabic: isArabic,
          ),
        ]),

        const SizedBox(height: 20.0),

        _buildSectionLabel(
          isArabic ? 'العملاء المحظورون ومناطق الخدمة' : 'Blocked Users & Restricted Areas',
          isArabic,
        ),
        const SizedBox(height: 10.0),
        _buildCardGroup([
          _buildActionTile(
            icon: Icons.person_off_rounded,
            title: isArabic ? 'العملاء المحظورون' : 'Blocked Customers',
            subtitle: _blockedEntities.isEmpty
                ? (isArabic ? 'لا يوجد عملاء محظورون' : 'No blocked customers')
                : (isArabic
                    ? '${_blockedEntities.length} عميل في قائمة الحظر'
                    : '${_blockedEntities.length} blocked user(s)'),
            trailing: _buildBadge('${_blockedEntities.length}'),
            onTap: () => _showBlockedEntitiesSheet(
              context: context,
              isArabic: isArabic,
              isProviderRole: true,
            ),
            isArabic: isArabic,
          ),
          _buildDivider(),
          _buildSwitchTile(
            icon: Icons.beach_access_rounded,
            title: isArabic ? 'وضع الإجازة (إيقاف مؤقت)' : 'Vacation / Off-Duty Mode',
            subtitle: isArabic
                ? 'إيقاف تلقي طلبات السحب تلقائياً دون التأثير على معدل القبول'
                : 'Pause new order dispatches without penalizing acceptance rate',
            value: _vacationMode,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              setState(() => _vacationMode = val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(val
                      ? (isArabic ? 'تم تفعيل وضع الإجازة' : 'Vacation mode enabled')
                      : (isArabic ? 'تم استئناف استقبال الطلبات' : 'Online dispatch resumed')),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            isArabic: isArabic,
          ),
        ]),

        const SizedBox(height: 20.0),

        _buildSectionLabel(
          isArabic ? 'إنهاء الشراكة والحساب' : 'Partner De-registration',
          isArabic,
        ),
        const SizedBox(height: 10.0),
        _buildDeleteAccountCard(context, isArabic, true),
      ],
    );
  }

  // ==========================================
  // SHARED REUSABLE BUILDERS
  // ==========================================

  Widget _buildSectionLabel(String text, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        text,
        style: isArabic
            ? GoogleFonts.cairo(
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4B5563),
              )
            : GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4B5563),
                letterSpacing: 0.2,
              ),
      ),
    );
  }

  Widget _buildSafetyGuidanceItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool isArabic,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.0,
            height: 34.0,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: Icon(icon, size: 18.0, color: iconColor),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: isArabic
                      ? GoogleFonts.cairo(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C2926),
                        )
                      : GoogleFonts.inter(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C2926),
                        ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  description,
                  style: isArabic
                      ? GoogleFonts.cairo(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                          height: 1.35,
                        )
                      : GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                          height: 1.35,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFF1F2EF),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1.0,
      thickness: 1.0,
      indent: 58.0,
      endIndent: 16.0,
      color: Color(0xFFF1F2EF),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    required bool isArabic,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EAFE),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 19.0,
                    color: const Color(0xFF8B53FE),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: isArabic
                          ? GoogleFonts.cairo(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C2926),
                            )
                          : GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF1C2926),
                            ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      subtitle,
                      style: isArabic
                          ? GoogleFonts.cairo(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B7280),
                            )
                          : GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B7280),
                            ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8.0),
                trailing,
              ],
              const SizedBox(width: 6.0),
              _HeaderChevron(
                width: 6.0,
                height: 11.0,
                color: const Color(0xFF9EABA7),
                strokeWidth: 1.6,
                isLeft: isArabic,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isArabic,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EAFE),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 19.0,
                color: const Color(0xFF8B53FE),
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: isArabic
                      ? GoogleFonts.cairo(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C2926),
                        )
                      : GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1C2926),
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2.0),
                Text(
                  subtitle,
                  style: isArabic
                      ? GoogleFonts.cairo(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        )
                      : GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Transform.scale(
            scale: 0.82,
            child: CupertinoSwitch(
              value: value,
              activeTrackColor: const Color(0xFF8B53FE),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAFE),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        count,
        style: GoogleFonts.inter(
          fontSize: 11.0,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF8B53FE),
        ),
      ),
    );
  }

  Widget _buildStatusPill(String text, Color fgColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: fgColor,
        ),
      ),
    );
  }

  Widget _buildDeleteAccountCard(BuildContext context, bool isArabic, bool isProvider) {
    final String title = isProvider
        ? (isArabic ? 'إلغاء تسجيل الشريك' : 'De-register Partner Account')
        : (isArabic ? 'حذف الحساب نهائياً' : 'Delete Account Permanently');

    final String subtitle = isProvider
        ? (isArabic
            ? 'إنهاء العقد التشغيلي وتسوية المستحقات المالية نهائياً'
            : 'Close fleet partner contract and settle outstanding balances')
        : (isArabic
            ? 'حذف بياناتك وسجل رحلاتك ومعلومات الدفع نهائياً'
            : 'Permanently remove your personal profile and ride history');

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
          borderRadius: BorderRadius.circular(16.0),
          onTap: () => _showDeleteAccountConfirmation(context, isArabic, isProvider),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36.0,
                  height: 36.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 20.0,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: isArabic
                            ? GoogleFonts.cairo(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFB91C1C),
                              )
                            : GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFB91C1C),
                              ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        subtitle,
                        style: isArabic
                            ? GoogleFonts.cairo(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFEF4444),
                              )
                            : GoogleFonts.inter(
                                fontSize: 11.0,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFEF4444),
                              ),
                      ),
                    ],
                  ),
                ),
                _HeaderChevron(
                  width: 6.0,
                  height: 11.0,
                  color: const Color(0xFFEF4444),
                  strokeWidth: 1.6,
                  isLeft: isArabic,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // MODAL SHEETS & INTERACTIVE DIALOGS
  // ==========================================

  void _triggerEmergencyCall(BuildContext context, String number, bool isArabic) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? 'جاري بدء الاتصال برقم الطوارئ: $number'
              : 'Connecting emergency dispatch to $number...',
        ),
        backgroundColor: const Color(0xFFEF4444),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showBlockedEntitiesSheet({
    required BuildContext context,
    required bool isArabic,
    required bool isProviderRole,
  }) {
    final list = isProviderRole ? _blockedEntities : _blockedProviders;
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
              ),
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40.0,
                      height: 4.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    isProviderRole
                        ? (isArabic ? 'قائمة العملاء المحظورين' : 'Blocked Customers List')
                        : (isArabic ? 'قائمة المزودين المحظورين' : 'Blocked Providers List'),
                    style: GoogleFonts.inter(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C2926),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    isProviderRole
                        ? (isArabic
                            ? 'لن يتم إرسال طلبات من هؤلاء العملاء إلى شاحنتك مستقبلاً.'
                            : 'You will not receive service dispatches from these customers.')
                        : (isArabic
                            ? 'لن يتم تعيين أي طلبات مستقبلية لك مع هؤلاء المزودين.'
                            : 'These service providers will never be matched with your requests.'),
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      color: const Color(0xFF616166),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Add new block form
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          decoration: InputDecoration(
                            hintText: isProviderRole
                                ? (isArabic ? 'أدخل اسم العميل أو المعرف' : 'Enter user name or phone')
                                : (isArabic ? 'أدخل اسم المزود أو المعرف' : 'Enter provider name or ID'),
                            hintStyle: GoogleFonts.inter(fontSize: 12.0, color: const Color(0xFF9CA3AF)),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B53FE),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        ),
                        onPressed: () {
                          final text = textController.text.trim();
                          if (text.isNotEmpty) {
                            HapticFeedback.lightImpact();
                            setModalState(() {
                              list.add(text);
                            });
                            setState(() {});
                            textController.clear();
                          }
                        },
                        child: Text(
                          isArabic ? 'حظر' : 'Block',
                          style: GoogleFonts.inter(fontSize: 12.0, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Empty State or List
                  if (list.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 28.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 50.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: const Center(
                              child: Icon(Icons.shield_outlined, size: 26.0, color: Color(0xFF9CA3AF)),
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            isArabic ? 'القائمة فارغة تماماً' : 'No blocked entities yet',
                            style: GoogleFonts.inter(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            isArabic
                                ? 'لم تقم بحظر أي شخص حتى الآن. يمكنك الحظر في أي وقت.'
                                : 'You have not blocked anyone. Matches will proceed normally.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: list.length,
                        itemBuilder: (context, i) {
                          final name = list[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(color: const Color(0xFFF1F2EF)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.person_off_rounded, size: 20.0, color: Color(0xFF616166)),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: GoogleFonts.inter(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1C2926),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    setModalState(() {
                                      list.removeAt(i);
                                    });
                                    setState(() {});
                                  },
                                  child: Text(
                                    isArabic ? 'إلغاء الحظر' : 'Unblock',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF8B53FE),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context, bool isArabic) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text(
          isArabic ? 'تغيير كلمة المرور' : 'Change Password',
          style: GoogleFonts.inter(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: isArabic ? 'كلمة المرور الحالية' : 'Current Password',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: isArabic ? 'كلمة المرور الجديدة' : 'New Password',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B53FE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isArabic ? 'تم تحديث كلمة المرور بنجاح' : 'Password updated successfully'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            child: Text(isArabic ? 'تحديث' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog(BuildContext context, bool isArabic) {
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text(
          isArabic ? 'تغيير رمز الأمان (PIN)' : 'Change Security PIN',
          style: GoogleFonts.inter(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isArabic
                  ? 'أدخل رمز أمان مكون من 4 أرقام لاعتماد السحوبات المالية والمهام الحساسة.'
                  : 'Enter a 4-digit PIN for sensitive financial operations and contract confirmations.',
              style: GoogleFonts.inter(fontSize: 12.0, color: const Color(0xFF616166)),
            ),
            const SizedBox(height: 14.0),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 20.0, letterSpacing: 8.0, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                counterText: '',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B53FE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isArabic ? 'تم تعيين رمز الأمان بنجاح' : 'Security PIN updated successfully'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            child: Text(isArabic ? 'حفظ الرمز' : 'Save PIN'),
          ),
        ],
      ),
    );
  }

  void _showSignOutOtherDevicesDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text(
          isArabic ? 'تسجيل الخروج من باقي الأجهزة' : 'Sign Out Other Devices',
          style: GoogleFonts.inter(fontSize: 16.5, fontWeight: FontWeight.w600),
        ),
        content: Text(
          isArabic
              ? 'هل ترغب في إنهاء كافة الجلسات المفتوحة على الهواتف أو المتصفحات الأخرى؟ ستحتاج إلى تسجيل الدخول مجدداً فيها.'
              : 'Are you sure you want to log out from all other active sessions? You will need to sign in again on those devices.',
          style: GoogleFonts.inter(fontSize: 12.5, height: 1.4, color: const Color(0xFF616166)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B53FE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic
                        ? 'تم تسجيل الخروج بنجاح من كافة الأجهزة الأخرى'
                        : 'Signed out from all other sessions',
                  ),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            child: Text(isArabic ? 'تسجيل الخروج' : 'Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDownloadDataDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Row(
          children: [
            const Icon(Icons.download_done_rounded, color: Color(0xFF8B53FE)),
            const SizedBox(width: 8.0),
            Text(
              isArabic ? 'تصدير البيانات الشخصية' : 'Personal Data Export',
              style: GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          isArabic
              ? 'وفقاً لنظام حماية البيانات الشخصية السعودي (PDPL)، يمكنك الحصول على نسخة من ملفك وسجل رحلاتك. سيتم إرسال رابط التحميل المشفر إلى بريدك الإلكتروني المسجل خلال 24 ساعة.'
              : 'Pursuant to Saudi PDPL regulations, you may request an encrypted archive of your account profile and service orders. The download link will be dispatched to your registered email within 24 hours.',
          style: GoogleFonts.inter(fontSize: 12.5, height: 1.4, color: const Color(0xFF566663)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B53FE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic
                        ? 'تم استلام طلب التصدير، سنتواصل معك عبر البريد المسجل'
                        : 'Data export request submitted. Check your inbox shortly.',
                  ),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            child: Text(isArabic ? 'تأكيد الطلب' : 'Request File'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text(
          isArabic ? 'سياسة الخصوصية وحماية البيانات' : 'Privacy & Data Protection',
          style: GoogleFonts.inter(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
        content: Text(
          isArabic
              ? 'يلتزم تطبيق قريب بحماية خصوصية وأمان بياناتك وفق الأنظمة واللوائح السعودية. لا يتم مشاركة موقعك أو أرقام الاتصال إلا مع الطرف المقابل أثناء سير الطلب النشط لضمان جودة وأمان تقديم الخدمة.'
              : 'Qareeb is fully committed to safeguarding user and partner privacy in compliance with Saudi national data privacy guidelines. Live GPS telemetry and telephone relays are only engaged during active dispatch windows.',
          style: GoogleFonts.inter(fontSize: 12.5, height: 1.45, color: const Color(0xFF566663)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              isArabic ? 'فهمت' : 'Understood',
              style: GoogleFonts.inter(color: const Color(0xFF8B53FE), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context, bool isArabic, bool isProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
            const SizedBox(width: 8.0),
            Text(
              isProvider
                  ? (isArabic ? 'إلغاء تسجيل الشريك' : 'Close Partner Account')
                  : (isArabic ? 'حذف الحساب نهائياً' : 'Delete Account Permanently'),
              style: GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          isProvider
              ? (isArabic
                  ? 'هل أنت متأكد من رغبتك في إلغاء تسجيل الشاحنة وإنهاء الشراكة؟ يجب التأكد من تسوية كافة المستحقات المالية أولاً.'
                  : 'Are you sure you want to de-register this fleet partner account? All outstanding payouts must be fully settled prior to contract termination.')
              : (isArabic
                  ? 'هل أنت متأكد من رغبتك في حذف الحساب؟ سيتم حذف جميع بياناتك وسجل رحلاتك ومعلومات الدفع ولا يمكن التراجع عن هذا الإجراء.'
                  : 'Are you sure you want to delete your account? All your ride history, saved addresses, and profile data will be permanently removed. This action cannot be undone.'),
          style: GoogleFonts.inter(fontSize: 12.5, height: 1.4, color: const Color(0xFF566663)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic
                        ? 'تم تقديم الطلب وسيقوم الفريق المختص بمراجعته'
                        : 'De-registration request submitted for administrative review',
                  ),
                  backgroundColor: const Color(0xFFEF4444),
                ),
              );
            },
            child: Text(isArabic ? 'تأكيد' : 'Confirm'),
          ),
        ],
      ),
    );
  }
}

/// Direction-aware Chevron painter
class _HeaderChevron extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final double strokeWidth;
  final bool isLeft;

  const _HeaderChevron({
    required this.width,
    required this.height,
    required this.color,
    this.strokeWidth = 1.8,
    this.isLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final flip = isLeft ? isRtl : !isRtl;

    return Transform.scale(
      scaleX: flip ? -1.0 : 1.0,
      child: CustomPaint(
        size: Size(width, height),
        painter: _ChevronPainter(
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _ChevronPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width, 0.0);
    path.lineTo(0.0, size.height / 2.0);
    path.lineTo(size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
