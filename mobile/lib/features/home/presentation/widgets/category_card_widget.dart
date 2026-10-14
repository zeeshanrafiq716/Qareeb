import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/category_model.dart';

/// Category card widget strictly matching Figma specifications:
/// Outer Card:
/// - width: 169 (or flexible when inside Expanded)
/// - height: 120
/// - border-radius: 8px
/// - background: #FFFFFF
/// - box-shadow: 0px 1px 10px 0px #00000014
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
  });

  /// Factory constructor to render any admin/backend CategoryModel with identical branding
  factory CategoryCardWidget.fromModel(
    CategoryModel model, {
    VoidCallback? onTap,
    double? width,
    double height = 120.0,
    Widget? customContent,
  }) {
    return CategoryCardWidget(
      key: ValueKey('category_card_${model.id}_${model.slug}'),
      title: model.name,
      subtitle: model.displaySubtitle,
      assetImagePath: model.displayAssetImage,
      networkImageUrl: model.iconUrl,
      onTap: onTap,
      width: width,
      height: height,
      child: customContent,
    );
  }

  Widget _buildImage() {
    Widget content;
    if (imageWidget != null) {
      content = imageWidget!;
    } else if (assetImagePath != null && assetImagePath!.isNotEmpty) {
      content = Image.asset(
        assetImagePath!,
        width: 98.0,
        height: 60.0,
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        errorBuilder: (_, _, _) => _buildFallbackImage(),
      );
    } else if (networkImageUrl != null && networkImageUrl!.isNotEmpty) {
      content = Image.network(
        networkImageUrl!,
        width: 98.0,
        height: 60.0,
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        errorBuilder: (_, _, _) => _buildFallbackImage(),
      );
    } else {
      content = _buildFallbackImage();
    }

    // By default, category image slot strictly follows branding: width: 98, height: 60
    return SizedBox(
      width: 98.0,
      height: 60.0,
      child: content,
    );
  }

  Widget _buildFallbackImage() {
    final String s = '$title $subtitle'.toLowerCase();
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

    // Clean transparent icon directly on white card (NO background box or shadow)
    return Align(
      alignment: Alignment.centerLeft,
      child: Icon(
        icon,
        size: 38.0,
        color: const Color(0xFF172623),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000), // #00000014 (opacity: 0.08)
            blurRadius: 10.0,
            spreadRadius: 0.0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child ??
          Stack(
            children: [
              // 1. Image Placement Branding (width: 98; height: 60; top: 10px; left: 12px; angle: 0 deg; opacity: 1)
              Positioned(
                top: 10.0,
                left: 12.0,
                width: 98.0,
                height: 60.0,
                child: _buildImage(),
              ),

              // 2. Text Branding & Right Vector Chevron (width: 169; top: 80px, bottom: 8px)
              Positioned(
                top: 80.0,
                left: 0.0,
                right: 0.0,
                bottom: 8.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left side text column (width: 79; height: 28)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title: font-family: Inter; font-weight: 500; font-style: Medium; font-size: 12px; leading-trim: CAP_HEIGHT; line-height: 22px; letter-spacing: 0px;
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textHeightBehavior: const TextHeightBehavior(
                                applyHeightToFirstAscent: false,
                                applyHeightToLastDescent: false,
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF172623),
                                height: 22.0 / 12.0,
                                letterSpacing: 0.0,
                              ),
                            ),

                            const SizedBox(height: 2.0),

                            // Subtitle: font-family: Inter; font-weight: 400; font-style: Regular; font-size: 10px; leading-trim: CAP_HEIGHT; line-height: 22px; letter-spacing: 0px; width: 99; height: 7; opacity: 1; angle: 0 deg;
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textHeightBehavior: const TextHeightBehavior(
                                applyHeightToFirstAscent: false,
                                applyHeightToLastDescent: false,
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 10.0,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF566663),
                                height: 22.0 / 10.0,
                                letterSpacing: 0.0,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 6.0),

                      // Vector on right side of >: width: 5; height: 10; border: 0.6px solid #566663
                      const _VectorChevron(
                        width: 5.0,
                        height: 10.0,
                        color: Color(0xFF566663),
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
      ..strokeWidth = 0.8
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
