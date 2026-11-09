import '../core/config/app_config.dart';

class CategoryModel {
  final dynamic id;
  final String name;
  final String? nameAr;
  final String slug;
  final bool isEnabled;
  final String? subtitle;
  final String? subtitleAr;
  final String? iconUrl;
  final String? assetImage;

  const CategoryModel({
    required this.id,
    required this.name,
    this.nameAr,
    required this.slug,
    this.isEnabled = true,
    this.subtitle,
    this.subtitleAr,
    this.iconUrl,
    this.assetImage,
  });

  /// Returns localized display name: Arabic when isArabic is true, English otherwise.
  String localizedName(bool isArabic) {
    if (!isArabic) {
      return name.replaceAll(RegExp(r'\s*\([\u0600-\u06FF\s]+\)\s*'), ' ').trim();
    }
    if (nameAr != null && nameAr!.trim().isNotEmpty) {
      return nameAr!.trim();
    }
    final lower = name.toLowerCase().trim();
    if (lower == 'workhouse' || lower == 'workshop' || lower == 'work house') return 'ورشة عمل';
    if (lower == 'garage') return 'ورشة / كراج';
    if (lower == 'flatbed truck' || lower == 'flatbed') return 'سطحة';
    if (lower == 'towing truck' || lower == 'towing') return 'ونش';
    if (lower == 'ride sedan' || lower == 'ride') return 'توصيل';
    if (lower == 'pickup truck' || lower == 'pickup') return 'وانيت';
    if (lower == 'family van' || lower == 'van') return 'فان';
    if (lower == 'emergency beacon' || lower == 'emergency') return 'طوارئ';
    if (lower == 'mechanic') return 'ميكانيكي';
    if (lower == 'electrician') return 'كهربائي';
    if (lower == 'battery') return 'بطارية';
    if (lower == 'tire' || lower == 'tyre') return 'إطارات';
    if (lower == 'fuel') return 'وقود';
    return name;
  }

  /// Formatted subtitle matching branding guidelines (empty by default if not set by admin)
  String get displaySubtitle {
    if (subtitle != null && subtitle!.trim().isNotEmpty) return subtitle!;
    return '';
  }

  /// Returns localized subtitle
  String localizedSubtitle(bool isArabic) {
    if (isArabic && subtitleAr != null && subtitleAr!.trim().isNotEmpty) {
      return subtitleAr!.trim();
    }
    return displaySubtitle;
  }

