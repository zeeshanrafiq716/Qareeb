import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'generated/app_localizations.dart';
import '../theme/app_typography.dart';

export 'generated/app_localizations.dart';
export '../theme/app_typography.dart';
export 'safe_text.dart';

const String _prefKeyLanguage = 'app_selected_language';

/// Manages application locale with Arabic as DEFAULT using Riverpod 3.x Notifier
class AppLocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _loadSavedLocale();
    return const Locale('ar');
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefKeyLanguage);
      if (savedCode != null && (savedCode == 'ar' || savedCode == 'en')) {
        state = Locale(savedCode);
      } else {
        // By default Arabic:
        state = const Locale('ar');
        await prefs.setString(_prefKeyLanguage, 'ar');
      }
    } catch (_) {
      // Fallback safely to Arabic on any storage error
      state = const Locale('ar');
    }
  }

  Future<void> setLocale(String languageCode) async {
    if (languageCode != 'ar' && languageCode != 'en') return;
    if (state.languageCode == languageCode) return;

    state = Locale(languageCode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyLanguage, languageCode);
    } catch (_) {}
  }

  Future<void> toggleLanguage() async {
    final nextCode = state.languageCode == 'ar' ? 'en' : 'ar';
    await setLocale(nextCode);
  }
}

/// Main reactive App Locale Provider
final appLocaleProvider = NotifierProvider<AppLocaleNotifier, Locale>(
  AppLocaleNotifier.new,
);

/// Boolean provider indicating if current language is Arabic
final isArabicProvider = Provider<bool>((ref) {
  return ref.watch(appLocaleProvider).languageCode == 'ar';
});

/// Riverpod provider exposing official AppLocalizations reactively matching active AppLocale
final l10nProvider = Provider<AppLocalizations>((ref) {
  final locale = ref.watch(appLocaleProvider);
  return lookupAppLocalizations(locale);
});

/// Alias pointing to l10nProvider for seamless integration
final translationsProvider = l10nProvider;

/// Type alias for AppLocalizations
typedef AppTranslations = AppLocalizations;

/// Context extensions for Flutter official localization
extension AppLocalizationsContextExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  AppLocalizations get tr => AppLocalizations.of(this)!;
  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
  String auto(String? text) => tr.auto(text);
}

/// Domain formatting and typography extension on AppLocalizations
extension AppLocalizationsDomainExtension on AppLocalizations {
  bool get isArabic => localeName.startsWith('ar');

