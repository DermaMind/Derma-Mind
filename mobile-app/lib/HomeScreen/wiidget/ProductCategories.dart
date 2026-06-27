import 'package:dermamind_app/utils/app_style.dart';
import 'package:flutter/material.dart';
import '../../utils/app_color.dart';

class ProductCategories extends StatelessWidget {
  const ProductCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          CategoryItem(text: "All", isSelected: true),
          CategoryItem(text: "Moisturizer"),
          CategoryItem(text: "Toner"),
          CategoryItem(text: "Cleanser"),
          CategoryItem(text: "Serum"),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String text;
  final bool isSelected;

  const CategoryItem({
    super.key,
    required this.text,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.blue2Color : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: AppStyle.popularText.copyWith(
            color: isSelected ? Colors.white : Colors.black,)



        ),
      ),
    );
  }
}