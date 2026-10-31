import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider Registration Data Model
/// Holds the real user input data across all onboarding steps:
/// 1. Phone / WhatsApp Auth
/// 2. Personal & Contact Information (Profile Details)
/// 3. Vehicle & Service Details
/// 4. Upload Documents
/// 5. Location Permission
/// 6. Admin Approval
class ProviderRegistrationData {
  final String phone;
  final bool isWhatsApp;
  final String fullName;
  final String iqamaNumber;
  final String iqamaExpiry;
  final String contactPhone;
  final String whatsappNumber;
  final String serviceCategory;
  final String vehicleType;
  final String plateNumber;
  final String vehicleModel;
  final String vehicleColor;
  final bool iqamaUploaded;
  final bool registrationUploaded;
  final bool licenceUploaded;
  final List<String> vehiclePhotos;
  final double? latitude;
  final double? longitude;
  final String status;
  final String publicId;

  const ProviderRegistrationData({
    this.phone = '+966 50 123 4567',
    this.isWhatsApp = false,
    this.fullName = '',
    this.iqamaNumber = '',
    this.iqamaExpiry = '',
    this.contactPhone = '',
    this.whatsappNumber = '',
    this.serviceCategory = 'Vehicle Towing',
    this.vehicleType = 'Flatbed Truck',
    this.plateNumber = '',
    this.vehicleModel = '',
    this.vehicleColor = 'White',
    this.iqamaUploaded = false,
    this.registrationUploaded = false,
    this.licenceUploaded = false,
    this.vehiclePhotos = const [],
    this.latitude,
    this.longitude,
    this.status = 'PENDING_PROFILE',
    this.publicId = 'QRB-1082',
  });

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
    List<String>? vehiclePhotos,
    double? latitude,
    double? longitude,
    String? status,
    String? publicId,
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
      vehiclePhotos: vehiclePhotos ?? this.vehiclePhotos,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      publicId: publicId ?? this.publicId,
    );
  }
}

/// Global Singleton store allowing seamless data sharing across all provider steps
class ProviderRegistrationStore {
  ProviderRegistrationStore._();
  static final ProviderRegistrationStore instance = ProviderRegistrationStore._();

  ProviderRegistrationData data = const ProviderRegistrationData();

  void update(ProviderRegistrationData Function(ProviderRegistrationData) updater) {
    data = updater(data);
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
    ProviderRegistrationStore.instance.data = state;
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
    ProviderRegistrationStore.instance.data = state;
  }

  void updateContactInfo({
    required String phone,
    String? whatsappNumber,
  }) {
    state = state.copyWith(
      contactPhone: phone,
      whatsappNumber: whatsappNumber ?? '',
    );
    ProviderRegistrationStore.instance.data = state;
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
    ProviderRegistrationStore.instance.data = state;
  }

  void setDocumentUploaded(String docType, bool isUploaded) {
    if (docType == 'iqama') {
      state = state.copyWith(iqamaUploaded: isUploaded);
    } else if (docType == 'registration') {
      state = state.copyWith(registrationUploaded: isUploaded);
    } else if (docType == 'licence') {
      state = state.copyWith(licenceUploaded: isUploaded);
    }
    ProviderRegistrationStore.instance.data = state;
  }

  void updateLocation(double lat, double lng) {
    state = state.copyWith(latitude: lat, longitude: lng, status: 'PENDING_VERIFICATION');
    ProviderRegistrationStore.instance.data = state;
  }
}

final providerRegistrationProvider =
    NotifierProvider<ProviderRegistrationNotifier, ProviderRegistrationData>(
  ProviderRegistrationNotifier.new,
);
