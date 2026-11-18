import '../core/config/app_config.dart';

/// Model representing a service provider displayed on the radar map & nearby list
class ProviderMarkerModel {
  final int id;
  final String publicId;
  final String name;
  final String? phone;
  final String? whatsappNumber;
  final String? photoUrl;
  final double distanceMeters;
  final double distanceKm;
  final int? estimatedMinutes;
  final double ratingAvg;
  final int ratingCount;
  final int ordersCount;
  final bool isOnline;
  final String verificationStatus;
  final double latitude;
  final double longitude;

  final String categoryName;
  final String categoryNameAr;
  final String categorySlug;
  final String? categoryIconUrl;
  final String vehicleType;
  final String vehicleModel;
  final String plateNumber;
  final String vehicleColor;

  // Screen layout coordinates inside the 320x320 map circle
  final double screenTop;
  final double screenLeft;
  final double carAngle; // degrees

  const ProviderMarkerModel({
    required this.id,
    required this.publicId,
    required this.name,
    this.phone,
    this.whatsappNumber,
    this.photoUrl,
    this.distanceMeters = 0.0,
    required this.distanceKm,
    this.estimatedMinutes,
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.ordersCount = 0,
    this.isOnline = true,
    this.verificationStatus = 'unverified',
    this.categoryName = '',
    this.categoryNameAr = '',
    this.categorySlug = '',
    this.categoryIconUrl,
    this.vehicleType = '',
    this.vehicleModel = '',
    this.plateNumber = '',
    this.vehicleColor = '',
    required this.latitude,
    required this.longitude,
    required this.screenTop,
    required this.screenLeft,
    required this.carAngle,
  });

  String get coordinatesDisplay => '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  String get distanceDisplay {
    final m = distanceMeters > 0 ? distanceMeters : (distanceKm * 1000.0);
    if (m < 1000) return '${m.round()} m';
    return '${(m / 1000.0).toStringAsFixed(1)} km';
  }

  String get etaDisplay {
    final m = distanceMeters > 0 ? distanceMeters : (distanceKm * 1000.0);
    if (m < 100) return '< 1 min';
    final mins = estimatedMinutes ?? ((m / 1000.0) / 30.0 * 60.0).ceil().clamp(1, 180);
    return '$mins min';
  }

  factory ProviderMarkerModel.fromJson(
    Map<String, dynamic> json, {
    double fallbackTop = 174.0,
    double fallbackLeft = 82.0,
    double fallbackAngle = 60.0,
  }) {
    final rawDistM = (json['distanceMeters'] as num?)?.toDouble();
    final rawDistKm = (json['distanceKm'] as num?)?.toDouble();
    final double distanceM = rawDistM ?? ((rawDistKm ?? 0.0) * 1000.0);
    final double distKm = rawDistKm ?? (distanceM / 1000.0);
    final ratingMap = json['rating'] as Map<String, dynamic>?;
    final categoryMap = json['category'] as Map<String, dynamic>?;

    String? rawCategoryIcon = categoryMap?['iconUrl']?.toString() ??
        categoryMap?['icon_url']?.toString() ??
        json['categoryIconUrl']?.toString() ??
        json['category_icon_url']?.toString();
    if (rawCategoryIcon != null) {
      rawCategoryIcon = rawCategoryIcon.trim();
      if (rawCategoryIcon.isEmpty) {
        rawCategoryIcon = null;
      } else if (rawCategoryIcon.startsWith('/') &&
          !rawCategoryIcon.startsWith('//') &&
          !rawCategoryIcon.startsWith('/assets/')) {
        rawCategoryIcon = '${AppConfig.baseUrl}$rawCategoryIcon';
      }
    }

    return ProviderMarkerModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      publicId: json['publicId']?.toString() ?? json['providerId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['contact']?['phone']?.toString(),
      whatsappNumber: json['whatsappNumber']?.toString() ?? json['whatsapp_number']?.toString(),
      photoUrl: _nullableUrl(json['photoUrl'] ?? json['photo_url']),
      distanceMeters: distanceM < 0 ? 0.0 : distanceM,
      distanceKm: distKm < 0 ? 0.0 : distKm,
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt(),
      ratingAvg: (ratingMap?['average'] as num?)?.toDouble() ??
          (json['ratingAvg'] as num?)?.toDouble() ??
          0.0,
      ratingCount: (ratingMap?['count'] as num?)?.toInt() ??
          (json['ratingCount'] as num?)?.toInt() ??
          0,
      ordersCount: (json['ordersCount'] as num?)?.toInt() ??
          (json['orders_count'] as num?)?.toInt() ??
          (json['completedOrders'] as num?)?.toInt() ??
          0,
      isOnline: json['isOnline'] == true || json['availability']?['isOnline'] == true,
      verificationStatus: json['verificationStatus']?.toString() ??
          (json['verified'] == true ? 'verified' : 'unverified'),
      categoryName: categoryMap?['name']?.toString() ?? json['categoryName']?.toString() ?? '',
      categoryNameAr: categoryMap?['nameAr']?.toString() ??
          categoryMap?['name_ar']?.toString() ??
          '',
      categorySlug: categoryMap?['slug']?.toString() ?? json['categorySlug']?.toString() ?? '',
      categoryIconUrl: rawCategoryIcon,
      vehicleType: json['vehicleType']?.toString() ??
          json['vehicle_type_name']?.toString() ??
          json['vehicle_type']?.toString() ??
          '',
      vehicleModel: json['vehicleModel']?.toString() ?? json['vehicle_model']?.toString() ?? '',
      plateNumber: json['plateNumber']?.toString() ?? json['plate_number']?.toString() ?? '',
      vehicleColor: json['vehicleColor']?.toString() ?? json['vehicle_color']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ??
          (json['approximateLocation']?['latitude'] as num?)?.toDouble() ??
          0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ??
          (json['approximateLocation']?['longitude'] as num?)?.toDouble() ??
          0.0,
      screenTop: (json['screenTop'] as num?)?.toDouble() ?? fallbackTop,
      screenLeft: (json['screenLeft'] as num?)?.toDouble() ?? fallbackLeft,
      carAngle: (json['carAngle'] as num?)?.toDouble() ?? fallbackAngle,
    );
  }

  static String? _nullableUrl(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return null;
    if (text.contains('unsplash.com') || text.contains('placeholder')) return null;
    if (text.startsWith('/') && !text.startsWith('//') && !text.startsWith('/assets/')) {
      return '${AppConfig.baseUrl}$text';
    }
    return text;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'publicId': publicId,
      'name': name,
      'phone': phone,
      'whatsappNumber': whatsappNumber,
      'photoUrl': photoUrl,
      'distanceMeters': distanceMeters,
      'distanceKm': distanceKm,
      'estimatedMinutes': estimatedMinutes,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
      'ordersCount': ordersCount,
      'isOnline': isOnline,
      'verificationStatus': verificationStatus,
      'categoryName': categoryName,
      'categorySlug': categorySlug,
      'categoryIconUrl': categoryIconUrl,
      'vehicleType': vehicleType,
      'vehicleModel': vehicleModel,
      'plateNumber': plateNumber,
      'vehicleColor': vehicleColor,
      'latitude': latitude,
      'longitude': longitude,
      'screenTop': screenTop,
      'screenLeft': screenLeft,
      'carAngle': carAngle,
    };
  }
}

typedef ProviderModel = ProviderMarkerModel;
