import 'package:dermamind_app/Scan_Screen/scan_result_screen.dart';
import 'package:dermamind_app/models/diagnose_answer_model.dart';
import 'package:dermamind_app/models/scan_analyze_model.dart';
import 'package:dermamind_app/providers/skin_test_provider.dart';
import 'package:dermamind_app/services/api_service.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ScanFollowupScreen — interactive diagnosis questions from /diagnose/start
// ─────────────────────────────────────────────────────────────────────────────

class ScanFollowupScreen extends StatefulWidget {
  static const String routeName = 'scanFollowup';

  const ScanFollowupScreen({super.key});

  @override
  State<ScanFollowupScreen> createState() => _ScanFollowupScreenState();
}

class _ScanFollowupScreenState extends State<ScanFollowupScreen> {
  late ScanAnalyzeModel analyzeResult;
  int _currentQuestion = 0;
  int? _selectedOption;
  bool _isAnalyzing = false;
  bool _initialized = false;
  String _loadingMessage = 'Analyzing your skin...';
  String _lang = 'ar';
  String? _errorMessage;
  final Map<int, String> _answers = {};

  // ── Dummy detected condition ───────────────────────────────────────────────
  String get _detectedCondition {
    if (analyzeResult.predictions.isEmpty) {
      return "Unknown";
    }

    final first = analyzeResult.predictions.first;

    return first.diseaseAr.isNotEmpty
        ? first.diseaseAr
        : first.disease;
  }

  double get _confidence {
    if (analyzeResult.predictions.isEmpty) {
      return 0;
    }

    return analyzeResult.predictions.first.confidence / 100;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      analyzeResult = args['analyze'] as ScanAnalyzeModel;
      _lang = args['lang'] as String? ?? 'ar';
      _initialized = true;

      _selectedOption = null;
      if (analyzeResult.questions.isNotEmpty &&
          _answers[_currentQuestion] != null) {
        _selectedOption = analyzeResult.questions[_currentQuestion]
            .options
            .indexOf(_answers[_currentQuestion]!);
      }

      if (analyzeResult.questions.isEmpty) {
        _errorMessage =
            'No follow-up questions were returned by the analysis.';
      }
    }
  }

  // ── Questions data ─────────────────────────────────────────────────────────
  List<ScanQuestion> get _questions => analyzeResult.questions;
  void _nextQuestion() {
    if (_selectedOption == null) return;
    _saveCurrentAnswer();
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedOption = _answers[_currentQuestion] != null
            ? analyzeResult.questions[_currentQuestion]
                .options
                .indexOf(_answers[_currentQuestion]!)
            : null;
      });
    } else {
      _submitDiagnosis();
    }
  }

  void _saveCurrentAnswer() {
    if (_selectedOption == null) return;
    final currentQuestion = _questions[_currentQuestion];
    _answers[_currentQuestion] = currentQuestion.options[_selectedOption!];
  }

  List<DiagnoseAnswer> _buildAnswersPayload() {
    return List.generate(_questions.length, (index) {
      final question = _questions[index];
      return DiagnoseAnswer(
        questionId: question.id,
        question: question.question,
        answer: _answers[index] ?? '',
      );
    });
  }

  Future<void> _submitDiagnosis() async {
    if (_isAnalyzing) return;
    _saveCurrentAnswer();
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _loadingMessage = 'Getting your results...';
    });

    try {
      final skinType = context.read<SkinTestProvider>().skinType;
      final response = await ApiService.diagnoseComplete(
        modelResult: analyzeResult.modelResult.toJson(),
        answers: _buildAnswersPayload().map((a) => a.toJson()).toList(),
        skinType: skinType.isNotEmpty && skinType != 'Unknown'
            ? skinType
            : 'Unknown',
        lang: _lang,
      );

      if (!mounted) return;

      if (!response.success || response.data == null) {
        setState(() {
          _errorMessage =
              response.message ?? 'Analysis failed. Please try again.';
        });
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        ScanResultScreen.routeName,
        arguments: response.data,
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Unable to complete the scan. Please check your connection and try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _loadingMessage = 'Analyzing your skin...';
        });
      }
    }
  }

  void _setSelectedOption(int optionIndex) {
    setState(() {
      _selectedOption = optionIndex;
      _answers[_currentQuestion] = _questions[_currentQuestion].options[optionIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildMainScaffold(),
        if (_isAnalyzing)
          Container(
            color: Colors.black45,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    _loadingMessage,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMainScaffold() {
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColor.primaryColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppStyle.regular.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.selectedColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Back'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColor.primaryColor,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final q = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top: detected condition banner ──────────────────────────────
            _ConditionBanner(
              condition: _detectedCondition,
              confidence: _confidence,
              onBack: () => Navigator.pop(context),
            ),

            // ── Progress ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentQuestion + 1} of ${_questions.length}',
                        style: AppStyle.regular.copyWith(
                          color: AppColor.grayColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: AppStyle.regular.copyWith(
                          color: AppColor.blueColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColor.blueColor),
                    ),
                  ),
                ],
              ),
            ),

            // ── Question + options ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.06, 0),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: Column(
                    key: ValueKey(_currentQuestion),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q.question,
                        style: AppStyle.semi40linear.copyWith(fontSize: 20, height: 1.35),
                      ),
                    const SizedBox(height: 20),
                      ...List.generate(
                        q.options.length,
                        (i) {
                          final optionText = q.options[i];
                          return _OptionCard(
                            option: _Option(
                              label: optionText,
                              hint: '',
                              dotColor: const Color(0xFF3B82F6),
                            ),
                            isSelected: _selectedOption == i,
                            onTap: () => _setSelectedOption(i),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Next button ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _selectedOption != null ? _nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.selectedColor,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentQuestion < _questions.length - 1
                            ? 'Next Question'
                            : 'See Results',
                        style: AppStyle.priceDetailsText.copyWith(
                          color: _selectedOption != null
                              ? Colors.white
                              : Colors.grey.shade500,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: _selectedOption != null
                            ? Colors.white
                            : Colors.grey.shade500,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Detected condition banner ─────────────────────────────────────────────────

class _ConditionBanner extends StatelessWidget {
  final String condition;
  final double confidence;
  final VoidCallback onBack;

  const _ConditionBanner({
    required this.condition,
    required this.confidence,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        color: AppColor.blueColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + label row
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'SCAN DETECTED',
                style: AppStyle.regular.copyWith(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Condition + confidence row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.biotech_outlined,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      condition,
                      style: AppStyle.semi40linear.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: confidence,
                              minHeight: 5,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(confidence * 100).toInt()}% confidence',
                          style: AppStyle.regular.copyWith(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Option card ────────────────────────────────────────────────────────────────

class _OptionCard extends StatelessWidget {
  final _Option option;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.blueColor.withValues(alpha: 0.07)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColor.blueColor : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Severity dot
            Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: isSelected ? AppColor.blueColor : option.dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: AppStyle.productNameText.copyWith(
                      fontSize: 14,
                      color: isSelected
                          ? AppColor.blueColor
                          : AppColor.black2Color,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option.hint,
                    style: AppStyle.regular.copyWith(
                      color: Colors.black45,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Radio circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColor.blueColor : Colors.transparent,
                border: Border.all(
                  color:
                      isSelected ? AppColor.blueColor : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data classes ───────────────────────────────────────────────────────────────

class _Question {
  final String text;
  final List<_Option> options;

  const _Question({required this.text, required this.options});
}

class _Option {
  final String label;
  final String hint;
  final Color dotColor;

  const _Option({
    required this.label,
    required this.hint,
    required this.dotColor,
  });
}
