import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/localization/app_locale.dart';
import '../../../../models/category_model.dart';

/// Category card widget strictly matching Figma specifications:
/// Outer Card:
/// - width: 169 (or flexible when inside Expanded)
/// - height: 120
/// - border-radius: 8px
/// - background: #FFFFFF
/// - box-shadow: 0px 1px 12px 0px #0000001A
///
/// Image Placement Branding:
/// - width: 98; height: 60; top: 10px; left: 12px; angle: 0 deg; opacity: 1;
///
/// Text Branding:
/// - width: 169; height: 28; top: 80px;
/// - padding-left: 12px; padding-right: 12px;
/// - justify-content: space-between;
///
/// Card Left Side Inner Content:
/// - Title (e.g. "Ride"): Inter Medium (500), 12px, leading-trim: CAP_HEIGHT, line-height: 22px, letter-spacing: 0px, #172623
/// - Subtitle (e.g. "Fast & convenient"): Inter Regular (400), 10px, leading-trim: CAP_HEIGHT, line-height: 22px, letter-spacing: 0px, width: 99, height: 7, #566663
///
/// Right Side Vector Chevron (>):
/// - width: 5; height: 10; border: 0.6px solid #566663;
class CategoryCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? assetImagePath;
  final String? networkImageUrl;
  final Widget? imageWidget;
  final Widget? child;
  final VoidCallback? onTap;
  final double? width;
  final double height;
  final AppTranslations? tr;

  const CategoryCardWidget({
    super.key,
    this.title = 'Ride',
    this.subtitle = 'City & local rides',
    this.assetImagePath,
    this.networkImageUrl,
    this.imageWidget,
    this.child,
    this.onTap,
    this.width,
    this.height = 120.0,
    this.tr,
  });

  /// Factory constructor to render any admin/backend CategoryModel with identical branding
  factory CategoryCardWidget.fromModel(
    CategoryModel model, {
    VoidCallback? onTap,
    double? width,
    double height = 120.0,
    Widget? customContent,
    String? titleOverride,
    String? subtitleOverride,
    AppTranslations? tr,
  }) {
    return CategoryCardWidget(
      key: ValueKey('category_card_${model.id}_${model.slug}'),
      title: titleOverride ?? model.name,
      subtitle: subtitleOverride ?? model.displaySubtitle,
      assetImagePath: model.assetImage ?? (model.iconUrl == null ? model.displayAssetImage : null),
      networkImageUrl: model.iconUrl,
      onTap: onTap,
      width: width,
      height: height,
      tr: tr,
      child: customContent,
    );
  }

  static const Set<String> _knownCategoryImages = {
    'tow_truck.png',
    'tyre_repair.png',
    'fuel_delivery.png',
    'car_mechanic.png',
    'small_pickup_dyna.png',
    'large_pickup_dyna.png',
    'small_water_tanker.png',
    'large_water_tanker.png',
    'battery_jump_start.png',
    'ac_technician.png',
    'electrician.png',
    'plumber.png',
    'house_cleaning.png',
    'washing_machine_tech.png',
    'refrigerator_tech.png',
    'appliance_technician.png',
    'tiles_ceramic.png',
    'carpenter.png',
    'painter.png',
    'pest_control.png',
    'network_technician.png',
    'cctv_technician.png',
    'curtain_installation.png',
    'doors_locks.png',
    'construction_renovation.png',
    'pool_maintenance.png',
    'car_ride.png',
    'pickup.png',
    'rider_bike.png',
    'van.png',
    'flatbed_truck.png',
    'towing.png',
    'truk.png',
    'ambulance.png',
    'police.png',
    'fire_brigade.png',
    'emergency_beacon.png',
  };

  static String _normalizeAssetPath(String path) {
    final clean = path.replaceAll('.svg', '.png').replaceAll(r'\', '/');
    final filename = clean.split('/').last.toLowerCase();

    // 1. Direct exact match for official realistic category assets
    if (_knownCategoryImages.contains(filename)) {
      return 'assets/images/$filename';
    }

    // 2. Slug-based filename candidate
    final slugClean = clean.split('/').last.split('.').first.toLowerCase().replaceAll('-', '_');
    final candidateFilename = '$slugClean.png';
    if (_knownCategoryImages.contains(candidateFilename)) {
      return 'assets/images/$candidateFilename';
    }

    // 3. Exact mappings for the 26 list categories by keyword & service type
    final lower = path.toLowerCase();
    if (lower.contains('tow') || lower.contains('recovery') || lower.contains('سطحة')) {
      return 'assets/images/tow_truck.png';
    }
    if (lower.contains('tyre') || lower.contains('tire') || lower.contains('puncture') || lower.contains('بنشر') || lower.contains('كاوتش')) {
      return 'assets/images/tyre_repair.png';
    }
    if (lower.contains('fuel') || lower.contains('petrol') || lower.contains('diesel') || lower.contains('وقود')) {
      return 'assets/images/fuel_delivery.png';
    }
    if (lower.contains('mechanic') || lower.contains('ميكانيك')) {
      return 'assets/images/car_mechanic.png';
    }
    if (lower.contains('large_pickup') || lower.contains('large pickup') || lower.contains('كبيرة')) {
      return 'assets/images/large_pickup_dyna.png';
    }
    if (lower.contains('small_pickup') || lower.contains('small pickup') || lower.contains('صغيرة') || lower.contains('dyna')) {
      return 'assets/images/small_pickup_dyna.png';
    }
    if (lower.contains('large_water') || lower.contains('large water') || lower.contains('وايت')) {
      return 'assets/images/large_water_tanker.png';
    }
    if (lower.contains('small_water') || lower.contains('small water') || lower.contains('صهريج') || lower.contains('tanker') || lower.contains('water')) {
      return 'assets/images/small_water_tanker.png';
    }
    if (lower.contains('battery') || lower.contains('jump') || lower.contains('بطارية')) {
      return 'assets/images/battery_jump_start.png';
    }
    if (lower.contains('ac') || lower.contains('hvac') || lower.contains('مكيف')) {
      return 'assets/images/ac_technician.png';
    }
    if (lower.contains('electric') || lower.contains('كهرب')) {
      return 'assets/images/electrician.png';
    }
    if (lower.contains('plumb') || lower.contains('سباك')) {
      return 'assets/images/plumber.png';
    }
    if (lower.contains('clean') || lower.contains('تنظيف')) {
      return 'assets/images/house_cleaning.png';
    }
    if (lower.contains('wash') || lower.contains('غسال')) {
      return 'assets/images/washing_machine_tech.png';
    }
    if (lower.contains('refrig') || lower.contains('fridge') || lower.contains('ثلاج')) {
      return 'assets/images/refrigerator_tech.png';
    }
    if (lower.contains('appliance') || lower.contains('أجهزة')) {
      return 'assets/images/appliance_technician.png';
    }
    if (lower.contains('tile') || lower.contains('ceramic') || lower.contains('بلاط') || lower.contains('سيراميك')) {
      return 'assets/images/tiles_ceramic.png';
    }
    if (lower.contains('carpent') || lower.contains('wood') || lower.contains('نجار')) {
      return 'assets/images/carpenter.png';
    }
    if (lower.contains('paint') || lower.contains('دهان')) {
      return 'assets/images/painter.png';
    }
    if (lower.contains('pest') || lower.contains('حشرات')) {
      return 'assets/images/pest_control.png';
    }
    if (lower.contains('network') || lower.contains('wifi') || lower.contains('شبك')) {
      return 'assets/images/network_technician.png';
    }
    if (lower.contains('cctv') || lower.contains('camera') || lower.contains('كامير')) {
      return 'assets/images/cctv_technician.png';
    }
    if (lower.contains('curtain') || lower.contains('ستائر')) {
      return 'assets/images/curtain_installation.png';
    }
    if (lower.contains('door') || lower.contains('lock') || lower.contains('أبواب') || lower.contains('أقفال')) {
      return 'assets/images/doors_locks.png';
    }
    if (lower.contains('construct') || lower.contains('renovat') || lower.contains('بناء') || lower.contains('ترميم')) {
      return 'assets/images/construction_renovation.png';
    }
    if (lower.contains('pool') || lower.contains('مسبح') || lower.contains('مسابح')) {
      return 'assets/images/pool_maintenance.png';
    }
    if (lower.contains('ride') || lower.contains('sedan')) {
      return 'assets/images/car_ride.png';
    }
    if (lower.contains('pickup')) {
      return 'assets/images/pickup.png';
    }
    if (lower.contains('rider') || lower.contains('bike') || lower.contains('moto')) {
      return 'assets/images/rider_bike.png';
    }
    if (lower.contains('van')) {
      return 'assets/images/van.png';
    }

    if (path.startsWith('/assets/images/')) return path.substring(1);
    if (path.startsWith('assets/images/')) return path;
    return 'assets/images/tow_truck.png';
  }

  Widget _buildImage() {
    Widget content;

    // 1. Direct widget override
    if (imageWidget != null) {
      content = imageWidget!;
    }
    // 2. Base64 Image uploaded by Admin (any resolution / size)
    else if (networkImageUrl != null && networkImageUrl!.startsWith('data:image')) {
      try {
        final commaIdx = networkImageUrl!.indexOf(',');
        final base64String = commaIdx != -1
            ? networkImageUrl!.substring(commaIdx + 1)
            : networkImageUrl!;
        final bytes = base64Decode(base64String);
        content = Image.memory(
          bytes,
          width: 98.0,
          height: 60.0,
          fit: BoxFit.contain,
          alignment: AlignmentDirectional.centerStart,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, _, _) => _buildFallbackImage(),
        );
      } catch (_) {
        content = _buildFallbackImage();
      }
    }
    // 3. Preset Asset selected by Admin (bundled inside local app assets)
    else if (networkImageUrl != null &&
        !networkImageUrl!.startsWith('/uploads/') &&
        !networkImageUrl!.contains('uploads/') &&
        (networkImageUrl!.contains('assets/') ||
            networkImageUrl!.endsWith('.svg') ||
            (networkImageUrl!.endsWith('.png') && !networkImageUrl!.startsWith('http')))) {
      final normalizedPath = _normalizeAssetPath(networkImageUrl!);
      content = Image.asset(
        normalizedPath,
        width: 98.0,
        height: 60.0,
        fit: BoxFit.contain,
        alignment: AlignmentDirectional.centerStart,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => _buildFallbackImage(),
      );
    }
    // 4. Remote HTTP/HTTPS URL or Server Uploaded URL (/uploads/categories/...)
    else if (networkImageUrl != null &&
        (networkImageUrl!.startsWith('http') || networkImageUrl!.startsWith('/uploads/'))) {
      final resolvedUrl = networkImageUrl!.startsWith('/')
          ? '${AppConfig.baseUrl}$networkImageUrl'
          : networkImageUrl!;
      content = Image.network(
        resolvedUrl,
        width: 98.0,
        height: 60.0,
        fit: BoxFit.contain,
        alignment: AlignmentDirectional.centerStart,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => _buildFallbackImage(),
      );
    }
    // 5. Explicit local asset path
    else if (assetImagePath != null && assetImagePath!.isNotEmpty) {
      final normalizedPath = _normalizeAssetPath(assetImagePath!);
      content = Image.asset(
        normalizedPath,
        width: 98.0,
        height: 60.0,
        fit: BoxFit.contain,
        alignment: AlignmentDirectional.centerStart,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => _buildFallbackImage(),
      );
    }
    // 6. Clean branded fallback vehicle
    else {
      content = _buildFallbackImage();
    }

    // Strictly enforce branding: exact width: 98px, height: 60px with containment
    return SizedBox(
      width: 98.0,
      height: 60.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: AlignmentDirectional.centerStart,
          child: SizedBox(
            width: 98.0,
            height: 60.0,
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackImage() {
    final String s = '$title $subtitle'.toLowerCase();
    final String fallbackPath = _normalizeAssetPath(s);

    return Image.asset(
      fallbackPath,
      width: 98.0,
      height: 60.0,
      fit: BoxFit.contain,
      alignment: AlignmentDirectional.centerStart,
      errorBuilder: (_, _, _) {
        final IconData icon;
        if (s.contains('pickup') || s.contains('truck')) {
          icon = Icons.local_shipping_outlined;
        } else if (s.contains('rider') || s.contains('moto') || s.contains('bike')) {
          icon = Icons.two_wheeler_rounded;
        } else if (s.contains('van')) {
          icon = Icons.airport_shuttle_outlined;
        } else if (s.contains('rickshaw') || s.contains('auto') || s.contains('tuk')) {
          icon = Icons.electric_rickshaw_outlined;
        } else if (s.contains('delivery') || s.contains('courier') || s.contains('parcel')) {
          icon = Icons.inventory_2_outlined;
        } else if (s.contains('electric') || s.contains('ac')) {
          icon = Icons.bolt_rounded;
        } else if (s.contains('plumb')) {
          icon = Icons.plumbing_rounded;
        } else if (s.contains('clean') || s.contains('home')) {
          icon = Icons.home_repair_service_outlined;
        } else if (s.contains('emergency')) {
          icon = Icons.emergency_rounded;
        } else {
          icon = Icons.directions_car_filled_outlined;
        }

        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: Icon(
            icon,
            size: 38.0,
            color: const Color(0xFF172623),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTitle = (tr != null && tr!.isArabic)
        ? tr!.categoryName(title, title)
        : title;
    final effectiveSubtitle = (tr != null && tr!.isArabic)
        ? tr!.categorySubtitle(subtitle, subtitle)
        : subtitle;

    final cardContent = Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000), // subtle base elevation
            blurRadius: 8.0,
            spreadRadius: 0.0,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x268B53FE), // light shadow of brand purple
            blurRadius: 12.0,
            spreadRadius: 1.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child ??
          Stack(
            children: [
              // 1. Image Placement Branding (width: 98; height: 60; top: 10px; start: 12px; angle: 0 deg; opacity: 1)
              PositionedDirectional(
                top: 10.0,
                start: 12.0,
                width: 98.0,
                height: 60.0,
                child: _buildImage(),
              ),

              // 2. Text Branding & Right Vector Chevron (width: 169; bottom: 8px)
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 8.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Leading text column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title
                            Text(
                              effectiveTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tr != null
                                  ? tr!.font(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF172623),
                                      height: 1.2,
                                    )
                                  : GoogleFonts.cairo(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF172623),
                                      height: 1.2,
                                    ),
                            ),

                            // Subtitle - only rendered if provided by admin (hidden by default)
                            if (effectiveSubtitle.trim().isNotEmpty) ...[
                              const SizedBox(height: 2.0),
                              Text(
                                effectiveSubtitle,
                                maxLines: 2,
                                softWrap: true,
                                overflow: TextOverflow.clip,
                                style: tr != null
                                    ? tr!.font(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF566663),
                                        height: 1.2,
                                      )
                                    : GoogleFonts.cairo(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF566663),
                                        height: 1.2,
                                      ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(width: 6.0),

                      // Vector chevron in brand purple #8B53FE (mirrored for RTL to <)
                      Transform.scale(
                        scaleX: ((tr?.isArabic ?? false) || Directionality.of(context) == TextDirection.rtl) ? -1.0 : 1.0,
                        child: const _VectorChevron(
                          width: 5.0,
                          height: 10.0,
                          color: Color(0xFF8B53FE),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );

    if (onTap == null) {
      return cardContent;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: cardContent,
      ),
    );
  }
}

/// Custom vector chevron matching exact Figma dimensions (width: 5, height: 10, stroke: 0.6px, #566663).
class _VectorChevron extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _VectorChevron({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _VectorChevronPainter(color: color),
    );
  }
}

class _VectorChevronPainter extends CustomPainter {
  final Color color;

  _VectorChevronPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(0.5, 0.5)
      ..lineTo(size.width - 0.5, size.height / 2)
      ..lineTo(0.5, size.height - 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
