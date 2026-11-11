import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../services/backend_service.dart';
import '../../../home/presentation/home_screen.dart';
import '../../../provider/auth/presentation/widgets/provider_animated_language_toggle.dart';
import '../../../provider/auth/presentation/widgets/provider_card_handle_bar.dart';
import '../../../provider/auth/presentation/widgets/provider_change_phone_button.dart';
import '../../../provider/auth/presentation/widgets/provider_header_back_button.dart';
import '../../../provider/auth/presentation/widgets/provider_otp_heading.dart';
import '../../../provider/auth/presentation/widgets/provider_otp_input_row.dart';
import '../../../provider/auth/presentation/widgets/provider_otp_timer_row.dart';
import '../../../provider/auth/presentation/widgets/provider_verify_code_button.dart';
import '../../../provider/splash/presentation/widgets/provider_branding_header.dart';
import '../../../provider/theme/provider_colors.dart';
import '../data/customer_auth_store.dart';

/// Customer OTP Verification Screen
/// Same layout, styling, and behavior as provider side OTP verification:
/// - Top bar with Back Button + Animated Language Toggle
/// - Subtle ambient branding header
/// - Bottom white card docked above keyboard
/// - 6-digit OTP input boxes with auto-focus and auto-advance
/// - Resend timer row with backend requestOtp hook
/// - Verify Code button & Change Phone Number button
/// - On verification: persists customer profile to CustomerAuthStore and redirects to HomeScreen.
class CustomerOtpVerificationScreen extends ConsumerStatefulWidget {
  final String fullName;
  final String phoneNumber;
  final String fullPhone;
  final String countryCode;
  final String? dummyOtp;

  const CustomerOtpVerificationScreen({
    super.key,
    this.fullName = '',
    this.phoneNumber = '',
    this.fullPhone = '',
    this.countryCode = '+966',
    this.dummyOtp,
  });

  static const double designWidth = 390.0;
  static const double designHeight = 844.0;

  @override
  ConsumerState<CustomerOtpVerificationScreen> createState() =>
      _CustomerOtpVerificationScreenState();
}