  /// Preset asset image matching brand assets
  String? get displayAssetImage {
    if (assetImage != null && assetImage!.isNotEmpty) return assetImage;
    final s = slug.toLowerCase();
    final n = name.toLowerCase();

    // 1. Direct slug / key mapping to 26 official category assets
    if (s == 'tow-truck' || s == 'tow_truck' || s.contains('tow') || n.contains('tow') || n.contains('سطحة')) {
      return 'assets/images/tow_truck.png';
    } else if (s == 'tyre-puncture-repair' || s == 'tyre_repair' || s.contains('tyre') || s.contains('tire') || s.contains('puncture') || n.contains('بنشر') || n.contains('كاوتش')) {
      return 'assets/images/tyre_repair.png';
    } else if (s == 'fuel-delivery' || s == 'fuel_delivery' || s.contains('fuel') || n.contains('وقود')) {
      return 'assets/images/fuel_delivery.png';
    } else if (s == 'car-mechanic' || s == 'car_mechanic' || s.contains('mechanic') || n.contains('ميكانيك')) {
      return 'assets/images/car_mechanic.png';
    } else if (s == 'small-pickup-dyna' || s == 'small_pickup_dyna' || s.contains('small_pickup') || n.contains('صغيرة')) {
      return 'assets/images/small_pickup_dyna.png';
    } else if (s == 'large-pickup-dyna' || s == 'large_pickup_dyna' || s.contains('large_pickup') || n.contains('كبيرة')) {
      return 'assets/images/large_pickup_dyna.png';
    } else if (s == 'small-water-tanker' || s == 'small_water_tanker' || (s.contains('water') && s.contains('small'))) {
      return 'assets/images/small_water_tanker.png';
    } else if (s == 'large-water-tanker' || s == 'large_water_tanker' || (s.contains('water') && s.contains('large')) || s.contains('water') || s.contains('tanker') || n.contains('صهريج')) {
      return 'assets/images/large_water_tanker.png';
    } else if (s == 'battery-jump-start' || s == 'battery_jump_start' || s.contains('battery') || s.contains('jump') || n.contains('بطارية')) {
      return 'assets/images/battery_jump_start.png';
    } else if (s == 'ac-technician' || s == 'ac_technician' || s.contains('ac') || s.contains('hvac') || n.contains('مكيف')) {
      return 'assets/images/ac_technician.png';
    } else if (s == 'electrician' || s.contains('electric') || n.contains('كهرب')) {
      return 'assets/images/electrician.png';
    } else if (s == 'plumber' || s.contains('plumb') || n.contains('سباك')) {
      return 'assets/images/plumber.png';
    } else if (s == 'house-cleaning' || s == 'house_cleaning' || s.contains('clean') || n.contains('تنظيف')) {
      return 'assets/images/house_cleaning.png';
    } else if (s == 'washing-machine-tech' || s == 'washing_machine_tech' || s.contains('washing') || s.contains('washer') || n.contains('غسال')) {
      return 'assets/images/washing_machine_tech.png';
    } else if (s == 'refrigerator-tech' || s == 'refrigerator_tech' || s.contains('refrig') || s.contains('fridge') || n.contains('ثلاج')) {
      return 'assets/images/refrigerator_tech.png';
    } else if (s == 'appliance-technician' || s == 'appliance_technician' || s.contains('appliance') || n.contains('أجهزة')) {
      return 'assets/images/appliance_technician.png';
    } else if (s == 'tiles-ceramic' || s == 'tiles_ceramic' || s.contains('tile') || s.contains('ceramic') || n.contains('بلاط') || n.contains('سيراميك')) {
      return 'assets/images/tiles_ceramic.png';
    } else if (s == 'carpenter' || s.contains('carpent') || s.contains('wood') || n.contains('نجار')) {
      return 'assets/images/carpenter.png';
    } else if (s == 'painter' || s.contains('paint') || n.contains('دهان')) {
      return 'assets/images/painter.png';
    } else if (s == 'pest-control' || s == 'pest_control' || s.contains('pest') || n.contains('حشرات')) {
      return 'assets/images/pest_control.png';
    } else if (s == 'network-technician' || s == 'network_technician' || s.contains('network') || s.contains('wifi') || n.contains('شبك')) {
      return 'assets/images/network_technician.png';
    } else if (s == 'cctv-technician' || s == 'cctv_technician' || s.contains('cctv') || s.contains('camera') || n.contains('كامير')) {
      return 'assets/images/cctv_technician.png';
    } else if (s == 'curtain-installation' || s == 'curtain_installation' || s.contains('curtain') || n.contains('ستائر')) {
      return 'assets/images/curtain_installation.png';
    } else if (s == 'doors-locks' || s == 'doors_locks' || s.contains('door') || s.contains('lock') || n.contains('أبواب') || n.contains('أقفال')) {
      return 'assets/images/doors_locks.png';
    } else if (s == 'construction-renovation' || s == 'construction_renovation' || s.contains('construct') || s.contains('renov') || n.contains('بناء') || n.contains('ترميم')) {
      return 'assets/images/construction_renovation.png';
    } else if (s == 'pool-maintenance' || s == 'pool_maintenance' || s.contains('pool') || n.contains('مسبح') || n.contains('مسابح')) {
      return 'assets/images/pool_maintenance.png';
    } else if (s.contains('car_ride') || s == 'ride' || s.contains('sedan') || n.contains('ride') || n.contains('مشوار')) {
      return 'assets/images/car_ride.png';
    } else if (s.contains('rider') || s == 'bike' || s.contains('moto') || n.contains('rider') || n.contains('دراجة')) {
      return 'assets/images/rider_bike.png';
    } else if (s == 'pickup' || s.contains('pickup')) {
      return 'assets/images/pickup.png';
    } else if (s == 'van' || s.contains('van') || n.contains('van') || n.contains('فان')) {
      return 'assets/images/van.png';
    } else if (s.contains('ambulance')) {
      return 'assets/images/ambulance.png';
    } else if (s.contains('police')) {
      return 'assets/images/police.png';
    } else if (s.contains('fire')) {
      return 'assets/images/fire_brigade.png';
    } else if (s.contains('beacon') || s.contains('emergency')) {
      return 'assets/images/emergency_beacon.png';
    }
    return 'assets/images/tow_truck.png';
  }

