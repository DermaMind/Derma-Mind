import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/skin_test_provider.dart';
import '../utils/app_color.dart';
import '../utils/app_style.dart';
import '../l10n/app_localizations.dart';
import '../HomeScreen/wiidget/main_layout.dart';
import 'reuseble_component/NextButton.dart';
import 'reuseble_component/option_Card.dart';
import 'reuseble_component/questionHeader.dart';
import 'sucessedScreen.dart';

class QuestionScreen extends StatefulWidget {
  static const String RoutName = "questionScreen";

  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int? selectedIndex;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<SkinTestProvider>();
      provider.resetTest();
      // Get current app language
      final locale = Localizations.localeOf(context).languageCode;
      provider.setLang(locale);
      await provider.loadQuestionsFromApi(lang: locale);
      setState(() {});
    });
  }
  void skipDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Skip Skin Test?"),
        content: const Text(
          "You can always take it later.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              Navigator.pushNamedAndRemoveUntil(
                context,
                mainLayout.routeName,
                    (route) => false,
              );
            },
            child: const Text(
              "Skip",
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
    );
  }

  Future<void> nextQuestion(
      SkinTestProvider provider,
      ) async {
    if (selectedIndex == null) return;

    final question =
    provider.apiQuestions[provider.currentQuestion];

    final optionId =
        question.options[selectedIndex!].id;

    provider.answerQuestion(
      provider.currentQuestion,
      optionId,
    );

    if (provider.isCompleted) {
      setState(() {
        loading = true;
      });

      await provider.completeSkinTest();

      setState(() {
        loading = false;
      });

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        SuccessScreen.RoutName,
            (route) => false,
      );

      return;
    }

    setState(() {
      selectedIndex = null;
    });
  }
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SkinTestProvider>();

    if (!provider.questionsLoaded || provider.apiQuestions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final question =
    provider.apiQuestions[provider.currentQuestion];

    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
        child: loading
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColor.blueColor,
              ),
              SizedBox(height: 20),
              Text(
                "Analyzing your skin...",
              )
            ],
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment:
                MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: skipDialog,
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  )
                ],
              ),

              QuestionHeader(
                title:
                "Question ${provider.currentQuestion + 1} of ${provider.totalQuestions}",
                rightIcon:
                const Icon(Icons.close),
                onRightTap: skipDialog,
              ),

              const SizedBox(height: 15),

              LinearProgressIndicator(
                value:
                (provider.currentQuestion + 1) /
                    provider.totalQuestions,
                backgroundColor:
                Colors.grey.shade300,
                valueColor:
                const AlwaysStoppedAnimation(
                  AppColor.blueColor,
                ),
                minHeight: 6,
                borderRadius:
                BorderRadius.circular(99),
              ),

              const SizedBox(height: 25),

              Text(
                question.questionText,
                style: AppStyle.semi40linear
                    .copyWith(fontSize: 26),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: ListView.builder(
                  itemCount:
                  question.options.length,
                  itemBuilder:
                      (context, index) {
                    final option =
                    question.options[index];

                    return QuestionCard(
                      title: option.optionText,
                      subtitle: null,
                      isSelected:
                      selectedIndex ==
                          index,
                      onTap: () {
                        setState(() {
                          selectedIndex =
                              index;
                        });
                      },
                    );
                  },
                ),
              ),

              Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 20,
                ),
                child: NextButton(
                  enabled:
                  selectedIndex != null,
                  title:
                  provider.currentQuestion ==
                      provider
                          .totalQuestions -
                          1
                      ? "Finish"
                      : AppLocalizations.of(
                      context)!
                      .next,
                  onPressed: () =>
                      nextQuestion(
                        provider,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Local fallback questions

}