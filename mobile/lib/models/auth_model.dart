/// Authentication Models for Provider OTP Request and Verification
class OtpRequestResult {
  final bool success;
  final String phone;
  final String otp;
  final String message;
  final bool isDummy;
  final int expiresInMinutes;
  final bool smsDelivered;
  final String channel;
  final String? messageSid;
  final bool alreadyExists;

  const OtpRequestResult({
    required this.success,
    required this.phone,
    required this.otp,
    required this.message,
    this.isDummy = false,
    this.expiresInMinutes = 10,
    this.smsDelivered = false,
    this.channel = 'sms',
    this.messageSid,
    this.alreadyExists = false,
  });

  factory OtpRequestResult.fromJson(Map<String, dynamic> json, {required String fallbackPhone, String? fallbackOtp}) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    final otpVal = data['otp']?.toString() ?? fallbackOtp ?? '';
    final phoneVal = data['phone']?.toString() ?? fallbackPhone;
    final messageVal = data['message']?.toString() ?? 'OTP sent to phone number';
    final expiresVal = int.tryParse(data['expiresInMinutes']?.toString() ?? '') ?? 10;
    final smsDeliveredVal = data['smsDelivered'] == true;
    final channelVal = data['channel']?.toString() ?? 'sms';
    final sidVal = data['messageSid']?.toString();

    return OtpRequestResult(
      success: true,
      phone: phoneVal,
      otp: otpVal,
      message: messageVal,
      isDummy: data['otp'] == null && !smsDeliveredVal,
      expiresInMinutes: expiresVal,
      smsDelivered: smsDeliveredVal,
      channel: channelVal,
      messageSid: sidVal,
    );
  }

  factory OtpRequestResult.dummy({required String phone, String otp = '123456', String? message}) {
    return OtpRequestResult(
      success: true,
      phone: phone,
      otp: otp,
      message: message ?? 'Dummy OTP generated for testing',
      isDummy: true,
      expiresInMinutes: 10,
      smsDelivered: false,
      channel: 'sms',
    );
  }
}

class OtpVerifyResult {
  final bool success;
  final String? token;
  final Map<String, dynamic>? provider;
  final String? errorMessage;
  final bool isDummy;

  const OtpVerifyResult({
    required this.success,
    this.token,
    this.provider,
    this.errorMessage,
    this.isDummy = false,
  });

  factory OtpVerifyResult.success({
    required String token,
    Map<String, dynamic>? provider,
    bool isDummy = false,
  }) {
    return OtpVerifyResult(
      success: true,
      token: token,
      provider: provider,
      isDummy: isDummy,
    );
  }

  factory OtpVerifyResult.failure(String message) {
    return OtpVerifyResult(
      success: false,
      errorMessage: message,
    );
  }
}
