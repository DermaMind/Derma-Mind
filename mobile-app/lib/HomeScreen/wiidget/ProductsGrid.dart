import 'package:dermamind_app/skin_test/reuseble_component/productItemCard_grid.dart';
import 'package:flutter/material.dart';
import '../../skin_test/reuseble_component/product_Item_card.dart';

class ProductsGrid extends StatelessWidget {
  const ProductsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 16,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        return ProductCardGrid();
      },
    );
  }
}