  /// Official 26 Categories from user's master reference list
  static const List<CategoryModel> default26Categories = [
    CategoryModel(
      id: '1',
      name: 'Tow Truck',
      nameAr: 'سطحة',
      slug: 'tow-truck',
      assetImage: 'assets/images/tow_truck.png',
      subtitle: 'Vehicle towing & recovery',
      subtitleAr: 'سحب ونقل سيارات',
      isEnabled: true,
    ),
    CategoryModel(
      id: '2',
      name: 'Tyre & Puncture Repair',
      nameAr: 'كاوتش / بنشر',
      slug: 'tyre-puncture-repair',
      assetImage: 'assets/images/tyre_repair.png',
      subtitle: 'Mobile tyre change & repair',
      subtitleAr: 'تبديل وإصلاح إطارات متنقل',
      isEnabled: true,
    ),
    CategoryModel(
      id: '3',
      name: 'Fuel Delivery',
      nameAr: 'توصيل وقود',
      slug: 'fuel-delivery',
      assetImage: 'assets/images/fuel_delivery.png',
      subtitle: 'Emergency petrol & diesel',
      subtitleAr: 'توصيل بنزين وديزل طوارئ',
      isEnabled: true,
    ),
    CategoryModel(
      id: '4',
      name: 'Car Mechanic',
      nameAr: 'ميكانيكي سيارات',
      slug: 'car-mechanic',
      assetImage: 'assets/images/car_mechanic.png',
      subtitle: 'Mobile vehicle repair',
      subtitleAr: 'فحص وإصلاح سيارات متنقل',
      isEnabled: true,
    ),
    CategoryModel(
      id: '5',
      name: 'Small Pickup (Dyna)',
      nameAr: 'دينا صغيرة',
      slug: 'small-pickup-dyna',
      assetImage: 'assets/images/small_pickup_dyna.png',
      subtitle: 'Goods & small cargo',
      subtitleAr: 'نقل بضائع وحمولات خفيفة',
      isEnabled: true,
    ),
    CategoryModel(
      id: '6',
      name: 'Large Pickup (Dyna)',
      nameAr: 'دينا كبيرة',
      slug: 'large-pickup-dyna',
      assetImage: 'assets/images/large_pickup_dyna.png',
      subtitle: 'Heavy cargo & transport',
      subtitleAr: 'نقل وشحن حمولات ثقيلة',
      isEnabled: true,
    ),
    CategoryModel(
      id: '7',
      name: 'Small Water Tanker',
      nameAr: 'صهريج ماء صغير',
      slug: 'small-water-tanker',
      assetImage: 'assets/images/small_water_tanker.png',
      subtitle: 'Clean water delivery (small)',
      subtitleAr: 'توصيل مياه شرب ونقية',
      isEnabled: true,
    ),
    CategoryModel(
      id: '8',
      name: 'Large Water Tanker',
      nameAr: 'صهريج ماء كبير',
      slug: 'large-water-tanker',
      assetImage: 'assets/images/large_water_tanker.png',
      subtitle: 'Commercial water tanker',
      subtitleAr: 'وايت مياه تجاري كبير',
      isEnabled: true,
    ),
    CategoryModel(
      id: '9',
      name: 'Battery Jump Start',
      nameAr: 'بطارية – جامب ستارتر',
      slug: 'battery-jump-start',
      assetImage: 'assets/images/battery_jump_start.png',
      subtitle: 'Roadside battery jumpstart',
      subtitleAr: 'شحن وتشغيل بطارية فوري',
      isEnabled: true,
    ),
    CategoryModel(
      id: '10',
      name: 'AC Technician',
      nameAr: 'فني مكيف هواء',
      slug: 'ac-technician',
      assetImage: 'assets/images/ac_technician.png',
      subtitle: 'AC install & maintenance',
      subtitleAr: 'تركيب وصيانة مكيفات',
      isEnabled: true,
    ),
    CategoryModel(
      id: '11',
      name: 'Electrician',
      nameAr: 'كهربائي',
      slug: 'electrician',
      assetImage: 'assets/images/electrician.png',
      subtitle: 'Electrical works & wiring',
      subtitleAr: 'تمديدات وإصلاحات كهربائية',
      isEnabled: true,
    ),
    CategoryModel(
      id: '12',
      name: 'Plumber',
      nameAr: 'سباك',
      slug: 'plumber',
      assetImage: 'assets/images/plumber.png',
      subtitle: 'Plumbing & sanitary repair',
      subtitleAr: 'تمديدات وسباكة منزلية',
      isEnabled: true,
    ),
    CategoryModel(
      id: '13',
      name: 'House Cleaning',
      nameAr: 'تنظيف منازل',
      slug: 'house-cleaning',
      assetImage: 'assets/images/house_cleaning.png',
      subtitle: 'Deep home & villa cleaning',
      subtitleAr: 'تنظيف شامل للمنازل والفلل',
      isEnabled: true,
    ),
    CategoryModel(
      id: '14',
      name: 'Washing Machine Tech',
      nameAr: 'فني غسالات',
      slug: 'washing-machine-tech',
      assetImage: 'assets/images/washing_machine_tech.png',
      subtitle: 'Washer & dryer repair',
      subtitleAr: 'صيانة وتصليح غسالات',
      isEnabled: true,
    ),
    CategoryModel(
      id: '15',
      name: 'Refrigerator Tech',
      nameAr: 'فني ثلاجة',
      slug: 'refrigerator-tech',
      assetImage: 'assets/images/refrigerator_tech.png',
      subtitle: 'Fridge & freezer repair',
      subtitleAr: 'صيانة ثلاجات وتبريد',
      isEnabled: true,
    ),
    CategoryModel(
      id: '16',
      name: 'Appliance Technician',
      nameAr: 'صيانة أجهزة',
      slug: 'appliance-technician',
      assetImage: 'assets/images/appliance_technician.png',
      subtitle: 'Home appliances repair',
      subtitleAr: 'صيانة وتصليح أجهزة منزلية',
      isEnabled: true,
    ),
    CategoryModel(
      id: '17',
      name: 'Tiles & Ceramic',
      nameAr: 'فني بلاط وسيراميك',
      slug: 'tiles-ceramic',
      assetImage: 'assets/images/tiles_ceramic.png',
      subtitle: 'Tile laying & masonry',
      subtitleAr: 'تركيب سيراميك وبلاط ورخام',
      isEnabled: true,
    ),
    CategoryModel(
      id: '18',
      name: 'Carpenter',
      nameAr: 'نجار',
      slug: 'carpenter',
      assetImage: 'assets/images/carpenter.png',
      subtitle: 'Woodwork & furniture',
      subtitleAr: 'تفصيل وتركيب أثاث ونجارة',
      isEnabled: true,
    ),
    CategoryModel(
      id: '19',
      name: 'Painter',
      nameAr: 'دهان',
      slug: 'painter',
      assetImage: 'assets/images/painter.png',
      subtitle: 'Wall painting & decor',
      subtitleAr: 'دهانات وتشطيبات وديكور',
      isEnabled: true,
    ),
    CategoryModel(
      id: '20',
      name: 'Pest Control',
      nameAr: 'مكافحة حشرات',
      slug: 'pest-control',
      assetImage: 'assets/images/pest_control.png',
      subtitle: 'Insect & pest extermination',
      subtitleAr: 'رش مبيدات ومكافحة حشرات',
      isEnabled: true,
    ),
    CategoryModel(
      id: '21',
      name: 'Network Technician',
      nameAr: 'فني شبكات',
      slug: 'network-technician',
      assetImage: 'assets/images/network_technician.png',
      subtitle: 'WiFi, fiber & routers',
      subtitleAr: 'تمديد وضبط شبكات وإنترنت',
      isEnabled: true,
    ),
    CategoryModel(
      id: '22',
      name: 'CCTV Technician',
      nameAr: 'فني كاميرات مراقبة',
      slug: 'cctv-technician',
      assetImage: 'assets/images/cctv_technician.png',
      subtitle: 'Security cameras install',
      subtitleAr: 'تركيب وبرمجة كاميرات مراقبة',
      isEnabled: true,
    ),
    CategoryModel(
      id: '23',
      name: 'Curtain Installation',
      nameAr: 'تركيب ستائر',
      slug: 'curtain-installation',
      assetImage: 'assets/images/curtain_installation.png',
      subtitle: 'Curtains & blinds fitting',
      subtitleAr: 'تركيب وتفصيل ستائر',
      isEnabled: true,
    ),
    CategoryModel(
      id: '24',
      name: 'Doors & Locks',
      nameAr: 'فني أبواب وأقفال',
      slug: 'doors-locks',
      assetImage: 'assets/images/doors_locks.png',
      subtitle: 'Locksmith & door repair',
      subtitleAr: 'فتح وتغيير أقفال وصيانة أبواب',
      isEnabled: true,
    ),
    CategoryModel(
      id: '25',
      name: 'Construction & Renovation',
      nameAr: 'أعمال بناء وترميم',
      slug: 'construction-renovation',
      assetImage: 'assets/images/construction_renovation.png',
      subtitle: 'Building renovation & masonry',
      subtitleAr: 'مقاولات وترميم وأعمال بناء',
      isEnabled: true,
    ),
    CategoryModel(
      id: '26',
      name: 'Pool Maintenance',
      nameAr: 'صيانة مسابح',
      slug: 'pool-maintenance',
      assetImage: 'assets/images/pool_maintenance.png',
      subtitle: 'Pool cleaning & chlorination',
      subtitleAr: 'تنظيف وصيانة وتطهير مسابح',
      isEnabled: true,
    ),
  ];

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    String? rawIcon = json['icon_url'] as String? ??
        json['iconUrl'] as String? ??
        json['image_url'] as String? ??
        json['imageUrl'] as String? ??
        json['image'] as String? ??
        json['icon'] as String?;