class _CustomerOtpVerificationScreenState
    extends ConsumerState<CustomerOtpVerificationScreen> {
  late String _currentOtp;
  bool _isVerifying = false;
  late final BackendService _backendService;

  @override
  void initState() {
    super.initState();
    _currentOtp = widget.dummyOtp ?? '123456';
    _backendService = BackendService(ApiClient());
  }

  Future<void> _handleVerify() async {
    if (_isVerifying) return;
    setState(() => _isVerifying = true);

    final phone = widget.fullPhone.isNotEmpty ? widget.fullPhone : '+966501234567';
    final otp = _currentOtp.isNotEmpty ? _currentOtp : (widget.dummyOtp ?? '123456');

    try {
      final result = await _backendService.verifyOtp(phone: phone, otp: otp);

      if (!mounted) return;
      setState(() => _isVerifying = false);

      // In production or test sandbox mode, valid code completes customer signup
      if (result.success || otp == (widget.dummyOtp ?? '123456') || otp == '123456') {
        final savedName = widget.fullName.isNotEmpty
            ? widget.fullName
            : (CustomerAuthStore.instance.fullName.isNotEmpty
                ? CustomerAuthStore.instance.fullName
                : 'Customer');

        await CustomerAuthStore.instance.signUp(
          fullName: savedName,
          phone: phone,
          countryCode: widget.countryCode.isNotEmpty ? widget.countryCode : '+966',
        );

        if (!mounted) return;
        HapticFeedback.mediumImpact();

        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => const HomeScreen(),
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
      } else {
        final isArabic = context.isArabic;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            backgroundColor: Colors.redAccent,
            content: Text(
              result.errorMessage ?? (isArabic ? 'رمز التحقق غير صحيح' : 'Invalid OTP code'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isVerifying = false);
        // Fallback for offline sandbox testing
        if (otp == '123456' || otp == widget.dummyOtp) {
          final savedName = widget.fullName.isNotEmpty
              ? widget.fullName
              : (CustomerAuthStore.instance.fullName.isNotEmpty
                  ? CustomerAuthStore.instance.fullName
                  : 'Customer');

          await CustomerAuthStore.instance.signUp(
            fullName: savedName,
            phone: phone,
            countryCode: widget.countryCode.isNotEmpty ? widget.countryCode : '+966',
          );
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      }
    }
  }

  Future<void> _handleResend() async {
    final phone = widget.fullPhone.isNotEmpty ? widget.fullPhone : '+966501234567';
    final result = await _backendService.requestOtp(phone: phone);

    if (!mounted) return;
    setState(() {
      _currentOtp = result.otp;
    });

    final isArabic = context.isArabic;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1C2926),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        content: Row(
          children: [
            const Icon(Icons.mark_email_read_outlined, color: ProviderColors.brandPurple, size: 20.0),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                isArabic
                    ? 'رمز التحقق الجديد (تجريبي): ${result.otp}'
                    : 'New Verification Code (Dummy): ${result.otp}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appLocaleProvider);
    final isArabic = context.isArabic;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isDesktopWeb = constraints.maxWidth > 500;
              final double containerWidth = isDesktopWeb
                  ? CustomerOtpVerificationScreen.designWidth
                  : constraints.maxWidth;
              final double containerHeight = isDesktopWeb
                  ? CustomerOtpVerificationScreen.designHeight
                  : constraints.maxHeight;

              final double topSafeArea = MediaQuery.of(context).padding.top;
              final double keyboardInset = MediaQuery.of(context).viewInsets.bottom;
              final bool isKeyboardOpen = keyboardInset > 0;

              final double toggleTop = topSafeArea > 0 ? (topSafeArea + 16.0) : 48.0;
              final double headerTop = isDesktopWeb
                  ? 120.0
                  : (toggleTop + 36.0 + 16.0).clamp(90.0, 140.0);

              final double effectiveBottomInset = isDesktopWeb ? 0.0 : keyboardInset;
              final double availableHeightAboveKeyboard = containerHeight - effectiveBottomInset;

              // Flexible docked card height: stays anchored above keyboard without hiding buttons
              final double cardHeight = isDesktopWeb
                  ? 440.0
                  : (isKeyboardOpen
                      ? (availableHeightAboveKeyboard - (topSafeArea + 24.0)).clamp(390.0, 520.0)
                      : (containerHeight * 0.58).clamp(430.0, 500.0));

              final String displayTargetPhone = widget.phoneNumber.isNotEmpty
                  ? widget.phoneNumber
                  : (widget.fullPhone.isNotEmpty ? widget.fullPhone : '+966 50 123 4567');

              final String subtitle = isArabic
                  ? 'لقد أرسلنا رمزاً مكوناً من 6 أرقام إلى $displayTargetPhone'
                  : 'We’ve sent a 6-digit code to $displayTargetPhone';

              final Widget screenContent = Container(
                width: containerWidth,
                height: containerHeight,
                color: Colors.white,
                child: Stack(
                  children: [
                    // 1. Underneath Scene: Background glow and branding header
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(color: Colors.white),
                            ),

                            // Top subtle lavender ambient glow
                            Positioned(
                              top: 0.0,
                              left: 0.0,
                              right: 0.0,
                              height: 280.0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFF3E8FF),
                                      Color(0x00F3E8FF),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Header Branding in background: ZESHO / Service always near you
                            Positioned(
                              top: headerTop,
                              left: 0,
                              right: 0,
                              child: const Center(
                                child: ProviderBrandingHeader(),
                              ),
                            ),

                            // Frosted glass soft overlay
                            Positioned.fill(
                              child: ClipRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 1.5,
                                    sigmaY: 1.5,
                                  ),
                                  child: Container(
                                    color: const Color(0x0DFFFFFF),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 2. White Bottom Card Layout (Docked above keyboard)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: effectiveBottomInset,
                      height: cardHeight,
                      child: Container(
                        width: containerWidth,
                        height: cardHeight,
                        decoration: const BoxDecoration(
                          color: ProviderColors.cardBackground,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28.0),
                            topRight: Radius.circular(28.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ProviderColors.cardShadow,
                              offset: Offset(0, -2),
                              blurRadius: 12.0,
                              spreadRadius: 0.0,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(28.0),
                            topRight: Radius.circular(28.0),
                          ),
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Positioned.fill(
                                child: SingleChildScrollView(
                                  physics: const ClampingScrollPhysics(),
                                  padding: EdgeInsets.only(
                                    top: isKeyboardOpen ? 12.0 : 16.0,
                                    left: 20.0,
                                    right: 20.0,
                                    bottom: isKeyboardOpen
                                        ? 12.0
                                        : (MediaQuery.of(context).padding.bottom > 0
                                            ? MediaQuery.of(context).padding.bottom + 16.0
                                            : 20.0),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Top Grab Handle Bar
                                      const ProviderCardHandleBar(),
                                      const SizedBox(height: 14.0),

                                      // Heading
                                      ProviderOtpHeading(
                                        title: isArabic ? 'خطوة واحدة بعد' : 'One more step ahead.',
                                        subtitle: subtitle,
                                      ),
                                      const SizedBox(height: 16.0),

                                      // 6-Cards OTP Input Row
                                      Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: ProviderOtpInputRow(
                                          initialValue: widget.dummyOtp ?? '123456',
                                          onChanged: (code) {
                                            _currentOtp = code;
                                          },
                                          onCompleted: (code) {
                                            _currentOtp = code;
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 14.0),

                                      // Resend Code Countdown Timer Row
                                      ProviderOtpTimerRow(
                                        onResend: _handleResend,
                                      ),
                                      const SizedBox(height: 16.0),

                                      // Verify Code Button (Purple Branded)
                                      ProviderVerifyCodeButton(
                                        isLoading: _isVerifying,
                                        onVerify: _handleVerify,
                                      ),
                                      const SizedBox(height: 12.0),

                                      // Change Phone Number Button (Black Branded)
                                      ProviderChangePhoneButton(
                                        onTap: () => Navigator.of(context).maybePop(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 3. Top Navigation Bar: Back Button + Animated Language Toggle (Topmost interactive layer)
                    Positioned(
                      top: toggleTop,
                      left: 20.0,
                      right: 20.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ProviderHeaderBackButton(
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                          const ProviderAnimatedLanguageToggle.compact(),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              if (isDesktopWeb) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color(0xFFF3F4F6),
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Container(
                      width: CustomerOtpVerificationScreen.designWidth,
                      height: CustomerOtpVerificationScreen.designHeight,
                      margin: const EdgeInsets.symmetric(vertical: 24.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(44),
                        border: Border.all(
                          color: const Color(0xFF8B53FE).withValues(alpha: 0.35),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 36,
                            spreadRadius: 6,
                          ),
                          BoxShadow(
                            color: const Color(0xFF8B53FE).withValues(alpha: 0.12),
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

              return screenContent;
            },
          ),
        ),
      ),
    );
  }
}
