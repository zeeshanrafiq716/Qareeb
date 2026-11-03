import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/data/provider_registration_state.dart';

/// Provider Vehicle Info Card Widget
/// Implements exact Figma branding specifications:
///
/// next card branding:
///   width: 350;
///   height: 150;
///   gap: 10px;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 12px;
///   padding: 16px;
///   box-shadow: 0px 1px 12px 0px #0000001A;
///   background: #FFFFFF;
///
/// card inner branding:
///   width: 318;
///   height: 118;
///   gap: 16px;
///   angle: 0 deg;
///   opacity: 1;
///
/// row 1 branding:
///   width: 318;
///   height: 53;
///   justify-content: space-between;
///   angle: 0 deg;
///   opacity: 1;
///
/// content branding:
///   width: 175;
///   height: 33;
///   gap: 12px;
///   angle: 0 deg;
///   opacity: 1;
///
/// content: Flatbed Truck
///   width: 106;
///   height: 12;
///   angle: 0 deg;
///   opacity: 1;
///   font-family: Inter;
///   font-weight: 500;
///   font-style: Medium;
///   font-size: 16px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 22px;
///   letter-spacing: 0px;
///   background: #252527;
///
/// Available for Pickup & Delivery
///   width: 175;
///   height: 9;
///   angle: 0 deg;
///   opacity: 1;
///   font-family: Inter;
///   font-weight: 400;
///   font-style: Regular;
///   font-size: 12px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 22px;
///   letter-spacing: 0px;
///   background: #616166;
///
/// img branding:
///   width: 106;
///   height: 53;
///   angle: 0 deg;
///   opacity: 1;
///   img is truk.png
///
/// border bottom:
///   width: 318;
///   height: 1;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 24px;
///   background: #E6EBE8;
///
/// row 2 branding:
///   width: 318;
///   height: 32;
///   gap: 16px;
///   angle: 0 deg;
///   opacity: 1;
///
/// row 2 1st part branding:
///   width: 109;
///   height: 32;
///   gap: 12px;
///   angle: 0 deg;
///   opacity: 1;
///
/// icon branding:
///   width: 32;
///   height: 32;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 8px;
///   background: #F3F2F5;
///
/// content layout:
///   width: 65;
///   height: 24;
///   gap: 10px;
///   angle: 0 deg;
///   opacity: 1;
///
/// Plate Number
///   width: 65;
///   height: 7;
///   angle: 0 deg;
///   opacity: 1;
///   font-family: Inter;
///   font-weight: 400;
///   font-style: Regular;
///   font-size: 10px;
///   leading-trim: CAP_HEIGHT;
///   line-height: 22px;
///   letter-spacing: 0px;
///   background: #616166;
///
/// 2nd row 2nd part layout:
///   width: 128;
///   height: 32;
///   gap: 12px;
///   angle: 0 deg;
///   opacity: 1;
class ProviderVehicleCard extends ConsumerWidget {
  final String? vehicleName;
  final String? availabilityText;
  final String? plateNumber;
  final String? categoryText;
  final String? imagePath;
  final VoidCallback? onTap;

