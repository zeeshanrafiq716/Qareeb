import 'package:flutter/material.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/data/provider_registration_state.dart';
import 'package:mobile/features/provider/auth/presentation/otp_verification_screen.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_or_divider.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_phone_input_widget.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_security_notice_row.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_whatsapp_button.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';
import 'package:mobile/models/country_model.dart';
import 'package:mobile/services/backend_service.dart';

/// Provider Auth Next Widget Layout (Form Section)
/// Implements exact Figma branding specifications:
///
/// 1. Name label: "Full Name" / "الاسم الكامل"
/// 2. Name input card (height: 52; #F2F5F4; 12px radius; with user icon)
/// 3. Phone label: "Phone Number" / "رقم الهاتف"
/// 4. Phone input card + Country Code with complete digit security
/// 5. Continue button
/// 6. Or divider
/// 7. Continue with WhatsApp button (verified with OTP)
/// 8. Security notice: "Your Number is safe with us."
class ProviderAuthFormLayout extends StatefulWidget {
  final Widget? phoneInputSlot;
  final Widget? actionButtonSlot;
  final VoidCallback? onWhatsAppTap;

  const ProviderAuthFormLayout({
    super.key,
    this.phoneInputSlot,
    this.actionButtonSlot,
    this.onWhatsAppTap,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 360.0;
  static const double designGap = 16.0;

  @override
  State<ProviderAuthFormLayout> createState() => _ProviderAuthFormLayoutState();
}

class _ProviderAuthFormLayoutState extends State<ProviderAuthFormLayout> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  CountryModel _selectedCountry = CountryModel.defaultCountry;
  late final BackendService _backendService;
  bool _isWhatsAppLoading = false;

  @override
  void initState() {
    super.initState();
    final existingData = ProviderRegistrationStore.instance.data;
    _nameController = TextEditingController(text: existingData.fullName);
    _phoneController = TextEditingController();
    _backendService = BackendService(ApiClient());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleWhatsAppRegistration() async {
    if (_isWhatsAppLoading) return;

    final isArabic = context.isArabic;
    final rawName = _nameController.text.trim();
    final rawPhone = _phoneController.text.trim();
    String digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) {
      digits = digits.replaceFirst(RegExp(r'^0+'), '');
    }

    // 1. Phone number is required for WhatsApp OTP verification
    if (digits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          backgroundColor: const Color(0xFF1C2926),
          content: Text(
            isArabic
                ? 'يرجى إدخال رقم الهاتف للمتابعة والتحقق عبر واتساب'
                : 'Please enter your phone number to verify via WhatsApp',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // 2. Security Check: Phone number digits must be complete for selected country
    if (digits.length != _selectedCountry.maxLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          backgroundColor: const Color(0xFF1C2926),
          content: Text(
            isArabic
                ? 'يرجى إكمال رقم الهاتف (${digits.length}/${_selectedCountry.maxLength} أرقام لدولة ${_selectedCountry.nameAr}) للتحقق عبر واتساب'
                : 'Please complete ${_selectedCountry.maxLength} digits for ${_selectedCountry.nameEn} (${digits.length}/${_selectedCountry.maxLength}) for WhatsApp verification',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isWhatsAppLoading = true);

    final fullPhone = '${_selectedCountry.dialCode}$digits';
    final displayPhone = '${_selectedCountry.dialCode} $digits';
    final nameToSave = rawName.isNotEmpty
        ? rawName
        : (isArabic ? 'مزود الخدمة' : 'Service Provider');

    ProviderRegistrationStore.instance.update(
      (data) => data.copyWith(
        fullName: nameToSave,
        phone: displayPhone,
        contactPhone: displayPhone,
        whatsappNumber: displayPhone,
        isWhatsApp: true,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1C2926),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        content: Row(
          children: [
            const SizedBox(
              width: 18.0,
              height: 18.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: ProviderColors.whatsappGreen,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                isArabic
                    ? 'جارٍ إرسال رمز التحقق عبر واتساب إلى $displayPhone...'
                    : 'Sending verification code via WhatsApp to $displayPhone...',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    final result = await _backendService.requestOtp(phone: fullPhone);

    if (!mounted) return;
    setState(() => _isWhatsAppLoading = false);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Show WhatsApp verification dummy OTP toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1C2926),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        content: Row(
          children: [
            const Icon(Icons.mark_email_read_outlined, color: ProviderColors.whatsappGreen, size: 20.0),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                isArabic
                    ? 'رمز التحقق عبر واتساب (تجريبي): ${result.otp}'
                    : 'WhatsApp Verification Code (Dummy): ${result.otp}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 5),
      ),
    );

    // Redirect to OTP verification screen for WhatsApp!
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => OtpVerificationScreen(
          phoneNumber: displayPhone,
          fullPhone: fullPhone,
          dummyOtp: result.otp,
          isWhatsApp: true,
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
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = context.isArabic;

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
              // 1. Label: "Full Name" / "الاسم الكامل"
              SizedBox(
                width: double.infinity,
                child: Text(
                  isArabic ? 'الاسم الكامل' : 'Full Name',
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: ProviderTextStyles.phoneInputLabel,
                ),
              ),

              const SizedBox(height: 8.0),

              // 2. Full Name Input Card (52px height, #F2F5F4 background, 12px radius)
              Container(
                width: double.infinity,
                height: 52.0,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: ProviderColors.inputBackground, // #F2F5F4
                  borderRadius: BorderRadius.circular(12.0),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFF566663),
                      size: 20.0,
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        style: ProviderTextStyles.phoneInput,
                        cursorColor: ProviderColors.primaryButton,
                        decoration: InputDecoration(
                          hintText: isArabic ? 'أدخل اسمك الكامل' : 'Enter your full name',
                          hintStyle: ProviderTextStyles.phonePlaceholder,
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16.0),

              // 3. Label: "Phone Number" / "رقم الهاتف" (14px, Medium 500, #1C2926)
              SizedBox(
                width: double.infinity,
                child: Text(
                  context.l10n.phoneNumberLabel,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: ProviderTextStyles.phoneInputLabel,
                ),
              ),

              const SizedBox(height: 8.0),

              // 4. Phone Number Widget Layout with complete digit security
              widget.phoneInputSlot ??
                  ProviderPhoneInputWidget(
                    nameController: _nameController,
                    controller: _phoneController,
                    selectedCountry: _selectedCountry,
                    onCountryChanged: (picked) {
                      setState(() {
                        _selectedCountry = picked;
                      });
                    },
                  ),

              // Gap: 16px
              const SizedBox(height: 16.0),

              // 5. Or Divider layout (lines on left and right + "or" centered)
              const ProviderOrDivider(),

              // Gap: 16px
              const SizedBox(height: 16.0),

              // 6. WhatsApp Button layout (width: double.infinity; height: 52; #F2F5F4)
              widget.actionButtonSlot ??
                  ProviderWhatsAppButton(
                    onTap: widget.onWhatsAppTap ??
                        () => _handleWhatsAppRegistration(),
                  ),

              // Gap: 16px
              const SizedBox(height: 16.0),

              // 7. Security Notice Row (lock icon + "Your Number is safe with us.")
              const Center(
                child: ProviderSecurityNoticeRow(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
