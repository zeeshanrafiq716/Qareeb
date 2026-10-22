import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_continue_button.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_profile_input_field.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_profile_input_icons.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_profile_section_heading.dart';

/// Provider Profile Contact Information (2nd Part Layout)
/// Implements exact Figma branding specifications:
///
/// 2nd part layout:
///   width: 350;
///   height: 188;
///   gap: 20px;
///   angle: 0 deg;
///   opacity: 1;
///
/// heading branding: Contact Information
///   - width: 350, height: 10, gap: 12px, Inter 500 Medium 14px #1C2926
///
/// input fields branding:
///   - label branding: same (Inter 500 Medium 12px, optional span: Inter 400 12px)
///   - input field width: 100% (350 / double.infinity)
///   - gap: 20px between fields
///
/// continue button branding:
///   - width: 100% (350 / double.infinity)
///   - height: 52px, radius: 12px, background: #1D8070
///   - text: Continue (Inter 500 Medium 14px #FFFFFF), gap: 12px, arrow: 14x12
class ProviderProfileContactInfoPart2 extends StatelessWidget {
  final Widget? heading;
  final Widget? content;
  final List<Widget>? fields;
  final TextEditingController? phoneController;
  final TextEditingController? whatsappController;
  final Widget? actionButton;
  final VoidCallback? onContinue;

  const ProviderProfileContactInfoPart2({
    super.key,
    this.heading,
    this.content,
    this.fields,
    this.phoneController,
    this.whatsappController,
    this.actionButton,
    this.onContinue,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 188.0;
  static const double designGap = 20.0;
  static const double buttonGap = 24.0;

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
              // Heading with same branding of contact information
              heading ??
                  ProviderProfileSectionHeading(
                    title: context.l10n.contactInformationHeading,
                  ),

              // gap: 20px
              const SizedBox(height: designGap),

              // Content / Fields slot (100% width inputs matching user screenshot)
              if (content != null)
                content!
              else if (fields != null && fields!.isNotEmpty)
                ..._buildSeparatedFields()
              else ...[
                // 1. Phone Number Input (width: 100%, height: 48, icon: Phone receiver outline)
                ProviderProfileInputField(
                  label: context.l10n.phoneNumberLabel,
                  placeholder: '+966 48 125 5637',
                  controller: phoneController,
                  width: double.infinity,
                  keyboardType: TextInputType.phone,
                  icon: const PhoneOutlineIconWidget(),
                ),

                // gap: 20px
                const SizedBox(height: designGap),

                // 2. WhatsApp number (Optional) Input (width: 100%, height: 48, icon: WhatsApp outline)
                ProviderProfileInputField(
                  label: context.l10n.whatsappNumberLabel,
                  labelSpan: context.l10n.optionalLabel,
                  placeholder: '+966 50 123 4567',
                  controller: whatsappController,
                  width: double.infinity,
                  keyboardType: TextInputType.phone,
                  icon: const WhatsAppOutlineIconWidget(),
                ),

                // gap: 24px
                const SizedBox(height: buttonGap),

                // 3. Continue button with same branding: width: 100%, height: 52, radius: 12, bg: #1D8070, text: Continue ->
                actionButton ??
                    ProviderContinueButton(
                      onTap: onContinue,
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSeparatedFields() {
    final List<Widget> items = [];
    final list = fields!;
    for (int i = 0; i < list.length; i++) {
      items.add(list[i]);
      if (i < list.length - 1) {
        items.add(const SizedBox(height: designGap));
      }
    }
    return items;
  }
}
