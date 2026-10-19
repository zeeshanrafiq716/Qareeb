import 'package:flutter/material.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Profile Section Heading Widget
/// Implements exact Figma branding specifications:
///
/// heading branding:
///   width: 350;
///   height: 10;
///   gap: 12px;
///   angle: 0 deg;
///   opacity: 1;
///
/// content: Personal Information
///   width: 350;
///   height: 10;
///   angle: 0 deg;
///   opacity: 1;
///   font-family: Inter;
///   font-weight: 500 (Medium);
///   font-size: 14px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 22px;
///   letter-spacing: 0px;
///   color: #1C2926;
class ProviderProfileSectionHeading extends StatelessWidget {
  final String title;

  const ProviderProfileSectionHeading({
    super.key,
    this.title = 'Personal Information',
  });

  static const double designWidth = 350.0;
  static const double designHeight = 10.0;
  static const double designGap = 12.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: designWidth,
          child: Text(
            title,
            style: ProviderTextStyles.personalInformationHeading,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
