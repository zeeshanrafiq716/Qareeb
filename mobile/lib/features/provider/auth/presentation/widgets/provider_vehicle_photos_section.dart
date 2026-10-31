import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_image_picker_modal.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_vehicle_photo_card.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Provider Vehicle Photos Section Widget
/// Implements exact Figma branding specifications with 2 rows (4 photos):
///
/// Row 1: Front View & Rear View
/// Row 2: Left Side View & Right Side View
///
/// Allows uploading real vehicle photos using Camera or Gallery.
class ProviderVehiclePhotosSection extends StatefulWidget {
  final VoidCallback? onFrontUpload;
  final VoidCallback? onRearUpload;
  final VoidCallback? onLeftSideUpload;
  final VoidCallback? onRightSideUpload;
  final Function(String viewKey, Uint8List? bytes)? onPhotoChanged;

  const ProviderVehiclePhotosSection({
    super.key,
    this.onFrontUpload,
    this.onRearUpload,
    this.onLeftSideUpload,
    this.onRightSideUpload,
    this.onPhotoChanged,
  });

  static const double designWidth = 350.0;
  static const double sectionGap = 16.0;
  static const double cardGap = 12.0;

  @override
  State<ProviderVehiclePhotosSection> createState() =>
      _ProviderVehiclePhotosSectionState();
}

