import 'package:flutter/material.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:dermamind_app/utils/assets_Maneger.dart';

import '../../HomeScreen/wiidget/SlidePageRoute.dart';
import '../../product_screen/product_details_screen.dart';
import '../../product_screen/product_model.dart';

class ProductCardGrid extends StatelessWidget {
  const ProductCardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(
          context,
          SlidePageRoute(page: ProductDetailsScreen(product: dummyProducts.first)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.white2Color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.2,
                    child: Image.asset(
                      AssetsManager.productPhoto,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 18,
                        color: AppColor.blue2Color,
                      ),
                    ),
                  ),
                ],
              ),
            ),


            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    Text(
                      "Firming power serum",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyle.productNameText,
                    ),

                    const SizedBox(height: 4),


                    Text(
                      "20pcs",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),

                    const Spacer(),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "200,00 EGP",
                          style: AppStyle.priceText,
                        ),

                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColor.blue2Color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}