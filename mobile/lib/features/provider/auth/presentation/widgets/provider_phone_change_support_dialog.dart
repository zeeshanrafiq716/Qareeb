import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_country_picker_modal.dart';
import 'package:mobile/models/country_model.dart';
import 'package:mobile/services/backend_service.dart';

typedef ProviderPhoneChangeSubmitted = void Function(String ticketNumber);

const Color _kPurple = Color(0xFF8B53FE);
const Color _kFieldBg = Color(0xFFF2F5F4);
const Color _kText = Color(0xFF1C2926);

/// Form to request a login phone change via admin Reports & Complaints.
Future<void> showProviderPhoneChangeSupportDialog(
  BuildContext context, {
  required String currentPhone,
  ProviderPhoneChangeSubmitted? onSubmitted,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => _ProviderPhoneChangeSupportDialog(
      currentPhone: currentPhone,
      onSubmitted: onSubmitted,
    ),
  );
}

class _ProviderPhoneChangeSupportDialog extends StatefulWidget {
  final String currentPhone;
  final ProviderPhoneChangeSubmitted? onSubmitted;

  const _ProviderPhoneChangeSupportDialog({
    required this.currentPhone,
    this.onSubmitted,
  });

  @override
  State<_ProviderPhoneChangeSupportDialog> createState() =>
      _ProviderPhoneChangeSupportDialogState();
}

class _ProviderPhoneChangeSupportDialogState
    extends State<_ProviderPhoneChangeSupportDialog> {
  final TextEditingController _phoneDigitsCtrl = TextEditingController();
  final TextEditingController _messageCtrl = TextEditingController();
  CountryModel _selectedCountry = CountryModel.defaultCountry;
  bool _submitting = false;

  @override
  void dispose() {
    _phoneDigitsCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  TextStyle get _inputStyle =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: _kText);

  TextStyle get _hintStyle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _kPurple.withValues(alpha: 0.85),
      );

  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: _hintStyle,
      filled: true,
      fillColor: _kFieldBg,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kPurple, width: 1.2),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  Future<void> _pickCountry() async {
    final picked = await ProviderCountryPickerModal.show(
      context,
      selectedCountry: _selectedCountry,
    );
    if (picked != null && mounted) {
      setState(() => _selectedCountry = picked);
    }
  }

  bool _validatePhone(bool isArabic) {
    String digits = _phoneDigitsCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) {
      digits = digits.replaceFirst(RegExp(r'^0+'), '');
    }
    if (digits.isEmpty) {
      _showError(isArabic ? 'يرجى إدخال رقم الجوال' : 'Please enter your mobile number');
      return false;
    }
    if (digits.length != _selectedCountry.maxLength) {
      _showError(
        isArabic
            ? 'يرجى إدخال ${_selectedCountry.maxLength} أرقام صحيحة لـ ${_selectedCountry.nameAr}'
            : 'Enter a valid ${_selectedCountry.maxLength}-digit number for ${_selectedCountry.nameEn}',
      );
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1C2926),
        content: Text(message),
      ),
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final isArabic = context.isArabic;
    final message = _messageCtrl.text.trim();

    if (message.isEmpty) {
      _showError(isArabic ? 'يرجى كتابة الرسالة' : 'Please enter your message');
      return;
    }
    if (!_validatePhone(isArabic)) return;

    String digits = _phoneDigitsCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) {
      digits = digits.replaceFirst(RegExp(r'^0+'), '');
    }
    final fullPhone = '${_selectedCountry.dialCode}$digits';

    setState(() => _submitting = true);

    final backend = BackendService(ApiClient());
    final result = await backend.submitProviderPhoneChangeRequest(
      requestedPhone: fullPhone,
      message: message,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.success) {
      Navigator.of(context).pop();
      widget.onSubmitted?.call(result.ticketNumber ?? '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: _kPurple,
          content: Text(
            isArabic
                ? 'تم إرسال الطلب. في انتظار موافقة الإدارة.'
                : 'Request submitted. Waiting for admin approval.',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      );
    } else {
      _showError(
        result.errorMessage ??
            (isArabic ? 'تعذر إرسال الطلب' : 'Could not submit request'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final phoneHint = isArabic ? '5XXXXXXXX' : '5XXXXXXXX';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      title: Row(
        children: [
          const Icon(Icons.headset_mic_rounded, color: _kPurple),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isArabic ? 'تغيير رقم تسجيل الدخول' : 'Change Login Number',
              style: GoogleFonts.inter(fontSize: 16.5, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isArabic
                  ? 'أدخل رقم الجوال الجديد ورسالة قصيرة. سيظهر طلبك في لوحة الإدارة للموافقة.'
                  : 'Enter your new mobile number and a short message. Your request will appear in the admin panel for approval.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF566663),
                height: 1.4,
              ),
            ),
            if (widget.currentPhone.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                isArabic
                    ? 'الرقم الحالي: ${widget.currentPhone}'
                    : 'Current number: ${widget.currentPhone}',
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9CA3AF)),
              ),
            ],
            const SizedBox(height: 18),
            _buildFieldLabel(isArabic ? 'رقم الجوال الجديد' : 'New mobile number'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _pickCountry,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                      decoration: BoxDecoration(
                        color: _kFieldBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedCountry.flagEmoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _selectedCountry.dialCode,
                            style: _inputStyle,
                            textDirection: TextDirection.ltr,
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: _kPurple.withValues(alpha: 0.9)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _phoneDigitsCtrl,
                    keyboardType: TextInputType.phone,
                    style: _inputStyle,
                    textDirection: TextDirection.ltr,
                    maxLength: _selectedCountry.maxLength,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _fieldDecoration(hint: phoneHint).copyWith(
                      counterText: '',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFieldLabel(isArabic ? 'الرسالة' : 'Message'),
            TextField(
              controller: _messageCtrl,
              maxLines: 3,
              maxLength: 500,
              style: _inputStyle,
              decoration: _fieldDecoration(
                hint: isArabic ? 'سبب تغيير الرقم...' : 'Why you need to change your number...',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text(
            isArabic ? 'إلغاء' : 'Cancel',
            style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _kPurple,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _kPurple.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(isArabic ? 'إرسال' : 'Submit'),
        ),
      ],
    );
  }
}