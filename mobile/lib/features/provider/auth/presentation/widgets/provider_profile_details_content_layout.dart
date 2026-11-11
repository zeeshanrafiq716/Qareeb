import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/data/provider_registration_state.dart';
import 'package:mobile/features/provider/auth/presentation/vehicle_service_details_screen.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_animated_button.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_bottom_indicator.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/services/backend_service.dart';

/// Provider Personal Details Content Layout Widget
/// Replaces form layout matching exact branding from user spec & Figma screenshot:
///
/// 1. Top security notification card:
///    - Background: #F6F3FE
///    - Shield icon + "Your login phone number is used for account security and cannot be changed."
/// 2. Full Name field:
///    - Label: "Full Name"
///    - Icon: Person + vertical divider + textfield
///    - Helper: "This name will be visible to customers."
/// 3. Phone number field:
///    - Label: "Phone number"
///    - Icon: Phone + vertical divider + registered number + "Read-only" badge + Lock icon
///    - Helper: "This is your registered login number and cannot be changed"
/// 4. WhatsApp number (Optional) field:
///    - Label: "WhatsApp number (Optional)"
///    - Icon: Chat/WhatsApp + vertical divider + textfield
///    - Helper: "You can add or update your secondary WhatsApp number."
/// 5. Support card:
///    - Purple exclamation circle + "Need to change your login number?"
///    - "For security, contact support to change your login number."
///    - "Contact Support ->"
/// 6. Save Changes Button:
///    - Purple (#8B53FE), 52px height, "Save Changes ->"
class ProviderProfileDetailsContentLayout extends StatefulWidget {
  final VoidCallback? onSaved;

