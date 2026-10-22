import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
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
              // 1. Label: "Phone Number" / "رقم الهاتف" (14px, Medium 500, #1C2926)
              SizedBox(
                width: double.infinity,
                child: Text(
                  context.l10n.phoneNumberLabel,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: ProviderTextStyles.phoneInputLabel,
                ),
              ),

              // Gap: 12px
              const SizedBox(height: 12.0),

              // 2. Phone Number Widget Layout (1st row cards + 16px gap + Continue button)
              phoneInputSlot ?? const ProviderPhoneInputWidget(),

              // Gap: 16px
              const SizedBox(height: 16.0),

              // 3. Or Divider layout (lines on left and right + "or" centered)
              const ProviderOrDivider(),

              // Gap: 16px
              const SizedBox(height: 16.0),

              // 4. WhatsApp Button layout (width: double.infinity; height: 52; #F2F5F4)
              actionButtonSlot ?? ProviderWhatsAppButton(onTap: onWhatsAppTap),

              // Gap: 16px
              const SizedBox(height: 16.0),

              // 5. Security Notice Row (lock icon + "Your Number is safe with us.")
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
