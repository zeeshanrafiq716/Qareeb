import 'package:flutter/material.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_or_divider.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_phone_input_widget.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_security_notice_row.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_whatsapp_button.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Auth Next Widget Layout (Form Section)
/// Implements exact Figma branding specifications:
///
/// next widget layout:
///   width: 350;
///   height: 280.22216796875;
///   angle: 0 deg;
///   opacity: 1;
///   gap: 20px;
///
/// 1. content: Phone Number (Inter 500 Medium 14px line-height 22px #1C2926)
/// 2. gap: 20px
/// 3. phone number widget layout: (width: 350; height: 120.22; gap: 16px)
/// 4. gap: 20px
/// 5. next layout branding (or divider: width: 300; height: 10; gap: 12px)
/// 6. gap: 20px
/// 7. button layout: Continue with WhatsApp (width: 350; height: 52; #F2F5F4)
/// 8. gap: 20px
/// 9. next row text branding (security notice: width: 186.8; height: 16; gap: 12px)
class ProviderAuthFormLayout extends StatelessWidget {
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
  static const double designHeight = 280.22216796875;
  static const double designGap = 20.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: designWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Label: "Phone Number" (14px, Medium 500, #1C2926)
              SizedBox(
                width: designWidth,
                child: Text(
                  'Phone Number',
                  style: ProviderTextStyles.phoneInputLabel,
                ),
              ),

              // Gap: 20px
              const SizedBox(height: designGap),

              // 2. Phone Number Widget Layout (1st row cards + 16px gap + Continue button)
              phoneInputSlot ?? const ProviderPhoneInputWidget(),

              // Gap: 20px
              const SizedBox(height: designGap),

              // 3. Or Divider layout (width: 300; height: 10; gap: 12px; lines: 131x1.2 #DEE0DF; "or" #566663)
              const Center(
                child: ProviderOrDivider(),
              ),

              // Gap: 20px
              const SizedBox(height: designGap),

              // 4. WhatsApp Button layout (width: 350; height: 52; #F2F5F4; "Continue with WhatsApp" + > chevron)
              actionButtonSlot ?? ProviderWhatsAppButton(onTap: onWhatsAppTap),

              // Gap: 20px
              const SizedBox(height: designGap),

              // 5. Security Notice Row (width: 186.8; height: 16; gap: 12px; lock icon + "Your Number is safe with us.")
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
