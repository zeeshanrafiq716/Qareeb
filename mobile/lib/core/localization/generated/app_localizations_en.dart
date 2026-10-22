// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'QAREEB';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSubtitle => 'Manage your account and preferences.';

  @override
  String get verifiedUser => 'Verified User';

  @override
  String get totalRequests => 'Total Requests';

  @override
  String get averageRating => 'Average Rating';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get personalInfoSubtitle => 'Name, phone number and more';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Manage your alerts and updates';

  @override
  String get language => 'Language';

  @override
  String get currentLanguageDisplay => 'English (US)';

  @override
  String get selectLanguageTitle => 'Select Language';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get savedLocations => 'Saved Locations';

  @override
  String get savedLocationsSubtitle => 'Home, Work, and other places';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get paymentMethodsSubtitle => 'Manage your payment options';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get privacySecuritySubtitle => 'Manage your data and security';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get helpSupportSubtitle => 'Find help or contact us';

  @override
  String get logOut => 'Log Out';

  @override
  String get logout => 'Logout';

  @override
  String greeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get exploreSomething => 'Explore Something';

  @override
  String get currentLocation => 'Current location';

  @override
  String get realGps => 'Real GPS';

  @override
  String get gpsDetecting => 'Detecting GPS...';

  @override
  String get urgentAssistance => 'Need urgent assistance?';

  @override
  String get getHelpNow => 'Get Help Now';

  @override
  String get chooseYourRide => 'Choose Your Ride';

  @override
  String get chooseRideSubtitle =>
      'Choose a service and see available options.';

  @override
  String get cancel => 'Cancel';

  @override
  String get done => 'Done';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get submit => 'Submit';

  @override
  String get navHome => 'Home';

  @override
  String get navRequests => 'Requests';

  @override
  String get navProfile => 'Profile';

  @override
  String get requestsTitle => 'Requests';

  @override
  String get requestsSubtitle => 'Track and manage your service requests';

  @override
  String get activeFilter => 'Active';

  @override
  String get historyFilter => 'History';

  @override
  String get searchRequests => 'Search requests...';

  @override
  String get noRequestsFound => 'No requests found';

  @override
  String get trySearchingDifferent => 'Try searching with a different term';

  @override
  String get providerOnTheWay => 'Your provider is on the way';

  @override
  String get providerArrivingSoon =>
      'Almost there! Your provider will arrive soon.';

  @override
  String get eightMinAway => '8 min away';

  @override
  String get youBadge => 'You';

  @override
  String get distanceAway => 'Distance Away';

  @override
  String get estimatedTime => 'Estimated time';

  @override
  String get requestSent => 'Request Sent';

  @override
  String get accepted => 'Accepted';

  @override
  String get onTheWay => 'On the way';

  @override
  String get arrived => 'Arrived';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get pickupDelivery => 'Pickup & Delivery';

  @override
  String get nearbyProviders => 'Nearby Providers';

  @override
  String providersNearbyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Providers nearby',
      one: '1 Provider nearby',
    );
    return '$_temp0';
  }

  @override
  String get withinRadius => 'Within 2 km radius';

  @override
  String get viewAll => 'View all';

  @override
  String get confirm => 'Confirm';

  @override
  String confirmDriver(String name) {
    return 'Confirm $name';
  }

  @override
  String get dragMapHint => 'Drag map to explore';

  @override
  String driversNearbyHint(int count) {
    return '$count Drivers nearby • Drag map to explore';
  }

  @override
  String get yourLocation => 'Your Location';

  @override
  String get detectingLocation => 'Detecting Location...';

  @override
  String get online => 'ONLINE';

  @override
  String kmAway(Object dist) {
    return '$dist km away';
  }

  @override
  String get verified => 'Verified';

  @override
  String get providersLabel => 'Providers';

  @override
  String get deliveriesLabel => 'Deliveries';

  @override
  String get onTime => 'On time';

  @override
  String get sendMyLocation => 'Send My Location';

  @override
  String get sendRequest => 'Send Request';

  @override
  String get sixMin => '6 min';

  @override
  String get onePointEightKm => '1.8 km';

  @override
  String get threePointEightKm => '3.8 km';

  @override
  String get shareYourLocation => 'Share your location?';

  @override
  String get tapOrSwipeToView => 'Tap or swipe up to view options';

  @override
  String shareLiveLocationWith(String name) {
    return 'Share your live location with $name for faster pickup';
  }

  @override
  String get endToEndEncrypted => 'End-to-end encrypted • Live tracking active';

  @override
  String get shareVia => 'Share via';

  @override
  String get whatsApp => 'WhatsApp';

  @override
  String get chatAndShare => 'Chat & Share';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get copyToShare => 'Copy to share';

  @override
  String get instagram => 'Instagram';

  @override
  String get shareInDm => 'Share in Dm';

  @override
  String get locationDetails => 'Location Details';

  @override
  String get sampleAddress => 'King Fahd Road, Al Olaya Riyadh, Saudi Arabia';

  @override
  String get sendLocation => 'Send Location';

  @override
  String locationSentSuccess(String provider) {
    return 'Location sent successfully to $provider!';
  }

  @override
  String get linkCopied => 'Location link copied to clipboard!';

  @override
  String get openingWhatsApp => 'Opening WhatsApp...';

  @override
  String get openingInstagram => 'Opening Instagram to share in DM...';

  @override
  String callingProvider(String name) {
    return 'Calling $name...';
  }

  @override
  String get waitingForResponse => 'Waiting for response';

  @override
  String get available => 'Available';

  @override
  String get requestAccepted => 'Request Accepted!';

  @override
  String get providerAcceptedStartingLive =>
      'Provider accepted. Starting live tracking...';

  @override
  String get waitingForProviderAccept =>
      'Waiting for provider to accept your request.';

  @override
  String get justNow => 'Just now';

  @override
  String get providerAccepted => 'Provider accepted';

  @override
  String get cancelRequest => 'Cancel Request';

  @override
  String get cancelRequestTitle => 'Cancel Request?';

  @override
  String cancelRequestConfirm(String name) {
    return 'Are you sure you want to cancel your request to $name?';
  }

  @override
  String get noKeep => 'No, Keep';

  @override
  String get yesCancel => 'Yes, Cancel';

  @override
  String get requestCancelled => 'Request cancelled';

  @override
  String get liveBadge => 'LIVE';

  @override
  String get eatEta => 'ETA: ';

  @override
  String get driverLocationUpdating => 'Driver location updating...';

  @override
  String get liveMovementOnMap => 'You\'ll see live movement on the map';

  @override
  String get zeroKm => '0 km';

  @override
  String get statusLabel => 'Status: ';

  @override
  String get atYourLocation => 'At your location';

  @override
  String get arrivedBadge => 'Arrived';

  @override
  String get providerHasArrived => 'Your Provider has arrived!';

  @override
  String get providerArrivedStartService =>
      'Provider has arrived. Start service now.';

  @override
  String tripDetails(String name, String category) {
    return 'Trip details for $name - $category';
  }

  @override
  String get serviceCompleteHeader => 'Service Complete';

  @override
  String get serviceCompleted => 'Service Completed!';

  @override
  String get requestCompletedSuccess =>
      'Your request has been completed\nsuccessfully';

  @override
  String reviewsCount(int count) {
    return '($count reviews)';
  }

  @override
  String get completedOn => 'Completed on';

  @override
  String get sampleCompletedDateTime => '12 Sep 2026, 9:58 PM';

  @override
  String get thankYou => 'Thank you!';

  @override
  String get hopeGreatExperience => 'We hope you had a great experience.';

  @override
  String get rateYourExperience => 'Rate your experience ';

  @override
  String get optional => '(optional)';

  @override
  String get viewDetails => 'View Details';

  @override
  String get rateExperience => 'Rate your experience (optional)';

  @override
  String get nearbyProvidersBadge => 'Nearby\nProviders';

  @override
  String get fastDeliveryBadge => 'Fast\nDelivery';

  @override
  String get realTimeTrackingBadge => 'Real-time\nTracking';

  @override
  String get findProvidersNearYou => 'Find Providers near you';

  @override
  String needLocationPermissionFor(String service) {
    return 'We need your location to show nearby\nproviders for $service.';
  }

  @override
  String get seeNearbyProviders => 'See nearby providers';

  @override
  String get findAvailableTeamsAround =>
      'Find available pickup & delivery teams around you.';

  @override
  String get fastService => 'Fast service';

  @override
  String get getQuickerAccurateResults =>
      'Get quicker and more accurate results.';

  @override
  String get yourPrivacyMatters => 'Your privacy matters';

  @override
  String get privacyLocationOnlyService =>
      'Your location is only used for this service and can be changed anytime.';

  @override
  String get allowLocation => 'Allow Location';

  @override
  String get youCanChangeLaterIn => 'You can change this later in ';

  @override
  String get settingsLabel => 'Settings';

  @override
  String get openingLocationSettings => 'Opening Location Settings...';

  @override
  String get emergencyServices => 'Emergency Services';

  @override
  String get getHelpFast => 'Get help, fast.';

  @override
  String get emergencyLabel => 'Emergency';

  @override
  String get emergencyCardSubtitle =>
      'We\'ll connect you with the nearest\navailable emergency team.';

  @override
  String get verifiedProvidersBadge => 'Verified Providers';

  @override
  String get quickResponseBadge => 'Quick Response';

  @override
  String get liveTrackingBadge => 'Live Tracking';

  @override
  String get chooseYourServices => 'Choose Your Services';

  @override
  String get chooseServiceImmediateHelp =>
      'Choose a service to get immediate help.';

  @override
  String get ambulanceTitle => 'Ambulance';

  @override
  String get ambulanceSubtitle => 'Medical emergency';

  @override
  String get policeTitle => 'Police';

  @override
  String get policeSubtitle => 'Crime & security';

  @override
  String get fireBrigadeTitle => 'Fire Brigade';

  @override
  String get fireBrigadeSubtitle => 'Fire & rescue response';

  @override
  String get towTruckTitle => 'Tow Truck';

  @override
  String get towTruckSubtitle => 'Roadside vehicle breakdown';

  @override
  String get hospitalTitle => 'Hospital';

  @override
  String get hospitalSubtitle => 'Urgent medical center';

  @override
  String get call => 'Call';

  @override
  String get message => 'Message';
}
