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

