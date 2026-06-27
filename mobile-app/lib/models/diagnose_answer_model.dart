class DiagnoseAnswer {
  final int questionId;
  final String question;
  final String answer;

  const DiagnoseAnswer({
    required this.questionId,
    required this.question,
    required this.answer,
  });

  Map<String, dynamic> toJson() => {
        'question_id': questionId,
        'question': question,
        'answer': answer,
      };
}
