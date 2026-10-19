import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_vehicle_photo_card.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';

/// Provider Vehicle Photos Section Widget
/// Implements exact Figma branding specifications:
///
/// next widget layout:
///   width: 350;
///   height: 203;
///   gap: 16px;
///   angle: 0 deg;
///   opacity: 1;
///
/// heading layout:
///   width: 350;
///   height: 29;
///   gap: 12px;
///
/// content: Vehicle Photos
///   Inter 500 Medium 14px line-height 22px #1C2926;
///
/// content: Upload front and rear photos of your vehicle
///   Inter 400 Regular 10px line-height 22px #566663;
///
/// framers layout:
///   width: 350;
///   height: 158;
///   gap: 16px;
///   Card 1: Front View (width: 167, height: 158, border: 1px dashed #1D8070)
///   gap: 16px
///   Card 2: Rear View (width: 167, height: 158, border: 1px dashed #1D8070)
class ProviderVehiclePhotosSection extends StatefulWidget {
  final VoidCallback? onFrontUpload;
  final VoidCallback? onRearUpload;

  const ProviderVehiclePhotosSection({
    super.key,
    this.onFrontUpload,
    this.onRearUpload,
  });

  static const double designWidth = 350.0;
  static const double designHeight = 203.0;
  static const double headingHeight = 29.0;
  static const double framersHeight = 158.0;
  static const double sectionGap = 16.0;
  static const double cardGap = 16.0;

  @override
  State<ProviderVehiclePhotosSection> createState() =>
      _ProviderVehiclePhotosSectionState();
}

class _ProviderVehiclePhotosSectionState
    extends State<ProviderVehiclePhotosSection> {
  bool _frontUploaded = false;
  bool _rearUploaded = false;

  void _handleUpload(String viewName, Function(bool) setUploaded, bool current) {
    setState(() {
      setUploaded(!current);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              !current ? '$viewName photo selected' : '$viewName photo removed',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
            ),
          ],
        ),
        backgroundColor: ProviderColors.primaryButton,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 1.0, // opacity: 1
      child: Transform.rotate(
        angle: 0.0, // angle: 0 deg
        child: SizedBox(
          width: ProviderVehiclePhotosSection.designWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Heading Layout: width: 350; height: 29; gap: 12px;
              SizedBox(
                width: ProviderVehiclePhotosSection.designWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title: Vehicle Photos (Inter 500 Medium 14px line-height 22px #1C2926)
                    Text(
                      'Vehicle Photos',
                      style: GoogleFonts.inter(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1C2926),
                        height: 1.15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4.0),

                    // Subtitle: Upload front and rear photos of your vehicle (Inter 400 Regular 10px line-height 22px #566663)
                    Text(
                      'Upload front and rear photos of your vehicle',
                      style: GoogleFonts.inter(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF566663),
                        height: 1.15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // gap: 16px
              const SizedBox(height: ProviderVehiclePhotosSection.sectionGap),

              // 2. Framers Layout: width: 350; height: 158; gap: 16px;
              SizedBox(
                width: ProviderVehiclePhotosSection.designWidth,
                height: ProviderVehiclePhotosSection.framersHeight,
                child: Row(
                  children: [
                    // 1st Card: Front View (width: 167; height: 158; border: 1px dashed #1D8070)
                    ProviderVehiclePhotoCard(
                      title: 'Front View',
                      subtitle: 'Upload a clear photo',
                      imageAsset: 'assets/images/vehicle_photo_front_view.jpg',
                      isUploaded: _frontUploaded,
                      onUpload: () {
                        widget.onFrontUpload != null
                            ? widget.onFrontUpload!()
                            : _handleUpload(
                                'Front view',
                                (val) => _frontUploaded = val,
                                _frontUploaded,
                              );
                      },
                    ),

                    // gap: 16px;
                    const SizedBox(width: ProviderVehiclePhotosSection.cardGap),

                    // 2nd Card: Rear View (width: 167; height: 158; border: 1px dashed #1D8070)
                    ProviderVehiclePhotoCard(
                      title: 'Rear View',
                      subtitle: 'Upload a clear photo',
                      imageAsset: 'assets/images/vehicle_photo_rear_view.jpg',
                      isUploaded: _rearUploaded,
                      onUpload: () {
                        widget.onRearUpload != null
                            ? widget.onRearUpload!()
                            : _handleUpload(
                                'Rear view',
                                (val) => _rearUploaded = val,
                                _rearUploaded,
                              );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
