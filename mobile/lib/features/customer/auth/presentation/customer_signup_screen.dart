import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../models/country_model.dart';
import '../../../../services/backend_service.dart';
import '../../../provider/auth/data/provider_registration_state.dart';
import '../../../provider/auth/presentation/phone_verification_screen.dart';
import '../../../provider/auth/presentation/widgets/provider_animated_language_toggle.dart';
import '../../../provider/auth/presentation/widgets/provider_country_picker_modal.dart';
import '../data/customer_auth_store.dart';
import 'customer_otp_verification_screen.dart';

/// Customer Signup Screen (Name and Phone Number only)
/// After completing signup, customer will never face these steps again.
class CustomerSignupScreen extends ConsumerStatefulWidget {
  const CustomerSignupScreen({super.key});

  @override
  ConsumerState<CustomerSignupScreen> createState() => _CustomerSignupScreenState();
}

class _CustomerSignupScreenState extends ConsumerState<CustomerSignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();

  CountryModel _selectedCountry = CountryModel.defaultCountry;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Pre-populate if previously entered or loaded
    final store = CustomerAuthStore.instance;
    if (store.fullName.isNotEmpty) {
      _nameController.text = store.fullName;
    }
    if (store.phone.isNotEmpty) {
      String cleanPhone = store.phone;
      if (cleanPhone.startsWith(_selectedCountry.dialCode)) {
        cleanPhone = cleanPhone.substring(_selectedCountry.dialCode.length).trim();
      }
      _phoneController.text = cleanPhone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
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

  Future<void> _handleSignup() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');
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

    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 7) {
      setState(() {
        _errorMessage = isArabic
            ? 'يرجى إدخال رقم هاتف صحيح'
            : 'Please enter a valid phone number';
      });
      _phoneFocusNode.requestFocus();
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final fullPhoneNumber = '${_selectedCountry.dialCode}$digitsOnly';
      final displayPhoneNumber = '${_selectedCountry.dialCode} $digitsOnly';

      // Request OTP via backend service (with dummy fallback for testing)
      final backendService = BackendService(ApiClient());
      final result = await backendService.requestOtp(phone: fullPhoneNumber);

      if (!mounted) return;
      setState(() => _isLoading = false);

      HapticFeedback.selectionClick();

      // Show dummy OTP snackbar for sandbox testing (matches provider side behavior)
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
                      : 'Verification Code (Dummy): ${result.otp}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 5),
        ),
      );

      // Navigate to Customer OTP Verification Screen (matches provider side OTP flow)
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => CustomerOtpVerificationScreen(
            fullName: name,
            phoneNumber: displayPhoneNumber,
            fullPhone: fullPhoneNumber,
            countryCode: _selectedCountry.dialCode,
            dummyOtp: result.otp,
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
                          SizedBox(height: headerTop + 54.0),

                          // Brand Badge
                          Center(
                            child: Container(
                              width: 64.0,
                              height: 64.0,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0EAFE),
                                borderRadius: BorderRadius.circular(20.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x1A8B53FE),
                                    offset: Offset(0, 4),
                                    blurRadius: 16.0,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.person_pin_rounded,
                                  size: 34.0,
                                  color: Color(0xFF8B53FE),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20.0),

                          // Heading
                          Text(
                            isArabic ? 'إنشاء حساب جديد' : 'Create Your Account',
                            textAlign: TextAlign.center,
                            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                              fontSize: 24.0,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1C2926),
                              letterSpacing: -0.3,
                            ),
                          ),

                          const SizedBox(height: 8.0),

                          // Subtitle
                          Text(
                            isArabic
                                ? 'أدخل اسمك ورقم هاتفك للمتابعة والوصول السريع للخدمات'
                                : 'Enter your name and phone number to get started with services',
                            textAlign: TextAlign.center,
                            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF616166),
                              height: 1.35,
                            ),
                          ),

                          const SizedBox(height: 32.0),

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

                          // 1. Full Name Field
                          Text(
                            isArabic ? 'الاسم الكامل' : 'Full Name',
                            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C2926),
                            ),
                          ),
                          const SizedBox(height: 6.0),

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

                          // 2. Phone Number Field
                          Text(
                            isArabic ? 'رقم الهاتف' : 'Phone Number',
                            style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1C2926),
                            ),
                          ),
                          const SizedBox(height: 6.0),

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

                          const SizedBox(height: 28.0),

                          // 3. Continue / Sign Up Button (Branded Black Button with White Text)
                          SizedBox(
                            width: double.infinity,
                            height: 52.0,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF252527),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22.0,
                                      height: 22.0,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          isArabic ? 'متابعة' : 'Continue',
                                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Icon(
                                          isArabic
                                              ? Icons.arrow_back_rounded
                                              : Icons.arrow_forward_rounded,
                                          size: 18.0,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20.0),

                          // Security Notice
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

                          const SizedBox(height: 32.0),

                          // Switcher to Partner Mode
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
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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

                          const SizedBox(height: 24.0),
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
