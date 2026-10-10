class HealthStatusModel {
  final bool isHealthy;
  final String status;
  final int phase;
  final String? message;
  final DateTime timestamp;

  HealthStatusModel({
    required this.isHealthy,
    required this.status,
    this.phase = 5,
    this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory HealthStatusModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;
    return HealthStatusModel(
      isHealthy: json['success'] == true || data['status'] == 'healthy',
      status: data['status'] as String? ?? 'unknown',
      phase: data['phase'] as int? ?? 5,
      message: data['message'] as String?,
    );
  }

  factory HealthStatusModel.offline(String error) {
    return HealthStatusModel(
      isHealthy: false,
      status: 'offline',
      phase: 0,
      message: error,
    );
  }
}
