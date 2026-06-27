class MapPlaceModel {
  final String name;
  final String specialty;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final bool isOpen;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? address;

  const MapPlaceModel({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.isOpen,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.address,
  });

  factory MapPlaceModel.fromJson(Map<String, dynamic> json) {
    return MapPlaceModel(
      name: json['name'] ?? '',
      specialty: json['specialty'] ?? json['type'] ?? '',
      rating: _toDouble(json['rating']),
      reviewCount: _toInt(json['reviewCount'] ?? json['review_count']),
      distanceKm: _toDouble(json['distance'] ?? json['distanceKm']),
      isOpen: json['isOpen'] ?? json['is_open'] ?? true,
      latitude: _toDouble(json['latitude'] ?? json['lat']),
      longitude: _toDouble(json['longitude'] ?? json['lng'] ?? json['lon']),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
    );
  }

  String get initials =>
      name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();

  String get distanceLabel => '${distanceKm.toStringAsFixed(1)} km away';

  String get reviewLabel => '($reviewCount reviews)';

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}