    // Prepend API base URL only if relative server upload path (e.g. /uploads/...)
    if (rawIcon != null &&
        rawIcon.startsWith('/') &&
        !rawIcon.startsWith('//') &&
        !rawIcon.startsWith('/assets/')) {
      rawIcon = '${AppConfig.baseUrl}$rawIcon';
    }

    final rawName = json['name'] as String? ?? 'General Service';
    String? rawNameAr = json['nameAr'] as String? ??
        json['name_ar'] as String? ??
        json['nameArabic'] as String?;

    if (rawNameAr == null || rawNameAr.trim().isEmpty) {
      final match = RegExp(r'\(([\u0600-\u06FF\s]+)\)').firstMatch(rawName);
      if (match != null && match.group(1) != null) {
        rawNameAr = match.group(1)!.trim();
      }
    }

    return CategoryModel(
      id: json['id']?.toString() ?? '0',
      name: rawName,
      nameAr: rawNameAr,
      slug: json['slug'] as String? ?? 'general',
      isEnabled: json['isEnabled'] as bool? ?? json['is_enabled'] as bool? ?? true,
      subtitle: json['subtitle'] as String?,
      subtitleAr: json['subtitleAr'] as String? ?? json['subtitle_ar'] as String?,
      iconUrl: rawIcon,
      assetImage: json['asset_image'] as String? ?? json['assetImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'nameAr': nameAr,
      'slug': slug,
      'isEnabled': isEnabled,
      'subtitle': subtitle,
      'subtitle_ar': subtitleAr,
      'subtitleAr': subtitleAr,
      'icon_url': iconUrl,
      'asset_image': assetImage,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel &&
        other.id.toString() == id.toString() &&
        other.name == name &&
        other.nameAr == nameAr &&
        other.slug == slug &&
        other.isEnabled == isEnabled &&
        other.subtitle == subtitle &&
        other.iconUrl == iconUrl &&
        other.assetImage == assetImage;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        nameAr,
        slug,
        isEnabled,
        subtitle,
        iconUrl,
        assetImage,
      );
}
