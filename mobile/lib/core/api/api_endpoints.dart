class ApiEndpoints {
  ApiEndpoints._();

  // Root health checks
  static const String root = '/';
  static const String health = '/health';
  static const String healthReady = '/health/ready';

  // API v1 prefix
  static const String v1Prefix = '/api/v1';

  // Public & Discovery endpoints
  static const String apiHealth = '$v1Prefix/health';
  static const String categories = '$v1Prefix/categories';
  static const String discoveryCategories = '$v1Prefix/discovery/categories';
  static const String discoveryNearby = '$v1Prefix/discovery/nearby';
  static const String discoverySearch = '$v1Prefix/discovery/search';
  static const String discoveryEvents = '$v1Prefix/discovery/events';

  // Auth endpoints
  static const String authOtpRequest = '$v1Prefix/auth/otp/request';
  static const String authOtpVerify = '$v1Prefix/auth/otp/verify';

  // Provider Verification & KYC endpoints
  static const String providerVerification = '$v1Prefix/providers/me/verification';
  static const String providerKycToken = '$v1Prefix/providers/me/kyc/token';

  // Provider Stats & Dashboard Analytics endpoints
  static const String providerStats = '$v1Prefix/providers/me/stats';
  static const String providerDashboard = '$v1Prefix/providers/me/dashboard';
}
