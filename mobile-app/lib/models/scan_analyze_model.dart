class ScanAnalyzeModel {
  final List<ScanPrediction> predictions;
  final List<ScanQuestion> questions;

  const ScanAnalyzeModel({
    required this.predictions,
    required this.questions,
  });

  factory ScanAnalyzeModel.fromJson(Map<String, dynamic> json) {
    final source = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final modelResult = source['model_result'] is Map<String, dynamic>
        ? source['model_result'] as Map<String, dynamic>
        : source;

    final top3List = modelResult['top3'] is List
        ? modelResult['top3'] as List
        : <dynamic>[];

    final questionsList = modelResult['questions'] is List
        ? modelResult['questions'] as List
        : source['questions'] is List
            ? source['questions'] as List
            : <dynamic>[];

    return ScanAnalyzeModel(
      predictions: top3List
          .whereType<Map<String, dynamic>>()
          .map((e) => ScanPrediction.fromJson(e))
          .toList(),
      questions: questionsList
          .whereType<Map<String, dynamic>>()
          .map((e) => ScanQuestion.fromJson(e))
          .toList(),
    );
  }
}

class ScanPrediction {
  final String disease;
  final String diseaseAr;
  final double confidence;

  const ScanPrediction({
    required this.disease,
    required this.diseaseAr,
    required this.confidence,
  });

  factory ScanPrediction.fromJson(Map<String, dynamic> json) {
    final rawConfidence = json['confidence'];
    final confidence = rawConfidence is num
        ? rawConfidence.toDouble()
        : double.tryParse(rawConfidence?.toString() ?? '') ?? 0.0;

    return ScanPrediction(
      disease: json['disease']?.toString() ?? '',
      diseaseAr: json['name_ar']?.toString() ?? '',
      confidence: confidence,
    );
  }
}

class ScanQuestion {
  final int id;
  final String question;
  final List<String> options;

  const ScanQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  factory ScanQuestion.fromJson(Map<String, dynamic> json) {
    final options = json['options'] is List
        ? (json['options'] as List)
            .map((e) => e?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList()
        : <String>[];

    return ScanQuestion(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      question: json['question']?.toString() ?? '',
      options: options,
    );
  }
}