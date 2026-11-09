import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/profile/presentation/provider_help_support_screen.dart';
import 'package:mobile/features/provider/auth/data/provider_registration_state.dart';
import 'package:mobile/features/provider/auth/presentation/phone_verification_screen.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_animated_language_toggle.dart';
import 'package:mobile/features/provider/home/presentation/provider_home_screen.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';
import 'package:mobile/services/backend_service.dart';

/// Provider Blocked Screen
/// Displayed when a provider is blocked by platform administration.
/// Automatically polls for status changes (unblock / reinstate / delete)
/// and updates the UI in real-time.
class ProviderBlockedScreen extends StatefulWidget {
  final String? reason;

  const ProviderBlockedScreen({
    super.key,
    this.reason,
  });

  static const double designWidth = 390.0;
  static const double designHeight = 844.0;

  @override
  State<ProviderBlockedScreen> createState() => _ProviderBlockedScreenState();
}

class _ProviderBlockedScreenState extends State<ProviderBlockedScreen> {
  Timer? _statusCheckTimer;
  late final BackendService _backendService;
  String _reason = '';

  @override
  void initState() {
    super.initState();
    _reason = widget.reason ?? '';
    _backendService = BackendService(ApiClient());

    // Live poller every 2.5s to react if admin unblocks or deletes
    _statusCheckTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      _checkAccountStatus();
    });
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkAccountStatus() async {
    try {
      final state = await _backendService.checkProviderAccountState();
      if (!mounted) return;

      if (state.status == ProviderAccountStatus.approved) {
        _statusCheckTimer?.cancel();
        ProviderRegistrationStore.instance.update(
          (d) => d.copyWith(status: 'APPROVED'),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ProviderHomeScreen()),
          (route) => false,
        );
      } else if (state.status == ProviderAccountStatus.deleted) {
        _statusCheckTimer?.cancel();
        await ProviderRegistrationStore.instance.clear();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.isArabic
                  ? 'تم حذف حساب مزود الخدمة الخاص بك من قبل الإدارة'
                  : 'Your provider account has been deleted by administration.',
            ),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PhoneVerificationScreen()),
          (route) => false,
        );
      } else if (state.statusReason.isNotEmpty && state.statusReason != _reason) {
        setState(() {
          _reason = state.statusReason;
        });
      }
    } catch (_) {}
  }

  Future<void> _handleSignOut() async {
    HapticFeedback.lightImpact();
    _statusCheckTimer?.cancel();
    await ProviderRegistrationStore.instance.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PhoneVerificationScreen()),
      (route) => false,
    );
  }

  void _handleContactSupport() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProviderHelpSupportScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

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
                ? ProviderBlockedScreen.designWidth
                : (constraints.maxWidth > ProviderBlockedScreen.designWidth
                    ? ProviderBlockedScreen.designWidth
                    : constraints.maxWidth);
            final double containerHeight =
                isDesktopWeb ? ProviderBlockedScreen.designHeight : constraints.maxHeight;

            final double topSafeArea = MediaQuery.of(context).padding.top;
            final double headerTop = topSafeArea > 0 ? (topSafeArea + 12.0) : 56.0;

            final Widget content = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                children: [
                  // Top Header
                  Positioned(
                    top: headerTop,
                    left: 20.0,
                    right: 20.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'QAREEB',
                          style: TextStyle(
                            fontFamily: isArabic ? 'Cairo' : 'Inter',
                            fontSize: 20.0,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF8B53FE),
                            letterSpacing: isArabic ? 0.0 : 1.5,
                          ),
                        ),
                        const ProviderAnimatedLanguageToggle(),
                      ],
                    ),
                  ),

                  // Center Blocked Body
                  Positioned.fill(
                    top: headerTop + 56.0,
                    bottom: 24.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(flex: 2),

                          // Blocked Shield Icon Badge
                          Center(
                            child: Container(
                              width: 104.0,
                              height: 104.0,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFFCA5A5),
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                                    blurRadius: 24.0,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.block_rounded,
                                  size: 48.0,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28.0),

                          // Heading
                          Text(
                            context.tr.accountBlockedTitle,
                            textAlign: TextAlign.center,
                            style: ProviderTextStyles.cardHeadingTitle.copyWith(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1C2926),
                            ),
                          ),

                          const SizedBox(height: 12.0),

                          // Subtitle description
                          Text(
                            context.tr.accountBlockedDesc,
                            textAlign: TextAlign.center,
                            style: ProviderTextStyles.cardHeadingSubtitle.copyWith(
                              fontSize: 13.0,
                              height: 1.5,
                              color: const Color(0xFF566663),
                            ),
                          ),

                          // Reason Box (if available)
                          if (_reason.trim().isNotEmpty) ...[
                            const SizedBox(height: 20.0),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: const Color(0xFFFCA5A5),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 2.0),
                                    child: Icon(
                                      Icons.info_outline_rounded,
                                      size: 16.0,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(
                                      '${isArabic ? "السبب:" : "Reason:"} $_reason',
                                      style: ProviderTextStyles.cardHeadingSubtitle.copyWith(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF991B1B),
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const Spacer(flex: 3),

                          // Primary Button: Contact Support
                          SizedBox(
                            width: double.infinity,
                            height: 52.0,
                            child: ElevatedButton(
                              onPressed: _handleContactSupport,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B53FE),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.headset_mic_rounded, size: 20.0),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    isArabic ? 'تواصل مع الدعم الفني' : 'Contact Support',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12.0),

                          // Secondary Button: Sign Out / Return to Sign In
                          SizedBox(
                            width: double.infinity,
                            height: 50.0,
                            child: OutlinedButton(
                              onPressed: _handleSignOut,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF566663),
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: Text(
                                isArabic ? 'تسجيل الخروج' : 'Sign Out',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16.0),
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
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    width: ProviderBlockedScreen.designWidth,
                    height: ProviderBlockedScreen.designHeight,
                    margin: const EdgeInsets.symmetric(vertical: 24.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: ProviderColors.mintGlow.withValues(alpha: 0.25),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.60),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(38),
                      child: content,
                    ),
                  ),
                ),
              );
            }

            return content;
          },
        ),
      ),
    );
  }
}
