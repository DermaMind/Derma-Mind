import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/app_style.dart';

class QuestionHeader extends StatelessWidget {
  final String title;
  final Widget? rightIcon;
  final VoidCallback? onRightTap;

  const QuestionHeader({
    super.key,
    required this.title,
    this.rightIcon,
    this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [


        _circleButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onTap: () => Navigator.pop(context),
        ),


        Text(
          title,
          style: AppStyle.semi40linear,
        ),


        rightIcon != null
            ? _circleButton(
          icon: rightIcon!,
          onTap: onRightTap ?? () {},
        )
            : const SizedBox(width: 40),
      ],
    );
  }

  Widget _circleButton({
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: icon,
      ),
    );
  }
}