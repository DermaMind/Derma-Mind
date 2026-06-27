import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:flutter/material.dart';

class TermsPrivacyScreen extends StatelessWidget {
  static const String routeName = 'termsPrivacyScreen';

  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
            'Terms & Privacy',
            style: AppStyle.semi40linear
                .copyWith(color: Colors.white, fontSize: 18),
          ),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: 'Terms of Service'),
              Tab(text: 'Privacy Policy'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TermsTab(),
            _PrivacyTab(),
          ],
        ),
      ),
    );
  }
}

// ── Terms of Service ───────────────────────────────────────────────────────────

class _TermsTab extends StatelessWidget {
  const _TermsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionTitle('Terms of Service'),
          _BodyText(
              'Last updated: June 2026\n\nWelcome to DermaMind. By using this application you agree to the following terms. Please read them carefully.'),
          _SectionTitle('1. Use of the App'),
          _BodyText(
              'DermaMind is intended for informational and educational purposes only. The AI-based skin analysis feature provides screening results and is NOT a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of a qualified healthcare provider with any questions you may have regarding a medical condition.'),
          _SectionTitle('2. User Accounts'),
          _BodyText(
              'You must create an account to use certain features. You are responsible for maintaining the confidentiality of your account credentials. Notify us immediately if you suspect unauthorized use of your account.'),
          _SectionTitle('3. Intellectual Property'),
          _BodyText(
              'All content, design, and technology within DermaMind — including but not limited to AI models, UI elements, and written content — are the intellectual property of the DermaMind development team. Unauthorized reproduction or distribution is prohibited.'),
          _SectionTitle('4. Limitation of Liability'),
          _BodyText(
              'DermaMind and its developers shall not be liable for any direct, indirect, incidental, or consequential damages arising from the use or inability to use this application, including any reliance on AI-generated results.'),
          _SectionTitle('5. Changes to Terms'),
          _BodyText(
              'We reserve the right to modify these terms at any time. Continued use of the app after changes are posted constitutes your acceptance of the updated terms.'),
          _SectionTitle('6. Contact'),
          _BodyText(
              'For questions about these Terms of Service, contact us at support@dermamind.app.'),
        ],
      ),
    );
  }
}

// ── Privacy Policy ─────────────────────────────────────────────────────────────

class _PrivacyTab extends StatelessWidget {
  const _PrivacyTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionTitle('Privacy Policy'),
          _BodyText(
              'Last updated: June 2026\n\nYour privacy is important to us. This policy explains what data we collect, how we use it, and your rights.'),
          _SectionTitle('1. Data We Collect'),
          _BodyText(
              '• Account information: name, email address, and optionally phone number and date of birth.\n'
              '• Skin scan images uploaded for analysis.\n'
              '• Skin test answers and results.\n'
              '• App usage data for improving our AI model.'),
          _SectionTitle('2. How We Use Your Data'),
          _BodyText(
              'Your data is used to provide and improve the DermaMind service, personalize your experience, and send optional notifications (which you can disable in Settings). We do not sell your personal data to third parties.'),
          _SectionTitle('3. Data Storage & Security'),
          _BodyText(
              'All data is encrypted in transit using HTTPS. Scan images and results are stored on secured servers. We apply industry-standard security practices to protect your information.'),
          _SectionTitle('4. Location Data'),
          _BodyText(
              'The "Nearby Dermatologists" feature requests your device location. This data is used only to find nearby clinics and is not stored on our servers.'),
          _SectionTitle('5. Your Rights'),
          _BodyText(
              'You have the right to access, correct, or delete your personal data at any time. You can delete your account from Settings → Edit Profile → Delete Account. This permanently removes all your data.'),
          _SectionTitle('6. Cookies & Analytics'),
          _BodyText(
              'DermaMind does not use browser cookies. We may collect anonymous usage analytics to improve the app experience.'),
          _SectionTitle('7. Contact'),
          _BodyText(
              'For privacy-related inquiries, contact us at support@dermamind.app.'),
        ],
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: Text(
        text,
        style: AppStyle.regular.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColor.blackColor,
        ),
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppStyle.regular.copyWith(
        fontSize: 13,
        color: AppColor.grayColor,
        height: 1.6,
      ),
    );
  }
}
