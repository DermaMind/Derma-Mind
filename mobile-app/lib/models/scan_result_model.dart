class ScanResultModel {
  final String disease;
  final String diseaseEn;
  final String diseaseAr;
  final double confidence;
  final String severity;
  final String description;
  final List<String> recommendations;
  final String? imageUrl;
  final String? disclaimer;
  final String? mode;

  const ScanResultModel({
    required this.disease,
    this.diseaseEn = '',
    this.diseaseAr = '',
    required this.confidence,
    required this.severity,
    required this.description,
    required this.recommendations,
    this.imageUrl,
    this.disclaimer,
    this.mode,
  });

  /// Context string for the chatbot API, e.g.
  /// "Acne - حب الشباب - confidence: 87%"
  String get diagnosisContext {
    final en = diseaseEn.isNotEmpty ? diseaseEn : disease;
    final ar = diseaseAr.isNotEmpty ? diseaseAr : '';

    String confidencePart;
    if (!isConfidenceLevel && confidence > 0) {
      final pct = confidence <= 1.0 ? confidence * 100 : confidence;
      confidencePart = '${pct.toStringAsFixed(0)}%';
    } else if (severity.isNotEmpty) {
      confidencePart = severity;
    } else {
      return '';
    }

    if (ar.isNotEmpty && en.isNotEmpty && ar != en) {
      return '$en - $ar - confidence: $confidencePart';
    }
    if (en.isNotEmpty) {
      return '$en - confidence: $confidencePart';
    }
    return '';
  }

  bool get isConfidenceLevel =>
      severity == 'عالية' ||
      severity == 'متوسطة' ||
      severity == 'منخفضة' ||
      severity.toLowerCase() == 'high' ||
      severity.toLowerCase() == 'moderate' ||
      severity.toLowerCase() == 'medium' ||
      severity.toLowerCase() == 'low';

  factory ScanResultModel.fromJson(dynamic rawJson) {
    try {
      final json = rawJson is Map<String, dynamic>
          ? rawJson
          : rawJson is Map
              ? Map<String, dynamic>.from(rawJson)
              : <String, dynamic>{};

      final source = json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : json;

      if (source.containsKey('confidence_level') ||
          source.containsKey('name_localized')) {
        return ScanResultModel.fromDiagnoseComplete(source);
      }

      final disclaimer = source['disclaimer']?.toString();
      final mode = source['mode']?.toString();

      final top3Raw = source['top3'];
      final top3 = top3Raw is List ? top3Raw : <dynamic>[];

      if (top3.isNotEmpty) {
        final firstRaw = top3.first;
        final first = firstRaw is Map<String, dynamic>
            ? firstRaw
            : <String, dynamic>{};

        final nameAr = first['name_ar']?.toString() ?? '';
        final nameEn = first['disease']?.toString() ?? '';
        final disease = nameAr.isNotEmpty ? nameAr : nameEn;

        return ScanResultModel(
          disease: disease,
          diseaseEn: nameEn,
          diseaseAr: nameAr,
          confidence: _toDouble(first['confidence']),
          severity: first['likelihood']?.toString() ?? '',
          description: first['personalized_insight']?.toString() ?? '',
          recommendations: _parseRecommendations(first['care_recommendations']),
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

  factory ScanResultModel.fromDiagnoseComplete(Map<String, dynamic> json) {
    final nameLocalized = json['name_localized']?.toString() ?? '';
    final diseaseEn = json['disease']?.toString() ?? '';
    final diseaseAr = json['name_ar']?.toString() ?? '';

    return ScanResultModel(
      disease: nameLocalized.isNotEmpty ? nameLocalized : diseaseEn,
      diseaseEn: diseaseEn,
      diseaseAr: diseaseAr,
      confidence: 0,
      severity: json['confidence_level']?.toString() ?? '',
      description: json['personalized_insight']?.toString() ?? '',
      recommendations: _parseRecommendations(json['care_recommendations']),
      disclaimer: json['disclaimer']?.toString(),
    );
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

  Map<String, dynamic> toJson() => {
        'disease': disease,
        'diseaseEn': diseaseEn,
        'diseaseAr': diseaseAr,
        'confidence': confidence,
        'severity': severity,
        'description': description,
        'recommendations': recommendations,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (disclaimer != null) 'disclaimer': disclaimer,
        if (mode != null) 'mode': mode,
      };

  factory ScanResultModel.fromStoredJson(Map<String, dynamic> json) {
    return ScanResultModel(
      disease: json['disease']?.toString() ?? '',
      diseaseEn: json['diseaseEn']?.toString() ?? '',
      diseaseAr: json['diseaseAr']?.toString() ?? '',
      confidence: _toDouble(json['confidence']),
      severity: json['severity']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      recommendations: _parseRecommendations(json['recommendations']),
      imageUrl: json['imageUrl']?.toString(),
      disclaimer: json['disclaimer']?.toString(),
      mode: json['mode']?.toString(),
    );
  }

  bool get hasDiagnosis =>
      disease.isNotEmpty || diseaseEn.isNotEmpty || diseaseAr.isNotEmpty;

  static List<String> _parseRecommendations(dynamic rawRec) {
    if (rawRec is List) {
      return rawRec
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (rawRec is String && rawRec.isNotEmpty) {
      final lines = rawRec
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (lines.length > 1) return lines;

      return rawRec
          .split(RegExp(r'(?<=\.)\s+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
