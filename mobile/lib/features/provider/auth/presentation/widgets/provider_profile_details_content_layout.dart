import 'package:flutter/material.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_bottom_indicator.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_profile_contact_info_part2.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_profile_personal_info_part1.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_profile_section_heading.dart';

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
class ProviderProfileDetailsContentLayout extends StatelessWidget {
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
              heading ?? const ProviderProfileSectionHeading(),

              // Gap: 24px
              const SizedBox(height: designGap),

              // 2. 1st Part Layout: Full Name + Iqama Number + Iqama Expiry Date
              firstPart ?? const ProviderProfilePersonalInfoPart1(),

              // Gap: 24px
              const SizedBox(height: designGap),

              // 3. 2nd Part Layout: Contact Information (width: 350, height: 188, gap: 20px)
              secondPart ?? const ProviderProfileContactInfoPart2(),

              // Future Form Parts with gap: 24px
              if ((remainingParts != null && remainingParts!.isNotEmpty) ||
                  (formFields != null && formFields!.isNotEmpty)) ...[
                const SizedBox(height: designGap),
                ..._buildSeparatedParts(),
              ],

              // Flexible bottom indicator: scrolls naturally at the end of the content
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
    final list = remainingParts ?? formFields ?? const [];
    for (int i = 0; i < list.length; i++) {
      items.add(list[i]);
      if (i < list.length - 1) {
        items.add(const SizedBox(height: designGap));
      }
    }
    return items;
  }
}
