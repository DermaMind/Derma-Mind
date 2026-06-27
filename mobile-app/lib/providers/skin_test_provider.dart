import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/skin_test_question_model.dart';
import '../services/api_service.dart';
import '../utils/prefs_helper.dart';

class SkinTestProvider extends ChangeNotifier {
  String _skinType = 'Unknown';
  String _skinHistory = 'No history';
  String _lastScan = 'Never';

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

  int get currentQuestion => _currentQuestion;

  int get totalQuestions => _apiQuestions.length;

  double get progress =>
      totalQuestions == 0 ? 0 : _answers.length / totalQuestions;

  bool get isCompleted =>
      totalQuestions > 0 && _answers.length == totalQuestions;

  bool get hasSkinResult => _skinType != 'Unknown';

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

  Future<void> loadQuestionsFromApi({String? lang}) async {
    if (_questionsLoaded) return;
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
        data['skinType']!.isNotEmpty) {
      _skinType = data['skinType']!;
    }

    if (data['skinHistory'] != null &&
        data['skinHistory']!.isNotEmpty) {
      _skinHistory = data['skinHistory']!;
    }

    if (data['lastScan'] != null &&
        data['lastScan']!.isNotEmpty) {
      _lastScan = data['lastScan']!;
    }

    try {
      final result =
      await ApiService.getSkinTestResult(lang: 'en');

      if (result.success && result.data != null) {
        if (_isValidSkinTypeString(result.data!.skinType)) {
          _skinType = result.data!.skinType;
        }

        if (result.data!.description != null &&
            result.data!.description!.isNotEmpty) {
          _skinHistory = result.data!.description!;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    notifyListeners();
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

    notifyListeners();
  }

  Future<void> clearResult() async {
    _skinType = 'Unknown';

    _skinHistory = 'No history';

    _lastScan = 'Never';

    _currentQuestion = 0;

    _answers.clear();

    await PrefsHelper.saveSkinResult(
      skinType: '',
      skinHistory: '',
      lastScan: '',
    );

    notifyListeners();
  }

  Future<void> completeSkinTest() async {
    _lastScan = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    if (!_questionsLoaded || _apiQuestions.isEmpty) {
      debugPrint("Questions are not loaded.");
      return;
    }
    try {
      final selectedOptionIds = _answers.values.toList();
      final response = await ApiService.submitSkinTest(
        selectedOptionIds: selectedOptionIds,
        lang: _lang,
      );
      if (!response.success) {
        debugPrint("Submit Skin Test Failed");
        return;
      }
      final result = await ApiService.getSkinTestResult(lang: _lang);
      if (result.success && result.data != null) {
        _skinType = result.data!.skinType;
        _skinHistory = result.data!.description ?? '';
        await PrefsHelper.saveSkinResult(
          skinType: _skinType,
          skinHistory: _skinHistory,
          lastScan: _lastScan,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

