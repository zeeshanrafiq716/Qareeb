import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_vehicle_photo_card.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

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
  static const double designHeight = 212.0;
  static const double headingHeight = 29.0;
  static const double framersHeight = 166.0;
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
              context.isArabic
                  ? (!current ? 'تم اختيار صورة $viewName' : 'تمت إزالة صورة $viewName')
                  : (!current ? '$viewName photo selected' : '$viewName photo removed'),
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
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Heading Layout: width: double.infinity; height: 29; gap: 12px;
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title: Vehicle Photos (ProviderTextStyles.whatsNextTitle)
                    Text(
                      context.l10n.vehiclePhotosTitle,
                      style: ProviderTextStyles.whatsNextTitle,
                      maxLines: 1,
                    ),

                    const SizedBox(height: 4.0),

                    // Subtitle: Upload front and rear photos of your vehicle
                    Text(
                      context.l10n.vehiclePhotosSubtitle,
                      style: ProviderTextStyles.stepCardSubtitle,
                      maxLines: 2,
                      softWrap: true,
                    ),
                  ],
                ),
              ),

              // gap: 16px
              const SizedBox(height: ProviderVehiclePhotosSection.sectionGap),

              // 2. Framers Layout: width: double.infinity; height: 158; gap: 12px;
              SizedBox(
                width: double.infinity,
                height: ProviderVehiclePhotosSection.framersHeight,
                child: Row(
                  children: [
                    // 1st Card: Front View
                    Expanded(
                      child: ProviderVehiclePhotoCard(
                        title: context.l10n.frontView,
                        subtitle: context.l10n.tapToUpload,
                        imageAsset: 'assets/images/vehicle_photo_front_view.jpg',
                        isUploaded: _frontUploaded,
                        onUpload: () {
                          widget.onFrontUpload != null
                              ? widget.onFrontUpload!()
                              : _handleUpload(
                                  context.l10n.frontView,
                                  (val) => _frontUploaded = val,
                                  _frontUploaded,
                                );
                        },
                      ),
                    ),

                    // gap: 12px;
                    const SizedBox(width: 12.0),

                    // 2nd Card: Rear View
                    Expanded(
                      child: ProviderVehiclePhotoCard(
                        title: context.l10n.rearView,
                        subtitle: context.l10n.tapToUpload,
                        imageAsset: 'assets/images/vehicle_photo_rear_view.jpg',
                        isUploaded: _rearUploaded,
                        onUpload: () {
                          widget.onRearUpload != null
                              ? widget.onRearUpload!()
                              : _handleUpload(
                                  context.l10n.rearView,
                                  (val) => _rearUploaded = val,
                                  _rearUploaded,
                                );
                        },
                      ),
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
