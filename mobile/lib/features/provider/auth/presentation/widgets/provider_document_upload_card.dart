import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Document Upload Card Widget
/// Implements exact Figma branding specifications:
///
/// card branding:
///   width: 350;
///   height: 93.29783630371094;
///   border-radius: 16px;
///   justify-content: space-between;
///   padding: 16px;
///   angle: 0 deg;
///   opacity: 1;
///   background: #FFFFFF;
///   box-shadow: 0px 1px 12px 0px #0000001A;
///
/// content layout:
///   width: 234; height: 56; gap: 12px;
///
/// img framer layout:
///   width: 88; height: 56; border-radius: 6px;
///
/// text content layout:
///   width: 134; height: 50; gap: 16px;
///
/// content: [Title] (Iqama, Vehicle Registration, Driving Licence)
///   Inter 500 Medium 12px line-height 22px #1C2926;
///
/// content: [Subtitle 1]
///   Inter 400 Regular 10px line-height 22px #566663;
///
/// content: Valid and not expired
///   Inter 400 Regular 10px line-height 22px #566663;
///
/// right side layout (upload box):
///   width: 72; height: 61.29783630371094; border-radius: 8px;
///   border: 0.8px dashed #D3E0DC (dashes: 3, 3);
///   padding: 10px 7.22px; background: #F2F5F4;
///   upload icon: 10.95x10.69 #1C2926;
///   "Upload" (Inter 500 Medium 10px #1C2926);
///   "JPG, PNG" (Inter 400 Regular 8px #566663);
class ProviderDocumentUploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String statusText;
  final String imageAsset;
  final VoidCallback? onUpload;
  final bool isUploaded;
  final String? uploadedFileName;

  const ProviderDocumentUploadCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.statusText = 'Valid and not expired',
    required this.imageAsset,
    this.onUpload,
    this.isUploaded = false,
    this.uploadedFileName,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 93.29783630371094;
  static const double imageWidth = 88.0;
  static const double imageHeight = 56.0;
  static const double uploadBoxWidth = 72.0;
  static const double uploadBoxHeight = 61.29783630371094;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: Container(
          width: double.infinity,
          height: designHeight,
          padding: const EdgeInsets.all(16.0), // padding: 16px
          decoration: BoxDecoration(
            color: Colors.white, // background: #FFFFFF
            borderRadius: BorderRadius.circular(16.0), // border-radius: 16px
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000), // box-shadow: 0px 1px 12px 0px #0000001A
                offset: Offset(0, 1),
                blurRadius: 12.0,
                spreadRadius: 0.0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // justify-content: space-between
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Content Layout: takes available width
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Image Framer: width: 88; height: 56; border-radius: 6px;
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.0),
                      child: Container(
                        width: imageWidth,
                        height: imageHeight,
                        color: const Color(0xFFF2F5F4),
                        child: Image.asset(
                          imageAsset,
                          width: imageWidth,
                          height: imageHeight,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _DocumentThumbnailFallback(title: title),
                        ),
                      ),
                    ),

                    // gap: 12px
                    const SizedBox(width: 12.0),

                    // Text Content Layout
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title: ProviderTextStyles.stepCardTitle
                          Text(
                            context.isArabic ? context.auto(title) : title,
                            style: ProviderTextStyles.stepCardTitle,
                            maxLines: 1,
                          ),

                          const SizedBox(height: 3.0),

                          // Subtitle 1: ProviderTextStyles.stepCardSubtitle
                          Text(
                            context.isArabic ? context.auto(subtitle) : subtitle,
                            style: ProviderTextStyles.stepCardSubtitle,
                            maxLines: 1,
                          ),

                          const SizedBox(height: 2.0),

                          // Subtitle 2: statusText (ProviderTextStyles.stepCardSubtitle)
                          Text(
                            context.isArabic ? context.auto(statusText) : statusText,
                            style: ProviderTextStyles.stepCardSubtitle,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8.0),

              // Right Side Upload Box:
              // width: 72; height: 61.29783630371094; border-radius: 8px;
              // background: #F2F5F4; border: 0.8px dashed #D3E0DC;
              _UploadBoxWidget(
                onTap: onUpload,
                isUploaded: isUploaded,
                uploadedFileName: uploadedFileName,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Right Side Upload Box with Dashed Border (0.8px, dashes: 3, 3, color #D3E0DC)
class _UploadBoxWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isUploaded;
  final String? uploadedFileName;

  const _UploadBoxWidget({
    this.onTap,
    this.isUploaded = false,
    this.uploadedFileName,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: CustomPaint(
          painter: const _DashedRRectPainter(
            color: Color(0xFFD3E0DC), // border: 0.8px solid #D3E0DC (dashed)
            strokeWidth: 0.8,
            radius: 8.0,
            dashLength: 3.0,
            dashGap: 3.0,
          ),
          child: Container(
            width: ProviderDocumentUploadCard.uploadBoxWidth, // 72px
            height: ProviderDocumentUploadCard.uploadBoxHeight, // 61.3px
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 6.0,
            ),
            decoration: BoxDecoration(
              color: isUploaded
                  ? ProviderColors.primaryButton.withValues(alpha: 0.08)
                  : const Color(0xFFF2F5F4), // background: #F2F5F4
              borderRadius: BorderRadius.circular(8.0), // border-radius: 8px
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isUploaded) ...[
                  Container(
                    width: 18.0,
                    height: 18.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EAFE),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE9E0FE), // border: 0.5px solid #E9E0FE
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 12.0,
                        height: 12.0,
                        decoration: const BoxDecoration(
                          color: Color(0xFF8B53FE), // background: #8B53FE
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 8.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    context.l10n.uploaded,
                    style: ProviderTextStyles.stepCardSubtitle.copyWith(
                      fontSize: 9.0,
                      fontWeight: FontWeight.w600,
                      color: ProviderColors.primaryButton,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  // Upload Vector Icon: width: 10.95; height: 10.69; color: #1C2926;
                  const SizedBox(
                    width: 11.0,
                    height: 11.0,
                    child: CustomPaint(
                      painter: _UploadTrayArrowPainter(
                        color: Color(0xFF1C2926),
                      ),
                    ),
                  ),

                  const SizedBox(height: 3.0),

                  // Content: Upload
                  Text(
                    context.l10n.uploadButtonText,
                    style: ProviderTextStyles.stepCardSubtitle.copyWith(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1C2926),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 1.0),

                  // Content: JPG, PNG
                  Text(
                    'JPG, PNG',
                    style: ProviderTextStyles.stepCardSubtitle.copyWith(
                      fontSize: 8.0,
                      height: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Upload Vector Icon Painter (Tray + Upward Arrow)
class _UploadTrayArrowPainter extends CustomPainter {
  final Color color;
  const _UploadTrayArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double w = size.width;
    final double h = size.height;

    // Bottom tray: |_|
    final tray = Path()
      ..moveTo(0.8, h * 0.72)
      ..lineTo(0.8, h - 0.8)
      ..lineTo(w - 0.8, h - 0.8)
      ..lineTo(w - 0.8, h * 0.72);
    canvas.drawPath(tray, paint);

    // Upward arrow stem
    canvas.drawLine(
      Offset(w / 2.0, h * 0.70),
      Offset(w / 2.0, 0.8),
      paint,
    );

    // Arrowhead: ^
    final head = Path()
      ..moveTo(w * 0.22, h * 0.36)
      ..lineTo(w / 2.0, 0.8)
      ..lineTo(w * 0.78, h * 0.36);
    canvas.drawPath(head, paint);
  }

  @override
  bool shouldRepaint(covariant _UploadTrayArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// CustomPainter that renders a dashed rounded rectangle:
/// dashes: 3, 3; border-width: 0.8px;
class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashLength;
  final double dashGap;

  const _DashedRRectPainter({
    required this.color,
    this.strokeWidth = 0.8,
    this.radius = 8.0,
    this.dashLength = 3.0,
    this.dashGap = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final dashedPath = _createDashedPath(path, dashLength, dashGap);
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source, double dashLength, double dashGap) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final length = draw ? dashLength : dashGap;
        if (distance + length > metric.length) {
          if (draw) {
            dest.addPath(
              metric.extractPath(distance, metric.length),
              Offset.zero,
            );
          }
          break;
        }
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius;
}

/// Procedural Fallback Card Thumbnail (if offline or image loading)
class _DocumentThumbnailFallback extends StatelessWidget {
  final String title;
  const _DocumentThumbnailFallback({required this.title});

  @override
  Widget build(BuildContext context) {
    final bool isCar = title.toLowerCase().contains('vehicle');
    return Container(
      width: ProviderDocumentUploadCard.imageWidth,
      height: ProviderDocumentUploadCard.imageHeight,
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F8),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: const Color(0xFFE2EBE8), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left avatar or vehicle icon
          Container(
            width: 24.0,
            height: 32.0,
            decoration: BoxDecoration(
              color: const Color(0xFFE2ECE8),
              borderRadius: BorderRadius.circular(3.0),
            ),
            child: Icon(
              isCar ? Icons.directions_car : Icons.person,
              size: 16.0,
              color: const Color(0xFF566663),
            ),
          ),
          const SizedBox(width: 5.0),
          // Right lines
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 3.0,
                  width: double.infinity,
                  color: const Color(0xFFB8C8C4),
                ),
                const SizedBox(height: 3.0),
                Container(
                  height: 2.5,
                  width: 32.0,
                  color: const Color(0xFFD3E0DC),
                ),
                const SizedBox(height: 3.0),
                Container(
                  height: 2.5,
                  width: 40.0,
                  color: const Color(0xFFD3E0DC),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
