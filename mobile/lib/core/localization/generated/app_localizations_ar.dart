// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'قريب';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileSubtitle => 'إدارة حسابك وتفضيلاتك بكل سهولة';

  @override
  String get verifiedUser => 'مستخدم موثق';

  @override
  String get totalRequests => 'إجمالي الطلبات';

  @override
  String get averageRating => 'متوسط التقييم';

  @override
  String get personalInfo => 'المعلومات الشخصية';

  @override
  String get personalInfoSubtitle => 'الاسم، رقم الهاتف والبيانات الشخصية';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get notificationsSubtitle => 'إدارة التنبيهات والرسائل';

  @override
  String get language => 'اللغة';

  @override
  String get currentLanguageDisplay => 'العربية';

  @override
  String get selectLanguageTitle => 'اختر اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get savedLocations => 'العناوين المحفوظة';

  @override
  String get savedLocationsSubtitle => 'المنزل، العمل والأماكن المفضلة';

  @override
  String get paymentMethods => 'طرق الدفع';

  @override
  String get paymentMethodsSubtitle => 'البطاقات والمحافظ الإلكترونية';

  @override
  String get privacySecurity => 'الخصوصية والأمان';

  @override
  String get privacySecuritySubtitle => 'حماية بياناتك وإعدادات الأمان';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get helpSupportSubtitle => 'مركز المساعدة وخدمة العملاء';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String greeting(String name) {
    return 'أهلاً بك، $name';
  }

  @override
  String get exploreSomething => 'استكشف الخدمات المتاحة';

  @override
  String get currentLocation => 'موقعك الحالي';

  @override
  String get realGps => 'تحديد الموقع بدقة';

  @override
  String get gpsDetecting => 'جارٍ تحديد موقعك...';

  @override
  String get urgentAssistance => 'هل تحتاج إلى مساعدة عاجلة؟';

  @override
  String get getHelpNow => 'احصل على المساعدة الآن';

  @override
  String get chooseYourRide => 'اختر وسيلة التنقل';

  @override
  String get chooseRideSubtitle =>
      'اختر الخدمة المناسبة واطلع على الكباتن المتاحين حولك.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get done => 'تم';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get save => 'حفظ';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get submit => 'إرسال';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navRequests => 'الطلبات';

  @override
  String get navProfile => 'حسابي';

  @override
  String get requestsTitle => 'طلباتي';

  @override
  String get requestsSubtitle => 'متابعة وإدارة طلباتك الحالية والسابقة';

  @override
  String get activeFilter => 'النشطة';

  @override
  String get historyFilter => 'السجل';

  @override
  String get searchRequests => 'البحث في الطلبات...';

  @override
  String get noRequestsFound => 'لا توجد طلبات حالياً';

  @override
  String get trySearchingDifferent => 'جرّب البحث بكلمات أخرى';

  @override
  String get providerOnTheWay => 'الكابتن في الطريق إليك';

  @override
  String get providerArrivingSoon => 'الكابتن على وشك الوصول إلى موقعك!';

  @override
  String get eightMinAway => 'على بُعد 8 دقائق';

  @override
  String get youBadge => 'أنت';

  @override
  String get distanceAway => 'المسافة';

  @override
  String get estimatedTime => 'الوقت المتوقع';

  @override
  String get requestSent => 'تم إرسال الطلب';

  @override
  String get accepted => 'تم قبول الطلب';

  @override
  String get onTheWay => 'في الطريق';

  @override
  String get arrived => 'وصل الكابتن';

  @override
  String get completed => 'مكتمل';

  @override
  String get cancelled => 'ملغي';

  @override
  String get pickupDelivery => 'نقل وتوصيل';

  @override
  String get nearbyProviders => 'الكباتن المتاحون';

  @override
  String providersNearbyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count كابتن بالقرب منك',
      few: '$count كباتن بالقرب منك',
      two: 'كابتنان بالقرب منك',
      one: 'كابتن واحد بالقرب منك',
    );
    return '$_temp0';
  }

  @override
  String get withinRadius => 'ضمن نطاق 2 كم';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get confirm => 'تأكيد';

  @override
  String confirmDriver(String name) {
    return 'تأكيد الطلب مع $name';
  }

  @override
  String get dragMapHint => 'حرّك الخريطة للاستكشاف';

  @override
  String driversNearbyHint(int count) {
    return '$count كباتن متاحين بالقرب منك • حرّك الخريطة';
  }

  @override
  String get yourLocation => 'موقعك الحالي';

  @override
  String get detectingLocation => 'جارٍ تحديد موقعك...';

  @override
  String get online => 'متصل';

  @override
  String kmAway(Object dist) {
    return '$dist كم';
  }

  @override
  String get verified => 'معتمد';

  @override
  String get providersLabel => 'كابتن معتمد';

  @override
  String get deliveriesLabel => 'رحلة مكتملة';

  @override
  String get onTime => 'في الموعد';

  @override
  String get sendMyLocation => 'إرسال موقعي';

  @override
  String get sendRequest => 'طلب المشوار الآن';

  @override
  String get sixMin => '6 دقائق';

  @override
  String get onePointEightKm => '1.8 كم';

  @override
  String get threePointEightKm => '3.8 كم';

  @override
  String get shareYourLocation => 'مشاركة موقعك الحالي';

  @override
  String get tapOrSwipeToView => 'اسحب لأعلى لعرض الخيارات';

  @override
  String shareLiveLocationWith(String name) {
    return 'شارك موقعك المباشر مع $name للوصول إليك بسرعة';
  }

  @override
  String get endToEndEncrypted => 'اتصال آمن ومشفر • التتبع المباشر نشط';

  @override
  String get shareVia => 'المشاركة عبر';

  @override
  String get whatsApp => 'واتساب';

  @override
  String get chatAndShare => 'مراسلة ومشاركة';

  @override
  String get copyLink => 'نسخ الرابط';

  @override
  String get copyToShare => 'نسخ للمشاركة';

  @override
  String get instagram => 'إنستغرام';

  @override
  String get shareInDm => 'إرسال بالخاص';

  @override
  String get locationDetails => 'تفاصيل الموقع';

  @override
  String get sampleAddress => 'طريق الملك فهد، حي العليا، الرياض';

  @override
  String get sendLocation => 'إرسال الموقع الآن';

  @override
  String locationSentSuccess(String provider) {
    return 'تم إرسال موقعك بنجاح إلى $provider!';
  }

  @override
  String get linkCopied => 'تم نسخ رابط الموقع إلى الحافظة بنجاح!';

  @override
  String get openingWhatsApp => 'جارٍ فتح تطبيق واتساب...';

  @override
  String get openingInstagram => 'جارٍ فتح تطبيق إنستغرام...';

  @override
  String callingProvider(String name) {
    return 'جارٍ الاتصال بـ $name...';
  }

  @override
  String get waitingForResponse => 'جارٍ انتظار الرد...';

  @override
  String get available => 'متاح';

  @override
  String get requestAccepted => 'تم قبول الطلب بنجاح!';

  @override
  String get providerAcceptedStartingLive =>
      'وافق الكابتن على طلبك. جارٍ بدء التتبع المباشر...';

  @override
  String get waitingForProviderAccept => 'بانتظار موافقة الكابتن على طلبك...';

  @override
  String get justNow => 'الآن';

  @override
  String get providerAccepted => 'تم قبول الطلب';

  @override
  String get cancelRequest => 'إلغاء الطلب';

  @override
  String get cancelRequestTitle => 'هل تريد إلغاء الطلب؟';

  @override
  String cancelRequestConfirm(String name) {
    return 'هل أنت متأكد من رغبتك في إلغاء طلبك إلى $name؟';
  }

  @override
  String get noKeep => 'لا، متابعة الطلب';

  @override
  String get yesCancel => 'نعم، إلغاء الطلب';

  @override
  String get requestCancelled => 'تم إلغاء الطلب';

  @override
  String get liveBadge => 'مباشر';

  @override
  String get eatEta => 'الوقت المتوقع للوصول: ';

  @override
  String get driverLocationUpdating => 'جارٍ تحديث موقع الكابتن مباشرة...';

  @override
  String get liveMovementOnMap =>
      'يمكنك مشاهدة حركة الكابتن مباشرة على الخريطة';

  @override
  String get zeroKm => '0 كم';

  @override
  String get statusLabel => 'الحالة: ';

  @override
  String get atYourLocation => 'في موقعك الآن';

  @override
  String get arrivedBadge => 'وصل';

  @override
  String get providerHasArrived => 'وصل الكابتن إلى موقعك!';

  @override
  String get providerArrivedStartService =>
      'وصل الكابتن إلى موقعك. يمكنك بدء المشوار الآن.';

  @override
  String tripDetails(String name, String category) {
    return 'تفاصيل المشوار مع $name - $category';
  }

  @override
  String get serviceCompleteHeader => 'اكتملت الخدمة';

  @override
  String get serviceCompleted => 'تمت الخدمة بنجاح!';

  @override
  String get requestCompletedSuccess =>
      'تم إكمال طلبك بنجاح\nشكراً لاختيارك تطبيق قريب';

  @override
  String reviewsCount(int count) {
    return '($count تقييم)';
  }

  @override
  String get completedOn => 'تاريخ الإكمال';

  @override
  String get sampleCompletedDateTime => '12 سبتمبر 2026، 9:58 م';

  @override
  String get thankYou => 'شكراً لك!';

  @override
  String get hopeGreatExperience =>
      'نتمنى أن تكون قد استمتعت بتجربة مريحة وممتازة.';

  @override
  String get rateYourExperience => 'كيف كانت تجربتك؟ ';

  @override
  String get optional => '(اختياري)';

  @override
  String get viewDetails => 'عرض تفاصيل الرحلة';

  @override
  String get rateExperience => 'شاركنا تقييمك للخدمة (اختياري)';

  @override
  String get nearbyProvidersBadge => 'كباتن\nبالقرب منك';

  @override
  String get fastDeliveryBadge => 'توصيل\nسريع';

  @override
  String get realTimeTrackingBadge => 'تتبع\nلحظي';

  @override
  String get findProvidersNearYou => 'ابحث عن أقرب مزودي الخدمة إليك';

  @override
  String needLocationPermissionFor(String service) {
    return 'نحتاج إذن الوصول لموقعك لعرض أقرب مزودي خدمة $service إليك.';
  }

  @override
  String get seeNearbyProviders => 'عرض الكباتن المتاحين حولك';

  @override
  String get findAvailableTeamsAround =>
      'استكشف مزودي الخدمة المتاحين في منطقتك فوراً.';

  @override
  String get fastService => 'خدمة سريعة وفورية';

  @override
  String get getQuickerAccurateResults => 'وصول أسرع ونتائج بحث دقيقة لموقعك.';

  @override
  String get yourPrivacyMatters => 'خصوصيتك في أمان تام';

  @override
  String get privacyLocationOnlyService =>
      'يُستخدم موقعك الجغرافي فقط أثناء استخدام الخدمة ولا تتم مشاركته.';

  @override
  String get allowLocation => 'السماح بتحديد الموقع';

  @override
  String get youCanChangeLaterIn => 'يمكنك تغيير هذا الإذن لاحقاً من ';

  @override
  String get settingsLabel => 'الإعدادات';

  @override
  String get openingLocationSettings => 'جارٍ فتح إعدادات الموقع...';

  @override
  String get emergencyServices => 'خدمات الطوارئ';

  @override
  String get getHelpFast => 'احصل على مساعدة فورية';

  @override
  String get emergencyLabel => 'طوارئ';

  @override
  String get emergencyCardSubtitle => 'سنصلك بأقرب فريق طوارئ متاح لمساعدتك.';

  @override
  String get verifiedProvidersBadge => 'مقدمو خدمة معتمدون';

  @override
  String get quickResponseBadge => 'استجابة سريعة';

  @override
  String get liveTrackingBadge => 'تتبع مباشر';

  @override
  String get chooseYourServices => 'اختر نوع الخدمة';

  @override
  String get chooseServiceImmediateHelp =>
      'اختر الخدمة المطلوبة لتلقي المساعدة فوراً.';

  @override
  String get ambulanceTitle => 'إسعاف';

  @override
  String get ambulanceSubtitle => 'حالات طوارئ طبية';

  @override
  String get policeTitle => 'شرطة';

  @override
  String get policeSubtitle => 'بلاغات وأمان';

  @override
  String get fireBrigadeTitle => 'دفاع مدني وإطفاء';

  @override
  String get fireBrigadeSubtitle => 'حرائق وإنقاذ';

  @override
  String get towTruckTitle => 'سحب مركبات';

  @override
  String get towTruckSubtitle => 'أعطال الطرق والقطر';

  @override
  String get hospitalTitle => 'مستشفى';

  @override
  String get hospitalSubtitle => 'مراكز طبية عاجلة';

  @override
  String get call => 'اتصال';

  @override
  String get message => 'مراسلة';
}
