import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_profile_input_field.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_profile_input_icons.dart';

/// Provider Profile Personal Information (1st Part Layout)
/// Implements exact Figma branding specifications:
///
/// 1st part layout:
///   width: 350;
///   height: 158;
///   gap: 20px;
///   angle: 0 deg;
///   opacity: 1;
///
/// Row 1: Full Name (as per Iqama)
///   width: 350; height: 69;
///   input: height: 48, radius: 12, padding: 16px 20px, bg: #F2F5F4, placeholder: Hassan Raza
///   icon: Person outline 16x16
///
/// gap: 20px;
///
/// Row 2: 2nd row layout: width: 350; height: 69; gap: 16px;
///   Card 1: Iqama Number (width: 183, height: 69, placeholder: 2487654321, icon: IdCard outline)
///   gap: 16px;
///   Card 2: Iqama Expiry Date (width: 151, height: 69, placeholder: DD/MM/YYY, icon: Calendar outline)
class ProviderProfilePersonalInfoPart1 extends StatefulWidget {
  final TextEditingController? nameController;
  final TextEditingController? iqamaController;
  final TextEditingController? expiryController;

  const ProviderProfilePersonalInfoPart1({
    super.key,
    this.nameController,
    this.iqamaController,
    this.expiryController,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 158.0;
  static const double designGap = 20.0;

  @override
  State<ProviderProfilePersonalInfoPart1> createState() =>
      _ProviderProfilePersonalInfoPart1State();
}

class _ProviderProfilePersonalInfoPart1State
    extends State<ProviderProfilePersonalInfoPart1> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _iqamaCtrl;
  late final TextEditingController _expiryCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = widget.nameController ?? TextEditingController();
    _iqamaCtrl = widget.iqamaController ?? TextEditingController();
    _expiryCtrl = widget.expiryController ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.nameController == null) _nameCtrl.dispose();
    if (widget.iqamaController == null) _iqamaCtrl.dispose();
    if (widget.expiryController == null) _expiryCtrl.dispose();
    super.dispose();
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
              // 1. Row 1: Full Name (as per Iqama) - width: double.infinity; height: 69;
              ProviderProfileInputField(
                label: context.l10n.fullNameLabel,
                labelSpan: context.l10n.asPerIqama,
                placeholder: context.l10n.fullNamePlaceholder,
                controller: _nameCtrl,
                width: double.infinity,
                icon: const PersonOutlineIconWidget(),
              ),

              // Gap: 20px
              const SizedBox(height: ProviderProfilePersonalInfoPart1.designGap),

              // 2. Row 2: Adaptive Iqama Number + Expiry Date without overflow
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2nd row 1st card: Iqama Number (proportional flex: 54)
                  Expanded(
                    flex: 54,
                    child: ProviderProfileInputField(
                      label: context.l10n.iqamaNumberLabel,
                      placeholder: '2487654321',
                      controller: _iqamaCtrl,
                      width: double.infinity,
                      keyboardType: TextInputType.number,
                      icon: const IdCardOutlineIconWidget(),
                    ),
                  ),

                  // gap: 12px
                  const SizedBox(width: 12.0),

                  // 2nd row 2nd card: Iqama Expiry Date (proportional flex: 46)
                  Expanded(
                    flex: 46,
                    child: ProviderProfileInputField(
                      label: context.l10n.iqamaExpiryDateLabel,
                      placeholder: context.isArabic ? 'يوم/شهر/سنة' : 'DD/MM/YYYY',
                      controller: _expiryCtrl,
                      width: double.infinity,
                      keyboardType: TextInputType.datetime,
                      icon: const CalendarOutlineIconWidget(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
