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

  bool get hasValidSkinType {
    final type = skinType.trim();
    return type.isNotEmpty && type.toLowerCase() != 'unknown';
  }

  factory SkinTestResultModel.fromJson(dynamic rawJson) {
    final json = rawJson is Map<String, dynamic>
        ? rawJson
        : rawJson is Map
            ? Map<String, dynamic>.from(rawJson)
            : <String, dynamic>{};

    var source = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json['data'] is Map
            ? Map<String, dynamic>.from(json['data'] as Map)
            : json;

    if (source['result'] is Map) {
      source = Map<String, dynamic>.from(source['result'] as Map);
    }

    final rawRecs = source['recommendations'] ?? source['tips'];
    final recs = rawRecs != null
        ? (rawRecs as List).map((e) => e.toString()).toList()
        : null;

    return SkinTestResultModel(
      skinType: source['skinTypeCode'] ??
          source['skinType'] ??
          source['skin_type'] ??
          source['skinTypeName'] ??
          source['type'] ??
          '',
      description: source['description'] ??
          source['details'] ??
          source['skinHistory'] ??
          source['mainConcern'],
      recommendations: recs,
      typeScores: _parseTypeScores(source),
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
