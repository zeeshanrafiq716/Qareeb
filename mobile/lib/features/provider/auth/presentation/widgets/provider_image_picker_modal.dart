import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/image_picker_helper.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/features/provider/theme/provider_text_styles.dart';

/// Representation of a picked document or vehicle photo
class PickedDocImage {
  final Uint8List bytes;
  final String name;

  const PickedDocImage({
    required this.bytes,
    required this.name,
  });
}

enum DocPickerActionResult { picked, cleared, cancelled }

class DocPickerResult {
  final DocPickerActionResult action;
  final PickedDocImage? image;

  const DocPickerResult({
    required this.action,
    this.image,
  });
}

/// Image Picker Bottom Sheet Modal
/// Beautifully styled in accordance with Qareeb design standards.
/// Allows uploading real documents/vehicle photos via Camera or Gallery.
class ProviderImagePickerModal extends StatelessWidget {
  final String title;
  final bool isAlreadyUploaded;

  const ProviderImagePickerModal({
    super.key,
    required this.title,
    this.isAlreadyUploaded = false,
  });

  static Future<DocPickerResult?> show(
    BuildContext context, {
    required String title,
    bool isAlreadyUploaded = false,
  }) {
    return showModalBottomSheet<DocPickerResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) => ProviderImagePickerModal(
        title: title,
        isAlreadyUploaded: isAlreadyUploaded,
      ),
    );
  }

  Future<void> _pick(BuildContext context, ImageSource source) async {
    try {
      final picked = await pickImageCustom(source: source);

      if (!context.mounted) return;

      if (picked != null) {
        Navigator.of(context).pop(
          DocPickerResult(
            action: DocPickerActionResult.picked,
            image: PickedDocImage(bytes: picked.bytes, name: picked.name),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 20.0,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 28.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle bar
          Center(
            child: Container(
              width: 38.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: const Color(0xFFD3E0DC),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),

          const SizedBox(height: 16.0),

          // Header: Title & Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: ProviderTextStyles.cardHeadingTitle.copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20.0, color: Color(0xFF566663)),
                onPressed: () => Navigator.of(context).pop(
                  const DocPickerResult(action: DocPickerActionResult.cancelled),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 6.0),

          Text(
            isArabic
                ? 'يرجى التأكد من وضوح الصورة وعدم انتهاء صلاحية الوثيقة'
                : 'Ensure image is clear, sharp, and document is valid',
            style: ProviderTextStyles.stepCardSubtitle.copyWith(fontSize: 11.5),
          ),

          const SizedBox(height: 20.0),

          // Option 1: Take Photo (Camera)
          _PickerOptionCard(
            icon: Icons.camera_alt_outlined,
            iconBg: const Color(0xFFE8F5E9),
            iconColor: const Color(0xFF2E7D32),
            title: isArabic ? 'التقاط صورة بالكاميرا' : 'Take Photo with Camera',
            subtitle: isArabic
                ? 'التقاط صورة حية ومباشرة للمستند'
                : 'Capture real live photo directly',
            onTap: () => _pick(context, ImageSource.camera),
          ),

          const SizedBox(height: 10.0),

          // Option 2: Choose from Gallery / Files
          _PickerOptionCard(
            icon: Icons.photo_library_outlined,
            iconBg: const Color(0xFFE0F2FE),
            iconColor: const Color(0xFF0284C7),
            title: isArabic ? 'اختيار من المعرض أو الملفات' : 'Choose from Gallery / Files',
            subtitle: isArabic
                ? 'رفع صورة محفوظة مسبقاً بجودة عالية'
                : 'Select high-quality saved image',
            onTap: () => _pick(context, ImageSource.gallery),
          ),

          // Option 3 (if already uploaded): Remove current photo
          if (isAlreadyUploaded) ...[
            const SizedBox(height: 10.0),
            _PickerOptionCard(
              icon: Icons.delete_outline_rounded,
              iconBg: const Color(0xFFFFEBEE),
              iconColor: const Color(0xFFD32F2F),
              title: isArabic ? 'حذف الصورة الحالية' : 'Remove Current Photo',
              subtitle: isArabic
                  ? 'إلغاء رفع هذه الوثيقة'
                  : 'Clear and remove this document',
              onTap: () {
                Navigator.of(context).pop(
                  const DocPickerResult(action: DocPickerActionResult.cleared),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _PickerOptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PickerOptionCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: ProviderColors.inputBackground, // #F2F5F4
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: const Color(0xFFD3E0DC),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(icon, color: iconColor, size: 22.0),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ProviderTextStyles.cardHeadingTitle.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      subtitle,
                      style: ProviderTextStyles.stepCardSubtitle.copyWith(
                        fontSize: 11.0,
                        color: const Color(0xFF71827E),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.0,
                color: Color(0xFF9AA7A3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
