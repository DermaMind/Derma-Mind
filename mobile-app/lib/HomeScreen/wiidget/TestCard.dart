import 'package:dermamind_app/providers/auth_provider.dart';
import 'package:dermamind_app/providers/skin_test_provider.dart';
import 'package:flutter/material.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:dermamind_app/utils/assets_Maneger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';

class TestCard extends StatefulWidget {
  final bool hasResult;
  final String skinType;
  final String skinHistory;
  final String lastScan;
  final VoidCallback? onStartTest;

  const TestCard({
    super.key,
    required this.hasResult,
    required this.skinType,
    required this.skinHistory,
    required this.lastScan,
    this.onStartTest,
  });

  @override
  State<TestCard> createState() => _TestCardState();
}

class _TestCardState extends State<TestCard> {
  static const _skippedKeyPrefix = 'skin_test_intro_skipped_';
  static const _photoWidth = 168.0;
  static const _photoHeight = 198.0;
  static const _cardHeight = 170.0;

  static const _invalidValues = {
    '',
    'unknown',
    'no history',
    'never',
    'not taken yet',
  };

  bool _skippedPref = false;
  bool _flagsLoaded = false;
  bool _awaitingTestReturn = false;

  @override
  void initState() {
    super.initState();
    _loadVisibilityFlags();
  }

  @override
  void didUpdateWidget(TestCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_awaitingTestReturn) {
      _awaitingTestReturn = false;
      if (!widget.hasResult) {
        _persistSkipped(true);
      }
    }
  }

  String _skippedKey(String email) => '$_skippedKeyPrefix$email';

  Future<void> _loadVisibilityFlags() async {
    final email = context.read<AuthProvider>().email.trim().toLowerCase();
    final prefs = await SharedPreferences.getInstance();

    var skipped = email.isNotEmpty && (prefs.getBool(_skippedKey(email)) ?? false);

    if (!widget.hasResult && !skipped && email.isNotEmpty) {
      skipped = _inferSkippedFromProvider();
      if (skipped) {
        await prefs.setBool(_skippedKey(email), true);
      }
    }

    if (!mounted) return;
    setState(() {
      _skippedPref = skipped;
      _flagsLoaded = true;
    });
  }

  bool _inferSkippedFromProvider() {
    final skinTest = context.read<SkinTestProvider>();
    return skinTest.questionsLoaded &&
        skinTest.progress == 0 &&
        !skinTest.hasSkinResult;
  }

  Future<void> _persistSkipped(bool value) async {
    final email = context.read<AuthProvider>().email.trim().toLowerCase();
    if (email.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_skippedKey(email), value);
    if (!mounted) return;
    setState(() => _skippedPref = value);
  }

  bool get _shouldShowIntro {
    if (widget.hasResult) return false;
    if (!_flagsLoaded) return false;
    if (_skippedPref) return true;
    return _inferSkippedFromProvider();
  }

  bool _isValidField(String value) {
    return !_invalidValues.contains(value.trim().toLowerCase());
  }

  void _handleStartTest() {
    _awaitingTestReturn = true;
    widget.onStartTest?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hasResult) {
      return _buildResultCard(context);
    }

    if (!_shouldShowIntro) {
      return const SizedBox.shrink();
    }

    return _buildIntroCard(context);
  }

  BorderRadius _photoBorderRadius(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return BorderRadius.only(
      topRight: isRtl ? Radius.zero : const Radius.circular(20),
      bottomRight: isRtl ? Radius.zero : const Radius.circular(20),
      topLeft: isRtl ? const Radius.circular(20) : Radius.zero,
      bottomLeft: isRtl ? const Radius.circular(20) : Radius.zero,
    );
  }

  Widget _buildOverflowPhoto(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Positioned(
      right: isRtl ? null : -10,
      left: isRtl ? -10 : null,
      top: -8,
      bottom: -12,
      child: ClipRRect(
        borderRadius: _photoBorderRadius(context),
        child: Image.asset(
          AssetsManager.photoHome,
          width: _photoWidth,
          height: _photoHeight,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
    );
  }

  Widget _buildCardShell({
    required BuildContext context,
    required BoxDecoration decoration,
    required Widget content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: _cardHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Container(
                decoration: decoration,
                clipBehavior: Clip.antiAlias,
                child: content,
              ),
            ),
            _buildOverflowPhoto(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final photoSidePadding = isRtl ? 96.0 : 96.0;

    return _buildCardShell(
      context: context,
      decoration: BoxDecoration(
        color: AppColor.blue2Color,
        borderRadius: BorderRadius.circular(20),
      ),
      content: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          photoSidePadding,
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n?.testSkinTypeTitle ?? 'Test Skin Type',
              style: AppStyle.SkinTestCard.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.testSkinTypeSubtitle ??
                  'Discover Your Skin Type In \nMinutes.',
              style: AppStyle.regular.copyWith(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _handleStartTest,
              child: Container(
                alignment: Alignment.center,
                width: width * .33,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: AppColor.bottonColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n?.skinTest ?? 'Skin Test',
                  style: AppStyle.regular.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final photoSidePadding = isRtl ? 96.0 : 96.0;

    final showSkinType = _isValidField(widget.skinType);
    final showSkinHistory = _isValidField(widget.skinHistory);
    final showLastScan = _isValidField(widget.lastScan);

    return _buildCardShell(
      context: context,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      content: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          photoSidePadding,
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n?.skinTypeResult ?? 'Skin Type Result',
              style: AppStyle.SkinTestCard.copyWith(
                fontSize: 18,
                color: AppColor.blackColor,
              ),
            ),
            const SizedBox(height: 10),
            if (showSkinType) ...[
              _ResultField(
                label: l10n?.skinType ?? 'Skin Type',
                value: widget.skinType,
              ),
              const SizedBox(height: 6),
            ],
            if (showSkinHistory) ...[
              _ResultField(
                label: l10n?.skinHistory ?? 'Skin History',
                value: widget.skinHistory,
                maxLines: 3,
              ),
              const SizedBox(height: 6),
            ],
            if (showLastScan)
              _ResultField(
                label: l10n?.lastScan ?? 'Last Scan',
                value: widget.lastScan,
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultField extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;

  const _ResultField({
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyle.regular.copyWith(
            color: AppColor.blackColor.withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: AppStyle.regular.copyWith(
            color: AppColor.blackColor.withValues(alpha: 0.85),
            fontSize: 13,
            height: 1.35,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
