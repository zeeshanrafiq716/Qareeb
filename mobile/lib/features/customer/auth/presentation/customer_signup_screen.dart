import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../models/country_model.dart';
import '../../../../services/backend_service.dart';
import '../../../home/presentation/home_screen.dart';
import '../../../provider/auth/data/provider_registration_state.dart';
import '../../../provider/auth/presentation/phone_verification_screen.dart';
import '../../../provider/auth/presentation/widgets/provider_animated_button.dart';
import '../../../provider/auth/presentation/widgets/provider_animated_language_toggle.dart';
import '../../../provider/auth/presentation/widgets/provider_country_picker_modal.dart';
import '../data/customer_auth_store.dart';
import 'customer_otp_verification_screen.dart';

/// Customer Signup Screen (Name and Phone Number only)
/// After completing signup, customer will never face these steps again.
class CustomerSignupScreen extends ConsumerStatefulWidget {
  final bool initialIsLogin;

  const CustomerSignupScreen({
    super.key,
    this.initialIsLogin = false,
  });

  @override
  ConsumerState<CustomerSignupScreen> createState() => _CustomerSignupScreenState();
}

class _CustomerSignupScreenState extends ConsumerState<CustomerSignupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  late final AnimationController _iconAnimCtrl;
  late final Animation<double> _iconScaleAnim;
  late final Animation<double> _iconFloatAnim;

  CountryModel _selectedCountry = CountryModel.defaultCountry;
  bool _isLoading = false;
  late bool _isLoginMode;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isLoginMode = widget.initialIsLogin;
    // Continuous subtle floating & scale animation for brand icon
    _iconAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _iconScaleAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _iconAnimCtrl, curve: Curves.easeInOutSine),
    );

    _iconFloatAnim = Tween<double>(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(parent: _iconAnimCtrl, curve: Curves.easeInOutSine),
    );

    // Fresh empty form fields on entry
    _nameController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _errorMessage = null;
  }

  void _switchMode(bool login) {
    if (_isLoginMode == login) return;
    setState(() {
      _isLoginMode = login;
      _nameController.clear();
      _phoneController.clear();
      _passwordController.clear();
      _errorMessage = null;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _iconAnimCtrl.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleCountryPicker() async {
    HapticFeedback.selectionClick();
    final picked = await ProviderCountryPickerModal.show(
      context,
      selectedCountry: _selectedCountry,
    );
    if (picked != null && mounted) {
      setState(() => _selectedCountry = picked);
    }
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');
    final password = _passwordController.text.trim();
    final isArabic = context.isArabic;

    if (phone.isEmpty) {
      setState(() {
        _errorMessage = isArabic ? 'يرجى إدخال رقم الهاتف' : 'Please enter your phone number';
      });
      _phoneFocusNode.requestFocus();
      return;
    }

    String digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.startsWith('0')) {
      digitsOnly = digitsOnly.replaceFirst(RegExp(r'^0+'), '');
    }

    if (digitsOnly.length < 7) {
      setState(() {
        _errorMessage = isArabic ? 'يرجى إدخال رقم هاتف صحيح' : 'Please enter a valid phone number';
      });
      _phoneFocusNode.requestFocus();
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _errorMessage = isArabic ? 'يرجى إدخال كلمة المرور' : 'Please enter your password';
      });
      _passwordFocusNode.requestFocus();
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final fullPhoneNumber = '${_selectedCountry.dialCode}$digitsOnly';
      final backendService = BackendService(ApiClient());
      final result = await backendService.loginWithPassword(
        phone: fullPhoneNumber,
        password: password,
        userType: 'customer',
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.success) {
        HapticFeedback.mediumImpact();
        final customerName = result.provider?['name']?.toString() ??
            (CustomerAuthStore.instance.fullName.isNotEmpty
                ? CustomerAuthStore.instance.fullName
                : 'Customer');

        await CustomerAuthStore.instance.signIn(
          fullName: customerName,
          phone: fullPhoneNumber,
          countryCode: _selectedCountry.dialCode,
          token: result.token,
        );

        if (!mounted) return;
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
        HapticFeedback.heavyImpact();
        setState(() {
          _errorMessage = result.errorMessage ??
              (isArabic ? 'رقم الهاتف أو كلمة المرور غير صحيحة' : 'Invalid phone number or password');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = isArabic ? 'حدث خطأ أثناء تسجيل الدخول' : 'An error occurred during login';
        });
      }
    }
  }

  Future<void> _handleSignup() async {
    FocusScope.of(context).unfocus();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');
    final password = _passwordController.text.trim();
    final isArabic = context.isArabic;

    if (name.isEmpty) {
      setState(() {
        _errorMessage = isArabic
            ? 'يرجى إدخال الاسم الكامل'
            : 'Please enter your full name';
      });
      _nameFocusNode.requestFocus();
      return;
    }

    if (name.length < 2) {
      setState(() {
        _errorMessage = isArabic
            ? 'يرجى إدخال اسم صحيح لا يقل عن حرفين'
            : 'Please enter a valid name (at least 2 characters)';
      });
      _nameFocusNode.requestFocus();
      return;
    }

    if (phone.isEmpty) {
      setState(() {
        _errorMessage = isArabic
            ? 'يرجى إدخال رقم الهاتف'
            : 'Please enter your phone number';
      });
      _phoneFocusNode.requestFocus();
      return;
    }

    String digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.startsWith('0')) {
      digitsOnly = digitsOnly.replaceFirst(RegExp(r'^0+'), '');
    }
    if (digitsOnly.length < 7) {
      setState(() {
        _errorMessage = isArabic
            ? 'يرجى إدخال رقم هاتف صحيح'
            : 'Please enter a valid phone number';
      });
      _phoneFocusNode.requestFocus();
      return;
    }

    if (password.isNotEmpty && password.length < 6) {
      setState(() {
        _errorMessage = isArabic
            ? 'كلمة المرور يجب أن لا تقل عن 6 خانات'
            : 'Password must be at least 6 characters';
      });
      _passwordFocusNode.requestFocus();
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final fullPhoneNumber = '${_selectedCountry.dialCode}$digitsOnly';
      final displayPhoneNumber = '${_selectedCountry.dialCode} $digitsOnly';

      // Check local store first to prevent duplicate signups with existing credentials
      if (CustomerAuthStore.instance.phone == fullPhoneNumber &&
          CustomerAuthStore.instance.hasCompletedSignup) {
        setState(() {
          _isLoading = false;
          _isLoginMode = true;
          _errorMessage = isArabic
              ? 'يوجد حساب مسجل بهذا الرقم بالفعل. يرجى تسجيل الدخول'
              : 'An account with this phone number already exists. Please log in.';
        });
        HapticFeedback.heavyImpact();
        return;
      }

      // Request OTP via backend service with Twilio SMS integration
      final backendService = BackendService(ApiClient());
      final result = await backendService.requestOtp(
        phone: fullPhoneNumber,
        channel: 'sms',
        userType: 'customer',
        purpose: 'signup',
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.alreadyExists) {
        HapticFeedback.heavyImpact();
        setState(() {
          _isLoginMode = true;
          _errorMessage = isArabic
              ? 'يوجد حساب مسجل بهذا الرقم بالفعل. يرجى تسجيل الدخول'
              : 'An account with this phone number already exists. Please log in.';
        });
        return;
      }

      HapticFeedback.selectionClick();

      // Show realistic SMS toast notification when sent via Twilio, or dev OTP toast in test mode
      if (result.smsDelivered) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1C2926),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            content: Row(
              children: [
                const Icon(Icons.sms_outlined, color: Color(0xFF8B53FE), size: 20.0),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    isArabic
                        ? 'تم إرسال رمز التحقق إلى $displayPhoneNumber عبر رسالة SMS'
                        : 'Verification code sent to $displayPhoneNumber via SMS',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1C2926),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            content: Row(
              children: [
                const Icon(Icons.mark_email_read_outlined, color: Color(0xFF8B53FE), size: 20.0),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    isArabic
                        ? 'رمز التحقق (تجريبي): ${result.otp}'
                        : 'Verification Code (Dev): ${result.otp}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }

      // Navigate to Customer OTP Verification Screen (matches provider side OTP flow)
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => CustomerOtpVerificationScreen(
            fullName: name,
            phoneNumber: displayPhoneNumber,
            fullPhone: fullPhoneNumber,
            countryCode: _selectedCountry.dialCode,
            dummyOtp: result.otp,
            password: password.isNotEmpty ? password : null,
          ),
          transitionsBuilder: (_, animation, _, child) => FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = isArabic
              ? 'حدث خطأ أثناء إرسال رمز التحقق، يرجى المحاولة مرة أخرى'
              : 'Error sending verification code, please try again';
        });
      }
    }
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
                ? math.min(844.0, (screenHeight - 32.0).clamp(520.0, 844.0))
                : screenHeight;

            final double safeTop = mediaQuery.padding.top;
            final double headerTop = math.max(safeTop + 12.0, 48.0);

            final Widget content = Container(
              width: containerWidth,
              height: containerHeight,
              color: Colors.white,
              child: Stack(
                children: [
                  // 1. Subtle top lavender ambient glow
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    right: 0.0,
                    height: 240.0,
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

                  // 2. Main Form Scrollable Area (Rendered underneath floating header controls)
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: headerTop + 16.0),

                          // Brand Badge with gentle floating and scale pulse animation
                          Center(
                            child: AnimatedBuilder(
                              animation: _iconAnimCtrl,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _iconFloatAnim.value),
                                  child: Transform.scale(
                                    scale: _iconScaleAnim.value,
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                                width: 52.0,
                                height: 52.0,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0EAFE),
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                    color: const Color(0xFF8B53FE).withValues(alpha: 0.18),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF8B53FE).withValues(alpha: 0.18),
                                      offset: const Offset(0, 4),
                                      blurRadius: 12.0,
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      offset: const Offset(0, -2),
                                      blurRadius: 4.0,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person_pin_rounded,
                                    size: 30.0,
                                    color: Color(0xFF8B53FE),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12.0),

                          // Mode Switcher Pill: [ Log In | Sign Up ]
                          Container(
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F5F4),
                              borderRadius: BorderRadius.circular(22.0),
                            ),
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _switchMode(true),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _isLoginMode ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(18.0),
                                        boxShadow: _isLoginMode
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.06),
                                                  blurRadius: 4.0,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          isArabic ? 'تسجيل الدخول' : 'Log In',
                                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                            fontSize: 13.5,
                                            fontWeight: _isLoginMode ? FontWeight.w700 : FontWeight.w500,
                                            color: _isLoginMode ? const Color(0xFF1C2926) : const Color(0xFF71717A),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _switchMode(false),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: !_isLoginMode ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(18.0),
                                        boxShadow: !_isLoginMode
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.06),
                                                  blurRadius: 4.0,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          isArabic ? 'إنشاء حساب جديد' : 'Sign Up',
                                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                            fontSize: 13.5,
                                            fontWeight: !_isLoginMode ? FontWeight.w700 : FontWeight.w500,
                                            color: !_isLoginMode ? const Color(0xFF1C2926) : const Color(0xFF71717A),
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

                          // Heading
                          Text(
                            _isLoginMode
                                ? (isArabic ? 'مرحباً بك مجدداً' : 'Welcome Back')
                                : (isArabic ? 'إنشاء حساب جديد' : 'Create Your Account'),
                            textAlign: TextAlign.center,
                            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1C2926),
                              letterSpacing: -0.3,
                              height: 1.25,
                            ),
                          ),

                          const SizedBox(height: 6.0),

                          // Subtitle
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              _isLoginMode
                                  ? (isArabic
                                      ? 'أدخل رقم هاتفك وكلمة المرور للمتابعة والوصول إلى خدماتك'
                                      : 'Enter your phone number and password to log in')
                                  : (isArabic
                                      ? 'أدخل اسمك ورقم هاتفك للمتابعة والوصول السريع للخدمات'
                                      : 'Enter your name and phone number to get started with services'),
                              textAlign: TextAlign.center,
                              style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF6B7280),
                                height: 1.4,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18.0),

                          // Error banner if any
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14.0,
                                vertical: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                  color: const Color(0xFFF87171),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    size: 18.0,
                                    color: Color(0xFFDC2626),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFFB91C1C),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16.0),
                          ],

                          // 1. Full Name Field (Only in Sign Up mode)
                          if (!_isLoginMode) ...[
                            Text(
                              isArabic ? 'الاسم الكامل' : 'Full Name',
                              style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 8.0),

                            Container(
                              height: 52.0,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F5F4),
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: _nameFocusNode.hasFocus
                                      ? const Color(0xFF8B53FE)
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.person_outline_rounded,
                                    size: 20.0,
                                    color: Color(0xFF71717A),
                                  ),
                                  const SizedBox(width: 10.0),
                                  Expanded(
                                    child: TextField(
                                      controller: _nameController,
                                      focusNode: _nameFocusNode,
                                      textCapitalization: TextCapitalization.words,
                                      style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF1C2926),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: isArabic
                                            ? 'مثال: عبد الله المنصور'
                                            : 'e.g. Abdullah Al-Mansoor',
                                        hintStyle: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF9CA3AF),
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onChanged: (_) {
                                        if (_errorMessage != null) {
                                          setState(() => _errorMessage = null);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20.0),
                          ],

                          // 2. Phone Number Field
                          Text(
                            isArabic ? 'رقم الهاتف' : 'Phone Number',
                            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8.0),

                          // Phone input row: Number code on the LEFT side, number field on the RIGHT side
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Row(
                              children: [
                                // Country code picker button (Left side)
                                InkWell(
                                  onTap: _handleCountryPicker,
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Container(
                                    height: 52.0,
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F5F4),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _selectedCountry.flagEmoji,
                                          style: const TextStyle(fontSize: 18.0),
                                        ),
                                        const SizedBox(width: 6.0),
                                        Text(
                                          _selectedCountry.dialCode,
                                          style: GoogleFonts.inter(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1C2926),
                                          ),
                                        ),
                                        const SizedBox(width: 4.0),
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 18.0,
                                          color: Color(0xFF71717A),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 10.0),

                                // Phone number input (Right side)
                                Expanded(
                                  child: Container(
                                    height: 52.0,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F5F4),
                                      borderRadius: BorderRadius.circular(12.0),
                                      border: Border.all(
                                        color: _phoneFocusNode.hasFocus
                                            ? const Color(0xFF8B53FE)
                                            : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                    child: Center(
                                      child: TextField(
                                        controller: _phoneController,
                                        focusNode: _phoneFocusNode,
                                        keyboardType: TextInputType.phone,
                                        textDirection: TextDirection.ltr,
                                        textAlign: TextAlign.left,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(12),
                                        ],
                                        style: GoogleFonts.inter(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1C2926),
                                          letterSpacing: 0.5,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: _selectedCountry.exampleNumber,
                                          hintStyle: GoogleFonts.inter(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF9CA3AF),
                                            letterSpacing: 0.0,
                                          ),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        onChanged: (_) {
                                          if (_errorMessage != null) {
                                            setState(() => _errorMessage = null);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20.0),

                          // 3. Password Field
                          Text(
                            isArabic
                                ? (_isLoginMode ? 'كلمة المرور' : 'تعيين كلمة المرور')
                                : (_isLoginMode ? 'Password' : 'Set Password'),
                            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8.0),

                          Container(
                            height: 52.0,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F5F4),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: _passwordFocusNode.hasFocus
                                    ? const Color(0xFF8B53FE)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 20.0,
                                  color: Color(0xFF71717A),
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: TextField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    obscureText: _obscurePassword,
                                    style: GoogleFonts.inter(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1C2926),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: isArabic
                                          ? (_isLoginMode
                                              ? 'أدخل كلمة المرور'
                                              : 'أدخل كلمة مرور (6 خانات على الأقل)')
                                          : (_isLoginMode
                                              ? 'Enter your password'
                                              : 'Enter password (min. 6 chars)'),
                                      hintStyle: GoogleFonts.inter(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF9CA3AF),
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (_) {
                                      if (_errorMessage != null) {
                                        setState(() => _errorMessage = null);
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20.0,
                                    color: const Color(0xFF71717A),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  splashRadius: 18.0,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24.0),

                          // 4. Continue / Log In Button (Never Disappears On Click)
                          ProviderAnimatedButton(
                            height: 52.0,
                            isLoading: _isLoading,
                            backgroundColor: const Color(0xFF252527),
                            foregroundColor: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            onTap: _isLoading
                                ? null
                                : (_isLoginMode ? _handleLogin : _handleSignup),
                            text: _isLoginMode
                                ? (isArabic ? 'تسجيل الدخول' : 'Log In')
                                : (isArabic ? 'إنشاء حساب ومتابعة' : 'Sign Up & Continue'),
                            textStyle: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            icon: Icon(
                              isArabic
                                  ? Icons.arrow_back_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 18.0,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 14.0),

                          // 1st subline: Switch between Login & Sign Up
                          Center(
                            child: InkWell(
                              onTap: () => _switchMode(!_isLoginMode),
                              borderRadius: BorderRadius.circular(8.0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                child: Text.rich(
                                  TextSpan(
                                    text: _isLoginMode
                                        ? (isArabic ? 'ليس لديك حساب؟ ' : "Don't have an account? ")
                                        : (isArabic ? 'لديك حساب بالفعل؟ ' : 'Already have an account? '),
                                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                      fontSize: 13.0,
                                      color: const Color(0xFF71717A),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: _isLoginMode
                                            ? (isArabic ? 'إنشاء حساب' : 'Sign Up')
                                            : (isArabic ? 'تسجيل الدخول' : 'Log In'),
                                        style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF8B53FE),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14.0),

                          // 2nd subline: Security Notice
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.lock_outline_rounded,
                                size: 14.0,
                                color: Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 6.0),
                              Text(
                                isArabic
                                    ? 'بياناتك الشخصية آمنة ومشفرة تماماً'
                                    : 'Your information is safe and private with us',
                                style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF71717A),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14.0),

                          // 3rd subline: Switcher to Partner Mode
                          Center(
                            child: InkWell(
                              onTap: () async {
                                final nav = Navigator.of(context);
                                await ProviderRegistrationStore.instance.setActiveAppMode('provider');
                                if (!mounted) return;
                                nav.pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const PhoneVerificationScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(8.0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                child: Text.rich(
                                  TextSpan(
                                    text: isArabic ? 'هل أنت مزود خدمة؟ ' : 'Are you a service provider? ',
                                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                      fontSize: 13.0,
                                      color: const Color(0xFF71717A),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: isArabic ? 'انضم كمزود' : 'Join as Partner',
                                        style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF8B53FE),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: math.max(28.0, MediaQuery.of(context).padding.bottom + 18.0),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Floating Language switch toggle in top header (Foreground layer - fully clickable)
                  Positioned(
                    top: headerTop,
                    right: 20.0,
                    child: const ProviderAnimatedLanguageToggle(),
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
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 32,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: content,
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
