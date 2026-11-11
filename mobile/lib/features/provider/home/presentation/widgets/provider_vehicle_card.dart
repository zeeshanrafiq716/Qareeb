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

  static String _formatCategoryName(String rawCategory, {required bool isArabic}) {
    final lower = rawCategory.toLowerCase().trim();
    if (lower.isEmpty) return isArabic ? 'عام' : 'General';

    if (lower.contains('tow') || lower.contains('سطحة')) {
      return isArabic ? 'سطحة سحب ونقل' : 'Tow Truck';
    }
    if (lower.contains('tyre') || lower.contains('tire') || lower.contains('puncture') || lower.contains('بنشر') || lower.contains('كاوتش')) {
      return isArabic ? 'إصلاح وصيانة الإطارات' : 'Tyre & Puncture Repair';
    }
    if (lower.contains('water') || lower.contains('tank') || lower.contains('صهريج') || lower.contains('مياه')) {
      if (lower.contains('small') || lower.contains('صغير')) {
        return isArabic ? 'صهريج مياه صغير' : 'Small Water Tanker';
      }
      return isArabic ? 'صهريج مياه' : 'Water Tanker';
    }
    if (lower.contains('fuel') || lower.contains('وقود') || lower.contains('بنزين')) {
      return isArabic ? 'توصيل وقود' : 'Fuel Delivery';
    }
    if (lower.contains('mechanic') || lower.contains('ميكانيك')) {
      return isArabic ? 'ميكانيكا سيارات' : 'Car Mechanic';
    }
    if (lower.contains('battery') || lower.contains('بطارية') || lower.contains('jump')) {
      return isArabic ? 'شحن واشتراك بطاريات' : 'Battery Jump Start';
    }
    if (lower.contains('small_pickup') || (lower.contains('pickup') && lower.contains('small')) || lower.contains('دينا صغيرة')) {
      return isArabic ? 'دينا نقل صغيرة' : 'Small Pickup (Dyna)';
    }
    if (lower.contains('large_pickup') || (lower.contains('pickup') && lower.contains('large')) || lower.contains('دينا كبيرة')) {
      return isArabic ? 'دينا نقل كبيرة' : 'Large Pickup (Dyna)';
    }
    if (lower.contains('ac') || lower.contains('hvac') || lower.contains('مكيف')) {
      return isArabic ? 'صيانة تكييف' : 'AC Technician';
    }
    if (lower.contains('electric') || lower.contains('كهرب')) {
      return isArabic ? 'أعمال كهرباء' : 'Electrician';
    }
    if (lower.contains('plumb') || lower.contains('سباك')) {
      return isArabic ? 'سباكة وصحية' : 'Plumber';
    }
    if (lower.contains('clean') || lower.contains('تنظيف')) {
      return isArabic ? 'تنظيف منزلي' : 'House Cleaning';
    }
    if (lower.contains('wash') || lower.contains('غسال')) {
      return isArabic ? 'صيانة غسالات' : 'Washing Machine Tech';
    }
    if (lower.contains('refrig') || lower.contains('fridge') || lower.contains('ثلاج')) {
      return isArabic ? 'صيانة ثلاجات' : 'Refrigerator Tech';
    }
    if (lower.contains('appliance') || lower.contains('أجهزة')) {
      return isArabic ? 'أجهزة منزلية' : 'Appliance Technician';
    }
    if (lower.contains('tile') || lower.contains('ceramic') || lower.contains('بلاط') || lower.contains('سيراميك')) {
      return isArabic ? 'بلاط وسيراميك' : 'Tiles & Ceramic';
    }
    if (lower.contains('carpent') || lower.contains('wood') || lower.contains('نجار')) {
      return isArabic ? 'أعمال نجارة' : 'Carpenter';
    }
    if (lower.contains('paint') || lower.contains('دهان')) {
      return isArabic ? 'دهانات وديكور' : 'Painter';
    }
    if (lower.contains('pest') || lower.contains('حشرات')) {
      return isArabic ? 'مكافحة حشرات' : 'Pest Control';
    }
    if (lower.contains('network') || lower.contains('wifi') || lower.contains('شبك')) {
      return isArabic ? 'شبكات وإنترنت' : 'Network Technician';
    }
    if (lower.contains('cctv') || lower.contains('camera') || lower.contains('كامير')) {
      return isArabic ? 'كاميرات مراقبة' : 'CCTV Technician';
    }
    if (lower.contains('curtain') || lower.contains('ستائر')) {
      return isArabic ? 'تركيب ستائر' : 'Curtain Installation';
    }
    if (lower.contains('door') || lower.contains('lock') || lower.contains('أبواب') || lower.contains('أقفال')) {
      return isArabic ? 'أبواب وأقفال ذكية' : 'Doors & Smart Locks';
    }
    if (lower.contains('construct') || lower.contains('renov') || lower.contains('بناء') || lower.contains('ترميم')) {
      return isArabic ? 'مقاولات وترميم' : 'Construction & Renovation';
    }
    if (lower.contains('pool') || lower.contains('مسبح') || lower.contains('مسابح')) {
      return isArabic ? 'صيانة مسابح' : 'Pool Maintenance';
    }
    if (lower.contains('ride') || lower.contains('sedan') || lower.contains('مشوار')) {
      return isArabic ? 'مشاوير خاصة' : 'Ride Delivery';
    }
    if (lower.contains('bike') || lower.contains('moto') || lower.contains('دراجة')) {
      return isArabic ? 'توصيل دراجات' : 'Motorbike Courier';
    }
    if (lower.contains('pickup') || lower.contains('وانيت')) {
      return isArabic ? 'وانيت نقل' : 'Pickup Delivery';
    }
    if (lower.contains('van') || lower.contains('فان')) {
      return isArabic ? 'فان بضائع' : 'Van Delivery';
    }

    return rawCategory
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ')
        .trim();
  }

  static String _resolveRealVehicleTitle(String category, {required bool isArabic}) {
    final lower = category.toLowerCase().trim();

    if (lower.contains('tow') || lower.contains('سطحة')) {
      return isArabic ? 'سطحة سحب ونقل' : 'Tow & Recovery Truck';
    }
    if (lower.contains('tyre') || lower.contains('tire') || lower.contains('puncture') || lower.contains('بنشر') || lower.contains('كاوتش')) {
      return isArabic ? 'خدمة إطارات متنقلة' : 'Mobile Tyre Service';
    }
    if (lower.contains('water') || lower.contains('tank') || lower.contains('صهريج') || lower.contains('مياه')) {
      if (lower.contains('small') || lower.contains('صغير')) {
        return isArabic ? 'صهريج مياه صغير' : 'Small Water Tanker';
      }
      return isArabic ? 'صهريج مياه' : 'Water Tanker Truck';
    }
    if (lower.contains('fuel') || lower.contains('وقود') || lower.contains('بنزين')) {
      return isArabic ? 'مركبة توصيل وقود' : 'Fuel Delivery Truck';
    }
    if (lower.contains('mechanic') || lower.contains('ميكانيك')) {
      return isArabic ? 'ورشة ميكانيكا متنقلة' : 'Mobile Mechanic Unit';
    }
    if (lower.contains('battery') || lower.contains('بطارية') || lower.contains('jump')) {
      return isArabic ? 'مركبة شحن وبطاريات' : 'Battery Service Unit';
    }
    if (lower.contains('ac') || lower.contains('hvac') || lower.contains('مكيف')) {
      return isArabic ? 'صيانة تكييف متنقلة' : 'AC Maintenance Unit';
    }
    if (lower.contains('small_pickup') || (lower.contains('pickup') && lower.contains('small')) || lower.contains('دينا صغيرة')) {
      return isArabic ? 'دينا نقل صغيرة' : 'Small Pickup (Dyna)';
    }
    if (lower.contains('large_pickup') || (lower.contains('pickup') && lower.contains('large')) || lower.contains('دينا كبيرة')) {
      return isArabic ? 'دينا نقل كبيرة' : 'Large Pickup (Dyna)';
    }
    if (lower.contains('pickup') || lower.contains('وانيت')) {
      return isArabic ? 'وانيت نقل بضائع' : 'Pickup Truck';
    }
    if (lower.contains('van') || lower.contains('فان')) {
      return isArabic ? 'فان خدمة متنقل' : 'Service Van';
    }
    if (lower.contains('electric') || lower.contains('كهرب')) {
      return isArabic ? 'ورشة كهرباء متنقلة' : 'Mobile Electrical Unit';
    }
    if (lower.contains('plumb') || lower.contains('سباك')) {
      return isArabic ? 'خدمة سباكة متنقلة' : 'Mobile Plumbing Unit';
    }
    if (lower.contains('clean') || lower.contains('تنظيف')) {
      return isArabic ? 'فريق تنظيف منزلي' : 'Home Cleaning Unit';
    }
    if (lower.contains('wash') || lower.contains('غسال')) {
      return isArabic ? 'صيانة غسالات متنقلة' : 'Washing Machine Service';
    }
    if (lower.contains('fridge') || lower.contains('refrig') || lower.contains('ثلاج')) {
      return isArabic ? 'صيانة ثلاجات متنقلة' : 'Refrigeration Service';
    }
    if (lower.contains('appliance') || lower.contains('أجهزة')) {
      return isArabic ? 'صيانة أجهزة منزلية' : 'Appliance Repair Unit';
    }
    if (lower.contains('tile') || lower.contains('ceramic') || lower.contains('بلاط') || lower.contains('سيراميك')) {
      return isArabic ? 'فريق تركيب بلاط وسيراميك' : 'Tiles & Ceramic Unit';
    }
    if (lower.contains('carpent') || lower.contains('wood') || lower.contains('نجار')) {
      return isArabic ? 'ورشة نجارة متنقلة' : 'Mobile Carpentry Unit';
    }
    if (lower.contains('paint') || lower.contains('دهان')) {
      return isArabic ? 'خدمة دهان وديكور' : 'Painting Service Unit';
    }
    if (lower.contains('pest') || lower.contains('حشرات')) {
      return isArabic ? 'مركبة مكافحة حشرات' : 'Pest Control Unit';
    }
    if (lower.contains('network') || lower.contains('wifi') || lower.contains('شبك')) {
      return isArabic ? 'فني شبكات متنقل' : 'Network Service Unit';
    }
    if (lower.contains('cctv') || lower.contains('camera') || lower.contains('كامير')) {
      return isArabic ? 'فني كاميرات ومراقبة' : 'CCTV Installation Unit';
    }
    if (lower.contains('curtain') || lower.contains('ستائر')) {
      return isArabic ? 'تركيب وتفصيل ستائر' : 'Curtain Service Unit';
    }
    if (lower.contains('door') || lower.contains('lock') || lower.contains('أبواب') || lower.contains('أقفال')) {
      return isArabic ? 'خدمة أبواب وأقفال ذكية' : 'Doors & Locks Service';
    }
    if (lower.contains('construct') || lower.contains('renov') || lower.contains('بناء') || lower.contains('ترميم')) {
      return isArabic ? 'فريق مقاولات وترميم' : 'Construction Service Unit';
    }
    if (lower.contains('pool') || lower.contains('مسبح') || lower.contains('مسابح')) {
      return isArabic ? 'صيانة وتنظيف مسابح' : 'Pool Maintenance Unit';
    }
    if (lower.contains('ride') || lower.contains('sedan') || lower.contains('مشوار')) {
      return isArabic ? 'سيارة توصيل ركاب' : 'Ride Sedan';
    }
    if (lower.contains('bike') || lower.contains('moto') || lower.contains('دراجة')) {
      return isArabic ? 'دراجة توصيل سريعة' : 'Delivery Motorbike';
    }

    return isArabic ? 'مركبة الخدمة' : 'Service Vehicle';
  }

  static String _resolveVehicleImage(String category, String vehicleType) {
    final cat = category.toLowerCase().trim();
    final veh = vehicleType.toLowerCase().trim();
    final combined = '$cat $veh';

    if (combined.contains('tow-truck') || combined.contains('tow_truck') || combined.contains('tow') || combined.contains('سطحة')) {
      return 'assets/images/tow_truck.png';
    }
    if (combined.contains('tyre') || combined.contains('tire') || combined.contains('puncture') || combined.contains('بنشر') || combined.contains('كاوتش')) {
      return 'assets/images/tyre_repair.png';
    }
    if (combined.contains('water') || combined.contains('tank') || combined.contains('صهريج') || combined.contains('مياه')) {
      if (combined.contains('small') || combined.contains('صغير')) {
        return 'assets/images/small_water_tanker.png';
      }
      return 'assets/images/large_water_tanker.png';
    }
    if (combined.contains('fuel') || combined.contains('وقود') || combined.contains('بنزين')) {
      return 'assets/images/fuel_delivery.png';
    }
    if (combined.contains('mechanic') || combined.contains('ميكانيك')) {
      return 'assets/images/car_mechanic.png';
    }
    if (combined.contains('small_pickup') || (combined.contains('pickup') && combined.contains('small')) || combined.contains('دينا صغيرة')) {
      return 'assets/images/small_pickup_dyna.png';
    }
    if (combined.contains('large_pickup') || (combined.contains('pickup') && combined.contains('large')) || combined.contains('دينا كبيرة')) {
      return 'assets/images/large_pickup_dyna.png';
    }
    if (combined.contains('battery') || combined.contains('jump') || combined.contains('بطارية')) {
      return 'assets/images/battery_jump_start.png';
    }
    if (combined.contains('ac') || combined.contains('hvac') || combined.contains('مكيف')) {
      return 'assets/images/ac_technician.png';
    }
    if (combined.contains('electric') || combined.contains('كهرب')) {
      return 'assets/images/electrician.png';
    }
    if (combined.contains('plumb') || combined.contains('سباك')) {
      return 'assets/images/plumber.png';
    }
    if (combined.contains('clean') || combined.contains('تنظيف')) {
      return 'assets/images/house_cleaning.png';
    }
    if (combined.contains('wash') || combined.contains('غسال')) {
      return 'assets/images/washing_machine_tech.png';
    }
    if (combined.contains('refrig') || combined.contains('fridge') || combined.contains('ثلاج')) {
      return 'assets/images/refrigerator_tech.png';
    }
    if (combined.contains('appliance') || combined.contains('أجهزة')) {
      return 'assets/images/appliance_technician.png';
    }
    if (combined.contains('tile') || combined.contains('ceramic') || combined.contains('بلاط') || combined.contains('سيراميك')) {
      return 'assets/images/tiles_ceramic.png';
    }
    if (combined.contains('carpent') || combined.contains('wood') || combined.contains('نجار')) {
      return 'assets/images/carpenter.png';
    }
    if (combined.contains('paint') || combined.contains('دهان')) {
      return 'assets/images/painter.png';
    }
    if (combined.contains('pest') || combined.contains('حشرات')) {
      return 'assets/images/pest_control.png';
    }
    if (combined.contains('network') || combined.contains('wifi') || combined.contains('شبك')) {
      return 'assets/images/network_technician.png';
    }
    if (combined.contains('cctv') || combined.contains('camera') || combined.contains('كامير')) {
      return 'assets/images/cctv_technician.png';
    }
    if (combined.contains('curtain') || combined.contains('ستائر')) {
      return 'assets/images/curtain_installation.png';
    }
    if (combined.contains('door') || combined.contains('lock') || combined.contains('أبواب') || combined.contains('أقفال')) {
      return 'assets/images/doors_locks.png';
    }
    if (combined.contains('construct') || combined.contains('renov') || combined.contains('بناء') || combined.contains('ترميم')) {
      return 'assets/images/construction_renovation.png';
    }
    if (combined.contains('pool') || combined.contains('مسبح') || combined.contains('مسابح')) {
      return 'assets/images/pool_maintenance.png';
    }
    if (combined.contains('ride') || combined.contains('sedan') || combined.contains('مشوار')) {
      return 'assets/images/car_ride.png';
    }
    if (combined.contains('bike') || combined.contains('moto') || combined.contains('دراجة')) {
      return 'assets/images/rider_bike.png';
    }
    if (combined.contains('pickup') || combined.contains('وانيت')) {
      return 'assets/images/pickup.png';
    }
    if (combined.contains('van') || combined.contains('فان')) {
      return 'assets/images/van.png';
    }

    return 'assets/images/tow_truck.png';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isArabic = context.isArabic;
    final registrationData = ref.watch(providerRegistrationProvider);
    final storeData = ProviderRegistrationStore.instance.data;

    // 1. Raw Category (from store, explicit param, or registration data)
    final String rawCategory = (categoryText != null && categoryText!.isNotEmpty)
        ? categoryText!
        : (registrationData.serviceCategory.isNotEmpty
            ? registrationData.serviceCategory
            : (storeData.serviceCategory.isNotEmpty
                ? storeData.serviceCategory
                : ''));
    final String cleanCategoryName = _formatCategoryName(rawCategory, isArabic: isArabic);
    final catLower = rawCategory.toLowerCase();
    final bool isTowCategory = catLower.contains('tow') || catLower.contains('سطحة');

    // 2. Raw Vehicle Model & Type
    final String rawVehicleModel = storeData.vehicleModel.isNotEmpty
        ? storeData.vehicleModel
        : registrationData.vehicleModel;

    final String rawVehicleType = (vehicleName != null && vehicleName!.isNotEmpty)
        ? vehicleName!
        : (registrationData.vehicleType.isNotEmpty
            ? registrationData.vehicleType
            : (storeData.vehicleType.isNotEmpty
                ? storeData.vehicleType
                : ''));

    // 3. Real Vehicle Heading:
    // If provider entered vehicleModel (e.g. "Toyota Hilux", "Isuzu 5-Ton"), display it.
    // If vehicleType matches category, display it.
    // Otherwise, generate realistic service vehicle unit title matching the registered category.
    final String effectiveVehicleName;
    if (vehicleName != null && vehicleName!.isNotEmpty) {
      effectiveVehicleName = isArabic ? context.auto(vehicleName!) : vehicleName!;
    } else if (rawVehicleModel.isNotEmpty &&
        !rawVehicleModel.toLowerCase().contains('heavy duty') &&
        !rawVehicleModel.toLowerCase().contains('recovery truck') &&
        !rawVehicleModel.toLowerCase().contains('flatbed') &&
        !rawVehicleModel.toLowerCase().contains('wheel lift')) {
      effectiveVehicleName = isArabic ? context.auto(rawVehicleModel) : rawVehicleModel;
    } else if (rawVehicleType.isNotEmpty &&
        (isTowCategory ||
            (!rawVehicleType.toLowerCase().contains('recovery truck') &&
                !rawVehicleType.toLowerCase().contains('flatbed') &&
                !rawVehicleType.toLowerCase().contains('wheel lift')))) {
      effectiveVehicleName = isArabic ? context.auto(rawVehicleType) : rawVehicleType;
    } else {
      effectiveVehicleName = _resolveRealVehicleTitle(rawCategory, isArabic: isArabic);
    }

    // 4. Real Subheading (Availability Text):
    final String effectiveAvailability;
    if (availabilityText != null && availabilityText!.isNotEmpty) {
      effectiveAvailability = availabilityText!;
    } else if (cleanCategoryName.isNotEmpty) {
      effectiveAvailability = isArabic
          ? 'متاح لـ $cleanCategoryName'
          : 'Available for $cleanCategoryName';
    } else {
      effectiveAvailability = isArabic
          ? 'متاح لتقديم الخدمة'
          : 'Available for Service';
    }

    // 5. Real Plate Number:
    final String rawPlateNumber = (plateNumber != null && plateNumber!.isNotEmpty)
        ? plateNumber!
        : (registrationData.plateNumber.isNotEmpty
            ? registrationData.plateNumber
            : (storeData.plateNumber.isNotEmpty
                ? storeData.plateNumber
                : ''));
    final String effectivePlateNumber = rawPlateNumber.isNotEmpty
        ? rawPlateNumber
        : (isArabic ? 'غير مسجل' : 'Not registered');

    final String effectivePlateLabel = isArabic ? 'رقم اللوحة' : 'Plate Number';
    final String effectiveCategoryLabel = isArabic ? 'الفئة' : 'Category';

    // 6. Category Value in Row 2:
    final String effectiveCategory = cleanCategoryName.isNotEmpty
        ? cleanCategoryName
        : (isArabic ? 'خدمة عامة' : 'General Service');

    // 7. Dynamic Vehicle Image (uploaded photo or matching category asset):
    String? realPhoto;
    final photos = storeData.vehiclePhotos.isNotEmpty
        ? storeData.vehiclePhotos
        : registrationData.vehiclePhotos;
    if (photos.isNotEmpty) {
      realPhoto = photos.firstWhere((p) => p.isNotEmpty, orElse: () => '');
    }
    if (realPhoto == null || realPhoto.isEmpty) {
      if (imagePath != null && imagePath!.isNotEmpty) {
        realPhoto = imagePath;
      }
    }

    final String effectiveImagePath = (realPhoto != null && realPhoto.isNotEmpty)
        ? realPhoto
        : _resolveVehicleImage(rawCategory, rawVehicleType);

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
                                child: _buildVehicleImage(
                                  effectiveImagePath,
                                  fallbackCategory: rawCategory,
                                  fallbackVehicleType: rawVehicleType,
                                ),
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

  Widget _buildVehicleImage(String path, {String? fallbackCategory, String? fallbackVehicleType}) {
    final fallbackAsset = _resolveVehicleImage(fallbackCategory ?? '', fallbackVehicleType ?? '');

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: 106.0,
        height: 53.0,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Image.asset(
          fallbackAsset,
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
        ),
      );
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: 106.0,
        height: 53.0,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Image.asset(
          fallbackAsset,
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
        ),
      );
    }

    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: 106.0,
        height: 53.0,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Image.asset(
          fallbackAsset,
          width: 106.0,
          height: 53.0,
          fit: BoxFit.contain,
        ),
      );
    }

    return Image.asset(
      fallbackAsset,
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
