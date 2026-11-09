import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/localization/app_locale.dart';
import 'package:mobile/features/provider/auth/data/provider_registration_state.dart';
import 'package:mobile/features/provider/home/presentation/widgets/provider_vehicle_card.dart';
import 'package:mobile/features/provider/auth/presentation/provider_onboarding_details_screen.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_auth_card.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_card_bottom_indicator.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_document_upload_card.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_otp_card.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_upload_documents_list.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_admin_approval_content_layout.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_admin_approval_heading.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_admin_approval_status_card.dart';
import 'package:mobile/features/provider/auth/presentation/widgets/provider_got_it_button.dart';
import 'package:mobile/features/provider/auth/presentation/provider_blocked_screen.dart';
import 'package:mobile/features/provider/home/presentation/provider_home_screen.dart';

Widget _buildTestApp(Widget home) {
  return ProviderScope(
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    ),
  );
}

void main() {
  testWidgets('Phone number screen has no Full Name field and no disturbing bottom indicator', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        const Scaffold(
          body: ProviderAuthCard(),
        ),
      ),
    );
    await tester.pump();

    // Verify Full Name field was removed from Phone screen
    expect(find.text('Enter your full name'), findsNothing);

    // Verify ProviderCardBottomIndicator is NOT present on the auth card
    expect(find.byType(ProviderCardBottomIndicator), findsNothing);

    await tester.pumpWidget(
      _buildTestApp(
        const Scaffold(
          body: ProviderOtpCard(),
        ),
      ),
    );
    await tester.pump();

    // Verify ProviderCardBottomIndicator is NOT present on the OTP card
    expect(find.byType(ProviderCardBottomIndicator), findsNothing);
  });

  testWidgets('ProviderOnboardingDetailsScreen renders personal & category dropdown fields without default data and without overflow', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        const ProviderOnboardingDetailsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Check personal info fields (empty initial text)
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Enter your full name'), findsOneWidget);
    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Read-only'), findsOneWidget);
    expect(find.text('WhatsApp number (Optional)'), findsOneWidget);

    // Check category & vehicle dropdown fields
    expect(find.text('Service Category'), findsOneWidget);
    expect(find.text('Select Service Category'), findsOneWidget);
    expect(find.text('Vehicle Type'), findsOneWidget);
    expect(find.text('Select Vehicle Type'), findsOneWidget);

    // Check vehicle text fields (empty initial text)
    expect(find.text('Plate Number'), findsOneWidget);
    expect(find.text('Vehicle Color'), findsOneWidget);

    // Check continue button
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('ProviderDocumentUploadCard displays clean title without asterisk/stars', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        const Scaffold(
          body: ProviderDocumentUploadCard(
            title: 'Iqama',
            subtitle: 'Upload a clear Iqama image.',
            imageAsset: 'assets/images/iqama_sample.jpg',
            isRequired: true,
          ),
        ),
      ),
    );
    await tester.pump();

    // Verify title is rendered cleanly without any '*'
    expect(find.text('Iqama'), findsOneWidget);
    expect(find.text(' *'), findsNothing);
    expect(find.text('Iqama *'), findsNothing);
  });

  testWidgets('ProviderUploadDocumentsList enforces compulsory documents and vehicle photos before continuing', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        const Scaffold(
          body: SingleChildScrollView(
            child: ProviderUploadDocumentsList(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Ensure Continue button is scrolled into view and tap
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pump();

    // Verify compulsory warning snackbar shows
    expect(find.textContaining('All documents and vehicle photos are compulsory'), findsOneWidget);
  });

  testWidgets('ProviderVehicleCard displays real data configured during onboarding', (tester) async {
    // Populate store with real provider onboarding data
    ProviderRegistrationStore.instance.update(
      (data) => data.copyWith(
        fullName: 'Kinza Test',
        serviceCategory: 'Vehicle Towing',
        vehicleType: 'Pickup Truck',
        plateNumber: 'KSA 7788',
      ),
    );

    await tester.pumpWidget(
      _buildTestApp(
        const Scaffold(
          body: ProviderVehicleCard(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify real onboarding data is rendered
    expect(find.text('Pickup Truck'), findsOneWidget);
    expect(find.text('Available for Vehicle Towing'), findsOneWidget);
    expect(find.text('KSA 7788'), findsOneWidget);
    expect(find.text('Vehicle Towing'), findsOneWidget);
  });

  testWidgets('AdminApprovalScreen displays red rejection card when documents are suspended', (tester) async {
    ProviderRegistrationStore.instance.update(
      (data) => data.copyWith(
        status: 'SUSPENDED',
      ),
    );

    await tester.pumpWidget(
      _buildTestApp(
        const Scaffold(
          body: SingleChildScrollView(
            child: ProviderAdminApprovalContentLayout(
              isSuspended: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify rejection title and text are rendered in red style
    expect(find.text('Your approval is rejected'), findsOneWidget);
    expect(
      find.text('Your account documents were not approved by admin. Please review your submitted documents or contact support.'),
      findsOneWidget,
    );
  });

  testWidgets('AdminApprovalScreen displays Resubmission Requested card and re-upload button', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        Scaffold(
          body: SingleChildScrollView(
            child: ProviderAdminApprovalContentLayout(
              heading: const ProviderAdminApprovalHeading(
                title: 'Resubmission Requested',
                subtitle: 'Admin requested document resubmission.',
              ),
              statusCard: const ProviderAdminApprovalStatusCard(
                isResubmission: true,
              ),
              actionButton: ProviderGotItButton(
                title: 'Re-upload Documents',
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Resubmission Requested'), findsAtLeastNWidgets(1));
    expect(find.text('Re-upload Documents'), findsOneWidget);
  });

  testWidgets('AdminApprovalScreen automatically redirects to ProviderHomeScreen when approved', (tester) async {
    ProviderRegistrationStore.instance.update(
      (data) => data.copyWith(
        status: 'APPROVED',
      ),
    );

    await tester.pumpWidget(
      _buildTestApp(
        const Scaffold(
          body: SingleChildScrollView(
            child: ProviderAdminApprovalContentLayout(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Should have redirected to ProviderHomeScreen
    expect(find.byType(ProviderHomeScreen), findsOneWidget);
  });

  testWidgets('ProviderBlockedScreen displays blocked alert, reason and actions', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        const ProviderBlockedScreen(
          reason: 'Terms violation test reason',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Account Blocked'), findsOneWidget);
    expect(find.textContaining('Terms violation test reason'), findsOneWidget);
    expect(find.text('Contact Support'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
  });

  testWidgets('ProviderAdminApprovalStatusCard displays suspended status correctly', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        const Scaffold(
          body: ProviderAdminApprovalStatusCard(
            isSuspended: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Account suspended by Admin'), findsOneWidget);
  });
}