  const ProviderVehicleCard({
    super.key,
    this.vehicleName,
    this.availabilityText,
    this.plateNumber,
    this.categoryText,
    this.imagePath,
    this.onTap,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 150.0;
  static const double innerWidth = 318.0;
  static const double innerHeight = 118.0;
  static const double innerPadding = 16.0;

  static String _resolveVehicleImage(String vehicleType) {
    final lower = vehicleType.toLowerCase();
    if (lower.contains('pickup')) {
      return 'assets/images/pickup.png';
    } else if (lower.contains('van')) {
      return 'assets/images/van.png';
    } else if (lower.contains('bike') || lower.contains('motorcycle')) {
      return 'assets/images/rider_bike.png';
    } else if (lower.contains('car') || lower.contains('sedan') || lower.contains('ride')) {
      return 'assets/images/car.png';
    } else if (lower.contains('tow') || lower.contains('recovery')) {
      return 'assets/images/towing.png';
    }
    return 'assets/images/flatbed_truck.png';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isArabic = context.isArabic;
    final registrationData = ref.watch(providerRegistrationProvider);
    final storeData = ProviderRegistrationStore.instance.data;

    // 1. Vehicle Name / Type (from onboarding store or explicit param)
    final String rawVehicleType = (vehicleName != null && vehicleName!.isNotEmpty)
        ? vehicleName!
        : (registrationData.vehicleType.isNotEmpty
            ? registrationData.vehicleType
            : (storeData.vehicleType.isNotEmpty
                ? storeData.vehicleType
                : ''));
    final String effectiveVehicleName = rawVehicleType.isNotEmpty
        ? (isArabic ? context.auto(rawVehicleType) : rawVehicleType)
        : (isArabic ? 'شاحنة مسطحة' : 'Flatbed Truck');

    // 2. Service Category (from onboarding store or explicit param)
    final String rawCategory = (categoryText != null && categoryText!.isNotEmpty)
        ? categoryText!
        : (registrationData.serviceCategory.isNotEmpty
            ? registrationData.serviceCategory
            : (storeData.serviceCategory.isNotEmpty
                ? storeData.serviceCategory
                : ''));
    final String effectiveCategory = rawCategory.isNotEmpty
        ? (isArabic ? context.auto(rawCategory) : rawCategory)
        : (isArabic ? 'استلام وتوصيل' : 'Pickup & Delivery');

    // 3. Availability Text
    final String effectiveAvailability;
    if (availabilityText != null && availabilityText!.isNotEmpty) {
      effectiveAvailability = availabilityText!;
    } else if (rawCategory.isNotEmpty) {
      effectiveAvailability = isArabic
          ? 'متاح لـ $effectiveCategory'
          : 'Available for $effectiveCategory';
    } else {
      effectiveAvailability = isArabic
          ? 'متاح للاستلام والتوصيل'
          : 'Available for Pickup & Delivery';
    }

    // 4. Plate Number (from onboarding store or explicit param)
    final String rawPlateNumber = (plateNumber != null && plateNumber!.isNotEmpty)
        ? plateNumber!
        : (registrationData.plateNumber.isNotEmpty
            ? registrationData.plateNumber
            : (storeData.plateNumber.isNotEmpty
                ? storeData.plateNumber
                : ''));
    final String effectivePlateNumber = rawPlateNumber.isNotEmpty
        ? rawPlateNumber
        : (isArabic ? 'أ ١٢٣٤' : 'A 1234');

    final String effectivePlateLabel = isArabic ? 'رقم اللوحة' : 'Plate Number';
    final String effectiveCategoryLabel = isArabic ? 'الفئة' : 'Category';

    // 5. Dynamic Vehicle Image matching vehicle type or category
    final String effectiveImagePath = (imagePath != null && imagePath!.isNotEmpty)
        ? imagePath!
        : _resolveVehicleImage(rawVehicleType.isNotEmpty ? rawVehicleType : rawCategory);

    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: Container(
          width: double.infinity, // stretch full available width
          constraints: const BoxConstraints(minHeight: designHeight), // minHeight: 150
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF), // background: #FFFFFF
            borderRadius: BorderRadius.circular(12.0), // border-radius: 12px
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000), // box-shadow: 0px 1px 12px 0px #0000001A
                offset: Offset(0, 1),
                blurRadius: 12.0,
                spreadRadius: 0.0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12.0),
              child: Padding(
                padding: const EdgeInsets.all(innerPadding), // padding: 16px
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. row 1 branding: width: 318; height: 53; justify-content: space-between;
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 53.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // justify-content: space-between
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // content branding: width: 175; height: 33; gap: 12px;
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // content: Real vehicle type from onboarding (no ellipsis / ...)
                                  Opacity(
                                    opacity: 1.0,
                                    child: Transform.rotate(
                                      angle: 0.0,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: AlignmentDirectional.centerStart,
                                        child: Text(
                                          effectiveVehicleName,
                                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF252527),
                                            height: isArabic ? 1.05 : 1.15,
                                            letterSpacing: 0.0,
                                          ),
                                          textHeightBehavior: const TextHeightBehavior(
                                            applyHeightToFirstAscent: false,
                                            applyHeightToLastDescent: false,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: isArabic ? 1.0 : 5.0),

                                  // Available for [Category] (or real category from onboarding)
                                  Opacity(
                                    opacity: 1.0,
                                    child: Transform.rotate(
                                      angle: 0.0,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: AlignmentDirectional.centerStart,
                                        child: Text(
                                          effectiveAvailability,
                                          style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w400,
                                            color: const Color(0xFF616166),
                                            height: isArabic ? 1.0 : 1.1,
                                            letterSpacing: 0.0,
                                          ),
                                          textHeightBehavior: const TextHeightBehavior(
                                            applyHeightToFirstAscent: false,
                                            applyHeightToLastDescent: false,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // img branding: width: 106; height: 53; img is dynamic vehicle asset or photo
                            Opacity(
                              opacity: 1.0,
                              child: Transform.rotate(
                                angle: 0.0,
                                child: _buildVehicleImage(effectiveImagePath),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12.0),

                      // border bottom: width: 318; height: 1; border-radius: 24px; background: #E6EBE8;
                      Opacity(
                        opacity: 1.0,
                        child: Container(
                          width: innerWidth,
                          height: 1.0,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6EBE8), // background: #E6EBE8
                            borderRadius: BorderRadius.circular(24.0), // border-radius: 24px
                          ),
                        ),
                      ),

                      const SizedBox(height: 12.0),

                      // 2. row 2 branding: width: 318; height: 32; gap: 16px;
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 32.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // row 2 1st part branding: Plate Number
                            _buildInfoPart(
                              isArabic: isArabic,
                              icon: Icons.directions_car_outlined,
                              label: effectivePlateLabel,
                              value: effectivePlateNumber,
                            ),

                            // Subtle vertical separator line between Part 1 and Part 2 matching screenshot
                            Container(
                              width: 1.0,
                              height: 24.0,
                              margin: const EdgeInsets.symmetric(horizontal: 14.0),
                              color: const Color(0xFFE6EBE8),
                            ),

                            // 2nd row 2nd part layout: Category
                            Expanded(
                              child: _buildInfoPart(
                                isArabic: isArabic,
                                icon: Icons.directions_car_outlined,
                                label: effectiveCategoryLabel,
                                value: effectiveCategory,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleImage(String path) {
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: 106.0,
        height: 53.0,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const SizedBox(
          width: 106.0,
          height: 53.0,
          child: Center(
            child: Icon(
              Icons.local_shipping_rounded,
              size: 40.0,
              color: Color(0xFF8B53FE),
            ),
          ),
        ),
      );
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: 106.0,
        height: 53.0,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const SizedBox(
          width: 106.0,
          height: 53.0,
          child: Center(
            child: Icon(
              Icons.local_shipping_rounded,
              size: 40.0,
              color: Color(0xFF8B53FE),
            ),
          ),
        ),
      );
    }

    return Image.file(
      File(path),
      width: 106.0,
      height: 53.0,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const SizedBox(
        width: 106.0,
        height: 53.0,
        child: Center(
          child: Icon(
            Icons.local_shipping_rounded,
            size: 40.0,
            color: Color(0xFF8B53FE),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPart({
    required bool isArabic,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // icon branding: width: 32; height: 32; border-radius: 8px; background: #F3F2F5;
        Opacity(
          opacity: 1.0,
          child: Transform.rotate(
            angle: 0.0,
            child: Container(
              width: 32.0,
              height: 32.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F2F5), // background: #F3F2F5
                borderRadius: BorderRadius.circular(8.0), // border-radius: 8px
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 18.0,
                  color: const Color(0xFF252527),
                ),
              ),
            ),
          ),
        ),

        // gap: 10px
        const SizedBox(width: 10.0),

        // content layout: Flexible column preventing overflow
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label (Plate Number / Category): font-size: 10px; color: #616166;
              Opacity(
                opacity: 1.0,
                child: Transform.rotate(
                  angle: 0.0,
                  child: Text(
                    label,
                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF616166), // color: #616166
                      height: isArabic ? 1.0 : 1.1,
                      letterSpacing: 0.0,
                    ),
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              SizedBox(height: isArabic ? 0.0 : 2.0),

              // Value (A 1234 / Pickup & Delivery): font-size: 12px; color: #252527; font-weight: 500;
              Opacity(
                opacity: 1.0,
                child: Transform.rotate(
                  angle: 0.0,
                  child: Text(
                    value,
                    style: (isArabic ? GoogleFonts.cairo : GoogleFonts.inter)(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF252527), // color: #252527
                      height: isArabic ? 1.05 : 1.15,
                      letterSpacing: 0.0,
                    ),
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
