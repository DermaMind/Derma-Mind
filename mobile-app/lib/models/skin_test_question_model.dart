class SkinTestOptionModel {
  final int id;
  final String optionText;
  final String? skinTypePoint;

  const SkinTestOptionModel({
    required this.id,
    required this.optionText,
    this.skinTypePoint,
  });

  factory SkinTestOptionModel.fromJson(Map<String, dynamic> json) {
    return SkinTestOptionModel(
      id: _toInt(json['id']),
      optionText: json['optionText'] ?? json['text'] ?? json['option'] ?? '',
      skinTypePoint: json['skinTypePoint'] ?? json['skin_type_point'],
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}

class SkinTestQuestionModel {
  final int id;
  final String questionText;
  final List<SkinTestOptionModel> options;

  const SkinTestQuestionModel({
    required this.id,
    required this.questionText,
    required this.options,
  });

  factory SkinTestQuestionModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] ?? json['choices'] ?? [];
    final options = (rawOptions as List)
        .map((o) => SkinTestOptionModel.fromJson(o as Map<String, dynamic>))
        .toList();

    return SkinTestQuestionModel(
      id: _toInt(json['id']),
      questionText:
          json['questionText'] ?? json['text'] ?? json['question'] ?? '',
      options: options,
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}
