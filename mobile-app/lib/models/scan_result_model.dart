class ScanResultModel {
  final String disease;
  final double confidence;
  final String severity;
  final String description;
  final List<String> recommendations;
  final String? imageUrl;
  final String? disclaimer;
  final String? mode;

  const ScanResultModel({
    required this.disease,
    required this.confidence,
    required this.severity,
    required this.description,
    required this.recommendations,
    this.imageUrl,
    this.disclaimer,
    this.mode,
  });

  factory ScanResultModel.fromJson(dynamic rawJson) {
    try {
      final json = rawJson is Map<String, dynamic>
          ? rawJson
          : <String, dynamic>{};

      final disclaimer = json['disclaimer']?.toString();
      final mode = json['mode']?.toString();

      final top3Raw = json['top3'];
      final top3 = top3Raw is List ? top3Raw : <dynamic>[];

      if (top3.isNotEmpty) {
        final firstRaw = top3.first;
        final first = firstRaw is Map<String, dynamic>
            ? firstRaw
            : <String, dynamic>{};

        List<String> recommendations = [];
        final rawRec = first['care_recommendations'];

        if (rawRec is List) {
          recommendations = rawRec
              .map((e) => e?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList();
        } else if (rawRec is String && rawRec.isNotEmpty) {
          recommendations = rawRec
              .split('.')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }

        final nameAr = first['name_ar']?.toString() ?? '';
        final nameEn = first['disease']?.toString() ?? '';
        final disease = nameAr.isNotEmpty ? nameAr : nameEn;

        return ScanResultModel(
          disease: disease,
          confidence: _toDouble(first['confidence']),
          severity: first['likelihood']?.toString() ?? '',
          description: first['personalized_insight']?.toString() ?? '',
          recommendations: recommendations,
          imageUrl: first['imageUrl']?.toString() ??
              first['image_url']?.toString(),
          disclaimer: disclaimer,
          mode: mode,
        );
      }

      return ScanResultModel(
        disease: '',
        confidence: 0,
        severity: '',
        description: '',
        recommendations: const [],
        disclaimer: disclaimer,
        mode: mode,
      );
    } catch (e) {
      return ScanResultModel.dummy();
    }
  }

  factory ScanResultModel.dummy() {
    return const ScanResultModel(
      disease: '',
      confidence: 0,
      severity: '',
      description: '',
      recommendations: [],
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}