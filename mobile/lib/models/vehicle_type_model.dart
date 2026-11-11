class VehicleTypeModel {
  final dynamic id;
  final String name;
  final String? nameAr;
  final String slug;
  final bool isEnabled;
  final int sortOrder;

  const VehicleTypeModel({
    required this.id,
    required this.name,
    this.nameAr,
    required this.slug,
    this.isEnabled = true,
    this.sortOrder = 0,
  });

  /// Official built-in vehicle types from platform database
  static const List<VehicleTypeModel> defaultVehicleTypes = [
    VehicleTypeModel(
      id: '1',
      name: 'Flatbed Tow Truck',
      nameAr: 'سطحة عادية',
      slug: 'flatbed-tow-truck',
      sortOrder: 1,
      isEnabled: true,
    ),
    VehicleTypeModel(
      id: '2',
      name: 'Hydraulic Low Flatbed',
      nameAr: 'سطحة هيدروليك',
      slug: 'hydraulic-low-flatbed',
      sortOrder: 2,
      isEnabled: true,
    ),
    VehicleTypeModel(
      id: '3',
      name: 'Wheel Lift Tow Truck',
      nameAr: 'ونش رفع',
      slug: 'wheel-lift-tow-truck',
      sortOrder: 3,
      isEnabled: true,
    ),
    VehicleTypeModel(
      id: '4',
      name: 'Heavy Duty Recovery Truck',
      nameAr: 'سطحة ثقيل',
      slug: 'heavy-duty-recovery-truck',
      sortOrder: 4,
      isEnabled: true,
    ),
    VehicleTypeModel(
      id: '5',
      name: 'Covered Carrier (VIP)',
      nameAr: 'سطحة مغلقة VIP',
      slug: 'covered-carrier-vip',
      sortOrder: 5,
      isEnabled: true,
    ),
    VehicleTypeModel(
      id: '6',
      name: 'Motorbike Carrier',
      nameAr: 'سطحة دبابات',
      slug: 'motorbike-carrier',
      sortOrder: 6,
      isEnabled: true,
    ),
  ];

  /// Returns authentic vehicle types matching the selected service category
  static List<VehicleTypeModel> getVehicleTypesForCategory(
    String? categoryName, {
    List<VehicleTypeModel>? backendOptions,
  }) {
    if (categoryName == null || categoryName.trim().isEmpty) {
      if (backendOptions != null && backendOptions.isNotEmpty) return backendOptions;
      return defaultVehicleTypes;
    }

    final lower = categoryName.toLowerCase().trim();

    if (lower.contains('tow') || lower.contains('سطحة')) {
      if (backendOptions != null && backendOptions.isNotEmpty) {
        return backendOptions;
      }
      return defaultVehicleTypes;
    }

    if (lower.contains('water') || lower.contains('tank') || lower.contains('صهريج') || lower.contains('مياه')) {
      return const [
        VehicleTypeModel(id: 'wt_1', name: 'Large Water Tanker (10,000L+)', nameAr: 'صهريج مياه كبير (١٠،٠٠٠+ لتر)', slug: 'large-water-tanker'),
        VehicleTypeModel(id: 'wt_2', name: 'Medium Water Tanker (5,000L)', nameAr: 'صهريج مياه متوسط (٥،٠٠٠ لتر)', slug: 'medium-water-tanker'),
        VehicleTypeModel(id: 'wt_3', name: 'Small Water Tanker (3,000L)', nameAr: 'صهريج مياه صغير (٣،٠٠٠ لتر)', slug: 'small-water-tanker'),
        VehicleTypeModel(id: 'wt_4', name: 'Drinking Water Potable Tanker', nameAr: 'صهريج مياه شرب محلاة', slug: 'potable-water-tanker'),
      ];
    }

    if (lower.contains('tyre') || lower.contains('tire') || lower.contains('puncture') || lower.contains('بنشر')) {
      return const [
        VehicleTypeModel(id: 'ty_1', name: 'Mobile Tyre Service Van', nameAr: 'فان صيانة إطارات متنقل', slug: 'mobile-tyre-van'),
        VehicleTypeModel(id: 'ty_2', name: 'Tyre Workshop Truck', nameAr: 'شاحنة ورشة إطارات متكاملة', slug: 'tyre-workshop-truck'),
        VehicleTypeModel(id: 'ty_3', name: 'Rapid Response Service Pickup', nameAr: 'وانيت خدمة إطارات سريع', slug: 'tyre-service-pickup'),
      ];
    }

    if (lower.contains('fuel') || lower.contains('وقود') || lower.contains('بنزين')) {
      return const [
        VehicleTypeModel(id: 'fd_1', name: 'Fuel Delivery Tanker Truck', nameAr: 'شاحنة صهريج توصيل وقود', slug: 'fuel-delivery-tanker'),
        VehicleTypeModel(id: 'fd_2', name: 'Emergency Mobile Fuel Van', nameAr: 'فان توصيل وقود طارئ', slug: 'fuel-delivery-van'),
        VehicleTypeModel(id: 'fd_3', name: 'Mobile Dispenser Pickup', nameAr: 'وانيت مضخة وقود متنقلة', slug: 'fuel-dispenser-pickup'),
      ];
    }

    if (lower.contains('mechanic') || lower.contains('ميكانيك')) {
      return const [
        VehicleTypeModel(id: 'mc_1', name: 'Mobile Mechanical Workshop Van', nameAr: 'فان ورشة ميكانيكا متنقلة', slug: 'mobile-mechanic-van'),
        VehicleTypeModel(id: 'mc_2', name: 'Diagnostic & Repair Truck', nameAr: 'شاحنة فحص وصيانة أعطال', slug: 'diagnostic-truck'),
        VehicleTypeModel(id: 'mc_3', name: 'Quick Service Mechanic Pickup', nameAr: 'وانيت ميكانيكا سريع', slug: 'mechanic-pickup'),
      ];
    }

    if (lower.contains('battery') || lower.contains('بطارية') || lower.contains('jump')) {
      return const [
        VehicleTypeModel(id: 'bt_1', name: 'Rapid Battery Jump Start Van', nameAr: 'فان خدمة واشتراك بطاريات', slug: 'battery-van'),
        VehicleTypeModel(id: 'bt_2', name: 'Mobile Battery Response Car', nameAr: 'سيارة خدمة بطاريات سريعة', slug: 'battery-car'),
        VehicleTypeModel(id: 'bt_3', name: 'Fast Courier Motorcycle', nameAr: 'دراجة توصيل واشتراك بطاريات', slug: 'battery-bike'),
      ];
    }

    if (lower.contains('small_pickup') || (lower.contains('pickup') && lower.contains('small')) || lower.contains('دينا صغيرة')) {
      return const [
        VehicleTypeModel(id: 'pk_1', name: 'Small Dyna (3-Ton)', nameAr: 'دينا صغيرة (٣ طن)', slug: 'small-dyna'),
        VehicleTypeModel(id: 'pk_2', name: 'Open Flatbed Pickup', nameAr: 'وانيت نقل مفتوح', slug: 'flatbed-pickup'),
        VehicleTypeModel(id: 'pk_3', name: 'Closed Box Dyna', nameAr: 'دينا صندوق مغلق', slug: 'closed-box-dyna'),
      ];
    }

    if (lower.contains('large_pickup') || (lower.contains('pickup') && lower.contains('large')) || lower.contains('دينا كبيرة')) {
      return const [
        VehicleTypeModel(id: 'lp_1', name: 'Large Dyna (5-Ton)', nameAr: 'دينا كبيرة (٥ طن)', slug: 'large-dyna'),
        VehicleTypeModel(id: 'lp_2', name: 'Long Bed Freight Truck', nameAr: 'شاحنة شحن طويلة', slug: 'long-bed-freight'),
        VehicleTypeModel(id: 'lp_3', name: 'Heavy Duty Box Truck', nameAr: 'شاحنة صندوق ثقيلة', slug: 'heavy-box-truck'),
      ];
    }

    if (lower.contains('ride') || lower.contains('sedan') || lower.contains('مشوار')) {
      return const [
        VehicleTypeModel(id: 'rd_1', name: 'Comfort Sedan', nameAr: 'سيارة سيدان مريحة', slug: 'comfort-sedan'),
        VehicleTypeModel(id: 'rd_2', name: 'Family SUV', nameAr: 'سيارة عائلية SUV', slug: 'family-suv'),
        VehicleTypeModel(id: 'rd_3', name: 'Economy Sedan', nameAr: 'سيارة سيدان اقتصادية', slug: 'economy-sedan'),
      ];
    }

    if (lower.contains('bike') || lower.contains('moto') || lower.contains('دراجة')) {
      return const [
        VehicleTypeModel(id: 'bk_1', name: 'Delivery Motorbike', nameAr: 'دراجة توصيل', slug: 'delivery-bike'),
        VehicleTypeModel(id: 'bk_2', name: 'Scooter Courier', nameAr: 'سكوتر توصيل سريع', slug: 'scooter-courier'),
      ];
    }

    return const [
      VehicleTypeModel(id: 'gn_1', name: 'Mobile Service Van', nameAr: 'فان صيانة وخدمات متنقل', slug: 'service-van'),
      VehicleTypeModel(id: 'gn_2', name: 'Service Pickup Truck', nameAr: 'وانيت صيانة ونقل معدات', slug: 'service-pickup'),
      VehicleTypeModel(id: 'gn_3', name: 'Maintenance Unit Car', nameAr: 'سيارة صيانة سريعة', slug: 'maintenance-car'),
    ];
  }

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['name'] as String? ?? '';
    String? rawNameAr = json['nameAr'] as String? ??
        json['name_ar'] as String? ??
        json['nameArabic'] as String?;

    if (rawNameAr == null || rawNameAr.trim().isEmpty) {
      final match = RegExp(r'\(([\u0600-\u06FF\s]+)\)').firstMatch(rawName);
      if (match != null && match.group(1) != null) {
        rawNameAr = match.group(1)!.trim();
      }
    }

    return VehicleTypeModel(
      id: json['id']?.toString() ?? '0',
      name: rawName,
      nameAr: rawNameAr,
      slug: json['slug'] as String? ?? '',
      isEnabled: json['isEnabled'] as bool? ?? json['is_enabled'] as bool? ?? true,
      sortOrder: json['sortOrder'] as int? ?? json['sort_order'] as int? ?? 0,
    );
  }

  factory VehicleTypeModel.fromString(String raw) {
    String? ar;
    final match = RegExp(r'\(([\u0600-\u06FF\s]+)\)').firstMatch(raw);
    if (match != null && match.group(1) != null) {
      ar = match.group(1)!.trim();
    }
    return VehicleTypeModel(
      id: raw,
      name: raw,
      nameAr: ar,
      slug: raw.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
    );
  }

  /// Returns localized display name: Arabic when isArabic is true, English otherwise.
  String localizedName(bool isArabic) {
    if (!isArabic) {
      return name.replaceAll(RegExp(r'\s*\([\u0600-\u06FF\s]+\)\s*'), ' ').trim();
    }
    if (nameAr != null && nameAr!.trim().isNotEmpty) {
      return nameAr!.trim();
    }
    final lower = name.toLowerCase().trim();
    if (lower.contains('hydraulic')) return 'سطحة هيدروليك';
    if (lower.contains('flatbed')) return 'سطحة عادية';
    if (lower.contains('wheel lift')) return 'ونش رفع';
    if (lower.contains('heavy duty')) return 'سطحة ثقيل';
    if (lower.contains('covered')) return 'سطحة مغلقة VIP';
    if (lower.contains('motorbike') || lower.contains('carrier')) return 'سطحة دبابات';
    if (lower.contains('winch')) return 'ونش سحب';
    if (lower.contains('truck')) return 'شاحنة';
    if (lower.contains('car')) return 'سيارة';
    return name;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehicleTypeModel &&
        other.id.toString() == id.toString() &&
        other.name == name &&
        other.nameAr == nameAr &&
        other.slug == slug;
  }

  @override
  int get hashCode => Object.hash(id, name, nameAr, slug);
}

