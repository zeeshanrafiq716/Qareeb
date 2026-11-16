import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/data/provider_registration_state.dart';
import 'package:mobile/features/provider/auth/presentation/otp_verification_screen.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_animated_button.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_country_picker_modal.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';
import 'package:mobile/models/country_model.dart';
import 'package:mobile/services/backend_service.dart';

/// Provider Phone Number Widget Layout
/// Implements exact Figma branding specifications:
///
/// phone number widget layout:
///   width: 350;
///   height: 120.22216796875;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 16px;
///
/// 1st row layout:
///   width: 350;
///   height: 52.22222137451172;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 10px;
///
/// number code card layout:
///   width: 126;
///   height: 52.22222137451172;
///   gap: 10px;
///   border-radius: 12px;
///   padding: 16px;
///   background: #F2F5F4;
///
/// row 1 2nd card layout:
///   width: 214;
///   height: 52;
///   border-radius: 12px;
///   background: #F2F5F4;
///   content: 50 123 4567 (Inter 400 14px line-height 22px #566663)
///
/// button layout:
///   width: 350;
///   height: 52;
///   border-radius: 12px;
///   background: #8B53FE;
///   content: Continue (Inter 500 14px line-height 22px #FFFFFF)
///   arrow icon branding: width: 14; height: 12; border: 1.5px solid #FFFFFF;
class ProviderPhoneInputWidget extends StatefulWidget {
  final TextEditingController? nameController;
  final TextEditingController? controller;
  final TextEditingController? passwordController;
  final CountryModel? selectedCountry;
  final ValueChanged<CountryModel>? onCountryChanged;
  final VoidCallback? onContinue;
  final VoidCallback? onCountryCodeTap;
  final bool initialIsLogin;

