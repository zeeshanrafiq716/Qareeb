import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/data/provider_registration_state.dart';
import 'package:mobile/features/provider/auth/presentation/otp_verification_screen.dart';
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
  final CountryModel? selectedCountry;
  final ValueChanged<CountryModel>? onCountryChanged;
  final VoidCallback? onContinue;
  final VoidCallback? onCountryCodeTap;

  const ProviderPhoneInputWidget({
    super.key,
    this.nameController,
    this.controller,
    this.selectedCountry,
    this.onCountryChanged,
    this.onContinue,
    this.onCountryCodeTap,
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
  CountryModel _localSelectedCountry = CountryModel.defaultCountry;
  bool _isLoading = false;
  late final BackendService _backendService;

  CountryModel get _selectedCountry => widget.selectedCountry ?? _localSelectedCountry;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
    _backendService = BackendService(ApiClient());
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
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

    final fullPhone = '${_selectedCountry.dialCode}$digits';
    final displayPhone = '${_selectedCountry.dialCode} $digits';

    ProviderRegistrationStore.instance.update(
      (data) => data.copyWith(
        fullName: rawName.isNotEmpty ? rawName : data.fullName,
        phone: displayPhone,
        contactPhone: displayPhone,
        isWhatsApp: false,
      ),
    );

    setState(() => _isLoading = true);

    final result = await _backendService.requestOtp(phone: fullPhone);

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Show realistic SMS toast notification with received dummy OTP
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1C2926),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        content: Row(
          children: [
            const Icon(Icons.mark_email_read_outlined, color: ProviderColors.primaryButton, size: 20.0),
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

    // Navigate to OTP Screen
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => OtpVerificationScreen(
          phoneNumber: displayPhone,
          fullPhone: fullPhone,
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
  }

  @override
  Widget build(BuildContext context) {
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

              // gap: 16px;
              const SizedBox(height: ProviderPhoneInputWidget.rowGap),

              // button layout: width: double.infinity; height: 52; border-radius: 12px; background: #8B53FE;
              _buildContinueButton(),
            ],
          ),
        ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: ProviderColors.inputBackground, // #F2F5F4
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // flag branding: width: 30; height: 20.22;
              _buildCountryFlag(_selectedCountry),

              const SizedBox(width: 6.0), // gap: 6px

              // dial code: Inter 500 14px line-height 22px #1C2926
              Text(
                _selectedCountry.dialCode,
                style: ProviderTextStyles.phoneCode,
                textDirection: TextDirection.ltr,
              ),

              const SizedBox(width: 10.0), // gap: 10px

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
              cursorColor: ProviderColors.primaryButton,
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
    return SizedBox(
      width: double.infinity,
      height: ProviderPhoneInputWidget.buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : (widget.onContinue ?? _handleContinue),
        style: ElevatedButton.styleFrom(
          backgroundColor: ProviderColors.primaryButton, // #8B53FE
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: EdgeInsets.zero,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.0,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // content: Continue (Inter 500 14px #FFFFFF)
                  Text(
                    context.l10n.continueButtonText,
                    style: ProviderTextStyles.continueButtonText,
                  ),

                  // gap: 12px;
                  const SizedBox(width: 12.0),

                  // arrow icon branding: width: 14; height: 12; angle: -180 deg; border: 1.5px solid #FFFFFF
                  const _ContinueArrowWidget(),
                ],
              ),
      ),
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