class _ProviderVehiclePhotosSectionState
    extends State<ProviderVehiclePhotosSection> {
  Uint8List? _frontImageBytes;
  Uint8List? _rearImageBytes;
  Uint8List? _leftSideImageBytes;
  Uint8List? _rightSideImageBytes;

  bool _frontUploaded = false;
  bool _rearUploaded = false;
  bool _leftSideUploaded = false;
  bool _rightSideUploaded = false;

  Future<void> _handleCardTap({
    required String viewKey,
    required String viewTitle,
    required bool isUploaded,
    required Function(Uint8List? bytes, bool uploaded) onUpdate,
  }) async {
    final result = await ProviderImagePickerModal.show(
      context,
      title: viewTitle,
      isAlreadyUploaded: isUploaded,
    );

    if (!mounted || result == null) return;

    final isArabic = context.isArabic;

    if (result.action == DocPickerActionResult.picked && result.image != null) {
      // 1. Client-side sanity check: Reject empty or blank dummy files (< 5KB)
      if (result.image!.bytes.lengthInBytes < 5 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic
                  ? 'حجم الصورة صغير جداً أو غير واضح. يرجى التقاط صورة واضحة.'
                  : 'Image is too small or blank. Please upload a clear photo.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      onUpdate(result.image!.bytes, true);
      widget.onPhotoChanged?.call(viewKey, result.image!.bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                isArabic
                    ? 'تم اختيار صورة $viewTitle بنجاح'
                    : '$viewTitle photo selected successfully',
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
    } else if (result.action == DocPickerActionResult.cleared) {
      onUpdate(null, false);
      widget.onPhotoChanged?.call(viewKey, null);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                isArabic
                    ? 'تمت إزالة صورة $viewTitle'
                    : '$viewTitle photo removed',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF566663),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Opacity(
      opacity: 1.0,
      child: Transform.rotate(
        angle: 0.0,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Heading Layout: Title & Subtitle
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title: Vehicle Photos
                    Text(
                      l10n.vehiclePhotosTitle,
                      style: ProviderTextStyles.whatsNextTitle,
                      maxLines: 1,
                    ),

                    const SizedBox(height: 4.0),

                    // Subtitle: Upload 4 photos of your vehicle (Front, Rear, and Sides)
                    Text(
                      l10n.vehiclePhotosSubtitle,
                      style: ProviderTextStyles.stepCardSubtitle,
                      maxLines: 2,
                      softWrap: true,
                    ),
                  ],
                ),
              ),

              // gap: 16px
              const SizedBox(height: ProviderVehiclePhotosSection.sectionGap),

              // 2. Framers Layout - Row 1: Front View & Rear View
              Row(
                children: [
                  // Front View Card
                  Expanded(
                    child: ProviderVehiclePhotoCard(
                      title: l10n.frontView,
                      subtitle: l10n.tapToUpload,
                      imageAsset: 'assets/images/vehicle_photo_front_view.jpg',
                      imageBytes: _frontImageBytes,
                      isUploaded: _frontUploaded,
                      onUpload: () {
                        widget.onFrontUpload != null
                            ? widget.onFrontUpload!()
                            : _handleCardTap(
                                viewKey: 'front',
                                viewTitle: l10n.frontView,
                                isUploaded: _frontUploaded,
                                onUpdate: (bytes, uploaded) {
                                  setState(() {
                                    _frontImageBytes = bytes;
                                    _frontUploaded = uploaded;
                                  });
                                },
                              );
                      },
                    ),
                  ),

                  // gap: 12px
                  const SizedBox(width: ProviderVehiclePhotosSection.cardGap),

                  // Rear View Card
                  Expanded(
                    child: ProviderVehiclePhotoCard(
                      title: l10n.rearView,
                      subtitle: l10n.tapToUpload,
                      imageAsset: 'assets/images/vehicle_photo_rear_view.jpg',
                      imageBytes: _rearImageBytes,
                      isUploaded: _rearUploaded,
                      onUpload: () {
                        widget.onRearUpload != null
                            ? widget.onRearUpload!()
                            : _handleCardTap(
                                viewKey: 'rear',
                                viewTitle: l10n.rearView,
                                isUploaded: _rearUploaded,
                                onUpdate: (bytes, uploaded) {
                                  setState(() {
                                    _rearImageBytes = bytes;
                                    _rearUploaded = uploaded;
                                  });
                                },
                              );
                      },
                    ),
                  ),
                ],
              ),

              // gap between rows: 12px
              const SizedBox(height: ProviderVehiclePhotosSection.cardGap),

              // 3. Framers Layout - Row 2: Left Side View & Right Side View
              Row(
                children: [
                  // Left Side View Card
                  Expanded(
                    child: ProviderVehiclePhotoCard(
                      title: l10n.leftSideView,
                      subtitle: l10n.tapToUpload,
                      imageAsset: 'assets/images/vehicle_photo_front_view.jpg',
                      imageBytes: _leftSideImageBytes,
                      isUploaded: _leftSideUploaded,
                      onUpload: () {
                        widget.onLeftSideUpload != null
                            ? widget.onLeftSideUpload!()
                            : _handleCardTap(
                                viewKey: 'left_side',
                                viewTitle: l10n.leftSideView,
                                isUploaded: _leftSideUploaded,
                                onUpdate: (bytes, uploaded) {
                                  setState(() {
                                    _leftSideImageBytes = bytes;
                                    _leftSideUploaded = uploaded;
                                  });
                                },
                              );
                      },
                    ),
                  ),

                  // gap: 12px
                  const SizedBox(width: ProviderVehiclePhotosSection.cardGap),

                  // Right Side View Card
                  Expanded(
                    child: ProviderVehiclePhotoCard(
                      title: l10n.rightSideView,
                      subtitle: l10n.tapToUpload,
                      imageAsset: 'assets/images/vehicle_photo_rear_view.jpg',
                      imageBytes: _rightSideImageBytes,
                      isUploaded: _rightSideUploaded,
                      onUpload: () {
                        widget.onRightSideUpload != null
                            ? widget.onRightSideUpload!()
                            : _handleCardTap(
                                viewKey: 'right_side',
                                viewTitle: l10n.rightSideView,
                                isUploaded: _rightSideUploaded,
                                onUpdate: (bytes, uploaded) {
                                  setState(() {
                                    _rightSideImageBytes = bytes;
                                    _rightSideUploaded = uploaded;
                                  });
                                },
                              );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