  TextStyle font({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    return AppTypography.fontForLocale(
      isArabic: isArabic,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }

  String categoryName(String slugOrName, [String? fallback]) {
    final text = (fallback != null && fallback.isNotEmpty) ? fallback : slugOrName;
    if (!isArabic) return text;

    final key = '${slugOrName.toLowerCase()} ${text.toLowerCase()}';
    if (key.contains('carpent')) return 'نجار';
    if (key.contains('ac-tech') || key.contains('ac tech') || key.contains('air cond') || key.contains('hvac') || key.contains('air conditioning')) return 'فني تكييف';
    if (key.contains('electri')) return 'كهربائي';
    if (key.contains('clean')) return 'خدمات تنظيف';
    if (key.contains('plumb')) return 'سباك';
    if (key.contains('paint')) return 'دهان وديكور';
    if (key.contains('mechanic')) return 'ميكانيكي سيارات';
    if (key.contains('pest')) return 'مكافحة حشرات';
    if (key.contains('home') || key.contains('maint') || key.contains('care')) return 'صيانة منزلية';
    if (key.contains('ride') || key.contains('car ride') || key.contains('transport')) return 'مشوار بسيارة';
    if (key.contains('pickup') && (key.contains('deliver') || key.contains('توصيل'))) return 'استلام وتوصيل';
    if (key.contains('pickup') || key.contains('truck') || key.contains('cargo') || key.contains('freight')) return 'نقل وتوصيل';
    if (key.contains('rider') || key.contains('bike') || key.contains('moto')) return 'توصيل بالدراجة';
    if (key.contains('van') || key.contains('shuttle') || key.contains('bus')) return 'حافلة عائلية';
    if (key.contains('auto') || key.contains('rickshaw') || key.contains('tuktuk') || key.contains('tuk')) return 'عربة ريكشا';
    if (key.contains('ambulance')) return 'إسعاف';
    if (key.contains('police')) return 'شرطة';
    if (key.contains('fire')) return 'دفاع مدني وإطفاء';
    if (key.contains('hospital')) return 'مستشفى';
    if (key.contains('emerg')) return 'طوارئ الطريق';
    if (key.contains('tow')) return 'سطحة وسحب سيارات';
    if (key.contains('tyre') || key.contains('tire')) return 'تبديل وإصلاح إطارات';
    if (key.contains('battery')) return 'شحن وتبديل بطارية';
    if (key.contains('fuel')) return 'توصيل وقود';
    if (key.contains('lock') || key.contains('key')) return 'فتح أقفال';
    if (key.contains('wash')) return 'غسيل سيارات متنقل';
    if (key.contains('oil')) return 'تغيير زيت وفلاتر';
    if (key.contains('furniture') || key.contains('moving') || key.contains('mover')) return 'نقل أثاث';
    if (key.contains('garden')) return 'تنسيق حدائق';
    if (key.contains('weld')) return 'حدادة ولحام';
    if (key.contains('tailor')) return 'خياطة وتفصيل';
    if (key.contains('secur')) return 'خدمات أمنية';
    if (key.contains('courier') || key.contains('parcel')) return 'شحن طرود';
    if (key.contains('appliance')) return 'صيانة أجهزة منزلية';
    if (key.contains('laundry')) return 'غسيل وكوي';
    if (key.contains('mason') || key.contains('brick')) return 'بناء وترميم';

    if (RegExp(r'[a-zA-Z]').hasMatch(text)) {
      return 'خدمة معتمدة';
    }
    return text;
  }

  String categorySubtitle(String slugOrSubtitle, [String? fallback]) {
    final text = (fallback != null && fallback.isNotEmpty) ? fallback : slugOrSubtitle;
    if (!isArabic) return text;

    final key = '${slugOrSubtitle.toLowerCase()} ${text.toLowerCase()}';
    if (key.contains('available') || key.contains('services')) return 'خدمات متاحة وموثوقة';
    if (key.contains('wiring') || key.contains('ac &') || key.contains('ac repair') || key.contains('technician')) return 'إصلاح التكييف والأسلاك';
    if (key.contains('cleaning') || key.contains('clean &') || key.contains('repairs')) return 'تنظيف وصيانة متكاملة';
    if (key.contains('city') || key.contains('local ride') || key.contains('local rides')) return 'رحلات سريعة ومريحة داخل المدينة';
    if (key.contains('good') || key.contains('deliver')) return 'شحن ونقل البضائع بأمان';
    if (key.contains('fast') || key.contains('convenient')) return 'سريع، موثوق واقتصادي';
    if (key.contains('group') || key.contains('family')) return 'مساحة واسعة للرحلات العائلية';
    if (key.contains('affordable') || key.contains('local travel')) return 'تنقل محلي بأفضل سعر';
    if (key.contains('roadside') || key.contains('urgent aid')) return 'مساعدة فورية على مدار الساعة';
    if (key.contains('pipe') || key.contains('plumb')) return 'إصلاح وصيانة السباكة';
    if (key.contains('paint') || key.contains('wall')) return 'أعمال الدهان والديكور الحديث';
    if (key.contains('vehicle') || key.contains('engine')) return 'صيانة وإصلاح المركبات';
    if (key.contains('pest') || key.contains('spray')) return 'مكافحة وإبادة الحشرات';
    if (key.contains('wood') || key.contains('furniture')) return 'أعمال النجارة وتركيب الأثاث';
    if (key.contains('electric') || key.contains('wiring')) return 'تمديدات وصيانة كهربائية متخصصة';
    if (key.contains('maintenance') || key.contains('home care')) return 'صيانة وإصلاحات منزلية شاملة';

    if (RegExp(r'[a-zA-Z]').hasMatch(text)) {
      return 'خدمات فورية وموثوقة';
    }
    return text;
  }

  String formatDateTimeString(String dt) {
    if (!isArabic) return dt;
    return dt
        .replaceAll('Jan', 'يناير')
        .replaceAll('Feb', 'فبراير')
        .replaceAll('Mar', 'مارس')
        .replaceAll('Apr', 'أبريل')
        .replaceAll('May', 'مايو')
        .replaceAll('Jun', 'يونيو')
        .replaceAll('Jul', 'يوليو')
        .replaceAll('Aug', 'أغسطس')
        .replaceAll('Sep', 'سبتمبر')
        .replaceAll('Oct', 'أكتوبر')
        .replaceAll('Nov', 'نوفمبر')
        .replaceAll('Dec', 'ديسمبر')
        .replaceAll('PM', 'م')
        .replaceAll('AM', 'ص');
  }

  String formatTripsString(String trips) {
    if (!isArabic) return trips;
    return trips.replaceAll('trips', 'رحلة').replaceAll('trip', 'رحلة');
  }

  String formatVehicleName(String name) {
    if (!isArabic) return name;
    return name
        .replaceAll('Toyota Hilux', 'تويوتا هايلوكس')
        .replaceAll('Suzuki Ravi', 'سوزوكي رافي')
        .replaceAll('Honda 125', 'هوندا 125')
        .replaceAll('Sedan', 'سيدان')
        .replaceAll('Pickup', 'شاحنة نقل')
        .replaceAll('Van', 'حافلة');
  }

  String formatStatus(String status) {
    if (!isArabic) return status;
    final s = status.toLowerCase().trim();
    if (s == 'completed') return 'مكتمل';
    if (s == 'cancelled' || s == 'canceled') return 'ملغي';
    if (s == 'pending' || s == 'pending_otp' || s == 'pending otp') return 'قيد الانتظار';
    if (s == 'pending_profile' || s == 'pending profile') return 'بانتظار الملف';
    if (s == 'pending_verification' || s == 'pending verification' || s == 'pending review') return 'بانتظار التوثيق';
    if (s == 'approved') return 'معتمد';
    if (s == 'rejected') return 'مرفوض';
    if (s == 'suspended') return 'معلق';
    if (s == 'initiated') return 'تم البدء';
    if (s == 'in_progress' || s == 'in progress') return 'قيد التنفيذ';
    if (s == 'accepted') return 'تم القبول';
    if (s == 'arrived') return 'وصل';
    if (s == 'on_the_way' || s == 'on the way') return 'في الطريق';
    if (s == 'online') return 'متصل';
    if (s == 'offline') return 'غير متصل';
    if (s == 'active') return 'نشط';
    return status;
  }

  String get loadingNearbyServices =>
      isArabic ? 'جارٍ تحميل الخدمات القريبة منك...' : 'Loading your nearby services...';

  String formatProviderName(String name) {
    if (!isArabic) return name;
    var result = name
        .replaceAll('Ahmad Transport', 'أحمد للنقل')
        .replaceAll('Babar Logistics', 'بابر للخدمات اللوجستية')
        .replaceAll('Hassan Rider', 'حسن للتوصيل')
        .replaceAll('Ali Transport', 'علي للنقل')
        .replaceAll('Tariq Van Service', 'طارق لخدمات الحافلات')
        .replaceAll('Ahmad Raza', 'أحمد رضا')
        .replaceAll('Muhammad Bilal', 'محمد بلال')
        .replaceAll('Usman Ali', 'عثمان علي')
        .replaceAll('Hamza Sheikh', 'حمزة شيخ')
        .replaceAll('Uzair Ahmed', 'عزير أحمد')
        .replaceAll('Adnan Said', 'عدنان سعيد')
        .replaceAll('Abdul Rehman', 'عبد الرحمن')
        .replaceAll('Mehmood Khan', 'محمود خان')
        .replaceAll('Ubaid Ullah', 'عبيد الله')
        .replaceAll('Rayan Tariq', 'ريان طارق')
        .replaceAll('Omar Farooq', 'عمر فاروق')
        .replaceAll('Saad Ali', 'سعد علي')
        .replaceAll('Hassan Raza', 'حسن رضا')
        .replaceAll('Ahmad Bilal', 'أحمد بلال')
        .replaceAll('Tariq Mehmood', 'طارق محمود');

    final Map<String, String> nameTokens = {
      'Muhammad': 'محمد',
      'Mohammad': 'محمد',
      'Mohammed': 'محمد',
      'Ahmed': 'أحمد',
      'Ahmad': 'أحمد',
      'Ali': 'علي',
      'Usman': 'عثمان',
      'Umar': 'عمر',
      'Omar': 'عمر',
      'Bilal': 'بلال',
      'Hamza': 'حمزة',
      'Hassan': 'حسن',
      'Hasan': 'حسن',
      'Hussein': 'حسين',
      'Hussain': 'حسين',
      'Tariq': 'طارق',
      'Rayan': 'ريان',
      'Rayyan': 'ريان',
      'Saad': 'سعد',
      'Raza': 'رضا',
      'Uzair': 'عزير',
      'Adnan': 'عدنان',
      'Said': 'سعيد',
      'Saeed': 'سعيد',
      'Abdul': 'عبد',
      'Rehman': 'الرحمن',
      'Rahman': 'الرحمن',
      'Mehmood': 'محمود',
      'Mahmood': 'محمود',
      'Khan': 'خان',
      'Ubaid': 'عبيد',
      'Ullah': 'الله',
      'Babar': 'بابر',
      'Sheikh': 'شيخ',
      'Malik': 'مالك',
      'Qureshi': 'قريشي',
      'Syed': 'سيد',
      'Farooq': 'فاروق',
      'Zeeshan': 'ذيشان',
      'Kamran': 'كامران',
      'Imran': 'عمران',
      'Kashif': 'كاشف',
      'Naveed': 'نويد',
      'Sajid': 'ساجد',
      'Farhan': 'فرحان',
      'Asif': 'آصف',
      'Waqas': 'وقاص',
      'Shahid': 'شاهد',
      'Faisal': 'فيصل',
      'Irfan': 'عرفان',
      'Rizwan': 'رضوان',
      'Yousaf': 'يوسف',
      'Ibrahim': 'إبراهيم',
      'Mustafa': 'مصطفى',
      'Transport': 'للنقل',
      'Logistics': 'للخدمات اللوجستية',
      'Services': 'للخدمات',
      'Service': 'للخدمات',
      'Rider': 'للتوصيل',
      'Driver': 'سائق',
      'Provider': 'مزود خدمة',
      'Delivery': 'للتوصيل',
      'Express': 'إكسبريس',
    };

    nameTokens.forEach((en, ar) {
      result = result.replaceAll(RegExp('\\b$en\\b', caseSensitive: false), ar);
    });

    return result;
  }

  // ==========================================
  // Provider / Partner App Localization Getters
  // ==========================================
  String get providerSplashHeadline =>
      isArabic ? 'جاهز للاستجابة\nمصمم للخدمة' : 'Ready to respond\nBuilt to deliver';

  String get providerSplashSubtitle => isArabic
      ? 'أدر طلبات الخدمة وتواصل مع العملاء في الوقت الفعلي.'
      : 'Manage service requests reach customers \nand stay connected in real time.';

  String get providerGettingThingsReady =>
      isArabic ? 'جارٍ تجهيز كل شيء...' : 'Getting things ready...';

  String get serviceAlwaysNearYou =>
      isArabic ? 'الخدمة دائماً بقربك' : 'Service always near you';

  String get startWithPhoneNumber =>
      isArabic ? 'ابدأ برقم هاتفك' : 'Start with your phone number';

  String get enterPhoneSubtitle => isArabic
      ? 'أدخل رقم هاتفك للوصول إلى حسابك واستقبال طلبات الخدمة.'
      : 'Enter your phone number to access your account \nand receive service requests.';

  String get phoneNumberLabel => isArabic ? 'رقم الهاتف' : 'Phone Number';

  String get enterMobileNumber => isArabic ? 'أدخل رقم جوالك' : 'Enter your mobile number';

  String get continueButtonText => isArabic ? 'متابعة' : 'Continue';

  String get orDividerText => isArabic ? 'أو' : 'or';

  String get continueWithWhatsApp =>
      isArabic ? 'المتابعة عبر واتساب' : 'Continue with WhatsApp';

  String get numberSafeWithUs =>
      isArabic ? 'رقمك وبياناتك بأمان معنا.' : 'Your Number is safe with us.';

  String get oneMoreStepAhead =>
      isArabic ? 'خطوة واحدة بعد.' : 'One more step ahead.';

  String get codeSentToPhone => isArabic
      ? 'أرسلنا رمزاً مكوناً من 4 أرقام إلى هاتفك.'
      : 'We’ve sent a 4-digit code to your phone.';

  String get resendCodeIn => isArabic ? 'إعادة إرسال الرمز خلال ' : 'Resend code in ';

  String get resendCode => isArabic ? 'إعادة إرسال الرمز' : 'Resend Code';

  String get changePhoneNumber => isArabic ? 'تغيير رقم الهاتف' : 'Change Phone Number';

  String get phoneVerificationTitle =>
      isArabic ? 'توثيق الهاتف' : 'Phone Verification';

  String get verifyCode => isArabic ? 'تأكيد الرمز' : 'Verify Code';

  String get verificationSuccessful =>
      isArabic ? 'تم التوثيق بنجاح!' : 'Verification Successful';

  String get verificationSuccessfulSubtitle => isArabic
      ? 'تم توثيق هاتفك بنجاح. أكمل ملفك الشخصي لاستقبال طلبات الخدمة.'
      : 'Your phone is verified. Complete your profile \nto receive service requests.';

  String get completeYourProfile =>
      isArabic ? 'إكمال الملف الشخصي' : 'Complete  Your Profile';

  String get completeProfileSubtitle => isArabic
      ? 'أضف بيانات عملك، الخدمات وموقعك.'
      : 'Add your business details, services, and location.';

  String get getVerified => isArabic ? 'توثيق الحساب' : 'Get Verified';

  String get getVerifiedSubtitle => isArabic
      ? 'ابنِ ثقة العملاء بملف شخصي موثق ومكتمل.'
      : 'Build customer trust with a complete and verified profile.';

  String get startReceivingRequests =>
      isArabic ? 'استقبال الطلبات' : 'Start Receiving Requests';

  String get startReceivingRequestsSubtitle => isArabic
      ? 'اتصل بالإنترنت وابدأ في استقبال طلبات الخدمة.'
      : 'Go online and start receiving service requests.';

  String get providerProfileDetails =>
      isArabic ? 'بيانات الملف الشخصي' : 'Provider Profile Details';

  String get enterPersonalDetailsToContinue => isArabic
      ? 'أدخل بياناتك الشخصية للمتابعة.'
      : 'Enter your personal details to continue.';

  String get personalInformationHeading =>
      isArabic ? 'المعلومات الشخصية' : 'Personal Information';

  String get fullNameLabel => isArabic ? 'الاسم الكامل' : 'Full Name';

  String get fullNamePlaceholder => isArabic ? 'حسن رضا' : 'Hassan Raza';

  String get asPerIqama => isArabic ? '(حسب الإقامة/الهوية)' : '(as per Iqama)';

  String get iqamaNumberLabel => isArabic ? 'رقم الإقامة / الهوية' : 'Iqama Number';

  String get iqamaExpiryDateLabel => isArabic ? 'تاريخ انتهاء الإقامة' : 'Iqama Expiry Date';

  String get contactInformationHeading =>
      isArabic ? 'معلومات الاتصال' : 'Contact Information';

  String get whatsappNumberLabel => isArabic ? 'رقم الواتساب' : 'WhatsApp number';

  String get optionalLabel => isArabic ? '(اختياري)' : '(Optional)';

  String get vehicleServiceDetailsTitle =>
      isArabic ? 'تفاصيل المركبة والخدمة' : 'Vehicle & Service Details';

  String get serviceCategoryLabel => isArabic ? 'فئة الخدمة' : 'Service Category';

  String get vehicleTypeLabel => isArabic ? 'نوع المركبة' : 'Vehicle Type';

  String get plateNumberLabel => isArabic ? 'رقم اللوحة' : 'Plate Number';

  String get vehicleModelLabel => isArabic ? 'موديل المركبة' : 'Vehicle Model';

  String get vehicleColorLabel => isArabic ? 'لون المركبة' : 'Vehicle Color';

  String get selectServiceCategory =>
      isArabic ? 'اختر فئة الخدمة' : 'Select Service Category';

  String get vehicleServiceSubtitle => isArabic
      ? 'اختر فئة الخدمة وأدخل تفاصيل مركبتك.'
      : 'Select a service category and enter\nyour vehicle details.';

  String get selectVehicleType => isArabic ? 'اختر نوع المركبة' : 'Select Vehicle Type';

  String get selectVehicleColor => isArabic ? 'اختر لون المركبة' : 'Select Vehicle Color';

  String get uploadDocumentsTitle => isArabic ? 'رفع المستندات' : 'Upload Documents';

  String get uploadDocumentsSubtitle => isArabic
      ? 'ارفع المستندات المطلوبة للتحقق.'
      : 'Upload the required documents for verification.';

  String get iqamaDocTitle => isArabic ? 'الإقامة / الهوية' : 'Iqama';

  String get iqamaDocSubtitle =>
      isArabic ? 'ارفع صورة واضحة للإقامة أو الهوية.' : 'Upload a clear Iqama image.';

  String get docValidNotExpired =>
      isArabic ? 'سارية المفعول وغير منتهية' : 'Valid and not expired';

  String get vehicleRegDocTitle =>
      isArabic ? 'استمارة المركبة' : 'Vehicle Registration';

  String get vehicleRegDocSubtitle =>
      isArabic ? 'ارفع صورة واضحة لاستمارتك.' : 'Upload a clear registration image.';

  String get drivingLicenceDocTitle =>
      isArabic ? 'رخصة القيادة' : 'Driving Licence';

  String get drivingLicenceDocSubtitle =>
      isArabic ? 'ارفع صورة واضحة لرخصتك.' : 'Upload a clear licence image.';

  String get vehiclePhotosTitle => isArabic ? 'صور المركبة' : 'Vehicle Photos';

  String get vehiclePhotosSubtitle => isArabic
      ? 'ارفع صوراً أمامية وخلفية لمركبتك'
      : 'Upload front and rear photos of your vehicle';

  String get frontView => isArabic ? 'الجهة الأمامية' : 'Front View';

  String get rearView => isArabic ? 'الجهة الخلفية' : 'Rear View';

  String get tapToUpload => isArabic ? 'اضغط للرفع' : 'Tap to upload';

  String get uploadedBadge => isArabic ? 'تم الرفع' : 'Uploaded';

  String get adminApprovalPendingTitle =>
      isArabic ? 'بانتظار موافقة الإدارة' : 'Admin Approval pending';

  String get adminApprovalPendingSubtitle => isArabic
      ? 'تم إرسال حسابك وفريقنا يقوم بمراجعته حالياً.'
      : 'Your account is submitted our team \nis reviewing it.';

  String get adminApprovalTitle => isArabic ? 'موافقة الإدارة' : 'Admin Approval';

  String get accountDetailsItem => isArabic ? 'بيانات الحساب' : 'Account Details';

  String get accountDetailsItemSubtitle => isArabic
      ? 'تم تقديم معلوماتك الأساسية.'
      : 'Your basic information has been submitted.';

  String get documentVerificationItem =>
      isArabic ? 'التحقق من المستندات' : 'Document Verification';

  String get documentVerificationItemSubtitle =>
      isArabic ? 'نقوم حالياً بمراجعة مستنداتك.' : 'We are reviewing your documents.';

  String get adminApprovalItem => isArabic ? 'موافقة الإدارة' : 'Admin Approval';

  String get adminApprovalItemSubtitle =>
      isArabic ? 'الاعتماد النهائي من فريقنا.' : 'Final Approval from our team.';

  String get statusCompleted => isArabic ? 'مكتمل' : 'Completed';

  String get statusInProgress => isArabic ? 'قيد التنفيذ' : 'In Progress';

  String get statusPendingBadge => isArabic ? 'قيد الانتظار' : 'Pending';

  String get whatsNext => isArabic ? 'ما هي الخطوة التالية؟' : 'What’s Next?';

  String get whatsNextSubtitle => isArabic
      ? 'سيتم إشعارك فور الاعتماد، عادةً خلال 1–24 ساعة.'
      : 'You’ll be notified once approved usually \nwithin 1–24 hours.';

  String get backToHome => isArabic ? 'العودة للرئيسية' : 'Back to Home';

  String get providerHomeTitle => isArabic ? 'رئيسية مزود الخدمة' : 'Provider Home';

  String formatProviderServiceName(String name) {
    if (!isArabic) return name;
    final s = name.toLowerCase();
    if (s.contains('vehicle towing') || s.contains('towing')) return 'سطحة وسحب سيارات';
    if (s.contains('flatbed')) return 'سطحة هيدروليك';
    if (s.contains('battery')) return 'شحن وتبديل بطارية';
    if (s.contains('tire') || s.contains('tyre')) return 'إصلاح وتبديل إطارات';
    if (s.contains('fuel')) return 'توصيل وقود';
    if (s.contains('recovery') || s.contains('emergency')) return 'إنقاذ وطوارئ';
    return name;
  }

  String formatProviderVehicleType(String type) {
    if (!isArabic) return type;
    final t = type.toLowerCase();
    if (t.contains('flatbed truck') || t.contains('flatbed')) return 'سطحة مستوية (هيدروليك)';
    if (t.contains('wheel-lift')) return 'ونش رفع عجلة';
    if (t.contains('integrated')) return 'ونش سحب مدمج';
    if (t.contains('heavy-duty')) return 'شاحنة إنقاذ للمهام الثقيلة';
    if (t.contains('van')) return 'فان خدمات متنقل';
    return type;
  }

  String formatProviderColor(String color) {
    if (!isArabic) return color;
    final c = color.toLowerCase();
    if (c == 'white') return 'أبيض';
    if (c == 'black') return 'أسود';
    if (c == 'silver') return 'فضي';
    if (c == 'grey' || c == 'gray') return 'رمادي';
    if (c == 'red') return 'أحمر';
    if (c == 'blue') return 'أزرق';
    if (c == 'yellow') return 'أصفر';
    if (c == 'green') return 'أخضر';
    return color;
  }

  String get uploaded => isArabic ? 'تم الرفع' : 'Uploaded';

  String get uploadButtonText => isArabic ? 'رفع' : 'Upload';

  // Location Permission Screen
  String get nearbyProviders => isArabic ? 'مزودون\nقريبون' : 'Nearby\nProviders';
  String get fastDelivery => isArabic ? 'خدمة\nسريعة' : 'Fast\nDelivery';
  String get realtimeTracking => isArabic ? 'تتبع\nمباشر' : 'Real-time\nTracking';
  String get findProvidersNearYou => isArabic ? 'ابحث عن مزودين قريبين منك' : 'Find Providers near you';
  String locationNeededForService(String serviceName) => isArabic
      ? 'نحتاج موقعك لعرض مزودين قريبين لخدمة $serviceName.'
      : 'We need your location to show nearby providers for $serviceName.';
  String get seeNearbyProviders => isArabic ? 'عرض المزودين القريبين' : 'See nearby providers';
  String get seeNearbyProvidersSubtitle => isArabic
      ? 'اعثر على فرق التوصيل المتاحة بالقرب منك.'
      : 'Find available pickup and delivery teams around you.';
  String get fastService => isArabic ? 'خدمة سريعة' : 'Fast service';
  String get fastServiceSubtitle =>
      isArabic ? 'احصل على نتائج أسرع وأكثر دقة.' : 'Get quicker and more accurate results.';
  String get yourPrivacyMatters => isArabic ? 'خصوصيتك مهمة' : 'Your privacy matters';
  String get yourPrivacyMattersSubtitle => isArabic
      ? 'موقعك يستخدم فقط لهذه الخدمة ويمكن تغييره في أي وقت.'
      : 'Your location is only used for this service and can be changed anytime.';
  String get allowLocation => isArabic ? 'السماح بالموقع' : 'Allow Location';
  String get openingLocationSettings =>
      isArabic ? 'فتح إعدادات الموقع...' : 'Opening Location Settings...';
  String get youCanChangeThisLaterIn =>
      isArabic ? 'يمكنك تغيير هذا لاحقاً في ' : 'You can change this later in ';
  String get settingsLink => isArabic ? 'الإعدادات' : 'Settings';

  // ==========================================
  // Universal Zero-Leakage Auto-Translation Pipeline
  // ==========================================
  /// Translates dynamic and static strings to the active language.
  /// Guarantees ZERO English leakage when app is in Arabic mode.
  String auto(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '';
    final trimmed = raw.trim();
    if (!isArabic) return trimmed;

    // 1. If text is already pure Arabic / numbers / punctuation, return as-is
    if (!RegExp(r'[a-zA-Z]').hasMatch(trimmed)) {
      return trimmed;
    }

    // 2. Direct dictionary match (exact lowercase)
    final lower = trimmed.toLowerCase();
    if (lower == 'pickup & delivery' || lower == 'pickup and delivery' || lower == 'pickup & delivery') {
      return 'استلام وتوصيل';
    }
    final direct = _autoTranslationMap[lower];
    if (direct != null) return direct;

    // 3. Statuses check
    final statusMatch = formatStatus(trimmed);
    if (statusMatch != trimmed) return statusMatch;

    // 4. Vehicles check
    final vehicleMatch = formatVehicleName(trimmed);
    if (vehicleMatch != trimmed) return vehicleMatch;

    // 5. Providers check
    final providerMatch = formatProviderName(trimmed);
    if (providerMatch != trimmed) return providerMatch;

    // 6. Service Categories check
    final catMatch = categoryName(trimmed);
    if (catMatch != 'خدمة معتمدة' && catMatch != trimmed) return catMatch;

    // 7. Multi-segment handling: "Part A • Part B" or "Part A | Part B" or "Part A - Part B"
    for (final delimiter in [' • ', ' . ', ' - ', ' | ', ' / ', ', ']) {
      if (trimmed.contains(delimiter)) {
        final parts = trimmed.split(delimiter);
        final translatedParts = parts.map((p) => auto(p)).toList();
        return translatedParts.join(delimiter == ' . ' ? ' • ' : delimiter);
      }
    }

    // 8. Distance, ETA, Trips and Currency regex replacements
    var result = trimmed;
    result = result
        .replaceAll(RegExp(r'(\d+(?:\.\d+)?)\s*min(?:s)?\s*away', caseSensitive: false), r'$1 دقائق متبقية')
        .replaceAll(RegExp(r'(\d+(?:\.\d+)?)\s*km\s*away', caseSensitive: false), r'$1 كم متبقي')
        .replaceAll(RegExp(r'(\d+(?:\.\d+)?)\s*min(?:s)?', caseSensitive: false), r'$1 دقيقة')
        .replaceAll(RegExp(r'(\d+(?:\.\d+)?)\s*km', caseSensitive: false), r'$1 كم')
        .replaceAll(RegExp(r'(\d+(?:\.\d+)?)\s*trips', caseSensitive: false), r'$1 رحلة')
        .replaceAll(RegExp(r'(\d+(?:\.\d+)?)\s*trip', caseSensitive: false), r'$1 رحلة')
        .replaceAll(RegExp(r'SAR\s*(\d+(?:\.\d+)?)', caseSensitive: false), r'$1 ر.س')
        .replaceAll(RegExp(r'(\d+(?:\.\d+)?)\s*SAR', caseSensitive: false), r'$1 ر.س')
        .replaceAll(RegExp(r'RS\s*(\d+(?:\.\d+)?)', caseSensitive: false), r'$1 ر.س')
        .replaceAll(RegExp(r'(\d+(?:\.\d+)?)\s*RS', caseSensitive: false), r'$1 ر.س')
        .replaceAll(RegExp(r'\bmin away\b', caseSensitive: false), 'دقائق متبقية')
        .replaceAll(RegExp(r'\bkm away\b', caseSensitive: false), 'كم متبقي');

    // 9. Word token replacement for any remaining English words
    _autoTranslationMap.forEach((enKey, arVal) {
      if (enKey.length >= 2 && !enKey.contains(' ')) {
        result = result.replaceAll(RegExp('\\b$enKey\\b', caseSensitive: false), arVal);
      }
    });

    return result;
  }

  static const Map<String, String> _autoTranslationMap = {
    // Actions & Buttons
    'got it': 'فهمت ذلك',
    "what's next": 'ما الخطوة التالية؟',
    "what's next?": 'ما الخطوة التالية؟',
    'what’s next': 'ما الخطوة التالية؟',
    'what’s next?': 'ما الخطوة التالية؟',
    'allow location': 'السماح بالموقع',
    'allow': 'السماح',
    'deny': 'رفض',
    'confirm': 'تأكيد',
    'cancel': 'إلغاء',
    'canceled': 'ملغي',
    'cancelled': 'ملغي',
    'submit': 'إرسال',
    'save': 'حفظ',
    'edit': 'تعديل',
    'delete': 'حذف',
    'remove': 'إزالة',
    'close': 'إغلاق',
    'back': 'رجوع',
    'next': 'التالي',
    'continue': 'متابعة',
    'done': 'تم',
    'finish': 'إنهاء',
    'view': 'عرض',
    'details': 'التفاصيل',
    'search': 'بحث',
    'call': 'اتصال',
    'chat': 'محادثة',
    'message': 'رسالة',
    'share': 'مشاركة',
    'retry': 'إعادة المحاولة',
    'refresh': 'تحديث',
    'ok': 'موافق',
    'yes': 'نعم',
    'no': 'لا',
    'apply': 'تطبيق',
    'choose': 'اختيار',
    'select': 'تحديد',
    'upload': 'رفع',
    'uploaded': 'تم الرفع',
    'clear': 'مسح',
    'reset': 'إعادة تعيين',
    'filter': 'تصفية',
    'sort': 'ترتيب',

    // Auth & Phone Verification
    'phone number': 'رقم الهاتف',
    'phone': 'الهاتف',
    'mobile number': 'رقم الجوال',
    'mobile': 'الجوال',
    'enter your mobile number': 'أدخل رقم جوالك',
    'start with your phone number': 'ابدأ برقم هاتفك',
    'enter your phone number to access your account and receive service requests': 'أدخل رقم هاتفك للوصول إلى حسابك واستقبال طلبات الخدمة',
    'enter your phone number to access your account and receive service requests.': 'أدخل رقم هاتفك للوصول إلى حسابك واستقبال طلبات الخدمة.',
    'continue with whatsapp': 'المتابعة عبر واتساب',
    'your number is safe with us': 'رقمك وبياناتك بأمان معنا',
    'your number is safe with us.': 'رقمك وبياناتك بأمان معنا.',
    'one more step ahead': 'خطوة واحدة بعد',
    'one more step ahead.': 'خطوة واحدة بعد.',
    'we’ve sent a 4-digit code to your phone': 'أرسلنا رمزاً مكوناً من 4 أرقام إلى هاتفك',
    'we’ve sent a 4-digit code to your phone.': 'أرسلنا رمزاً مكوناً من 4 أرقام إلى هاتفك.',
    'resend code in': 'إعادة إرسال الرمز خلال',
    'resend code': 'إعادة إرسال الرمز',
    'change phone number': 'تغيير رقم الهاتف',
    'phone verification': 'توثيق الهاتف',
    'verify code': 'تأكيد الرمز',
    'back to home': 'العودة للرئيسية',
    'personal information': 'المعلومات الشخصية',
    'contact information': 'معلومات الاتصال',
    'full name': 'الاسم الكامل',
    'full name (as per iqama)': 'الاسم الكامل (حسب الإقامة/الهوية)',
    'full name  (as per iqama)': 'الاسم الكامل (حسب الإقامة/الهوية)',
    'as per iqama': '(حسب الإقامة/الهوية)',
    '(as per iqama)': '(حسب الإقامة/الهوية)',
    'hassan raza': 'حسن رضا',
    'dd/mm/yyy': 'يوم/شهر/سنة',
    'dd/mm/yyyy': 'يوم/شهر/سنة',
    'iqama number': 'رقم الإقامة / الهوية',
    'iqama expiry date': 'تاريخ انتهاء الإقامة',
    'service category': 'فئة الخدمة',
    'vehicle type': 'نوع المركبة',
    'plate number': 'رقم اللوحة',
    'vehicle model': 'موديل المركبة',
    'vehicle color': 'لون المركبة',
    'enter vehicle model': 'أدخل موديل المركبة',
    'select service category': 'اختر فئة الخدمة',
    'select vehicle type': 'اختر نوع المركبة',
    'select vehicle color': 'اختر لون المركبة',
    'complete your profile': 'إكمال الملف الشخصي',
    'complete  your profile': 'إكمال الملف الشخصي',
    'add your business details, services, and location': 'أضف بيانات عملك، الخدمات وموقعك',
    'add your business details, services, and location.': 'أضف بيانات عملك، الخدمات وموقعك.',
    'get verified': 'توثيق الحساب',
    'build customer trust with a complete and verified profile': 'ابنِ ثقة العملاء بملف شخصي موثق ومكتمل',
    'build customer trust with a complete and verified profile.': 'ابنِ ثقة العملاء بملف شخصي موثق ومكتمل.',
    'start receiving requests': 'استقبال الطلبات',
    'go online and start receiving service requests': 'اتصل بالإنترنت وابدأ في استقبال طلبات الخدمة',
    'go online and start receiving service requests.': 'اتصل بالإنترنت وابدأ في استقبال طلبات الخدمة.',
    'admin approval pending': 'بانتظار موافقة الإدارة',
    'your account is submitted our team is reviewing it': 'تم إرسال حسابك وفريقنا يقوم بمراجعته حالياً',
    'your account is submitted our team is reviewing it.': 'تم إرسال حسابك وفريقنا يقوم بمراجعته حالياً.',
    'your account is submitted our team \nis reviewing it.': 'تم إرسال حسابك وفريقنا يقوم بمراجعته حالياً.',
    'account details': 'بيانات الحساب',
    'document verification': 'التحقق من المستندات',
    'admin approval': 'موافقة الإدارة',
    'upload documents': 'رفع المستندات',
    'vehicle & service details': 'تفاصيل المركبة والخدمة',
    'provider profile details': 'بيانات الملف الشخصي',
    'enter your personal details to continue': 'أدخل بياناتك الشخصية للمتابعة',
    'enter your personal details to continue.': 'أدخل بياناتك الشخصية للمتابعة.',
    'select a service category and enter your vehicle details': 'اختر فئة الخدمة وأدخل تفاصيل مركبتك',
    'select a service category and enter your vehicle details.': 'اختر فئة الخدمة وأدخل تفاصيل مركبتك.',
    'select a service category and enter\nyour vehicle details.': 'اختر فئة الخدمة وأدخل تفاصيل مركبتك.',
    'vehicle photos': 'صور المركبة',
    'upload front and rear photos of your vehicle': 'ارفع صوراً أمامية وخلفية لمركبتك',
    'front view': 'الجهة الأمامية',
    'rear view': 'الجهة الخلفية',
    'tap to upload': 'اضغط للرفع',
    'driving licence': 'رخصة القيادة',
    'vehicle registration': 'استمارة المركبة',
    'iqama': 'الإقامة / الهوية',
    'valid and not expired': 'سارية المفعول وغير منتهية',

    // Statuses & Tracking
    'online': 'متصل',
    'offline': 'غير متصل',
    'active': 'نشط',
    'pending': 'قيد الانتظار',
    'in progress': 'قيد التنفيذ',
    'in_progress': 'قيد التنفيذ',
    'completed': 'مكتمل',
    'accepted': 'تم القبول',
    'arrived': 'وصل',
    'on the way': 'في الطريق',
    'on_the_way': 'في الطريق',
    'driver arrived': 'وصل السائق',
    'provider arrived': 'وصل مزود الخدمة',
    'finding provider': 'جارٍ البحث عن مزود',
    'finding driver': 'جارٍ البحث عن سائق',
    'live tracking': 'تتبع مباشر',
    'real-time tracking': 'تتبع في الوقت الفعلي',
    'fast delivery': 'خدمة سريعة',
    'fast service': 'خدمة سريعة',
    'nearby providers': 'مزودون قريبون',
    'see nearby providers': 'عرض المزودين القريبين',
    'pickup location': 'موقع الاستلام',
    'dropoff location': 'موقع التسليم',
    'current location': 'الموقع الحالي',
    'set location': 'تأكيد الموقع',
    'destination': 'الوجهة',
    'distance': 'المسافة',
    'duration': 'الوقت المتوقع',
    'estimated arrival': 'الوقت المتوقع للوصول',
    'min away': 'دقائق متبقية',
    'mins away': 'دقائق متبقية',
    'km away': 'كم متبقي',
    'min': 'دقيقة',
    'mins': 'دقائق',
    'km': 'كم',
    'trips': 'رحلات',
    'trip': 'رحلة',
    'rating': 'التقييم',
    'reviews': 'التقييمات',
    'away': 'متبقي',

    // Pricing & Payment
    'cash': 'نقداً',
    'card': 'بطاقة',
    'credit card': 'بطاقة ائتمانية',
    'wallet': 'المحفظة',
    'fare': 'الأجرة',
    'total': 'المجموع',
    'price': 'السعر',
    'estimated fare': 'الأجرة المتوقعة',
    'pay': 'دفع',
    'payment': 'الدفع',
    'sar': 'ر.س',
    'rs': 'ر.س',
    'free': 'مجاناً',

    // Vehicles & Common Services
    'sedan': 'سيدان',
    'sedan • ac': 'سيدان • مكيف',
    'sedan . ac': 'سيدان • مكيف',
    'sedan • non-ac': 'سيدان • بدون تكييف',
    'sedan . non-ac': 'سيدان • بدون تكييف',
    'ac': 'مكيف',
    'non-ac': 'بدون تكييف',
    'pickup': 'شاحنة نقل',
    'pickup & delivery': 'استلام وتوصيل',
    'pickup and delivery': 'استلام وتوصيل',
    'cargo': 'نقل بضائع',
    'van': 'حافلة عائلية',
    'bike': 'دراجة',
    'motorcycle': 'دراجة نارية',
    'rickshaw': 'عربة ريكشا',
    'towing': 'سطحة وسحب',
    'flatbed': 'سطحة هيدروليكية',
    'flatbed truck': 'سطحة هيدروليكية',
    'wheel-lift': 'ونش رفع عجلة',
    'emergency': 'طوارئ',
    'roadside assistance': 'مساعدة على الطريق',
    'fuel delivery': 'توصيل وقود',
    'battery jumpstart': 'شحن بطارية',
    'tire change': 'تبديل إطار',
    'lockout': 'فتح أقفال',
    'mechanic': 'ميكانيكي سيارات',
    'electrician': 'كهربائي',
    'plumber': 'سباك',
    'carpenter': 'نجار',
    'ac technician': 'فني تكييف',
    'cleaning': 'تنظيف',
    'home maintenance': 'صيانة منزلية',
    'suzuki swift': 'سوزوكي سويفت',
    'toyota hilux': 'تويوتا هايلوكس',
    'suzuki ravi': 'سوزوكي رافي',
    'honda 125': 'هوندا 125',

    // Colors
    'white': 'أبيض',
    'black': 'أسود',
    'silver': 'فضي',
    'grey': 'رمادي',
    'gray': 'رمادي',
    'red': 'أحمر',
    'blue': 'أزرق',
    'yellow': 'أصفر',
    'green': 'أخضر',

    // Specific Provider Vehicle & Service Options
    'vehicle towing': 'سطحة وسحب سيارات',
    'flatbed towing': 'سطحة هيدروليك',
    'tire assistance': 'إصلاح وتبديل إطارات',
    'emergency recovery': 'إنقاذ وسحب طوارئ',
    'wheel-lift tow truck': 'سطحة سحب هيدروليكية',
    'integrated tow truck': 'شاحنة سحب متكاملة',
    'heavy-duty recovery truck': 'شاحنة سحب ثقيلة',
    'service van': 'فان صيانة',

    'dashboard': 'لوحة التحكم',
    'dashbaord': 'لوحة التحكم',
    'see how customers find and contact you.': 'تعرف على كيفية عثور العملاء عليك والتواصل معك.',
    'see how customers find and contact you': 'تعرف على كيفية عثور العملاء عليك والتواصل معك.',
    'profile views': 'مشاهدات الملف الشخصي',
    'customers viewed your profile': 'العملاء الذين شاهدوا ملفك الشخصي',
    'contacts received': 'جهات الاتصال المستلمة',
    'customers contacted you through qareeb.': 'العملاء الذين تواصلوا معك عبر قريب.',
    'customers contacted you through qareeb': 'العملاء الذين تواصلوا معك عبر قريب.',
    'calls received': 'المكالمات المستلمة',
    'whatsapp tabs': 'نقرات واتساب',
    'whatsapp taps': 'نقرات واتساب',
    'vs yesterday': 'مقارنة بالأمس',
    'today': 'اليوم',
    'yesterday': 'الأمس',
    '10days': '١٠ أيام',
    '15 days': '١٥ يوماً',
    '20 days': '٢٠ يوماً',
    'mon': 'إثنين',
    'tue': 'ثلاثاء',
    'wed': 'أربعاء',
    'thu': 'خميس',
    'fri': 'جمعة',
    'sat': 'سبت',
    'sun': 'أحد',
    'settings': 'الإعدادات',
    'profile': 'الملف الشخصي',
    'history': 'السجل',
    'notifications': 'الإشعارات',
    'help & support': 'المساعدة والدعم',
    'support': 'الدعم',
    'privacy policy': 'سياسة الخصوصية',
    'terms & conditions': 'الشروط والأحكام',
    'logout': 'تسجيل الخروج',
    'log out': 'تسجيل الخروج',
    'sign out': 'تسجيل الخروج',
    'sign in': 'تسجيل الدخول',
    'login': 'تسجيل الدخول',
    'register': 'إنشاء حساب',
    'home': 'الرئيسية',
    'orders': 'الطلبات',
    'my orders': 'طلباتي',
    'requests': 'الطلبات',
    'my requests': 'طلباتي',
    'activity': 'النشاط',
    'loading': 'جارٍ التحميل...',
    'loading...': 'جارٍ التحميل...',
    'please wait': 'يرجى الانتظار...',
  };
}
