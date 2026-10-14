import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/home/presentation/widgets/home_header_widget.dart';
import 'package:mobile/features/splash/presentation/widgets/branding_header_widget.dart';

import 'package:mobile/features/home/presentation/home_screen.dart';
import 'package:mobile/features/home/presentation/widgets/category_card_widget.dart';
import 'package:mobile/features/home/presentation/widgets/services_section_widget.dart';
import 'package:mobile/features/home/presentation/widgets/urgent_assistance_card.dart';
import 'package:mobile/features/home/presentation/widgets/bottom_nav_bar_widget.dart';
import 'package:mobile/features/emergency/presentation/emergency_services_screen.dart';
import 'package:mobile/features/location/presentation/location_permission_screen.dart';
import 'package:mobile/features/location/presentation/pickup_delivery_screen.dart';
import 'package:mobile/features/profile/presentation/profile_screen.dart';
import 'package:mobile/features/requests/presentation/requests_screen.dart';

void main() {
  testWidgets('Qareeb branding title and slogan render correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BrandingHeaderWidget(),
        ),
      ),
    );

    // Verify QAREEB branding text and slogan match specifications
    expect(find.text('QAREEB'), findsOneWidget);
    expect(find.text('People. Services. Closer.'), findsOneWidget);
  });

  testWidgets('HomeHeaderWidget renders greeting, location, notification button, and urgent assistance card', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomeHeaderWidget(),
        ),
      ),
    );

    expect(find.text('Hello, Shayan'), findsOneWidget);
    expect(find.text('Explore Something'), findsOneWidget);
    expect(find.text('Current location'), findsOneWidget);
    expect(find.text('Karachi Pakistan'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    expect(find.byType(UrgentAssistanceCard), findsOneWidget);
    expect(find.text('Need urgent assistance?'), findsOneWidget);
    expect(find.text('Get Help Now'), findsOneWidget);
  });

  testWidgets('HomeScreen renders ServicesSectionWidget with CategoryCardWidgets', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    expect(find.byType(ServicesSectionWidget), findsOneWidget);
    expect(find.text('Choose Your Ride'), findsOneWidget);
    expect(find.text('Choose a service and see available options.'), findsOneWidget);
    // All 6 CategoryCardWidgets (Row 1: Ride, Pickup; Row 2: Rider, Van; Row 3: Auto, Emergency)
    expect(find.byType(CategoryCardWidget), findsNWidgets(6));
    expect(find.text('Ride'), findsOneWidget);
    expect(find.text('City & local rides'), findsOneWidget);
    expect(find.text('Pickup'), findsOneWidget);
    expect(find.text('Goods & deliveries'), findsOneWidget);
    expect(find.text('Rider'), findsOneWidget);
    expect(find.text('Fast & convenient'), findsOneWidget);
    expect(find.text('Van'), findsOneWidget);
    expect(find.text('Group & family travel'), findsOneWidget);
    expect(find.text('Auto'), findsOneWidget);
    expect(find.text('Affordable local travel'), findsOneWidget);
    expect(find.text('Emergency'), findsOneWidget);
    expect(find.text('Urgent roadside aid'), findsOneWidget);
    expect(find.byType(BottomNavBarWidget, skipOffstage: true), findsOneWidget);
    expect(find.text('Home', skipOffstage: true), findsOneWidget);
    expect(find.byType(StylizedHomeIcon, skipOffstage: true), findsOneWidget);
    expect(find.text('Request', skipOffstage: true), findsOneWidget);
    expect(find.byType(StylizedRequestIcon, skipOffstage: true), findsOneWidget);
    expect(find.text('Profile', skipOffstage: true), findsOneWidget);
    expect(find.byType(StylizedProfileIcon, skipOffstage: true), findsOneWidget);
  });

  testWidgets('HomeScreen switches between Home, Request, and Profile tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Initial state: Home tab is active
    expect(find.text('Choose Your Ride', skipOffstage: true), findsOneWidget);

    // Tap Request tab
    await tester.tap(find.text('Request', skipOffstage: true));
    await tester.pumpAndSettle();

    // Requests screen is now active
    expect(find.byType(RequestsScreen, skipOffstage: true), findsOneWidget);

    // Tap Profile tab
    await tester.tap(find.text('Profile', skipOffstage: true));
    await tester.pumpAndSettle();

    // Profile screen is now active
    expect(find.byType(ProfileScreen, skipOffstage: true), findsOneWidget);

    // Tap Home tab
    await tester.tap(find.text('Home', skipOffstage: true));
    await tester.pumpAndSettle();

    // Home tab is active again
    expect(find.text('Choose Your Ride', skipOffstage: true), findsOneWidget);
  });

  testWidgets('EmergencyServicesScreen renders header gradient, cards, and bottom nav bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EmergencyServicesScreen(),
      ),
    );

    expect(find.byType(EmergencyServicesScreen), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.byType(BottomNavBarWidget), findsOneWidget);
    expect(find.text('Verified Providers'), findsOneWidget);
    expect(find.text('Quick Response'), findsOneWidget);
    expect(find.text('Live Tracking'), findsOneWidget);
    expect(find.text('Ambulance'), findsOneWidget);
    expect(find.text('Police'), findsOneWidget);
    expect(find.text('Fire Brigade'), findsOneWidget);
    // Verify mock status bar items (time 9:41 and battery icon) are removed
    expect(find.text('9:41'), findsNothing);
    expect(find.byIcon(Icons.battery_full_rounded), findsNothing);
  });

  testWidgets('LocationPermissionScreen renders background image, gradient, back button, and service title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LocationPermissionScreen(serviceName: 'Pickup & Delivery'),
      ),
    );

    expect(find.byType(LocationPermissionScreen), findsOneWidget);
    expect(find.text('Pickup & Delivery'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(2));
    expect(find.text('Nearby\nProviders'), findsOneWidget);
    expect(find.text('Fast\nDelivery'), findsOneWidget);
    expect(find.text('Real-time\nTracking'), findsOneWidget);
    expect(find.text('Find Providers near you'), findsOneWidget);
    expect(find.text('Wee need your location to show nearby\nproviders for Pickup & Delivery.'), findsOneWidget);
    expect(find.text('See nearby providers'), findsOneWidget);
    expect(find.text('Fast service'), findsOneWidget);
    expect(find.text('Your privacy matters'), findsOneWidget);
    expect(find.text('Your location is only used for this service and can be changed anhytime'), findsOneWidget);
    expect(find.text('Allow Location'), findsOneWidget);
    expect(find.textContaining('You can change this later in'), findsOneWidget);
  });

  testWidgets('PickupDeliveryScreen renders header with back button and service title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PickupDeliveryScreen(serviceName: 'Pickup & Delivery'),
        ),
      ),
    );

    expect(find.byType(PickupDeliveryScreen), findsOneWidget);
    expect(find.text('Pickup & Delivery'), findsOneWidget);
    expect(find.byKey(const Key('map_widget_beacon')), findsOneWidget);
    expect(find.byKey(const Key('current_location_button')), findsOneWidget);
    expect(find.byKey(const Key('user_gps_center_marker')), findsOneWidget);
    expect(find.byKey(const Key('radar_rotated_layout')), findsOneWidget);
    expect(find.byKey(const Key('animated_radar_sector')), findsOneWidget);
    expect(find.byKey(const ValueKey('fake_car_1')), findsOneWidget);
    expect(find.text('Uzair'), findsOneWidget);
    // Verify reviews/stars are removed from car badges
    expect(find.byIcon(Icons.star_rounded), findsNothing);

    // Verify tapping on fake_car_1 triggers selection card and selected state
    await tester.tap(find.byKey(const ValueKey('fake_car_1')));
    await tester.pump();

    expect(find.byKey(const Key('selected_driver_card')), findsOneWidget);
    expect(find.text('SELECTED'), findsOneWidget);
    expect(find.text('Confirm Uzair'), findsOneWidget);
  });
}

