import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Customer Auth Data Model
class CustomerAuthData {
  final String fullName;
  final String phone;
  final String countryCode;
  final bool isSignedUp;
  final String? photoPath;

  const CustomerAuthData({
    this.fullName = '',
    this.phone = '',
    this.countryCode = '+966',
    this.isSignedUp = false,
    this.photoPath,
  });

  CustomerAuthData copyWith({
    String? fullName,
    String? phone,
    String? countryCode,
    bool? isSignedUp,
    String? photoPath,
  }) {
    return CustomerAuthData(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      isSignedUp: isSignedUp ?? this.isSignedUp,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phone': phone,
        'countryCode': countryCode,
        'isSignedUp': isSignedUp,
        'photoPath': photoPath,
      };

  factory CustomerAuthData.fromJson(Map<String, dynamic> json) =>
      CustomerAuthData(
        fullName: json['fullName'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        countryCode: json['countryCode'] as String? ?? '+966',
        isSignedUp: json['isSignedUp'] as bool? ?? false,
        photoPath: json['photoPath'] as String?,
      );
}

/// Global Singleton store for Customer Auth & Profile
class CustomerAuthStore {
  CustomerAuthStore._();
  static final CustomerAuthStore instance = CustomerAuthStore._();

  static const String _storageKey = 'qareeb_customer_profile_v1';
  static const String _isSignedUpKey = 'customer_is_signed_up';
  static const String _nameKey = 'customer_profile_name';
  static const String _phoneKey = 'customer_profile_phone';

  CustomerAuthData data = const CustomerAuthData();
  bool isLoaded = false;
  VoidCallback? onDataChanged;

  String get fullName => data.fullName;
  String get phone => data.phone;
  bool get hasCompletedSignup => data.isSignedUp;

  Future<bool> isSignedUp() async {
    if (!isLoaded) {
      await loadFromPrefs();
    }
    return data.isSignedUp;
  }

  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          data = CustomerAuthData.fromJson(decoded);
        }
      } else {
        // Fallback to legacy individual keys if present
        final legacyName = prefs.getString(_nameKey) ?? '';
        final legacyPhone = prefs.getString(_phoneKey) ?? '';
        final legacySignedUp = prefs.getBool(_isSignedUpKey) ??
            (legacyName.trim().isNotEmpty && legacyPhone.trim().isNotEmpty);
        data = CustomerAuthData(
          fullName: legacyName,
          phone: legacyPhone,
          isSignedUp: legacySignedUp,
        );
      }
      isLoaded = true;
    } catch (e) {
      debugPrint('Error loading customer auth data: $e');
    }
  }

  Future<void> saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(data.toJson()));
      await prefs.setBool(_isSignedUpKey, data.isSignedUp);
      await prefs.setString(_nameKey, data.fullName);
      await prefs.setString(_phoneKey, data.phone);
    } catch (e) {
      debugPrint('Error saving customer auth data: $e');
    }
  }

  Future<void> signUp({
    required String fullName,
    required String phone,
    String countryCode = '+966',
  }) async {
    data = data.copyWith(
      fullName: fullName.trim(),
      phone: phone.trim(),
      countryCode: countryCode,
      isSignedUp: true,
    );
    await saveToPrefs();
    onDataChanged?.call();
  }

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? countryCode,
    String? photoPath,
  }) async {
    data = data.copyWith(
      fullName: fullName?.trim(),
      phone: phone?.trim(),
      countryCode: countryCode,
      photoPath: photoPath,
    );
    await saveToPrefs();
    onDataChanged?.call();
  }

  Future<void> clear() async {
    data = const CustomerAuthData();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      await prefs.remove(_isSignedUpKey);
      await prefs.remove(_nameKey);
      await prefs.remove(_phoneKey);
    } catch (_) {}
    onDataChanged?.call();
  }
}

/// Reactive Riverpod Notifier for Customer Auth Data
class CustomerAuthNotifier extends Notifier<CustomerAuthData> {
  @override
  CustomerAuthData build() {
    CustomerAuthStore.instance.onDataChanged = () {
      state = CustomerAuthStore.instance.data;
    };
    ref.onDispose(() {
      CustomerAuthStore.instance.onDataChanged = null;
    });
    return CustomerAuthStore.instance.data;
  }

  void syncWithStore() {
    state = CustomerAuthStore.instance.data;
  }
}

final customerAuthProvider =
    NotifierProvider<CustomerAuthNotifier, CustomerAuthData>(
  CustomerAuthNotifier.new,
);

