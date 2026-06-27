import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:dermamind_app/utils/assets_Maneger.dart';
import 'package:flutter/material.dart';

class productItemCard extends StatelessWidget {

  const productItemCard({super.key, });



  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,

      decoration: BoxDecoration(
        color: AppColor.white2Color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200,width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(AssetsManager.productPhoto,
                  height: 110,
                  width:double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                  top: 4,
                  right: 4,
                  child:CircleAvatar(
                    backgroundColor: AppColor.white2Color,radius:13 ,
                    child: IconButton(
                        onPressed: (){},
                        color: AppColor.blue2Color,
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        icon:  Icon(Icons.favorite_border_rounded,color: AppColor.blue2Color
                          ,)),
                  ))
            ],
          ),
          const SizedBox(height: 2),
          Padding(
            padding:
            const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Firming power serum', maxLines: 2,
                  overflow: TextOverflow.ellipsis,style: AppStyle.productNameText,),
                const SizedBox(height: 2),
                Text(
                  "20pcs",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "200,00 EGP",
                      style: AppStyle.priceText,
                    ),

                    InkWell(
                      onTap: (){},
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(color: AppColor.blue2Color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.add,size: 18,color: AppColor.white2Color,),
                      ),
                    )
                  ],
                )

              ],
            ),
          )
        ],
      ),
    );
  }
}
