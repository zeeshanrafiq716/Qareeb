import 'package:flutter/material.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Profile Input Field Widget
/// Implements exact Figma branding specifications:
///
/// input field layout:
///   height: 48;
///   gap: 12px;
///   border-radius: 12px;
///   padding: 16px 20px;
///   background: #F2F5F4;
///
/// label branding:
///   Inter 500 (Medium) 12px line-height 22px #1C2926;
///   optional span: Inter 400 (Regular) 12px line-height 22px #566663;
class ProviderProfileInputField extends StatelessWidget {
  final String label;
  final String? labelSpan;
  final String placeholder;
  final TextEditingController? controller;
  final Widget? icon;
  final Widget? suffixIcon;
  final double? width;
  final double height;
  final double inputHeight;
  final TextInputType keyboardType;
  final VoidCallback? onTap;
  final bool readOnly;

  const ProviderProfileInputField({
    super.key,
    required this.label,
    this.labelSpan,
    required this.placeholder,
    this.controller,
    this.icon,
    this.suffixIcon,
    this.width = double.infinity,
    this.height = 69.0,
    this.inputHeight = 48.0,
    this.keyboardType = TextInputType.text,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Label branding: Inter 500 Medium 12px #1C2926, optional span: Inter 400 #566663
          if (labelSpan != null)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: label,
                    style: ProviderTextStyles.profileInputLabel,
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: labelSpan,
                    style: ProviderTextStyles.profileInputLabelSpan,
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          else
            Text(
              label,
              style: ProviderTextStyles.profileInputLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

          const SizedBox(height: 8.0),

          // Input field container (width: 100%, height: 48, radius: 12, background: #F2F5F4, padding: 16px 20px)
          Container(
            width: double.infinity,
            height: inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              color: ProviderColors.inputBackground, // #F2F5F4
              borderRadius: BorderRadius.circular(12.0), // border-radius: 12px
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon branding: width: 16; height: 16; border: 1px solid #566663
                if (icon != null) ...[
                  SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: Center(child: icon),
                  ),
                  const SizedBox(width: 12.0), // gap: 12px
                ],

                // Text field content (Inter 400 Regular 14px line-height 22px #1C2926 / placeholder: #566663)
                Expanded(
                  child: TextField(
                    controller: controller,
                    readOnly: readOnly,
                    onTap: onTap,
                    keyboardType: keyboardType,
                    style: ProviderTextStyles.profileInputText,
                    cursorColor: ProviderColors.primaryButton,
                    decoration: InputDecoration(
                      hintText: placeholder,
                      hintStyle: ProviderTextStyles.profileInputPlaceholder,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                // Trailing suffix icon (e.g. dropdown chevron)
                if (suffixIcon != null) ...[
                  const SizedBox(width: 12.0),
                  suffixIcon!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
