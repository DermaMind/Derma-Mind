import 'package:dermamind_app/chatbot/chatbot_screen.dart';
import 'package:dermamind_app/doctors/doctors_screen.dart';
import 'package:dermamind_app/models/scan_result_model.dart';
import 'package:dermamind_app/product_screen/product_screen.dart';
import 'package:dermamind_app/providers/skin_test_provider.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ScanResultScreen — "Final Assessment"
// Shown after the user completes all follow-up questions.
// All data is dummy / hardcoded — replace with real API response later.
// ─────────────────────────────────────────────────────────────────────────────

class ScanResultScreen extends StatefulWidget {
  static const String routeName = 'scanResult';

  const ScanResultScreen({super.key});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  bool _insightExpanded = true;

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
      case 'severe':
        return const Color(0xFFF97316);
      case 'moderate':
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'low':
      case 'mild':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFFF97316);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = ModalRoute.of(context)?.settings.arguments as ScanResultModel?
        ?? ScanResultModel.dummy();
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConditionCard(result),
            const SizedBox(height: 14),
            _buildSkinTypeCard(context),
            const SizedBox(height: 14),
            _buildPersonalizedInsight(result),
            const SizedBox(height: 14),
            _buildCarePlan(result),
            const SizedBox(height: 14),
            _buildDisclaimer(result),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Final Assessment',
          style: AppStyle.semi40linear.copyWith(fontSize: 18)),
      centerTitle: true,
      actions: [

        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Share coming soon'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.share_outlined,
              color: Colors.black54, size: 22),
        ),
      ],
    );
  }

  // ── Condition card (blue) ──────────────────────────────────────────────────

  Widget _buildConditionCard(ScanResultModel result) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.blueColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DETECTED CONDITION',
            style: AppStyle.regular.copyWith(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.medical_information_outlined,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.disease,
                      style: AppStyle.semi40linear.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (result.severity.isNotEmpty)
                          _SeverityBadge(
                            label: result.severity,
                            color: _severityColor(result.severity),
                          ),
                        if (result.severity.isNotEmpty) const SizedBox(width: 10),
                        Text(
                          '${(result.confidence <= 1.0 ? result.confidence * 100 : result.confidence).toStringAsFixed(0)}% confidence',
                          style: AppStyle.regular.copyWith(
                            color: Colors.white70,
                            fontSize: 13,
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

  // ── Skin type card ─────────────────────────────────────────────────────────

  Widget _buildSkinTypeCard(BuildContext context) {
    final provider = context.read<SkinTestProvider>();
    final skinDescription = provider.skinHistory.isNotEmpty
        ? provider.skinHistory
        : provider.skinType;
    final skinCode = provider.skinType;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.blueColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.face_retouching_natural,
                color: AppColor.blueColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR SKIN TYPE',
                  style: AppStyle.regular.copyWith(
                    color: AppColor.grayColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  skinDescription,
                  style: AppStyle.regular.copyWith(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (skinCode.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.blueColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                skinCode,
                style: AppStyle.regular.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 1.0,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Personalized insight ──────────────────────────────────────────────────

  Widget _buildPersonalizedInsight(ScanResultModel result) {
    if (result.description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => _insightExpanded = !_insightExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.tips_and_updates_outlined,
                      color: AppColor.blueColor, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Personalized Insight',
                    style: AppStyle.productNameText.copyWith(fontSize: 15),
                  ),
                  const Spacer(),
                  Icon(
                    _insightExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColor.grayColor,
                  ),
                ],
              ),
            ),
          ),
          if (_insightExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColor.blueColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          'About Your Condition',
                          style: AppStyle.productNameText.copyWith(
                              color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.description,
                    style: AppStyle.regular.copyWith(
                      color: Colors.black54,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Care plan ─────────────────────────────────────────────────────────────

  Widget _buildCarePlan(ScanResultModel result) {
    final recommendations = result.recommendations;
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_services_outlined,
                  color: AppColor.blueColor, size: 20),
              const SizedBox(width: 10),
              Text(
                'Initial Care Recommendations',
                style: AppStyle.productNameText.copyWith(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline,
                    color: Color(0xFF10B981), size: 16),
                const SizedBox(width: 6),
                Text(
                  'Care Plan',
                  style: AppStyle.regular.copyWith(
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...recommendations.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(Icons.check_circle,
                        color: Color(0xFF10B981), size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      r,
                      style: AppStyle.regular.copyWith(
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Disclaimer ────────────────────────────────────────────────────────────

  Widget _buildDisclaimer(ScanResultModel result) {
    if (result.disclaimer == null || result.disclaimer!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFF59E0B), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              result.disclaimer!,
              style: AppStyle.regular.copyWith(
                color: const Color(0xFF92400E),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ────────────────────────────────────────────────────────

  Widget _buildActionButtons() {
    return Column(
      children: [
        _ActionButton(
          label: 'Chat with Smart Assistant',
          icon: Icons.smart_toy_outlined,
          color: AppColor.blueColor,
          onTap: () =>
              Navigator.pushNamed(context, ChatbotScreen.routeName),
        ),
        const SizedBox(height: 12),
        _ActionButton(
          label: 'Find Nearby Dermatologists',
          icon: Icons.location_on_outlined,
          color: const Color(0xFF10B981),
          onTap: () =>
              Navigator.pushNamed(context, DoctorsScreen.routeName),
        ),
        const SizedBox(height: 12),
        _ActionButton(
          label: 'View Recommended Products',
          icon: Icons.shopping_bag_outlined,
          color: const Color(0xFF8B5CF6),
          onTap: () =>
              Navigator.pushNamed(context, ProductsScreen.routeName),
        ),
      ],
    );
  }
}

// ── Severity badge ─────────────────────────────────────────────────────────────

class _SeverityBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SeverityBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          label,
          style: AppStyle.priceDetailsText
              .copyWith(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
