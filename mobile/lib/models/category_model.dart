import '../core/config/app_config.dart';

class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final bool isEnabled;
  final String? subtitle;
  final String? iconUrl;
  final String? assetImage;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.isEnabled = true,
    this.subtitle,
    this.iconUrl,
    this.assetImage,
  });

  /// Formatted subtitle matching branding guidelines
  String get displaySubtitle {
    if (subtitle != null && subtitle!.isNotEmpty) return subtitle!;
    final s = slug.toLowerCase();
    if (s == 'ride' || s == 'transport') {
      return 'City & local rides';
    } else if (s == 'pickup') {
      return 'Goods & deliveries';
    } else if (s == 'rider' || s.contains('bike') || s.contains('moto')) {
      return 'Fast & convenient';
    } else if (s == 'van') {
      return 'Group & family travel';
    } else if (s.contains('rickshaw') || s.contains('auto') || s.contains('tuk')) {
      return 'Affordable local travel';
    } else if (s.contains('delivery') || s.contains('courier')) {
      return 'Courier & parcels';
    } else if (s.contains('home') || s.contains('clean')) {
      return 'Cleaning & repairs';
    } else if (s.contains('electric') || s.contains('ac')) {
      return 'AC & wiring repairs';
    } else if (s.contains('plumb')) {
      return 'Pipe & water fixes';
    } else if (s.contains('emergency')) {
      return 'Urgent roadside aid';
    }
    return 'Available services';
  }

  /// Preset asset image matching brand assets
  String? get displayAssetImage {
    if (assetImage != null && assetImage!.isNotEmpty) return assetImage;
    final s = slug.toLowerCase();
    if (s == 'ride' || s == 'transport') {
      return 'assets/images/car_ride.png';
    } else if (s == 'pickup') {
      return 'assets/images/pickup.png';
    } else if (s == 'rider' || s == 'moto' || s == 'bike') {
      return 'assets/images/rider_bike.png';
    } else if (s == 'van') {
      return 'assets/images/van.png';
    }
    return null;
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    String? rawIcon = json['icon_url'] as String? ??
        json['iconUrl'] as String? ??
        json['image_url'] as String? ??
        json['imageUrl'] as String? ??
        json['image'] as String? ??
        json['icon'] as String?;

    // Prepend API base URL if relative path provided by backend upload
    if (rawIcon != null && rawIcon.startsWith('/') && !rawIcon.startsWith('//')) {
      rawIcon = '${AppConfig.baseUrl}$rawIcon';
    }

    return CategoryModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] as String? ?? 'General Service',
      slug: json['slug'] as String? ?? 'general',
      isEnabled: json['isEnabled'] as bool? ?? json['is_enabled'] as bool? ?? true,
      subtitle: json['subtitle'] as String?,
      iconUrl: rawIcon,
      assetImage: json['asset_image'] as String? ?? json['assetImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'isEnabled': isEnabled,
      'subtitle': subtitle,
      'icon_url': iconUrl,
      'asset_image': assetImage,
    };
  }
}