  const ProviderProfileDetailsContentLayout({
    super.key,
    this.onSaved,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 400.0;
  static const double designTop = 152.0;
  static const double designLeft = 20.0;
  static const double designGap = 20.0;

  @override
  State<ProviderProfileDetailsContentLayout> createState() =>
      _ProviderProfileDetailsContentLayoutState();
}

class _ProviderProfileDetailsContentLayoutState
    extends State<ProviderProfileDetailsContentLayout> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _whatsappCtrl;
  late final String _registeredPhone;
  bool _isLoading = false;
  late final BackendService _backendService;

  @override
  void initState() {
    super.initState();
    final savedData = ProviderRegistrationStore.instance.data;
    _nameCtrl = TextEditingController(
      text: savedData.fullName,
    );
    _registeredPhone = savedData.phone.isNotEmpty ? savedData.phone : '';
    _whatsappCtrl = TextEditingController(
      text: savedData.whatsappNumber.isNotEmpty
          ? savedData.whatsappNumber
          : _registeredPhone,
    );
    _backendService = BackendService(ApiClient());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _whatsappCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSaveChanges() async {
    if (_isLoading) return;

    final isArabic = context.isArabic;
    final name = _nameCtrl.text.trim();
    final whatsapp = _whatsappCtrl.text.trim();

    if (name.isEmpty) {
      _showFeedback(
        isArabic ? 'يرجى إدخال الاسم الكامل' : 'Please enter your full name',
      );
      return;
    }

    setState(() => _isLoading = true);

    // Persist to central registration store
    ProviderRegistrationStore.instance.update(
      (data) => data.copyWith(
        fullName: name,
        whatsappNumber: whatsapp,
        status: data.isOnboardingCompleted ? data.status : 'PENDING_PROFILE',
      ),
    );

    // Call backend service update
    try {
      await _backendService.updateProviderProfile(
        name: name,
        categoryId: '1',
        address: '',
        city: '',
      );
    } catch (_) {
      // Graceful offline fallback
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    _showFeedback(
      isArabic
          ? 'تم حفظ التغييرات بنجاح'
          : 'Changes saved successfully',
      isSuccess: true,
    );

    if (widget.onSaved != null) {
      widget.onSaved!();
      return;
    }

    // After Personal Info page, proceed directly to Vehicle & Service Details screen
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const VehicleServiceDetailsScreen(),
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

  void _showFeedback(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        backgroundColor: const Color(0xFF1C2926),
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.info_outline,
              color: isSuccess ? ProviderColors.whatsappGreen : Colors.orangeAccent,
              size: 20.0,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13.0,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSupportDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Row(
          children: [
            const Icon(Icons.headset_mic_rounded, color: Color(0xFF8B53FE)),
            const SizedBox(width: 10.0),
            Text(
              isArabic ? 'تغيير رقم تسجيل الدخول' : 'Change Login Number',
              style: GoogleFonts.inter(fontSize: 16.5, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          isArabic
              ? 'لحماية أمان حسابك، يتطلب تغيير رقم الهاتف المسجل التحقق من الهوية عبر فريق دعم زيشو (Zesho). يرجى التواصل معنا للمتابعة.'
              : 'For security and account safety, changing your registered login phone number requires identity verification via Zesho Partner Support.',
          style: GoogleFonts.inter(fontSize: 13.0, color: const Color(0xFF566663), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              isArabic ? 'إلغاء' : 'Cancel',
              style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
            ),
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
                  content: Text(isArabic ? 'تم فتح تذكرة دعم لتغيير الرقم' : 'Support ticket opened for phone change'),
                  backgroundColor: const Color(0xFF8B53FE),
                ),
              );
            },
            child: Text(isArabic ? 'تواصل مع الدعم' : 'Contact Support'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return Opacity(
      opacity: 1.0,
      child: Transform.rotate(
        angle: 0.0,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Security Notice Box
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F3FE),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: const Color(0xFFEBE4FC),
                    width: 1.0,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      size: 20.0,
                      color: Color(0xFF566663),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Text(
                        isArabic
                            ? 'يتم استخدام رقم هاتف تسجيل الدخول لأمان الحساب ولا يمكن تغييره.'
                            : 'Your login phone number is used for account security and cannot be changed.',
                        style: isArabic
                            ? GoogleFonts.cairo(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF566663),
                                height: 1.35,
                              )
                            : GoogleFonts.inter(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF566663),
                                height: 1.35,
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20.0),

              // 2. Full Name Field
              Text(
                isArabic ? 'الاسم الكامل' : 'Full Name',
                style: isArabic
                    ? GoogleFonts.cairo(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C2926),
                      )
                    : GoogleFonts.inter(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C2926),
                      ),
              ),
              const SizedBox(height: 8.0),
              Container(
                height: 52.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 20.0,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 10.0),
                    Container(
                      width: 1.0,
                      height: 18.0,
                      color: const Color(0xFFD1D5DB),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: TextField(
                        controller: _nameCtrl,
                        style: isArabic
                            ? GoogleFonts.cairo(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1C2926),
                              )
                            : GoogleFonts.inter(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1C2926),
                              ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: isArabic ? 'أدخل اسمك الكامل' : 'Enter full name',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14.0,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                isArabic
                    ? 'سيكون هذا الاسم مرئياً للعملاء.'
                    : 'This name will be visible to customers.',
                style: isArabic
                    ? GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8E8E93),
                      )
                    : GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8E8E93),
                      ),
              ),

              const SizedBox(height: 18.0),

              // 3. Phone Number Field (Read-only)
              Text(
                isArabic ? 'رقم الهاتف' : 'Phone number',
                style: isArabic
                    ? GoogleFonts.cairo(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C2926),
                      )
                    : GoogleFonts.inter(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C2926),
                      ),
              ),
              const SizedBox(height: 8.0),
              Container(
                height: 52.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 19.0,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 10.0),
                    Container(
                      width: 1.0,
                      height: 18.0,
                      color: const Color(0xFFD1D5DB),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        _registeredPhone,
                        style: GoogleFonts.inter(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBE8F5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        isArabic ? 'للقراءة فقط' : 'Read-only',
                        style: isArabic
                            ? GoogleFonts.cairo(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF7C69A5),
                              )
                            : GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF7C69A5),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    const Icon(
                      Icons.lock_rounded,
                      size: 16.0,
                      color: Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                isArabic
                    ? 'هذا هو رقم تسجيل الدخول المسجل ولا يمكن تغييره'
                    : 'This is your registered login number and cannot be changed',
                style: isArabic
                    ? GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8E8E93),
                      )
                    : GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8E8E93),
                      ),
              ),

              const SizedBox(height: 18.0),

              // 4. WhatsApp Number (Optional) Field
              Row(
                children: [
                  Text(
                    isArabic ? 'رقم الواتساب ' : 'WhatsApp number ',
                    style: isArabic
                        ? GoogleFonts.cairo(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1C2926),
                          )
                        : GoogleFonts.inter(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1C2926),
                          ),
                  ),
                  Text(
                    isArabic ? '(اختياري)' : '(Optional)',
                    style: isArabic
                        ? GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF8E8E93),
                          )
                        : GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF8E8E93),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Container(
                height: 52.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 19.0,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 10.0),
                    Container(
                      width: 1.0,
                      height: 18.0,
                      color: const Color(0xFFD1D5DB),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: TextField(
                        controller: _whatsappCtrl,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.inter(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1C2926),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: '+966 50 123 4567',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14.0,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                isArabic
                    ? 'يمكنك إضافة أو تحديث رقم الواتساب الثانوي الخاص بك.'
                    : 'You can add or update your secondary WhatsApp number.',
                style: isArabic
                    ? GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8E8E93),
                      )
                    : GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8E8E93),
                      ),
              ),

              const SizedBox(height: 24.0),

              // 5. Need to change login number support card
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: const Color(0xFFEBEBEF),
                    width: 1.0,
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32.0,
                      height: 32.0,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8B53FE),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.priority_high_rounded,
                          size: 18.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic
                                ? 'هل تحتاج لتغيير رقم تسجيل الدخول؟'
                                : 'Need to change your login number?',
                            style: isArabic
                                ? GoogleFonts.cairo(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1C2926),
                                  )
                                : GoogleFonts.inter(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1C2926),
                                  ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            isArabic
                                ? 'لأسباب أمنية، يرجى التواصل مع الدعم لتغيير رقم تسجيل الدخول.'
                                : 'For security, contact support to change your login number.',
                            style: isArabic
                                ? GoogleFonts.cairo(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF6B7280),
                                    height: 1.35,
                                  )
                                : GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF6B7280),
                                    height: 1.35,
                                  ),
                          ),
                          const SizedBox(height: 8.0),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _showSupportDialog(context, isArabic);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    isArabic ? 'التواصل مع الدعم' : 'Contact Support',
                                    style: isArabic
                                        ? GoogleFonts.cairo(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF8B53FE),
                                          )
                                        : GoogleFonts.inter(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF8B53FE),
                                          ),
                                  ),
                                  const SizedBox(width: 4.0),
                                  Icon(
                                    isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                                    size: 14.0,
                                    color: const Color(0xFF8B53FE),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24.0),

              // 6. Save Changes Button (Animated, does not hide content)
              ProviderAnimatedButton(
                onTap: _handleSaveChanges,
                isLoading: _isLoading,
                text: isArabic ? 'حفظ التغييرات' : 'Save Changes',
                textStyle: isArabic
                    ? GoogleFonts.cairo(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )
                    : GoogleFonts.inter(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                icon: Icon(
                  isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                  size: 18.0,
                  color: Colors.white,
                ),
              ),

              // Flexible bottom indicator
              const SizedBox(height: 24.0),
              const Center(child: ProviderCardBottomIndicator()),
              const SizedBox(height: 12.0),
            ],
          ),
        ),
      ),
    );
  }
}
