import 'package:flutter/material.dart';
import 'package:mobile/features/provider/auth/presentation/provider_location_permission_screen.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_bottom_indicator.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_continue_button.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_document_upload_card.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_vehicle_photos_section.dart';
import 'package:mobile/features/provider/theme/provider_colors.dart';

/// Provider Upload Documents List Widget
/// Implements all 3 document cards with exact branding and equal gap:
///
/// 1. Card 1: Iqama (width: 350, height: 93.3, bg: #FFFFFF, shadow)
///    gap: 16px
/// 2. Card 2: Vehicle Registration (width: 350, height: 93.3, bg: #FFFFFF, shadow)
///    gap: 16px
/// 3. Card 3: Driving Licence (width: 350, height: 93.3, bg: #FFFFFF, shadow)
///    gap: 24px
/// 4. Continue Button (width: 100%, height: 52, radius: 12, bg: #1D8070, text: Continue ->)
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
  bool _iqamaUploaded = false;
  bool _registrationUploaded = false;
  bool _licenceUploaded = false;

  void _handleUpload(String docName, Function(bool) setUploaded, bool current) {
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
              !current ? '$docName uploaded successfully' : '$docName removed',
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
    return SizedBox(
      width: ProviderUploadDocumentsList.designWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Card 1: Iqama
          ProviderDocumentUploadCard(
            title: 'Iqama',
            subtitle: 'Upload a clear Iqama image.',
            statusText: 'Valid and not expired',
            imageAsset: 'assets/images/iqama_sample_card.jpg',
            isUploaded: _iqamaUploaded,
            onUpload: () => _handleUpload(
              'Iqama',
              (val) => _iqamaUploaded = val,
              _iqamaUploaded,
            ),
          ),

          // Equal gap: 16px
          SizedBox(height: widget.cardGap),

          // 2. Card 2: Vehicle Registration
          ProviderDocumentUploadCard(
            title: 'Vehicle Registration',
            subtitle: 'Upload a clear Iqama image.',
            statusText: 'Valid and not expired',
            imageAsset: 'assets/images/vehicle_registration_sample_card.jpg',
            isUploaded: _registrationUploaded,
            onUpload: () => _handleUpload(
              'Vehicle Registration',
              (val) => _registrationUploaded = val,
              _registrationUploaded,
            ),
          ),

          // Equal gap: 16px
          SizedBox(height: widget.cardGap),

          // 3. Card 3: Driving Licence
          ProviderDocumentUploadCard(
            title: 'Driving Licence',
            subtitle: 'Upload a clear licence image.',
            statusText: 'Valid and not expired',
            imageAsset: 'assets/images/driving_licence_sample_card.jpg',
            isUploaded: _licenceUploaded,
            onUpload: () => _handleUpload(
              'Driving Licence',
              (val) => _licenceUploaded = val,
              _licenceUploaded,
            ),
          ),

          // Section Gap: 20px
          const SizedBox(height: 20.0),

          // Next Widget: Vehicle Photos Section (width: 350, height: 203, gap: 16px)
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
