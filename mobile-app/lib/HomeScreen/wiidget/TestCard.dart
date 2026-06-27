import 'package:flutter/material.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:dermamind_app/utils/assets_Maneger.dart';
import '../../l10n/app_localizations.dart';

class TestCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (hasResult) {
      return _buildResultCard(context);
    }

    return _buildTestCard(context);
  }

  Widget _buildTestCard(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
      constraints: const BoxConstraints(
        minHeight: 170,
      ),
      decoration: BoxDecoration(
        color: AppColor.blue2Color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Flexible(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.testSkinTypeTitle,
                    style: AppStyle.SkinTestCard.copyWith(
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    AppLocalizations.of(context)!
                        .testSkinTypeSubtitle,
                    style: AppStyle.regular.copyWith(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 14),

                  GestureDetector(
                    onTap: onStartTest,
                    child: Container(
                      alignment: Alignment.center,
                      width: width * .33,
                      padding: const EdgeInsets.symmetric(
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.bottonColor,
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!
                            .skinTest,
                        style: AppStyle.regular.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          SizedBox(
            width: 140,
            height: 170,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
            
                Positioned(
                  right: 10,
                  top: 20,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                        Colors.white.withOpacity(.25),
                        width: 14,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: AppColor.blue2Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
            
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Image.asset(
                    AssetsManager.photoCard,
                    height: 165,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildResultCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColor.blue2Color,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              const Icon(
                Icons.verified,
                color: AppColor.blue2Color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "Skin Analysis",
                style: AppStyle.SkinTestCard.copyWith(
                  color: AppColor.blue2Color,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            "Skin Type",
            style: AppStyle.regular.copyWith(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            skinType.isEmpty ? "--" : skinType,
            style: AppStyle.semi20Linear.copyWith(
              color: AppColor.blackColor,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "Description",
            style: AppStyle.regular.copyWith(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            skinHistory.isEmpty
                ? "No description available."
                : skinHistory,
            style: AppStyle.regular.copyWith(
              color: AppColor.blackColor,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Icon(
                Icons.history,
                color: AppColor.blue2Color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Last Scan",
                style: AppStyle.regular.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                lastScan,
                style: AppStyle.regular.copyWith(
                  color: Colors.black54,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStartTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.blue2Color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Retake Skin Test",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Legend row ─────────────────────────────────────────────────────────────────

