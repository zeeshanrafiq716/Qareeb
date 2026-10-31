import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/data/provider_registration_state.dart';
import 'package:mobile/features/provider/auth/presentation/provider_location_permission_screen.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_bottom_indicator.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_continue_button.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_document_upload_card.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_image_picker_modal.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_vehicle_photos_section.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';
import 'package:mobile/services/backend_service.dart';

/// Provider Upload Documents List Widget
/// Implements all 3 document cards with real document photo uploads and 4 vehicle photos:
///
/// 1. Card 1: Iqama (width: 350, height: 93.3, bg: #FFFFFF, shadow)
///    gap: 16px
/// 2. Card 2: Vehicle Registration (width: 350, height: 93.3, bg: #FFFFFF, shadow)
///    gap: 16px
/// 3. Card 3: Driving Licence (width: 350, height: 93.3, bg: #FFFFFF, shadow)
///    gap: 20px
/// 4. Next Widget: Vehicle Photos Section (4 vehicle photos in 2 rows)
///    gap: 24px
/// 5. Continue Button (width: 100%, height: 52, radius: 12, bg: #1D8070, text: Continue ->)
class ProviderUploadDocumentsList extends StatefulWidget {
  final VoidCallback? onContinue;
  final double cardGap;
  final bool showContinueButton;

  const ProviderUploadDocumentsList({
    super.key,
    this.onContinue,
    this.cardGap = 16.0,
    this.showContinueButton = true,
  });

  static const double designWidth = 350.0;
  static const double defaultCardGap = 16.0;
  static const double buttonGap = 24.0;

  @override
  State<ProviderUploadDocumentsList> createState() =>
      _ProviderUploadDocumentsListState();
}

class _ProviderUploadDocumentsListState extends State<ProviderUploadDocumentsList> {
  late bool _iqamaUploaded;
  late bool _registrationUploaded;
  late bool _licenceUploaded;

  Uint8List? _iqamaBytes;
  Uint8List? _registrationBytes;
  Uint8List? _licenceBytes;

  String? _iqamaFileName;
  String? _registrationFileName;
  String? _licenceFileName;

  late final BackendService _backendService;

  @override
  void initState() {
    super.initState();
    final data = ProviderRegistrationStore.instance.data;
    _iqamaUploaded = data.iqamaUploaded;
    _registrationUploaded = data.registrationUploaded;
    _licenceUploaded = data.licenceUploaded;
    _backendService = BackendService(ApiClient());
  }

