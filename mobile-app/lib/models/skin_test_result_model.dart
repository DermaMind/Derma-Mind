class SkinTypeScore {
  final String label;
  final double percent;

  const SkinTypeScore({
    required this.label,
    required this.percent,
  });

  factory SkinTypeScore.fromJson(Map<String, dynamic> json) {
    return SkinTypeScore(
      label: (json['label'] ??
              json['type'] ??
              json['name'] ??
              json['skinType'] ??
              '')
          .toString(),
      percent: _toDouble(json['percent'] ?? json['percentage'] ?? json['value']),
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'percent': percent,
      };

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

class SkinTestResultModel {
  final String skinType;
  final String? description;
  final List<String>? recommendations;
  final List<SkinTypeScore> typeScores;

  const SkinTestResultModel({
    required this.skinType,
    this.description,
    this.recommendations,
    this.typeScores = const [],
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
      typeScores: _parseTypeScores(json),
    );
  }

  static List<SkinTypeScore> _parseTypeScores(Map<String, dynamic> json) {
    final raw = json['typeScores'] ??
        json['type_scores'] ??
        json['typePercentages'] ??
        json['type_percentages'] ??
        json['breakdown'] ??
        json['scores'] ??
        json['skinTypeBreakdown'] ??
        json['skin_type_breakdown'];

    if (raw == null) return [];

    if (raw is Map) {
      return raw.entries
          .map(
            (e) => SkinTypeScore(
              label: e.key.toString(),
              percent: SkinTypeScore._toDouble(e.value),
            ),
          )
          .where((s) => s.label.isNotEmpty && s.percent > 0)
          .toList()
        ..sort((a, b) => b.percent.compareTo(a.percent));
    }

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => SkinTypeScore.fromJson(Map<String, dynamic>.from(e)))
          .where((s) => s.label.isNotEmpty && s.percent > 0)
          .toList()
        ..sort((a, b) => b.percent.compareTo(a.percent));
    }

    return [];
  }
}
