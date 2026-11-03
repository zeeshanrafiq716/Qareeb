import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/localization/app_locale.dart';

/// Privacy & Security Screen (Safety & Security) navigated from Profile.
/// Specifications:
/// - Screen Layout: width: 390; height: 878; angle: 0 deg; opacity: 1; background: #FFFFFF;
/// - Header Branding: Circular back button + Title & Subtitle matching app branding
class PrivacySecurityScreen extends ConsumerStatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  ConsumerState<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends ConsumerState<PrivacySecurityScreen> {
  // Settings state
  bool _biometricLogin = true;
  bool _twoFactorAuth = true;
  bool _shareTripStatus = false;
  bool _analyticsSharing = false;

  final List<String> _blockedProviders = [
    'Tariq Recovery Service',
    'Falcon Towing Co.',
  ];

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
                          _buildSafetyHeader(context, tr, isArabic),
                          const SizedBox(height: 22.0),

                          // Section 1: Safety & Blocked Controls
                          _buildSectionLabel(
                            isArabic ? 'إعدادات الأمان والمزودين' : 'Safety & Provider Controls',
                            isArabic,
                          ),
                          const SizedBox(height: 10.0),
                          _buildCardGroup([
                            _buildActionTile(
                              icon: Icons.block_rounded,
                              title: isArabic ? 'المزودون المحظورون' : 'Blocked Providers',
                              subtitle: isArabic
                                  ? 'إدارة مقدمي الخدمة المحظورين (${_blockedProviders.length})'
                                  : 'Manage blocked providers (${_blockedProviders.length})',
                              trailing: _buildBadge('${_blockedProviders.length}'),
                              onTap: () => _showBlockedProvidersSheet(context, isArabic),
                              isArabic: isArabic,
                            ),
                            _buildDivider(),
                            _buildActionTile(
                              icon: Icons.emergency_rounded,
                              title: isArabic ? 'المساعدة في الطوارئ (SOS)' : 'Emergency Assistance (SOS)',
                              subtitle: isArabic
                                  ? 'اتصال فوري ومشاركة الموقع مع جهات الطوارئ'
                                  : 'Quick emergency call & live trip location sharing',
                              onTap: () => _showEmergencyDialog(context, isArabic),
                              isArabic: isArabic,
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              icon: Icons.share_location_rounded,
                              title: isArabic ? 'مشاركة مسار الرحلة' : 'Share Trip Status',
                              subtitle: isArabic
                                  ? 'مشاركة حالة ومسار رحلتك تلقائياً مع جهات موثوقة'
                                  : 'Automatically share live route with trusted contacts',
                              value: _shareTripStatus,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                setState(() => _shareTripStatus = val);
                              },
                              isArabic: isArabic,
                            ),
                          ]),

                          const SizedBox(height: 20.0),

                          // Section 2: Account Security & Authentication
                          _buildSectionLabel(
                            isArabic ? 'تسجيل الدخول والمصادقة' : 'Login & Authentication',
                            isArabic,
                          ),
                          const SizedBox(height: 10.0),
                          _buildCardGroup([
                            _buildSwitchTile(
                              icon: Icons.fingerprint_rounded,
                              title: isArabic ? 'تسجيل الدخول بالبصمة' : 'Biometric Login',
                              subtitle: isArabic
                                  ? 'استخدام بصمة الوجه أو الأصبع لتأمين الحساب'
                                  : 'Use Face ID or fingerprint to quickly unlock',
                              value: _biometricLogin,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                setState(() => _biometricLogin = val);
                              },
                              isArabic: isArabic,
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              icon: Icons.security_rounded,
                              title: isArabic ? 'التحقق بخطوتين (2FA)' : 'Two-Factor Authentication',
                              subtitle: isArabic
                                  ? 'طبقة حماية إضافية عبر رمز التحقق OTP'
                                  : 'Additional protection layer via SMS OTP verification',
                              value: _twoFactorAuth,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                setState(() => _twoFactorAuth = val);
                              },
                              isArabic: isArabic,
                            ),
                            _buildDivider(),
                            _buildActionTile(
                              icon: Icons.lock_outline_rounded,
                              title: isArabic ? 'تغيير كلمة المرور' : 'Change Password',
                              subtitle: isArabic
                                  ? 'تحديث بيانات تسجيل الدخول وكلمة السر'
                                  : 'Update your account login password',
                              onTap: () => _showChangePasswordDialog(context, isArabic),
                              isArabic: isArabic,
                            ),
                          ]),

                          const SizedBox(height: 20.0),

                          // Section 3: Privacy & Permissions
                          _buildSectionLabel(
                            isArabic ? 'الخصوصية والبيانات' : 'Privacy & Permissions',
                            isArabic,
                          ),
                          const SizedBox(height: 10.0),
                          _buildCardGroup([
                            _buildActionTile(
                              icon: Icons.location_on_rounded,
                              title: isArabic ? 'إذن الوصول إلى الموقع' : 'Location Access',
                              subtitle: isArabic
                                  ? 'الموقع الدقيق أثناء استخدام التطبيق'
                                  : 'Precise location while using the app',
                              trailing: _buildStatusPill(
                                isArabic ? 'نشط' : 'Always Active',
                                const Color(0xFF10B981),
                                const Color(0xFFECFDF5),
                              ),
                              onTap: () {},
                              isArabic: isArabic,
                            ),
                            _buildDivider(),
                            _buildSwitchTile(
                              icon: Icons.analytics_outlined,
                              title: isArabic ? 'مشاركة بيانات التحسين' : 'Analytics & Diagnostics',
                              subtitle: isArabic
                                  ? 'مساعدتنا في تحسين الأداء وتجربة الاستخدام'
                                  : 'Help us improve service reliability and app quality',
                              value: _analyticsSharing,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                setState(() => _analyticsSharing = val);
                              },
                              isArabic: isArabic,
                            ),
                            _buildDivider(),
                            _buildActionTile(
                              icon: Icons.policy_rounded,
                              title: isArabic ? 'سياسة الخصوصية' : 'Privacy Policy',
                              subtitle: isArabic
                                  ? 'اطلع على كيفية معالجة وحماية بياناتك'
                                  : 'Read how your personal information is protected',
                              onTap: () => _showPrivacyPolicyDialog(context, isArabic),
                              isArabic: isArabic,
                            ),
                          ]),

                          const SizedBox(height: 20.0),

                          // Section 4: Account Danger Zone
                          _buildSectionLabel(
                            isArabic ? 'إدارة الحساب' : 'Account Management',
                            isArabic,
                          ),
                          const SizedBox(height: 10.0),
                          _buildDeleteAccountCard(context, isArabic),

                          const SizedBox(height: 48.0),
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

  /// Header widget matching previous screens branding and uploaded screenshot:
  /// - Circular white back button with subtle shadow
  /// - Safety & Security title
  /// - Explanatory subtitle
  Widget _buildSafetyHeader(BuildContext context, AppTranslations tr, bool isArabic) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Ellipse branding back button
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
                    color: Color(0x14000000), // 0px 1px 8px 0px #00000014
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

        // Header Title & Subtitle matching the Figma screenshot branding
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isArabic ? 'الأمان والخصوصية' : 'Safety & Security',
                style: isArabic
                    ? GoogleFonts.cairo(
                        fontSize: 19.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C2926),
                        height: 1.2,
                      )
                    : GoogleFonts.inter(
                        fontSize: 19.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C2926),
                        height: 1.2,
                      ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2.0),
              Text(
                isArabic
                    ? 'لن تتلقى طلبات خدمة أو اتصالات مستقبلية من هذا المزود.'
                    : 'You won’t receive future service requests or contact from this provider.',
                style: isArabic
                    ? GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF616166),
                        height: 1.3,
                      )
                    : GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF616166),
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

  /// Section Label Header
  Widget _buildSectionLabel(String text, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        text,
        style: isArabic
            ? GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF616166),
              )
            : GoogleFonts.inter(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF616166),
                letterSpacing: 0.2,
              ),
      ),
    );
  }

  /// Card Group Container
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

  /// Action Tile with Chevron or Custom Trailing
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
                              fontSize: 11.0,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF616166),
                            )
                          : GoogleFonts.inter(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF616166),
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

  /// Switch Tile with Cupertino toggle
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
                          fontSize: 11.0,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF616166),
                        )
                      : GoogleFonts.inter(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF616166),
                        ),
                  maxLines: 1,
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

  /// Badge indicator
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

  /// Status Pill
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

  /// Destructive Delete Account Card
  Widget _buildDeleteAccountCard(BuildContext context, bool isArabic) {
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
          onTap: () => _showDeleteAccountConfirmation(context, isArabic),
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
                        isArabic ? 'حذف الحساب' : 'Delete Account',
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
                        isArabic
                            ? 'حذف بياناتك وسجل رحلاتك نهائياً'
                            : 'Permanently remove your account and data',
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

  // --- Modal Bottom Sheets & Dialogs ---

  void _showBlockedProvidersSheet(BuildContext context, bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
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
                    isArabic ? 'المزودون المحظورون' : 'Blocked Providers',
                    style: GoogleFonts.inter(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1C2926),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    isArabic
                        ? 'لن يتمكن هؤلاء المزودون من تلقي طلباتك أو التواصل معك.'
                        : 'These providers cannot receive your service requests or contact you.',
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      color: const Color(0xFF616166),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  if (_blockedProviders.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Text(
                          isArabic ? 'لا يوجد مزودون محظورون' : 'No blocked providers yet',
                          style: GoogleFonts.inter(
                            fontSize: 14.0,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    )
                  else
                    ..._blockedProviders.map((name) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
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
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1C2926),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                setModalState(() {
                                  _blockedProviders.remove(name);
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
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEmergencyDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Row(
          children: [
            const Icon(Icons.emergency_rounded, color: Color(0xFFEF4444)),
            const SizedBox(width: 10.0),
            Text(
              isArabic ? 'المساعدة في الطوارئ' : 'Emergency SOS',
              style: GoogleFonts.inter(fontSize: 17.0, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          isArabic
              ? 'في حال حدوث أي طارئ أثناء الرحلة، يمكنك الاتصال فوراً بخدمات الطوارئ 911 أو مشاركة موقعك المباشر مع مركز مساعدة قريب.'
              : 'In case of any emergency during your trip, you can quickly contact emergency services (911) or share your live location with Qareeb Support.',
          style: GoogleFonts.inter(fontSize: 13.0, height: 1.4, color: const Color(0xFF566663)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              isArabic ? 'إغلاق' : 'Close',
              style: GoogleFonts.inter(color: const Color(0xFF616166)),
            ),
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
                  content: Text(isArabic ? 'تم تفعيل الاتصال بالطوارئ' : 'Emergency contacts notified'),
                  backgroundColor: const Color(0xFFEF4444),
                ),
              );
            },
            child: Text(isArabic ? 'اتصال بالطوارئ 911' : 'Call 911'),
          ),
        ],
      ),
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

  void _showPrivacyPolicyDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text(
          isArabic ? 'سياسة الخصوصية' : 'Privacy Policy',
          style: GoogleFonts.inter(fontSize: 17.0, fontWeight: FontWeight.w600),
        ),
        content: Text(
          isArabic
              ? 'يلتزم تطبيق قريب بحماية خصوصية وأمان بياناتك. لا يتم مشاركة موقعك أو أرقام الاتصال الخاصة بك إلا مع مزود الخدمة المخصص لطلبك لضمان تقديم الخدمة بأمان وكفاءة.'
              : 'Qareeb is committed to safeguarding your privacy. Your exact location and contact details are only shared with the assigned provider for the duration of the active service to ensure high safety standards.',
          style: GoogleFonts.inter(fontSize: 13.0, height: 1.45, color: const Color(0xFF566663)),
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

  void _showDeleteAccountConfirmation(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
            const SizedBox(width: 8.0),
            Text(
              isArabic ? 'حذف الحساب نهائياً' : 'Delete Account Permanently',
              style: GoogleFonts.inter(fontSize: 16.0, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          isArabic
              ? 'هل أنت متأكد من رغبتك في حذف الحساب؟ سيتم حذف جميع بياناتك وسجل رحلاتك ومعلومات الدفع ولا يمكن التراجع عن هذا الإجراء.'
              : 'Are you sure you want to delete your account? All your ride history, saved addresses, and profile data will be permanently removed. This action cannot be undone.',
          style: GoogleFonts.inter(fontSize: 13.0, height: 1.4, color: const Color(0xFF566663)),
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
                  content: Text(isArabic ? 'تم تقديم طلب حذف الحساب' : 'Account deletion requested'),
                  backgroundColor: const Color(0xFFEF4444),
                ),
              );
            },
            child: Text(isArabic ? 'نعم، حذف' : 'Yes, Delete'),
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

