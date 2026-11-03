// ignore_for_file: prefer_initializing_formals
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';

/// Provider Registration Data Model
/// Completely null-safe and resilient against hot-reload or legacy cached state.
class ProviderRegistrationData {
  final String? _phone;
  final bool? _isWhatsApp;
  final String? _fullName;
  final String? _iqamaNumber;
  final String? _iqamaExpiry;
  final String? _contactPhone;
  final String? _whatsappNumber;
  final String? _serviceCategory;
  final String? _vehicleType;
  final String? _plateNumber;
  final String? _vehicleModel;
  final String? _vehicleColor;
  final bool? _iqamaUploaded;
  final bool? _registrationUploaded;
  final bool? _licenceUploaded;
  final bool? _vehicleFrontUploaded;
  final bool? _vehicleRearUploaded;
  final bool? _vehicleLeftUploaded;
  final bool? _vehicleRightUploaded;
  final List<String>? _vehiclePhotos;
  final double? latitude;
  final double? longitude;
  final String? _status;
  final String? _publicId;
  final String? authToken;
  final bool? _isOnboardingCompleted;
  final bool? _isOnline;

  String get phone => _phone ?? '';
  bool get isWhatsApp => _isWhatsApp == true;
  String get fullName => _fullName ?? '';
  String get iqamaNumber => _iqamaNumber ?? '';
  String get iqamaExpiry => _iqamaExpiry ?? '';
  String get contactPhone => _contactPhone ?? '';
  String get whatsappNumber => _whatsappNumber ?? '';
  String get serviceCategory => _serviceCategory ?? '';
  String get vehicleType => _vehicleType ?? '';
  String get plateNumber => _plateNumber ?? '';
  String get vehicleModel => _vehicleModel ?? '';
  String get vehicleColor => _vehicleColor ?? '';
  bool get iqamaUploaded => _iqamaUploaded == true;
  bool get registrationUploaded => _registrationUploaded == true;
  bool get licenceUploaded => _licenceUploaded == true;
  bool get vehicleFrontUploaded => _vehicleFrontUploaded == true;
  bool get vehicleRearUploaded => _vehicleRearUploaded == true;
  bool get vehicleLeftUploaded => _vehicleLeftUploaded == true;
  bool get vehicleRightUploaded => _vehicleRightUploaded == true;
  List<String> get vehiclePhotos => _vehiclePhotos ?? const [];
  String get status => _status ?? 'PENDING_PROFILE';
  String get publicId => _publicId ?? 'QRB-1082';
  bool get isOnboardingCompleted => _isOnboardingCompleted == true;
  bool get isOnline => _isOnline == true;
  bool get isSuspended =>
      _status == 'SUSPENDED' || _status == 'REJECTED' || _status == 'DECLINED';

  const ProviderRegistrationData({
    String? phone,
    bool? isWhatsApp,
    String? fullName,
    String? iqamaNumber,
    String? iqamaExpiry,
    String? contactPhone,
    String? whatsappNumber,
    String? serviceCategory,
    String? vehicleType,
    String? plateNumber,
    String? vehicleModel,
    String? vehicleColor,
    bool? iqamaUploaded,
    bool? registrationUploaded,
    bool? licenceUploaded,
    bool? vehicleFrontUploaded,
    bool? vehicleRearUploaded,
    bool? vehicleLeftUploaded,
    bool? vehicleRightUploaded,
    List<String>? vehiclePhotos,
    this.latitude,
    this.longitude,
    String? status,
    String? publicId,
    this.authToken,
    bool? isOnboardingCompleted,
    bool? isOnline,
  })  : _phone = phone,
        _isWhatsApp = isWhatsApp,
        _fullName = fullName,
        _iqamaNumber = iqamaNumber,
        _iqamaExpiry = iqamaExpiry,
        _contactPhone = contactPhone,
        _whatsappNumber = whatsappNumber,
        _serviceCategory = serviceCategory,
        _vehicleType = vehicleType,
        _plateNumber = plateNumber,
        _vehicleModel = vehicleModel,
        _vehicleColor = vehicleColor,
        _iqamaUploaded = iqamaUploaded,
        _registrationUploaded = registrationUploaded,
        _licenceUploaded = licenceUploaded,
        _vehicleFrontUploaded = vehicleFrontUploaded,
        _vehicleRearUploaded = vehicleRearUploaded,
        _vehicleLeftUploaded = vehicleLeftUploaded,
        _vehicleRightUploaded = vehicleRightUploaded,
        _vehiclePhotos = vehiclePhotos,
        _status = status,
        _publicId = publicId,
        _isOnboardingCompleted = isOnboardingCompleted,
        _isOnline = isOnline;

