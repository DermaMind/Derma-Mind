import 'package:flutter/foundation.dart';

import '../models/scan_history_model.dart';
import '../models/scan_result_model.dart';
import '../utils/prefs_helper.dart';

class ScanHistoryProvider extends ChangeNotifier {
  List<ScanHistoryItem> _items = [];
  bool _isLoading = false;
  bool _loadedFromDisk = false;

  List<ScanHistoryItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  Future<void> _ensureLoadedFromDisk() async {
    if (_loadedFromDisk) return;

    final raw = await PrefsHelper.loadScanHistory();
    _items = raw.map(ScanHistoryItem.fromJson).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _loadedFromDisk = true;
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _ensureLoadedFromDisk();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addScan(ScanResultModel result) async {
    if (!result.hasDiagnosis) return;

    await _ensureLoadedFromDisk();

    final now = DateTime.now();
    if (_items.isNotEmpty) {
      final latest = _items.first;
      final latestName = latest.result.disease.isNotEmpty
          ? latest.result.disease
          : latest.result.diseaseEn;
      final newName =
          result.disease.isNotEmpty ? result.disease : result.diseaseEn;
      final isDuplicate = latestName == newName &&
          now.difference(latest.createdAt).inSeconds < 10;
      if (isDuplicate) return;
    }

    final item = ScanHistoryItem(
      id: now.millisecondsSinceEpoch,
      createdAt: now,
      result: result,
    );

    _items.insert(0, item);
    await PrefsHelper.saveScanHistory(
      _items.map((e) => e.toJson()).toList(),
    );
    notifyListeners();
  }
}