  Future<void> _handleDocUpload({
    required String docTypeKey,
    required String docName,
    required bool isUploaded,
    required Function(Uint8List? bytes, String? fileName, bool uploaded) onUpdate,
  }) async {
    final result = await ProviderImagePickerModal.show(
      context,
      title: docName,
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

      onUpdate(result.image!.bytes, result.image!.name, true);

      ProviderRegistrationStore.instance.update((data) {
        if (docTypeKey == 'iqama') {
          return data.copyWith(iqamaUploaded: true);
        } else if (docTypeKey == 'registration') {
          return data.copyWith(registrationUploaded: true);
        } else {
          return data.copyWith(licenceUploaded: true);
        }
      });

      // 2. Real multipart file upload with server-side clarity & anti-dummy check
      final uploadRes = await _backendService.submitVerificationDocument(
        documentType: docTypeKey,
        fileBytes: result.image!.bytes,
        fileName: result.image!.name,
      );

      if (!mounted) return;

      if (!uploadRes.success && uploadRes.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(uploadRes.errorMessage!),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isArabic
                      ? 'تم التحقق من جودة $docName ورفعها بنجاح'
                      : '$docName verified for quality and uploaded successfully',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                ),
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
      onUpdate(null, null, false);

      ProviderRegistrationStore.instance.update((data) {
        if (docTypeKey == 'iqama') {
          return data.copyWith(iqamaUploaded: false);
        } else if (docTypeKey == 'registration') {
          return data.copyWith(registrationUploaded: false);
        } else {
          return data.copyWith(licenceUploaded: false);
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                isArabic
                    ? 'تمت إزالة $docName'
                    : '$docName removed',
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
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Card 1: Iqama (Front)
          ProviderDocumentUploadCard(
            title: l10n.iqamaDocTitle,
            subtitle: l10n.iqamaDocSubtitle,
            statusText: l10n.docValidNotExpired,
            imageAsset: 'assets/images/iqama_sample_card.jpg',
            imageBytes: _iqamaBytes,
            isUploaded: _iqamaUploaded,
            uploadedFileName: _iqamaFileName,
            onUpload: () => _handleDocUpload(
              docTypeKey: 'iqama',
              docName: l10n.iqamaDocTitle,
              isUploaded: _iqamaUploaded,
              onUpdate: (bytes, name, val) {
                setState(() {
                  _iqamaBytes = bytes;
                  _iqamaFileName = name;
                  _iqamaUploaded = val;
                });
              },
            ),
          ),

          // Equal gap: 16px
          SizedBox(height: widget.cardGap),

          // 2. Card 2: Vehicle Registration (Front)
          ProviderDocumentUploadCard(
            title: l10n.vehicleRegDocTitle,
            subtitle: l10n.vehicleRegDocSubtitle,
            statusText: l10n.docValidNotExpired,
            imageAsset: 'assets/images/vehicle_registration_sample_card.jpg',
            imageBytes: _registrationBytes,
            isUploaded: _registrationUploaded,
            uploadedFileName: _registrationFileName,
            onUpload: () => _handleDocUpload(
              docTypeKey: 'registration',
              docName: l10n.vehicleRegDocTitle,
              isUploaded: _registrationUploaded,
              onUpdate: (bytes, name, val) {
                setState(() {
                  _registrationBytes = bytes;
                  _registrationFileName = name;
                  _registrationUploaded = val;
                });
              },
            ),
          ),

          // Equal gap: 16px
          SizedBox(height: widget.cardGap),

          // 3. Card 3: Driving Licence (Front)
          ProviderDocumentUploadCard(
            title: l10n.drivingLicenceDocTitle,
            subtitle: l10n.drivingLicenceDocSubtitle,
            statusText: l10n.docValidNotExpired,
            imageAsset: 'assets/images/driving_licence_sample_card.jpg',
            imageBytes: _licenceBytes,
            isUploaded: _licenceUploaded,
            uploadedFileName: _licenceFileName,
            onUpload: () => _handleDocUpload(
              docTypeKey: 'licence',
              docName: l10n.drivingLicenceDocTitle,
              isUploaded: _licenceUploaded,
              onUpdate: (bytes, name, val) {
                setState(() {
                  _licenceBytes = bytes;
                  _licenceFileName = name;
                  _licenceUploaded = val;
                });
              },
            ),
          ),

          // Section Gap: 20px
          const SizedBox(height: 20.0),

          // Next Widget: Vehicle Photos Section (4 photos in 2 rows)
          const ProviderVehiclePhotosSection(),

          // Proper gap below Vehicle Photos: 24px
          const SizedBox(height: ProviderUploadDocumentsList.buttonGap),

          // Continue Button: width: 100%, height: 52, radius: 12, bg: #1D8070, text: Continue ->
          ProviderContinueButton(
            onTap: widget.onContinue ?? () => _defaultOnContinue(context),
          ),

          // Flexible bottom indicator: scrolls naturally at the end of the content
          const SizedBox(height: 24.0),
          const ProviderCardBottomIndicator(),
          const SizedBox(height: 12.0),
        ],
      ),
    );
  }

  void _defaultOnContinue(BuildContext context) {
    final isArabic = context.isArabic;
    if (!_iqamaUploaded && !_licenceUploaded && !_registrationUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          backgroundColor: const Color(0xFF1C2926),
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.orangeAccent, size: 20.0),
              const SizedBox(width: 10.0),
              Expanded(
                child: Text(
                  isArabic
                      ? 'يرجى رفع المستندات المطلوبة (الإقامة ورخصة القيادة)'
                      : 'Please upload the required documents (Iqama and Driving Licence)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13.0,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    ProviderRegistrationStore.instance.update(
      (data) => data.copyWith(
        iqamaUploaded: _iqamaUploaded,
        registrationUploaded: _registrationUploaded,
        licenceUploaded: _licenceUploaded,
        status: 'PENDING_VERIFICATION',
      ),
    );

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ProviderLocationPermissionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}