  ProviderRegistrationData copyWith({
    String? phone,
    bool? isWhatsApp,
    String? fullName,
    String? iqamaNumber,
    String? iqamaExpiry,
    String? contactPhone,
    String? whatsappNumber,
    String? serviceCategory,
    String? vehicleType,
    String? plateNumber,
    String? vehicleModel,
    String? vehicleColor,
    bool? iqamaUploaded,
    bool? registrationUploaded,
    bool? licenceUploaded,
    bool? vehicleFrontUploaded,
    bool? vehicleRearUploaded,
    bool? vehicleLeftUploaded,
    bool? vehicleRightUploaded,
    List<String>? vehiclePhotos,
    double? latitude,
    double? longitude,
    String? status,
    String? publicId,
    String? authToken,
    bool? isOnboardingCompleted,
    bool? isOnline,
  }) {
    return ProviderRegistrationData(
      phone: phone ?? this.phone,
      isWhatsApp: isWhatsApp ?? this.isWhatsApp,
      fullName: fullName ?? this.fullName,
      iqamaNumber: iqamaNumber ?? this.iqamaNumber,
      iqamaExpiry: iqamaExpiry ?? this.iqamaExpiry,
      contactPhone: contactPhone ?? this.contactPhone,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      vehicleType: vehicleType ?? this.vehicleType,
      plateNumber: plateNumber ?? this.plateNumber,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      iqamaUploaded: iqamaUploaded ?? this.iqamaUploaded,
      registrationUploaded: registrationUploaded ?? this.registrationUploaded,
      licenceUploaded: licenceUploaded ?? this.licenceUploaded,
      vehicleFrontUploaded: vehicleFrontUploaded ?? this.vehicleFrontUploaded,
      vehicleRearUploaded: vehicleRearUploaded ?? this.vehicleRearUploaded,
      vehicleLeftUploaded: vehicleLeftUploaded ?? this.vehicleLeftUploaded,
      vehicleRightUploaded: vehicleRightUploaded ?? this.vehicleRightUploaded,
      vehiclePhotos: vehiclePhotos ?? this.vehiclePhotos,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      publicId: publicId ?? this.publicId,
      authToken: authToken ?? this.authToken,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'isWhatsApp': isWhatsApp,
      'fullName': fullName,
      'iqamaNumber': iqamaNumber,
      'iqamaExpiry': iqamaExpiry,
      'contactPhone': contactPhone,
      'whatsappNumber': whatsappNumber,
      'serviceCategory': serviceCategory,
      'vehicleType': vehicleType,
      'plateNumber': plateNumber,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'iqamaUploaded': iqamaUploaded,
      'registrationUploaded': registrationUploaded,
      'licenceUploaded': licenceUploaded,
      'vehicleFrontUploaded': vehicleFrontUploaded,
      'vehicleRearUploaded': vehicleRearUploaded,
      'vehicleLeftUploaded': vehicleLeftUploaded,
      'vehicleRightUploaded': vehicleRightUploaded,
      'vehiclePhotos': vehiclePhotos,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'publicId': publicId,
      'authToken': authToken,
      'isOnboardingCompleted': isOnboardingCompleted,
      'isOnline': isOnline,
    };
  }

  factory ProviderRegistrationData.fromJson(Map<String, dynamic> json) {
    return ProviderRegistrationData(
      phone: json['phone'] as String?,
      isWhatsApp: json['isWhatsApp'] as bool?,
      fullName: json['fullName'] as String?,
      iqamaNumber: json['iqamaNumber'] as String?,
      iqamaExpiry: json['iqamaExpiry'] as String?,
      contactPhone: json['contactPhone'] as String?,
      whatsappNumber: json['whatsappNumber'] as String?,
      serviceCategory: json['serviceCategory'] as String?,
      vehicleType: json['vehicleType'] as String?,
      plateNumber: json['plateNumber'] as String?,
      vehicleModel: json['vehicleModel'] as String?,
      vehicleColor: json['vehicleColor'] as String?,
      iqamaUploaded: json['iqamaUploaded'] as bool?,
      registrationUploaded: json['registrationUploaded'] as bool?,
      licenceUploaded: json['licenceUploaded'] as bool?,
      vehicleFrontUploaded: json['vehicleFrontUploaded'] as bool?,
      vehicleRearUploaded: json['vehicleRearUploaded'] as bool?,
      vehicleLeftUploaded: json['vehicleLeftUploaded'] as bool?,
      vehicleRightUploaded: json['vehicleRightUploaded'] as bool?,
      vehiclePhotos: (json['vehiclePhotos'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      status: json['status'] as String?,
      publicId: json['publicId'] as String?,
      authToken: json['authToken'] as String?,
      isOnboardingCompleted: json['isOnboardingCompleted'] as bool?,
      isOnline: json['isOnline'] as bool?,
    );
  }
}

/// Global Singleton store allowing seamless persistent data sharing across all provider steps
class ProviderRegistrationStore {
  ProviderRegistrationStore._();
  static final ProviderRegistrationStore instance = ProviderRegistrationStore._();

  static const String _storageKey = 'qareeb_provider_registration_store_v1';
  static const String activeAppModeKey = 'qareeb_active_app_mode';

  ProviderRegistrationData data = const ProviderRegistrationData();
  bool isLoaded = false;

  /// Returns 'provider' if provider mode is active, otherwise 'customer'.
  Future<String> getActiveAppMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mode = prefs.getString(activeAppModeKey);
      if (mode != null && mode.isNotEmpty) return mode;

      // If no mode is explicitly set, check if provider onboarding or session exists
      if (data.authToken != null && data.authToken!.isNotEmpty) {
        return 'provider';
      }
      if (data.isOnboardingCompleted ||
          data.status == 'APPROVED' ||
          data.status == 'PENDING_VERIFICATION') {
        return 'provider';
      }
    } catch (e) {
      debugPrint('Error getting active app mode: $e');
    }
    return 'customer';
  }

