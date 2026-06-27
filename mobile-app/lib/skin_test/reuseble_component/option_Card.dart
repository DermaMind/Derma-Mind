import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback? onTap;

  const QuestionCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.blueColor : AppColor.whiteColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColor.blueColor : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppStyle.semi20Linear.copyWith(
                color: isSelected ? Colors.white70 : AppColor.blackColor,
              ),
            ),
            const SizedBox(height: 4),
            if (subtitle != null && subtitle!.isNotEmpty)
              Text(
                subtitle!,
                style: AppStyle.regular.copyWith(
                  color: isSelected ? Colors.white70 : Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
