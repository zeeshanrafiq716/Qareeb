import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/data/provider_registration_state.dart';
import 'package:mobile/features/provider/auth/presentation/upload_documents_screen.dart';
import 'package:mobile/features/provider/auth/presentation/vehicle_service_details_screen.dart';
import 'package:mobile/features/provider/home/presentation/provider_home_screen.dart';

/// Helpers for skipping onboarding vs. completing it before going online.
class ProviderOnboardingGuard {
  ProviderOnboardingGuard._();

  static bool canGoOnline(ProviderRegistrationData data) => data.canGoOnline;

  /// Resume onboarding from Home in a streamlined 2-screen flow:
  /// Screen 1: Vehicle & Service Details (type, color, plate, category)
  /// Screen 2: Upload Documents (documents + vehicle photos) -> returns directly to Home.
  static void openOnboardingFlow(BuildContext context) {
    if (!context.mounted) return;
    final d = ProviderRegistrationStore.instance.data;

    final bool needsVehicleDetails = d.plateNumber.trim().isEmpty ||
        d.vehicleColor.trim().isEmpty ||
        d.serviceCategory.trim().isEmpty ||
        d.vehicleType.trim().isEmpty;

    final Widget destination = needsVehicleDetails
        ? const VehicleServiceDetailsScreen(fromHomeResume: true)
        : const UploadDocumentsScreen(fromHomeResume: true);

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => destination,
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  static void skipToHome(BuildContext context) {
    ProviderRegistrationStore.instance.update(
      (data) => data.copyWith(isOnline: false),
    );
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ProviderHomeScreen()),
      (_) => false,
    );
  }

  static void showMustCompleteOnboarding(
    BuildContext context,
    ProviderRegistrationData data,
  ) {
    final isArabic = context.isArabic;
    final message = isArabic
        ? 'أكمل التسجيل والتحقق من المستندات لتتمكن من الاتصال.'
        : 'Complete onboarding and document verification to go online.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1C2926),
        duration: const Duration(seconds: 5),
        content: Text(
          message,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        action: SnackBarAction(
          label: isArabic ? 'متابعة' : 'Continue',
          textColor: const Color(0xFF8B53FE),
          onPressed: () => openOnboardingFlow(context),
        ),
      ),
    );
  }
}

/// Text link to enter the app home without finishing onboarding.
class ProviderSkipOnboardingButton extends StatelessWidget {
  const ProviderSkipOnboardingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabic;
    final label = isArabic ? 'تخطي الآن' : 'Skip for now';

    return Center(
      child: TextButton(
        onPressed: () => ProviderOnboardingGuard.skipToHome(context),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF71717A),
            decoration: TextDecoration.underline,
            decorationColor: const Color(0xFF71717A),
          ),
        ),
      ),
    );
  }
}