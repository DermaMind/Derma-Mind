import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final String title;
  const SearchBarWidget({super.key,required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,

      decoration: BoxDecoration(
        color: AppColor.white2Color,
        borderRadius: BorderRadius.circular(25),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),

      child: TextField(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 14),


          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade600,
            size: 24,
          ),


          hintText: title,
          hintStyle: AppStyle.regular.copyWith(
            color: Colors.grey.shade500,
          ),


          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),


          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: AppColor.blueColor,
              width: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}