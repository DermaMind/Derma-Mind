class SkinTestResultModel {
  final String skinType;
  final String? description;
  final List<String>? recommendations;

  const SkinTestResultModel({
    required this.skinType,
    this.description,
    this.recommendations,
  });

  factory SkinTestResultModel.fromJson(Map<String, dynamic> json) {
    final rawRecs = json['recommendations'] ?? json['tips'];
    final recs = rawRecs != null
        ? (rawRecs as List).map((e) => e.toString()).toList()
        : null;

    return SkinTestResultModel(
      skinType: json['skinTypeCode'] ??
          json['skinType'] ??
          json['skin_type'] ??
          json['type'] ??
          '',
      description: json['description'] ?? json['details'],
      recommendations: recs,
    );
  }
}
