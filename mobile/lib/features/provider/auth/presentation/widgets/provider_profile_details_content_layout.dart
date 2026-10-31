import 'package:flutter/material.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/data/provider_registration_state.dart';
import 'package:mobile/features/provider/auth/presentation/vehicle_service_details_screen.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_bottom_indicator.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_profile_contact_info_part2.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_profile_personal_info_part1.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_profile_section_heading.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/services/backend_service.dart';

/// Provider Profile Details Content Layout Widget
/// Implements exact Figma branding specifications:
///
/// provider profile screen next widget layout:
///   width: 350;
///   height: 400;
///   top: 152px;
///   left: 20px;
///   gap: 24px;
///   angle: 0 deg;
///   opacity: 1;
///
/// 1. heading branding:
///   width: 350; height: 10; gap: 12px;
///   content: Personal Information (Inter 500 14px #1C2926)
///
/// 2. 1st part layout:
///   width: 350; height: 158; gap: 20px;
///   Row 1: Full Name (as per Iqama) [350x69]
///   Row 2: Iqama Number [183x69] + Iqama Expiry Date [151x69]
///
/// 3. 2nd part layout:
///   width: 350; height: 188; gap: 20px;
///   Heading: Contact Information (Inter 500 14px #1C2926)
///
/// 4. Future form parts with gap: 24px;
class ProviderProfileDetailsContentLayout extends StatefulWidget {
  final Widget? heading;
  final List<Widget>? formFields;
  final Widget? firstPart;
  final Widget? secondPart;
  final List<Widget>? remainingParts;

  const ProviderProfileDetailsContentLayout({
    super.key,
    this.heading,
    this.formFields,
    this.firstPart,
    this.secondPart,
    this.remainingParts,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 400.0;
  static const double designTop = 152.0;
  static const double designLeft = 20.0;
  static const double designGap = 24.0;

  @override
  State<ProviderProfileDetailsContentLayout> createState() =>
      _ProviderProfileDetailsContentLayoutState();
}

class _ProviderProfileDetailsContentLayoutState
    extends State<ProviderProfileDetailsContentLayout> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _iqamaCtrl;
  late final TextEditingController _expiryCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _whatsappCtrl;
  bool _isLoading = false;
  late final BackendService _backendService;

  @override
  void initState() {
    super.initState();
    final savedData = ProviderRegistrationStore.instance.data;
    _nameCtrl = TextEditingController(text: savedData.fullName);
    _iqamaCtrl = TextEditingController(text: savedData.iqamaNumber);
    _expiryCtrl = TextEditingController(text: savedData.iqamaExpiry);
    _phoneCtrl = TextEditingController(
      text: savedData.contactPhone.isNotEmpty
          ? savedData.contactPhone
          : savedData.phone,
    );
    _whatsappCtrl = TextEditingController(text: savedData.whatsappNumber);
    _backendService = BackendService(ApiClient());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _iqamaCtrl.dispose();
    _expiryCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_isLoading) return;

    final isArabic = context.isArabic;
    final name = _nameCtrl.text.trim();
    final iqama = _iqamaCtrl.text.trim();
    final expiry = _expiryCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final whatsapp = _whatsappCtrl.text.trim();

    // 1. Validation for Full Name
    if (name.isEmpty) {
      _showFeedback(
        isArabic
            ? 'يرجى إدخال الاسم الكامل كما هو مدون في الإقامة'
            : 'Please enter your full name as per Iqama',
      );
      return;
    }

    // 2. Validation for Iqama Number
    if (iqama.isEmpty) {
      _showFeedback(
        isArabic
            ? 'يرجى إدخال رقم الإقامة / الهوية الوطنية'
            : 'Please enter your Iqama / National ID number',
      );
      return;
    }

    // 3. Validation for Iqama Expiry Date
    if (expiry.isEmpty) {
      _showFeedback(
        isArabic
            ? 'يرجى إدخال تاريخ انتهاء الإقامة'
            : 'Please enter Iqama expiry date',
      );
      return;
    }

    // 4. Validation for Phone Number
    if (phone.isEmpty) {
      _showFeedback(
        isArabic ? 'يرجى إدخال رقم الهاتف' : 'Please enter your phone number',
      );
      return;
    }

    setState(() => _isLoading = true);

    // Persist to central registration store
    ProviderRegistrationStore.instance.update(
      (data) => data.copyWith(
        fullName: name,
        iqamaNumber: iqama,
        iqamaExpiry: expiry,
        contactPhone: phone,
        whatsappNumber: whatsapp,
        status: 'PENDING_PROFILE',
      ),
    );

    // Call backend API to update provider profile
    await _backendService.updateProviderProfile(
      name: name,
      categoryId: '1',
      address: '',
      city: '',
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    _showFeedback(
      isArabic
          ? 'تم حفظ المعلومات الشخصية وبيانات الاتصال بنجاح'
          : 'Personal and contact information saved successfully',
      isSuccess: true,
    );

    // Navigate to next onboarding step: Vehicle & Service Details
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Heading Branding: Personal Information
              widget.heading ?? const ProviderProfileSectionHeading(),

              // Gap: 24px
              const SizedBox(height: ProviderProfileDetailsContentLayout.designGap),

              // 2. 1st Part Layout: Full Name + Iqama Number + Iqama Expiry Date
              widget.firstPart ??
                  ProviderProfilePersonalInfoPart1(
                    nameController: _nameCtrl,
                    iqamaController: _iqamaCtrl,
                    expiryController: _expiryCtrl,
                  ),

              // Gap: 24px
              const SizedBox(height: ProviderProfileDetailsContentLayout.designGap),

              // 3. 2nd Part Layout: Contact Information
              widget.secondPart ??
                  ProviderProfileContactInfoPart2(
                    phoneController: _phoneCtrl,
                    whatsappController: _whatsappCtrl,
                    onContinue: _handleContinue,
                  ),

              // Future Form Parts with gap: 24px
              if ((widget.remainingParts != null && widget.remainingParts!.isNotEmpty) ||
                  (widget.formFields != null && widget.formFields!.isNotEmpty)) ...[
                const SizedBox(height: ProviderProfileDetailsContentLayout.designGap),
                ..._buildSeparatedParts(),
              ],

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

  List<Widget> _buildSeparatedParts() {
    final List<Widget> items = [];
    final list = widget.remainingParts ?? widget.formFields ?? const [];
    for (int i = 0; i < list.length; i++) {
      items.add(list[i]);
      if (i < list.length - 1) {
        items.add(const SizedBox(height: ProviderProfileDetailsContentLayout.designGap));
      }
    }
    return items;
  }
}
