import 'package:dermamind_app/HomeScreen/wiidget/main_layout.dart';
import 'package:dermamind_app/providers/skin_test_provider.dart';
import 'package:dermamind_app/skin_test/reuseble_component/NextButton.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../utils/app_color.dart';

class SuccessScreen extends StatelessWidget {
  static const String RoutName = 'successScreen';

  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final skinTest = context.watch<SkinTestProvider>();

    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check,
                          size: 60,
                          color: AppColor.blueColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      AppLocalizations.of(context)!.messageSucceed,
                      textAlign: TextAlign.center,
                      style: AppStyle.semi20Linear.copyWith(
                        color: AppColor.blackColor,
                        fontSize: 25,
                      ),
                    ),
                    if (skinTest.skinType != 'Unknown') ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColor.blueColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColor.blueColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Skin Type',
                              style: AppStyle.regular.copyWith(
                                color: AppColor.grayColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              skinTest.skinType,
                              style: AppStyle.semi40linear.copyWith(
                                color: AppColor.blueColor,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Main Concern',
                              style: AppStyle.regular.copyWith(
                                color: AppColor.grayColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              skinTest.skinHistory,
                              textAlign: TextAlign.center,
                              style: AppStyle.regular.copyWith(
                                color: AppColor.blackColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: NextButton(
                  enabled: true,
                  title: AppLocalizations.of(context)!.goto_home,
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      mainLayout.routeName,
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
