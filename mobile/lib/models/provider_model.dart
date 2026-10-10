/// Model representing a service provider displayed on the radar map
class ProviderMarkerModel {
  final int id;
  final String publicId;
  final String name;
  final String? photoUrl;
  final double distanceKm;
  final double ratingAvg;
  final int ratingCount;
  final bool isOnline;
  final String verificationStatus;
  final double latitude;
  final double longitude;

  // Screen layout coordinates inside the 320x320 map circle  final double screenTop;
  final double screenLeft;
  final double carAngle; // degrees

  const ProviderMarkerModel({
    required this.id,
    required this.publicId,
    required this.name,
    this.photoUrl,
    required this.distanceKm,
    this.ratingAvg = 4.9,
    this.ratingCount = 120,
    this.isOnline = true,
    this.verificationStatus = 'verified',
    required this.latitude,
    required this.longitude,
    required this.screenTop,
    required this.screenLeft,
    required this.carAngle,
  });

  factory ProviderMarkerModel.fromJson(
    Map<String, dynamic> json, {
    double fallbackTop = 174.0,
    double fallbackLeft = 82.0,
    double fallbackAngle = 60.0,
  }) {
    final distanceM = (json['distanceMeters'] as num?)?.toDouble() ?? 500.0;
    final distKm = (json['distanceKm'] as num?)?.toDouble() ?? (distanceM / 1000.0);
    final ratingMap = json['rating'] as Map<String, dynamic>?;

    return ProviderMarkerModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      publicId: json['publicId']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Provider',
      photoUrl: json['photoUrl']?.toString(),
      distanceKm: double.parse(distKm.toStringAsFixed(1)),
      ratingAvg: (ratingMap?['average'] as num?)?.toDouble() ?? 4.9,
      ratingCount: (ratingMap?['count'] as num?)?.toInt() ?? 120,
      isOnline: json['isOnline'] == true,
      verificationStatus: json['verificationStatus']?.toString() ?? 'verified',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 24.7681,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 46.7153,
      screenTop: (json['screenTop'] as num?)?.toDouble() ?? fallbackTop,
      screenLeft: (json['screenLeft'] as num?)?.toDouble() ?? fallbackLeft,
      carAngle: (json['carAngle'] as num?)?.toDouble() ?? fallbackAngle,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'publicId': publicId,
      'name': name,
      'photoUrl': photoUrl,
      'distanceKm': distanceKm,
      'ratingAvg': ratingAvg,
      'ratingCount': ratingCount,
      'isOnline': isOnline,
      'verificationStatus': verificationStatus,
      'latitude': latitude,
      'longitude': longitude,
      'screenTop': screenTop,
      'screenLeft': screenLeft,
      'carAngle': carAngle,
    };
  }
}
