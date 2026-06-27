class ChatbotResponseModel {
  final String reply;
  final String? sessionId;

  const ChatbotResponseModel({required this.reply, this.sessionId});

  factory ChatbotResponseModel.fromJson(Map<String, dynamic> json) {
    final reply = json['reply'] ??
        json['message'] ??
        json['response'] ??
        json['content'] ??
        json['answer'] ??
        'I understand. How can I help you further?';

    return ChatbotResponseModel(
      reply: reply.toString(),
      sessionId: json['sessionId']?.toString() ?? json['session_id']?.toString(),
    );
  }
}
