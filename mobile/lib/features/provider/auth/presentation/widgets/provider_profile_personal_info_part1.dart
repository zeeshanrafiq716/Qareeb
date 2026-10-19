import 'package:flutter/material.dart';
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
          width: ProviderProfilePersonalInfoPart1.designWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Row 1: Full Name (as per Iqama) - width: 350; height: 69;
              ProviderProfileInputField(
                label: 'Full Name',
                labelSpan: '(as per Iqama)',
                placeholder: 'Hassan Raza',
                controller: _nameCtrl,
                width: 350.0,
                icon: const PersonOutlineIconWidget(),
              ),

              // Gap: 20px
              const SizedBox(height: ProviderProfilePersonalInfoPart1.designGap),

              // 2. Row 2: width: 350; height: 69; gap: 16px;
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2nd row 1st card: Iqama Number (width: 183; height: 69)
                  ProviderProfileInputField(
                    label: 'Iqama Number',
                    placeholder: '2487654321',
                    controller: _iqamaCtrl,
                    width: 183.0,
                    keyboardType: TextInputType.number,
                    icon: const IdCardOutlineIconWidget(),
                  ),

                  // gap: 16px
                  const SizedBox(width: 16.0),

                  // 2nd row 2nd card: Iqama Expiry Date (width: 151; height: 69)
                  ProviderProfileInputField(
                    label: 'Iqama Expiry Date',
                    placeholder: 'DD/MM/YYY',
                    controller: _expiryCtrl,
                    width: 151.0,
                    keyboardType: TextInputType.datetime,
                    icon: const CalendarOutlineIconWidget(),
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