  const ProviderPhoneInputWidget({
    super.key,
    this.nameController,
    this.controller,
    this.passwordController,
    this.selectedCountry,
    this.onCountryChanged,
    this.onContinue,
    this.onCountryCodeTap,
    this.initialIsLogin = false,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 120.22216796875;
  static const double row1Height = 52.22222137451172;
  static const double buttonHeight = 52.0;
  static const double rowGap = 16.0;
  static const double cardGap = 10.0;

  @override
  State<ProviderPhoneInputWidget> createState() => _ProviderPhoneInputWidgetState();
}

class _ProviderPhoneInputWidgetState extends State<ProviderPhoneInputWidget> {
  late final TextEditingController _internalController;
  late final TextEditingController _passwordController;
  CountryModel _localSelectedCountry = CountryModel.defaultCountry;
  bool _isLoading = false;
  late bool _isLoginMode;
  bool _obscurePassword = true;
  late final BackendService _backendService;

  CountryModel get _selectedCountry => widget.selectedCountry ?? _localSelectedCountry;

  @override
  void initState() {
    super.initState();
    _isLoginMode = widget.initialIsLogin;
    _internalController = widget.controller ?? TextEditingController();
    _passwordController = widget.passwordController ?? TextEditingController();
    _internalController.clear();
    _passwordController.clear();
    _backendService = BackendService(ApiClient());
  }

  void _switchMode(bool login) {
    if (_isLoginMode == login) return;
    setState(() {
      _isLoginMode = login;
      _internalController.clear();
      _passwordController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    if (widget.passwordController == null) {
      _passwordController.dispose();
    }
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  Future<void> _handlePasswordLogin() async {
    if (_isLoading) return;
    final isArabic = context.isArabic;
    final rawPhone = _internalController.text.trim();
    final password = _passwordController.text.trim();

    String digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) {
      digits = digits.replaceFirst(RegExp(r'^0+'), '');
    }

    if (digits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          backgroundColor: const Color(0xFF1C2926),
          content: Text(
            isArabic ? 'يرجى إدخال رقم الهاتف للمتابعة' : 'Please enter your phone number to continue',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          backgroundColor: const Color(0xFF1C2926),
          content: Text(
            isArabic ? 'يرجى إدخال كلمة المرور' : 'Please enter your password',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final fullPhone = '${_selectedCountry.dialCode}$digits';
    final displayPhone = '${_selectedCountry.dialCode} $digits';

    try {
      final result = await _backendService.loginWithPassword(
        phone: fullPhone,
        password: password,
        userType: 'provider',
      );

      if (!mounted) return;

      if (result.success) {
        HapticFeedback.mediumImpact();
        if (result.token != null) {
          ApiClient.setGlobalToken(result.token);
        }

        final providerStatus = result.provider?['status']?.toString();
        final isAlreadyApproved = providerStatus == 'APPROVED';
        final isPendingVerification = providerStatus == 'PENDING_VERIFICATION';

        if (result.provider != null) {
          ProviderRegistrationStore.instance.updateFromBackendProfile(result.provider!);
        }

        ProviderRegistrationStore.instance.update(
          (data) => data.copyWith(
            phone: displayPhone,
            authToken: result.token ?? data.authToken,
            status: providerStatus ?? data.status,
            isOnboardingCompleted: isAlreadyApproved || isPendingVerification || data.isOnboardingCompleted,
          ),
        );

        if (isAlreadyApproved) {
          Navigator.of(context).pushNamedAndRemoveUntil('/provider/home', (route) => false);
        } else if (isPendingVerification) {
          Navigator.of(context).pushNamedAndRemoveUntil('/provider/admin-approval', (route) => false);
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil('/provider/home', (route) => false);
        }
      } else {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            content: Text(
              result.errorMessage ??
                  (isArabic ? 'رقم الهاتف أو كلمة المرور غير صحيحة' : 'Invalid phone number or password'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            content: Text(
              isArabic ? 'حدث خطأ، يرجى المحاولة مرة أخرى' : 'An error occurred, please try again',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openCountryPicker() async {
    final picked = await ProviderCountryPickerModal.show(
      context,
      selectedCountry: _selectedCountry,
    );
    if (picked != null && mounted) {
      setState(() {
        _localSelectedCountry = picked;
      });
      widget.onCountryChanged?.call(picked);
    }
  }

  Future<void> _handleContinue() async {
    if (_isLoading) return;

    final isArabic = context.isArabic;
    final rawName = widget.nameController?.text.trim() ?? '';

    // 1. Name Validation (if nameController is connected)
    if (widget.nameController != null) {
      if (rawName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            backgroundColor: const Color(0xFF1C2926),
            content: Text(
              isArabic ? 'يرجى إدخال اسمك الكامل' : 'Please enter your full name',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      if (rawName.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            backgroundColor: const Color(0xFF1C2926),
            content: Text(
              isArabic ? 'الاسم قصير جداً، يرجى إدخال اسم صحيح' : 'Name is too short, please enter a valid name',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    // 2. Phone Digits Security Validation
    final rawPhone = _internalController.text.trim();
    String digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) {
      digits = digits.replaceFirst(RegExp(r'^0+'), '');
    }

    if (digits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          backgroundColor: const Color(0xFF1C2926),
          content: Text(
            isArabic ? 'يرجى إدخال رقم الهاتف' : 'Please enter your phone number',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Security Check: Complete digits required matching the selected country code!
    if (digits.length != _selectedCountry.maxLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          backgroundColor: const Color(0xFF1C2926),
          content: Text(
            isArabic
                ? 'يرجى إكمال رقم الهاتف (${digits.length}/${_selectedCountry.maxLength} أرقام لدولة ${_selectedCountry.nameAr})'
                : 'Please complete ${_selectedCountry.maxLength} digits for ${_selectedCountry.nameEn} (${digits.length}/${_selectedCountry.maxLength})',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // 3. Password Validation for Provider Registration
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          backgroundColor: const Color(0xFF1C2926),
          content: Text(
            isArabic
                ? 'يرجى تعيين كلمة المرور (6 خانات على الأقل)'
                : 'Please set a password (at least 6 characters)',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          backgroundColor: const Color(0xFF1C2926),
          content: Text(
            isArabic
                ? 'كلمة المرور يجب أن لا تقل عن 6 خانات'
                : 'Password must be at least 6 characters',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final fullPhone = '${_selectedCountry.dialCode}$digits';
    final displayPhone = '${_selectedCountry.dialCode} $digits';

    setState(() => _isLoading = true);

    try {
      try {
        ProviderRegistrationStore.instance.update(
          (data) => data.copyWith(
            fullName: rawName.isNotEmpty ? rawName : data.fullName,
            phone: displayPhone,
            contactPhone: displayPhone,
            isWhatsApp: false,
          ),
        );
      } catch (storeError) {
        debugPrint('ProviderRegistrationStore update error: $storeError');
      }

      final result = await _backendService.requestOtp(
        phone: fullPhone,
        channel: 'sms',
        userType: 'provider',
        purpose: 'signup',
      );

      if (!mounted) return;

      if (!result.success) {
        if (result.alreadyExists) {
          _switchMode(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF1C2926),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              content: Text(
                isArabic
                    ? 'يوجد حساب مسجل بهذا الرقم بالفعل. يرجى تسجيل الدخول'
                    : 'An account with this phone number already exists. Please log in.',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.redAccent,
              content: Text(
                result.message.isNotEmpty
                    ? result.message
                    : (isArabic ? 'تعذر إرسال رمز التحقق. يرجى المحاولة لاحقاً' : 'Failed to send verification code. Please try again.'),
              ),
            ),
          );
        }
        return;
      }

      // Show realistic SMS notification if sent via Twilio, or dev OTP toast in test mode
      if (result.smsDelivered) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1C2926),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            content: Row(
              children: [
                const Icon(Icons.sms_outlined, color: ProviderColors.brandPurple, size: 20.0),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    isArabic
                        ? 'تم إرسال رمز التحقق إلى $displayPhone عبر رسالة SMS'
                        : 'Verification code sent to $displayPhone via SMS',
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
                const Icon(Icons.mark_email_read_outlined, color: ProviderColors.brandPurple, size: 20.0),
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

      // Navigate to OTP Screen
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => OtpVerificationScreen(
            phoneNumber: displayPhone,
            fullPhone: fullPhone,
            dummyOtp: result.otp,
            password: password,
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
    } catch (e, stack) {
      debugPrint('Error in _handleContinue: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            content: Text(
              isArabic ? 'حدث خطأ، يرجى المحاولة مرة أخرى' : 'An error occurred, please try again',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 0. Mode Switcher Pill: [ Log In | Register ]
              Container(
                height: 44.0,
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
                                fontSize: 13.0,
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
                              isArabic ? 'تسجيل جديد' : 'Register',
                              style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                fontSize: 13.0,
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

              // 1st row layout: width: double.infinity; height: 52.22; gap: 10px;
              // Enforce LTR so in both Arabic and English, code field stays on the LEFT side and phone input field on the RIGHT side.
              Directionality(
                textDirection: TextDirection.ltr,
                child: SizedBox(
                  width: double.infinity,
                  height: ProviderPhoneInputWidget.row1Height,
                  child: Row(
                    children: [
                      // number code card layout: width: 126; height: 52.22; border-radius: 12px; background: #F2F5F4;
                      _buildNumberCodeCard(),

                      // gap: 10px;
                      const SizedBox(width: ProviderPhoneInputWidget.cardGap),

                      // row 1 2nd card layout: Expanded; height: 52; border-radius: 12px; background: #F2F5F4;
                      Expanded(
                        child: _buildPhoneNumberInputCard(),
                      ),
                    ],
                  ),
                ),
              ),

              // Password input field: Always available for both Registration and Login
              const SizedBox(height: 12.0),
              _buildPasswordInputCard(),

              // gap: 16px;
              const SizedBox(height: ProviderPhoneInputWidget.rowGap),

              // button layout: width: double.infinity; height: 52; border-radius: 12px; background: #8B53FE;
              _buildContinueButton(),

              if (_isLoginMode) ...[
                const SizedBox(height: 12.0),
                Center(
                  child: InkWell(
                    onTap: () => _switchMode(false),
                    borderRadius: BorderRadius.circular(6.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Text(
                        isArabic ? 'نسيت كلمة المرور؟ الدخول عبر رمز SMS' : 'Forgot password? Login with SMS OTP',
                        style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8B53FE),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordInputCard() {
    final isArabic = context.isArabic;
    return Container(
      height: 52.0,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5F4),
        borderRadius: BorderRadius.circular(12.0),
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
              obscureText: _obscurePassword,
              style: GoogleFonts.inter(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1C2926),
              ),
              decoration: InputDecoration(
                hintText: _isLoginMode
                    ? (isArabic ? 'أدخل كلمة المرور' : 'Enter your password')
                    : (isArabic ? 'تعيين كلمة المرور (6 خانات على الأقل)' : 'Set Password (at least 6 characters)'),
                hintStyle: GoogleFonts.inter(
                  fontSize: 13.0,
                  color: const Color(0xFF9CA3AF),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
    );
  }

  /// number code card layout:
  /// width: 126; height: 52.22; border-radius: 12px; padding: 16px; background: #F2F5F4;
  /// inner content: flag (30x20.22) + gap(6px) + dialCode + gap(10px) + dropdown(11x5)
  Widget _buildNumberCodeCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onCountryCodeTap ?? _openCountryPicker,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          width: 126.0,
          height: ProviderPhoneInputWidget.row1Height,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: ProviderColors.inputBackground, // #F2F5F4
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // flag branding: width: 30; height: 20.22;
              _buildCountryFlag(_selectedCountry),

              const SizedBox(width: 4.0), // gap: 4px

              // dial code: Inter 500 14px line-height 22px #1C2926
              Flexible(
                child: Text(
                  _selectedCountry.dialCode,
                  style: ProviderTextStyles.phoneCode,
                  textDirection: TextDirection.ltr,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 6.0), // gap: 6px

              // dropdown icon branding: width: 11; height: 5; border: 1px solid #566663;
              const _DropdownChevronWidget(),
            ],
          ),
        ),
      ),
    );
  }

  /// Country Flag widget:
  /// Uses custom exact painter for Saudi Arabia (SA), and crisp flag display for other countries
  Widget _buildCountryFlag(CountryModel country) {
    if (country.code == 'SA') {
      return const _SaudiFlagWidget();
    }
    return Container(
      width: 30.0,
      height: 20.22222328186035,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: Text(
        country.flagEmoji,
        style: const TextStyle(
          fontSize: 18.0,
          height: 1.0,
        ),
      ),
    );
  }

  /// row 1 2nd card layout:
  /// width: 214; height: 52; border-radius: 12px; background: #F2F5F4;
  /// card inner content branding:
  /// content: placeholder; left: 16px; Inter 400 14px line-height 22px #566663;
  Widget _buildPhoneNumberInputCard() {
    final raw = _internalController.text.trim();
    final digits = raw.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp(r'^0+'), '');
    final bool isCompleted = digits.length == _selectedCountry.maxLength;

    return Container(
      height: ProviderPhoneInputWidget.row1Height,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: ProviderColors.inputBackground, // #F2F5F4
        borderRadius: BorderRadius.circular(12.0),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _internalController,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(_selectedCountry.maxLength),
              ],
              onChanged: (val) {
                if (val.startsWith('0')) {
                  final clean = val.replaceFirst(RegExp(r'^0+'), '');
                  _internalController.value = TextEditingValue(
                    text: clean,
                    selection: TextSelection.collapsed(offset: clean.length),
                  );
                }
                setState(() {});
              },
              style: ProviderTextStyles.phoneInput,
              cursorColor: ProviderColors.brandPurple,
              decoration: InputDecoration(
                hintText: _selectedCountry.exampleNumber,
                hintStyle: ProviderTextStyles.phonePlaceholder,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (isCompleted)
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF1D8070),
              size: 18.0,
            )
          else if (digits.isNotEmpty)
            Text(
              '${digits.length}/${_selectedCountry.maxLength}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.0,
                fontWeight: FontWeight.w500,
                color: Color(0xFF566663),
              ),
            ),
        ],
      ),
    );
  }

  /// button layout:
  /// width: 350; height: 52; border-radius: 12px; background: #8B53FE;
  /// button inner branding:
  /// width: 87; height: 12; gap: 12px;
  /// content: Continue (Inter 500 14px line-height 22px #FFFFFF)
  /// arrow icon branding: width: 14; height: 12; border: 1.5px solid #FFFFFF
  Widget _buildContinueButton() {
    final isArabic = context.isArabic;
    return ProviderAnimatedButton(
      height: ProviderPhoneInputWidget.buttonHeight,
      backgroundColor: ProviderColors.primaryButton, // #8B53FE
      foregroundColor: Colors.white,
      isLoading: _isLoading,
      text: _isLoginMode
          ? (isArabic ? 'تسجيل الدخول' : 'Log In')
          : context.l10n.continueButtonText,
      icon: const _ContinueArrowWidget(),
      onTap: _isLoginMode
          ? _handlePasswordLogin
          : (widget.onContinue ?? _handleContinue),
    );
  }
}

/// flag branding:
/// width: 30; height: 20.22222328186035; angle: 0 deg; opacity: 1;
class _SaudiFlagWidget extends StatelessWidget {
  const _SaudiFlagWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.0,
      height: 20.22222328186035,
      decoration: BoxDecoration(
        color: ProviderColors.saudiGreen, // #006C35
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: const CustomPaint(
        painter: _SaudiFlagPainter(),
      ),
    );
  }
}

class _SaudiFlagPainter extends CustomPainter {
  const _SaudiFlagPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Stylized white sword near bottom
    final double swordY = size.height * 0.70;
    canvas.drawLine(
      Offset(size.width * 0.18, swordY),
      Offset(size.width * 0.82, swordY),
      linePaint,
    );
    // Sword hilt crossbar
    canvas.drawLine(
      Offset(size.width * 0.76, swordY - 2.0),
      Offset(size.width * 0.76, swordY + 2.0),
      linePaint,
    );

    // Stylized Arabic calligraphy representation
    final double textY = size.height * 0.38;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.20, textY - 2.0, size.width * 0.60, 4.0),
        const Radius.circular(1.5),
      ),
      whitePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// dropdown icon branding:
/// width: 11; height: 5; angle: 0 deg; opacity: 1; border-width: 1px; border: 1px solid #566663
class _DropdownChevronWidget extends StatelessWidget {
  const _DropdownChevronWidget();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      size: Size(11.0, 5.0),
      painter: _DropdownChevronPainter(),
    );
  }
}

class _DropdownChevronPainter extends CustomPainter {
  const _DropdownChevronPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ProviderColors.dropdownBorder // #566663
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0.5, 0.5)
      ..lineTo(size.width / 2, size.height - 0.5)
      ..lineTo(size.width - 0.5, 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// arrow icon branding:
/// width: 14; height: 12; angle: -180 deg; opacity: 1; border-width: 1.5px; border: 1.5px solid #FFFFFF
class _ContinueArrowWidget extends StatelessWidget {
  const _ContinueArrowWidget();

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: Directionality.of(context) == TextDirection.rtl,
      child: const CustomPaint(
        size: Size(14.0, 12.0),
        painter: _ContinueArrowPainter(),
      ),
    );
  }
}

class _ContinueArrowPainter extends CustomPainter {
  const _ContinueArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double midY = size.height / 2;

    // Horizontal stem from left to right
    final shaftPath = Path()
      ..moveTo(0.5, midY)
      ..lineTo(size.width - 0.5, midY);
    canvas.drawPath(shaftPath, paint);

    // Arrowhead pointing forward (right)
    final headPath = Path()
      ..moveTo(size.width - 5.5, 1.5)
      ..lineTo(size.width - 0.5, midY)
      ..lineTo(size.width - 5.5, size.height - 1.5);
    canvas.drawPath(headPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
