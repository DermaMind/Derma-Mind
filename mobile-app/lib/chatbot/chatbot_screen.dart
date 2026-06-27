import 'dart:io';

import 'package:dermamind_app/providers/auth_provider.dart';
import 'package:dermamind_app/providers/skin_test_provider.dart';
import 'package:dermamind_app/services/api_service.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ChatbotScreen — local AI skincare assistant (no API)
// ─────────────────────────────────────────────────────────────────────────────

class ChatbotScreen extends StatefulWidget {
  static const String routeName = 'chatbotScreen';

  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final SpeechToText _speech = SpeechToText();

  bool _isTyping = false;
  bool _isListening = false;
  bool _contextInitialized = false;
  bool _diagnosisContextSent = false;
  List<Map<String, dynamic>> _chatHistory = [];
  String? _diagnosisContext;

  late final AnimationController _dotsController;

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: 'Hi there! 👋 I\'m DermaMind Assistant, your AI skincare assistant.\n'
          'I can help you with general skincare tips, explain skin types, '
          'and guide you step by step to a simple and effective routine.\n'
          'How can I help you today?',
      isUser: false,
      time: _nowStatic(),
    ),
  ];

  static String _nowStatic() {
    final t = DateTime.now();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  String _now() => _nowStatic();

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _contextInitialized) return;
      _contextInitialized = true;

      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      if (routeArgs is String && routeArgs.isNotEmpty) {
        _diagnosisContext = routeArgs;
        _initChatWithDiagnosis();
        return;
      }

      final skinType = context.read<SkinTestProvider>().skinType;
      if (skinType != 'Unknown') {
        _diagnosisContext = 'User skin type: $skinType';
      }
    });
  }

  Future<void> _initChatWithDiagnosis() async {
    setState(() => _isTyping = true);

    try {
      final response = await ApiService.sendChatMessage(
        message: null,
        history: [],
        diagnosisContext: _diagnosisContext,
      );

      final reply = response.success && response.data != null
          ? response.data!.reply
          : 'I reviewed your scan results. How can I help you today?';

      _chatHistory.add({'role': 'assistant', 'content': reply});
      _diagnosisContextSent = true;

      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages[0] = _ChatMessage(text: reply, isUser: false, time: _now());
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages[0] = _ChatMessage(
          text: 'I reviewed your scan results. How can I help you today?',
          isUser: false,
          time: _now(),
        );
      });
    }
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _dotsController.dispose();
    if (_isListening) _speech.stop();
    super.dispose();
  }

  // ── Send text ──────────────────────────────────────────────────────────────

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true, time: _now()));
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();
    _sendToApi(text);
  }

  Future<void> _sendToApi(String text) async {
    try {
      _chatHistory.add({'role': 'user', 'content': text});

      final response = await ApiService.sendChatMessage(
        message: text,
        history: _chatHistory,
        diagnosisContext: _diagnosisContextSent ? null : _diagnosisContext,
      );

      final reply = response.success && response.data != null
          ? response.data!.reply
          : _getResponse(text);

      _chatHistory.add({'role': 'assistant', 'content': reply});
      _diagnosisContextSent = true;

      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(text: reply, isUser: false, time: _now()));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(
          text: _getResponse(text),
          isUser: false,
          time: _now(),
        ));
      });
    }
    _scrollToBottom();
  }

  // ── Pick image (gallery or camera) ────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (file == null || !mounted) return;

      setState(() {
        _messages.add(_ChatMessage(
          text: 'Image attached',
          isUser: true,
          time: _now(),
          imagePath: file.path,
        ));
        _isTyping = true;
      });
      _scrollToBottom();

      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(
          text: 'I can see you\'ve shared an image! 📸\n'
              'For accurate skin analysis, please use the Scan feature '
              'in the home screen.\nIt uses our AI model for proper diagnosis.',
          isUser: false,
          time: _now(),
        ));
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Could not open image picker'),
            duration: Duration(seconds: 2)),
      );
    }
  }

  // ── Voice input ────────────────────────────────────────────────────────────

  Future<void> _startListening() async {
    final status = await Permission.microphone.request();
    if (!mounted) return;

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Microphone permission denied'),
            duration: Duration(seconds: 2)),
      );
      return;
    }

    final available = await _speech.initialize(
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );

    if (!available || !mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Voice input not supported on this device'),
            duration: Duration(seconds: 2)),
      );
      return;
    }

    setState(() => _isListening = true);
    _showListeningSheet();

    _speech.listen(
      localeId: 'en_US',
      listenFor: const Duration(seconds: 5),
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          _messageController.text = result.recognizedWords;
        }
      },
    );

    await Future.delayed(const Duration(seconds: 5));
    await _speech.stop();
    if (mounted) setState(() => _isListening = false);
  }

  void _showListeningSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColor.blueColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic_rounded,
                      color: AppColor.blueColor, size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  'Listening...',
                  style: AppStyle.semi40linear.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Speak now. Auto-stops after 5 seconds.',
                  style: AppStyle.regular.copyWith(
                      color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _speech.stop();
                      if (mounted) setState(() => _isListening = false);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.blueColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Tap to Stop',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).then((_) async {
      if (_isListening) {
        await _speech.stop();
        if (mounted) setState(() => _isListening = false);
      }
    });
  }

  // ── Scroll ─────────────────────────────────────────────────────────────────

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.hasContentDimensions &&
          _scrollController.position.maxScrollExtent >= 0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Local response logic (fallback) ───────────────────────────────────────

  String _getResponse(String input) {
    final msg = input.toLowerCase();
    final skinType = context.read<SkinTestProvider>().skinType;
    final name = context.read<AuthProvider>().userName;
    final firstName = name.isNotEmpty ? name.split(' ')[0] : 'there';

    if (msg.contains('hello') || msg.contains('hi') || msg.contains('hey')) {
      return 'Hello $firstName! 😊 How can I help you with your skin today?';
    }
    if (msg.contains('oily') || msg.contains('shine') || msg.contains('sebum')) {
      return 'For oily skin:\n'
          '• Use a gentle foaming cleanser twice daily\n'
          '• Look for niacinamide or salicylic acid products\n'
          '• Always use oil-free, non-comedogenic moisturizer\n'
          '• Never skip SPF — even oily skin needs it!';
    }
    if (msg.contains('dry') || msg.contains('flak') || msg.contains('tight')) {
      return 'For dry skin:\n'
          '• Use a rich cream cleanser (not foaming)\n'
          '• Apply moisturizer while skin is still damp\n'
          '• Look for hyaluronic acid and ceramides\n'
          '• Avoid hot showers — they strip natural oils';
    }
    if (msg.contains('acne') || msg.contains('pimple') || msg.contains('breakout')) {
      return 'For acne-prone skin:\n'
          '• Cleanser with 2% salicylic acid works great\n'
          '• Spot treat with benzoyl peroxide at night\n'
          '• Never pop pimples — it causes scarring\n'
          '• Change pillowcases every 2-3 days';
    }
    if (msg.contains('routine') || msg.contains('morning') || msg.contains('night')) {
      return 'Basic routine for $skinType skin:\n\n'
          '☀️ Morning:\n'
          '1. Gentle cleanser\n'
          '2. Toner\n'
          '3. Moisturizer\n'
          '4. SPF 50+\n\n'
          '🌙 Night:\n'
          '1. Double cleanse\n'
          '2. Serum\n'
          '3. Night moisturizer';
    }
    if (msg.contains('spf') || msg.contains('sunscreen') || msg.contains('sun')) {
      return 'SPF is non-negotiable! ☀️\n'
          '• Use SPF 50+ every single day\n'
          '• Reapply every 2 hours outdoors\n'
          '• For $skinType skin, choose a lightweight formula\n'
          '• Even on cloudy days — UV rays still reach you';
    }
    if (msg.contains('ingredient') || msg.contains('niacinamide') ||
        msg.contains('retinol') || msg.contains('vitamin')) {
      return 'Key skincare ingredients:\n'
          '• Niacinamide — pores + oil control\n'
          '• Hyaluronic acid — deep hydration\n'
          '• Retinol — anti-aging (use at night only)\n'
          '• Vitamin C — brightening + antioxidant\n'
          '• Ceramides — skin barrier repair';
    }
    if (msg.contains('dermatologist') || msg.contains('doctor') || msg.contains('see a')) {
      return 'You should see a dermatologist if:\n'
          '• Acne is severe or leaving scars\n'
          '• You have unusual moles or spots\n'
          '• Rashes that don\'t go away\n'
          '• Hair loss or nail changes\n\n'
          'Tip: Use the "Nearby Dermatologists" feature in the app!';
    }
    if (msg.contains('skin type') || msg.contains('my skin')) {
      return skinType == 'Unknown'
          ? 'I don\'t have your skin type yet! '
              'Take the Skin Test in your profile to get personalized advice. 💙'
          : 'Based on your skin test, you have $skinType skin. '
              'This means your skin needs specific care. '
              'Ask me anything about $skinType skin and I\'ll help!';
    }
    if (msg.contains('product') || msg.contains('recommend') || msg.contains('buy')) {
      return 'For personalized product recommendations, '
          'check the Products section in the app — '
          'it\'s tailored to your $skinType skin type! 🛍️\n\n'
          'Generally look for:\n'
          '• Fragrance-free formulas\n'
          '• Dermatologist tested\n'
          '• Non-comedogenic labels';
    }
    if (msg.contains('sensitive') || msg.contains('irritat')) {
      return 'For sensitive skin:\n'
          '• Choose fragrance-free and alcohol-free products\n'
          '• Patch test every new product first\n'
          '• Use soothing ingredients like aloe vera, centella\n'
          '• Avoid physical scrubs — use gentle chemical exfoliants';
    }
    if (msg.contains('combination')) {
      return 'For combination skin:\n'
          '• Use a balanced gel cleanser\n'
          '• Apply lighter moisturizer on the T-zone\n'
          '• Use a richer cream on dry areas (cheeks)\n'
          '• Niacinamide helps regulate the T-zone oil';
    }
    if (msg.contains('tip') || msg.contains('advice') || msg.contains('help')) {
      return 'Here are my top skincare tips 💙\n'
          '1. Always cleanse morning and night\n'
          '2. Moisturize — every skin type needs it\n'
          '3. SPF 50+ is your best anti-aging tool\n'
          '4. Stay hydrated — drink enough water\n'
          '5. Get 7-8 hours of sleep for skin repair';
    }
    return 'That\'s a great question! 💙\n'
        'Based on your $skinType skin type, I recommend consulting '
        'the Products section for personalized picks.\n\n'
        'You can also:\n'
        '• Take the Skin Test for detailed analysis\n'
        '• Visit a nearby dermatologist for professional advice\n\n'
        'Is there something specific about your skin I can help with?';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                if (index < 0 || index >= _messages.length) {
                  return const SizedBox.shrink();
                }
                final message = _messages[index];
                if (!message.isUser && index == 0 && _messages.length == 1) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBotBubble(message),
                      _buildQuickReplies(),
                    ],
                  );
                }
                return message.isUser
                    ? _buildUserBubble(message)
                    : _buildBotBubble(message);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.blueColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            child: Icon(Icons.smart_toy_outlined,
                color: AppColor.blueColor, size: 20),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DermaMind Assistant',
                  style: AppStyle.productNameText.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Online',
                      style: AppStyle.regular
                          .copyWith(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Options coming soon'),
                  duration: Duration(seconds: 2)),
            );
          },
        ),
      ],
    );
  }

  // ── Quick reply chips ──────────────────────────────────────────────────────

  Widget _buildQuickReplies() {
    const chips = [
      'General skincare tips',
      'Explain skin types',
      'Tips for oily / sensitive skin',
      'How to maintain healthy skin',
      'When should I see a dermatologist?',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips.map((chip) {
          return GestureDetector(
            onTap: () {
              _messageController.text = chip;
              _sendMessage();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColor.blueColor.withValues(alpha: 0.3)),
              ),
              child: Text(chip,
                  style: AppStyle.regular
                      .copyWith(color: AppColor.blueColor, fontSize: 12)),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── User bubble ────────────────────────────────────────────────────────────

  Widget _buildUserBubble(_ChatMessage msg) {
    // Image bubble
    if (msg.imagePath != null) {
      return Align(
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 2, left: 60, right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(msg.imagePath!),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14, bottom: 2),
              child: Text('Image attached',
                  style: AppStyle.regular
                      .copyWith(color: Colors.grey.shade600, fontSize: 11)),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14, bottom: 8),
              child: Text(msg.time,
                  style: AppStyle.regular
                      .copyWith(color: Colors.grey, fontSize: 10)),
            ),
          ],
        ),
      );
    }

    // Text bubble
    final maxWidth = MediaQuery.of(context).size.width * 0.75;
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            margin: const EdgeInsets.only(bottom: 2, left: 60, right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColor.blueColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(msg.text,
                style: AppStyle.regular
                    .copyWith(color: Colors.white, fontSize: 14, height: 1.45)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14, bottom: 8),
            child: Text(msg.time,
                style: AppStyle.regular
                    .copyWith(color: Colors.grey, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  // ── Bot bubble ─────────────────────────────────────────────────────────────

  Widget _buildBotBubble(_ChatMessage msg) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 12, right: 60),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColor.blueColor,
              child: const Icon(Icons.smart_toy_outlined,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(msg.text,
                        style: AppStyle.regular.copyWith(
                            color: Colors.black87, fontSize: 14, height: 1.5)),
                  ),
                  const SizedBox(height: 3),
                  Text(msg.time,
                      style: AppStyle.regular
                          .copyWith(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Typing indicator ───────────────────────────────────────────────────────

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 12, right: 60),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColor.blueColor,
              child: const Icon(Icons.smart_toy_outlined,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final start = i * (1 / 3);
                  final end = start + (1 / 3);
                  final anim = CurvedAnimation(
                    parent: _dotsController,
                    curve: Interval(start, end, curve: Curves.easeInOut),
                  );
                  return AnimatedBuilder(
                    animation: anim,
                    builder: (_, __) => Container(
                      margin: EdgeInsets.only(left: i == 0 ? 0 : 5),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey
                            .withValues(alpha: 0.3 + anim.value * 0.7),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Input bar ──────────────────────────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment
            IconButton(
              icon: Icon(Icons.attach_file_rounded,
                  color: Colors.grey.shade500, size: 22),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
            // Text field
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Write your message...',
                    hintStyle:
                        TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            // Camera
            IconButton(
              icon: Icon(Icons.camera_alt_outlined,
                  color: Colors.grey.shade500, size: 22),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            // Mic
            IconButton(
              icon: Icon(
                _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: _isListening ? AppColor.blueColor : Colors.grey.shade500,
                size: 22,
              ),
              onPressed: _isListening ? null : _startListening,
            ),
            const SizedBox(width: 4),
            // Send
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColor.blueColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColor.blueColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

// ── Message model ──────────────────────────────────────────────────────────────

class _ChatMessage {
  final String text;
  final bool isUser;
  final String time;
  final String? imagePath;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.imagePath,
  });
}
