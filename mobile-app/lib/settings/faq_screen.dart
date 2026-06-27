import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:flutter/material.dart';

class FaqScreen extends StatefulWidget {
  static const String routeName = 'faqScreen';

  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  static const List<Map<String, String>> _faqs = [
    {
      'q': 'What is DermaMind?',
      'a':
          'DermaMind is an AI-powered skin disease classification app that helps you identify potential skin conditions from photos, track your skin health over time, and connect with nearby dermatologists.',
    },
    {
      'q': 'How does the skin scan work?',
      'a':
          'Take or upload a clear photo of the affected skin area. Our AI model analyzes the image and provides a classification along with a confidence score, severity rating, and recommended next steps.',
    },
    {
      'q': 'Is my scan data private?',
      'a':
          'Yes. Your scan images and results are stored securely and are never shared with third parties. You can delete your account and all associated data at any time from the Settings screen.',
    },
    {
      'q': 'What is the Skin Test?',
      'a':
          'The Skin Test is a short questionnaire that helps us understand your skin type and history. The results are used to personalize product recommendations and skincare advice throughout the app.',
    },
    {
      'q': 'How accurate is the AI diagnosis?',
      'a':
          'Our model is trained on a large dataset of dermatological images and achieves high accuracy on common conditions. However, the app is intended as a screening tool only — always consult a licensed dermatologist for a formal diagnosis.',
    },
    {
      'q': 'Can I use DermaMind without an internet connection?',
      'a':
          'Basic features such as viewing your saved skin profile and previously loaded products work offline. Skin scanning, chatbot responses, and finding nearby doctors require an internet connection.',
    },
    {
      'q': 'How do I find a nearby dermatologist?',
      'a':
          'Tap "Nearby Dermatologists" from the Home screen. The app will request your location and show clinics and pharmacies on an interactive map. Tap any pin or card to see details.',
    },
    {
      'q': 'What should I do if the scan result seems wrong?',
      'a':
          'AI results can vary with image quality and lighting. Try retaking the photo in good natural light with the affected area clearly visible. If you are still concerned, please visit a dermatologist in person.',
    },
    {
      'q': 'How do I change my password?',
      'a':
          'Go to Settings → Change Password. You will receive a one-time code on your registered email address to verify your identity before setting a new password.',
    },
    {
      'q': 'How do I contact support?',
      'a':
          'Tap Settings → Contact Support to open a pre-filled email to support@dermamind.app. Our team typically responds within 24 hours.',
    },
  ];

  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: AppBar(
        backgroundColor: AppColor.blueColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Help & FAQ',
          style:
              AppStyle.semi40linear.copyWith(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          final isOpen = _expanded.contains(index);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() {
                if (isOpen) {
                  _expanded.remove(index);
                } else {
                  _expanded.add(index);
                }
              }),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            faq['q']!,
                            style: AppStyle.regular.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          isOpen
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppColor.blueColor,
                          size: 22,
                        ),
                      ],
                    ),
                    if (isOpen) ...[
                      const SizedBox(height: 10),
                      Divider(height: 1, color: Colors.grey.shade100),
                      const SizedBox(height: 10),
                      Text(
                        faq['a']!,
                        style: AppStyle.regular.copyWith(
                          fontSize: 13,
                          color: AppColor.grayColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
