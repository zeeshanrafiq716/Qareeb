import 'package:flutter/material.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Vehicle Photo Card Widget
/// Implements exact Figma branding specifications:
///
/// 1st card layout:
///   width: 167;
///   height: 158;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 16px;
///   border-width: 1px;
///   border-style: dashed;
///   dashes: 4, 4;
///   border: 1px solid #1D8070;
///
/// img layout:
///   width: 150.7112274169922;
///   height: 102.06349182128906;
///   top: 8px;
///   left: 8px;
///   angle: 0 deg;
///   opacity: 1;
///   border-radius: 12px;
///
/// uploader icon branding:
///   width: 30.955286026000977;
///   height: 30.697837829589844;
///   top: 44px;
///   left: 68px;
///   border-radius: 100px;
///   padding: 10px;
///   background: #FFFFFF;
///
/// inner layout (upload vector):
///   width: 10.955286026000977;
///   height: 10.697836875915527;
///   background: #1C2926;
///
/// content:
///   title: Front View / Rear View (Inter 500 Medium 12px #1C2926)
///   subtitle: Upload a clear photo (Inter 400 Regular 10px #566663)
class ProviderVehiclePhotoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageAsset;
  final VoidCallback? onUpload;
  final bool isUploaded;

  const ProviderVehiclePhotoCard({
    super.key,
    required this.title,
    this.subtitle = 'Upload a clear photo',
    required this.imageAsset,
    this.onUpload,
    this.isUploaded = false,
  });

  static const double cardWidth = 167.0;
  static const double cardHeight = 166.0;
  static const double imageWidth = 151.0;
  static const double imageHeight = 96.0;
  static const double uploadBadgeSize = 31.0;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: double.infinity,
          height: cardHeight,
          child: CustomPaint(
            painter: const _DashedCardBorderPainter(
              color: ProviderColors.primaryButton, // border: 1px dashed #1D8070
              strokeWidth: 1.0,
              radius: 16.0,
              dashLength: 4.0,
              dashGap: 4.0,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onUpload,
                borderRadius: BorderRadius.circular(16.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 6.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Image container with centered upload icon button overlay
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0), // border-radius: 12px
                        child: SizedBox(
                          width: double.infinity,
                          height: imageHeight,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Vehicle photo
                              Image.asset(
                                imageAsset,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _VehiclePhotoFallback(
                                  title: title,
                                ),
                              ),

                              // Uploader icon branding: 31x31 circular white button
                              Center(
                                child: Container(
                                  width: uploadBadgeSize,
                                  height: uploadBadgeSize,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x26000000),
                                        blurRadius: 6.0,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: isUploaded
                                      ? Center(
                                          child: Container(
                                            width: 22.0,
                                            height: 22.0,
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
                                                width: 15.0,
                                                height: 15.0,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF8B53FE), // background: #8B53FE
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.check_rounded,
                                                    size: 10.0,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : const Center(
                                          child: SizedBox(
                                            width: 11.0,
                                            height: 11.0,
                                            child: CustomPaint(
                                              painter: _VehicleUploadArrowPainter(
                                                color: Color(0xFF1C2926),
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 6.0),

                      // 2. Title: ProviderTextStyles.stepCardTitle
                      Text(
                        title,
                        style: ProviderTextStyles.stepCardTitle,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),

                      const SizedBox(height: 2.0),

                      // 3. Subtitle: ProviderTextStyles.stepCardSubtitle
                      Text(
                        subtitle,
                        style: ProviderTextStyles.stepCardSubtitle,
                        textAlign: TextAlign.center,
                        maxLines: 1,
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
}

/// Upload Vector Icon (tray + upward arrow in 11x11 #1C2926)
class _VehicleUploadArrowPainter extends CustomPainter {
  final Color color;
  const _VehicleUploadArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
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
      ..moveTo(w * 0.20, h * 0.38)
      ..lineTo(w / 2.0, 0.8)
      ..lineTo(w * 0.80, h * 0.38);
    canvas.drawPath(head, paint);
  }

  @override
  bool shouldRepaint(covariant _VehicleUploadArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// CustomPainter for dashed rounded rectangle with dashes: 4, 4; border: 1px solid #1D8070
class _DashedCardBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashLength;
  final double dashGap;

  const _DashedCardBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.radius = 16.0,
    this.dashLength = 4.0,
    this.dashGap = 4.0,
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
  bool shouldRepaint(covariant _DashedCardBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius;
}

/// Procedural Fallback if image asset is loading
class _VehiclePhotoFallback extends StatelessWidget {
  final String title;
  const _VehiclePhotoFallback({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE6EEEC),
      child: Center(
        child: Icon(
          Icons.local_shipping_outlined,
          size: 32.0,
          color: ProviderColors.primaryButton.withValues(alpha: 0.60),
        ),
      ),
    );
  }
}
