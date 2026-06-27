class ScanAnalyzeModel {
  final ModelResult modelResult;
  final List<ScanQuestion> questions;

  const ScanAnalyzeModel({
    required this.modelResult,
    required this.questions,
  });

  List<ScanPrediction> get predictions => modelResult.top3;

  factory ScanAnalyzeModel.fromJson(Map<String, dynamic> json) {
    final source = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final modelResultRaw = source['model_result'] is Map<String, dynamic>
        ? source['model_result'] as Map<String, dynamic>
        : source;

    final questionsList = source['questions'] is List
        ? source['questions'] as List
        : modelResultRaw['questions'] is List
            ? modelResultRaw['questions'] as List
            : <dynamic>[];

    return ScanAnalyzeModel(
      modelResult: ModelResult.fromJson(modelResultRaw),
      questions: questionsList
          .whereType<Map<String, dynamic>>()
          .map((e) => ScanQuestion.fromJson(e))
          .toList(),
    );
  }
}

class ModelResult {
  final List<ScanPrediction> top3;
  final Map<String, double> rawScores;

  const ModelResult({
    required this.top3,
    required this.rawScores,
  });

  factory ModelResult.fromJson(Map<String, dynamic> json) {
    final top3List =
        json['top3'] is List ? json['top3'] as List : <dynamic>[];

    final rawScoresRaw = json['raw_scores'];
    final rawScores = <String, double>{};
    if (rawScoresRaw is Map) {
      rawScoresRaw.forEach((key, value) {
        final parsed = value is num
            ? value.toDouble()
            : double.tryParse(value?.toString() ?? '') ?? 0.0;
        rawScores[key.toString()] = parsed;
      });
    }

    return ModelResult(
      top3: top3List
          .whereType<Map<String, dynamic>>()
          .map((e) => ScanPrediction.fromJson(e))
          .toList(),
      rawScores: rawScores,
    );
  }

  Map<String, dynamic> toJson() => {
        'top3': top3.map((e) => e.toJson()).toList(),
        'raw_scores': rawScores,
      };
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

  Map<String, dynamic> toJson() => {
        'disease': disease,
        'name_ar': diseaseAr,
        'confidence': confidence,
      };
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