  /// Sets active app mode ('provider' or 'customer')
  Future<void> setActiveAppMode(String mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(activeAppModeKey, mode);
    } catch (e) {
      debugPrint('Error setting active app mode: $e');
    }
  }

  /// Loads saved provider data & auth token from SharedPreferences
  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          data = ProviderRegistrationData.fromJson(decoded);
          if (data.authToken != null && data.authToken!.isNotEmpty) {
            ApiClient.setGlobalToken(data.authToken);
          }
        }
      }
      isLoaded = true;
    } catch (e) {
      debugPrint('Error loading provider registration data: $e');
    }
  }

  /// Persists provider data to local SharedPreferences
  Future<void> saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(data.toJson());
      await prefs.setString(_storageKey, raw);
    } catch (e) {
      debugPrint('Error saving provider registration data: $e');
    }
  }

  void update(ProviderRegistrationData Function(ProviderRegistrationData) updater) {
    try {
      data = updater(data);
    } catch (e) {
      debugPrint('Warning: ProviderRegistrationStore updater error, using fresh state: $e');
      data = updater(const ProviderRegistrationData());
    }

    if (data.authToken != null && data.authToken!.isNotEmpty) {
      ApiClient.setGlobalToken(data.authToken);
    }

    // Auto-mark provider mode if onboarding or provider status is set
    if (data.isOnboardingCompleted ||
        data.status == 'APPROVED' ||
        data.status == 'PENDING_VERIFICATION') {
      setActiveAppMode('provider');
    }

    saveToPrefs();
  }

  /// Clear session and onboarding data on logout or reset
  Future<void> clear() async {
    data = const ProviderRegistrationData();
    ApiClient.setGlobalToken(null);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      await prefs.setString(activeAppModeKey, 'customer');
    } catch (e) {
      debugPrint('Error clearing provider registration data: $e');
    }
  }
}

/// Reactive Riverpod Notifier for Provider Registration Data
class ProviderRegistrationNotifier extends Notifier<ProviderRegistrationData> {
  @override
  ProviderRegistrationData build() {
    return ProviderRegistrationStore.instance.data;
  }

  void setPhone(String phone, {bool isWhatsApp = false}) {
    state = state.copyWith(phone: phone, isWhatsApp: isWhatsApp, contactPhone: phone);
    ProviderRegistrationStore.instance.update((_) => state);
  }

  void updatePersonalInfo({
    required String fullName,
    required String iqamaNumber,
    required String iqamaExpiry,
  }) {
    state = state.copyWith(
      fullName: fullName,
      iqamaNumber: iqamaNumber,
      iqamaExpiry: iqamaExpiry,
    );
    ProviderRegistrationStore.instance.update((_) => state);
  }

  void updateContactInfo({
    required String phone,
    String? whatsappNumber,
  }) {
    state = state.copyWith(
      contactPhone: phone,
      whatsappNumber: whatsappNumber ?? '',
    );
    ProviderRegistrationStore.instance.update((_) => state);
  }

  void updateVehicleDetails({
    required String serviceCategory,
    required String vehicleType,
    required String plateNumber,
    required String vehicleModel,
    required String vehicleColor,
  }) {
    state = state.copyWith(
      serviceCategory: serviceCategory,
      vehicleType: vehicleType,
      plateNumber: plateNumber,
      vehicleModel: vehicleModel,
      vehicleColor: vehicleColor,
    );
    ProviderRegistrationStore.instance.update((_) => state);
  }

  void setDocumentUploaded(String docType, bool isUploaded) {
    if (docType == 'iqama') {
      state = state.copyWith(iqamaUploaded: isUploaded);
    } else if (docType == 'registration') {
      state = state.copyWith(registrationUploaded: isUploaded);
    } else if (docType == 'licence') {
      state = state.copyWith(licenceUploaded: isUploaded);
    }
    ProviderRegistrationStore.instance.update((_) => state);
  }

  void updateLocation(double lat, double lng) {
    state = state.copyWith(
      latitude: lat,
      longitude: lng,
      status: 'PENDING_VERIFICATION',
      isOnboardingCompleted: true,
    );
    ProviderRegistrationStore.instance.update((_) => state);
  }
}

final providerRegistrationProvider =
    NotifierProvider<ProviderRegistrationNotifier, ProviderRegistrationData>(
  ProviderRegistrationNotifier.new,
);
