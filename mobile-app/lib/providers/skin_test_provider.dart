import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/skin_test_question_model.dart';
import '../models/skin_test_result_model.dart';
import '../services/api_service.dart';
import '../utils/prefs_helper.dart';

class SkinTestProvider extends ChangeNotifier {
  String _skinType = 'Unknown';
  String _skinHistory = 'No history';
  String _lastScan = 'Never';
  List<SkinTypeScore> _typeScores = [];

  int _currentQuestion = 0;

  final Map<int, int> _answers = {};

  List<SkinTestQuestionModel> _apiQuestions = [];

  bool _questionsLoaded = false;
  String _lang = 'en';

  void setLang(String lang) {
    _lang = lang;
  }

  String get skinType => _skinType;

  String get skinHistory => _skinHistory;

  String get lastScan => _lastScan;

  List<SkinTypeScore> get typeScores => List.unmodifiable(_typeScores);

  List<SkinTypeScore> get displayTypeScores {
    if (_typeScores.isNotEmpty) return _typeScores;
    if (_skinType.isEmpty || _skinType.toLowerCase() == 'unknown') {
      return const [];
    }
    return [SkinTypeScore(label: _skinType, percent: 100)];
  }

  int get currentQuestion => _currentQuestion;

  int get totalQuestions => _apiQuestions.length;

  double get progress =>
      totalQuestions == 0 ? 0 : _answers.length / totalQuestions;

  bool get isCompleted =>
      totalQuestions > 0 && _answers.length == totalQuestions;

  bool get hasSkinResult => _isValidSkinType(_skinType);

  static bool _isValidSkinType(String value) {
    final trimmed = value.trim();
    return trimmed.isNotEmpty && trimmed.toLowerCase() != 'unknown';
  }

  List<SkinTestQuestionModel> get apiQuestions =>
      List.unmodifiable(_apiQuestions);

  bool get questionsLoaded => _questionsLoaded;

  static bool _containsArabic(String text) {
    return RegExp(r'[؀-ۿ]').hasMatch(text);
  }

  static bool _isValidSkinTypeString(String value) {
    return value.isNotEmpty &&
        !_containsArabic(value) &&
        value.toLowerCase() != 'unknown';
  }

  Future<void> loadQuestionsFromApi({String? lang, bool force = false}) async {
    if (_questionsLoaded && !force) return;
    final language = lang ?? _lang;
    try {
      final response = await ApiService.getSkinTestQuestions(lang: language);
      if (response.success &&
          response.data != null &&
          response.data!.isNotEmpty) {
        _apiQuestions = response.data!;
        _questionsLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> loadFromPrefs() async {
    final data = await PrefsHelper.loadSkinResult();

    if (data['skinType'] != null &&
        (data['skinType'] as String).isNotEmpty) {
      _skinType = data['skinType'] as String;
    }

    if (data['skinHistory'] != null &&
        (data['skinHistory'] as String).isNotEmpty) {
      _skinHistory = data['skinHistory'] as String;
    }

    if (data['lastScan'] != null &&
        (data['lastScan'] as String).isNotEmpty) {
      _lastScan = data['lastScan'] as String;
    }

    final savedScores = data['typeScores'];
    if (savedScores is List) {
      _typeScores = savedScores
          .whereType<Map>()
          .map((e) => SkinTypeScore.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    try {
      final savedLang = await PrefsHelper.loadLocale();
      final result = await ApiService.getSkinTestResult(lang: savedLang);

      if (result.success && result.data != null) {
        _applyResultModel(result.data!);
        if (hasSkinResult) {
          await _persistSkinResult();
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    notifyListeners();
  }

  void _applyResultModel(SkinTestResultModel model) {
    if (model.hasValidSkinType) {
      _skinType = model.skinType.trim();
    }

    if (model.description != null && model.description!.trim().isNotEmpty) {
      _skinHistory = model.description!.trim();
    }

    if (model.typeScores.isNotEmpty) {
      _typeScores = model.typeScores;
    }
  }

  Future<void> _persistSkinResult() async {
    await PrefsHelper.saveSkinResult(
      skinType: _skinType == 'Unknown' ? '' : _skinType,
      skinHistory: _skinHistory == 'No history' ? '' : _skinHistory,
      lastScan: _lastScan == 'Never' ? '' : _lastScan,
      typeScores: _typeScores.map((s) => s.toJson()).toList(),
    );
  }

  void answerQuestion(
      int questionIndex,
      int selectedOptionId,
      ) {
    _answers[questionIndex] = selectedOptionId;

    if (questionIndex < totalQuestions - 1) {
      _currentQuestion++;
    }

    notifyListeners();
  }

  void previousQuestion() {
    if (_currentQuestion > 0) {
      _currentQuestion--;

      notifyListeners();
    }
  }

  void resetTest() {
    _currentQuestion = 0;
    _answers.clear();
    _questionsLoaded = false;
    _apiQuestions = [];
    notifyListeners();
  }

  Future<void> clearResult() async {
    _skinType = 'Unknown';

    _skinHistory = 'No history';

    _lastScan = 'Never';

    _typeScores = [];

    _currentQuestion = 0;

    _answers.clear();

    await PrefsHelper.saveSkinResult(
      skinType: '',
      skinHistory: '',
      lastScan: '',
      typeScores: const [],
    );

    notifyListeners();
  }

  Future<void> recordScanCompleted() async {
    _lastScan = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    await _persistSkinResult();
    notifyListeners();
  }

  /// Returns `null` on success, or an error message when any step fails.
  Future<String?> completeSkinTest() async {
    if (!_questionsLoaded || _apiQuestions.isEmpty) {
      return 'Skin test questions are not loaded. Please try again.';
    }
    if (!isCompleted) {
      return 'Please answer all questions before finishing.';
    }

    try {
      final selectedOptionIds = _answers.values.toList();
      final submitResponse = await ApiService.submitSkinTest(
        selectedOptionIds: selectedOptionIds,
        lang: _lang,
      );
      if (!submitResponse.success) {
        return submitResponse.message ?? 'Failed to submit skin test.';
      }

      final resultResponse = await ApiService.getSkinTestResult(lang: _lang);
      if (!resultResponse.success) {
        return resultResponse.message ??
            'Failed to retrieve skin test result.';
      }
      if (resultResponse.data == null) {
        return 'Invalid skin test result received.';
      }

      final model = resultResponse.data!;
      if (!model.hasValidSkinType) {
        return 'Skin test result is missing a valid skin type.';
      }

      _applyResultModel(model);
      if (!hasSkinResult) {
        return 'Failed to apply skin test result.';
      }

      _lastScan = DateFormat('MMMM dd, yyyy').format(DateTime.now());

      try {
        await _persistSkinResult();
      } catch (e) {
        debugPrint(e.toString());
        return 'Failed to save skin test result locally.';
      }

      notifyListeners();
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return 'An unexpected error occurred. Please try again.';
    }
  }
}

