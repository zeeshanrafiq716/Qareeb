import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'QAREEB'**
  String get appTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your account and preferences.'**
  String get profileSubtitle;

  /// No description provided for @verifiedUser.
  ///
  /// In en, this message translates to:
  /// **'Verified User'**
  String get verifiedUser;

  /// No description provided for @totalRequests.
  ///
  /// In en, this message translates to:
  /// **'Total Requests'**
  String get totalRequests;

  /// No description provided for @averageRating.
  ///
  /// In en, this message translates to:
  /// **'Average Rating'**
  String get averageRating;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @personalInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Name, phone number and more'**
  String get personalInfoSubtitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your alerts and updates'**
  String get notificationsSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @currentLanguageDisplay.
  ///
  /// In en, this message translates to:
  /// **'English (US)'**
  String get currentLanguageDisplay;

  /// No description provided for @selectLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguageTitle;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @savedLocations.
  ///
  /// In en, this message translates to:
  /// **'Saved Locations'**
  String get savedLocations;

  /// No description provided for @savedLocationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Home, Work, and other places'**
  String get savedLocationsSubtitle;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @paymentMethodsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your payment options'**
  String get paymentMethodsSubtitle;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @privacySecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your data and security'**
  String get privacySecuritySubtitle;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @helpSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find help or contact us'**
  String get helpSupportSubtitle;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Greeting on home screen
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String greeting(String name);

  /// No description provided for @exploreSomething.
  ///
  /// In en, this message translates to:
  /// **'Explore Something'**
  String get exploreSomething;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocation;

  /// No description provided for @realGps.
  ///
  /// In en, this message translates to:
  /// **'Real GPS'**
  String get realGps;

  /// No description provided for @gpsDetecting.
  ///
  /// In en, this message translates to:
  /// **'Detecting GPS...'**
  String get gpsDetecting;

  /// No description provided for @urgentAssistance.
  ///
  /// In en, this message translates to:
  /// **'Need urgent assistance?'**
  String get urgentAssistance;

  /// No description provided for @getHelpNow.
  ///
  /// In en, this message translates to:
  /// **'Get Help Now'**
  String get getHelpNow;

  /// No description provided for @chooseYourRide.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Ride'**
  String get chooseYourRide;

  /// No description provided for @chooseRideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a service and see available options.'**
  String get chooseRideSubtitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get navRequests;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @requestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requestsTitle;

  /// No description provided for @requestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track and manage your service requests'**
  String get requestsSubtitle;

  /// No description provided for @activeFilter.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeFilter;

  /// No description provided for @historyFilter.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyFilter;

  /// No description provided for @searchRequests.
  ///
  /// In en, this message translates to:
  /// **'Search requests...'**
  String get searchRequests;

  /// No description provided for @noRequestsFound.
  ///
  /// In en, this message translates to:
  /// **'No requests found'**
  String get noRequestsFound;

  /// No description provided for @trySearchingDifferent.
  ///
  /// In en, this message translates to:
  /// **'Try searching with a different term'**
  String get trySearchingDifferent;

  /// No description provided for @providerOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'Your provider is on the way'**
  String get providerOnTheWay;

  /// No description provided for @providerArrivingSoon.
  ///
  /// In en, this message translates to:
  /// **'Almost there! Your provider will arrive soon.'**
  String get providerArrivingSoon;

  /// No description provided for @eightMinAway.
  ///
  /// In en, this message translates to:
  /// **'8 min away'**
  String get eightMinAway;

  /// No description provided for @youBadge.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youBadge;

  /// No description provided for @distanceAway.
  ///
  /// In en, this message translates to:
  /// **'Distance Away'**
  String get distanceAway;

  /// No description provided for @estimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated time'**
  String get estimatedTime;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request Sent'**
  String get requestSent;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @onTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get onTheWay;

  /// No description provided for @arrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get arrived;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @pickupDelivery.
  ///
  /// In en, this message translates to:
  /// **'Pickup & Delivery'**
  String get pickupDelivery;

  /// No description provided for @nearbyProviders.
  ///
  /// In en, this message translates to:
  /// **'Nearby Providers'**
  String get nearbyProviders;

  /// Count of nearby providers
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Provider nearby} other{{count} Providers nearby}}'**
  String providersNearbyCount(int count);

  /// No description provided for @withinRadius.
  ///
  /// In en, this message translates to:
  /// **'Within 2 km radius'**
  String get withinRadius;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmDriver.
  ///
  /// In en, this message translates to:
  /// **'Confirm {name}'**
  String confirmDriver(String name);

  /// No description provided for @dragMapHint.
  ///
  /// In en, this message translates to:
  /// **'Drag map to explore'**
  String get dragMapHint;

  /// No description provided for @driversNearbyHint.
  ///
  /// In en, this message translates to:
  /// **'{count} Drivers nearby • Drag map to explore'**
  String driversNearbyHint(int count);

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get yourLocation;

  /// No description provided for @detectingLocation.
  ///
  /// In en, this message translates to:
  /// **'Detecting Location...'**
  String get detectingLocation;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'ONLINE'**
  String get online;

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'{dist} km away'**
  String kmAway(Object dist);

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @providersLabel.
  ///
  /// In en, this message translates to:
  /// **'Providers'**
  String get providersLabel;

  /// No description provided for @deliveriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get deliveriesLabel;

  /// No description provided for @onTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get onTime;

  /// No description provided for @sendMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Send My Location'**
  String get sendMyLocation;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendRequest;

  /// No description provided for @sixMin.
  ///
  /// In en, this message translates to:
  /// **'6 min'**
  String get sixMin;

  /// No description provided for @onePointEightKm.
  ///
  /// In en, this message translates to:
  /// **'1.8 km'**
  String get onePointEightKm;

  /// No description provided for @threePointEightKm.
  ///
  /// In en, this message translates to:
  /// **'3.8 km'**
  String get threePointEightKm;

  /// No description provided for @shareYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Share your location?'**
  String get shareYourLocation;

  /// No description provided for @tapOrSwipeToView.
  ///
  /// In en, this message translates to:
  /// **'Tap or swipe up to view options'**
  String get tapOrSwipeToView;

  /// No description provided for @shareLiveLocationWith.
  ///
  /// In en, this message translates to:
  /// **'Share your live location with {name} for faster pickup'**
  String shareLiveLocationWith(String name);

  /// No description provided for @endToEndEncrypted.
  ///
  /// In en, this message translates to:
  /// **'End-to-end encrypted • Live tracking active'**
  String get endToEndEncrypted;

  /// No description provided for @shareVia.
  ///
  /// In en, this message translates to:
  /// **'Share via'**
  String get shareVia;

  /// No description provided for @whatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsApp;

  /// No description provided for @chatAndShare.
  ///
  /// In en, this message translates to:
  /// **'Chat & Share'**
  String get chatAndShare;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @copyToShare.
  ///
  /// In en, this message translates to:
  /// **'Copy to share'**
  String get copyToShare;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @shareInDm.
  ///
  /// In en, this message translates to:
  /// **'Share in Dm'**
  String get shareInDm;

  /// No description provided for @locationDetails.
  ///
  /// In en, this message translates to:
  /// **'Location Details'**
  String get locationDetails;

  /// No description provided for @sampleAddress.
  ///
  /// In en, this message translates to:
  /// **'King Fahd Road, Al Olaya Riyadh, Saudi Arabia'**
  String get sampleAddress;

  /// No description provided for @sendLocation.
  ///
  /// In en, this message translates to:
  /// **'Send Location'**
  String get sendLocation;

  /// No description provided for @locationSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Location sent successfully to {provider}!'**
  String locationSentSuccess(String provider);

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Location link copied to clipboard!'**
  String get linkCopied;

  /// No description provided for @openingWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Opening WhatsApp...'**
  String get openingWhatsApp;

  /// No description provided for @openingInstagram.
  ///
  /// In en, this message translates to:
  /// **'Opening Instagram to share in DM...'**
  String get openingInstagram;

  /// No description provided for @callingProvider.
  ///
  /// In en, this message translates to:
  /// **'Calling {name}...'**
  String callingProvider(String name);

  /// No description provided for @waitingForResponse.
  ///
  /// In en, this message translates to:
  /// **'Waiting for response'**
  String get waitingForResponse;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @requestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Request Accepted!'**
  String get requestAccepted;

  /// No description provided for @providerAcceptedStartingLive.
  ///
  /// In en, this message translates to:
  /// **'Provider accepted. Starting live tracking...'**
  String get providerAcceptedStartingLive;

  /// No description provided for @waitingForProviderAccept.
  ///
  /// In en, this message translates to:
  /// **'Waiting for provider to accept your request.'**
  String get waitingForProviderAccept;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @providerAccepted.
  ///
  /// In en, this message translates to:
  /// **'Provider accepted'**
  String get providerAccepted;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelRequest;

  /// No description provided for @cancelRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request?'**
  String get cancelRequestTitle;

  /// No description provided for @cancelRequestConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel your request to {name}?'**
  String cancelRequestConfirm(String name);

  /// No description provided for @noKeep.
  ///
  /// In en, this message translates to:
  /// **'No, Keep'**
  String get noKeep;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @requestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled'**
  String get requestCancelled;

  /// No description provided for @liveBadge.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get liveBadge;

  /// No description provided for @eatEta.
  ///
  /// In en, this message translates to:
  /// **'ETA: '**
  String get eatEta;

  /// No description provided for @driverLocationUpdating.
  ///
  /// In en, this message translates to:
  /// **'Driver location updating...'**
  String get driverLocationUpdating;

  /// No description provided for @liveMovementOnMap.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see live movement on the map'**
  String get liveMovementOnMap;

  /// No description provided for @zeroKm.
  ///
  /// In en, this message translates to:
  /// **'0 km'**
  String get zeroKm;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: '**
  String get statusLabel;

  /// No description provided for @atYourLocation.
  ///
  /// In en, this message translates to:
  /// **'At your location'**
  String get atYourLocation;

  /// No description provided for @arrivedBadge.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get arrivedBadge;

  /// No description provided for @providerHasArrived.
  ///
  /// In en, this message translates to:
  /// **'Your Provider has arrived!'**
  String get providerHasArrived;

  /// No description provided for @providerArrivedStartService.
  ///
  /// In en, this message translates to:
  /// **'Provider has arrived. Start service now.'**
  String get providerArrivedStartService;

  /// No description provided for @tripDetails.
  ///
  /// In en, this message translates to:
  /// **'Trip details for {name} - {category}'**
  String tripDetails(String name, String category);

  /// No description provided for @serviceCompleteHeader.
  ///
  /// In en, this message translates to:
  /// **'Service Complete'**
  String get serviceCompleteHeader;

  /// No description provided for @serviceCompleted.
  ///
  /// In en, this message translates to:
  /// **'Service Completed!'**
  String get serviceCompleted;

  /// No description provided for @requestCompletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your request has been completed\nsuccessfully'**
  String get requestCompletedSuccess;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'({count} reviews)'**
  String reviewsCount(int count);

  /// No description provided for @completedOn.
  ///
  /// In en, this message translates to:
  /// **'Completed on'**
  String get completedOn;

  /// No description provided for @sampleCompletedDateTime.
  ///
  /// In en, this message translates to:
  /// **'12 Sep 2026, 9:58 PM'**
  String get sampleCompletedDateTime;

  /// No description provided for @thankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank you!'**
  String get thankYou;

  /// No description provided for @hopeGreatExperience.
  ///
  /// In en, this message translates to:
  /// **'We hope you had a great experience.'**
  String get hopeGreatExperience;

  /// No description provided for @rateYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate your experience '**
  String get rateYourExperience;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get optional;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @rateExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate your experience (optional)'**
  String get rateExperience;

  /// No description provided for @nearbyProvidersBadge.
  ///
  /// In en, this message translates to:
  /// **'Nearby\nProviders'**
  String get nearbyProvidersBadge;

  /// No description provided for @fastDeliveryBadge.
  ///
  /// In en, this message translates to:
  /// **'Fast\nDelivery'**
  String get fastDeliveryBadge;

  /// No description provided for @realTimeTrackingBadge.
  ///
  /// In en, this message translates to:
  /// **'Real-time\nTracking'**
  String get realTimeTrackingBadge;

  /// No description provided for @findProvidersNearYou.
  ///
  /// In en, this message translates to:
  /// **'Find Providers near you'**
  String get findProvidersNearYou;

  /// No description provided for @needLocationPermissionFor.
  ///
  /// In en, this message translates to:
  /// **'We need your location to show nearby\nproviders for {service}.'**
  String needLocationPermissionFor(String service);

  /// No description provided for @seeNearbyProviders.
  ///
  /// In en, this message translates to:
  /// **'See nearby providers'**
  String get seeNearbyProviders;

  /// No description provided for @findAvailableTeamsAround.
  ///
  /// In en, this message translates to:
  /// **'Find available pickup & delivery teams around you.'**
  String get findAvailableTeamsAround;

  /// No description provided for @fastService.
  ///
  /// In en, this message translates to:
  /// **'Fast service'**
  String get fastService;

  /// No description provided for @getQuickerAccurateResults.
  ///
  /// In en, this message translates to:
  /// **'Get quicker and more accurate results.'**
  String get getQuickerAccurateResults;

  /// No description provided for @yourPrivacyMatters.
  ///
  /// In en, this message translates to:
  /// **'Your privacy matters'**
  String get yourPrivacyMatters;

  /// No description provided for @privacyLocationOnlyService.
  ///
  /// In en, this message translates to:
  /// **'Your location is only used for this service and can be changed anytime.'**
  String get privacyLocationOnlyService;

  /// No description provided for @allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow Location'**
  String get allowLocation;

  /// No description provided for @youCanChangeLaterIn.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in '**
  String get youCanChangeLaterIn;

  /// No description provided for @settingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsLabel;

  /// No description provided for @openingLocationSettings.
  ///
  /// In en, this message translates to:
  /// **'Opening Location Settings...'**
  String get openingLocationSettings;

  /// No description provided for @emergencyServices.
  ///
  /// In en, this message translates to:
  /// **'Emergency Services'**
  String get emergencyServices;

  /// No description provided for @getHelpFast.
  ///
  /// In en, this message translates to:
  /// **'Get help, fast.'**
  String get getHelpFast;

  /// No description provided for @emergencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergencyLabel;

  /// No description provided for @emergencyCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll connect you with the nearest\navailable emergency team.'**
  String get emergencyCardSubtitle;

  /// No description provided for @verifiedProvidersBadge.
  ///
  /// In en, this message translates to:
  /// **'Verified Providers'**
  String get verifiedProvidersBadge;

  /// No description provided for @quickResponseBadge.
  ///
  /// In en, this message translates to:
  /// **'Quick Response'**
  String get quickResponseBadge;

  /// No description provided for @liveTrackingBadge.
  ///
  /// In en, this message translates to:
  /// **'Live Tracking'**
  String get liveTrackingBadge;

  /// No description provided for @chooseYourServices.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Services'**
  String get chooseYourServices;

  /// No description provided for @chooseServiceImmediateHelp.
  ///
  /// In en, this message translates to:
  /// **'Choose a service to get immediate help.'**
  String get chooseServiceImmediateHelp;

  /// No description provided for @ambulanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Ambulance'**
  String get ambulanceTitle;

  /// No description provided for @ambulanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Medical emergency'**
  String get ambulanceSubtitle;

  /// No description provided for @policeTitle.
  ///
  /// In en, this message translates to:
  /// **'Police'**
  String get policeTitle;

  /// No description provided for @policeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Crime & security'**
  String get policeSubtitle;

  /// No description provided for @fireBrigadeTitle.
  ///
  /// In en, this message translates to:
  /// **'Fire Brigade'**
  String get fireBrigadeTitle;

  /// No description provided for @fireBrigadeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fire & rescue response'**
  String get fireBrigadeSubtitle;

  /// No description provided for @towTruckTitle.
  ///
  /// In en, this message translates to:
  /// **'Tow Truck'**
  String get towTruckTitle;

  /// No description provided for @towTruckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Roadside vehicle breakdown'**
  String get towTruckSubtitle;

  /// No description provided for @hospitalTitle.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get hospitalTitle;

  /// No description provided for @hospitalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Urgent medical center'**
  String get hospitalSubtitle;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
