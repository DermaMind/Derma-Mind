import 'scan_result_model.dart';

class ScanHistoryItem {
  final int id;
  final DateTime createdAt;
  final ScanResultModel result;

  const ScanHistoryItem({
    required this.id,
    required this.createdAt,
    required this.result,
  });

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      createdAt: DateTime.tryParse(
              json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      result: json['result'] != null
          ? ScanResultModel.fromJson(json['result'])
          : ScanResultModel.fromJson(json),
    );
  }

  // Display date formatted
  String get formattedDate {
    final d = createdAt;
    return '${d.day}/${d.month}/${d.year}';
  }

  // Top disease name
  String get diseaseName => result.disease;

  // Confidence
  String get confidenceLabel =>
      '${result.confidence.toStringAsFixed(0)}%';
}